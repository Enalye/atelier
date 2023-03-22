/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.input;

import std.traits;

import grimoire;

import dahu.input;
import dahu.common;
import dahu.core;

void loadLibInput(GrLibDefinition lib) {
    GrType keyButton = lib.addEnum("KeyButton", [
            __traits(allMembers, InputEvent.KeyButton.Button)
        ], cast(GrInt[])[EnumMembers!(InputEvent.KeyButton.Button)]);

    GrType mouseButton = lib.addEnum("MouseButton", [
            __traits(allMembers, InputEvent.MouseButton.Button)
        ], cast(GrInt[])[EnumMembers!(InputEvent.MouseButton.Button)]);

    GrType controllerButton = lib.addEnum("ControllerButton", [
            __traits(allMembers, InputEvent.ControllerButton.Button)
        ], cast(GrInt[])[EnumMembers!(InputEvent.ControllerButton.Button)]);

    GrType controllerAxis = lib.addEnum("ControllerAxis", [
            __traits(allMembers, InputEvent.ControllerAxis.Axis)
        ], cast(GrInt[])[EnumMembers!(InputEvent.ControllerAxis.Axis)]);

    GrType inputEventType = lib.addEnum("InputEventType", [
            __traits(allMembers, InputEvent.Type)
        ]);

    GrType inputEvent = lib.addNative("InputEvent");
    GrType inputEventKeyButton = lib.addNative("InputEventKeyButton");
    GrType inputEventMouseButton = lib.addNative("InputEventMouseButton");
    GrType inputEventMouseMotion = lib.addNative("InputEventMouseMotion");
    GrType inputEventMouseWheel = lib.addNative("InputEventMouseWheel");
    GrType inputEventControllerButton = lib.addNative("InputEventControllerButton");
    GrType inputEventControllerAxis = lib.addNative("InputEventControllerAxis");
    GrType inputEventTextInput = lib.addNative("InputEventTextInput");
    GrType inputEventDropFile = lib.addNative("InputEventDropFile");

    // InputEvent
    lib.addCast(&_asString, inputEvent, grString);
    lib.addProperty(&_type, null, "type", inputEvent, inputEventType);
    lib.addFunction(&_inputEvent_isPressed, "isPressed", [inputEvent], [grBool]);
    lib.addFunction(&_inputEvent_isEcho, "isEcho", [inputEvent], [grBool]);

    lib.addProperty(&_keyButton, null, "keyButton", inputEvent, grOptional(inputEventKeyButton));
    lib.addProperty(&_mouseButton, null, "mouseButton", inputEvent,
        grOptional(inputEventMouseButton));
    lib.addProperty(&_mouseMotion, null, "mouseMotion", inputEvent,
        grOptional(inputEventMouseMotion));
    lib.addProperty(&_mouseWheel, null, "mouseWheel", inputEvent,
        grOptional(inputEventMouseWheel));
    lib.addProperty(&_controllerButton, null, "controllerButton", inputEvent,
        grOptional(inputEventControllerButton));
    lib.addProperty(&_controllerAxis, null, "controllerAxis", inputEvent,
        grOptional(inputEventControllerAxis));
    lib.addProperty(&_textInput, null, "textInput", inputEvent, grOptional(inputEventTextInput));
    lib.addProperty(&_dropFile, null, "dropFile", inputEvent, grOptional(inputEventDropFile));

    lib.addFunction(&_accept, "accept", [inputEvent]);
    lib.addFunction(&_print, "print", [inputEvent]);

    // KeyButton
    lib.addProperty(&_KeyButton_button, null, "button", inputEventKeyButton, keyButton);
    lib.addProperty(&_KeyButton_pressed, null, "pressed", inputEventKeyButton, grBool);
    lib.addProperty(&_KeyButton_isEcho, null, "isEcho", inputEventKeyButton, grBool);

    // MouseButton
    lib.addProperty(&_MouseButton_button, null, "button", inputEventMouseButton, keyButton);
    lib.addProperty(&_MouseButton_pressed, null, "pressed", inputEventMouseButton, grBool);
    lib.addProperty(&_MouseButton_clicks, null, "clicks", inputEventMouseButton, grInt);
    lib.addProperty(&_MouseButton_x, null, "x", inputEventMouseButton, grFloat);
    lib.addProperty(&_MouseButton_y, null, "y", inputEventMouseButton, grFloat);

    // MouseMotion
    lib.addProperty(&_MouseMotion_x, null, "x", inputEventMouseMotion, grFloat);
    lib.addProperty(&_MouseMotion_y, null, "y", inputEventMouseMotion, grFloat);
    lib.addProperty(&_MouseMotion_deltaX, null, "deltaX", inputEventMouseMotion, grFloat);
    lib.addProperty(&_MouseMotion_deltaY, null, "deltaY", inputEventMouseMotion, grFloat);

    // MouseWheel
    lib.addProperty(&_MouseWheel_x, null, "x", inputEventMouseWheel, grFloat);
    lib.addProperty(&_MouseWheel_y, null, "y", inputEventMouseWheel, grFloat);

    // ControllerButton
    lib.addProperty(&_ControllerButton_button, null, "button",
        inputEventControllerButton, controllerButton);
    lib.addProperty(&_ControllerButton_pressed, null, "pressed",
        inputEventControllerButton, grBool);

    // ControllerAxis
    lib.addProperty(&_ControllerAxis_axis, null, "axis",
        inputEventControllerAxis, controllerButton);
    lib.addProperty(&_ControllerAxis_value, null, "value", inputEventControllerAxis, grFloat);

    // TextInput
    lib.addProperty(&_TextInput_text, null, "text", inputEventTextInput, grString);

    // DropFile
    lib.addProperty(&_DropFile_path, null, "path", inputEventDropFile, grString);

    // Input

    lib.addStatic(&_makeKeyButton, inputEvent, "keyButton", [
            keyButton, grBool, grBool
        ], [inputEvent]);

    lib.addStatic(&_makeMouseButton, inputEvent, "mouseButton", [
            mouseButton, grBool, grInt, grInt, grInt, grInt, grInt
        ], [inputEvent]);

    lib.addStatic(&_makeMouseMotion, inputEvent, "mouseMotion", [
            grInt, grInt, grInt, grInt
        ], [inputEvent]);

    lib.addStatic(&_makeMouseWheel, inputEvent, "mouseWheel", [grInt, grInt], [
            inputEvent
        ]);

    lib.addStatic(&_makeControllerButton, inputEvent, "controllerButton",
        [controllerButton, grBool], [inputEvent]);

    lib.addStatic(&_makeControllerAxis, inputEvent, "controllerAxis",
        [controllerAxis, grFloat], [inputEvent]);

    lib.addStatic(&_makeTextInput, inputEvent, "textInput", [grString], [
            inputEvent
        ]);

    lib.addStatic(&_makeDropFile, inputEvent, "dropFile", [grString], [
            inputEvent
        ]);

    lib.addFunction(&_isPressed!(InputEvent.KeyButton.Button), "isPressed",
        [keyButton], [grBool]);
    lib.addFunction(&_isPressed!(InputEvent.MouseButton.Button), "isPressed",
        [mouseButton], [grBool]);
    lib.addFunction(&_isPressed!(InputEvent.ControllerButton.Button),
        "isPressed", [controllerButton], [grBool]);

    // Action

    lib.addFunction(&_addAction, "addAction", [grString, grFloat]);
    lib.addFunction(&_removeAction, "removeAction", [grString]);
    lib.addFunction(&_hasAction, "hasAction", [grString], [grBool]);
    lib.addFunction(&_isAction, "isAction", [inputEvent, grString], [grBool]);
    lib.addFunction(&_addActionEvent, "addActionEvent", [grString, inputEvent]);
    lib.addFunction(&_removeActionEvents, "removeActionEvents", [grString]);
    lib.addFunction(&_isActionPressed, "isActionPressed", [grString], [grBool]);
    lib.addFunction(&_getActionStrength, "getActionStrength", [grString], [
            grFloat
        ]);
    lib.addFunction(&_getActionAxis, "getActionAxis", [grString, grString], [
            grFloat
        ]);

}

