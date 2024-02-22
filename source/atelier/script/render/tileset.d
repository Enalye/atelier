/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.tileset;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.script.util;

void loadLibRender_tileset(GrLibDefinition library) {
    library.setModule("render.tileset");
    library.setModuleInfo(GrLocale.fr_FR, "Jeu de tuiles");

    GrType tilesetType = library.addNative("Tileset");

    GrType imageDataType = grGetNativeType("ImageData");
    GrType sceneType = grGetNativeType("Scene");

    library.addConstructor(&_ctor, tilesetType, [grString]);

    library.addProperty(&_frameTime!"get", &_frameTime!"set", "frameTime", tilesetType, grInt);
}

private void _ctor(GrCall call) {
    call.setNative(Atelier.res.get!Tileset(call.getString(0)));
}

private void _frameTime(string op)(GrCall call) {
    Tileset tileset = call.getNative!Tileset(0);

    static if (op == "set") {
        tileset.frameTime = call.getInt(1);
    }
    call.setInt(tileset.frameTime);
}
