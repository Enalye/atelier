/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.render.rectangle;

import grimoire;

import atelier.common;
import atelier.render;
import atelier.script.util;

package void loadLibRender_rectangle(GrLibDefinition lib) {
    GrType rectangleType = lib.addNative("Rectangle", [], "Image");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    lib.addConstructor(&_ctor, rectangleType, [
            grFloat, grFloat, grBool, grFloat
        ]);

    lib.addProperty(&_size!"get", &_size!"set", "size", rectangleType, vec2fType);
    lib.addProperty(&_filled!"get", &_filled!"set", "filled", rectangleType, grBool);
    lib.addProperty(&_thickness!"get", &_thickness!"set", "thickness", rectangleType, grFloat);
}

private void _ctor(GrCall call) {
    call.setNative(new Rectangle(Vec2f(call.getFloat(0), call.getFloat(1)),
            call.getBool(2), call.getFloat(3)));
}

private void _size(string op)(GrCall call) {
    Rectangle rectangle = call.getNative!Rectangle(0);

    static if (op == "set") {
        rectangle.size = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(rectangle.size));
}

private void _filled(string op)(GrCall call) {
    Rectangle rectangle = call.getNative!Rectangle(0);

    static if (op == "set") {
        rectangle.filled = call.getBool(1);
    }

    call.setBool(rectangle.filled);
}

private void _thickness(string op)(GrCall call) {
    Rectangle rect = call.getNative!Rectangle(0);

    static if (op == "set") {
        rect.thickness = call.getFloat(1);
    }
    call.setFloat(rect.thickness);
}
