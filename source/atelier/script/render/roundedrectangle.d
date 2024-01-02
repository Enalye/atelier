/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.render.roundedrectangle;

import grimoire;

import atelier.common;
import atelier.render;
import atelier.script.util;

package void loadLibRender_roundedRectangle(GrLibDefinition library) {
    GrType rrectType = library.addNative("RoundedRectangle", [], "Image");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.addConstructor(&_ctor, rrectType, [
            grFloat, grFloat, grFloat, grBool, grFloat
        ]);

    library.addProperty(&_size!"get", &_size!"set", "size", rrectType, vec2fType);
    library.addProperty(&_radius!"get", &_radius!"set", "radius", rrectType, grFloat);
    library.addProperty(&_filled!"get", &_filled!"set", "filled", rrectType, grBool);
    library.addProperty(&_thickness!"get", &_thickness!"set", "thickness", rrectType, grFloat);
}

private void _ctor(GrCall call) {
    call.setNative(new RoundedRectangle(Vec2f(call.getFloat(0),
            call.getFloat(1)), call.getFloat(2), call.getBool(3), call.getFloat(4)));
}

private void _size(string op)(GrCall call) {
    RoundedRectangle rect = call.getNative!RoundedRectangle(0);

    static if (op == "set") {
        rect.size = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(rect.size));
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
