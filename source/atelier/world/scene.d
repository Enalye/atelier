module atelier.world.scene;

import std.algorithm;
import std.conv : to, ConvException;
import std.exception : enforce;

import farfadet;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.render;
import atelier.world.weather;
import atelier.world.entity;
import atelier.world.lighting;

final class Scene : Resource!Scene {
    final class TerrainLayer {
        private {
            string _name;
            int _level;
            TerrainMap _terrainMap;
            Tileset _tileset;
            Tilemap _tilemap;
            string _terrainRID;
        }

        @property {
            int level() const {
                return _level;
            }

            Color color() const {
                return _tilemap.color;
            }

            Color color(Color color_) {
                return _tilemap.color = color_;
            }

            Tilemap tilemap() {
                return _tilemap;
            }

            string terrainRID() {
                return _terrainRID;
            }

            string terrainRID(string id) {
                return _terrainRID = id;
            }
        }

        this(uint width, uint height) {
            _tilemap = new Tilemap(width, height);
        }

        this(TerrainLayer other) {
            _name = other._name;
            _level = other._level;
            _terrainRID = other._terrainRID;
            _tilemap = new Tilemap(other._tilemap);
        }

        void setup() {
            _terrainMap = Atelier.res.get!TerrainMap(_terrainRID);
            _tileset = Atelier.res.get!Tileset(_terrainMap.tileset);
            _tilemap.setTileset(_tileset);
            _tilemap.size = _tilemap.mapSize();
        }

        void load(const(Farfadet) ffd) {
            _name = ffd.get!string(0);

            if (ffd.hasNode("level")) {
                _level = ffd.getNode("level").get!int(0);
            }

            if (ffd.hasNode("terrain")) {
                _terrainRID = ffd.getNode("terrain").get!string(0);
            }

            if (ffd.hasNode("tiles")) {
                _tilemap.setTiles(ffd.getNode("tiles").get!(int[][])(0));
            }
        }

        void serialize(OutStream stream) {
            stream.write!string(_name);
            stream.write!int(_level);
            stream.write!string(_terrainRID);
            stream.write!(int[][])(_tilemap.getTiles());
        }

        void deserialize(InStream stream) {
            _name = stream.read!string();
            _level = stream.read!int();
            _terrainRID = stream.read!string();
            _tilemap.setTiles(0, 0, stream.read!(int[][])());
        }

        void update() {
            _tilemap.update();
        }

        void drawLine(int y, Vec2f offset) {
            _tilemap.drawLine(y, offset);
        }

        void draw(Vec2f offset) {
            _tilemap.draw(offset);
        }
    }

    final class ParallaxLayer {
        private {
            string _name;
            float _distance = 1f;
            Tilemap _tilemap;
            string _tilesetRID;
            uint _columns, _lines;
        }

        @property {
            float distance() const {
                return _distance;
            }
        }

        this(uint width_, uint height_) {
            _columns = width_;
            _lines = height_;
            _tilemap = new Tilemap(_columns, _lines);
        }

        this(ParallaxLayer other) {
            _name = other._name;
            _columns = other._columns;
            _lines = other._lines;
            _distance = other._distance;
            _tilesetRID = other._tilesetRID;
            _tilemap = new Tilemap(other._tilemap);
        }

        void setup() {
            _tilemap.setTileset(Atelier.res.get!Tileset(_tilesetRID));
            _tilemap.size = _tilemap.mapSize();
        }

        void setSize(uint width_, uint height_) {
            _columns = width_;
            _lines = height_;
            _tilemap.setDimensions(_columns, _lines);
        }

        uint getWidth() const {
            return _columns;
        }

        uint getHeight() const {
            return _lines;
        }

        void load(const(Farfadet) ffd) {
            _name = ffd.get!string(0);

            if (ffd.hasNode("distance")) {
                _distance = ffd.getNode("distance").get!float(0);
            }

            if (ffd.hasNode("size")) {
                Farfadet sizeNode = ffd.getNode("size");
                _columns = sizeNode.get!uint(0);
                _lines = sizeNode.get!uint(1);
                _tilemap.setDimensions(_columns, _lines);
            }

            if (ffd.hasNode("tileset")) {
                _tilesetRID = ffd.getNode("tileset").get!string(0);
            }

            if (ffd.hasNode("tiles")) {
                _tilemap.setTiles(ffd.getNode("tiles").get!(int[][])(0));
            }
        }

        void serialize(OutStream stream) {
            stream.write!string(_name);
            stream.write!float(_distance);
            stream.write!uint(_columns);
            stream.write!uint(_lines);
            stream.write!string(_tilesetRID);
            stream.write!(int[][])(_tilemap.getTiles());
        }

        void deserialize(InStream stream) {
            _name = stream.read!string();
            _distance = stream.read!float();
            _columns = stream.read!uint();
            _lines = stream.read!uint();
            _tilesetRID = stream.read!string();
            _tilemap.setTiles(0, 0, stream.read!(int[][])());
        }

        void update() {
            _tilemap.update();
        }

        void draw(Vec2f offset) {
            _tilemap.draw(offset);
        }
    }

    final class CollisionLayer {
        private {
            string _name;
            int _level;
            Grid!int _grid;
        }

        @property {
            int level() const {
                return _level;
            }
        }

        this(uint width, uint height) {
            _grid = new Grid!int(width, height);
        }

