module atelier.etabli.media.res.scene.common;

import std.conv : to;
import std.math : round;
import std.exception;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;
import atelier.world;

import atelier.etabli.ui;
import atelier.etabli.media.res.scene.terrain;
import atelier.etabli.media.res.scene.parallax;
import atelier.etabli.media.res.scene.collision;
import atelier.etabli.media.res.scene.entity;

package final class SceneDefinition {
    final class TerrainLayer {
        string name;
        bool isVisible = true;
        int level;
        Tilemap tilemap;
        TerrainToolbox toolbox;

        private {
            TerrainMap _terrainMap;
            string _terrainRID;
            Tileset _tileset;
        }

        @property {
            Tileset tileset() {
                return _tileset;
            }

            string terrainRID() {
                return _terrainRID;
            }

            string terrainRID(string rid) {
                _terrainRID = rid;
                _terrainMap = Atelier.etabli.getTerrain(_terrainRID);
                enforce(_terrainMap,
                    "La ressource `" ~ _terrainRID ~ "` de type terrain n’est pas définie");
                _tileset = Atelier.etabli.getTileset(_terrainMap.tileset);
                enforce(_tileset,
                    "La ressource `" ~ _terrainMap.tileset ~
                        "` de type tileset n’est pas définie");
                tilemap.setTileset(_tileset);
                if (toolbox) {
                    toolbox.setTileset(_terrainMap.tileset);
                }
                return _terrainRID;
            }
        }

        this(uint width, uint height) {
            tilemap = new Tilemap(width, height);
        }

        this(TerrainLayer other) {
            name = other.name;
            isVisible = true;
            level = other.level;
            _terrainRID = other._terrainRID;
            tilemap = new Tilemap(other.tilemap);
        }

        void openToolbox() {
            if (!toolbox) {
                toolbox = new TerrainToolbox;
                toolbox.setTileset(_terrainRID);
            }

            Atelier.ui.addUI(toolbox);
        }

        void closeToolbox() {
            if (toolbox) {
                toolbox.removeUI();
            }
        }

        void moveUp() {
            for (size_t i = 1; i < _terrainlayers.length; ++i) {
                if (_terrainlayers[i] == this) {
                    _terrainlayers[i] = _terrainlayers[i - 1];
                    _terrainlayers[i - 1] = this;
                    break;
                }
            }
        }

        void moveDown() {
            for (size_t i = 0; (i + 1) < _terrainlayers.length; ++i) {
                if (_terrainlayers[i] == this) {
                    _terrainlayers[i] = _terrainlayers[i + 1];
                    _terrainlayers[i + 1] = this;
                    break;
                }
            }
        }

        void remove() {
            TerrainLayer[] layers;
            foreach (layer; _terrainlayers) {
                if (layer != this) {
                    layers ~= layer;
                }
            }
            _terrainlayers = layers;
        }

        void save(Farfadet ffd) {
            Farfadet node = ffd.addNode("terrainLayer").add(name);
            node.addNode("level").add(level);
            node.addNode("isVisible").add(isVisible);
            node.addNode("terrain").add(_terrainRID);
            node.addNode("tiles").add(tilemap.getTiles());
        }

        void load(Farfadet ffd) {
            name = ffd.get!string(0);

            if (ffd.hasNode("level")) {
                level = ffd.getNode("level").get!int(0);
            }

            if (ffd.hasNode("isVisible")) {
                isVisible = ffd.getNode("isVisible").get!bool(0);
            }

            if (ffd.hasNode("terrain")) {
                terrainRID(ffd.getNode("terrain").get!string(0));
            }

            if (ffd.hasNode("tiles")) {
                tilemap.setTiles(0, 0, ffd.getNode("tiles").get!(int[][])(0));
            }
        }
    }

    final class ParallaxLayer {
        string name;
        bool isVisible = true;
        float distance = 1f;
        Tilemap tilemap;
        ParallaxToolbox toolbox;

        private {
            string _tilesetRID;
            Tileset _tileset;
            uint _columns, _lines;
        }

        @property {
            Tileset tileset() {
                return _tileset;
            }

            string tilesetRID() {
                return _tilesetRID;
            }

            string tilesetRID(string rid) {
                _tilesetRID = rid;
                _tileset = Atelier.etabli.getTileset(rid);
                tilemap.setTileset(_tileset);
                if (toolbox) {
                    toolbox.setTileset(rid);
                }
                return _tilesetRID;
            }
        }

        this(uint width_, uint height_) {
            _columns = width_;
            _lines = height_;
            tilemap = new Tilemap(_columns, _lines);
        }

        this(ParallaxLayer other) {
            name = other.name;
            isVisible = true;
            _columns = other._columns;
            _lines = other._lines;
            distance = other.distance;
            _tilesetRID = other._tilesetRID;
            tilemap = new Tilemap(other.tilemap);
        }

        void setSize(uint width_, uint height_) {
            _columns = width_;
            _lines = height_;
            tilemap.setDimensions(_columns, _lines);
        }

        uint getWidth() const {
            return _columns;
        }

        uint getHeight() const {
            return _lines;
        }

        void openToolbox() {
            if (!toolbox) {
                toolbox = new ParallaxToolbox;
                toolbox.setTileset(_tilesetRID);
            }

            Atelier.ui.addUI(toolbox);
        }

        void closeToolbox() {
            if (toolbox) {
                toolbox.removeUI();
            }
        }

        void moveUp() {
            for (size_t i = 1; i < _parallaxLayers.length; ++i) {
                if (_parallaxLayers[i] == this) {
                    _parallaxLayers[i] = _parallaxLayers[i - 1];
                    _parallaxLayers[i - 1] = this;
                    break;
                }
            }
        }

        void moveDown() {
            for (size_t i = 0; (i + 1) < _parallaxLayers.length; ++i) {
                if (_parallaxLayers[i] == this) {
                    _parallaxLayers[i] = _parallaxLayers[i + 1];
                    _parallaxLayers[i + 1] = this;
                    break;
                }
            }
        }

        void remove() {
            ParallaxLayer[] layers;
            foreach (layer; _parallaxLayers) {
                if (layer != this) {
                    layers ~= layer;
                }
            }
            _parallaxLayers = layers;
        }

        void save(Farfadet ffd) {
            Farfadet node = ffd.addNode("parallaxLayer").add(name);
            node.addNode("size").add(_columns).add(_lines);
            node.addNode("distance").add(distance);
            node.addNode("isVisible").add(isVisible);
            node.addNode("tileset").add(_tilesetRID);
            node.addNode("tiles").add(tilemap.getTiles());
        }

        void load(Farfadet ffd) {
            name = ffd.get!string(0);

            if (ffd.hasNode("distance")) {
                distance = ffd.getNode("distance").get!float(0);
            }

            if (ffd.hasNode("size")) {
                Farfadet sizeNode = ffd.getNode("size");
                _columns = sizeNode.get!uint(0);
                _lines = sizeNode.get!uint(1);
                tilemap.setDimensions(_columns, _lines);
            }

            if (ffd.hasNode("isVisible")) {
                isVisible = ffd.getNode("isVisible").get!bool(0);
            }

            if (ffd.hasNode("tileset")) {
                tilesetRID(ffd.getNode("tileset").get!string(0));
            }

            if (ffd.hasNode("tiles")) {
                tilemap.setTiles(0, 0, ffd.getNode("tiles").get!(int[][])(0));
            }
        }
    }

    final class CollisionLayer {
        string name;
        int level;
        int mode;
        bool isVisible;
        Tilemap tilemap;
        CollisionToolbox toolbox;

        this(uint width, uint height) {
            tilemap = new Tilemap(Atelier.res.get!Tileset("editor:collision"), width, height);
        }

        this(CollisionLayer other) {
            name = other.name;
            level = other.level;
            tilemap = new Tilemap(other.tilemap);
        }

        void openToolbox() {
            isVisible = true;

            if (!toolbox) {
                toolbox = new CollisionToolbox(mode);
            }

            Atelier.ui.addUI(toolbox);
        }

        void closeToolbox() {
            isVisible = false;

            if (toolbox) {
                toolbox.removeUI();
            }
        }

        void moveUp() {
            for (size_t i = 1; i < _collisionLayers.length; ++i) {
                if (_collisionLayers[i] == this) {
                    _collisionLayers[i] = _collisionLayers[i - 1];
                    _collisionLayers[i - 1] = this;
                    break;
                }
            }
        }

        void moveDown() {
            for (size_t i = 0; (i + 1) < _collisionLayers.length; ++i) {
                if (_collisionLayers[i] == this) {
                    _collisionLayers[i] = _collisionLayers[i + 1];
                    _collisionLayers[i + 1] = this;
                    break;
                }
            }
        }

        void remove() {
            CollisionLayer[] layers;
            foreach (layer; _collisionLayers) {
                if (layer != this) {
                    layers ~= layer;
                }
            }
            _collisionLayers = layers;
        }

        void save(Farfadet ffd) {
            Farfadet node = ffd.addNode("collisionLayer").add(name);
            node.addNode("level").add(level);
            node.addNode("tiles").add(tilemap.getTiles());
        }

        void load(Farfadet ffd) {
            name = ffd.get!string(0);

            if (ffd.hasNode("level")) {
                level = ffd.getNode("level").get!int(0);
            }

            if (ffd.hasNode("tiles")) {
                tilemap.setTiles(0, 0, ffd.getNode("tiles").get!(int[][])(0));
            }
        }
    }

    final class TopologicMap {
        private {
            string _terrainRID;
            Tileset _tileset;
            TerrainMap _terrainMap;
            Tilemap[] _lowerTilemaps, _upperTilemaps;
            Grid!int _levelGrid;
            Grid!int _brushGrid;
            Grid!bool _cliffGrid;
            bool _isDirty = true;
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

            string terrainRID(string rid) {
                _terrainRID = rid;
                _terrainMap = Atelier.etabli.getTerrain(_terrainRID);
                enforce(_terrainMap,
                    "La ressource `" ~ _terrainRID ~ "` de type terrain n’est pas définie");
                _tileset = Atelier.etabli.getTileset(_terrainMap.tileset);
                enforce(_tileset,
                    "La ressource `" ~ _terrainMap.tileset ~
                        "` de type tileset n’est pas définie");
                foreach (tilemap; _lowerTilemaps) {
                    tilemap.setTileset(_tileset);
                }
                foreach (tilemap; _upperTilemaps) {
                    tilemap.setTileset(_tileset);
                }
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

            updateLevels();
        }

        void setDimensions(uint columns, uint lines) {
            _levelGrid.setDimensions(columns + 1, lines + _levels);
            _brushGrid.setDimensions(columns + 1, lines + _levels);
            _cliffGrid.setDimensions(columns + 1, lines + _levels);

            foreach (i, tilemap; _lowerTilemaps) {
                tilemap.setDimensions(columns, lines + cast(uint) i);
            }
            foreach (i, tilemap; _upperTilemaps) {
                tilemap.setDimensions(columns, lines + cast(uint) i);
            }
        }

        int getLevel(int x, int y) {
            return _levelGrid.getValue(x, y);
        }

        void save(Farfadet ffd) {
            Farfadet node = ffd.addNode("topography");
            if (_terrainRID.length) {
                node.addNode("terrain").add(_terrainRID);
            }
            node.addNode("levels").add(_levelGrid.getValues());
            node.addNode("brushes").add(_brushGrid.getValues());
        }

        void load(Farfadet ffd) {
            if (!ffd.hasNode("topography"))
                return;

            Farfadet node = ffd.getNode("topography");

            if (node.hasNode("terrain")) {
                terrainRID(node.getNode("terrain").get!string(0));
            }

            if (node.hasNode("levels")) {
                _levelGrid.setValues(0, 0, node.getNode("levels").get!(int[][])(0));
            }
            if (node.hasNode("brushes")) {
                _brushGrid.setValues(0, 0, node.getNode("brushes").get!(int[][])(0));
            }

            updateTiles();
        }

        void updateLevels() {
            setDimensions(_columns, _lines);

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

            updateTiles();
        }

        void setTile(int x, int y, uint brushId, uint level) {
            int oldBrush = _brushGrid.getValue(x, y);
            int oldLevel = _levelGrid.getValue(x, y);
            if (oldBrush == brushId && oldLevel == level)
                return;

            _isDirty = true;

            _brushGrid.setValue(x, y, brushId);
            _levelGrid.setValue(x, y, level);
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
                /*if (level == maxLevel) {
                    int upperTileIndex = 0;
                    for (int i; i < 4; ++i) {
                        if (levels[i] == level) {
                            upperTileIndex |= 0x1 << i;
                        }
                    }
                    if (upperTileIndex == 0 || upperTileIndex == 15)
                        continue;

                    tiles = brush.tiles[27 + upperTileIndex];
                }*/
                int lowerTileId = -1;
                int upperTileId = -1;
                if (upperTiles.length) {
                    upperTileId = upperTiles[(x + y) % upperTiles.length];
                }
                if (lowerTiles.length) {
                    lowerTileId = lowerTiles[(x + y) % lowerTiles.length];
                }
                //if (tileId >= 0) {
                if (lowerTileId >= 0) {
                    _lowerTilemaps[level].setTile(x, y, lowerTileId);
                }

                _upperTilemaps[level].setTile(x, y, upperTileId);
                //log(x, ":", y, ", ", level, " -> ", tileId);
                //}
            }
        }
        /+
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

            int upperTileIndex = 0;
            int lowerTileIndex = 0;
            for (int i; i < 4; ++i) {
                if (levels[i] == maxLevel) {
                    upperTileIndex |= 0x1 << i;
                }
                if (levels[i] == minLevel) {
                    lowerTileIndex |= 0x1 << i;
                }
            }

            foreach (size_t tilemapLevel, Tilemap tilemap; _tilemaps) {
                bool isUpper, isBelow;

                isUpper = tilemapLevel == maxLevel;
                isBelow = tilemapLevel == minLevel;

                int[] tiles;
                if (isUpper) {
                    if (upperTileIndex == 0 || upperTileIndex == 15)
                        continue;

                    tiles = brush.tiles[27 + upperTileIndex];
                }
                else if (isBelow) {
                    if (upperTileIndex == 15)
                        continue;

                    immutable int[15] swapTable = [
                        0, 0, 0, 0, 1, 2, 3, 3, 4, 5, 6, 5, 7, 8, 9
                    ];
                    tiles = brush.tiles[16 + swapTable[lowerTileIndex]];
                }
                else if (tilemapLevel > minLevel && tilemapLevel < maxLevel) {
                    int currentTileIndex = 0;
                    for (int i; i < 4; ++i) {
                        if (levels[i] != tilemapLevel) {
                            currentTileIndex |= 0x1 << i;
                        }
                    }
                    /*
                    if(upperTileIndex == 0b11 && lowerTileIndex == 0b11) {
                        tiles = brush.tiles[16];
                    }
                    else if(upperTileIndex == 0b10 && lowerTileIndex == 0b1101) {
                        tiles = brush.tiles[50];
                    }
                    else if(upperTileIndex == 0b1 && lowerTileIndex == 0b1110) {
                        tiles = brush.tiles[51];
                    }
                    else if((upperTileIndex == 0b111 && lowerTileIndex == 0b1)
                    || (upperTileIndex == 0b10 && lowerTileIndex == 0b1101)
                    || (upperTileIndex == 0b101 && lowerTileIndex == 0b1010)) {
                        tiles = brush.tiles[27];
                    }
                    else if((upperTileIndex == 0b1011 && lowerTileIndex == 0b100)
                    || (upperTileIndex == 0b1 && lowerTileIndex == 0b1110)
                    || (upperTileIndex == 0b1010 && lowerTileIndex == 0b101)) {
                        tiles = brush.tiles[28];
                    }
                    else if(upperTileIndex == 0b10 && lowerTileIndex == 0b1000) {
                        tiles = brush.tiles[45];
                    }
                    else if(upperTileIndex == 0b1 && lowerTileIndex == 0b100) {
                        tiles = brush.tiles[44];
                    }
                    else if(upperTileIndex == 0b11 && lowerTileIndex == 0b100) {
                        tiles = brush.tiles[48];
                    }
                    else if(upperTileIndex == 0b11 && lowerTileIndex == 0b1000) {
                        tiles = brush.tiles[49];
                    }
                    else if(upperTileIndex == 0b1 && lowerTileIndex == 0b1100) {
                        tiles = brush.tiles[43];
                    }
                    else if(upperTileIndex == 0b10 && lowerTileIndex == 0b1100) {
                        tiles = brush.tiles[42];
                    }
                    else if(upperTileIndex == 0b10 && lowerTileIndex == 0b100) {
                        tiles = brush.tiles[46];
                    }
                    else if(upperTileIndex == 0b1 && lowerTileIndex == 0b1000) {
                        tiles = brush.tiles[47];
                    }*/
                }
                /*else if (tilemapLevel + 1 == maxLevel) {
                    for (int y2 = y; y2 <= _columns; ++y2) {
                        Tile leftTile = _grid.getValue(x + neighborsOffset[3].x, y2);
                        Tile rightTile = _grid.getValue(x + neighborsOffset[2].x, y2);

                        if (leftTile.level <= tilemapLevel && rightTile.level <= tilemapLevel) {
                            tiles = brush.tiles[16];
                            break;
                        }
                        else if (rightTile.level <= tilemapLevel) {
                            tiles = brush.tiles[27];
                            break;
                        }
                        else if (leftTile.level <= tilemapLevel) {
                            tiles = brush.tiles[26];
                            break;
                        }
                    }
                }*/
                int tileId = -1;
                if (tiles.length) {
                    tileId = tiles[(x + y) % tiles.length];
                }
                if (tileId > 0) {
                    tilemap.setTile(x, y, tileId);
                }
            }
        }+/

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
            if (!_terrainMap || !_isDirty)
                return;

            _isDirty = false;

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

    final class Light {
        enum Type {
            pointLight,
        }

        bool isAlive = true;
        string name;
        Vec2i position;
        float brightness = 1f;
        float radius = 0f;
        Color color = Color.white;

        private {
            Type _type;
            Vec2f _offset = Vec2f.zero;
            Vec2f _tempMove = Vec2f.zero;
            float _zoom = 1f;
            bool _isSelected, _isTempSelected, _isHovered;
            Sprite _icon;
            Circle _circle;
        }

        @property {
            Vec2i tempPosition() const {
                return position + (cast(Vec2i) _tempMove.round());
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
                name = ffd.getNode("name").get!string(0);
            }

            if (ffd.hasNode("position")) {
                position = ffd.getNode("position").get!Vec2i(0);
            }

            if (ffd.hasNode("radius")) {
                radius = ffd.getNode("radius").get!float(0);
            }

            if (ffd.hasNode("color")) {
                color = ffd.getNode("color").get!Color(0);
            }

            if (ffd.hasNode("brightness")) {
                brightness = ffd.getNode("brightness").get!float(0);
            }
            _setup();
        }

        this(Type type_) {
            _type = type_;
            _setup();
        }

        private void _setup() {
            _circle = Circle.outline(radius, 1f);
            _icon = Atelier.res.get!Sprite("editor:scene-lighting");
        }

        void setTempMove(Vec2f move) {
            _tempMove = move;
        }

        void applyMove() {
            position += cast(Vec2i) _tempMove.round();
            _tempMove = Vec2f.zero;
        }

        void setTempSelected(bool selected) {
            _isTempSelected = selected;
        }

        bool getTempSelected() {
            return _isTempSelected;
        }

        void setSelected(bool selected) {
            _isSelected = selected;
        }

        bool getSelected() {
            return _isSelected;
        }

        bool isInside(Vec2f minPos, Vec2f maxPos) {
            Vec2f a = (cast(Vec2f) position) - radius / 2f;
            Vec2f b = (cast(Vec2f) position) + radius / 2f;

            return minPos.x < b.x && maxPos.x > a.x && minPos.y < b.y && maxPos.y > a.y;
        }

        bool checkHover(Vec2f point) {
            return point.distance(cast(Vec2f) position) < radius / 2f;
        }

        void setHover(bool hover) {
            _isHovered = hover;
        }

        void update(Vec2f offset, float zoom) {
            _offset = offset;
            _zoom = zoom;
            _circle.radius = clamp(radius * _zoom, 0f, 1024f);
            _circle.position = offset + (_tempMove + cast(Vec2f) position) * _zoom;
            _icon.position = _circle.position;
            _icon.size = (cast(Vec2f) _icon.clip.zw) * _zoom;
            _circle.color = color;
        }

        void draw() {
            bool showHitbox = _isHovered || _isSelected || _isTempSelected;
            float alpha = (_isHovered || _isTempSelected) ? 0.5f : 1f;

            _circle.alpha = alpha;
            _icon.alpha = alpha;

            _circle.filled = _isHovered;
            if (showHitbox) {
                _circle.draw();
            }
            _icon.draw();
        }

        void save(Farfadet ffd) {
            Farfadet node = ffd.addNode("light").add(to!string(_type));
            node.addNode("name").add(name);
            node.addNode("position").add(position);
            node.addNode("radius").add(radius);
            node.addNode("color").add(color);
            node.addNode("brightness").add(brightness);
        }

        UIElement createSettingsWindow() {
            return new LightSettings(this);
        }
    }

    final class Entity {
        enum Type {
            prop,
            actor,
            trigger,
            teleporter,
            note
        }

        bool isAlive = true;
        EntityData entityData;

        abstract class BuilderData {
            void save(Farfadet ffd);
            void update(float zoom);
            void draw(Vec2f offset, Vec3f hbSize, Vec2f hbOffset);
            UIElement createSettingsWindow();
        }

        final class PropBuilderData : BuilderData {
            private {
                string[] _graphics;
                string _graphic;
                float _angle = 180f;
                string _rid;
                Sprite _sprite;
                Animation _anim;
                MultiDirAnimation _mdiranim;
                Image _image;
                Vec2f _imageOffset = Vec2f.zero;
            }

            @property {
                string rid() const {
                    return _rid;
                }

                string rid(string rid_) {
                    if (_rid != rid_) {
                        _rid = rid_;
                        _graphic.length = 0;
                        reload();
                    }
                    return _rid;
                }

                string graphic() const {
                    return _graphic;
                }

                string graphic(string graphic_) {
                    if (_graphic != graphic_) {
                        _graphic = graphic_;
                        reload();
                    }
                    return _graphic;
                }

                float angle() const {
                    return _angle;
                }

                float angle(float angle_) {
                    _angle = angle_;
                    if (_mdiranim) {
                        _mdiranim.dirAngle = _angle;
                    }
                    return _angle;
                }
            }

            this(Farfadet ffd) {
                if (ffd.hasNode("graphic")) {
                    _graphic = ffd.getNode("graphic").get!string(0);
                }

                if (ffd.hasNode("angle")) {
                    _angle = ffd.getNode("angle").get!float(0);
                }

                if (ffd.hasNode("rid")) {
                    _rid = ffd.getNode("rid").get!string(0);
                }

                reload();
            }

            this() {
            }

            string[] getGraphicList() {
                return _graphics;
            }

            override void save(Farfadet ffd) {
                ffd.addNode("graphic").add(_graphic);
                ffd.addNode("angle").add(_angle);
                ffd.addNode("rid").add(_rid);
            }

            override UIElement createSettingsWindow() {
                return new PropSettings(this.outer);
            }

            void reload() {
                Farfadet ffd;
                try {
                    ffd = Atelier.etabli.getResource("prop", _rid).farfadet;
                }
                catch (Exception e) {
                    return;
                }

                if (ffd.hasNode("hitbox")) {
                    Farfadet hitboxNode = ffd.getNode("hitbox");
                    if (hitboxNode.hasNode("size")) {
                        _hitbox = hitboxNode.getNode("size").get!Vec3i(0);
                    }
                }

                _sprite = null;
                _anim = null;
                _mdiranim = null;
                _image = null;
                _imageOffset = Vec2f.zero;

                foreach (renderNode; ffd.getNodes("render")) {
                    _graphics ~= renderNode.get!string(0);

                    if (_graphic == renderNode.get!string(0) || _graphic.length == 0) {
                        _graphic = renderNode.get!string(0);
                        string renderRid, renderType;

                        if (renderNode.hasNode("type")) {
                            renderType = renderNode.getNode("type").get!string(0);
                        }
                        if (renderNode.hasNode("rid")) {
                            renderRid = renderNode.getNode("rid").get!string(0);
                        }

                        switch (renderType) {
                        case "sprite":
                            _sprite = Atelier.etabli.getSprite(renderRid);
                            _image = _sprite;
                            break;
                        case "animation":
                            _anim = Atelier.etabli.getAnimation(renderRid);
                            _image = _anim;
                            break;
                        case "multidiranimation":
                            _mdiranim = Atelier.etabli.getMultiDirAnimation(renderRid);
                            _image = _mdiranim;
                            break;
                        default:
                            break;
                        }

                        if (_mdiranim) {
                            _mdiranim.dirAngle = _angle;
                        }

                        if (_image) {
                            if (renderNode.hasNode("offset")) {
                                _imageOffset = cast(Vec2f) renderNode.getNode("offset")
                                    .get!Vec2i(0);
                            }

                            if (renderNode.hasNode("anchor")) {
                                _image.anchor = renderNode.getNode("anchor").get!Vec2f(0);
                            }

                            if (renderNode.hasNode("pivot")) {
                                _image.pivot = renderNode.getNode("pivot").get!Vec2f(0);
                            }
                        }
                    }
                }
            }

            override void update(float zoom) {
                if (_sprite) {
                    _sprite.size = (cast(Vec2f) _sprite.clip.zw) * zoom;
                }
                if (_anim) {
                    _anim.size = (cast(Vec2f) _anim.clip.zw) * zoom;
                }
                if (_mdiranim) {
                    _mdiranim.size = (cast(Vec2f) _mdiranim.clip.zw) * zoom;
                }

                if (_image) {
                    _image.position = _imageOffset * zoom;
                    _image.update();
                }
            }

            override void draw(Vec2f origin, Vec3f hitboxSize, Vec2f offset) {
                bool showHitbox = _isHovered || _isSelected || _isTempSelected;
                float hitboxAlpha = (_isHovered || _isTempSelected) ? 0.5f : 1f;
                Color hitboxColor = (_isSelected || _isTempSelected) ? Atelier.theme.danger
                    : Atelier.theme.onNeutral;

                if (showHitbox) {
                    Atelier.renderer.drawRect(origin - offset, hitboxSize.xy,
                        hitboxColor, 0.2f * hitboxAlpha, false);
                }

                if (_image) {
                    _image.draw(origin);
                }

                if (showHitbox) {
                    Atelier.renderer.drawRect(origin - (offset + Vec2f(0f,
                            hitboxSize.z)), hitboxSize.xy, Color.yellow, 0.2f * hitboxAlpha, true);

                    Atelier.renderer.drawRect(origin + Vec2f(0f,
                            hitboxSize.y) - (offset + Vec2f(0f, hitboxSize.z)),
                        hitboxSize.xz, Color.orange, 0.2f * hitboxAlpha, true);

                    Atelier.renderer.drawRect(origin - (offset + Vec2f(0f, hitboxSize.z)),
                        hitboxSize.xy, hitboxColor, hitboxAlpha, false);

                    Atelier.renderer.drawRect(origin - (offset + Vec2f(0f,
                            hitboxSize.z)), hitboxSize.xy + Vec2f(0f, hitboxSize.z),
                        hitboxColor, hitboxAlpha, false);
                }
            }
        }

        final class ActorBuilderData : BuilderData {
            private {
                string[] _graphics;
                string _graphic;
                float _angle = 180f;
                string _rid;
                Sprite _sprite;
                Animation _anim;
                MultiDirAnimation _mdiranim;
                Image _image;
                Vec2f _imageOffset = Vec2f.zero;
            }

            @property {
                string rid() const {
                    return _rid;
                }

                string rid(string rid_) {
                    if (_rid != rid_) {
                        _rid = rid_;
                        _graphic.length = 0;
                        reload();
                    }
                    return _rid;
                }

                string graphic() const {
                    return _graphic;
                }

                string graphic(string graphic_) {
                    if (_graphic != graphic_) {
                        _graphic = graphic_;
                        reload();
                    }
                    return _graphic;
                }

                float angle() const {
                    return _angle;
                }

                float angle(float angle_) {
                    _angle = angle_;
                    if (_mdiranim) {
                        _mdiranim.dirAngle = _angle;
                    }
                    return _angle;
                }
            }

            this(Farfadet ffd) {
                if (ffd.hasNode("graphic")) {
                    _graphic = ffd.getNode("graphic").get!string(0);
                }

                if (ffd.hasNode("angle")) {
                    _angle = ffd.getNode("angle").get!float(0);
                }

                if (ffd.hasNode("rid")) {
                    _rid = ffd.getNode("rid").get!string(0);
                }

                reload();
            }

            this() {
            }

            string[] getGraphicList() {
                return _graphics;
            }

            override void save(Farfadet ffd) {
                ffd.addNode("graphic").add(_graphic);
                ffd.addNode("angle").add(_angle);
                ffd.addNode("rid").add(_rid);
            }

            override UIElement createSettingsWindow() {
                return new ActorSettings(this.outer);
            }

            void reload() {
                Farfadet ffd;
                try {
                    ffd = Atelier.etabli.getResource("actor", _rid).farfadet;
                }
                catch (Exception e) {
                    return;
                }

                if (ffd.hasNode("hitbox")) {
                    Farfadet hitboxNode = ffd.getNode("hitbox");
                    if (hitboxNode.hasNode("size")) {
                        _hitbox = hitboxNode.getNode("size").get!Vec3i(0);
                    }
                }

                _sprite = null;
                _anim = null;
                _mdiranim = null;
                _image = null;
                _imageOffset = Vec2f.zero;

                foreach (renderNode; ffd.getNodes("render")) {
                    _graphics ~= renderNode.get!string(0);

                    if (_graphic == renderNode.get!string(0) || _graphic.length == 0) {
                        _graphic = renderNode.get!string(0);
                        string renderRid, renderType;

                        if (renderNode.hasNode("type")) {
                            renderType = renderNode.getNode("type").get!string(0);
                        }
                        if (renderNode.hasNode("rid")) {
                            renderRid = renderNode.getNode("rid").get!string(0);
                        }

                        switch (renderType) {
                        case "sprite":
                            _sprite = Atelier.etabli.getSprite(renderRid);
                            _image = _sprite;
                            break;
                        case "animation":
                            _anim = Atelier.etabli.getAnimation(renderRid);
                            _image = _anim;
                            break;
                        case "multidiranimation":
                            _mdiranim = Atelier.etabli.getMultiDirAnimation(renderRid);
                            _image = _mdiranim;
                            break;
                        default:
                            break;
                        }

                        if (_mdiranim) {
                            _mdiranim.dirAngle = _angle;
                        }

                        if (_image) {
                            if (renderNode.hasNode("offset")) {
                                _imageOffset = cast(Vec2f) renderNode.getNode("offset")
                                    .get!Vec2i(0);
                            }

                            if (renderNode.hasNode("anchor")) {
                                _image.anchor = renderNode.getNode("anchor").get!Vec2f(0);
                            }

                            if (renderNode.hasNode("pivot")) {
                                _image.pivot = renderNode.getNode("pivot").get!Vec2f(0);
                            }
                        }
                    }
                }
            }

            override void update(float zoom) {
                if (_sprite) {
                    _sprite.size = (cast(Vec2f) _sprite.clip.zw) * zoom;
                }
                if (_anim) {
                    _anim.size = (cast(Vec2f) _anim.clip.zw) * zoom;
                }
                if (_mdiranim) {
                    _mdiranim.size = (cast(Vec2f) _mdiranim.clip.zw) * zoom;
                }

                if (_image) {
                    _image.position = _imageOffset * zoom;
                    _image.update();
                }
            }

            override void draw(Vec2f origin, Vec3f hitboxSize, Vec2f offset) {
                bool showHitbox = _isHovered || _isSelected || _isTempSelected;
                float hitboxAlpha = (_isHovered || _isTempSelected) ? 0.5f : 1f;
                Color hitboxColor = (_isSelected || _isTempSelected) ? Atelier.theme.danger
                    : Atelier.theme.onNeutral;

                if (showHitbox) {
                    Atelier.renderer.drawRect(origin - offset, hitboxSize.xy,
                        hitboxColor, 0.2f * hitboxAlpha, false);
                }

                if (_image) {
                    _image.draw(origin);
                }

                if (showHitbox) {
                    Atelier.renderer.drawRect(origin - (offset + Vec2f(0f,
                            hitboxSize.z)), hitboxSize.xy, Color.yellow, 0.2f * hitboxAlpha, true);

                    Atelier.renderer.drawRect(origin + Vec2f(0f,
                            hitboxSize.y) - (offset + Vec2f(0f, hitboxSize.z)),
                        hitboxSize.xz, Color.orange, 0.2f * hitboxAlpha, true);

                    Atelier.renderer.drawRect(origin - (offset + Vec2f(0f, hitboxSize.z)),
                        hitboxSize.xy, hitboxColor, hitboxAlpha, false);

                    Atelier.renderer.drawRect(origin - (offset + Vec2f(0f,
                            hitboxSize.z)), hitboxSize.xy + Vec2f(0f, hitboxSize.z),
                        hitboxColor, hitboxAlpha, false);
                }
            }
        }

        final class TriggerBuilderData : BuilderData {
            private {
                string _event;
            }

            @property {
                string event() const {
                    return _event;
                }

                string event(string event_) {
                    return _event = event_;
                }

                Vec3i hitbox() const {
                    return _hitbox;
                }

                Vec3i hitbox(Vec3i hitbox_) {
                    return _hitbox = hitbox_;
                }
            }

            this(Farfadet ffd) {
                if (ffd.hasNode("event")) {
                    _event = ffd.getNode("event").get!string(0);
                }

                _hitbox = Vec3i(16, 16, 16);
                if (ffd.hasNode("hitbox")) {
                    _hitbox = ffd.getNode("hitbox").get!Vec3i(0);
                }
            }

            this() {
                _hitbox = Vec3i(16, 16, 16);
            }

            override void save(Farfadet ffd) {
                ffd.addNode("event").add(_event);
                ffd.addNode("hitbox").add(_hitbox);
            }

            override UIElement createSettingsWindow() {
                return new TriggerSettings(this.outer);
            }

            override void update(float zoom) {
            }

            override void draw(Vec2f origin, Vec3f hitboxSize, Vec2f offset) {
                float hitboxAlpha = (_isHovered || _isTempSelected) ? 0.5f : 1f;
                Color hitboxColor = (_isSelected || _isTempSelected) ? Atelier.theme.danger
                    : Atelier.theme.onNeutral;

                Atelier.renderer.drawRect(origin - offset, hitboxSize.xy,
                    hitboxColor, 0.2f * hitboxAlpha, false);

                Atelier.renderer.drawRect(origin - (offset + Vec2f(0f,
                        hitboxSize.z)), hitboxSize.xy, Color.cyan, 0.2f * hitboxAlpha, true);

                Atelier.renderer.drawRect(origin + Vec2f(0f,
                        hitboxSize.y) - (offset + Vec2f(0f, hitboxSize.z)),
                    hitboxSize.xz, Color.blue, 0.2f * hitboxAlpha, true);

                Atelier.renderer.drawRect(origin - (offset + Vec2f(0f, hitboxSize.z)),
                    hitboxSize.xy, hitboxColor, hitboxAlpha, false);

                Atelier.renderer.drawRect(origin - (offset + Vec2f(0f,
                        hitboxSize.z)), hitboxSize.xy + Vec2f(0f, hitboxSize.z),
                    hitboxColor, hitboxAlpha, false);
            }
        }

        final class TeleporterBuilderData : BuilderData {
            private {
                string _scene, _target;
                uint _direction;
            }

            @property {
                string scene() const {
                    return _scene;
                }

                string scene(string scene_) {
                    return _scene = scene_;
                }

                string target() const {
                    return _target;
                }

                string target(string target_) {
                    return _target = target_;
                }

                uint direction() const {
                    return _direction;
                }

                uint direction(uint direction_) {
                    return _direction = direction_;
                }

                Vec3i hitbox() const {
                    return _hitbox;
                }

                Vec3i hitbox(Vec3i hitbox_) {
                    return _hitbox = hitbox_;
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

                _hitbox = Vec3i(16, 16, 16);
                if (ffd.hasNode("hitbox")) {
                    _hitbox = ffd.getNode("hitbox").get!Vec3i(0);
                }
            }

            this() {
                _hitbox = Vec3i(16, 16, 16);
            }

            override void save(Farfadet ffd) {
                ffd.addNode("scene").add(_scene);
                ffd.addNode("target").add(_target);
                ffd.addNode("direction").add(_direction);
                ffd.addNode("hitbox").add(_hitbox);
            }

            override UIElement createSettingsWindow() {
                return new TeleporterSettings(this.outer);
            }

            override void update(float zoom) {
            }

            override void draw(Vec2f origin, Vec3f hitboxSize, Vec2f offset) {
                float hitboxAlpha = (_isHovered || _isTempSelected) ? 0.5f : 1f;
                Color hitboxColor = (_isSelected || _isTempSelected) ? Atelier.theme.danger
                    : Atelier.theme.onNeutral;

                Atelier.renderer.drawRect(origin - offset, hitboxSize.xy,
                    hitboxColor, 0.2f * hitboxAlpha, false);

                Atelier.renderer.drawRect(origin - (offset + Vec2f(0f,
                        hitboxSize.z)), hitboxSize.xy, Color.cyan, 0.2f * hitboxAlpha, true);

                Atelier.renderer.drawRect(origin + Vec2f(0f,
                        hitboxSize.y) - (offset + Vec2f(0f, hitboxSize.z)),
                    hitboxSize.xz, Color.blue, 0.2f * hitboxAlpha, true);

                Atelier.renderer.drawRect(origin - (offset + Vec2f(0f, hitboxSize.z)),
                    hitboxSize.xy, hitboxColor, hitboxAlpha, false);

                Atelier.renderer.drawRect(origin - (offset + Vec2f(0f,
                        hitboxSize.z)), hitboxSize.xy + Vec2f(0f, hitboxSize.z),
                    hitboxColor, hitboxAlpha, false);
            }
        }

        final class NoteBuilderData : BuilderData {
            @property {
                Vec2i size() const {
                    return _hitbox.xy;
                }

                Vec2i size(Vec2i size_) {
                    _hitbox.xy = size_;
                    return _hitbox.xy;
                }
            }

            this(Farfadet ffd) {
                _hitbox = Vec3i(16, 16, 0);
                if (ffd.hasNode("size")) {
                    _hitbox = Vec3i(ffd.getNode("size").get!Vec2i(0), 0);
                }
            }

            this() {
                _hitbox = Vec3i(16, 16, 0);
            }

            override void save(Farfadet ffd) {
                ffd.addNode("size").add(_hitbox.xy);
            }

            override UIElement createSettingsWindow() {
                return new NoteSettings(this.outer);
            }

            override void update(float zoom) {
            }

            override void draw(Vec2f origin, Vec3f hitboxSize, Vec2f offset) {
                float hitboxAlpha = (_isHovered || _isTempSelected) ? 0.5f : 1f;
                Color hitboxColor = (_isSelected || _isTempSelected) ? Atelier.theme.danger
                    : Atelier.theme.onNeutral;

                Atelier.renderer.drawRect(origin - offset, hitboxSize.xy,
                    hitboxColor, 0.2f * hitboxAlpha, false);

                Atelier.renderer.drawRect(origin - offset, hitboxSize.xy, Color.green, 0.2f * hitboxAlpha, true);

                drawText((origin - offset) + Vec2f(1f, hitboxSize.y - 1f), to!dstring(name),
                    Atelier.theme.font, Atelier.theme.onNeutral);
            }
        }

        @property {
            int level() {
                return entityData.position.z / 16;
            }

            Vec3i hitbox() {
                return _hitbox;
            }

            PropBuilderData prop() {
                enforce(_type == Type.prop, "Type d’entité invalide");
                return _prop;
            }

            ActorBuilderData actor() {
                enforce(_type == Type.actor, "Type d’entité invalide");
                return _actor;
            }

            TriggerBuilderData trigger() {
                enforce(_type == Type.trigger, "Type d’entité invalide");
                return _trigger;
            }

            TeleporterBuilderData teleporter() {
                enforce(_type == Type.teleporter, "Type d’entité invalide");
                return _teleporter;
            }

            NoteBuilderData note() {
                enforce(_type == Type.note, "Type d’entité invalide");
                return _note;
            }

            Vec3i tempPosition() const {
                return entityData.position + (cast(Vec3i) _tempMove.round());
            }

            int yOrder() const {
                return entityData.position.y + (cast(int) round(_tempMove.y)) + (
                    _hitbox.y - (_hitbox.y / 2));
            }
        }

        private {
            Vec3i _hitbox;
            Type _type;
            union {
                PropBuilderData _prop;
                ActorBuilderData _actor;
                TriggerBuilderData _trigger;
                TeleporterBuilderData _teleporter;
                NoteBuilderData _note;
            }

            BuilderData _data;
        }

        this(Farfadet ffd) {
            _type = asEnum!Type(ffd.get!string(0), Type.prop);

            entityData.load(ffd);

            final switch (_type) with (Type) {
            case prop:
                _prop = new PropBuilderData(ffd);
                _data = _prop;
                break;
            case actor:
                _actor = new ActorBuilderData(ffd);
                _data = _actor;
                break;
            case trigger:
                _trigger = new TriggerBuilderData(ffd);
                _data = _trigger;
                break;
            case teleporter:
                _teleporter = new TeleporterBuilderData(ffd);
                _data = _teleporter;
                break;
            case note:
                _note = new NoteBuilderData(ffd);
                _data = _note;
                break;
            }
        }

        this(Type type_) {
            _type = type_;
            final switch (_type) with (Type) {
            case prop:
                _prop = new PropBuilderData;
                _data = _prop;
                break;
            case actor:
                _actor = new ActorBuilderData;
                _data = _actor;
                break;
            case trigger:
                _trigger = new TriggerBuilderData;
                _data = _trigger;
                break;
            case teleporter:
                _teleporter = new TeleporterBuilderData;
                _data = _teleporter;
                break;
            case note:
                _note = new NoteBuilderData;
                _data = _note;
                break;
            }
        }

        void save(Farfadet ffd) {
            Farfadet node = ffd.addNode("entity").add(to!string(_type));
            entityData.save(node);
            _data.save(node);
        }

        UIElement createSettingsWindow() {
            return _data.createSettingsWindow();
        }

        private {
            Vec2f _offset = Vec2f.zero;
            Vec3f _tempMove = Vec3f.zero;
            float _zoom = 1f;
            bool _isSelected, _isTempSelected, _isHovered;
        }

        void setTempMove(Vec3f move) {
            _tempMove = move;
        }

        void applyMove() {
            entityData.position += cast(Vec3i) _tempMove.round();
            _tempMove = Vec3f.zero;
        }

        void setTempSelected(bool selected) {
            _isTempSelected = selected;
        }

        bool getTempSelected() {
            return _isTempSelected;
        }

        void setSelected(bool selected) {
            _isSelected = selected;
        }

        bool getSelected() {
            return _isSelected;
        }

        bool isInside(Vec2f minPos, Vec2f maxPos) {
            Vec2f a = Vec2f(entityData.position.x - _hitbox.x / 2f,
                entityData.position.y - (entityData.position.z + _hitbox.y / 2f + _hitbox.z));

            Vec2f b = Vec2f(entityData.position.x + _hitbox.x / 2f, entityData.position.y + _hitbox.y / 2f);

            return minPos.x < b.x && maxPos.x > a.x && minPos.y < b.y && maxPos.y > a.y;
        }

        bool checkHover(Vec2f pos) {
            return pos.isBetween(Vec2f(entityData.position.x - _hitbox.x / 2f,
                    entityData.position.y - (entityData.position.z + _hitbox.y / 2f + _hitbox.z)),
                Vec2f(entityData.position.x + _hitbox.x / 2f, entityData.position.y + _hitbox.y / 2f));
        }

        void setHover(bool hover) {
            _isHovered = hover;
        }

        void update(Vec2f offset, float zoom) {
            _offset = offset;
            _zoom = zoom;

            _data.update(_zoom);
        }

        void draw() {
            Vec3f hitboxSize = (cast(Vec3f) _hitbox) * _zoom;
            Vec2f offset = (cast(Vec2f)(_hitbox.xy - (_hitbox.xy >> 1))) * _zoom;
            Vec2f origin = _offset + Vec2f(entityData.position.x + _tempMove.x,
                entityData.position.y + _tempMove.y - (entityData.position.z + _tempMove.z)) * _zoom;

            _data.draw(origin, hitboxSize, offset);
        }
    }

    private {
        TerrainLayer[] _terrainlayers;
        ParallaxLayer[] _parallaxLayers;
        CollisionLayer[] _collisionLayers;
        TopologicMap _tolopogicMap;
        uint _columns, _lines;
        int _levels;
        Array!Entity _entities;
        Array!Light _lights;
    }

    string name;
    uint mainLevel;
    float brightness = 1f;
    string weatherType = "none";
    float weatherValue = 1f;

    @property {
        TopologicMap topologicMap() {
            return _tolopogicMap;
        }

        int levels() {
            return _levels;
        }

        int levels(int levels_) {
            _levels = levels_;
            _tolopogicMap.updateLevels();
            return _levels;
        }
    }

    this() {
        _tolopogicMap = new TopologicMap;
        _entities = new Array!Entity;
        _lights = new Array!Light;
    }

    void setSize(uint width_, uint height_) {
        _columns = width_;
        _lines = height_;

        foreach (layer; _terrainlayers) {
            layer.tilemap.setDimensions(_columns, _lines);
        }
        foreach (layer; _collisionLayers) {
            layer.tilemap.setDimensions(_columns, _lines);
        }
        _tolopogicMap.setDimensions(_columns, _lines);
    }

    uint getWidth() const {
        return _columns;
    }

    uint getHeight() const {
        return _lines;
    }

    void load(Farfadet ffd) {
        name = ffd.get!string(0);

        if (ffd.hasNode("size")) {
            Farfadet node = ffd.getNode("size");
            _columns = node.get!uint(0);
            _lines = node.get!uint(1);
            _tolopogicMap.setDimensions(_columns, _lines);
        }

        if (ffd.hasNode("levels")) {
            _levels = ffd.getNode("levels").get!(int)(0);
            _tolopogicMap.updateLevels();
        }

        if (ffd.hasNode("mainLevel")) {
            mainLevel = ffd.getNode("mainLevel").get!(uint)(0);
        }

        if (ffd.hasNode("brightness")) {
            brightness = ffd.getNode("brightness").get!(float)(0);
        }

        if (ffd.hasNode("weather")) {
            weatherType = ffd.getNode("weather").get!(string)(0);
            weatherValue = ffd.getNode("weather").get!(float)(1);
        }

        _tolopogicMap.load(ffd);

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

        foreach (entityNode; ffd.getNodes("entity")) {
            Entity entity = new Entity(entityNode);
            _entities ~= entity;
        }

        foreach (lightNode; ffd.getNodes("light")) {
            Light light = new Light(lightNode);
            _lights ~= light;
        }
    }

    Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("scene");
        node.add(name);
        node.addNode("size").add(_columns).add(_lines);
        node.addNode("levels").add(_levels);
        node.addNode("mainLevel").add(mainLevel);
        node.addNode("brightness").add(brightness);
        node.addNode("weather").add(weatherType).add(weatherValue);

        _tolopogicMap.save(node);

        foreach (layer; _terrainlayers) {
            layer.save(node);
        }

        foreach (layer; _parallaxLayers) {
            layer.save(node);
        }

        foreach (layer; _collisionLayers) {
            layer.save(node);
        }

        foreach (entity; _entities) {
            entity.save(node);
        }

        foreach (light; _lights) {
            light.save(node);
        }

        return node;
    }

    TerrainLayer createTerrainLayer() {
        TerrainLayer layer = new TerrainLayer(_columns, _lines);
        _terrainlayers ~= layer;
        return layer;
    }

    TerrainLayer duplicateTerrainLayer(TerrainLayer other) {
        TerrainLayer layer = new TerrainLayer(other);
        _terrainlayers ~= layer;
        return layer;
    }

    TerrainLayer[] getTerrainLayers() {
        return _terrainlayers;
    }

    ParallaxLayer createParallaxLayer() {
        ParallaxLayer layer = new ParallaxLayer(_columns, _lines);
        _parallaxLayers ~= layer;
        return layer;
    }

    ParallaxLayer duplicateParallaxLayer(ParallaxLayer other) {
        ParallaxLayer layer = new ParallaxLayer(other);
        _parallaxLayers ~= layer;
        return layer;
    }

    ParallaxLayer[] getParallaxLayers() {
        return _parallaxLayers;
    }

    CollisionLayer createCollisionLayer() {
        CollisionLayer layer = new CollisionLayer(_columns, _lines);
        _collisionLayers ~= layer;
        return layer;
    }

    CollisionLayer duplicateCollisionLayer(CollisionLayer other) {
        CollisionLayer layer = new CollisionLayer(other);
        _collisionLayers ~= layer;
        return layer;
    }

    CollisionLayer[] getCollisionLayers() {
        return _collisionLayers;
    }

    Array!Light getLights() {
        return _lights;
    }

    Light createLight(string type) {
        Light.Type type_;
        try {
            type_ = to!(Light.Type)(type);
        }
        catch (Exception e) {
            Atelier.log(e.msg);
        }
        Light light = new Light(type_);
        _lights ~= light;
        return light;
    }

    Array!Entity getEntities() {
        return _entities;
    }

    Entity createEntity(string type) {
        Entity.Type type_;
        try {
            type_ = to!(Entity.Type)(type);
        }
        catch (Exception e) {
            Atelier.log(e.msg);
        }
        Entity entity = new Entity(type_);
        _entities ~= entity;
        return entity;
    }

    int getLevels() const {
        return _levels;
    }

    int getLevel(int level) const {
        if (level >= _levels)
            return 0;
        return level * 16;
    }
}