private void _asString(GrCall call) {
    call.setString(call.getNative!InputEvent(0).prettify());
}

private void _type(GrCall call) {
    call.setEnum(call.getNative!InputEvent(0).type);
}

private void _inputEvent_isPressed(GrCall call) {
    call.setBool(call.getNative!InputEvent(0).isPressed());
}

private void _inputEvent_isEcho(GrCall call) {
    call.setBool(call.getNative!InputEvent(0).isEcho());
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

private void _KeyButton_pressed(GrCall call) {
    call.setBool(call.getNative!(InputEvent.KeyButton)(0).pressed);
}

private void _KeyButton_isEcho(GrCall call) {
    call.setBool(call.getNative!(InputEvent.KeyButton)(0).isEcho);
}

// MouseButton

private void _MouseButton_button(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.MouseButton)(0).button);
}

private void _MouseButton_pressed(GrCall call) {
    call.setBool(call.getNative!(InputEvent.MouseButton)(0).pressed);
}

private void _MouseButton_clicks(GrCall call) {
    call.setInt(call.getNative!(InputEvent.MouseButton)(0).clicks);
}

private void _MouseButton_x(GrCall call) {
    call.setFloat(call.getNative!(InputEvent.MouseButton)(0).x);
}

private void _MouseButton_y(GrCall call) {
    call.setFloat(call.getNative!(InputEvent.MouseButton)(0).y);
}

