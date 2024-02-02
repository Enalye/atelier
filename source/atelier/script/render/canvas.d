/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.render.canvas;

import grimoire;

import atelier.common;
import atelier.render;
import atelier.script.util;

package void loadLibRender_canvas(GrLibDefinition library) {
    library.setModule("render.canvas");
    library.setModuleInfo(GrLocale.fr_FR, "Texture de rendu");

    GrType canvasType = library.addNative("Canvas", [], "ImageData");
}