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

    lib.addFunction(&_setSize, "setSize", [graphicType, grFloat, grFloat]);
    lib.addProperty(&_sizeX!"get", &_sizeX!"set", "sizeX", graphicType, grFloat);
    lib.addProperty(&_sizeY!"get", &_sizeY!"set", "sizeY", graphicType, grFloat);

    lib.addFunction(&_setPivot, "setPivot", [graphicType, grFloat, grFloat]);
    lib.addProperty(&_pivotX!"get", &_pivotX!"set", "pivotX", graphicType, grFloat);
    lib.addProperty(&_pivotY!"get", &_pivotY!"set", "pivotY", graphicType, grFloat);

    lib.addProperty(&_angle!"get", &_angle!"set", "angle", graphicType, grDouble);

    lib.addProperty(&_color!"get", &_color!"set", "color", graphicType, colorType);

    lib.addProperty(&_alpha!"get", &_alpha!"set", "alpha", graphicType, grFloat);

}

private bool _drawable(GrData data, GrType type, const GrType[]) {
    if (type.base != GrType.Base.native)
        return false;

    foreach (key; ["Animation", "Image", "NinePatch", "Rectangle"]) {
        if (type.mangledType == key)
            return true;
    }

    return false;
}

private void _setSize(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    graphic.sizeX = call.getFloat(1);
    graphic.sizeY = call.getFloat(2);
}

private void _sizeX(string op)(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    static if (op == "set") {
        graphic.sizeX = call.getFloat(1);
    }
    call.setFloat(graphic.sizeX);
}

private void _sizeY(string op)(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    static if (op == "set") {
        graphic.sizeY = call.getFloat(1);
    }
    call.setFloat(graphic.sizeY);
}

private void _setPivot(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    graphic.pivot.x = call.getFloat(1);
    graphic.pivot.y = call.getFloat(2);
}

private void _pivotX(string op)(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    static if (op == "set") {
        graphic.pivot.x = call.getFloat(1);
    }
    call.setFloat(graphic.pivot.x);
}

private void _pivotY(string op)(GrCall call) {
    Graphic graphic = call.getNative!Graphic(0);

    static if (op == "set") {
        graphic.pivot.y = call.getFloat(1);
    }
    call.setFloat(graphic.pivot.y);
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
