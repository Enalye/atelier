/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.render.drawable;

import dahu.common;
import dahu.render.util;

abstract class Drawable {
    @property {
        uint width() const;
        uint height() const;
    }

    float sizeX = 0f, sizeY = 0f;

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

    this(Drawable drawable) {
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

    void draw(float x, float y);
}
