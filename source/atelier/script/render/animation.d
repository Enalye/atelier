/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.animation;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.script.util;

void loadLibRender_animation(GrModule mod) {
    mod.setModule("render.animation");
    mod.setModuleInfo(GrLocale.fr_FR, "Animation");
    mod.setModuleDescription(GrLocale.fr_FR,
        "Animation est une ressource définie dans un fichier `.res` (voir la page [ressources](/resources#Animation)).");

    GrType animationType = mod.addNative("Animation", [], "Image");

    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType vec2iType = grGetNativeType("Vec2", [grInt]);
    GrType vec4uType = grGetNativeType("Vec4", [grUInt]);
    GrType imageDataType = grGetNativeType("ImageData");

    mod.setParameters(["name"]);
    mod.addConstructor(&_ctor_str, animationType, [grString]);

    mod.setParameters(["imageData", "clip", "columns", "lines"]);
    mod.addConstructor(&_ctor_imageData_2, animationType, [
            imageDataType, vec4uType, grInt, grInt
        ]);

    mod.setParameters(["imageData", "clip", "columns", "lines", "maxCount"]);
    mod.addConstructor(&_ctor_imageData_3, animationType, [
            imageDataType, vec4uType, grInt, grInt, grInt
        ]);

    mod.addProperty(&_size!"get", &_size!"set", "size", animationType, vec2fType);
    mod.addProperty(&_margin!"get", &_margin!"set", "margin", animationType, vec2iType);
    mod.addProperty(&_repeat!"get", &_repeat!"set", "repeat", animationType, grBool);
    mod.addProperty(&_frameTime!"get", &_frameTime!"set", "frameTime", animationType, grInt);
    mod.addProperty(&_frames!"get", &_frames!"set", "frames", animationType, grList(grInt));
    mod.addProperty(&_columns!"get", &_columns!"set", "columns", animationType, grUInt);
    mod.addProperty(&_lines!"get", &_lines!"set", "lines", animationType, grUInt);
    mod.addProperty(&_maxCount!"get", &_maxCount!"set", "maxCount", animationType, grUInt);
}

private void _ctor_str(GrCall call) {
    call.setNative(Atelier.res.get!Animation(call.getString(0)));
}

private void _ctor_imageData_2(GrCall call) {
    call.setNative(new Animation(call.getNative!ImageData(0),
            call.getNative!SVec4u(1), call.getInt(1), call.getInt(2)));
}

private void _ctor_imageData_3(GrCall call) {
    call.setNative(new Animation(call.getNative!ImageData(0),
            call.getNative!SVec4u(1), call.getInt(1), call.getInt(2), call.getInt(3)));
}

private void _size(string op)(GrCall call) {
    Animation animation = call.getNative!Animation(0);

    static if (op == "set") {
        animation.size = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(animation.size));
}

private void _margin(string op)(GrCall call) {
    Animation animation = call.getNative!Animation(0);

    static if (op == "set") {
        animation.margin = call.getNative!SVec2i(1);
    }
    call.setNative(svec2(animation.margin));
}

private void _repeat(string op)(GrCall call) {
    Animation animation = call.getNative!Animation(0);

    static if (op == "set") {
        animation.repeat = call.getBool(1);
    }
    call.setBool(animation.repeat);
}

private void _frameTime(string op)(GrCall call) {
    Animation animation = call.getNative!Animation(0);

    static if (op == "set") {
        animation.frameTime = call.getInt(1);
    }
    call.setInt(animation.frameTime);
}

private void _frames(string op)(GrCall call) {
    Animation animation = call.getNative!Animation(0);

    static if (op == "set") {
        animation.frames = call.getList(1).getInts();
    }
    GrList list = new GrList;
    list.setInts(animation.frames);
    call.setList(list);
}

private void _columns(string op)(GrCall call) {
    Animation animation = call.getNative!Animation(0);

    static if (op == "set") {
        animation.columns = call.getUInt(1);
    }
    call.setUInt(animation.columns);
}

private void _lines(string op)(GrCall call) {
    Animation animation = call.getNative!Animation(0);

    static if (op == "set") {
        animation.lines = call.getUInt(1);
    }
    call.setUInt(animation.lines);
}

private void _maxCount(string op)(GrCall call) {
    Animation animation = call.getNative!Animation(0);

    static if (op == "set") {
        animation.maxCount = call.getUInt(1);
    }
    call.setUInt(animation.maxCount);
}
