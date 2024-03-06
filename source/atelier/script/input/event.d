/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.input.event;

import std.traits;

import grimoire;

import atelier.input;
import atelier.common;
import atelier.core;
import atelier.script.util;

void loadLibInput_event(GrLibDefinition library) {
    library.setModule("input.event");
    library.setModuleInfo(GrLocale.fr_FR, "Événements d’entrée");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.setDescription(GrLocale.fr_FR, "État d’une entrée");
    GrType keyState = library.addEnum("KeyState", grNativeEnum!(KeyState));

    library.setDescription(GrLocale.fr_FR, "Touche du clavier");
    GrType keyButton = library.addEnum("KeyButton", grNativeEnum!(InputEvent.KeyButton.Button));

    library.setDescription(GrLocale.fr_FR, "Bouton de la souris");
    GrType mouseButton = library.addEnum("MouseButton",
        grNativeEnum!(InputEvent.MouseButton.Button));

    library.setDescription(GrLocale.fr_FR, "Bouton de la manette");
    GrType controllerButton = library.addEnum("ControllerButton",
        grNativeEnum!(InputEvent.ControllerButton.Button));

    library.setDescription(GrLocale.fr_FR, "Axe de la manette");
    GrType controllerAxis = library.addEnum("ControllerAxis",
        grNativeEnum!(InputEvent.ControllerAxis.Axis));

    library.setDescription(GrLocale.fr_FR, "Type d’événement");
    GrType inputEventType = library.addEnum("InputEventType", grNativeEnum!(InputEvent.Type));

    GrType inputEvent = library.addNative("InputEvent");
    GrType inputEventKeyButton = library.addNative("InputEventKeyButton");
    GrType inputEventMouseButton = library.addNative("InputEventMouseButton");
    GrType inputEventMouseMotion = library.addNative("InputEventMouseMotion");
    GrType inputEventMouseWheel = library.addNative("InputEventMouseWheel");
    GrType inputEventControllerButton = library.addNative("InputEventControllerButton");
    GrType inputEventControllerAxis = library.addNative("InputEventControllerAxis");
    GrType inputEventTextInput = library.addNative("InputEventTextInput");
    GrType inputEventDropFile = library.addNative("InputEventDropFile");

    // InputEvent
    library.addCast(&_asString, inputEvent, grString);
    library.addProperty(&_type, null, "type", inputEvent, inputEventType);

    library.setDescription(GrLocale.fr_FR, "L’événement correspond-il à l’action ?");
    library.setParameters(["event", "action"]);
    library.addFunction(&_isAction, "isAction", [inputEvent, grString], [grBool]);

    library.setDescription(GrLocale.fr_FR, "La touche est-elle active ?");
    library.addFunction(&_inputEvent_isPressed, "isPressed", [inputEvent], [
            grBool
        ]);

    library.setDescription(GrLocale.fr_FR, "L’événement est-il déclenché par répétition ?");
    library.addFunction(&_inputEvent_echo, "echo", [inputEvent], [grBool]);

    library.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventKeyButton, retourne le type.");
    library.addProperty(&_keyButton, null, "keyButton", inputEvent,
        grOptional(inputEventKeyButton));

    library.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventMouseButton, retourne le type.");
    library.addProperty(&_mouseButton, null, "mouseButton", inputEvent,
        grOptional(inputEventMouseButton));

    library.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventMouseMotion, retourne le type.");
    library.addProperty(&_mouseMotion, null, "mouseMotion", inputEvent,
        grOptional(inputEventMouseMotion));

    library.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventMouseWheel, retourne le type.");
    library.addProperty(&_mouseWheel, null, "mouseWheel", inputEvent,
        grOptional(inputEventMouseWheel));

    library.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventControllerButton, retourne le type.");
    library.addProperty(&_controllerButton, null, "controllerButton",
        inputEvent, grOptional(inputEventControllerButton));

    library.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventControllerAxis, retourne le type.");
    library.addProperty(&_controllerAxis, null, "controllerAxis", inputEvent,
        grOptional(inputEventControllerAxis));

    library.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventTextInput, retourne le type.");
    library.addProperty(&_textInput, null, "textInput", inputEvent,
        grOptional(inputEventTextInput));

    library.setDescription(GrLocale.fr_FR,
        "Si l’événement est de type InputEventDropFile, retourne le type.");
    library.addProperty(&_dropFile, null, "dropFile", inputEvent, grOptional(inputEventDropFile));

    library.setDescription(GrLocale.fr_FR, "Consomme l’événement.");
    library.addFunction(&_accept, "accept", [inputEvent]);

    library.setDescription(GrLocale.fr_FR, "Affiche le contenu de l’événement.");
    library.addFunction(&_print, "print", [inputEvent]);

    // KeyButton
    library.addProperty(&_KeyButton_button, null, "button", inputEventKeyButton, keyButton);
    library.addProperty(&_KeyButton_state, null, "state", inputEventKeyButton, keyState);
    library.addProperty(&_KeyButton_echo, null, "echo", inputEventKeyButton, grBool);

    // MouseButton
    library.addProperty(&_MouseButton_button, null, "button", inputEventMouseButton, keyButton);
    library.addProperty(&_MouseButton_state, null, "state", inputEventMouseButton, keyState);
    library.addProperty(&_MouseButton_clicks, null, "clicks", inputEventMouseButton, grInt);
    library.addProperty(&_MouseButton_position, null, "position",
        inputEventMouseButton, vec2fType);
    library.addProperty(&_MouseButton_deltaPosition, null, "deltaPosition",
        inputEventMouseButton, vec2fType);

    // MouseMotion
    library.addProperty(&_MouseMotion_position, null, "position",
        inputEventMouseMotion, vec2fType);
    library.addProperty(&_MouseMotion_deltaPosition, null, "deltaPosition",
        inputEventMouseMotion, vec2fType);

    // MouseWheel
    library.addProperty(&_MouseWheel_x, null, "x", inputEventMouseWheel, grInt);
    library.addProperty(&_MouseWheel_y, null, "y", inputEventMouseWheel, grInt);

    // ControllerButton
    library.addProperty(&_ControllerButton_button, null, "button",
        inputEventControllerButton, controllerButton);
    library.addProperty(&_ControllerButton_state, null, "state",
        inputEventControllerButton, keyState);

    // ControllerAxis
    library.addProperty(&_ControllerAxis_axis, null, "axis",
        inputEventControllerAxis, controllerButton);
    library.addProperty(&_ControllerAxis_value, null, "value", inputEventControllerAxis, grFloat);

    // TextInput
    library.addProperty(&_TextInput_text, null, "text", inputEventTextInput, grString);

    // DropFile
    library.addProperty(&_DropFile_path, null, "path", inputEventDropFile, grString);

    // Input

    library.setDescription(GrLocale.fr_FR, "Crée un événement clavier.");
    library.addStatic(&_makeKeyButton1, inputEvent, "keyButton", [
            keyButton, keyState
        ], [inputEvent]);

    library.addStatic(&_makeKeyButton2, inputEvent, "keyButton", [
            keyButton, keyState, grBool
        ], [inputEvent]);

    library.setDescription(GrLocale.fr_FR, "Crée un événement bouton de souris.");
    library.addStatic(&_makeMouseButton, inputEvent, "mouseButton",
        [mouseButton, keyState, grInt, vec2fType, vec2fType], [inputEvent]);

    library.setDescription(GrLocale.fr_FR, "Crée un événement déplacement de souris.");
    library.addStatic(&_makeMouseMotion, inputEvent, "mouseMotion",
        [vec2fType, vec2fType], [inputEvent]);

    library.setDescription(GrLocale.fr_FR, "Crée un événement molette de souris.");
    library.addStatic(&_makeMouseWheel, inputEvent, "mouseWheel", [grInt, grInt], [
            inputEvent
        ]);

    library.setDescription(GrLocale.fr_FR, "Crée un événement bouton de manette.");
    library.addStatic(&_makeControllerButton, inputEvent, "controllerButton",
        [controllerButton, keyState], [inputEvent]);

    library.setDescription(GrLocale.fr_FR, "Crée un événement axe de manette.");
    library.addStatic(&_makeControllerAxis, inputEvent, "controllerAxis",
        [controllerAxis, grFloat], [inputEvent]);

    library.setDescription(GrLocale.fr_FR, "Crée un événement entrée textuelle.");
    library.addStatic(&_makeTextInput, inputEvent, "textInput", [grString], [
            inputEvent
        ]);

    library.setDescription(GrLocale.fr_FR, "Crée un événement fichier déposé.");
    library.addStatic(&_makeDropFile, inputEvent, "dropFile", [grString], [
            inputEvent
        ]);
}

