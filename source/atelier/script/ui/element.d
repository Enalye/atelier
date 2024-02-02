/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
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

    GrType alignXType = library.addEnum("UIAlignX", ["left", "center", "right"]);
    GrType alignYType = library.addEnum("UIAlignY", ["top", "center", "bottom"]);
    GrType stateType = grGetNativeType("UIState");

    GrType elementType = library.addNative("UIElement");

    GrType imageType = grGetNativeType("Image");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.addConstructor(&_ctor, elementType);

    library.addProperty(&_position!"get", &_position!"set", "position", elementType, vec2fType);
    library.addProperty(&_size!"get", &_size!"set", "size", elementType, vec2fType);
    library.addProperty(&_scale!"get", &_scale!"set", "scaleX", elementType, vec2fType);
    library.addProperty(&_pivot!"get", &_pivot!"set", "pivot", elementType, vec2fType);

    library.addProperty(&_angle!"get", &_angle!"set", "angle", elementType, grDouble);

    library.addProperty(&_alpha!"get", &_alpha!"set", "alpha", elementType, grFloat);

    library.addFunction(&_setAlign, "setAlign", [
            elementType, alignXType, alignYType
        ]);
    library.addProperty(&_alignX!"get", &_alignX!"set", "alignX", elementType, alignXType);
    library.addProperty(&_alignY!"get", &_alignY!"set", "alignY", elementType, alignYType);
    /*
    library.addProperty(&_hovered, null, "hovered", elementType, grBool);
    library.addProperty(&_focused, null, "focused", elementType, grBool);
    library.addProperty(&_pressed, null, "pressed", elementType, grBool);

    library.addProperty(&_onPress!"get", &_onPress!"set", "onSubmit",
        elementType, grOptional(grEvent()));*/

    library.addFunction(&_addState, "addState", [elementType, stateType]);
    library.addFunction(&_setState, "setState", [elementType, grString]);
    library.addFunction(&_runState, "runState", [elementType, grString]);

    library.addFunction(&_addImage, "addImage", [elementType, imageType]);

    library.addFunction(&_addElement, "addElement", [elementType, elementType]);

    library.addFunction(&_addEventListener, "addEventListener", [
            elementType, grString, grEvent()
        ]);
    library.addFunction(&_removeEventListener, "removeEventListener",
        [elementType, grString, grEvent()]);

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
        ui.setAlign(ui.getAlignX(), call.getEnum!(UIAlignY)(2));
    }
    call.setEnum!UIAlignY(ui.getAlignY());
}
/*
private void _hovered(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    call.setBool(ui.hovered);
}

private void _focused(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    call.setBool(ui.focused);
}

private void _pressed(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    call.setBool(ui.pressed);
}

private void _onPress(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.onSubmitEvent = call.isNull(1) ? null : call.getEvent(1);
    }

    if (ui.onSubmitEvent)
        call.setEvent(ui.onSubmitEvent);
    else
        call.setNull();
}*/

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

private void _addElement(GrCall call) {
    UIElement uiParent = call.getNative!UIElement(0);
    UIElement uiChild = call.getNative!UIElement(1);

    uiParent.addElement(uiChild);
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