// MouseMotion

private void _MouseMotion_x(GrCall call) {
    call.setFloat(call.getNative!(InputEvent.MouseMotion)(0).x);
}

private void _MouseMotion_y(GrCall call) {
    call.setFloat(call.getNative!(InputEvent.MouseMotion)(0).y);
}

private void _MouseMotion_deltaX(GrCall call) {
    call.setFloat(call.getNative!(InputEvent.MouseMotion)(0).deltaX);
}

private void _MouseMotion_deltaY(GrCall call) {
    call.setFloat(call.getNative!(InputEvent.MouseMotion)(0).deltaY);
}

// MouseWheel

private void _MouseWheel_x(GrCall call) {
    call.setFloat(call.getNative!(InputEvent.MouseWheel)(0).x);
}

private void _MouseWheel_y(GrCall call) {
    call.setFloat(call.getNative!(InputEvent.MouseWheel)(0).y);
}

// ControllerButton

private void _ControllerButton_button(GrCall call) {
    call.setEnum(call.getNative!(InputEvent.ControllerButton)(0).button);
}

private void _ControllerButton_pressed(GrCall call) {
    call.setBool(call.getNative!(InputEvent.ControllerButton)(0).pressed);
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

private void _makeKeyButton(GrCall call) {
    call.setNative(InputEvent.keyButton(call.getEnum!(InputEvent.KeyButton.Button)(0),
            call.getBool(1), call.getBool(2)));
}

private void _makeMouseButton(GrCall call) {
    call.setNative(InputEvent.mouseButton(call.getEnum!(InputEvent.MouseButton.Button)(0),
            call.getBool(1), call.getInt(2), call.getInt(3), call.getInt(4)));
}

private void _makeMouseMotion(GrCall call) {
    call.setNative(InputEvent.mouseMotion(call.getInt(0), call.getInt(1),
            call.getInt(2), call.getInt(3)));
}

private void _makeMouseWheel(GrCall call) {
    call.setNative(InputEvent.mouseWheel(call.getInt(0), call.getInt(1)));
}

private void _makeControllerButton(GrCall call) {
    call.setNative(InputEvent.controllerButton(
            call.getEnum!(InputEvent.ControllerButton.Button)(0), call.getBool(1)));
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

private void _isPressed(T)(GrCall call) {
    call.setBool(app.input.isPressed(call.getEnum!T(0)));
}

private void _getAxis(GrCall call) {
    call.setFloat(app.input.getAxis(call.getEnum!(InputEvent.ControllerAxis.Axis)(0)));
}

// Action

private void _addAction(GrCall call) {
    app.input.addAction(call.getString(0), call.getFloat(1));
}

private void _removeAction(GrCall call) {
    app.input.removeAction(call.getString(0));
}

private void _hasAction(GrCall call) {
    call.setBool(app.input.hasAction(call.getString(0)));
}

private void _isAction(GrCall call) {
    call.setBool(app.input.isAction(call.getString(1), call.getNative!InputEvent(0)));
}

private void _addActionEvent(GrCall call) {
    app.input.addActionEvent(call.getString(0), call.getNative!InputEvent(1));
}

private void _removeActionEvents(GrCall call) {
    app.input.removeActionEvents(call.getString(0));
}

private void _isActionPressed(GrCall call) {
    call.setBool(app.input.isPressed(call.getString(0)));
}

private void _getActionStrength(GrCall call) {
    call.setFloat(app.input.getActionStrength(call.getString(0)));
}

private void _getActionAxis(GrCall call) {
    call.setFloat(app.input.getActionAxis(call.getString(0), call.getString(1)));
}
