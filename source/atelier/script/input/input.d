/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.input.input;

import std.traits;

import grimoire;

import atelier.input;
import atelier.common;
import atelier.core;
import atelier.script.util;

void loadLibInput_input(GrLibDefinition library) {
    library.setModule("input.input");
    library.setModuleInfo(GrLocale.fr_FR, "Entrées utilisateur");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    GrType keyButton = grGetEnumType("KeyButton");
    GrType mouseButton = grGetEnumType("MouseButton");
    GrType controllerButton = grGetEnumType("ControllerButton");

    GrType inputType = library.addNative("Input");

    GrType inputEvent = grGetNativeType("InputEvent");

    library.setDescription(GrLocale.fr_FR, "La touche est-elle appuyée sur cette frame ?");
    library.setParameters(["input"]);
    library.addStatic(&_isDown!(InputEvent.KeyButton.Button), inputType,
        "isDown", [keyButton], [grBool]);
    library.addStatic(&_isDown!(InputEvent.MouseButton.Button), inputType,
        "isDown", [mouseButton], [grBool]);
    library.addStatic(&_isDown!(InputEvent.ControllerButton.Button),
        inputType, "isDown", [controllerButton], [grBool]);

    library.setDescription(GrLocale.fr_FR, "La touche est-elle relâchée sur cette frame ?");
    library.setParameters(["input"]);
    library.addStatic(&_isUp!(InputEvent.KeyButton.Button), inputType,
        "isUp", [keyButton], [grBool]);
    library.addStatic(&_isUp!(InputEvent.MouseButton.Button), inputType,
        "isUp", [mouseButton], [grBool]);
    library.addStatic(&_isUp!(InputEvent.ControllerButton.Button), inputType,
        "isUp", [controllerButton], [grBool]);

    library.setDescription(GrLocale.fr_FR, "La touche est-elle enfoncée ?");
    library.setParameters(["input"]);
    library.addStatic(&_isHeld!(InputEvent.KeyButton.Button), inputType,
        "isHeld", [keyButton], [grBool]);
    library.addStatic(&_isHeld!(InputEvent.MouseButton.Button), inputType,
        "isHeld", [mouseButton], [grBool]);
    library.addStatic(&_isHeld!(InputEvent.ControllerButton.Button),
        inputType, "isHeld", [controllerButton], [grBool]);

    library.setDescription(GrLocale.fr_FR, "La touche est-elle pressée ?");
    library.setParameters(["input"]);
    library.addStatic(&_isPressed!(InputEvent.KeyButton.Button), inputType,
        "isPressed", [keyButton], [grBool]);
    library.addStatic(&_isPressed!(InputEvent.MouseButton.Button), inputType,
        "isPressed", [mouseButton], [grBool]);
    library.addStatic(&_isPressed!(InputEvent.ControllerButton.Button),
        inputType, "isPressed", [controllerButton], [grBool]);

    // Action

    library.setDescription(GrLocale.fr_FR, "Défini une nouvelle action");
    library.setParameters(["action"]);
    library.addStatic(&_addAction, inputType, "addAction", [grString]);

    library.setDescription(GrLocale.fr_FR, "Supprime une action existante");
    library.setParameters(["action"]);
    library.addStatic(&_removeAction, inputType, "removeAction", [grString]);

    library.setDescription(GrLocale.fr_FR, "Vérifie si l’action existe");
    library.setParameters(["action"]);
    library.addStatic(&_hasAction, inputType, "hasAction", [grString], [grBool]);

    library.setDescription(GrLocale.fr_FR, "L’événement correspond-il a l’action ?");
    library.setParameters(["action", "event"]);
    library.addStatic(&_isAction, inputType, "isAction", [grString, inputEvent], [
            grBool
        ]);

    library.setDescription(GrLocale.fr_FR, "Associe un événement à une action");
    library.setParameters(["action", "event"]);
    library.addStatic(&_addActionEvent, inputType, "addActionEvent", [
            grString, inputEvent
        ]);

    library.setDescription(GrLocale.fr_FR, "Supprime les événements associés à une action");
    library.setParameters(["action"]);
    library.addStatic(&_removeActionEvents, inputType, "removeActionEvents", [
            grString
        ]);

    library.setDescription(GrLocale.fr_FR, "L’action a-t’elle été déclenchée ?");
    library.setParameters(["action"]);
    library.addStatic(&_isActionActivated, inputType, "isActionActivated", [
            grString
        ], [grBool]);

    library.setDescription(GrLocale.fr_FR, "Récupère l’intensité de l’action");
    library.setParameters(["action"]);
    library.addStatic(&_getActionStrength, inputType, "getActionStrength", [
            grString
        ], [grFloat]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère l’intensité sous forme d’un axe défini par 2 actions (l’un positif, l’autre négatif)");
    library.setParameters(["negative", "positive"]);
    library.addStatic(&_getActionAxis, inputType, "getActionAxis", [
            grString, grString
        ], [grFloat]);

    library.setDescription(GrLocale.fr_FR,
        "Récupère l’intensité sous forme d’un vecteur défini par 4 actions");
    library.setParameters(["left", "right", "up", "down"]);
    library.addStatic(&_getActionVector, inputType, "getActionVector",
        [grString, grString, grString, grString], [vec2fType]);
}

private void _isDown(T)(GrCall call) {
    call.setBool(Atelier.input.isDown(call.getEnum!T(0)));
}

private void _isUp(T)(GrCall call) {
    call.setBool(Atelier.input.isUp(call.getEnum!T(0)));
}

private void _isHeld(T)(GrCall call) {
    call.setBool(Atelier.input.isHeld(call.getEnum!T(0)));
}

private void _isPressed(T)(GrCall call) {
    call.setBool(Atelier.input.isPressed(call.getEnum!T(0)));
}

private void _getAxis(GrCall call) {
    call.setFloat(Atelier.input.getAxis(call.getEnum!(InputEvent.ControllerAxis.Axis)(0)));
}

// Action

private void _addAction(GrCall call) {
    Atelier.input.addAction(call.getString(0));
}

private void _removeAction(GrCall call) {
    Atelier.input.removeAction(call.getString(0));
}

private void _hasAction(GrCall call) {
    call.setBool(Atelier.input.hasAction(call.getString(0)));
}

private void _isAction(GrCall call) {
    call.setBool(Atelier.input.isAction(call.getString(0), call.getNative!InputEvent(1)));
}

private void _addActionEvent(GrCall call) {
    Atelier.input.addActionEvent(call.getString(0), call.getNative!InputEvent(1));
}

private void _removeActionEvents(GrCall call) {
    Atelier.input.removeActionEvents(call.getString(0));
}

private void _isActionActivated(GrCall call) {
    call.setBool(Atelier.input.activated(call.getString(0)));
}

private void _getActionStrength(GrCall call) {
    call.setFloat(Atelier.input.getActionStrength(call.getString(0)));
}

private void _getActionAxis(GrCall call) {
    call.setFloat(Atelier.input.getActionAxis(call.getString(0), call.getString(1)));
}

private void _getActionVector(GrCall call) {
    call.setNative(svec2(Atelier.input.getActionVector(call.getString(0),
            call.getString(1), call.getString(2), call.getString(3))));
}
