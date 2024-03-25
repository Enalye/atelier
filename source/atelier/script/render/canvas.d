/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.canvas;

import grimoire;

import atelier.common;
import atelier.render;
import atelier.script.util;

package void loadLibRender_canvas(GrModule mod) {
    mod.setModule("render.canvas");
    mod.setModuleInfo(GrLocale.fr_FR, "Texture de rendu");

    GrType canvasType = mod.addNative("Canvas", [], "ImageData");
}
