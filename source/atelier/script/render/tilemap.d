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

void loadLibRender_tilemap(GrModule mod) {
    mod.setModule("render.tilemap");
    mod.setModuleInfo(GrLocale.fr_FR, "Grille de tuiles alignées");
    mod.setModuleDescription(GrLocale.fr_FR, "");
    mod.setModuleExample(GrLocale.fr_FR, "var tileset = @Tileset(\"terrain\");
var tilemap = @Tilemap(tileset, 20, 20);

// Tilemap peut également être définie en ressource
var tilemap = @Tilemap(\"terrain\");

// Change la tuile {0;2} à 1
tilemap.setTile(0, 2, 1);

var map = @Entity;
map.addImage(tilemap);
scene.addEntity(map);");

    GrType tilemapType = mod.addNative("Tilemap", [], "Image");

    GrType tilesetType = grGetNativeType("Tileset");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);

    mod.setDescription(GrLocale.fr_FR, "Crée une tilemap depuis un tileset");
    mod.setParameters(["tileset", "width", "height"]);
    mod.addConstructor(&_ctor_tileset, tilemapType, [tilesetType, grInt, grInt]);

    mod.setDescription(GrLocale.fr_FR, "Copie la tilemap");
    mod.setParameters(["tilemap"]);
    mod.addConstructor(&_ctor_copy, tilemapType, [tilemapType]);

    mod.setDescription(GrLocale.fr_FR, "Charge la ressource");
    mod.setParameters(["name"]);
    mod.addConstructor(&_ctor_name, tilemapType, [grString]);

    mod.setDescription(GrLocale.fr_FR, "Largeur en tuiles");
    mod.addProperty(&_width, null, "width", tilemapType, grUInt);

    mod.setDescription(GrLocale.fr_FR, "Hauteur en tuiles");
    mod.addProperty(&_height, null, "height", tilemapType, grUInt);

    mod.setDescription(GrLocale.fr_FR, "Taille d’une tuile");
    mod.addProperty(&_tileSize!"get", &_tileSize!"set", "tileSize", tilemapType, vec2fType);

    mod.setDescription(GrLocale.fr_FR, "Récupère la tuile à la position donnée");
    mod.setParameters(["x", "y"]);
    mod.addFunction(&_getTile, "getTile", [tilemapType, grInt, grInt], [grInt]);

    mod.setDescription(GrLocale.fr_FR, "Change la tuile à la position donnée");
    mod.setParameters(["x", "y", "tile"]);
    mod.addFunction(&_setTile, "setTile", [tilemapType, grInt, grInt, grInt]);
}

private void _ctor_tileset(GrCall call) {
    call.setNative(new Tilemap(call.getNative!Tileset(0), call.getInt(1), call.getInt(2)));
}

private void _ctor_copy(GrCall call) {
    call.setNative(new Tilemap(call.getNative!Tilemap(0)));
}

private void _ctor_name(GrCall call) {
    call.setNative(Atelier.res.get!Tilemap(call.getString(0)));
}

private void _width(GrCall call) {
    Tilemap tilemap = call.getNative!Tilemap(0);
    call.setUInt(tilemap.width);
}

private void _height(GrCall call) {
    Tilemap tilemap = call.getNative!Tilemap(0);
    call.setUInt(tilemap.height);
}

private void _tileSize(string op)(GrCall call) {
    Tilemap tilemap = call.getNative!Tilemap(0);

    static if (op == "set") {
        tilemap.tileSize = call.getNative!SVec2f(1);
    }
    call.setNative(svec2(tilemap.tileSize));
}

private void _getTile(GrCall call) {
    Tilemap tilemap = call.getNative!Tilemap(0);
    call.setInt(tilemap.getTile(call.getInt(1), call.getInt(2)));
}

private void _setTile(GrCall call) {
    Tilemap tilemap = call.getNative!Tilemap(0);
    tilemap.setTile(call.getInt(1), call.getInt(2), call.getInt(3));
}