        this(CollisionLayer other) {
            _name = other._name;
            _level = other._level;
            _grid = new Grid!int(other._grid);
        }

        void load(Farfadet ffd) {
            _name = ffd.get!string(0);

            if (ffd.hasNode("level")) {
                _level = ffd.getNode("level").get!int(0);
            }

            if (ffd.hasNode("tiles")) {
                _grid.setValues(0, 0, ffd.getNode("tiles").get!(int[][])(0));
            }
        }

        void serialize(OutStream stream) {
            stream.write!string(_name);
            stream.write!uint(_level);
            stream.write!(int[][])(_grid.getValues());
        }

        void deserialize(InStream stream) {
            _name = stream.read!string();
            _level = stream.read!uint();
            _grid.setValues(0, 0, stream.read!(int[][])());
        }

        int getId(int x, int y) {
            switch (_grid.getValue(x, y)) {
            case 0:
                return 0b1110;
            case 1:
                return 0b1101;
            case 2:
                return 0b0100;
            case 3:
                return 0b1000;
            case 4:
                return 0b1010;
            case 5:
                return 0b0011;
            case 6:
                return 0b0110;
            case 7:
                return 0b1001;
            case 8:
                return 0b1100;
            case 9:
                return 0b0111;
            case 10:
                return 0b1011;
            case 11:
                return 0b0010;
            case 12:
                return 0b0001;
            case 13:
                return 0b0101;
            case 14:
                return 0b1111;
            case 15:
                return 0x10 | Physics.Shape.slopeUp;
            case 16:
                return 0x10 | Physics.Shape.slopeDown;
            case 17:
                return 0x10 | Physics.Shape.slopeRight;
            case 18:
                return 0x10 | Physics.Shape.slopeLeft;
            case 19:
                return 0x10 | Physics.Shape.startSlopeUp;
            case 20:
                return 0x10 | Physics.Shape.middleSlopeUp;
            case 21:
                return 0x10 | Physics.Shape.endSlopeUp;
            case 22:
                return 0x10 | Physics.Shape.startSlopeDown;
            case 23:
                return 0x10 | Physics.Shape.middleSlopeDown;
            case 24:
                return 0x10 | Physics.Shape.endSlopeDown;
            case 25:
                return 0x10 | Physics.Shape.startSlopeRight;
            case 26:
                return 0x10 | Physics.Shape.middleSlopeRight;
            case 27:
                return 0x10 | Physics.Shape.endSlopeRight;
            case 28:
                return 0x10 | Physics.Shape.startSlopeLeft;
            case 29:
                return 0x10 | Physics.Shape.middleSlopeLeft;
            case 30:
                return 0x10 | Physics.Shape.endSlopeLeft;
            default:
                return 0;
            }
        }
    }

    final class TopologicMap {
        private {
            struct ShadowTile {
                int level;
                bool isShadowed;
            }

            string _terrainRID, _shadowRID;
            TerrainMap _terrainMap;
            Tileset _tileset, _shadowTileset;
            Tilemap[] _lowerTilemaps, _upperTilemaps, _shadowTilemaps;
            Grid!int _levelGrid;
            Grid!int _brushGrid;
            Grid!bool _cliffGrid;
            Grid!ShadowTile _shadowGrid;
        }

        @property {
            Tilemap[] lowerTilemaps() {
                return _lowerTilemaps;
            }

            Tilemap[] upperTilemaps() {
                return _upperTilemaps;
            }

            Tilemap[] shadowTilemaps() {
                return _shadowTilemaps;
            }

            Tileset tileset() {
                return _tileset;
            }

            string terrainRID() {
                return _terrainRID;
            }

            string terrainRID(string id) {
                return _terrainRID = id;
            }

            string shadowRID() {
                return _shadowRID;
            }

            string shadowRID(string id) {
                return _shadowRID = id;
            }

            Grid!int levelGrid() {
                return _levelGrid;
            }

            Grid!int brushGrid() {
                return _brushGrid;
            }
        }

        this() {
            _levelGrid = new Grid!int(_columns + 1, _lines + _levels);
            _brushGrid = new Grid!int(_columns + 1, _lines + _levels);
            _cliffGrid = new Grid!bool(_columns + 1, _lines + _levels);
            _shadowGrid = new Grid!ShadowTile((_columns + 1) << 1, (_lines + _levels) << 1);

            _levelGrid.defaultValue = -1;
            _brushGrid.defaultValue = 0;
            _cliffGrid.defaultValue = false;
            _shadowGrid.defaultValue = ShadowTile(-1, false);
        }

        void setup() {
            _terrainMap = Atelier.res.get!TerrainMap(_terrainRID);
            _tileset = Atelier.res.get!Tileset(_terrainMap.tileset);
            if (_shadowRID.length) {
                _shadowTileset = Atelier.res.get!Tileset(_shadowRID);
            }
            updateLevels();

            foreach (i, tilemap; _lowerTilemaps) {
                tilemap.setTileset(_tileset);
                tilemap.size = tilemap.mapSize();
                tilemap.anchor = Vec2f.zero;
                tilemap.position = Vec2f(columns, lines) * -8f - Vec2f(0f, i << 4);
            }
            foreach (i, tilemap; _upperTilemaps) {
                tilemap.setTileset(_tileset);
                tilemap.size = tilemap.mapSize();
                tilemap.anchor = Vec2f.zero;
                tilemap.position = Vec2f(columns, lines) * -8f - Vec2f(0f, i << 4);
            }
            foreach (i, tilemap; _shadowTilemaps) {
                if (_shadowTileset) {
                    tilemap.setTileset(_shadowTileset);
                }
                tilemap.size = tilemap.mapSize();
                tilemap.anchor = Vec2f.zero;
                tilemap.position = Vec2f(columns, lines) * -8f - Vec2f(0f, i << 4);
                tilemap.color = Color.blue.mix(Color.purple).mix(Color.black);
                tilemap.blend = Blend.alpha;
                tilemap.alpha = 0.2f;
            }

            updateTiles();
        }

