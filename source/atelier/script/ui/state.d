/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.ui.state;

import std.conv : to;
import std.math;
import std.algorithm.comparison : min, max;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.script.util;

package void loadLibUI_state(GrLibDefinition library) {
    library.setModule("ui.state");
    library.setModuleInfo(GrLocale.fr_FR, "État d’un élément d’interface");

    GrType splineType = grGetEnumType("Spline");
    GrType stateType = library.addNative("UIState");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.addConstructor(&_ui_state_new, stateType, [grString]);

    library.addProperty(&_ui_state_offset!"get", &_ui_state_offset!"set",
        "offset", stateType, vec2fType);
    library.addProperty(&_ui_state_scale!"get", &_ui_state_scale!"set",
        "scale", stateType, vec2fType);
    library.addProperty(&_ui_state_angle!"get", &_ui_state_angle!"set",
        "angle", stateType, grDouble);
    library.addProperty(&_ui_state_alpha!"get", &_ui_state_alpha!"set",
        "alpha", stateType, grFloat);
    library.addProperty(&_ui_state_time!"get", &_ui_state_time!"set", "time", stateType, grInt);
    library.addProperty(&_ui_state_spline!"get", &_ui_state_spline!"set",
        "spline", stateType, splineType);
}

private void _ui_state_new(GrCall call) {
    UIElement.State state = new UIElement.State;

    state.name = call.getString(0);
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
    ui.offset = ptr.offset;
    ui.scale = ptr.scale;
    ui.angle = ptr.angle;
    ui.alpha = ptr.alpha;
    ui.timer.stop();
}
