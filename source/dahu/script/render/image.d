/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.render.image;

import grimoire;

import dahu.common;
import dahu.render;

import dahu.script.util;

package void loadLibRender_image(GrLibDefinition lib) {
    GrType imageType = lib.addNative("Image");
    GrType colorType = grGetNativeType("Color");

    lib.addConstraint(&_drawable, "Drawable");

    lib.addFunction(&_setPivot, "setPivot", [imageType, grFloat, grFloat]);
    lib.addProperty(&_pivotX!"get", &_pivotX!"set", "pivotX", imageType, grFloat);
    lib.addProperty(&_pivotY!"get", &_pivotY!"set", "pivotY", imageType, grFloat);

    lib.addProperty(&_angle!"get", &_angle!"set", "angle", imageType, grDouble);

    lib.addProperty(&_color!"get", &_color!"set", "color", imageType, colorType);

    lib.addProperty(&_alpha!"get", &_alpha!"set", "alpha", imageType, grFloat);

    lib.addFunction(&_fit, "fit", [imageType, grFloat, grFloat]);
    lib.addFunction(&_contain, "contain", [imageType, grFloat, grFloat]);
}

private bool _drawable(GrData data, GrType type, const GrType[]) {
    if (type.base != GrType.Base.native)
        return false;

    foreach (key; [
            "Animation", "Capsule", "Circle", "Sprite", "NinePatch",
            "Rectangle", "RoundedRectangle"
        ]) {
        if (type.mangledType == key)
            return true;
    }

    return false;
}

private void _setPivot(GrCall call) {
    Image image = call.getNative!Image(0);

    image.pivotX = call.getFloat(1);
    image.pivotY = call.getFloat(2);
}

private void _pivotX(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.pivotX = call.getFloat(1);
    }
    call.setFloat(image.pivotX);
}

private void _pivotY(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.pivotY = call.getFloat(1);
    }
    call.setFloat(image.pivotY);
}

private void _angle(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.angle = call.getDouble(1);
    }
    call.setDouble(image.angle);
}

private void _color(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.color = call.getNative!SColor(1);
    }
    SColor color = new SColor;
    color = image.color;
    call.setNative(color);
}

private void _alpha(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.alpha = call.getFloat(1);
    }
    call.setFloat(image.alpha);
}

private void _fit(GrCall call) {
    Image image = call.getNative!Image(0);

    image.fit(call.getFloat(1), call.getFloat(2));
}

private void _contain(GrCall call) {
    Image image = call.getNative!Image(0);

    image.contain(call.getFloat(1), call.getFloat(2));
}
