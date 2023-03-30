/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.common.color;

import grimoire;

import dahu.common;

import dahu.script.util;

package void loadLibCommon_color(GrLibDefinition lib) {
    GrType colorType = lib.addNative("Color");

    lib.addConstructor(&_ctor, colorType, [grFloat, grFloat, grFloat]);

    static foreach (field; ["r", "g", "b"]) {
        lib.addProperty(&_property!(field, "get"), &_property!(field,
                "set"), field, colorType, grFloat);
    }

    static foreach (c; [
            "red", "lime", "blue", "white", "black", "yellow", "cyan", "magenta",
            "silver", "gray", "grey", "maroon", "olive", "green", "purple",
            "teal", "pink", "orange"
        ]) {
        lib.addStatic(&_color!c, colorType, c, [], [colorType]);
    }
}

private void _ctor(GrCall call) {
    SColor color = new SColor;
    static foreach (int idx, field; ["r", "g", "b"]) {
        mixin("color.", field, " = call.getFloat(", idx, ");");
    }
    call.setNative(color);
}

private void _property(string field, string op)(GrCall call) {
    SColor color = call.getNative!(SColor)(0);
    static if (op == "set") {
        mixin("color.", field, " = call.getFloat(1);");
    }
    mixin("call.setFloat(color.", field, ");");
}

private void _color(string c)(GrCall call) {
    SColor color = new SColor;
    mixin("color = Color.", c, ";");
    call.setNative(color);
}
