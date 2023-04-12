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
    float sizeX = 0f, sizeY = 0f;

    @property {
        pragma(inline) uint width() const {
            return cast(uint) sizeX;
        }

        pragma(inline) uint height() const {
            return cast(uint) sizeY;
        }
    }

    bool filled = true;

    this() {
    }

    this(Rectangle rect) {
        super(rect);
        sizeX = rect.sizeX;
        sizeY = rect.sizeY;
        filled = rect.filled;
    }

    void update() {
    }

    void draw(float x, float y) {
        app.renderer.drawRect(x, y, sizeX, sizeY, color, alpha, filled);
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