private void _asString(GrCall call) {
    call.setString(call.getNative!InputEvent(0).prettify());
}

private void _type(GrCall call) {
    call.setEnum(call.getNative!InputEvent(0).type);
}

private void _isAction(GrCall call) {
    call.setBool(Atelier.input.isAction(call.getString(1), call.getNative!InputEvent(0)));
}

private void _inputEvent_isPressed(GrCall call) {
    call.setBool(call.getNative!InputEvent(0).pressed);
}

private void _inputEvent_echo(GrCall call) {
    call.setBool(call.getNative!InputEvent(0).echo);
}

private void _keyButton(GrCall call) {
    InputEvent.KeyButton keyButton = call.getNative!InputEvent(0).asKeyButton;
    if (keyButton)
        call.setNative(keyButton);
    else
        call.setNull();
}

private void _mouseButton(GrCall call) {
    InputEvent.MouseButton mouseButton = call.getNative!InputEvent(0).asMouseButton;
    if (mouseButton)
        call.setNative(mouseButton);
    else
        call.setNull();
}

private void _mouseMotion(GrCall call) {
    InputEvent.MouseMotion mouseMotion = call.getNative!InputEvent(0).asMouseMotion;
    if (mouseMotion)
        call.setNative(mouseMotion);
    else
        call.setNull();
}

