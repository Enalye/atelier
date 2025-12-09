module atelier.common.terrain;

import farfadet;
import atelier.common.grid;
import atelier.common.resource;
import atelier.common.stream;
import atelier.common.vec2;

final class TerrainMap : Resource!TerrainMap {
    private {
        string _tilesetRID;
        Grid!int _cliffmap;
        Grid!int _brushmap;
        Brush[] _brushes;
        uint[] _brushIndexes;
        uint _columns, _lines;
        Cliff[CliffsSize] _cliffs;
    }

    struct Brush {
        bool isValid;
        int id = -1;
        int material;
        string name;
    }

    struct Tiles {
        int[] ids;
    }

    struct Cliff {
        Tiles[uint] tiles;

        void addTile(uint tileValue, uint tileId) {
            tiles.update(tileValue,
                () {
                Tiles t; //
                t.ids ~= tileId; //
                return t; //
            },
                (ref Tiles t) {
                t.ids ~= tileId; //
            });
        }
    }

    enum CliffsSize = 39;

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

    static immutable cliffMasks = [
        // 1ère ligne
        0b0100, //
        0b1100, //
        0b1000, //
        0b0110, //
        0b1001, //
        0b0010, //
        0b0001, //
        0b0111, //

        // 2ème ligne
        0b0010, //
        0b0011, //
        0b0001, //
        0b1110, //
        0b1101, //
        0b1010, //
        0b0101, //
        0b1011, //

        // 3ème ligne
        0b0010, //
        0b0011, //
        0b0001, //
        0b0111, //
        0b1011, //
        0b1011, //
        0b0111, //
        0b1011, //

        // 4ème ligne
        0b1111, //
        0b1111, //
        0b1111, //
        0b0010, //
        0b0001, //
        0b0011, //
        0b0011, //
        0b0111, //

        // 5ème ligne
        0b1010, //
        0b0101, //
        0b0110, //
        0b1001, //
        0b1011, //
        0b0111, //        
    ];

    @property {
        string tileset() const {
            return _tilesetRID;
        }

        string tileset(string tileset_) {
            return _tilesetRID = tileset_;
        }
    }

    this() {
        _cliffmap = new Grid!int;
        _brushmap = new Grid!int;
    }

    this(const Farfadet ffd) {
        _cliffmap = new Grid!int;
        _brushmap = new Grid!int;

        if (ffd.hasNode("size")) {
            Farfadet sizeNode = ffd.getNode("size");
            _columns = sizeNode.get!uint(0);
            _lines = sizeNode.get!uint(1);
            setSize(_columns, _lines);
        }

        if (ffd.hasNode("tileset")) {
            _tilesetRID = ffd.getNode("tileset").get!string(0);
        }
        if (ffd.hasNode("cliffmap")) {
            _cliffmap.setValues(0, 0, ffd.getNode("cliffmap").get!(int[][])(0));
        }

        if (ffd.hasNode("brushmap")) {
            _brushmap.setValues(0, 0, ffd.getNode("brushmap").get!(int[][])(0));
        }

        foreach (brushNode; ffd.getNodes("brush")) {
            uint id;
            if (brushNode.hasNode("id")) {
                id = brushNode.getNode("id").get!uint(0);
            }
            string name;
            if (brushNode.hasNode("name")) {
                name = brushNode.getNode("name").get!string(0);
            }
            int material = -1;
            if (brushNode.hasNode("material")) {
                material = brushNode.getNode("material").get!int(0);
            }

            addBrush(name, id, material);
        }

        cache();
    }

    void setSize(uint columns_, uint lines_) {
        _columns = columns_;
        _lines = lines_;
        _cliffmap.setDimensions(_columns, _lines);
        _brushmap.setDimensions(_columns << 1, _lines << 1);
    }

