/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.render.roundedrectangle;

import grimoire;

import dahu.common;
import dahu.render;

package void loadLibRender_roundedRectangle(GrLibDefinition lib) {
    GrType rrectType = lib.addNative("RoundedRectangle", [], "Graphic");

    lib.addConstructor(&_ctor, rrectType, [
            grFloat, grFloat, grFloat, grBool, grFloat
        ]);

    lib.addFunction(&_setSize, "setSize", [rrectType, grFloat, grFloat]);
    lib.addProperty(&_sizeX!"get", &_sizeX!"set", "sizeX", rrectType, grFloat);
    lib.addProperty(&_sizeY!"get", &_sizeY!"set", "sizeY", rrectType, grFloat);

    lib.addProperty(&_radius!"get", &_radius!"set", "radius", rrectType, grFloat);
    lib.addProperty(&_filled!"get", &_filled!"set", "filled", rrectType, grBool);
    lib.addProperty(&_thickness!"get", &_thickness!"set", "thickness", rrectType, grFloat);
}

private void _ctor(GrCall call) {
    call.setNative(new RoundedRectangle(call.getFloat(0), call.getFloat(1),
            call.getFloat(2), call.getBool(3), call.getFloat(4)));
}

private void _setSize(GrCall call) {
    RoundedRectangle rect = call.getNative!RoundedRectangle(0);

    rect.sizeX = call.getFloat(1);
    rect.sizeY = call.getFloat(2);
}

private void _sizeX(string op)(GrCall call) {
    RoundedRectangle rect = call.getNative!RoundedRectangle(0);

    static if (op == "set") {
        rect.sizeX = call.getFloat(1);
    }
    call.setFloat(rect.sizeX);
}

private void _sizeY(string op)(GrCall call) {
    RoundedRectangle rect = call.getNative!RoundedRectangle(0);

    static if (op == "set") {
        rect.sizeY = call.getFloat(1);
    }
    call.setFloat(rect.sizeY);
}

private void _radius(string op)(GrCall call) {
    RoundedRectangle rect = call.getNative!RoundedRectangle(0);

    static if (op == "set") {
        rect.radius = call.getFloat(1);
    }
    call.setFloat(rect.radius);
}

private void _filled(string op)(GrCall call) {
    RoundedRectangle rect = call.getNative!RoundedRectangle(0);

    static if (op == "set") {
        rect.filled = call.getBool(1);
    }

    call.setBool(rect.filled);
}

private void _thickness(string op)(GrCall call) {
    RoundedRectangle rect = call.getNative!RoundedRectangle(0);

    static if (op == "set") {
        rect.thickness = call.getFloat(1);
    }
    call.setFloat(rect.thickness);
}
