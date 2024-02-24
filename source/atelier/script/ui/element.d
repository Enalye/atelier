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

package void loadLibUI_element(GrLibDefinition library) {
    library.setModule("ui.element");
    library.setModuleInfo(GrLocale.fr_FR, "Élément d’interface");

    library.setDescription(GrLocale.fr_FR, "Alignement horizontal");
    GrType alignXType = library.addEnum("UIAlignX", ["left", "center", "right"]);

    library.setDescription(GrLocale.fr_FR, "Alignement vertical");
    GrType alignYType = library.addEnum("UIAlignY", ["top", "center", "bottom"]);

    GrType stateType = grGetNativeType("UIState");

    GrType elementType = library.addNative("UIElement");

    GrType imageType = grGetNativeType("Image");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.setDescription(GrLocale.fr_FR, "Crée un élément d’interface");
    library.addConstructor(&_ctor, elementType);

    library.setDescription(GrLocale.fr_FR, "Position relatif au parent");
    library.addProperty(&_position!"get", &_position!"set", "position", elementType, vec2fType);

    library.setDescription(GrLocale.fr_FR, "Taille de l’interface");
    library.addProperty(&_size!"get", &_size!"set", "size", elementType, vec2fType);

    library.setDescription(GrLocale.fr_FR, "Facteur d’échelle de l’interface");
    library.addProperty(&_scale!"get", &_scale!"set", "scale", elementType, vec2fType);

    library.setDescription(GrLocale.fr_FR, "Point de rotation de l’interface");
    library.addProperty(&_pivot!"get", &_pivot!"set", "pivot", elementType, vec2fType);

    library.setDescription(GrLocale.fr_FR, "Rotation de l’interface");
    library.addProperty(&_angle!"get", &_angle!"set", "angle", elementType, grDouble);

    library.setDescription(GrLocale.fr_FR, "Couleur de l’interface");
    library.addProperty(&_color!"get", &_color!"set", "color", elementType, grFloat);

    library.setDescription(GrLocale.fr_FR, "Opacité de l’interface");
    library.addProperty(&_alpha!"get", &_alpha!"set", "alpha", elementType, grFloat);

    library.setDescription(GrLocale.fr_FR, "Fixe l’alignement de l’interface.
Détermine à partir d’où la position de l’interface sera calculé par rapport au parent.");
    library.setParameters(["ui", "alignX", "alignY"]);
    library.addFunction(&_setAlign, "setAlign", [
            elementType, alignXType, alignYType
        ]);

    library.setDescription(GrLocale.fr_FR, "Alignement horizontal");
    library.addProperty(&_alignX!"get", &_alignX!"set", "alignX", elementType, alignXType);

    library.setDescription(GrLocale.fr_FR, "Alignement vertical");
    library.addProperty(&_alignY!"get", &_alignY!"set", "alignY", elementType, alignYType);

    library.setDescription(GrLocale.fr_FR, "Survolé ?");
    library.addProperty(&_isHovered, null, "isHovered", elementType, grBool);

    library.setDescription(GrLocale.fr_FR, "Focus ?");
    library.addProperty(&_hasFocus, null, "hasFocus", elementType, grBool);

    library.setDescription(GrLocale.fr_FR, "Pressé ?");
    library.addProperty(&_isPressed, null, "isPressed", elementType, grBool);

    library.setDescription(GrLocale.fr_FR, "Sélectionné ?");
    library.addProperty(&_isSelected!"get", &_isSelected!"set",
        "isSelected", elementType, grBool);

    library.setDescription(GrLocale.fr_FR, "Actif ?");
    library.addProperty(&_isActive!"get", &_isActive!"set", "isActive", elementType, grBool);

    library.setDescription(GrLocale.fr_FR, "L’interface est saisie ?");
    library.addProperty(&_isGrabbed, null, "isEnabled", elementType, grBool);

    library.setDescription(GrLocale.fr_FR, "Active/désactive l’interface");
    library.addProperty(&_isEnabled!"get", &_isEnabled!"set", "isEnabled", elementType, grBool);

    /*
    library.addProperty(&_hovered, null, "hovered", elementType, grBool);
    library.addProperty(&_focused, null, "focused", elementType, grBool);
    library.addProperty(&_pressed, null, "pressed", elementType, grBool);

    library.addProperty(&_onPress!"get", &_onPress!"set", "onSubmit",
        elementType, grOptional(grEvent()));*/

    library.setDescription(GrLocale.fr_FR, "Ajoute un état à l’interface.");
    library.setParameters(["ui", "state"]);
    library.addFunction(&_addState, "addState", [elementType, stateType]);

    library.setDescription(GrLocale.fr_FR,
        "Fixe l’état actuel de l’interface sans transition.");
    library.setParameters(["ui", "stateId"]);
    library.addFunction(&_setState, "setState", [elementType, grString]);

    library.setDescription(GrLocale.fr_FR,
        "Démarre la transition de l’interface de son état actuel vers son prochain état.");
    library.setParameters(["ui", "stateId"]);
    library.addFunction(&_runState, "runState", [elementType, grString]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une image à l’interface.");
    library.setParameters(["ui", "image"]);
    library.addFunction(&_addImage, "addImage", [elementType, imageType]);

    library.setDescription(GrLocale.fr_FR,
        "Ajoute une interface en tant qu’enfant de cette interface.");
    library.setParameters(["parent", "child"]);
    library.addFunction(&_addUI, "addUI", [elementType, elementType]);

    library.setDescription(GrLocale.fr_FR,
        "Supprime les éléments d’interface enfants du parent.");
    library.setParameters(["parent"]);
    library.addFunction(&_clearUI, "clearUI", [elementType]);

    library.setDescription(GrLocale.fr_FR, "Ajoute une fonction de rappel à un événement.");
    library.setParameters(["ui", "id", "callback"]);
    library.addFunction(&_addEventListener, "addEventListener", [
            elementType, grString, grEvent()
        ]);

    library.setDescription(GrLocale.fr_FR,
        "Supprime une fonction de rappel lié à un événement.");
    library.setParameters(["ui", "id", "callback"]);
    library.addFunction(&_removeEventListener, "removeEventListener",
        [elementType, grString, grEvent()]);

    library.setDescription(GrLocale.fr_FR, "Retire l’interface de l’arborescence.");
    library.setParameters(["ui"]);
    library.addFunction(&_remove, "remove", [elementType]);
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

    ui.states[state.name] = state;
}

private void _setState(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    const auto ptr = call.getString(1) in ui.states;
    if (!ptr) {
        call.raise("NullError");
        return;
    }

    ui.currentStateName = ptr.name;
    ui.initState = null;
    ui.targetState = null;
    ui.offset = ptr.offset;
    ui.scale = ptr.scale;
    ui.color = ptr.color;
    ui.angle = ptr.angle;
    ui.alpha = ptr.alpha;
    ui.timer.stop();
}

private void _runState(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    auto ptr = call.getString(1) in ui.states;
    if (!ptr) {
        call.raise("NullError");
        return;
    }

    ui.currentStateName = ptr.name;
    ui.initState = new UIElement.State;
    ui.initState.offset = ui.offset;
    ui.initState.scale = ui.scale;
    ui.initState.angle = ui.angle;
    ui.initState.alpha = ui.alpha;
    ui.initState.time = ui.timer.duration;
    ui.targetState = *ptr;
    ui.timer.start(ptr.time);
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
