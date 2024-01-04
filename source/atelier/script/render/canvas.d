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
    GrType canvasType = library.addNative("Canvas", [], "ImageData");
}