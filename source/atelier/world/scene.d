module atelier.world.scene;

import std.algorithm;
import std.conv : to, ConvException;
import std.exception : enforce;

import farfadet;
import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world.weather;
import atelier.world.entity;

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
                return 0b1111;
            case 1:
                return 0b1110;
            case 2:
                return 0b1101;
            case 3:
                return 0b0100;
            case 4:
                return 0b1000;
            case 5:
                return 0b1010;
            case 6:
                return 0b0011;
            case 7:
                return 0b0110;
            case 8:
                return 0b1001;
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
                return 0b1100;
            default:
                return 0;
            }
        }
    }

    final class TopologicMap {
        private {
            string _terrainRID;
            TerrainMap _terrainMap;
            Tileset _tileset;
            Tilemap[] _lowerTilemaps, _upperTilemaps;
            Grid!int _levelGrid;
            Grid!int _brushGrid;
            Grid!bool _cliffGrid;
        }

        @property {
            Tilemap[] lowerTilemaps() {
                return _lowerTilemaps;
            }

            Tilemap[] upperTilemaps() {
                return _upperTilemaps;
            }

            Tileset tileset() {
                return _tileset;
            }

            string terrainRID() {
                return _terrainRID;
            }
        }

        this() {
            _levelGrid = new Grid!int(_columns + 1, _lines + _levels);
            _brushGrid = new Grid!int(_columns + 1, _lines + _levels);
            _cliffGrid = new Grid!bool(_columns + 1, _lines + _levels);

            _levelGrid.defaultValue = -1;
            _brushGrid.defaultValue = 0;
            _cliffGrid.defaultValue = false;
        }

        void setup() {
            _terrainMap = Atelier.res.get!TerrainMap(_terrainRID);
            _tileset = Atelier.res.get!Tileset(_terrainMap.tileset);
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

            updateTiles();
        }

        void setupWireframe(TopologicMap baseMap) {
            _terrainRID = "wireframe";
            _levelGrid.setValues(0, 0, baseMap._levelGrid.getValues());
            _brushGrid.setValues(0, 0, baseMap._brushGrid.getValues());
        }

        void setDimensions(uint columns, uint lines) {
            _levelGrid.setDimensions(columns + 1, lines + _levels);
            _brushGrid.setDimensions(columns + 1, lines + _levels);
            _cliffGrid.setDimensions(columns + 1, lines + _levels);

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

            if (node.hasNode("levels")) {
                _levelGrid.setValues(0, 0, node.getNode("levels").get!(int[][])(0));
            }
            if (node.hasNode("brushes")) {
                _brushGrid.setValues(0, 0, node.getNode("brushes").get!(int[][])(0));
            }
        }

        void serialize(OutStream stream) {
            stream.write!string(_terrainRID);
            stream.write!(int[][])(_levelGrid.getValues());
            stream.write!(int[][])(_brushGrid.getValues());
        }

        void deserialize(InStream stream) {
            _terrainRID = stream.read!string();
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
        }

        void processCliff(int x, int y, Vec2i[4] neighborsOffset) {
            Vec2i neighbor;
            int neighborLevel;
            int neighborBrush;
            TerrainMap.Brush brush, currentBrush;
            int[4] levels;
            int minLevel, maxLevel;
            foreach (int i, Vec2i neighborOffset; neighborsOffset) {
                neighbor = Vec2i(x, y) + neighborOffset;
                neighborBrush = _brushGrid.getValue(neighbor.x, neighbor.y);
                neighborLevel = _levelGrid.getValue(neighbor.x, neighbor.y);
                currentBrush = _terrainMap.getBrush(neighborBrush);

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

                if (currentBrush && brush) {
                    if (currentBrush.id != brush.id) {
                        break;
                    }
                }
                if (currentBrush) {
                    brush = currentBrush;
                }
            }

            if (!brush) {
                brush = _terrainMap.getBrush(0);
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
                for (int i; i < TerrainMap.Brush.cliffIndexes.length; ++i) {
                    TerrainMap.Brush.CliffInfo info = TerrainMap.Brush.cliffIndexes[i];
                    if (tileValue == info.index) {
                        if (info.isUpperLayer) {
                            upperTiles = brush.cliffs[i];
                        }
                        else {
                            lowerTiles = brush.cliffs[i];
                        }
                        break;
                    }
                }
                if (lowerTiles.length == 0 && upperTiles.length == 0) {
                    for (int i; i < TerrainMap.Brush.composedCliffIndexes.length;
                        ++i) {
                        TerrainMap.Brush.ComposedCliffInfo info =
                            TerrainMap.Brush.composedCliffIndexes[i];
                        if (tileValue == info.index) {
                            if (info.firstTile >= 0) {
                                TerrainMap.Brush.CliffInfo firstCliffInfo =
                                    TerrainMap.Brush.cliffIndexes[info.firstTile];

                                if (firstCliffInfo.isUpperLayer) {
                                    upperTiles = brush.cliffs[info.firstTile];
                                }
                                else {
                                    lowerTiles = brush.cliffs[info.firstTile];
                                }
                            }

                            if (info.secondTile >= 0) {
                                TerrainMap.Brush.CliffInfo secondCliffInfo =
                                    TerrainMap.Brush.cliffIndexes[info.secondTile];

                                if (secondCliffInfo.isUpperLayer) {
                                    upperTiles = brush.cliffs[info.secondTile];
                                }
                                else {
                                    lowerTiles = brush.cliffs[info.secondTile];
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
            int tileId = 0;
            uint tileIndex = 0;
            Vec2i neighbor;
            int neighborBrush;
            int neighborLevel;
            bool neighborCliff;
            TerrainMap.Brush brush, currentBrush;
            int level = int.max;

            foreach (int i, Vec2i neighborOffset; neighborsOffset) {
                neighbor = Vec2i(x, y) + neighborOffset;
                neighborBrush = _brushGrid.getValue(neighbor.x, neighbor.y);
                neighborLevel = _levelGrid.getValue(neighbor.x, neighbor.y);
                neighborCliff = _cliffGrid.getValue(neighbor.x, neighbor.y);
                currentBrush = _terrainMap.getBrush(neighborBrush);

                if (neighborLevel < level) {
                    level = neighborLevel;
                }

                if (currentBrush && brush) {
                    if (currentBrush.id != brush.id) {
                        tileIndex = -1;
                        break;
                    }
                }
                if (currentBrush) {
                    brush = currentBrush;
                }

                if (neighborBrush != -1 || neighborCliff) {
                    tileIndex |= 0x1 << i;
                }
            }

            if (!brush) {
                brush = _terrainMap.getBrush(0);
            }
            int[] tiles = brush.tiles[tileIndex];
            if (tiles.length) {
                tileId = tiles[(x + y) % tiles.length];
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
        }
    }

    private {
        EntityBuilder[] _entities;
        LightBuilder[] _lights;
        TerrainLayer[] _terrainlayers;
        ParallaxLayer[] _parallaxLayers;
        CollisionLayer[] _collisionLayers;
        TopologicMap _topologicMap, _topologicWireframeMap;
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

        TopologicMap topologicWireframeMap() {
            return _topologicWireframeMap;
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
        _topologicWireframeMap = new TopologicMap;
    }

    Scene fetch() {
        return this;
    }

    void setup() {
        _topologicMap.setup();
        _topologicWireframeMap.setup();

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
            _topologicWireframeMap.setDimensions(_columns, _lines);
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
        _topologicWireframeMap.load(ffd);
        _topologicWireframeMap.setupWireframe(_topologicMap);

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
        _topologicWireframeMap.setDimensions(_columns, _lines);
        _topologicWireframeMap.setupWireframe(_topologicMap);

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

                return _topologicMap._terrainMap.getMaterial(tileId, subCoords);
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
    enum Type {
        pointLight
    }

    private {
        Type _type;
        string _name;
        Vec2i _position;
        float _radius = 0f;
        Color _color = Color.white;
        float _brightness = 1f;
    }

    @property {
        Type type() const {
            return _type;
        }

        string name() const {
            return _name;
        }

        Vec2i position() const {
            return _position;
        }

        float radius() const {
            return _radius;
        }

        Color color() const {
            return _color;
        }

        float brightness() const {
            return _brightness;
        }
    }

    this(Farfadet ffd) {
        try {
            _type = to!Type(ffd.get!string(0));
        }
        catch (Exception e) {
            _type = Type.pointLight;
        }

        if (ffd.hasNode("name")) {
            _name = ffd.getNode("name").get!string(0);
        }

        if (ffd.hasNode("position")) {
            _position = ffd.getNode("position").get!Vec2i(0);
        }

        if (ffd.hasNode("radius")) {
            _radius = ffd.getNode("radius").get!float(0);
        }

        if (ffd.hasNode("color")) {
            Farfadet colorNode = ffd.getNode("color");
            _color = Color(colorNode.get!float(0), colorNode.get!float(1),
                colorNode.get!float(2));
        }

        if (ffd.hasNode("brightness")) {
            _brightness = ffd.getNode("brightness").get!float(0);
        }
    }

    this(InStream stream) {
        _type = stream.read!Type();
        _name = stream.read!string();
        _position = stream.read!Vec2i();
        _radius = stream.read!float();
        _color = stream.read!Color();
        _brightness = stream.read!float();
    }

    void serialize(OutStream stream) {
        stream.write!Type(_type);
        stream.write!string(_name);
        stream.write!Vec2i(_position);
        stream.write!float(_radius);
        stream.write!Color(_color);
        stream.write!float(_brightness);
    }
}

final class EntityBuilder {
    enum Type {
        prop,
        actor,
        trigger,
        teleporter,
        note
    }

    private {
        Type _type;
        EntityData _data;
        union {
            PropBuilderData _prop;
            ActorBuilderData _actor;
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

        PropBuilderData prop() {
            return _prop;
        }

        ActorBuilderData actor() {
            return _actor;
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
            _type = Type.prop;
        }

        _data.load(ffd);

        final switch (_type) with (Type) {
        case prop:
            _prop = new PropBuilderData(ffd);
            break;
        case actor:
            _actor = new ActorBuilderData(ffd);
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
        }
    }

    this(InStream stream) {
        _type = stream.read!Type();
        _data.deserialize(stream);

        final switch (_type) with (Type) {
        case prop:
            _prop = new PropBuilderData(stream);
            break;
        case actor:
            _actor = new ActorBuilderData(stream);
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
        }
    }

    void serialize(OutStream stream) {
        stream.write!Type(_type);
        _data.serialize(stream);

        final switch (_type) with (Type) {
        case prop:
            _prop.serialize(stream);
            break;
        case actor:
            _actor.serialize(stream);
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
        }
    }
}

final class PropBuilderData {
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

final class ActorBuilderData {
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
        Vec3i _hitbox;
    }

    @property {
        string event() const {
            return _event;
        }

        Vec3i hitbox() const {
            return _hitbox;
        }
    }

    this(Farfadet ffd) {
        if (ffd.hasNode("event")) {
            _event = ffd.getNode("event").get!string(0);
        }
        if (ffd.hasNode("hitbox")) {
            _hitbox = ffd.getNode("hitbox").get!Vec3i(0);
        }
    }

    this(InStream stream) {
        _event = stream.read!string();
        _hitbox = stream.read!Vec3i();
    }

    void serialize(OutStream stream) {
        stream.write!string(_event);
        stream.write!Vec3i(_hitbox);
    }
}

final class TeleporterBuilderData {
    private {
        string _scene;
        string _target;
        uint _direction;
        Vec3i _hitbox;
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
    }

    this(InStream stream) {
        _scene = stream.read!string();
        _target = stream.read!string();
        _direction = stream.read!uint();
        _hitbox = stream.read!Vec3i();
    }

    void serialize(OutStream stream) {
        stream.write!string(_scene);
        stream.write!string(_target);
        stream.write!uint(_direction);
        stream.write!Vec3i(_hitbox);
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
