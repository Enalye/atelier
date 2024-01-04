/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.render.writabletexture;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;

void loadLibRender_writableTexture(GrLibDefinition library) {
    GrType wtextureType = library.addNative("WritableTexture", [], "ImageData");

}