        void setDimensions(uint columns, uint lines) {
            _levelGrid.setDimensions(columns + 1, lines + _levels);
            _brushGrid.setDimensions(columns + 1, lines + _levels);
            _cliffGrid.setDimensions(columns + 1, lines + _levels);
            _shadowGrid.setDimensions(columns + 1, lines + _levels);

            foreach (i, tilemap; _lowerTilemaps) {
                tilemap.setDimensions(columns, lines + cast(uint) i);
                tilemap.size = tilemap.mapSize();
                tilemap.anchor = Vec2f.zero;
                tilemap.position = Vec2f(columns, lines) * -8f - Vec2f(0f, i << 4);
            }
            foreach (i, tilemap; _upperTilemaps) {
                tilemap.setDimensions(columns, lines + cast(uint) i);
                tilemap.size = tilemap.mapSize();
                tilemap.anchor = Vec2f.zero;
                tilemap.position = Vec2f(columns, lines) * -8f - Vec2f(0f, i << 4);
            }
            foreach (i, tilemap; _shadowTilemaps) {
                tilemap.setDimensions(columns, lines + cast(uint) i);
                tilemap.size = tilemap.mapSize();
                tilemap.anchor = Vec2f.zero;
                tilemap.position = Vec2f(columns, lines) * -8f - Vec2f(0f, i << 4);
            }
        }

        int getLevel(int x, int y) {
            return _levelGrid.getValue(x, y);
        }

        void load(const(Farfadet) ffd) {
            if (!ffd.hasNode("topography"))
                return;

            Farfadet node = ffd.getNode("topography");

            if (node.hasNode("terrain")) {
                _terrainRID = node.getNode("terrain").get!string(0);
            }
            if (node.hasNode("shadow")) {
                _shadowRID = node.getNode("shadow").get!string(0);
            }

            if (node.hasNode("levels")) {
                _levelGrid.setValues(0, 0, node.getNode("levels").get!(int[][])(0));
            }
            if (node.hasNode("brushes")) {
                _brushGrid.setValues(0, 0, node.getNode("brushes").get!(int[][])(0));
            }
        }

        void serialize(OutStream stream) {
            stream.write!string(_terrainRID);
            stream.write!string(_shadowRID);
            stream.write!(int[][])(_levelGrid.getValues());
            stream.write!(int[][])(_brushGrid.getValues());
        }

        void deserialize(InStream stream) {
            _terrainRID = stream.read!string();
            _shadowRID = stream.read!string();
            _levelGrid.setValues(0, 0, stream.read!(int[][])());
            _brushGrid.setValues(0, 0, stream.read!(int[][])());
        }

        void updateLevels() {
            if (_lowerTilemaps.length > _levels) {
                _lowerTilemaps.length = _levels;
            }
            else if (_lowerTilemaps.length < _levels) {
                for (size_t i = _lowerTilemaps.length; i < _levels; ++i) {
                    _lowerTilemaps ~= new Tilemap(_columns, _lines + cast(uint) i);
                }
            }

            if (_upperTilemaps.length > _levels) {
                _upperTilemaps.length = _levels;
            }
            else if (_upperTilemaps.length < _levels) {
                for (size_t i = _upperTilemaps.length; i < _levels; ++i) {
                    _upperTilemaps ~= new Tilemap(_columns, _lines + cast(uint) i);
                }
            }

            if (_shadowTilemaps.length > _levels) {
                _shadowTilemaps.length = _levels;
            }
            else if (_shadowTilemaps.length < _levels) {
                for (size_t i = _shadowTilemaps.length; i < _levels; ++i) {
                    _shadowTilemaps ~= new Tilemap(_columns, _lines + cast(uint) i);
                }
            }
        }

