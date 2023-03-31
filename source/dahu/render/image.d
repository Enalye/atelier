/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.render.image;

import std.conv : to;

import dahu.common;

import dahu.render.drawable;
import dahu.render.graphic;
import dahu.render.texture;
import dahu.render.util;

final class Image : Graphic, Drawable {
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

    void update() {
    }

    void draw(float x, float y) {
        _texture.color = color;
        _texture.blend = blend;
        _texture.alpha = alpha;
        _texture.draw(x, y, sizeX, sizeY, clip, angle, pivotX, pivotY, flipX, flipY);
    }
}
