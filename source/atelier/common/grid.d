module atelier.common.grid;

import std.conv : to;
import std.exception : enforce;
import atelier.common.resource;

final class Grid(T) : Resource!Grid {
    //static assert(__traits(isArithmetic, T));

    private {
        T[] _values;
        uint _columns, _lines;
    }

    T defaultValue;

    @property {
        uint columns() const {
            return _columns;
        }

        uint lines() const {
            return _lines;
        }
    }

    this() {
    }

    this(uint columns, uint lines) {
        _columns = columns;
        _lines = lines;

        _values.length = _columns * _lines;
        static if (__traits(isFloating, T)) {
            defaultValue = 0.0;

            foreach (ref T value; _values) {
                value = defaultValue;
            }
        }
    }

    this(Grid grid) {
        _columns = grid._columns;
        _lines = grid._lines;
        _values = grid._values.dup;
    }

    /// Accès à la ressource
    Grid fetch() {
        return new Grid(this);
    }

    void setDimensions(uint columns_, uint lines_) {
        T[][] values_ = getValues();
        _lines = lines_;
        _columns = columns_;
        _values.length = _columns * _lines;
        for (size_t i; i < _values.length; ++i) {
            _values[i] = defaultValue;
        }
        setValues(0, 0, values_);
    }

    T getValue(int id) {
        if (id < 0 || id >= _values.length)
            return defaultValue;

        return _values[id];
    }

    T getValue(int x, int y) {
        if (x < 0 || y < 0 || x >= _columns || y >= _lines)
            return defaultValue;

        return _values[x + y * _columns];
    }

    void setValue(int x, int y, T value) {
        if (x < 0 || y < 0 || x >= _columns || y >= _lines)
            return;

        _values[x + y * _columns] = value;
    }

    void setValues(const(T[][]) values) {
        enforce(values.length == _lines, "taille des tuiles invalides: " ~ to!string(
                values.length) ~ " lignes au lieu de " ~ to!string(_lines));
        foreach (size_t y, ref const(T[]) line; values) {
            enforce(line.length == _columns, "taille des tuiles invalides: " ~ to!string(
                    values.length) ~ " colonnes au lieu de " ~ to!string(
                    _columns) ~ " à la ligne " ~ to!string(y));
            foreach (size_t x, T value; line) {
                _values[x + y * _columns] = value;
            }
        }
    }

    void setValues(int x, int y, const(T[][]) values) {
        foreach (size_t ln, ref const(T[]) lines; values) {
            if ((ln + y) >= _lines || (ln + y) < 0)
                continue;

            foreach (size_t col, T value; lines) {
                if ((col + x) >= _columns || (col + x) < 0)
                    continue;

                _values[(col + x) + (ln + y) * _columns] = value;
            }
        }
    }

    T[][] getValues() {
        T[][] values = new T[][](_lines, _columns);

        for (size_t y; y < _lines; ++y) {
            for (size_t x; x < _columns; ++x) {
                values[y][x] = _values[x + y * _columns];
            }
        }

        return values;
    }
}