    void cache() {
        immutable Vec2i[4] cornerOffsets = [
            Vec2i(0, 0), Vec2i(1, 0), Vec2i(1, 1), Vec2i(0, 1)
        ];

        uint tileId;
        Vec2i coords;
        for (uint y; y < _lines; ++y) {
            for (uint x; x < _columns; ++x) {
                int cliffValue = _cliffmap.getValue(x, y);
                uint tileValue;
                uint cliffMask = 0b1111;

                if (cliffValue >= 0) {
                    cliffMask = TerrainMap.cliffMasks[cliffValue];
                }

                for (uint i; i < 4; ++i) {
                    if ((cliffMask & (1 << i)) == 0)
                        continue;

                    coords.x = (x << 1) + cornerOffsets[i].x;
                    coords.y = (y << 1) + cornerOffsets[i].y;
                    uint corner = _brushmap.getValue(coords.x, coords.y);
                    tileValue |= corner << (i << 3);
                }

                _cliffs[cliffValue + 1].addTile(tileValue, tileId);
                tileId++;
            }
        }
    }

    int[] getTiles(int cliffIndex, uint brushIndex) {
        if (cliffIndex == -1) {
            auto pTiles = brushIndex in _cliffs[0].tiles;
            return pTiles !is null ? pTiles.ids : [];
        }

        if (cliffIndex < 0 || (cliffIndex + 1) >= _cliffs.length) {
            return [];
        }

        int cliffMask = TerrainMap.cliffMasks[cliffIndex];
        int brushMask;
        for (uint i; i < 4; ++i) {
            if (cliffMask & (1 << i)) {
                brushMask |= 0xff << (i << 3);
            }
        }
        brushIndex &= brushMask;

        auto pTiles = brushIndex in _cliffs[cliffIndex + 1].tiles;
        return pTiles !is null ? pTiles.ids : [];
    }

    /// Accès à la ressource
    TerrainMap fetch() {
        return this;
    }

    void serialize(OutStream stream) {
        stream.write!string(_tilesetRID);
        stream.write!uint(_columns);
        stream.write!uint(_lines);

        stream.write!(int[][])(_cliffmap.getValues());
        stream.write!(int[][])(_brushmap.getValues());

        stream.write!uint(cast(uint) _brushes.length);
        foreach (ref brush; _brushes) {
            stream.write(brush.name);
            stream.write(brush.id);
            stream.write(brush.material);
        }
    }

    void deserialize(InStream stream) {
        _tilesetRID = stream.read!string();
        _columns = stream.read!uint();
        _lines = stream.read!uint();

        _cliffmap.setDimensions(_columns, _lines);
        _brushmap.setDimensions(_columns << 1, _lines << 1);
        _cliffmap.setValues(0, 0, stream.read!(int[][])());
        _brushmap.setValues(0, 0, stream.read!(int[][])());

        uint brushCount = stream.read!uint();
        for (size_t i; i < brushCount; ++i) {
            string name = stream.read!string();
            uint id = stream.read!uint();
            int material = stream.read!int();
            addBrush(name, id, material);
        }

        cache();
    }

    void setCliffmap(int x, int y, int[][] values) {
        _cliffmap.setValues(x, y, values);
    }

    void setBrushmap(int x, int y, int[][] values) {
        _brushmap.setValues(x, y, values);
    }

    void addBrush(string name, uint id, int material) {
        if (id >= 256)
            return;

        if (id >= _brushes.length) {
            _brushes.length = id + 1;
        }
        _brushes[id].isValid = true;
        _brushes[id].id = id;
        _brushes[id].name = name;
        _brushes[id].material = material;
        _brushIndexes ~= id;
    }

    string[] getBrushNames() const {
        string[] result;
        foreach (index; _brushIndexes) {
            result ~= _brushes[index].name;
        }
        return result;
    }

    Brush getBrush(string name) {
        foreach (index; _brushIndexes) {
            if (_brushes[index].name == name) {
                return _brushes[index];
            }
        }
        return Brush();
    }

    Brush getBrush(int id) {
        if (id >= 0 && id < _brushes.length) {
            return _brushes[id];
        }
        return Brush();
    }

    int getMaterial(int tileId, Vec2i subCoords) {
        tileId <<= 1;
        Vec2i coords = Vec2i(tileId % _brushmap.columns, tileId / _brushmap.columns);
        coords.y <<= 1;
        coords += subCoords;
        int brush = _brushmap.getValue(coords.x, coords.y);
        if (brush < 0 || brush >= _brushes.length)
            return -1;
        return _brushes[brush].material;
    }
}
