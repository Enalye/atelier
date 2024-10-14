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

void loadLibRender_sprite(GrModule mod) {
    mod.setModule("render.sprite");
    mod.setModuleInfo(GrLocale.fr_FR, "Élément d’une texture");
    mod.setModuleDescription(GrLocale.fr_FR,
        "Sprite est une ressource définie dans un fichier `.ffd` (voir la page [ressources](/resources#Sprite)).");

    GrType spriteType = mod.addNative("Sprite", [], "Image");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType imageDataType = grGetNativeType("ImageData");
    GrType sceneType = grGetNativeType("Scene");
    GrType entityType = grGetNativeType("Entity");

    mod.addConstructor(&_ctor_str, spriteType, [grString]);

    mod.addConstructor(&_ctor_imageData, spriteType, [imageDataType]);

    //mod.addConstructor(&_ctor_scene, spriteType, [sceneType]);

    //mod.addConstructor(&_ctor_entity, spriteType, [entityType]);

    mod.addProperty(&_size!"get", &_size!"set", "size", spriteType, vec2fType);
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

private void _ctor_entity(GrCall call) {
    /*Canvas canvas = call.getNative!Entity(0).canvas;
    if (canvas) {
        call.setNative(new Sprite(canvas));
        return;
    }
    call.raise("NullError");*/
    call.raise("DeprecatedError");
}

private void _size(string op)(GrCall call) {
    Sprite sprite = call.getNative!Sprite(0);

    static if (op == "set") {
        sprite.size = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(sprite.size));
}
