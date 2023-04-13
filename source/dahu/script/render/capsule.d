/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.render.capsule;

import grimoire;

import dahu.common;
import dahu.render;

package void loadLibRender_capsule(GrLibDefinition lib) {
    GrType capsuleType = lib.addNative("Capsule", [], "Graphic");

    lib.addConstructor(&_ctor, capsuleType, [grFloat, grFloat, grBool, grFloat]);

    lib.addFunction(&_setSize, "setSize", [capsuleType, grFloat, grFloat]);
    lib.addProperty(&_sizeX!"get", &_sizeX!"set", "sizeX", capsuleType, grFloat);
    lib.addProperty(&_sizeY!"get", &_sizeY!"set", "sizeY", capsuleType, grFloat);

    lib.addProperty(&_filled!"get", &_filled!"set", "filled", capsuleType, grBool);
    lib.addProperty(&_thickness!"get", &_thickness!"set", "thickness", capsuleType, grFloat);
}

private void _ctor(GrCall call) {
    call.setNative(new Capsule(call.getFloat(0), call.getFloat(1),
            call.getBool(2), call.getFloat(3)));
}

private void _setSize(GrCall call) {
    Capsule rect = call.getNative!Capsule(0);

    rect.sizeX = call.getFloat(1);
    rect.sizeY = call.getFloat(2);
}

private void _sizeX(string op)(GrCall call) {
    Capsule rect = call.getNative!Capsule(0);

    static if (op == "set") {
        rect.sizeX = call.getFloat(1);
    }
    call.setFloat(rect.sizeX);
}

private void _sizeY(string op)(GrCall call) {
    Capsule rect = call.getNative!Capsule(0);

    static if (op == "set") {
        rect.sizeY = call.getFloat(1);
    }
    call.setFloat(rect.sizeY);
}

private void _filled(string op)(GrCall call) {
    Capsule rect = call.getNative!Capsule(0);

    static if (op == "set") {
        rect.filled = call.getBool(1);
    }

    call.setBool(rect.filled);
}

private void _thickness(string op)(GrCall call) {
    Capsule rect = call.getNative!Capsule(0);

    static if (op == "set") {
        rect.thickness = call.getFloat(1);
    }
    call.setFloat(rect.thickness);
}
