module atelier.common.optional;

import std.exception : enforce;

struct Option(T) {
    private {
        T _value;
        bool _hasValue = false;
    }

    @property {
        bool isNull() const {
            return !_hasValue;
        }
    }

    this(T value) {
        _value = value;
        _hasValue = true;
    }

    void setNull() {
        _hasValue = false;
    }

    void set(T value) {
        _hasValue = true;
        _value = value;
    }

    ref T get() {
        enforce(_hasValue, "l’option ne contient aucune valeur");
        return _value;
    }

    ref T getOr(ref T defaultValue) {
        if (_hasValue)
            return _value;
        return defaultValue;
    }

    bool opEquals(const Option!T other) const @safe pure nothrow {
        if (other._hasValue != _hasValue)
            return false;
        return (!_hasValue) || (other._value == _value);
    }

    bool opEquals(const T other) const @safe pure nothrow {
        if (!_hasValue)
            return false;
        return other == _value;
    }

    T opCast(T : bool)() const {
        return _hasValue;
    }

    void opAssign(T value) {
        _value = value;
        _hasValue = true;
    }

    size_t toHash() const @safe pure nothrow {
        import std.typecons : tuple;

        return tuple(_value, _hasValue).toHash();
    }
}

Option!T some(T)(T value) {
    return Option!T(value);
}

Option!T none(T)() {
    return Option!T();
}
