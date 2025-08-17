module atelier.script.ui.state;

import std.conv : to;
import std.math;
import std.algorithm.comparison : min, max;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.script.util;

package void loadLibUI_state(GrModule mod) {
    mod.setModule("ui.state");
    mod.setModuleInfo(GrLocale.fr_FR, "État d’un élément d’interface");

    GrType splineType = grGetEnumType("Spline");
    GrType stateType = mod.addNative("UIState");
    GrType colorType = grGetNativeType("Color");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    mod.addConstructor(&_ui_state_new, stateType, [grString]);

    mod.addProperty(&_ui_state_offset!"get", &_ui_state_offset!"set",
        "offset", stateType, vec2fType);
    mod.addProperty(&_ui_state_scale!"get", &_ui_state_scale!"set",
        "scale", stateType, vec2fType);
    mod.addProperty(&_ui_state_angle!"get", &_ui_state_angle!"set",
        "angle", stateType, grDouble);
    mod.addProperty(&_ui_state_color!"get", &_ui_state_color!"set",
        "color", stateType, colorType);
    mod.addProperty(&_ui_state_alpha!"get", &_ui_state_alpha!"set",
        "alpha", stateType, grFloat);
    mod.addProperty(&_ui_state_time!"get", &_ui_state_time!"set", "time", stateType, grInt);
    mod.addProperty(&_ui_state_spline!"get", &_ui_state_spline!"set",
        "spline", stateType, splineType);
}

private void _ui_state_new(GrCall call) {
    UIElement.State state = new UIElement.State(call.getString(0));
    call.setNative(state);
}

private void _ui_state_offset(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    static if (op == "set") {
        state.offset = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(state.offset));
}

private void _ui_state_scale(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    static if (op == "set") {
        state.scale = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(state.scale));
}

private void _ui_state_angle(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    static if (op == "set") {
        state.angle = call.getDouble(1);
    }
    call.setDouble(state.angle);
}

private void _ui_state_color(string op)(GrCall call) {
    UIElement.State state = call.getNative!(UIElement.State)(0);

    static if (op == "set") {
        state.color = call.getNative!SColor(1);
    }
    call.setNative(scolor(state.color));
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