        void processShadow(int x, int y, Vec2i[4] neighborsOffset) {
            bool[] levels;
            levels.length = _levels;
            int[4] neighborLevels;
            ShadowTile[4] neighborShadows;

            foreach (int i, Vec2i neighborOffset; neighborsOffset) {
                Vec2i neighbor = Vec2i(x, y) + neighborOffset;
                neighborLevels[i] = _levelGrid.getValue(neighbor.x, neighbor.y);
                neighborShadows[i] = _shadowGrid.getValue(neighbor.x, neighbor.y);
            }

            for (int i; i < 4; ++i) {
                int level = neighborLevels[i];
                if (level < 0 || level >= _levels || levels[level])
                    continue;

                levels[level] = true;

                int tileValue = 0;
                int levelValue = 0;

                for (int i2; i2 < 4; ++i2) {
                    ShadowTile neighborShadow = neighborShadows[i2];

                    if (neighborLevels[i2] < level) {
                        levelValue |= 0x1 << i2;
                    }
                    if (neighborLevels[i2] > level) {
                        levelValue |= 0x1 << (i2 + 4);
                    }

                    if (neighborShadow.isShadowed && neighborLevels[i2] == level) {
                        tileValue |= 1 << i2;
                    }
                }

                tileValue--;

                if (tileValue == 0 && (levelValue == 0b0110_0000 || levelValue == 0b0110_1000 || levelValue == 0b0100_1010)) {
                    tileValue = 16;
                }
                else if (tileValue == 1 && (levelValue == 0b1001_0000 || levelValue == 0b1001_0100 || levelValue == 0b1000_0101)) {
                    tileValue = 17;
                }
                else if (tileValue == 3 && (levelValue == 0b0010_0000 || levelValue == 0b0010_1001 || levelValue == 0b0010_1000)) {
                    tileValue = 18;
                }
                else if (tileValue == 7 && (levelValue == 0b0001_0000 || levelValue == 0b0001_0110 || levelValue == 0b0001_0100)) {
                    tileValue = 19;
                }
                else if (tileValue == 0 && levelValue == 0b0010_1100) {
                    tileValue = 24;
                }
                else if (tileValue == 1 && levelValue == 0b0001_1100) {
                    tileValue = 25;
                }
                else if (tileValue == 3 && (levelValue == 0b0011_1000 || levelValue == 0b0000_0011)) {
                    tileValue = 26;
                }
                else if (tileValue == 7 && (levelValue == 0b0011_0100 || levelValue == 0b0000_0011)) {
                    tileValue = 27;
                }
                else if (tileValue == 3 && (levelValue == 0b0010_0001 || levelValue == 0b0100_0011)) {
                    tileValue = 22;
                }
                else if (tileValue == 7 && (levelValue == 0b0001_0010 || levelValue == 0b0100_0011)) {
                    tileValue = 23;
                }
                else if (tileValue == 4 && levelValue == 0b1010_0000) {
                    tileValue = 28;
                }
                else if (tileValue == 9 && levelValue == 0b0101_0000) {
                    tileValue = 29;
                }
                else if (tileValue == 8 && levelValue == 0b0010_0100) {
                    tileValue = 31;
                }
                else if (tileValue == 5 && levelValue == 0b0001_1000) {
                    tileValue = 30;
                }

                _shadowTilemaps[level].setTile(x, y, tileValue);
            }
        }

        void processCliff(int x, int y, Vec2i[4] neighborsOffset) {
            Vec2i neighbor;
            int neighborLevel;
            int neighborBrush;
            int[4] levels;
            int minLevel, maxLevel;
            int tileIndex;

            foreach (int i, Vec2i neighborOffset; neighborsOffset) {
                neighbor = Vec2i(x, y) + neighborOffset;
                neighborBrush = _brushGrid.getValue(neighbor.x, neighbor.y);
                neighborLevel = _levelGrid.getValue(neighbor.x, neighbor.y);

                if (i == 0) {
                    minLevel = neighborLevel;
                    maxLevel = minLevel;
                }
                else if (neighborLevel > maxLevel) {
                    maxLevel = neighborLevel;
                }
                else if (neighborLevel < minLevel) {
                    minLevel = neighborLevel;
                }

                levels[i] = neighborLevel;
                tileIndex |= neighborBrush << (i << 3);
            }

            for (int level; level < _levels; ++level) {
                int tileValue = 0;
                for (int i; i < 4; ++i) {
                    if (levels[i] < level) {
                        tileValue |= 0x1 << i;
                    }
                    else if (levels[i] == level) {
                        tileValue |= 0x1 << (i + 4);
                    }
                    else if (levels[i] > level) {
                        tileValue |= 0x1 << (i + 8);
                    }
                }

                int[] lowerTiles, upperTiles;
                for (int i; i < TerrainMap.cliffIndexes.length; ++i) {
                    TerrainMap.CliffInfo info = TerrainMap.cliffIndexes[i];
                    if (tileValue == info.index) {
                        if (info.isUpperLayer) {
                            upperTiles = _terrainMap.getTiles(i, tileIndex);
                        }
                        else {
                            lowerTiles = _terrainMap.getTiles(i, tileIndex);
                        }
                        break;
                    }
                }
                if (lowerTiles.length == 0 && upperTiles.length == 0) {
                    for (int i; i < TerrainMap.composedCliffIndexes.length; ++i) {
                        TerrainMap.ComposedCliffInfo info =
                            TerrainMap.composedCliffIndexes[i];
                        if (tileValue == info.index) {
                            if (info.firstTile >= 0) {
                                TerrainMap.CliffInfo firstCliffInfo =
                                    TerrainMap.cliffIndexes[info.firstTile];

                                if (firstCliffInfo.isUpperLayer) {
                                    upperTiles = _terrainMap.getTiles(info.firstTile, tileIndex);
                                }
                                else {
                                    lowerTiles = _terrainMap.getTiles(info.firstTile, tileIndex);
                                }
                            }

                            if (info.secondTile >= 0) {
                                TerrainMap.CliffInfo secondCliffInfo =
                                    TerrainMap.cliffIndexes[info.secondTile];

                                if (secondCliffInfo.isUpperLayer) {
                                    upperTiles = _terrainMap.getTiles(info.secondTile, tileIndex);
                                }
                                else {
                                    lowerTiles = _terrainMap.getTiles(info.secondTile, tileIndex);
                                }
                            }
                            break;
                        }
                    }
                }

                int lowerTileId = -1;
                int upperTileId = -1;

                if (upperTiles.length) {
                    upperTileId = upperTiles[(x + y) % upperTiles.length];
                }

                if (lowerTiles.length) {
                    lowerTileId = lowerTiles[(x + y) % lowerTiles.length];
                }

                if (lowerTileId >= 0) {
                    _lowerTilemaps[level].setTile(x, y, lowerTileId);
                }

                _upperTilemaps[level].setTile(x, y, upperTileId);
            }
        }

