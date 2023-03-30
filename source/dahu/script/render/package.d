/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script.render;

import grimoire;

import dahu.script.render.graphic;
import dahu.script.render.rectangle;
import dahu.script.render.texture;

package(dahu.script) GrLibLoader[] getLibLoaders_render() {
    return [
        &loadLibRender_graphic, &loadLibRender_rectangle, &loadLibRender_texture
    ];
}
