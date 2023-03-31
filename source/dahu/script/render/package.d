/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.render;

import grimoire;

import dahu.script.render.graphic;
import dahu.script.render.image;
import dahu.script.render.ninepatch;
import dahu.script.render.rectangle;
import dahu.script.render.texture;

package(dahu.script) GrLibLoader[] getLibLoaders_render() {
    return [
        &loadLibRender_graphic, &loadLibRender_image, &loadLibRender_ninepatch,
        &loadLibRender_rectangle, &loadLibRender_texture
    ];
}
