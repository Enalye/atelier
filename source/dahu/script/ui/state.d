/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.ui.state;

import std.conv : to;
import std.math;
import std.algorithm.comparison : min, max;

import grimoire;

import dahu.common;
import dahu.core;
import dahu.ui;

package void loadLibUI_state(GrLibDefinition lib) {
    GrType splineType = grGetEnumType("Spline");
    GrType stateType = lib.addNative("UIState");

    lib.addConstructor(&_ui_state_new, stateType, [grString]);

    lib.addFunction(&_ui_state_setOffset, "setOffset", [
            stateType, grFloat, grFloat
        ]);
    lib.addProperty(&_ui_state_offsetX!"get", &_ui_state_offsetX!"set",
        "offsetX", stateType, grFloat);
    lib.addProperty(&_ui_state_offsetY!"get", &_ui_state_offsetY!"set",
        "offsetY", stateType, grFloat);

    lib.addFunction(&_ui_state_setScale, "setScale", [
            stateType, grFloat, grFloat
        ]);
    lib.addProperty(&_ui_state_scaleX!"get", &_ui_state_scaleX!"set",
        "scaleX", stateType, grFloat);
    lib.addProperty(&_ui_state_scaleY!"get", &_ui_state_scaleY!"set",
        "scaleY", stateType, grFloat);

    lib.addProperty(&_ui_state_angle!"get", &_ui_state_angle!"set",
        "angle", stateType, grDouble);
    lib.addProperty(&_ui_state_alpha!"get", &_ui_state_alpha!"set",
        "alpha", stateType, grFloat);

    lib.addProperty(&_ui_state_time!"get", &_ui_state_time!"set", "time", stateType, grInt);
    lib.addProperty(&_ui_state_spline!"get", &_ui_state_spline!"set",
        "spline", stateType, splineType);

}

private void _ui_state_new(GrCall call) {
    UIElement.State state = new UIElement.State;

    state.name = call.getString(0);
    call.setNative(state);
}

private void _ui_state_setOffset(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    state.offsetX = call.getFloat(1);
    state.offsetY = call.getFloat(2);
}

private void _ui_state_offsetX(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    static if (op == "set") {
        state.offsetX = call.getFloat(1);
    }
    call.setFloat(state.offsetX);
}

private void _ui_state_offsetY(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    static if (op == "set") {
        state.offsetY = call.getFloat(1);
    }
    call.setFloat(state.offsetY);
}

private void _ui_state_setScale(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    state.scaleX = call.getFloat(1);
    state.scaleY = call.getFloat(2);
}

private void _ui_state_scaleX(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    static if (op == "set") {
        state.scaleX = call.getFloat(1);
    }
    call.setFloat(state.scaleX);
}

private void _ui_state_scaleY(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    static if (op == "set") {
        state.scaleY = call.getFloat(1);
    }
    call.setFloat(state.scaleY);
}

private void _ui_state_angle(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    static if (op == "set") {
        state.angle = call.getDouble(1);
    }
    call.setDouble(state.angle);
}

private void _ui_state_alpha(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    static if (op == "set") {
        state.alpha = call.getFloat(1);
    }
    call.setFloat(state.alpha);
}

private void _ui_state_time(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    static if (op == "set") {
        state.time = call.getInt(1);
    }
    call.setInt(state.time);
}

private void _ui_state_spline(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    static if (op == "set") {
        state.spline = call.getEnum!Spline(1);
    }
    call.setEnum!Spline(state.spline);
}

private void _ui_addState(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    UIElement.State state = call.getNative!(UIElement.State)(1);

    ui.states[state.name] = state;
}

private void _ui_setState(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    const auto ptr = call.getString(1) in ui.states;
    if (!ptr) {
        call.raise("NullError");
        return;
    }

    ui.currentStateName = ptr.name;
    ui.initState = null;
    ui.targetState = null;
    ui.offsetX = ptr.offsetX;
    ui.offsetY = ptr.offsetY;
    ui.scaleX = ptr.scaleX;
    ui.scaleX = ptr.scaleX;
    ui.angle = ptr.angle;
    ui.alpha = ptr.alpha;
    ui.timer.stop();
}
