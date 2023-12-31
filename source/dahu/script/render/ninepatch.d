/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.render.ninepatch;

import grimoire;

import dahu.common;
import dahu.core;
import dahu.input;
import dahu.render;

import dahu.script.util;

void loadLibRender_ninepatch(GrLibDefinition lib) {
    GrType ninepatchType = lib.addNative("NinePatch", [], "Image");

    GrType vec4iType = grGetNativeType("Vec4", [grInt]);

    lib.addConstructor(&_ctor, ninepatchType, [
            grString, vec4iType, grInt, grInt, grInt, grInt
        ]);

    static foreach (property; ["top", "bottom", "left", "right"]) {
        mixin("lib.addProperty(&_property!(property, \"get\"), &_property!(property, \"set\"),
            property, ninepatchType, grInt);");
    }

    lib.addFunction(&_setSize, "setSize", [ninepatchType, grFloat, grFloat]);
    lib.addProperty(&_sizeX!"get", &_sizeX!"set", "sizeX", ninepatchType, grFloat);
    lib.addProperty(&_sizeY!"get", &_sizeY!"set", "sizeY", ninepatchType, grFloat);
}

private void _ctor(GrCall call) {
    call.setNative(new NinePatch(call.getString(0), call.getNative!SVec4i(1),
            call.getInt(2), call.getInt(3), call.getInt(4), call.getInt(5)));
}

private void _property(string property, string op)(GrCall call) {
    NinePatch ninepatch = call.getNative!NinePatch(0);

    static if (op == "set") {
        mixin("ninepatch.", property, " = call.getInt(1);");
    }

    mixin("call.setInt(ninepatch.", property, ");");
}

private void _setSize(GrCall call) {
    NinePatch circle = call.getNative!NinePatch(0);

    circle.sizeX = call.getFloat(1);
    circle.sizeY = call.getFloat(2);
}

private void _sizeX(string op)(GrCall call) {
    NinePatch circle = call.getNative!NinePatch(0);

    static if (op == "set") {
        circle.sizeX = call.getFloat(1);
    }
    call.setFloat(circle.sizeX);
}

private void _sizeY(string op)(GrCall call) {
    NinePatch circle = call.getNative!NinePatch(0);

    static if (op == "set") {
        circle.sizeY = call.getFloat(1);
    }
    call.setFloat(circle.sizeY);
}
