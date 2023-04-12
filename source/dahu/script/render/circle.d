/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.render.circle;

import grimoire;

import dahu.common;
import dahu.render;

package void loadLibRender_circle(GrLibDefinition lib) {
    GrType circleType = lib.addNative("Circle", [], "Graphic");

    lib.addConstructor(&_ctor, circleType, [grFloat, grBool, grFloat]);

    lib.addProperty(&_radius!"get", &_radius!"set", "radius", circleType, grFloat);
    lib.addProperty(&_filled!"get", &_filled!"set", "filled", circleType, grBool);
    lib.addProperty(&_thickness!"get", &_thickness!"set", "thickness", circleType, grFloat);
}

private void _ctor(GrCall call) {
    call.setNative(new Circle(call.getFloat(0), call.getBool(1), call.getFloat(2)));
}

private void _radius(string op)(GrCall call) {
    Circle circle = call.getNative!Circle(0);

    static if (op == "set") {
        circle.radius = call.getFloat(1);
    }
    call.setFloat(circle.radius);
}

private void _filled(string op)(GrCall call) {
    Circle circle = call.getNative!Circle(0);

    static if (op == "set") {
        circle.filled = call.getBool(1);
    }

    call.setBool(circle.filled);
}

private void _thickness(string op)(GrCall call) {
    Circle circle = call.getNative!Circle(0);

    static if (op == "set") {
        circle.thickness = call.getFloat(1);
    }
    call.setFloat(circle.thickness);
}
