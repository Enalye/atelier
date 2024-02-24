/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.texture;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;

void loadLibRender_texture(GrLibDefinition library) {
    library.setModule("render.texture");
    library.setModuleInfo(GrLocale.fr_FR, "Représente un fichier de texture");
    library.setModuleDescription(GrLocale.fr_FR,
        "Texture est une ressource définie dans un fichier `.res` (voir la page [ressources](/resources#Texture)).");

    GrType textureType = library.addNative("Texture", [], "ImageData");

}
