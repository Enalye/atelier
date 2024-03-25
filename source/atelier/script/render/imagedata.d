/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.imagedata;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;

void loadLibRender_imageData(GrModule mod) {
    mod.setModule("render.imagedata");
    mod.setModuleInfo(GrLocale.fr_FR, "Information d’une image");

    mod.addNative("ImageData");
    mod.addEnum("Blend", grNativeEnum!Blend());
}
