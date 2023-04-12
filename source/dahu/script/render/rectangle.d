/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.render.rectangle;

import grimoire;

import dahu.common;
import dahu.render;

package void loadLibRender_rectangle(GrLibDefinition lib) {
    GrType rectangleType = lib.addNative("Rectangle", [], "Graphic");

    lib.addConstructor(&_ctor, rectangleType);

    lib.addFunction(&_setSize, "setSize", [rectangleType, grFloat, grFloat]);
    lib.addProperty(&_sizeX!"get", &_sizeX!"set", "sizeX", rectangleType, grFloat);
    lib.addProperty(&_sizeY!"get", &_sizeY!"set", "sizeY", rectangleType, grFloat);

    lib.addProperty(&_filled!"get", &_filled!"set", "filled", rectangleType, grBool);
}

private void _ctor(GrCall call) {
    call.setNative(new Rectangle);
}

private void _setSize(GrCall call) {
    Rectangle circle = call.getNative!Rectangle(0);

    circle.sizeX = call.getFloat(1);
    circle.sizeY = call.getFloat(2);
}

private void _sizeX(string op)(GrCall call) {
    Rectangle circle = call.getNative!Rectangle(0);

    static if (op == "set") {
        circle.sizeX = call.getFloat(1);
    }
    call.setFloat(circle.sizeX);
}

private void _sizeY(string op)(GrCall call) {
    Rectangle circle = call.getNative!Rectangle(0);

    static if (op == "set") {
        circle.sizeY = call.getFloat(1);
    }
    call.setFloat(circle.sizeY);
}

private void _filled(string op)(GrCall call) {
    Rectangle rectangle = call.getNative!Rectangle(0);

    static if (op == "set") {
        rectangle.filled = call.getBool(1);
    }

    call.setBool(rectangle.filled);
}
