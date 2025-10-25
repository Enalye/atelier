module atelier.common.terrain;

import farfadet;
import atelier.common.grid;
import atelier.common.resource;
import atelier.common.stream;
import atelier.common.vec2;

final class TerrainMap : Resource!TerrainMap {
    private {
        string _tilesetRID;
        Grid!int _collision;
        Grid!int _material;
        Brush[] _brushes;
        uint _columns, _lines;
    }

    class Brush {
        enum TilesSize = 16;
        enum CliffsSize = 38;

        string name;
        int id;
        int[][TilesSize] tiles;
        int[][CliffsSize] cliffs;

        struct CliffInfo {
            int index;
            bool isUpperLayer;

            this(int below, int ground, int above, bool isUpperLayer_) {
                index = (below & 0xf) | ((ground & 0xf) << 4) | ((above & 0xf) << 8);
                isUpperLayer = isUpperLayer_;
            }
        }

        struct ComposedCliffInfo {
            int index;
            int firstTile, secondTile;

            this(int below, int ground, int above, int firstTile_ = -1, int secondTile_ = -1) {
                index = (below & 0xf) | ((ground & 0xf) << 4) | ((above & 0xf) << 8);
                firstTile = firstTile_;
                secondTile = secondTile_;
            }
        }

        static immutable composedCliffIndexes = [
            ComposedCliffInfo(0b0011, 0b1000, 0b0100, 1),
            ComposedCliffInfo(0b0011, 0b0100, 0b1000, 1),

            ComposedCliffInfo(0, 0b1010, 0b0101, 13),
            ComposedCliffInfo(0, 0b0101, 0b1010, 14),

            ComposedCliffInfo(0b0100, 0b0001, 0b1010, 4, 28),
            ComposedCliffInfo(0b1000, 0b0010, 0b0101, 5, 27),

            ComposedCliffInfo(0b1000, 0b0011, 0b0100, 19),
            ComposedCliffInfo(0b0100, 0b0011, 0b1000, 20),

            ComposedCliffInfo(0b1010, 0, 0b0101, 5),
            ComposedCliffInfo(0b0101, 0, 0b1010, 6),

            ComposedCliffInfo(0b1000, 0b0001, 0b0110, 19),
            ComposedCliffInfo(0b0100, 0b0010, 0b1001, 20),

            ComposedCliffInfo(0b1010, 0b0001, 0b0100, 19),
            ComposedCliffInfo(0b0101, 0b0010, 0b1000, 20),

            ComposedCliffInfo(0b0010, 0b1000, 0b0101, 13),
            ComposedCliffInfo(0b0001, 0b0100, 0b1010, 14),

            ComposedCliffInfo(0b0001, 0b1100, 0b0010, 1, 16),
            ComposedCliffInfo(0b0010, 0b1100, 0b0001, 1, 18),

            ComposedCliffInfo(0b0001, 0b0110, 0b1000, 11),
            ComposedCliffInfo(0b0010, 0b1001, 0b0100, 12),

            ComposedCliffInfo(0b1010, 0b0100, 0b0001, 18, 0),
            ComposedCliffInfo(0b0101, 0b1000, 0b0010, 16, 2),

            ComposedCliffInfo(0b0010, 0b0100, 0b1001, 1),
            ComposedCliffInfo(0b0001, 0b1000, 0b0110, 1),

            ComposedCliffInfo(0b0001, 0b1010, 0b0100, 11),
            ComposedCliffInfo(0b0010, 0b0101, 0b1000, 12),
        ];

        static immutable cliffIndexes = [
            // 1ère ligne
            CliffInfo(0b1011, 0b0100, 0, true), CliffInfo(0b0011, 0b1100, 0,
                true), CliffInfo(0b0111, 0b1000, 0, true),
            CliffInfo(0b1001, 0b0110, 0, true), CliffInfo(0b0110, 0b1001, 0,
                true), CliffInfo(0b1000, 0, 0b0111, false),
            CliffInfo(0b0100, 0, 0b1011, false),

            CliffInfo(0b1000, 0b0100, 0b0011, true),

            // 2ème ligne
            CliffInfo(0b1101, 0b0010, 0, false),
            CliffInfo(0b1100, 0b0011, 0, false),
            CliffInfo(0b1110, 0b0001, 0, false),
            CliffInfo(0b0001, 0b1110, 0, true), CliffInfo(0b0010, 0b1101, 0,
                true), CliffInfo(0, 0b1000, 0b0111, true),
            CliffInfo(0, 0b0100, 0b1011, true),

            CliffInfo(0b0100, 0b1000, 0b0011, true),

            // 3ème ligne
            CliffInfo(0b1101, 0, 0b0010, false),
            CliffInfo(0b1100, 0, 0b0011, false),
            CliffInfo(0b1110, 0, 0b0001, false),
            CliffInfo(0b1000, 0b0111, 0, false),
            CliffInfo(0b0100, 0b1011, 0, false),

            CliffInfo(0b0100, 0b1001, 0b0010, false),
            CliffInfo(0b1000, 0b0110, 0b0001, false),

            CliffInfo(0b0100, 0b1010, 0b0001, false),

            // 4ème ligne
            CliffInfo(0, 0b1101, 0b0010, true), CliffInfo(0, 0b1100, 0b0011,
                true), CliffInfo(0, 0b1110, 0b0001, true),
            CliffInfo(0b1101, 0b0010, 0, false),
            CliffInfo(0b1110, 0b0001, 0, false),

            CliffInfo(0b1100, 0b0001, 0b0010, false),
            CliffInfo(0b1100, 0b0010, 0b0001, false),

            CliffInfo(0b1000, 0b0101, 0b0010, false),

            // 5ème ligne
            CliffInfo(0b0101, 0b1010, 0, false),
            CliffInfo(0b1010, 0b0101, 0, false),

            CliffInfo(0b1001, 0b0100, 0b0010, false),
            CliffInfo(0b0110, 0b1000, 0b0001, false),

            CliffInfo(0, 0b1001, 0b0110, false),
            CliffInfo(0, 0b0110, 0b1001, false),
        ];
    }

