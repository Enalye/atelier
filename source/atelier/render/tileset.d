/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.render.tileset;

import std.conv : to;
import std.exception : enforce;
import std.algorithm : max;

import bindbc.sdl;

import atelier.common;

import atelier.render.imagedata;
import atelier.render.sprite;
import atelier.render.imagedata;
import atelier.render.util;

/// Jeu de tuiles
final class Tileset : Resource!Tileset {
    private {
        ImageData _imageData;
        short[short] _tileFrames;
    }

    Vec4i clip;
    Vec2i tileSize;
    int columns, lines, maxCount;
    Vec2i margin;
    bool isIsometric;

    int frameTime;

    Color color = Color.white;
    float alpha = 1f;
    Blend blend = Blend.alpha;

    @property {
        pragma(inline) uint width() const {
            return _imageData.width;
        }

        pragma(inline) uint height() const {
            return _imageData.height;
        }
    }

    /// Ctor
    this(ImageData texture, Vec4i clip_, uint columns_, uint lines_, uint maxCount_ = 0) {
        _imageData = texture;
        clip = clip_;
        tileSize = clip.zw;
        columns = columns_;
        lines = lines_;
        maxCount = maxCount_;
    }

    /// Copie
    this(Tileset tileset) {
        _imageData = tileset._imageData;
        clip = tileset.clip;
        tileSize = tileset.tileSize;
        columns = tileset.columns;
        lines = tileset.lines;
        maxCount = tileset.maxCount;
        isIsometric = tileset.isIsometric;
        frameTime = tileset.frameTime;
        _tileFrames = tileset._tileFrames;
        margin = tileset.margin;
        color = tileset.color;
        alpha = tileset.alpha;
        blend = tileset.blend;
    }

    void setTileFrame(short previousTile, short nextTile) {
        _tileFrames[previousTile] = nextTile;
    }

    short getTileFrame(short previousTile) {
        auto p = previousTile in _tileFrames;
        return p ? *p : previousTile;
    }

    /// Récupère une image correspondant à la tuile
    Sprite getImage(int id) {
        columns = max(columns, 1);
        lines = max(lines, 1);
        uint count = maxCount > 0 ? maxCount : columns * lines;

        if (id >= count)
            id = count - 1;

        if (id < 0)
            id = 0;

        Vec2i coord = Vec2i(id % columns, id / columns);
        Vec4i imageClip = Vec4i(clip.x + coord.x * (clip.z + margin.x),
            clip.y + coord.y * (clip.w + margin.y), clip.z, clip.w);

        return new Sprite(_imageData, imageClip);
    }

    /// Accès à la ressource
    Tileset fetch() {
        return new Tileset(this);
    }

    /// Retourne toutes les tuiles en images
    Sprite[] asSprites() {
        columns = max(columns, 1);
        lines = max(lines, 1);
        uint count = maxCount > 0 ? maxCount : columns * lines;

        Sprite[] images;
        foreach (id; 0 .. count)
            images ~= getImage(id);
        return images;
    }

    /// Dessine une tuile
    void draw(int id, Vec2f position, Vec2f size, float angle = 0f) {
        columns = max(columns, 1);
        lines = max(lines, 1);
        uint count = maxCount > 0 ? maxCount : columns * lines;

        if (id >= count)
            id = count - 1;

        if (id < 0)
            id = 0;

        Vec2i coord = Vec2i(id % columns, id / columns);
        enforce(coord.y <= lines, "tileset id out of bounds");

        Vec4i currentClip = Vec4i(clip.x + coord.x * (clip.z + margin.x),
            clip.y + coord.y * (clip.w + margin.y), clip.z, clip.w);

        _imageData.color = color;
        _imageData.blend = blend;
        _imageData.alpha = alpha;
        _imageData.draw(position, size, currentClip, angle);
    }
}
