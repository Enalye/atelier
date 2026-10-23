module atelier.script.util;

import grimoire;

import atelier.common;
import atelier.world;

final class SVec2(T) {
    Vec2!T _vector;
    alias _vector this;

    U opCast(U : GrPointer)() const @safe pure nothrow {
        return cast(GrPointer) this;
    }
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

GrList svec2(T)(Vec2!(T)[] list) {
    GrList result = new GrList;
    for (size_t i; i < list.length; ++i) {
        result.pushBack(GrValue(svec2(list[i])));
    }
    return result;
}

final class SVec3(T) {
    Vec3!T _vector;
    alias _vector this;

    U opCast(U : GrPointer)() const @safe pure nothrow {
        return cast(GrPointer) this;
    }
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

GrList svec3(T)(Vec3!(T)[] list) {
    GrList result = new GrList;
    for (size_t i; i < list.length; ++i) {
        result.pushBack(GrValue(svec3(list[i])));
    }
    return result;
}

final class SVec4(T) {
    Vec4!T _vector;
    alias _vector this;

    U opCast(U : GrPointer)() const @safe pure nothrow {
        return cast(GrPointer) this;
    }
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

GrList svec4(T)(Vec4!(T)[] list) {
    GrList result = new GrList;
    for (size_t i; i < list.length; ++i) {
        result.pushBack(GrValue(svec4(list[i])));
    }
    return result;
}

final class SColor {
    Color _color;
    alias _color this;

    U opCast(U : GrPointer)() const @safe pure nothrow {
        return cast(GrPointer) this;
    }
}

SColor scolor(Color color) {
    SColor result = new SColor;
    result = color;
    return result;
}

final class SHSLColor {
    HSLColor _hslcolor;
    alias _hslcolor this;

    U opCast(U : GrPointer)() const @safe pure nothrow {
        return cast(GrPointer) this;
    }
}

SHSLColor shslcolor(HSLColor hslcolor) {
    SHSLColor result = new SHSLColor;
    result = hslcolor;
    return result;
}
