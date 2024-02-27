/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.tilemap;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.render;
import atelier.script.util;

void loadLibRender_tilemap(GrLibDefinition library) {
    library.setModule("render.tilemap");
    library.setModuleInfo(GrLocale.fr_FR, "Grille de tuiles alignées");
    library.setModuleDescription(GrLocale.fr_FR, "");
    library.setModuleExample(GrLocale.fr_FR, "var tileset = @Tileset(\"terrain\");
var tilemap = @Tilemap(tileset, 20, 20);

// Tilemap peut également être définie en ressource
var tilemap = @Tilemap(\"terrain\");

// Change la tuile {0;2} à 1
tilemap.setTile(0, 2, 1);

var map = @Entity;
map.addImage(tilemap);
scene.addEntity(map);");

    GrType tilemapType = library.addNative("Tilemap", [], "Image");

    GrType tilesetType = grGetNativeType("Tileset");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    library.setDescription(GrLocale.fr_FR, "Crée une tilemap depuis un tileset");
    library.setParameters(["tileset", "width", "height"]);
    library.addConstructor(&_ctor_tileset, tilemapType, [
            tilesetType, grInt, grInt
        ]);

    library.setDescription(GrLocale.fr_FR, "Charge la ressource");
    library.setParameters(["name"]);
    library.addConstructor(&_ctor_name, tilemapType, [grString]);

    library.setDescription(GrLocale.fr_FR, "Taille d’une tuile");
    library.addProperty(&_size!"get", &_size!"set", "size", tilemapType, vec2fType);

    library.setDescription(GrLocale.fr_FR, "Récupère la tuile à la position donnée");
    library.setParameters(["x", "y"]);
    library.addFunction(&_getTile, "getTile", [tilemapType, grInt, grInt], [
            grInt
        ]);

    library.setDescription(GrLocale.fr_FR, "Change la tuile à la position donnée");
    library.setParameters(["x", "y", "tile"]);
    library.addFunction(&_setTile, "setTile", [tilemapType, grInt, grInt, grInt]);
}

private void _ctor_tileset(GrCall call) {
    call.setNative(new Tilemap(call.getNative!Tileset(0), call.getInt(1), call.getInt(2)));
}

private void _ctor_name(GrCall call) {
    call.setNative(Atelier.res.get!Tilemap(call.getString(0)));
}

private void _size(string op)(GrCall call) {
    Tilemap tilemap = call.getNative!Tilemap(0);

    static if (op == "set") {
        tilemap.size = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(tilemap.size));
}

private void _getTile(GrCall call) {
    Tilemap tilemap = call.getNative!Tilemap(0);
    call.setInt(tilemap.getTile(call.getInt(1), call.getInt(2)));
}

private void _setTile(GrCall call) {
    Tilemap tilemap = call.getNative!Tilemap(0);
    tilemap.setTile(call.getInt(1), call.getInt(2), call.getInt(3));
}
