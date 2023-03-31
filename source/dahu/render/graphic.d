/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.render.graphic;

import std.conv : to;

import dahu.common;
import dahu.render.util;

abstract class Graphic {
    protected {
        float _sizeX = 0f, _sizeY = 0f;
    }

    @property {
        uint width() const;
        uint height() const;

        pragma(inline) float sizeX() const {
            return _sizeX;
        }

        pragma(inline) float sizeX(float sizeX_) {
            return _sizeX = sizeX_;
        }

        pragma(inline) float sizeY() const {
            return _sizeY;
        }

        pragma(inline) float sizeY(float sizeY_) {
            return _sizeY = sizeY_;
        }
    }

    Vec4i clip;

    double angle = 0.0;

    bool flipX, flipY;

    float anchorX = 0f, anchorY = 0f;

    float pivotX = 0f, pivotY = 0f;

    Blend blend = Blend.alpha;

    Color color = Color.white;

    float alpha = 1f;

    this() {
    }

    this(Graphic drawable) {
        sizeX = drawable.sizeX;
        sizeY = drawable.sizeY;
        clip = drawable.clip;
        angle = drawable.angle;
        flipX = drawable.flipX;
        flipY = drawable.flipY;
        anchorX = drawable.anchorX;
        anchorY = drawable.anchorY;
        pivotX = drawable.pivotX;
        pivotY = drawable.pivotY;
        blend = drawable.blend;
        color = drawable.color;
        alpha = drawable.alpha;
    }

    /// Redimensionne l’image pour qu’elle puisse tenir dans une taille donnée
    final void fit(float x, float y) {
        Vec2f size = to!Vec2f(clip.zw).fit(Vec2f(x, y));
        sizeX(size.x);
        sizeY(size.y);
    }

    /// Redimensionne l’image pour qu’elle puisse contenir une taille donnée
    final void contain(float x, float y) {
        Vec2f size = to!Vec2f(clip.zw).contain(Vec2f(x, y));
        sizeX(size.x);
        sizeY(size.y);
    }
}
