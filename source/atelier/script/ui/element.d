/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.ui.element;

import std.conv : to;
import std.math;
import std.algorithm.comparison : min, max;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui;
import atelier.script.util;

package void loadLibUI_element(GrModule mod) {
    mod.setModule("ui.element");
    mod.setModuleInfo(GrLocale.fr_FR, "Élément d’interface");

    mod.setDescription(GrLocale.fr_FR, "Alignement horizontal");
    GrType alignXType = mod.addEnum("UIAlignX", ["left", "center", "right"]);

    mod.setDescription(GrLocale.fr_FR, "Alignement vertical");
    GrType alignYType = mod.addEnum("UIAlignY", ["top", "center", "bottom"]);

    GrType stateType = grGetNativeType("UIState");

    GrType elementType = mod.addNative("UIElement");

    GrType imageType = grGetNativeType("Image");
    GrType colorType = grGetNativeType("Color");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Crée un élément d’interface");
    mod.addConstructor(&_ctor, elementType);

    mod.setDescription(GrLocale.fr_FR, "Position relatif au parent");
    mod.addProperty(&_position!"get", &_position!"set", "position", elementType, vec2fType);

    mod.setDescription(GrLocale.fr_FR, "Position de la souris dans l’interface");
    mod.addProperty(&_mousePosition, null, "mousePosition", elementType, vec2fType);

    mod.setDescription(GrLocale.fr_FR, "Taille de l’interface");
    mod.addProperty(&_size!"get", &_size!"set", "size", elementType, vec2fType);

    mod.setDescription(GrLocale.fr_FR, "Facteur d’échelle de l’interface");
    mod.addProperty(&_scale!"get", &_scale!"set", "scale", elementType, vec2fType);

    mod.setDescription(GrLocale.fr_FR, "Point de rotation de l’interface");
    mod.addProperty(&_pivot!"get", &_pivot!"set", "pivot", elementType, vec2fType);

    mod.setDescription(GrLocale.fr_FR, "Rotation de l’interface");
    mod.addProperty(&_angle!"get", &_angle!"set", "angle", elementType, grDouble);

    mod.setDescription(GrLocale.fr_FR, "Couleur de l’interface");
    mod.addProperty(&_color!"get", &_color!"set", "color", elementType, colorType);

    mod.setDescription(GrLocale.fr_FR, "Opacité de l’interface");
    mod.addProperty(&_alpha!"get", &_alpha!"set", "alpha", elementType, grFloat);

    mod.setDescription(GrLocale.fr_FR, "Fixe l’alignement de l’interface.
Détermine à partir d’où la position de l’interface sera calculé par rapport au parent.");
    mod.setParameters(["ui", "alignX", "alignY"]);
    mod.addFunction(&_setAlign, "setAlign", [
            elementType, alignXType, alignYType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Alignement horizontal");
    mod.addProperty(&_alignX!"get", &_alignX!"set", "alignX", elementType, alignXType);

    mod.setDescription(GrLocale.fr_FR, "Alignement vertical");
    mod.addProperty(&_alignY!"get", &_alignY!"set", "alignY", elementType, alignYType);

    mod.setDescription(GrLocale.fr_FR, "Survolé ?");
    mod.addProperty(&_isHovered, null, "isHovered", elementType, grBool);

    mod.setDescription(GrLocale.fr_FR, "Focus ?");
    mod.addProperty(&_hasFocus, null, "hasFocus", elementType, grBool);

    mod.setDescription(GrLocale.fr_FR, "Pressé ?");
    mod.addProperty(&_isPressed, null, "isPressed", elementType, grBool);

    mod.setDescription(GrLocale.fr_FR, "Sélectionné ?");
    mod.addProperty(&_isSelected!"get", &_isSelected!"set", "isSelected", elementType, grBool);

    mod.setDescription(GrLocale.fr_FR, "Actif ?");
    mod.addProperty(&_isActive!"get", &_isActive!"set", "isActive", elementType, grBool);

    mod.setDescription(GrLocale.fr_FR, "L’interface est saisie ?");
    mod.addProperty(&_isGrabbed, null, "isGrabbed", elementType, grBool);

    mod.setDescription(GrLocale.fr_FR, "Active/désactive l’interface");
    mod.addProperty(&_isEnabled!"get", &_isEnabled!"set", "isEnabled", elementType, grBool);

    mod.setDescription(GrLocale.fr_FR, "Ajoute un état à l’interface.");
    mod.setParameters(["ui", "state"]);
    mod.addFunction(&_addState, "addState", [elementType, stateType]);

    mod.setDescription(GrLocale.fr_FR, "Retourne le nom de l’état actuel.");
    mod.setParameters(["ui"]);
    mod.addFunction(&_getState, "getState", [elementType], [grString]);

    mod.setDescription(GrLocale.fr_FR, "Fixe l’état actuel de l’interface sans transition.");
    mod.setParameters(["ui", "stateId"]);
    mod.addFunction(&_setState, "setState", [elementType, grString]);

    mod.setDescription(GrLocale.fr_FR,
        "Démarre la transition de l’interface de son état actuel vers son prochain état.");
    mod.setParameters(["ui", "stateId"]);
    mod.addFunction(&_runState, "runState", [elementType, grString]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute une image à l’interface.");
    mod.setParameters(["ui", "image"]);
    mod.addFunction(&_addImage, "addImage", [elementType, imageType]);

    mod.setDescription(GrLocale.fr_FR,
        "Ajoute une interface en tant qu’enfant de cette interface.");
    mod.setParameters(["parent", "child"]);
    mod.addFunction(&_addUI, "addUI", [elementType, elementType]);

    mod.setDescription(GrLocale.fr_FR, "Supprime les éléments d’interface enfants du parent.");
    mod.setParameters(["parent"]);
    mod.addFunction(&_clearUI, "clearUI", [elementType]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute une fonction de rappel à un événement.");
    mod.setParameters(["ui", "id", "callback"]);
    mod.addFunction(&_addEventListener, "addEventListener", [
            elementType, grString, grEvent()
        ]);

    mod.setDescription(GrLocale.fr_FR, "Supprime une fonction de rappel lié à un événement.");
    mod.setParameters(["ui", "id", "callback"]);
    mod.addFunction(&_removeEventListener, "removeEventListener",
        [elementType, grString, grEvent()]);

    mod.setDescription(GrLocale.fr_FR, "Retire l’interface de l’arborescence.");
    mod.setParameters(["ui"]);
    mod.addFunction(&_remove, "remove", [elementType]);
}

private void _ctor(GrCall call) {
    call.setNative(new UIElement);
}

private void _position(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.setPosition(call.getNative!SVec2f(1));
    }
    call.setNative(svec2(ui.getPosition()));
}

private void _mousePosition(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    call.setNative(svec2(ui.getMousePosition()));
}

private void _size(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.setSize(call.getNative!SVec2f(1));
    }
    call.setNative(svec2(ui.getSize()));
}

private void _scale(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.scale = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(ui.scale));
}

private void _pivot(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.setPivot(call.getNative!SVec2f(1));
    }
    call.setNative(svec2(ui.getPivot()));
}

private void _angle(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.angle = call.getDouble(1);
    }
    call.setDouble(ui.angle);
}

