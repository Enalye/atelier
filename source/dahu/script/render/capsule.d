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
    GrType capsuleType = lib.addNative("Capsule", [], "Image");

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
    Capsule capsule = call.getNative!Capsule(0);

    capsule.sizeX = call.getFloat(1);
    capsule.sizeY = call.getFloat(2);
}

private void _sizeX(string op)(GrCall call) {
    Capsule capsule = call.getNative!Capsule(0);

    static if (op == "set") {
        capsule.sizeX = call.getFloat(1);
    }
    call.setFloat(capsule.sizeX);
}

private void _sizeY(string op)(GrCall call) {
    Capsule capsule = call.getNative!Capsule(0);

    static if (op == "set") {
        capsule.sizeY = call.getFloat(1);
    }
    call.setFloat(capsule.sizeY);
}

private void _filled(string op)(GrCall call) {
    Capsule capsule = call.getNative!Capsule(0);

    static if (op == "set") {
        capsule.filled = call.getBool(1);
    }

    call.setBool(capsule.filled);
}

private void _thickness(string op)(GrCall call) {
    Capsule capsule = call.getNative!Capsule(0);

    static if (op == "set") {
        capsule.thickness = call.getFloat(1);
    }
    call.setFloat(capsule.thickness);
}
