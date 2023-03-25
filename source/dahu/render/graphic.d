/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.render.graphic;

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

    Vec2f anchor = Vec2f.zero;

    Vec2f pivot = Vec2f.zero;

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
        anchor = drawable.anchor;
        pivot = drawable.pivot;
        blend = drawable.blend;
        color = drawable.color;
        alpha = drawable.alpha;
    }
}
