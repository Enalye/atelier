/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.ninepatch;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;

import atelier.script.util;

void loadLibRender_ninepatch(GrModule mod) {
    mod.setModule("render.ninepatch");
    mod.setModuleInfo(GrLocale.fr_FR,
        "Image divisé en 9 sections pouvant se mettre à l’échelle sans être étiré");
    mod.setModuleDescription(GrLocale.fr_FR,
        "NinePatch est une ressource définie dans un fichier `.ffd` (voir la page [ressources](/resources#NinePatch)).");

    GrType ninepatchType = mod.addNative("NinePatch", [], "Image");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType vec4uType = grGetNativeType("Vec4", [grUInt]);
    GrType textureType = grGetNativeType("Texture");

    mod.addConstructor(&_ctor_str, ninepatchType, [grString]);
    mod.addConstructor(&_ctor_texture, ninepatchType, [
            textureType, vec4uType, grInt, grInt, grInt, grInt
        ]);

    mod.addProperty(&_size!"get", &_size!"set", "size", ninepatchType, vec2fType);

    static foreach (property; ["top", "bottom", "left", "right"]) {
        mixin("mod.addProperty(&_property!(property, \"get\"), &_property!(property, \"set\"),
            property, ninepatchType, grInt);");
    }

    mod.addProperty(&_size!"get", &_size!"set", "sizeX", ninepatchType, vec2fType);
}

private void _ctor_str(GrCall call) {
    call.setNative(Atelier.res.get!NinePatch(call.getString(0)));
}

private void _ctor_texture(GrCall call) {
    call.setNative(new NinePatch(call.getNative!Texture(0),
            call.getNative!SVec4u(1), call.getInt(2), call.getInt(3),
            call.getInt(4), call.getInt(5)));
}

private void _property(string property, string op)(GrCall call) {
    NinePatch ninepatch = call.getNative!NinePatch(0);

    static if (op == "set") {
        mixin("ninepatch.", property, " = call.getInt(1);");
    }

    mixin("call.setInt(ninepatch.", property, ");");
}

private void _size(string op)(GrCall call) {
    NinePatch ninepatch = call.getNative!NinePatch(0);

    static if (op == "set") {
        ninepatch.size = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(ninepatch.size));
}
