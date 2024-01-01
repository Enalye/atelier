/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.render.sprite;

import std.conv : to;

import dahu.common;
import dahu.core;

import dahu.render.image;
import dahu.render.texture;
import dahu.render.util;

final class Sprite : Image, Resource!Sprite {
    private {
        Texture _texture;
    }

    Vec2f size = Vec2f.zero;

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
        size = Vec2f(_texture.width, _texture.height);
    }

    this(Sprite sprite) {
        super(sprite);
        _texture = sprite._texture;
        size = sprite.size;
    }

    /// Accès à la ressource
    Sprite fetch() {
        return new Sprite(this);
    }

    override void update() {
    }

    /// Redimensionne l’image pour qu’elle puisse tenir dans une taille donnée
    override void fit(Vec2f size_) {
        size = to!Vec2f(clip.zw).fit(size_);
    }

    /// Redimensionne l’image pour qu’elle puisse contenir une taille donnée
    override void contain(Vec2f size_) {
        size = to!Vec2f(clip.zw).contain(size_);
    }

    override void draw(Vec2f origin) {
        _texture.color = color;
        _texture.blend = blend;
        _texture.alpha = alpha;
        _texture.draw(origin + position, size, clip, angle, pivot, flipX, flipY);
    }
}
