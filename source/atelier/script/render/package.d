/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.render;

import grimoire;

import atelier.script.render.animation;
import atelier.script.render.capsule;
import atelier.script.render.circle;
import atelier.script.render.image;
import atelier.script.render.ninepatch;
import atelier.script.render.rectangle;
import atelier.script.render.sprite;
import atelier.script.render.roundedrectangle;
import atelier.script.render.texture;
import atelier.script.render.tilemap;
import atelier.script.render.tileset;

package(atelier.script) GrLibLoader[] getLibLoaders_render() {
    return [
        &loadLibRender_animation, &loadLibRender_capsule, &loadLibRender_circle,
        &loadLibRender_image, &loadLibRender_ninepatch,
        &loadLibRender_rectangle, &loadLibRender_roundedRectangle,
        &loadLibRender_sprite, &loadLibRender_texture,
        &loadLibRender_tilemap, &loadLibRender_tileset

    ];
}
