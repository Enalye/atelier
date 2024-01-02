/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.render.tilemap;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.script.util;

void loadLibRender_tilemap(GrLibDefinition library) {
    GrType tilemapType = library.addNative("Tilemap", [], "Image");

    GrType tilesetType = grGetNativeType("Tileset");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.addConstructor(&_ctor, tilemapType, [tilesetType, grInt, grInt]);

    library.addProperty(&_size!"get", &_size!"set", "size", tilemapType, vec2fType);
    library.addProperty(&_frameTime!"get", &_frameTime!"set", "frameTime", tilemapType, grInt);

    library.addFunction(&_setTile, "setTile", [tilemapType, grInt, grInt, grInt]);
}

private void _ctor(GrCall call) {
    call.setNative(new Tilemap(call.getNative!Tileset(0), call.getInt(1), call.getInt(2)));
}

private void _size(string op)(GrCall call) {
    Tilemap tilemap = call.getNative!Tilemap(0);

    static if (op == "set") {
        tilemap.size = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(tilemap.size));
}

private void _frameTime(string op)(GrCall call) {
    Tilemap tilemap = call.getNative!Tilemap(0);

    static if (op == "set") {
        tilemap.frameTime = call.getInt(1);
    }
    call.setInt(tilemap.frameTime);
}

private void _setTile(GrCall call) {
    Tilemap tilemap = call.getNative!Tilemap(0);
    tilemap.setTile(call.getInt(1), call.getInt(2), call.getInt(3));
}