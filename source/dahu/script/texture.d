/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.texture;

import grimoire;

import dahu.common;
import dahu.core;
import dahu.input;
import dahu.render;

void loadLibTexture(GrLibDefinition lib) {
    GrType textureType = lib.addNative("Texture");

    GrType imageType = lib.addNative("Image");

    lib.addConstructor(&_image, imageType, [grString]);
    
}

private void _image(GrCall call) {
    call.setNative(new Image(call.getString(0)));
}