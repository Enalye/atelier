/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.render.tilemap;

import std.conv : to;

import atelier.common;
import atelier.render.image;
import atelier.render.tileset;

final class Tilemap : Image {
    private {
        Tileset _tileset;
        uint _currentTick;
        short[] _tiles;
        int _width, _height;
    }

    Vec2f size = Vec2f.zero;

    this(Tileset tileset, int width, int height) {
        _tileset = tileset;
        _width = width;
        _height = height;
        clip = _tileset.clip;
        size = cast(Vec2f) clip.zw;

        _tiles.length = _width * _height;
        foreach (ref short tile; _tiles) {
            tile = -1;
        }
    }

    this(Tilemap tilemap) {
        super(tilemap);
        _tileset = tilemap._tileset;
        _width = tilemap._width;
        _height = tilemap._height;
        _tiles = tilemap._tiles;
        size = tilemap.size;
    }

    void setTile(int x, int y, int tile) {
        if (x < 0 || y < 0 || x >= _width || y >= _height)
            return;

        _tiles[x + y * _width] = cast(short) tile;
    }

    /// Redimensionne l’image pour qu’elle puisse tenir dans une taille donnée
    override void fit(Vec2f size_) {
        size = to!Vec2f(clip.zw).fit(size_);
    }

    /// Redimensionne l’image pour qu’elle puisse contenir une taille donnée
    override void contain(Vec2f size_) {
        size = to!Vec2f(clip.zw).contain(size_);
    }

    override void update() {
        _currentTick++;
        if (_currentTick >= _tileset.frameTime) {
            _currentTick = 0;
            foreach (ref tile; _tiles) {
                tile = _tileset.getTileFrame(tile);
            }
        }
    }

    override void draw(Vec2f origin) {
        _tileset.color = color;
        _tileset.alpha = alpha;
        _tileset.blend = blend;

        Vec2f startPos = origin + position - (size * anchor);
        Vec2f tilePos;

        uint column, line;
        foreach (tile; _tiles) {
            tilePos = startPos;
            tilePos.x += column * size.x;
            tilePos.y += line * size.y;

            if (tile >= 0)
                _tileset.draw(tile, tilePos, size, angle);

            if ((column + 1) == _width) {
                column = 0;
                line++;
            }
            else {
                column++;
            }
        }
    }
}
