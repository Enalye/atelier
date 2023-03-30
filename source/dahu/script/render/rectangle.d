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
}

private void _ctor(GrCall call) {
    call.setNative(new Rectangle);
}
