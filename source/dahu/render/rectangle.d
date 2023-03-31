/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.render.rectangle;

import std.conv : to;

import dahu.common;
import dahu.core;

import dahu.render.drawable;
import dahu.render.graphic;
import dahu.render.renderer;

final class Rectangle : Graphic, Drawable {
    @property {
        pragma(inline) override uint width() const {
            return cast(uint) _sizeX;
        }

        pragma(inline) override uint height() const {
            return cast(uint) _sizeY;
        }
    }

    bool filled = true;

    this() {
    }

    this(Rectangle rect) {
        super(rect);
        filled = rect.filled;
    }

    void update() {
    }

    void draw(float x, float y) {
        app.renderer.drawRect(x, y, sizeX, sizeY, color, alpha, filled);
    }
}
