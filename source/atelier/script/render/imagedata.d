/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.render.imagedata;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;

void loadLibRender_imageData(GrLibDefinition library) {
    library.setModule("render.imagedata");
    library.setModuleInfo(GrLocale.fr_FR, "Information d’une image");

    GrType imageData = library.addNative("ImageData");
    
}