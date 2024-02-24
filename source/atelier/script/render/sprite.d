/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.sprite;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.scene;
import atelier.script.util;

void loadLibRender_sprite(GrLibDefinition library) {
    library.setModule("render.sprite");
    library.setModuleInfo(GrLocale.fr_FR, "Élément d’une texture");
    library.setModuleDescription(GrLocale.fr_FR,
        "Sprite est une ressource définie dans un fichier `.res` (voir la page [ressources](/resources#Sprite)).");

    GrType spriteType = library.addNative("Sprite", [], "Image");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType imageDataType = grGetNativeType("ImageData");
    GrType sceneType = grGetNativeType("Scene");

    library.addConstructor(&_ctor_str, spriteType, [grString]);

    library.addConstructor(&_ctor_imageData, spriteType, [imageDataType]);

    library.addConstructor(&_ctor_scene, spriteType, [sceneType]);

    library.addProperty(&_size!"get", &_size!"set", "size", spriteType, vec2fType);
}

private void _ctor_str(GrCall call) {
    call.setNative(Atelier.res.get!Sprite(call.getString(0)));
}

private void _ctor_imageData(GrCall call) {
    call.setNative(new Sprite(call.getNative!ImageData(0)));
}

private void _ctor_scene(GrCall call) {
    call.setNative(new Sprite(call.getNative!Scene(0).canvas));
}

private void _size(string op)(GrCall call) {
    Sprite sprite = call.getNative!Sprite(0);

    static if (op == "set") {
        sprite.size = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(sprite.size));
}
