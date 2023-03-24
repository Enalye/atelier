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
import dahu.render.texture;
import dahu.render.util;

/// Series of aligned tiles.
final class Tileset {
    private {
        Texture _texture;
    }

    @property {
        pragma(inline) uint width() const {
            return _texture.width;
        }

        pragma(inline) uint height() const {
            return _texture.height;
        }
    }

    float sizeX = 0f, sizeY = 0f;

    Vec4i clip;

    double angle = 0.0;

    bool flipX, flipY;

    Vec2f anchor = Vec2f.zero;

    Vec2f pivot = Vec2f.zero;

    Blend blend = Blend.alpha;

    Color color = Color.white;

    float alpha = 1f;

    int columns, lines, maxCount;
    int marginX, marginY;

    /// Ctor
    this(string name, Vec4i clip_, uint columns_, uint lines_, uint maxCount_ = 0) {
        _texture = fetchPrototype!Texture(name);
        clip = clip_;
        sizeX = clip_.z;
        sizeY = clip_.w;
        columns = columns_;
        lines = lines_;
        maxCount = maxCount_;
    }

    /// Copie
    this(Tileset tileset) {
        _texture = tileset._texture;
        sizeX = tileset.sizeX;
        sizeY = tileset.sizeY;
        clip = tileset.clip;
        angle = tileset.angle;
        flipX = tileset.flipX;
        flipY = tileset.flipY;
        anchor = tileset.anchor;
        pivot = tileset.pivot;
        blend = tileset.blend;
        color = tileset.color;
        alpha = tileset.alpha;
        clip = tileset.clip;
        columns = tileset.columns;
        lines = tileset.lines;
        maxCount = tileset.maxCount;
        marginX = tileset.marginX;
        marginY = tileset.marginY;
    }

    /// Récupère une image correspondant à la tuile
    Image getImage(int id) {
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

        Image image = new Image(_texture);
        image.clip = imageClip;
        image.blend = blend;
        image.color = color;
        image.alpha = alpha;
        image.anchor = anchor;
        image.angle = angle;
        image.sizeX = sizeX;
        image.sizeY = sizeY;
        return image;
    }

    /// Retourne toutes les tuiles en images
    Image[] asSprites() {
        columns = max(columns, 1);
        lines = max(lines, 1);
        uint count = maxCount > 0 ? maxCount : columns * lines;

        Image[] images;
        foreach (id; 0 .. count)
            images ~= getImage(id);
        return images;
    }

    /// Redimensionne l’image pour qu’elle puisse tenir dans une taille donnée
    void fit(float x, float y) {
        Vec2f size = to!Vec2f(clip.zw).fit(Vec2f(x, y));
        sizeX = size.x;
        sizeY = size.y;
    }

    /// Redimensionne l’image pour qu’elle puisse contenir une taille donnée
    void contain(float x, float y) {
        Vec2f size = to!Vec2f(clip.zw).contain(Vec2f(x, y));
        sizeX = size.x;
        sizeY = size.y;
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
        _texture.draw(x, y, sizeX, sizeY, currentClip, angle, Vec2f.zero);
    }
}
