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
        app.renderer.drawRect(x, y, sizeX, sizeY, color, alpha, filled);
    }
}
