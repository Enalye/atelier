module atelier.script.render.texture;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;

void loadLibRender_texture(GrModule mod) {
    mod.setModule("render.texture");
    mod.setModuleInfo(GrLocale.fr_FR, "Représente un fichier de texture");
    mod.setModuleDescription(GrLocale.fr_FR,
        "Texture est une ressource définie dans un fichier `.ffd` (voir la page [ressources](/resources#Texture)).");

    GrType textureType = mod.addNative("Texture", [], "ImageData");

}
