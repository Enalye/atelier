/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.render.imagedata;

import dahu.common;

abstract class ImageData {
    /// Dessine une section de l’image à cette position
    void draw(float x, float y, float w, float h, Vec4i clip, double angle,
        float pivotX = 0f, float pivotY = 0f, bool flipX = false, bool flipY = false);
}