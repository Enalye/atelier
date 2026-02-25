module atelier.console.value;

import std.conv : to, ConvException;
import std.exception : enforce;
import std.traits;

import atelier.console.error;

package template isCommandValueType(T) {
    enum isCommandValueType = isSomeString!T || isSomeChar!T || is(Unqual!T == U[],
            U) || is(Unqual!T == bool) || __traits(isIntegral, T) || __traits(isFloating, T);
}

struct ConsoleValue {
    enum Type {
        uint_,
        int_,
        char_,
        float_,
        bool_,
        string_
    }

    private {
        Type _type;

        union {
            ulong _uint;
            long _int;
            dchar _char;
            double _float;
            bool _bool;
            string _string;
        }
    }

    this(ulong value) {
        _type = Type.uint_;
        _uint = value;
    }

    this(long value) {
        _type = Type.int_;
        _int = value;
    }

    this(dchar value) {
        _type = Type.char_;
        _char = value;
    }

    this(double value) {
        _type = Type.float_;
        _float = value;
    }

    this(bool value) {
        _type = Type.bool_;
        _bool = value;
    }

    this(string value) {
        _type = Type.string_;
        _string = value;
    }

    /// Récupère la valeur au bon format
    T get(T)() const {
        static if (is(Unqual!T == enum)) {
            enforce!ConsoleException(_type == Type.string_, "la valeur n’est pas une énumération");
            try {
                return to!T(_string);
            }
            catch (ConvException e) {
                throw new ConsoleException("l’énumération n’est pas un champ valide");
            }
        }
        else static if (isSomeString!T) {
            enforce!ConsoleException(_type == Type.string_, "la valeur n’est pas un string");
            return to!T(_string);
        }
        else static if (is(Unqual!T == U[], U)) {
            T result;
            foreach (value; _array) {
                result ~= value.get!U();
            }
            return result;
        }
        else static if (isSomeChar!T) {
            enforce!ConsoleException(_type == Type.char_, "la valeur n’est pas un caractère");
            return to!T(_char);
        }
        else static if (is(Unqual!T == bool)) {
            enforce!ConsoleException(_type == Type.bool_, "la valeur n’est pas booléenne");
            return _bool;
        }
        else static if (__traits(isIntegral, T)) {
            static if (__traits(isUnsigned, T)) {
                switch (_type) with (Type) {
                case uint_:
                    static if (T.sizeof < ulong.sizeof) {
                        enforce!ConsoleException(_uint < T.max, "la valeur est trop grande");
                    }
                    return cast(T) _uint;
                case int_:
                    enforce!ConsoleException(_int >= 0, "la valeur est négative");
                    static if (T.sizeof < long.sizeof) {
                        enforce!ConsoleException(_int < T.max, "la valeur est trop grande");
                    }
                    return cast(T) _int;
                default:
                    throw new ConsoleException("la valeur n’est pas un nombre intégral");
                }
            }
            else static if (isSigned!T) {
                switch (_type) with (Type) {
                case uint_:
                    static if (T.sizeof < ulong.sizeof) {
                        enforce!ConsoleException(_uint < T.max, "la valeur est trop grande");
                    }
                    static if (T.sizeof == ulong.sizeof) {
                        enforce!ConsoleException(_uint & (1uL << 63), "la valeur est trop grande");
                    }
                    return cast(T) _uint;
                case int_:
                    static if (T.sizeof < long.sizeof) {
                        enforce!ConsoleException(_int < T.max, "la valeur est trop grande");
                    }
                    return cast(T) _int;
                default:
                    throw new ConsoleException("la valeur n’est pas un nombre intégral");
                }
            }
        }
        else static if (__traits(isFloating, T)) {
            switch (_type) with (Type) {
            case uint_:
                return cast(T) _uint;
            case int_:
                return cast(T) _int;
            case float_:
                return cast(T) _float;
            default:
                throw new ConsoleException("la valeur n’est pas un nombre à virgule flottante");
            }
        }
        else {
            static assert(false, "type `" ~ T.stringof ~ "` non-supporté");
        }
    }

    /// Modifie la valeur au bon format
    void set(T)(const T value) {
        static if (is(Unqual!T == enum)) {
            _string = to!string(value);
            _type = Type.string_;
        }
        else static if (isSomeString!T) {
            _string = to!string(value);
            _type = Type.string_;
        }
        else static if (is(Unqual!T == U[], U)) {
            _array.length = 0;
            foreach (ref element; value) {
                Value subValue;
                subValue.set!U(element);
                _array ~= subValue;
            }
            _type = Type.array_;
        }
        else static if (isSomeChar!T) {
            _char = to!dchar(value);
            _type = Type.char_;
        }
        else static if (is(Unqual!T == bool)) {
            _bool = value;
            _type = Type.bool_;
        }
        else static if (__traits(isIntegral, T)) {
            static if (__traits(isUnsigned, T)) {
                _uint = value;
                _type = Type.uint_;
            }
            else static if (isSigned!T) {
                _int = value;
                _type = Type.int_;
            }
        }
        else static if (__traits(isFloating, T)) {
            _float = value;
            _type = Type.float_;
        }
        else {
            static assert(false, "type `" ~ T.stringof ~ "` non-supporté");
        }
    }

    string toString() const {
        final switch (_type) with (Type) {
        case uint_:
            return to!string(_uint);
        case int_:
            return to!string(_int);
        case char_:
            return "'" ~ to!string(_char) ~ "'";
        case float_:
            return to!string(_float);
        case bool_:
            return _bool ? "true" : "false";
        case string_:
            return "\"" ~ _string ~ "\"";
        }
    }
}