        void processTile(int x, int y, Vec2i[4] neighborsOffset) {
            int tileId = -1;
            uint tileIndex = 0;
            Vec2i neighbor;
            int[4] neighborBrushes;
            int[4] neighborLevels;
            bool neighborCliff;
            int level = int.max;

            foreach (int i, Vec2i neighborOffset; neighborsOffset) {
                neighbor = Vec2i(x, y) + neighborOffset;
                neighborBrushes[i] = _brushGrid.getValue(neighbor.x, neighbor.y);
                neighborLevels[i] = _levelGrid.getValue(neighbor.x, neighbor.y);
                neighborCliff = _cliffGrid.getValue(neighbor.x, neighbor.y);

                if (neighborLevels[i] < level) {
                    level = neighborLevels[i];
                }

                if (i == 3 && neighborLevels[i] > neighborLevels[0]) {
                    neighborBrushes[i] = neighborBrushes[0];
                }
                else if (i == 2 && neighborLevels[i] > neighborLevels[1]) {
                    neighborBrushes[i] = neighborBrushes[1];
                }

                tileIndex |= neighborBrushes[i] << (i << 3);
            }

            if (tileIndex >= 0) {
                int[] tiles = _terrainMap.getTiles(-1, tileIndex);
                if (tiles.length) {
                    tileId = tiles[(x + y) % tiles.length];
                }
            }
            foreach (size_t i, Tilemap tilemap; _lowerTilemaps) {
                tilemap.setTile(x, y, (level == i) ? tileId : -1);
            }
        }

        void updateTiles() {
            if (!_terrainMap)
                return;

            immutable Vec2i[4] innerOffsets = [
                Vec2i(0, 0), Vec2i(1, 0), Vec2i(1, 1), Vec2i(0, 1)
            ];

            immutable Vec2i[8] cliffNodeOffsets = [
                Vec2i(-1, -1), Vec2i(0, -1), Vec2i(1, -1), Vec2i(-1, 0),
                Vec2i(1, 0), Vec2i(-1, 1), Vec2i(0, 1), Vec2i(1, 1),
            ];

            // Cache des jonctions de falaises
            for (uint y; y < _lines + _levels; ++y) {
                for (uint x; x < _columns + 1; ++x) {
                    int level = _levelGrid.getValue(x, y);
                    _cliffGrid.setValue(x, y, false);

                    foreach (offset; cliffNodeOffsets) {
                        Vec2i neighbor = Vec2i(x, y) + offset;
                        int neighborLevel = _levelGrid.getValue(neighbor.x, neighbor.y);
                        if (neighborLevel != level) {
                            _cliffGrid.setValue(x, y, true);
                            break;
                        }
                    }
                }
            }

            // Cache de l’ombragement
            for (uint y; y < _lines + _levels; ++y) {
                for (uint x; x < _columns + 1; ++x) {
                    Vec2i baseCoords = Vec2i(x, y);
                    int level = _levelGrid.getValue(baseCoords.x, baseCoords.y);

                    ShadowTile tile;
                    tile.level = level;

                    for (int iy = 1; iy <= y; ++iy) {
                        int otherLevel = _levelGrid.getValue(x, (cast(int) y) - iy);
                        int delta = (otherLevel - level) - iy;
                        if (delta >= 0) {
                            tile.isShadowed = true;
                            break;
                        }
                    }
                    _shadowGrid.setValue(x, y, tile);
                }
            }

            uint maxY = _lines + max(0, (cast(int) _levels) - 1);

            // Terrain
            processTile(0, 0, innerOffsets);
            processTile(_columns, 0, innerOffsets);
            processTile(_columns, maxY, innerOffsets);
            processTile(0, maxY, innerOffsets);

            for (uint x = 1; x < _columns; ++x) {
                processTile(x, 0, innerOffsets);
                processTile(x, maxY, innerOffsets);
            }

            for (uint y = 1; y < maxY; ++y) {
                processTile(0, y, innerOffsets);
                processTile(_columns, y, innerOffsets);

                for (uint x = 1; x < _columns; ++x) {
                    processTile(x, y, innerOffsets);
                }
            }

            // Falaises
            processCliff(0, 0, innerOffsets);
            processCliff(_columns, 0, innerOffsets);
            processCliff(_columns, maxY, innerOffsets);
            processCliff(0, maxY, innerOffsets);

            for (uint x = 1; x < _columns; ++x) {
                processCliff(x, 0, innerOffsets);
                processCliff(x, maxY, innerOffsets);
            }

            for (uint y = 1; y < maxY; ++y) {
                processCliff(0, y, innerOffsets);
                processCliff(_columns, y, innerOffsets);

                for (uint x = 1; x < _columns; ++x) {
                    processCliff(x, y, innerOffsets);
                }
            }

            // Ombres
            processShadow(0, 0, innerOffsets);
            processShadow(_columns, 0, innerOffsets);
            processShadow(_columns, maxY, innerOffsets);
            processShadow(0, maxY, innerOffsets);

            for (uint x = 1; x < _columns; ++x) {
                processShadow(x, 0, innerOffsets);
                processShadow(x, maxY, innerOffsets);
            }

            for (uint y = 1; y < maxY; ++y) {
                processShadow(0, y, innerOffsets);
                processShadow(_columns, y, innerOffsets);

                for (uint x = 1; x < _columns; ++x) {
                    processShadow(x, y, innerOffsets);
                }
            }
        }

