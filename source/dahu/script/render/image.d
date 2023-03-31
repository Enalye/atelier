/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.render.image;

import grimoire;

import dahu.common;
import dahu.core;
import dahu.input;
import dahu.render;

void loadLibRender_image(GrLibDefinition lib) {
    GrType imageType = lib.addNative("Image", [], "Graphic");

    lib.addConstructor(&_image, imageType, [grString]);
}

private void _image(GrCall call) {
    call.setNative(new Image(call.getString(0)));
}