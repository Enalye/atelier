/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.render.image;

import std.conv : to;

import atelier.common;
import atelier.render.util;

abstract class Image {
    Vec4u clip;

    Vec2f position = Vec2f.zero;

    double angle = 0.0;

    bool flipX, flipY;

    Vec2f anchor = Vec2f.half;

    Vec2f pivot = Vec2f.half;

    Blend blend = Blend.alpha;

    Color color = Color.white;

    float alpha = 1f;

    int zOrder;

    bool isVisible = true;

    private bool _isAlive = true;

    @property {
        bool isAlive() const {
            return _isAlive;
        }
    }

    this() {
    }

    this(Image image) {
        position = image.position;
        clip = image.clip;
        angle = image.angle;
        flipX = image.flipX;
        flipY = image.flipY;
        anchor = image.anchor;
        pivot = image.pivot;
        blend = image.blend;
        color = image.color;
        alpha = image.alpha;
    }

    void remove() {
        _isAlive = false;
    }

    /// Redimensionne l’image pour qu’elle puisse tenir dans une taille donnée
    abstract void fit(Vec2f size_);

    /// Redimensionne l’image pour qu’elle puisse contenir une taille donnée
    abstract void contain(Vec2f size_);

    abstract void update();

    abstract void draw(Vec2f origin = Vec2f.zero);
}
