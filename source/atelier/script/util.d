/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.util;

import grimoire;

import atelier.common;
import atelier.world;

final class SEntity {
    Scene scene;
    EntityID id;
}

final class SVec2(T) {
    Vec2!T _vector;
    alias _vector this;
}

alias SVec2f = SVec2!GrFloat;
alias SVec2d = SVec2!GrDouble;
alias SVec2i = SVec2!GrInt;
alias SVec2u = SVec2!GrUInt;

SVec2!T svec2(T)(Vec2!T vec) {
    SVec2!T result = new SVec2!T;
    result.x = vec.x;
    result.y = vec.y;
    return result;
}

final class SVec3(T) {
    Vec3!T _vector;
    alias _vector this;
}

alias SVec3f = SVec3!GrFloat;
alias SVec3d = SVec3!GrDouble;
alias SVec3i = SVec3!GrInt;
alias SVec3u = SVec3!GrUInt;

SVec3!T svec3(T)(Vec3!T vec) {
    SVec3!T result = new SVec3!T;
    result.x = vec.x;
    result.y = vec.y;
    result.z = vec.z;
    return result;
}

final class SVec4(T) {
    Vec4!T _vector;
    alias _vector this;
}

alias SVec4f = SVec4!GrFloat;
alias SVec4d = SVec4!GrDouble;
alias SVec4i = SVec4!GrInt;
alias SVec4u = SVec4!GrUInt;

SVec4!T svec4(T)(Vec4!T vec) {
    SVec4!T result = new SVec4!T;
    result.x = vec.x;
    result.y = vec.y;
    result.z = vec.z;
    result.w = vec.w;
    return result;
}

final class SColor {
    Color _color;
    alias _color this;
}

SColor scolor(Color color) {
    SColor result = new SColor;
    result = color;
    return result;
}

final class SHSLColor {
    HSLColor _hslcolor;
    alias _hslcolor this;
}

SHSLColor shslcolor(HSLColor hslcolor) {
    SHSLColor result = new SHSLColor;
    result = hslcolor;
    return result;
}
