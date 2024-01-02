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

package void loadLibUI_element(GrLibDefinition library) {
    GrType alignXType = library.addEnum("AlignX", ["left", "center", "right"]);
    GrType alignYType = library.addEnum("AlignY", ["top", "center", "bottom"]);
    GrType stateType = grGetNativeType("UIState");

    GrType uiType = library.addNative("UIElement");

    GrType imageType = grGetNativeType("Image");

    library.addFunction(&_setPos, "setPos", [uiType, grFloat, grFloat]);
    library.addProperty(&_posX!"get", &_posX!"set", "posX", uiType, grFloat);
    library.addProperty(&_posY!"get", &_posY!"set", "posY", uiType, grFloat);

    library.addFunction(&_setSize, "setSize", [uiType, grFloat, grFloat]);
    library.addProperty(&_sizeX!"get", &_sizeX!"set", "sizeX", uiType, grFloat);
    library.addProperty(&_sizeY!"get", &_sizeY!"set", "sizeY", uiType, grFloat);

    library.addFunction(&_setScale, "setScale", [uiType, grFloat, grFloat]);
    library.addProperty(&_scaleX!"get", &_scaleX!"set", "scaleX", uiType, grFloat);
    library.addProperty(&_scaleY!"get", &_scaleY!"set", "scaleY", uiType, grFloat);

    library.addFunction(&_setPivot, "setPivot", [uiType, grFloat, grFloat]);
    library.addProperty(&_pivotX!"get", &_pivotX!"set", "pivotX", uiType, grFloat);
    library.addProperty(&_pivotY!"get", &_pivotY!"set", "pivotY", uiType, grFloat);

    library.addProperty(&_angle!"get", &_angle!"set", "angle", uiType, grDouble);

    library.addProperty(&_alpha!"get", &_alpha!"set", "alpha", uiType, grFloat);

    library.addFunction(&_setAlign, "setAlign", [uiType, alignXType, alignYType]);
    library.addProperty(&_alignX!"get", &_alignX!"set", "alignX", uiType, alignXType);
    library.addProperty(&_alignY!"get", &_alignY!"set", "alignY", uiType, alignYType);

    library.addProperty(&_hovered, null, "hovered", uiType, grBool);
    library.addProperty(&_focused, null, "focused", uiType, grBool);
    library.addProperty(&_pressed, null, "pressed", uiType, grBool);

    library.addProperty(&_onPress!"get", &_onPress!"set", "onSubmit",
        uiType, grOptional(grEvent()));

    library.addFunction(&_addState, "addState", [uiType, stateType]);
    library.addFunction(&_setState, "setState", [uiType, grString]);
    library.addFunction(&_runState, "runState", [uiType, grString]);

    library.addFunction(&_addImage, "addImage", [uiType, imageType]);

    library.addFunction(&_addUI, "addUI", [uiType]);
    library.addFunction(&_addChild, "addChild", [uiType, uiType]);

    library.addFunction(&_remove, "remove", [uiType]);
}

private void _setPos(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    ui.posX = call.getFloat(1);
    ui.posY = call.getFloat(2);
}

private void _posX(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.posX = call.getFloat(1);
    }
    call.setFloat(ui.posX);
}

private void _posY(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.posY = call.getFloat(1);
    }
    call.setFloat(ui.posY);
}

private void _setSize(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    ui.sizeX = call.getFloat(1);
    ui.sizeY = call.getFloat(2);
}

private void _sizeX(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.sizeX = call.getFloat(1);
    }
    call.setFloat(ui.sizeX);
}

private void _sizeY(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.sizeY = call.getFloat(1);
    }
    call.setFloat(ui.sizeY);
}

private void _setScale(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    ui.scaleX = call.getFloat(1);
    ui.scaleY = call.getFloat(2);
}

private void _scaleX(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.scaleX = call.getFloat(1);
    }
    call.setFloat(ui.scaleX);
}

private void _scaleY(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.scaleY = call.getFloat(1);
    }
    call.setFloat(ui.scaleY);
}

private void _setPivot(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    ui.pivotX = call.getFloat(1);
    ui.pivotY = call.getFloat(2);
}

private void _pivotX(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.pivotX = call.getFloat(1);
    }
    call.setFloat(ui.pivotX);
}

private void _pivotY(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.pivotY = call.getFloat(1);
    }
    call.setFloat(ui.pivotY);
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

    ui.alignX = call.getEnum!(UIElement.AlignX)(1);
    ui.alignY = call.getEnum!(UIElement.AlignY)(2);
}

private void _alignX(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.alignX = call.getEnum!(UIElement.AlignX)(1);
    }
    call.setEnum!(UIElement.AlignX)(ui.alignX);
}

private void _alignY(string op)(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    static if (op == "set") {
        ui.alignY = call.getEnum!(UIElement.AlignY)(1);
    }
    call.setEnum!(UIElement.AlignY)(ui.alignY);
}

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
    ui.offsetX = ptr.offsetX;
    ui.offsetY = ptr.offsetY;
    ui.scaleX = ptr.scaleX;
    ui.scaleX = ptr.scaleX;
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
    ui.initState.offsetX = ui.offsetX;
    ui.initState.offsetY = ui.offsetY;
    ui.initState.scaleX = ui.scaleX;
    ui.initState.scaleY = ui.scaleY;
    ui.initState.angle = ui.angle;
    ui.initState.alpha = ui.alpha;
    ui.initState.time = ui.timer.duration;
    ui.targetState = *ptr;
    ui.timer.start(ptr.time);
}

private void _addImage(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    Image image = call.getNative!Image(1);

    ui._images ~= image;
}

private void _addUI(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);

    Atelier.ui.appendRoot(ui);
}

private void _addChild(GrCall call) {
    UIElement uiParent = call.getNative!UIElement(0);
    UIElement uiChild = call.getNative!UIElement(1);

    uiParent._children ~= uiChild;
}

private void _remove(GrCall call) {
    UIElement ui = call.getNative!UIElement(0);
    ui.alive = false;
}