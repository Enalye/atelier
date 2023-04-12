/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.render.image;

import grimoire;

import dahu.common;
import dahu.core;
import dahu.input;
import dahu.render;

void loadLibRender_image(GrLibDefinition lib) {
    GrType imageType = lib.addNative("Image", [], "Graphic");

    lib.addConstructor(&_image, imageType, [grString]);

    lib.addFunction(&_setSize, "setSize", [imageType, grFloat, grFloat]);
    lib.addProperty(&_sizeX!"get", &_sizeX!"set", "sizeX", imageType, grFloat);
    lib.addProperty(&_sizeY!"get", &_sizeY!"set", "sizeY", imageType, grFloat);
}

private void _image(GrCall call) {
    call.setNative(new Image(call.getString(0)));
}

private void _setSize(GrCall call) {
    Image circle = call.getNative!Image(0);

    circle.sizeX = call.getFloat(1);
    circle.sizeY = call.getFloat(2);
}

private void _sizeX(string op)(GrCall call) {
    Image circle = call.getNative!Image(0);

    static if (op == "set") {
        circle.sizeX = call.getFloat(1);
    }
    call.setFloat(circle.sizeX);
}

private void _sizeY(string op)(GrCall call) {
    Image circle = call.getNative!Image(0);

    static if (op == "set") {
        circle.sizeY = call.getFloat(1);
    }
    call.setFloat(circle.sizeY);
}