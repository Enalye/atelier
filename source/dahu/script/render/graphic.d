/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.render.graphic;

import grimoire;

import dahu.common;
import dahu.render;

import dahu.script.util;

package void loadLibRender_graphic(GrLibDefinition lib) {
    GrType graphicType = lib.addNative("Graphic");
    GrType colorType = grGetNativeType("Color");

    lib.addConstraint(&_drawable, "Drawable");

    lib.addFunction(&_setPivot, "setPivot", [graphicType, grFloat, grFloat]);
    lib.addProperty(&_pivotX!"get", &_pivotX!"set", "pivotX", graphicType, grFloat);
    lib.addProperty(&_pivotY!"get", &_pivotY!"set", "pivotY", graphicType, grFloat);

    lib.addProperty(&_angle!"get", &_angle!"set", "angle", graphicType, grDouble);

    lib.addProperty(&_color!"get", &_color!"set", "color", graphicType, colorType);

    lib.addProperty(&_alpha!"get", &_alpha!"set", "alpha", graphicType, grFloat);

    lib.addFunction(&_fit, "fit", [graphicType, grFloat, grFloat]);
    lib.addFunction(&_contain, "contain", [graphicType, grFloat, grFloat]);
}

private bool _drawable(GrData data, GrType type, const GrType[]) {
    if (type.base != GrType.Base.native)
        return false;

    foreach (key; ["Animation", "Circle", "Image", "NinePatch", "Rectangle"]) {
        if (type.mangledType == key)
            return true;
    }

    return false;
}

private void _setPivot(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    graphic.pivotX = call.getFloat(1);
    graphic.pivotY = call.getFloat(2);
}

private void _pivotX(string op)(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    static if (op == "set") {
        graphic.pivotX = call.getFloat(1);
    }
    call.setFloat(graphic.pivotX);
}

private void _pivotY(string op)(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    static if (op == "set") {
        graphic.pivotY = call.getFloat(1);
    }
    call.setFloat(graphic.pivotY);
}

private void _angle(string op)(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    static if (op == "set") {
        graphic.angle = call.getDouble(1);
    }
    call.setDouble(graphic.angle);
}

private void _color(string op)(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    static if (op == "set") {
        graphic.color = call.getNative!SColor(1);
    }
    SColor color = new SColor;
    color = graphic.color;
    call.setNative(color);
}

private void _alpha(string op)(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    static if (op == "set") {
        graphic.alpha = call.getFloat(1);
    }
    call.setFloat(graphic.alpha);
}

private void _fit(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    graphic.fit(call.getFloat(1), call.getFloat(2));
}

private void _contain(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    graphic.contain(call.getFloat(1), call.getFloat(2));
}