private void _color(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.color = call.getNative!SColor(1);
    }
    call.setNative(scolor(ui.color));
}

private void _alpha(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.alpha = call.getFloat(1);
    }
    call.setFloat(ui.alpha);
}

private void _setAlign(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    ui.setAlign(call.getEnum!(UIAlignX)(1), call.getEnum!(UIAlignY)(2));
}

private void _alignX(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.setAlign(call.getEnum!(UIAlignX)(1), ui.getAlignY());
    }
    call.setEnum!UIAlignX(ui.getAlignX());
}

private void _alignY(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.setAlign(ui.getAlignX(), call.getEnum!(UIAlignY)(1));
    }
    call.setEnum!UIAlignY(ui.getAlignY());
}

private void _isHovered(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    call.setBool(ui.isHovered);
}

private void _hasFocus(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    call.setBool(ui.hasFocus);
}

private void _isPressed(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    call.setBool(ui.isPressed);
}

private void _isSelected(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.isSelected = call.getBool(1);
    }

    call.setBool(ui.isSelected);
}

private void _isActive(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.isActive = call.getBool(1);
    }

    call.setBool(ui.isActive);
}

private void _isGrabbed(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    call.setBool(ui.isGrabbed);
}

private void _isEnabled(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.isEnabled = call.getBool(1);
    }

    call.setBool(ui.isEnabled);
}

private void _addState(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    UIElement.State state = call.getNative!(UIElement.State)(1);
    ui.addState(state);
}

private void _getState(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    call.setString(ui.getState());
}

private void _setState(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    ui.setState(call.getString(1));
}

private void _runState(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    ui.runState(call.getString(1));
}

private void _addImage(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    Image image = call.getNative!Image(1);

    ui.addImage(image);
}

private void _addUI(GrCall call) {
    UIElement uiParent = call.getNative!UIElement(0);
    UIElement uiChild = call.getNative!UIElement(1);

    uiParent.addUI(uiChild);
}

private void _clearUI(GrCall call) {
    UIElement uiParent = call.getNative!UIElement(0);

    uiParent.clearUI();
}

private void _addEventListener(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    string key = call.getString(1).str();
    GrEvent event = call.getEvent(2);

    ui.addEventListener(key, event);
}

private void _removeEventListener(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    string key = call.getString(1).str();
    GrEvent event = call.getEvent(2);

    ui.removeEventListener(key, event);
}

private void _remove(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    ui.remove();
}
