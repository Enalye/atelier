/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.render.sprite;

import grimoire;

import dahu.common;
import dahu.core;
import dahu.input;
import dahu.render;

void loadLibRender_sprite(GrLibDefinition lib) {
    GrType spriteType = lib.addNative("Sprite", [], "Image");

    lib.addConstructor(&_sprite, spriteType, [grString]);

    lib.addFunction(&_setSize, "setSize", [spriteType, grFloat, grFloat]);
    lib.addProperty(&_sizeX!"get", &_sizeX!"set", "sizeX", spriteType, grFloat);
    lib.addProperty(&_sizeY!"get", &_sizeY!"set", "sizeY", spriteType, grFloat);
}

private void _sprite(GrCall call) {
    call.setNative(Dahu.res.get!Sprite(call.getString(0)));
}

private void _setSize(GrCall call) {
    Sprite circle = call.getNative!Sprite(0);

    circle.sizeX = call.getFloat(1);
    circle.sizeY = call.getFloat(2);
}

private void _sizeX(string op)(GrCall call) {
    Sprite circle = call.getNative!Sprite(0);

    static if (op == "set") {
        circle.sizeX = call.getFloat(1);
    }
    call.setFloat(circle.sizeX);
}

private void _sizeY(string op)(GrCall call) {
    Sprite circle = call.getNative!Sprite(0);

    static if (op == "set") {
        circle.sizeY = call.getFloat(1);
    }
    call.setFloat(circle.sizeY);
}