        void update() {
            foreach (tilemap; _lowerTilemaps) {
                tilemap.update();
            }
            foreach (tilemap; _upperTilemaps) {
                tilemap.update();
            }
        }
    }

    private {
        EntityBuilder[] _entities;
        LightBuilder[] _lights;
        TerrainLayer[] _terrainlayers;
        ParallaxLayer[] _parallaxLayers;
        CollisionLayer[] _collisionLayers;
        TopologicMap _topologicMap;
        string _name;
        uint _columns, _lines;
        int _levels;
        uint _mainLevel;
        float _brightness = 1f;
        string _weatherType;
        float _weatherValue = 1f;
    }

    @property {
        uint columns() const {
            return _columns;
        }

        uint lines() const {
            return _lines;
        }

        uint levels() const {
            return _levels;
        }

        float brightness() const {
            return _brightness;
        }

        string weatherType() const {
            return _weatherType;
        }

        float weatherValue() const {
            return _weatherValue;
        }

        TopologicMap topologicMap() {
            return _topologicMap;
        }

        TerrainLayer[] terrainLayers() {
            return _terrainlayers;
        }

        ParallaxLayer[] parallaxLayers() {
            return _parallaxLayers;
        }

        CollisionLayer[] collisionLayers() {
            return _collisionLayers;
        }

        EntityBuilder[] entities() {
            return _entities;
        }

        LightBuilder[] lights() {
            return _lights;
        }
    }

    this() {
        _topologicMap = new TopologicMap;
    }

    Scene fetch() {
        return this;
    }

    void setup() {
        _topologicMap.setup();

        foreach (layer; _terrainlayers) {
            layer.setup();
        }

        foreach (layer; _parallaxLayers) {
            layer.setup();
        }
    }

    void load(const(Farfadet) ffd) {
        _name = ffd.get!string(0);

        if (ffd.hasNode("size")) {
            Farfadet node = ffd.getNode("size");
            _columns = node.get!uint(0);
            _lines = node.get!uint(1);
            _topologicMap.setDimensions(_columns, _lines);
        }

        if (ffd.hasNode("levels")) {
            _levels = ffd.getNode("levels").get!(int)(0);
        }

        if (ffd.hasNode("mainLevel")) {
            _mainLevel = ffd.getNode("mainLevel").get!(uint)(0);
        }

        if (ffd.hasNode("brightness")) {
            _brightness = ffd.getNode("brightness").get!(float)(0);
        }

        if (ffd.hasNode("weather")) {
            Farfadet weatherNode = ffd.getNode("weather");
            _weatherType = weatherNode.get!(string)(0);
            _weatherValue = weatherNode.get!(float)(1);
        }

        _topologicMap.load(ffd);

        foreach (layerNode; ffd.getNodes("terrainLayer")) {
            TerrainLayer layer = new TerrainLayer(_columns, _lines);
            layer.load(layerNode);
            _terrainlayers ~= layer;
        }

        foreach (layerNode; ffd.getNodes("parallaxLayer")) {
            ParallaxLayer layer = new ParallaxLayer(_columns, _lines);
            layer.load(layerNode);
            _parallaxLayers ~= layer;
        }

        foreach (layerNode; ffd.getNodes("collisionLayer")) {
            CollisionLayer layer = new CollisionLayer(_columns, _lines);
            layer.load(layerNode);
            _collisionLayers ~= layer;
        }

        sort!((a, b) => (a.level < b.level), SwapStrategy.stable)(
            _collisionLayers);

        foreach (entityNode; ffd.getNodes("entity")) {
            EntityBuilder entity = new EntityBuilder(entityNode);
            _entities ~= entity;
        }

        foreach (lightNode; ffd.getNodes("light")) {
            LightBuilder light = new LightBuilder(lightNode);
            _lights ~= light;
        }
    }

    void serialize(OutStream stream) {
        stream.write!string(_name);
        stream.write!uint(_columns);
        stream.write!uint(_lines);
        stream.write!int(_levels);
        stream.write!uint(_mainLevel);
        stream.write!float(_brightness);
        stream.write!string(_weatherType);
        stream.write!float(_weatherValue);

        _topologicMap.serialize(stream);

        stream.write!uint(cast(uint) _terrainlayers.length);
        foreach (layer; _terrainlayers) {
            layer.serialize(stream);
        }

        stream.write!uint(cast(uint) _parallaxLayers.length);
        foreach (layer; _parallaxLayers) {
            layer.serialize(stream);
        }

        stream.write!uint(cast(uint) _collisionLayers.length);
        foreach (layer; _collisionLayers) {
            layer.serialize(stream);
        }

        stream.write!uint(cast(uint) _entities.length);
        foreach (EntityBuilder entity; _entities) {
            entity.serialize(stream);
        }

        stream.write!uint(cast(uint) _lights.length);
        foreach (LightBuilder light; _lights) {
            light.serialize(stream);
        }
    }

