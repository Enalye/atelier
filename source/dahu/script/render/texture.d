/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.render.texture;

import grimoire;

import dahu.common;
import dahu.core;
import dahu.input;
import dahu.render;

void loadLibRender_texture(GrLibDefinition lib) {
    GrType textureType = lib.addNative("Texture");

    GrType imageType = lib.addNative("Image", [], "Graphic");

    lib.addConstructor(&_image, imageType, [grString]);
    
}

private void _image(GrCall call) {
    call.setNative(new Image(call.getString(0)));
}