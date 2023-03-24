/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.render.image;

import std.conv : to;

import dahu.common;

import dahu.render.drawable;
import dahu.render.texture;
import dahu.render.util;

final class Image : Drawable {
    private {
        Texture _texture;
    }

    @property {
        pragma(inline) override uint width() const {
            return _texture.width;
        }

        pragma(inline) override uint height() const {
            return _texture.height;
        }
    }

    this(string name) {
        _texture = fetchPrototype!Texture(name);
        clip = Vec4i(0, 0, _texture.width, _texture.height);
        sizeX = _texture.width;
        sizeY = _texture.height;
    }

    this(Texture tex) {
        _texture = tex;
        clip = Vec4i(0, 0, _texture.width, _texture.height);
        sizeX = _texture.width;
        sizeY = _texture.height;
    }

    this(Image img) {
        super(img);
        _texture = img._texture;
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

    override void draw(float x, float y) {
        _texture.color = color;
        _texture.blend = blend;
        _texture.alpha = alpha;
        _texture.draw(x, y, sizeX, sizeY, clip, angle, pivot, flipX, flipY);
    }
}