    void deserialize(InStream stream) {
        _name = stream.read!string();
        _columns = stream.read!uint();
        _lines = stream.read!uint();
        _levels = stream.read!int();
        _mainLevel = stream.read!uint();
        _brightness = stream.read!float();
        _weatherType = stream.read!string();
        _weatherValue = stream.read!float();

        _topologicMap.setDimensions(_columns, _lines);
        _topologicMap.deserialize(stream);

        const uint terrainCount = stream.read!uint();
        for (uint i; i < terrainCount; ++i) {
            TerrainLayer layer = new TerrainLayer(_columns, _lines);
            layer.deserialize(stream);
            _terrainlayers ~= layer;
        }

        const uint parallaxCount = stream.read!uint();
        for (uint i; i < parallaxCount; ++i) {
            ParallaxLayer layer = new ParallaxLayer(_columns, _lines);
            layer.deserialize(stream);
            _parallaxLayers ~= layer;
        }

        const uint collisionCount = stream.read!uint();
        for (uint i; i < collisionCount; ++i) {
            CollisionLayer layer = new CollisionLayer(_columns, _lines);
            layer.deserialize(stream);
            _collisionLayers ~= layer;
        }

        const uint entityCount = stream.read!uint();
        _entities = new EntityBuilder[entityCount];
        for (uint i; i < entityCount; ++i) {
            _entities[i] = new EntityBuilder(stream);
        }

        const uint lightCount = stream.read!uint();
        _lights = new LightBuilder[lightCount];
        for (uint i; i < lightCount; ++i) {
            _lights[i] = new LightBuilder(stream);
        }
    }

    void update() {
        _topologicMap.update();

        foreach (layer; _terrainlayers)
            layer.update();

        foreach (layer; _parallaxLayers)
            layer.update();
    }

    int getBaseZ(Vec2i pos) {
        Vec2i coords = (pos - 8) / 16;
        return _topologicMap.getLevel(coords.x, coords.y) * 16;
    }

    int getLevel(int x, int y) {
        return _topologicMap.getLevel(x, y);
    }

    int getMaterial(Vec3i pos) {
        if (pos.z < 0 || _levels <= 0)
            return 0;

        Vec3i coords;
        Vec2i subCoords;

        coords.x = pos.x / 16;
        coords.y = pos.y / 16;
        coords.z = pos.z / 16;

        if (coords.z >= _levels)
            coords.z = _levels - 1;

        int tileId = -1;

        foreach_reverse (layer; _terrainlayers) {
            if (coords.z != cast(int) layer.level)
                continue;

            tileId = layer._tilemap.getTile(coords.x, coords.y);
            if (tileId >= 0) {
                subCoords.x = (pos.x / 8) & 0x1;
                subCoords.y = (pos.y / 8) & 0x1;

                int material = layer._terrainMap.getMaterial(tileId, subCoords);
                if (material >= 0)
                    return material;
            }
        }

        coords.x = pos.x / 16;
        coords.y = pos.y / 16;

        tileId = _topologicMap._upperTilemaps[coords.z].getTile(coords.x, coords.y);
        if (tileId < 0) {
            tileId = _topologicMap._lowerTilemaps[coords.z].getTile(coords.x, coords.y);
        }

        subCoords.x = (pos.x / 8) & 0x1;
        subCoords.y = (pos.y / 8) & 0x1;

        return _topologicMap._terrainMap.getMaterial(tileId, subCoords);
    }
}

final class LightBuilder {
    private {
        string _rid;
        LightData _data;
    }

    @property {
        string rid() const {
            return _rid;
        }

        const(LightData) data() const {
            return _data;
        }
    }

    this(Farfadet ffd) {
        _rid = ffd.get!string(0);
        _data.load(ffd);
    }

    this(InStream stream) {
        _rid = stream.read!string();
        _data.deserialize(stream);
    }

    void serialize(OutStream stream) {
        stream.write!string(_rid);
        _data.serialize(stream);
    }
}

final class EntityBuilder {
    enum Type {
        entity,
        trigger,
        teleporter,
        note,
        marker
    }

    private {
        Type _type;
        EntityData _data;
        union {
            EntityBuilderData _entity;
            TriggerBuilderData _trigger;
            TeleporterBuilderData _teleporter;
            NoteBuilderData _note;
        }
    }

    @property {
        Type type() const {
            return _type;
        }

        const(EntityData) data() const {
            return _data;
        }

        EntityBuilderData entity() {
            return _entity;
        }

        TriggerBuilderData trigger() {
            return _trigger;
        }

        TeleporterBuilderData teleporter() {
            return _teleporter;
        }

        NoteBuilderData note() {
            return _note;
        }
    }

    this(Farfadet ffd) {
        try {
            _type = to!Type(ffd.get!string(0));
        }
        catch (Exception e) {
            _type = Type.entity;
        }

        _data.load(ffd);

        final switch (_type) with (Type) {
        case entity:
            _entity = new EntityBuilderData(ffd);
            break;
        case trigger:
            _trigger = new TriggerBuilderData(ffd);
            break;
        case teleporter:
            _teleporter = new TeleporterBuilderData(ffd);
            break;
        case note:
            _note = new NoteBuilderData(ffd);
            break;
        case marker:
            break;
        }
    }

