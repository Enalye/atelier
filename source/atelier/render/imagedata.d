/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.render.imagedata;

import atelier.common;
import atelier.render.util;

abstract class ImageData {
    @property {
        pragma(inline) uint width() const;

        pragma(inline) uint height() const;

        Blend blend() const;
        Blend blend(Blend blend_);
        Color color() const;
        Color color(Color color_);
        float alpha() const;
        float alpha(float alpha_);
    }

    /// Dessine une section de l’image à cette position
    void draw(Vec2f position = Vec2f.zero, Vec2f size, Vec4i clip, double angle,
        Vec2f pivot = Vec2f.zero, bool flipX = false, bool flipY = false);
}
