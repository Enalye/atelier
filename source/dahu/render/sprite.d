/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.render.sprite;

import std.conv : to;

import dahu.common;
import dahu.core;

import dahu.render.drawable;
import dahu.render.image;
import dahu.render.texture;
import dahu.render.util;

final class Sprite : Image, Drawable, Resource!Sprite {
    private {
        Texture _texture;
    }

    float sizeX = 0f, sizeY = 0f;

    @property {
        pragma(inline) uint width() const {
            return _texture.width;
        }

        pragma(inline) uint height() const {
            return _texture.height;
        }
    }

    this(Texture texture) {
        this(texture, Vec4i(0, 0, _texture.width, _texture.height));
    }

    this(Texture texture, Vec4i clip_) {
        _texture = texture;
        clip = clip_;
        sizeX = _texture.width;
        sizeY = _texture.height;
    }

    this(Sprite img) {
        super(img);
        _texture = img._texture;
        sizeX = img.sizeX;
        sizeY = img.sizeY;
    }

    /// Accès à la ressource
    Sprite fetch() {
        return new Sprite(this);
    }

    void update() {
    }

    void draw(float x, float y) {
        _texture.color = color;
        _texture.blend = blend;
        _texture.alpha = alpha;
        _texture.draw(x, y, sizeX, sizeY, clip, angle, pivotX, pivotY, flipX, flipY);
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