    this(InStream stream) {
        _type = stream.read!Type();
        _data.deserialize(stream);

        final switch (_type) with (Type) {
        case entity:
            _entity = new EntityBuilderData(stream);
            break;
        case trigger:
            _trigger = new TriggerBuilderData(stream);
            break;
        case teleporter:
            _teleporter = new TeleporterBuilderData(stream);
            break;
        case note:
            _note = new NoteBuilderData(stream);
            break;
        case marker:
            break;
        }
    }

    void serialize(OutStream stream) {
        stream.write!Type(_type);
        _data.serialize(stream);

        final switch (_type) with (Type) {
        case entity:
            _entity.serialize(stream);
            break;
        case trigger:
            _trigger.serialize(stream);
            break;
        case teleporter:
            _teleporter.serialize(stream);
            break;
        case note:
            _note.serialize(stream);
            break;
        case marker:
            break;
        }
    }
}

final class EntityBuilderData {
    private {
        float _angle = 180f;
        string _rid;
        string _graphic;
    }

    @property {
        string rid() const {
            return _rid;
        }

        string graphic() const {
            return _graphic;
        }

        float angle() const {
            return _angle;
        }
    }

    this(Farfadet ffd) {
        if (ffd.hasNode("rid")) {
            _rid = ffd.getNode("rid").get!string(0);
        }

        if (ffd.hasNode("graphic")) {
            _graphic = ffd.getNode("graphic").get!string(0);
        }

        if (ffd.hasNode("angle")) {
            _angle = ffd.getNode("angle").get!float(0);
        }
    }

    this(InStream stream) {
        _rid = stream.read!string();
        _graphic = stream.read!string();
        _angle = stream.read!float();
    }

    void serialize(OutStream stream) {
        stream.write!string(_rid);
        stream.write!string(_graphic);
        stream.write!float(_angle);
    }
}

final class TriggerBuilderData {
    private {
        string _event;
        bool _isActive;
        bool _isActiveOnce;
        Vec3i _hitbox;
    }

    @property {
        string event() const {
            return _event;
        }

        Vec3i hitbox() const {
            return _hitbox;
        }

        bool isActive() const {
            return _isActive;
        }

        bool isActiveOnce() const {
            return _isActiveOnce;
        }
    }

    this(Farfadet ffd) {
        if (ffd.hasNode("event")) {
            _event = ffd.getNode("event").get!string(0);
        }
        if (ffd.hasNode("hitbox")) {
            _hitbox = ffd.getNode("hitbox").get!Vec3i(0);
        }
        if (ffd.hasNode("isActive")) {
            _isActive = ffd.getNode("isActive").get!bool(0);
        }
        if (ffd.hasNode("isActiveOnce")) {
            _isActiveOnce = ffd.getNode("isActiveOnce").get!bool(0);
        }
    }

    this(InStream stream) {
        _event = stream.read!string();
        _hitbox = stream.read!Vec3i();
        _isActive = stream.read!bool();
        _isActiveOnce = stream.read!bool();
    }

    void serialize(OutStream stream) {
        stream.write!string(_event);
        stream.write!Vec3i(_hitbox);
        stream.write!bool(_isActive);
        stream.write!bool(_isActiveOnce);
    }
}

final class TeleporterBuilderData {
    private {
        string _scene;
        string _target;
        uint _direction;
        Vec3i _hitbox;
        bool _isActive;
    }

    @property {
        string scene() const {
            return _scene;
        }

        string target() const {
            return _target;
        }

        uint direction() const {
            return _direction;
        }

        Vec3i hitbox() const {
            return _hitbox;
        }

        bool isActive() const {
            return _isActive;
        }
    }

    this(Farfadet ffd) {
        if (ffd.hasNode("scene")) {
            _scene = ffd.getNode("scene").get!string(0);
        }
        if (ffd.hasNode("target")) {
            _target = ffd.getNode("target").get!string(0);
        }
        if (ffd.hasNode("direction")) {
            _direction = ffd.getNode("direction").get!uint(0);
        }
        if (ffd.hasNode("hitbox")) {
            _hitbox = ffd.getNode("hitbox").get!Vec3i(0);
        }
        if (ffd.hasNode("isActive")) {
            _isActive = ffd.getNode("isActive").get!bool(0);
        }
    }

    this(InStream stream) {
        _scene = stream.read!string();
        _target = stream.read!string();
        _direction = stream.read!uint();
        _hitbox = stream.read!Vec3i();
        _isActive = stream.read!bool();
    }

    void serialize(OutStream stream) {
        stream.write!string(_scene);
        stream.write!string(_target);
        stream.write!uint(_direction);
        stream.write!Vec3i(_hitbox);
        stream.write!bool(_isActive);
    }
}

final class NoteBuilderData {
    private {
        Vec2i _size;
    }

    @property {
        Vec2i size() const {
            return _size;
        }
    }

    this(Farfadet ffd) {
        if (ffd.hasNode("size")) {
            _size = ffd.getNode("size").get!Vec2i(0);
        }
    }

    this(InStream stream) {
        _size = stream.read!Vec2i();
    }

    void serialize(OutStream stream) {
        stream.write!Vec2i(_size);
    }
}
