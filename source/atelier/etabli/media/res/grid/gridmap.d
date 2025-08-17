module atelier.etabli.media.res.grid.gridmap;

import std.conv : to;
import std.exception : enforce;
import std.math : floor, ceil;
import std.algorithm.comparison : min, max;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

final class GridMap(T) : Image {
    private {
        T[] _values;
        uint _columns, _lines;
        bool _isDirty = true;
        T _minValue, _maxValue;
    }

    Vec2f size = Vec2f.zero;
    T defaultValue;

    @property {
        uint columns() const {
            return _columns;
        }

        uint lines() const {
            return _lines;
        }

        Vec2f tileSize() const {
            return size / Vec2f(_columns, _lines);
        }
    }

    this(uint columns_, uint lines_) {
        _columns = columns_;
        _lines = lines_;
        size = Vec2f(32f, 32f) * Vec2f(_columns, _lines);
        _values.length = _columns * _lines;

        static if (is(T == uint) || is(T == int)) {
            defaultValue = 0;
        }
        else static if (is(T == float)) {
            defaultValue = 0f;
        }
        else static if (is(T == bool)) {
            defaultValue = false;
        }
    }

    this(GridMap gridmap) {
        super(gridmap);
        _columns = gridmap._columns;
        _lines = gridmap._lines;
        _values = gridmap._values.dup;
        defaultValue = gridmap.defaultValue;
        size = gridmap.size;
    }

    void setSize(uint columns_, uint lines_) {
        T[][] values = getValues();
        _values.length = columns_ * lines_;

        if (columns_ > _columns && lines_ > _lines) {
            for (int y = _lines; y < lines_; y++) {
                for (int x = _columns; x < columns_; x++) {
                    _values[x + y * columns_] = defaultValue;
                }
            }
        }
        else if (columns_ > _columns) {
            for (int y = 0; y < lines_; y++) {
                for (int x = _columns; x < columns_; x++) {
                    _values[x + y * columns_] = defaultValue;
                }
            }
        }
        else if (lines_ > _lines) {
            for (int y = _lines; y < lines_; y++) {
                for (int x = 0; x < columns_; x++) {
                    _values[x + y * columns_] = defaultValue;
                }
            }
        }
        _columns = columns_;
        _lines = lines_;

        setValues(0, 0, values);

        _isDirty = true;
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
        _isDirty = true;
    }

    void setValues(const(T[][]) values_) {
        enforce(values_.length == _lines, "taille des tuiles invalides: " ~ to!string(
                values_.length) ~ " lignes au lieu de " ~ to!string(_lines));
        foreach (size_t y, ref const(T[]) line; values_) {
            enforce(line.length == _columns, "taille des tuiles invalides: " ~ to!string(
                    values_.length) ~ " colonnes au lieu de " ~ to!string(
                    _columns) ~ " à la ligne " ~ to!string(y));
            foreach (size_t x, T value; line) {
                _values[x + y * _columns] = value;
            }
        }
        _isDirty = true;
    }

    T[][] getValues() {
        T[][] values = new T[][](_columns, _lines);

        for (size_t y; y < _lines; ++y) {
            for (size_t x; x < _columns; ++x) {
                values[x][y] = _values[x + y * _columns];
            }
        }

        return values;
    }

    void setValues(int x, int y, const(T[][]) values_) {
        foreach (size_t col, ref const(T[]) column; values_) {
            if ((col + x) >= _columns || (col + x) < 0)
                continue;

            foreach (size_t ln, T value; column) {
                if ((ln + y) >= _lines || (ln + y) < 0)
                    continue;

                _values[(col + x) + (ln + y) * _columns] = value;
            }
        }
        _isDirty = true;
    }

    override void update() {
        if (_isDirty) {
            _isDirty = false;

            static if (is(T == float) || is(T == uint) || is(T == int)) {
                _minValue = defaultValue;
                _maxValue = defaultValue;

                for (size_t i; i < _lines * _columns; ++i) {
                    T value = _values[i];
                    if (value < _minValue) {
                        _minValue = value;
                    }
                    if (value > _maxValue) {
                        _maxValue = value;
                    }
                }

                import std.stdio;

                writeln("min: ", _minValue, " max: ", _maxValue);
            }
        }
    }

    /// Redimensionne l’image pour qu’elle puisse tenir dans une taille donnée
    override void fit(Vec2f size_) {
        size = size_;
    }

    /// Redimensionne l’image pour qu’elle puisse contenir une taille donnée
    override void contain(Vec2f size_) {
        size = size_;
    }

    override void draw(Vec2f origin = Vec2f.zero) {
        Vec2f finalTileSize = size / Vec2f(_columns, _lines);
        Vec2f startPos = origin + position - size * anchor;
        Vec2f tilePos;

        for (int y = 0; y < _lines; y++) {
            for (int x = 0; x < _columns; x++) {
                tilePos = startPos;
                tilePos.x += x * finalTileSize.x;
                tilePos.y += y * finalTileSize.y;

                T value = _values[x + y * _columns];

                float t = rlerp(_minValue, _maxValue, value);
                //Color c = Color.black.lerp(Color.white, t);
                Color c = Color(t, t, t);

                Atelier.renderer.drawRect(tilePos, finalTileSize, c, 1f, true);
            }
        }
    }
}
