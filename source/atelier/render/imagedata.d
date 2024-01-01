/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.render.imagedata;

import atelier.common;

abstract class ImageData {
    /// Dessine une section de l’image à cette position
    void draw(Vec2f position = Vec2f.zero, Vec2f size, Vec4i clip, double angle,
        Vec2f pivot = Vec2f.zero, bool flipX = false, bool flipY = false);
}
