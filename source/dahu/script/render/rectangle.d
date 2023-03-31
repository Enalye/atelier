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

    lib.addProperty(&_filled!"get", &_filled!"set", "filled", rectangleType, grBool);
}

private void _ctor(GrCall call) {
    call.setNative(new Rectangle);
}

private void _filled(string op)(GrCall call) {
    Rectangle rectangle = call.getNative!Rectangle(0);

    static if (op == "set") {
        rectangle.filled = call.getBool(1);
    }

    call.setBool(rectangle.filled);
}
