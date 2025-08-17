module atelier.script.render;

import grimoire;

import atelier.script.render.animation;
import atelier.script.render.canvas;
import atelier.script.render.capsule;
import atelier.script.render.circle;
import atelier.script.render.font;
import atelier.script.render.image;
import atelier.script.render.imagedata;
import atelier.script.render.ninepatch;
import atelier.script.render.rectangle;
import atelier.script.render.sprite;
import atelier.script.render.roundedrectangle;
import atelier.script.render.texture;
import atelier.script.render.tilemap;
import atelier.script.render.tileset;
import atelier.script.render.writabletexture;

package(atelier.script) GrModuleLoader[] getLibLoaders_render() {
    return [
        &loadLibRender_animation, &loadLibRender_canvas, &loadLibRender_capsule,
        &loadLibRender_circle, &loadLibRender_font, &loadLibRender_image,
        &loadLibRender_imageData, &loadLibRender_ninepatch,
        &loadLibRender_rectangle, &loadLibRender_roundedRectangle,
        &loadLibRender_sprite, &loadLibRender_texture, &loadLibRender_tilemap,
        &loadLibRender_tileset, &loadLibRender_writableTexture

    ];
}
