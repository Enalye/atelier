/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.render.ninepatch;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;

import atelier.script.util;

void loadLibRender_ninepatch(GrLibDefinition library) {
    GrType ninepatchType = library.addNative("NinePatch", [], "Image");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType vec4iType = grGetNativeType("Vec4", [grInt]);

    /*library.addConstructor(&_ctor, ninepatchType, [
            grString, vec4iType, grInt, grInt, grInt, grInt
        ]);*/
    library.addProperty(&_size!"get", &_size!"set", "size", ninepatchType, vec2fType);

    static foreach (property; ["top", "bottom", "left", "right"]) {
        mixin("library.addProperty(&_property!(property, \"get\"), &_property!(property, \"set\"),
            property, ninepatchType, grInt);");
    }

    library.addProperty(&_size!"get", &_size!"set", "sizeX", ninepatchType, vec2fType);
}

private void _ctor(GrCall call) {
    //call.setNative(new NinePatch(call.getString(0), call.getNative!SVec4i(1),
    //        call.getInt(2), call.getInt(3), call.getInt(4), call.getInt(5)));
}

private void _property(string property, string op)(GrCall call) {
    NinePatch ninepatch = call.getNative!NinePatch(0);

    static if (op == "set") {
        mixin("ninepatch.", property, " = call.getInt(1);");
    }

    mixin("call.setInt(ninepatch.", property, ");");
}

private void _size(string op)(GrCall call) {
    NinePatch ninepatch = call.getNative!NinePatch(0);

    static if (op == "set") {
        ninepatch.size = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(ninepatch.size));
}