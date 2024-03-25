/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.image;

import grimoire;

import atelier.common;
import atelier.render;

import atelier.script.util;

package void loadLibRender_image(GrModule mod) {
    mod.setModule("render.image");
    mod.setModuleInfo(GrLocale.fr_FR, "Image");

    GrType imageType = mod.addNative("Image");
    GrType colorType = grGetNativeType("Color");
    GrType blendType = grGetEnumType("Blend");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType vec4uType = grGetNativeType("Vec4", [grUInt]);

    mod.addProperty(&_clip!"get", &_clip!"set", "clip", imageType, vec4uType);
    mod.addProperty(&_position!"get", &_position!"set", "position", imageType, vec2fType);
    mod.addProperty(&_angle!"get", &_angle!"set", "angle", imageType, grDouble);
    mod.addProperty(&_flipX!"get", &_flipX!"set", "flipX", imageType, grBool);
    mod.addProperty(&_flipY!"get", &_flipY!"set", "flipY", imageType, grBool);
    mod.addProperty(&_anchor!"get", &_anchor!"set", "anchor", imageType, vec2fType);
    mod.addProperty(&_pivot!"get", &_pivot!"set", "pivot", imageType, vec2fType);
    mod.addProperty(&_blend!"get", &_blend!"set", "blend", imageType, blendType);
    mod.addProperty(&_color!"get", &_color!"set", "color", imageType, colorType);
    mod.addProperty(&_alpha!"get", &_alpha!"set", "alpha", imageType, grFloat);
    mod.addProperty(&_zOrder!"get", &_zOrder!"set", "zOrder", imageType, grInt);
    mod.addProperty(&_isVisible!"get", &_isVisible!"set", "isVisible", imageType, grBool);
    mod.addProperty(&_isAlive, null, "isAlive", imageType, grBool);

    mod.addFunction(&_fit, "fit", [imageType, grFloat, grFloat]);
    mod.addFunction(&_contain, "contain", [imageType, grFloat, grFloat]);
    mod.addFunction(&_remove, "remove", [imageType]);
}

private void _clip(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.clip = call.getNative!SVec4u(1);
    }
    call.setNative(svec4(image.clip));
}

private void _position(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.position = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(image.position));
}

private void _angle(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.angle = call.getDouble(1);
    }
    call.setDouble(image.angle);
}

private void _flipX(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.flipX = call.getBool(1);
    }
    call.setBool(image.flipX);
}

private void _flipY(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.flipY = call.getBool(1);
    }
    call.setBool(image.flipY);
}

private void _anchor(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.anchor = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(image.anchor));
}

private void _pivot(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.pivot = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(image.pivot));
}

private void _blend(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.blend = call.getEnum!Blend(1);
    }
    call.setEnum(image.blend);
}

private void _color(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.color = call.getNative!SColor(1);
    }
    call.setNative(scolor(image.color));
}

private void _alpha(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.alpha = call.getFloat(1);
    }
    call.setFloat(image.alpha);
}

private void _zOrder(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.zOrder = call.getInt(1);
    }
    call.setInt(image.zOrder);
}

private void _isVisible(string op)(GrCall call) {
    Image image = call.getNative!Image(0);

    static if (op == "set") {
        image.isVisible = call.getBool(1);
    }
    call.setBool(image.isVisible);
}

private void _isAlive(GrCall call) {
    Image image = call.getNative!Image(0);
    call.setBool(image.isAlive);
}

private void _fit(GrCall call) {
    Image image = call.getNative!Image(0);

    image.fit(Vec2f(call.getFloat(1), call.getFloat(2)));
}

private void _contain(GrCall call) {
    Image image = call.getNative!Image(0);

    image.contain(Vec2f(call.getFloat(1), call.getFloat(2)));
}

private void _remove(GrCall call) {
    Image image = call.getNative!Image(0);
    image.remove();
}
