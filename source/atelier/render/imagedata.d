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

    /// Récupère les pixels
    Grid!uint getPixels();

    /// Récupère les pixels dans une région
    Grid!uint getPixels(Vec4u clip);

    /// Dessine une section de l’image à cette position
    void draw(Vec2f position, Vec2f size, Vec4u clip, double angle,
        Vec2f pivot = Vec2f.zero, bool flipX = false, bool flipY = false);
}