    @property {
        string tileset() const {
            return _tilesetRID;
        }

        string tileset(string tileset_) {
            return _tilesetRID = tileset_;
        }
    }

    this() {
        _collision = new Grid!int;
        _material = new Grid!int;
    }

    this(const Farfadet ffd) {
        _collision = new Grid!int;
        _material = new Grid!int;

        if (ffd.hasNode("size")) {
            Farfadet sizeNode = ffd.getNode("size");
            _columns = sizeNode.get!uint(0);
            _lines = sizeNode.get!uint(1);
            _collision.setDimensions(_columns, _lines);
            _material.setDimensions(_columns << 1, _lines << 1);
        }

        if (ffd.hasNode("tileset")) {
            _tilesetRID = ffd.getNode("tileset").get!string(0);
        }
        if (ffd.hasNode("collision")) {
            _collision.setValues(0, 0, ffd.getNode("collision").get!(int[][])(0));
        }

        if (ffd.hasNode("material")) {
            _material.setValues(0, 0, ffd.getNode("material").get!(int[][])(0));
        }

        foreach (brushNode; ffd.getNodes("brush")) {
            Brush brush = new Brush;
            brush.name = brushNode.get!string(0);
            brush.id = cast(uint) _brushes.length;

            foreach (tileNode; brushNode.getNodes("tiles")) {
                uint id = tileNode.get!uint(0);
                if (id >= Brush.TilesSize)
                    continue;
                brush.tiles[id] = tileNode.get!(int[])(1);
            }

            foreach (tileNode; brushNode.getNodes("cliffs")) {
                uint id = tileNode.get!uint(0);
                if (id >= Brush.CliffsSize)
                    continue;
                brush.cliffs[id] = tileNode.get!(int[])(1);
            }
            _brushes ~= brush;
        }
    }

    /// Accès à la ressource
    TerrainMap fetch() {
        return this;
    }

    void serialize(OutStream stream) {
        stream.write(_tilesetRID);
        stream.write(_columns);
        stream.write(_lines);

        stream.write!(int[][])(_collision.getValues());
        stream.write!(int[][])(_material.getValues());

        stream.write(_brushes.length);
        foreach (ref brush; _brushes) {
            stream.write(brush.name);
            for (size_t i; i < Brush.TilesSize; ++i) {
                stream.write!(int[])(brush.tiles[i]);
            }
            for (size_t i; i < Brush.CliffsSize; ++i) {
                stream.write!(int[])(brush.cliffs[i]);
            }
        }
    }

    void deserialize(InStream stream) {
        _tilesetRID = stream.read!string();
        _columns = stream.read!uint();
        _lines = stream.read!uint();

        _collision.setDimensions(_columns, _lines);
        _material.setDimensions(_columns << 1, _lines << 1);
        _collision.setValues(0, 0, stream.read!(int[][])());
        _material.setValues(0, 0, stream.read!(int[][])());

        _brushes.length = stream.read!size_t();
        for (size_t i; i < _brushes.length; ++i) {
            Brush brush = new Brush;
            brush.name = stream.read!string();
            brush.id = cast(uint) i;
            for (size_t y; y < Brush.TilesSize; ++y) {
                brush.tiles[y] = stream.read!(int[])();
            }
            for (size_t y; y < Brush.CliffsSize; ++y) {
                brush.cliffs[y] = stream.read!(int[])();
            }
            _brushes[brush.id] = brush;
        }
    }

    void setCollisions(int x, int y, int[][] values) {
        _collision.setValues(x, y, values);
    }

    void setMaterials(int x, int y, int[][] values) {
        _material.setValues(x, y, values);
    }

    Brush addBrush(string name) {
        Brush brush = new Brush;
        brush.name = name;
        brush.id = cast(uint) _brushes.length;
        _brushes ~= brush;
        return brush;
    }

    string[] getBrushNames() const {
        string[] result;
        foreach (brush; _brushes) {
            result ~= brush.name;
        }
        return result;
    }

    Brush getBrush(string name) {
        foreach (brush; _brushes) {
            if (brush.name == name) {
                return brush;
            }
        }
        return null;
    }

    Brush getBrush(int id) {
        if (id >= 0 && id < _brushes.length) {
            return _brushes[id];
        }
        return null;
    }

    int getMaterial(int tileId, Vec2i subCoords) {
        tileId <<= 1;
        Vec2i coords = Vec2i(tileId % _material.columns, tileId / _material.columns);
        coords.y <<= 1;
        coords += subCoords;
        return _material.getValue(coords.x, coords.y);
    }
}
