module atelier.core.loader.tilemap;

import std.exception : enforce;
import std.format : format;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

/// Crée une tilemap
package void compileTilemap(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept(["tileset", "size", "tiles", "heightmap"]);

    string tilesetRID = ffd.getNode("tileset", 1).get!string(0);

    Farfadet sizeNode = ffd.getNode("size", 2);
    uint width = sizeNode.get!int(0);
    uint height = sizeNode.get!int(1);

    int[][] tiles;
    if (ffd.hasNode("tiles")) {
        tiles = ffd.getNode("tiles", 1).get!(int[][])(0);
    }

    stream.write!string(rid);
    stream.write!uint(width);
    stream.write!uint(height);
    stream.write!string(tilesetRID);
    stream.write!(int[][])(tiles);
}

package void loadTilemap(InStream stream) {
    const string rid = stream.read!string();
    const uint width = stream.read!uint();
    const uint height = stream.read!uint();
    const string tilesetRID = stream.read!string();
    const int[][] tiles = stream.read!(int[][])();

    Atelier.res.store(rid, {
        Tileset tileset = Atelier.res.get!Tileset(tilesetRID);
        Tilemap tilemap = new Tilemap(tileset, width, height);
        if (tiles.length)
            tilemap.setTiles(tiles);
        return tilemap;
    });
}
