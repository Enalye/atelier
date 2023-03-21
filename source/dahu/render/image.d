/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.render.image;

import std.conv : to;

import dahu.common;

import dahu.render.texture;

final class Image {
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

    Vec2f size = Vec2f.zero;

    Vec4i clip;

    double angle = 0f;

    bool flipX, flipY;

    Vec2f anchor = Vec2f.zero;

    Vec2f pivot = Vec2f.zero;

    Blend blend = Blend.alpha;

    Color color = Color.white;

    float alpha = 1f;

    this(string path) {
        _texture = fetchPrototype!Texture(path);
    }

    this(Texture tex) {
        _texture = tex;
    }

    this(Image img) {
        _texture = img._texture;
        size = img.size;
        clip = img.clip;
        angle = img.angle;
        flipX = img.flipX;
        flipY = img.flipY;
        anchor = img.anchor;
        pivot = img.pivot;
        blend = img.blend;
        color = img.color;
        alpha = img.alpha;
    }

    /// Set the img's size to fit inside the specified size.
    void fit(Vec2f size_) {
        size = to!Vec2f(clip.zw).fit(size_);
    }

    /// Set the img's size to contain the specified size.
    void contain(Vec2f size_) {
        size = to!Vec2f(clip.zw).contain(size_);
    }

    void draw(Vec2f pos) {
        _texture.color = color;
        _texture.blend = blend;
        _texture.alpha = alpha;
        _texture.draw(pos, size, clip, angle, pivot, flipX, flipY);
    }
}
