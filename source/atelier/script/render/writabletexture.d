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
    library.setModule("render.writabletexture");
    library.setModuleInfo(GrLocale.fr_FR, "Texture générée procéduralement");

    GrType wtextureType = library.addNative("WritableTexture", [], "ImageData");

}
