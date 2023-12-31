/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.render.tileset;

import std.conv : to;
import std.exception : enforce;
import std.algorithm : max;

import bindbc.sdl;

import dahu.common;

import dahu.render.image;
import dahu.render.sprite;
import dahu.render.texture;
import dahu.render.util;

/// Jeu de tuiles
final class Tileset : Image, Resource!Tileset {
    private {
        Texture _texture;
    }

    float sizeX = 0f, sizeY = 0f;
    int columns, lines, maxCount;
    int marginX, marginY;

    @property {
        pragma(inline) uint width() const {
            return _texture.width;
        }

        pragma(inline) uint height() const {
            return _texture.height;
        }
    }

    /// Ctor
    this(Texture texture, Vec4i clip_, uint columns_, uint lines_, uint maxCount_ = 0) {
        _texture = texture;
        clip = clip_;
        sizeX = clip_.z;
        sizeY = clip_.w;
        columns = columns_;
        lines = lines_;
        maxCount = maxCount_;
    }

    /// Copie
    this(Tileset tileset) {
        super(tileset);
        _texture = tileset._texture;
        sizeX = tileset.sizeX;
        sizeY = tileset.sizeY;
        columns = tileset.columns;
        lines = tileset.lines;
        maxCount = tileset.maxCount;
        marginX = tileset.marginX;
        marginY = tileset.marginY;
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
        Vec4i imageClip = Vec4i(clip.x + coord.x * (clip.z + marginX),
            clip.y + coord.y * (clip.w + marginY), clip.z, clip.w);

        Sprite image = new Sprite(_texture);
        image.clip = imageClip;
        image.blend = blend;
        image.color = color;
        image.alpha = alpha;
        image.anchorX = anchorX;
        image.anchorY = anchorY;
        image.pivotX = pivotX;
        image.pivotY = pivotY;
        image.angle = angle;
        image.sizeX = sizeX;
        image.sizeY = sizeY;
        return image;
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
    void draw(int id, float x, float y) {
        columns = max(columns, 1);
        lines = max(lines, 1);
        uint count = maxCount > 0 ? maxCount : columns * lines;

        if (id >= count)
            id = count - 1;

        if (id < 0)
            id = 0;

        Vec2i coord = Vec2i(id % columns, id / columns);
        enforce(coord.y <= lines, "tileset id out of bounds");

        Vec4i currentClip = Vec4i(clip.x + coord.x * (clip.z + marginX),
            clip.y + coord.y * (clip.w + marginY), clip.z, clip.w);

        _texture.color = color;
        _texture.blend = blend;
        _texture.alpha = alpha;
        _texture.draw(x, y, sizeX, sizeY, currentClip, angle, 0f, 0f);
    }

    /// Redimensionne l’image pour qu’elle puisse tenir dans une taille donnée
    override void fit(float x, float y) {
        Vec2f size = to!Vec2f(clip.zw).fit(Vec2f(x, y));
        sizeX = size.x;
        sizeY = size.y;
    }

    /// Redimensionne l’image pour qu’elle puisse contenir une taille donnée
    override void contain(float x, float y) {
        Vec2f size = to!Vec2f(clip.zw).contain(Vec2f(x, y));
        sizeX = size.x;
        sizeY = size.y;
    }
}
