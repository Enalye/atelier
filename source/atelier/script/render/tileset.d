/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.render.tileset;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.script.util;

void loadLibRender_tileset(GrLibDefinition library) {
    GrType tilesetType = library.addNative("Tileset");

    library.addConstructor(&_ctor, tilesetType, [grString]);
}

private void _ctor(GrCall call) {
    call.setNative(Atelier.res.get!Tileset(call.getString(0)));
}
