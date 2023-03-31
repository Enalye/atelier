/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.util;

import grimoire;

import dahu.common;

final class SVec2(T) {
    Vec2!T _vector;
    alias _vector this;
}

alias SVec2f = SVec2!GrFloat;
alias SVec2d = SVec2!GrDouble;
alias SVec2i = SVec2!GrInt;
alias SVec2u = SVec2!GrUInt;

final class SVec3(T) {
    Vec3!T _vector;
    alias _vector this;
}

alias SVec3f = SVec3!GrFloat;
alias SVec3d = SVec3!GrDouble;
alias SVec3i = SVec3!GrInt;
alias SVec3u = SVec3!GrUInt;
/*
SVec3f sVec3f(Vec3f v_) {
    auto v = new SVec3f;
    v.x = v_.x;
    v.y = v_.y;
    v.z = v_.z;
    return v;
}*/

final class SVec4(T) {
    Vec4!T _vector;
    alias _vector this;
}

alias SVec4f = SVec4!GrFloat;
alias SVec4d = SVec4!GrDouble;
alias SVec4i = SVec4!GrInt;
alias SVec4u = SVec4!GrUInt;

final class SColor {
    Color _color;
    alias _color this;
}
