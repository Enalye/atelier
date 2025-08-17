module atelier.common.vec4;

import bindbc.sdl;

import atelier.common.vec2;

struct Vec4(T) {
    static assert(__traits(isArithmetic, T));

    static if (__traits(isUnsigned, T)) {
        /// {1, 1, 1, 1} vector. Its length is not one !
        enum one = Vec4!T(1u, 1u, 1u, 1u);
        /// Null vector.
        enum zero = Vec4!T(0u, 0u, 0u, 0u);
    }
    else {
        static if (__traits(isFloating, T)) {
            /// {1, 1, 1, 1} vector. Its length is not one !
            enum one = Vec4!T(1f, 1f, 1f, 1f);
            /// {0.5, 0.5, 0.5, 0.5} vector. Its length is not 0.5 !
            enum half = Vec4!T(.5f, .5f, .5f, .5f);
            /// Null vector.
            enum zero = Vec4!T(0f, 0f, 0f, 0f);
        }
        else {
            /// {1, 1, 1, 1} vector. Its length is not one !
            enum one = Vec4!T(1, 1, 1, 1);
            /// Null vector.
            enum zero = Vec4!T(0, 0, 0, 0);
        }
    }

    T x, y, z, w;

    @property {
        Vec2!T xy() const {
            return Vec2!T(x, y);
        }

        Vec2!T xy(Vec2!T v) {
            x = v.x;
            y = v.y;
            return v;
        }

        Vec2!T zw() const {
            return Vec2!T(z, w);
        }

        Vec2!T zw(Vec2!T v) {
            z = v.x;
            w = v.y;
            return v;
        }
    }

    this(T nx, T ny, T nz, T nw) {
        x = nx;
        y = ny;
        z = nz;
        w = nw;
    }

    this(Vec2!T nxy, Vec2!T nzw) {
        x = nxy.x;
        y = nxy.y;
        z = nzw.x;
        w = nzw.y;
    }

    void set(T nx, T ny, T nz, T nw) {
        x = nx;
        y = ny;
        z = nz;
        w = nw;
    }

    void set(Vec2!T nxy, Vec2!T nzw) {
        x = nxy.x;
        y = nxy.y;
        z = nzw.x;
        w = nzw.y;
    }

    static if (__traits(isFloating, T)) {
        /// Returns an interpolated vector from this vector to the end vector by a factor. \
        /// Does not modify this vector.
        Vec4!T lerp(Vec4!T end, float t) const {
            return (this * (1.0 - t)) + (end * t);
        }
    }

    bool opEquals(const Vec4!T v) const {
        return (x == v.x) && (y == v.y) && (z == v.z) && (w == v.w);
    }

    Vec4!T opUnary(string op)() const {
        return mixin("Vec4!T(", op, " x, ", op, " y, ", op, " z, ", op, " w)");
    }

    Vec4!T opBinary(string op)(const Vec4!T v) const {
        return mixin("Vec4!T(x ", op, " v.x, y ", op, " v.y, z ", op, " v.z, w " ~ op ~ " v.w)");
    }

    Vec4!T opBinary(string op)(T s) const {
        return mixin("Vec4!T(x ", op, " s, y ", op, " s, z ", op, " s, w ", op, " s)");
    }

    Vec4!T opBinaryRight(string op)(T s) const {
        return mixin("Vec4!T(s ", op, " x, s ", op, " y, s ", op, " z, s ", op, "w)");
    }

    Vec4!T opOpAssign(string op)(Vec4!T v) {
        mixin("x = x", op, "v.x;y = y", op, "v.y;z = z", op, "v.z;w = w", op, "v.w;");
        return this;
    }

    Vec4!T opOpAssign(string op)(T s) {
        mixin("x = x", op, "s;y = y", op, "s;z = z", op, "s;w = w", op, "s;");
        return this;
    }

    Vec4!U opCast(V : Vec4!U, U)() const {
        return V(cast(U) x, cast(U) y, cast(U) z, cast(U) w);
    }

    /// Hash value.
    size_t toHash() const @safe pure nothrow {
        import std.typecons : tuple;

        return tuple(x, y, z, w).toHash();
    }

    static if (__traits(isIntegral, T)) {
        SDL_Rect toSdlRect() const {
            SDL_Rect sdlRect = {x, y, z, w};
            return sdlRect;
        }
    }

    /// Plus petit vecteur possible entre les deux
    Vec4!T min(const Vec4!T v) const {
        return Vec4!T(x < v.x ? x : v.x, y < v.y ? y : v.y, z < v.z ? z : v.z, w < v.w ? w : v.w);
    }

    /// Plus grand vecteur possible entre les deux
    Vec4!T max(const Vec4!T v) const {
        return Vec4!T(x > v.x ? x : v.x, y > v.y ? y : v.y, z > v.z ? z : v.z, w > v.w ? w : v.w);
    }

    /// Retourne la valeur la plus petite valeur
    T min() const {
        return x < y ? (x < z ? (x < w ? x : w) : (z < w ? z : w)) : (y < z ? (y < w ? y : w) : (z < w ? z
                : w));
    }

    /// Retourne la valeur la plus grande valeur
    T max() const {
        return x > y ? (x > z ? (x > w ? x : w) : (z > w ? z : w)) : (y > z ? (y > w ? y : w) : (z > w ? z
                : w));
    }

    /// Retourne -1, 0 ou 1 en fonction de l’orientation de chaque axe
    Vec4!T sign() const {
        static if (__traits(isFloating, T))
            return Vec4!T(x != .0 ? (x > .0 ? 1.0 : -1.0) : 0.0, y != .0 ? (y > .0 ?
                    1.0 : -1.0) : 0.0, z != .0 ? (z > .0 ? 1.0 : -1.0) : 0.0, w != .0 ? (w > .0 ? 1.0 : -1.0)
                    : 0.0);
        else static if (__traits(isUnsigned, T))
            return Vec4!T(x != 0U ? 1U : 0U, y != 0U ? 1U : 0U, z != 0U ? 1U : 0U, w != 0U ? 1U : 0U);
        else
            return Vec4!T(x != 0 ? (x > 0 ? 1 : -1) : 0, y != 0 ? (y > 0 ?
                    1 : -1) : 0, z != 0 ? (z > 0 ? 1 : -1) : 0, w != 0 ? (w > 0 ? 1 : -1) : 0);
    }

    /// Retire la composante négative
    Vec4!T abs() const {
        static if (__traits(isFloating, T))
            return Vec4!T(x < .0 ? -x : x, y < .0 ? -y : y, z < .0 ? -z : z, w < .0 ? -w : w);
        else static if (__traits(isUnsigned, T))
            return Vec4!T(x < 0U ? -x : x, y < 0U ? -y : y, z < 0U ? -z : z, w < 0U ? -w : w);
        else
            return Vec4!T(x < 0 ? -x : x, y < 0 ? -y : y, z < 0 ? -z : z, w < 0 ? -w : w);
    }
}

alias Vec4f = Vec4!(float);
alias Vec4i = Vec4!(int);
alias Vec4u = Vec4!(uint);