private void _mouseWheel(GrCall call) {
    InputEvent.MouseWheel mouseWheel = call.getNative!InputEvent(0).asMouseWheel;
    if (mouseWheel)
        call.setNative(mouseWheel);
    else
        call.setNull();
}

private void _controllerButton(GrCall call) {
    InputEvent.ControllerButton controllerButton = call.getNative!InputEvent(0).asControllerButton;
    if (controllerButton)
        call.setNative(controllerButton);
    else
        call.setNull();
}

private void _controllerAxis(GrCall call) {
    InputEvent.ControllerAxis controllerAxis = call.getNative!InputEvent(0).asControllerAxis;
    if (controllerAxis)
        call.setNative(controllerAxis);
    else
        call.setNull();
}

private void _textInput(GrCall call) {
    InputEvent.TextInput textInput = call.getNative!InputEvent(0).asTextInput;
    if (textInput)
        call.setNative(textInput);
    else
        call.setNull();
}

private void _dropFile(GrCall call) {
    InputEvent.DropFile dropFile = call.getNative!InputEvent(0).asDropFile;
    if (dropFile)
        call.setNative(dropFile);
    else
        call.setNull();
}

private void _accept(GrCall call) {
    call.getNative!InputEvent(0).accept();
}

private void _print(GrCall call) {
    grPrint(call.getNative!InputEvent(0).prettify());
}

// KeyButton

private void _KeyButton_button(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.KeyButton)(0).button);
}

private void _KeyButton_state(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.KeyButton)(0).state);
}

private void _KeyButton_echo(GrCall call) {
    call.setBool(call.getNative!(InputEvent.KeyButton)(0).echo);
}

// MouseButton

private void _MouseButton_button(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.MouseButton)(0).button);
}

private void _MouseButton_state(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.MouseButton)(0).state);
}

private void _MouseButton_clicks(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseButton)(0).clicks);
}

private void _MouseButton_position(GrCall call) {
    call.setNative(svec2(call.getNative!(InputEvent.MouseButton)(0).position));
}

private void _MouseButton_deltaPosition(GrCall call) {
    call.setNative(svec2(call.getNative!(InputEvent.MouseButton)(0).deltaPosition));
}

// MouseMotion

private void _MouseMotion_position(GrCall call) {
    call.setNative(svec2(call.getNative!(InputEvent.MouseMotion)(0).position));
}

private void _MouseMotion_deltaPosition(GrCall call) {
    call.setNative(svec2(call.getNative!(InputEvent.MouseMotion)(0).deltaPosition));
}

// MouseWheel

private void _MouseWheel_x(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseWheel)(0).wheel.x);
}

private void _MouseWheel_y(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseWheel)(0).wheel.y);
}

// ControllerButton

private void _ControllerButton_button(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.ControllerButton)(0).button);
}

private void _ControllerButton_state(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.ControllerButton)(0).state);
}

// ControllerButton

private void _ControllerAxis_axis(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.ControllerAxis)(0).axis);
}

private void _ControllerAxis_value(GrCall call) {
    call.setFloat(call.getNative!(InputEvent.ControllerAxis)(0).value);
}

// TextInput

private void _TextInput_text(GrCall call) {
    call.setString(call.getNative!(InputEvent.TextInput)(0).text);
}

// DropFile

private void _DropFile_path(GrCall call) {
    call.setString(call.getNative!(InputEvent.DropFile)(0).path);
}

// Input

private void _makeKeyButton1(GrCall call) {
    call.setNative(InputEvent.keyButton(call.getEnum!(InputEvent.KeyButton.Button)(0),
            InputState(call.getEnum!KeyState(1))));
}

private void _makeKeyButton2(GrCall call) {
    call.setNative(InputEvent.keyButton(call.getEnum!(InputEvent.KeyButton.Button)(0),
            InputState(call.getEnum!KeyState(1)), call.getBool(2)));
}

private void _makeMouseButton(GrCall call) {
    call.setNative(InputEvent.mouseButton(call.getEnum!(InputEvent.MouseButton.Button)(0),
            InputState(call.getEnum!KeyState(1)), call.getInt(2),
            call.getNative!SVec2f(3), call.getNative!SVec2f(4)));
}

private void _makeMouseMotion(GrCall call) {
    call.setNative(InputEvent.mouseMotion(call.getNative!SVec2f(0), call.getNative!SVec2f(1)));
}

private void _makeMouseWheel(GrCall call) {
    call.setNative(InputEvent.mouseWheel(Vec2i(call.getInt(0), call.getInt(1))));
}

private void _makeControllerButton(GrCall call) {
    call.setNative(InputEvent.controllerButton(call.getEnum!(InputEvent.ControllerButton.Button)(0),
            InputState(call.getEnum!KeyState(1))));
}

private void _makeControllerAxis(GrCall call) {
    call.setNative(InputEvent.controllerAxis(
            call.getEnum!(InputEvent.ControllerAxis.Axis)(0), call.getFloat(1)));
}

private void _makeTextInput(GrCall call) {
    call.setNative(InputEvent.textInput(call.getString(0)));
}

private void _makeDropFile(GrCall call) {
    call.setNative(InputEvent.dropFile(call.getString(0)));
}
