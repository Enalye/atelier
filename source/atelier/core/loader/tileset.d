/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.core.loader.tileset;

import std.exception : enforce;
import std.format : format;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

/// Crée des Tilesets
package void compileTileset(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept([
        "texture", "clip", "tileSize", "isIsometric", "frameTime", "tileFrame",
        "columns", "lines", "maxCount", "margin"
    ]);

    string textureRID = ffd.getNode("texture", 1).get!string(0);

    Vec4u clip;
    Vec2u tileSize;
    {
        Farfadet clipNode = ffd.getNode("clip", 4);
        clip.x = clipNode.get!uint(0);
        clip.y = clipNode.get!uint(1);
        clip.z = clipNode.get!uint(2);
        clip.w = clipNode.get!uint(3);
        tileSize = clip.zw;
    }

    if (ffd.hasNode("tileSize")) {
        Farfadet tileSizeNode = ffd.getNode("tileSize", 2);
        tileSize = Vec2u(tileSizeNode.get!uint(0), tileSizeNode.get!uint(1));
    }

    bool isIsometric;
    if (ffd.hasNode("isIsometric")) {
        isIsometric = ffd.getNode("isIsometric", 1).get!bool(0);
    }

    uint frameTime;
    if (ffd.hasNode("frameTime")) {
        frameTime = ffd.getNode("frameTime", 1).get!uint(0);
    }

    int[] tileFrames;
    foreach (node; ffd.getNodes("tileFrame", 2)) {
        tileFrames ~= node.get!int(0);
        tileFrames ~= node.get!int(1);
    }

    uint columns;
    if (ffd.hasNode("columns")) {
        columns = ffd.getNode("columns", 1).get!uint(0);
    }

    uint lines;
    if (ffd.hasNode("lines")) {
        lines = ffd.getNode("lines", 1).get!uint(0);
    }

    uint maxCount = columns * lines;
    if (ffd.hasNode("maxCount")) {
        maxCount = ffd.getNode("maxCount", 1).get!uint(0);
    }

    Vec2i margin;
    if (ffd.hasNode("margin")) {
        Farfadet marginNode = ffd.getNode("margin", 2);
        margin = Vec2i(marginNode.get!int(0), marginNode.get!int(1));
    }

    stream.write!string(rid);
    stream.write!string(textureRID);
    stream.write!Vec4u(clip);
    stream.write!Vec2u(tileSize);
    stream.write!uint(columns);
    stream.write!uint(lines);
    stream.write!uint(maxCount);
    stream.write!bool(isIsometric);
    stream.write!(int[])(tileFrames);
    stream.write!uint(frameTime);
    stream.write!Vec2i(margin);
}

package void loadTileset(InStream stream) {
    string rid = stream.read!string();
    string textureRID = stream.read!string();
    Vec4u clip = stream.read!Vec4u();
    Vec2u tileSize = stream.read!Vec2u();
    uint columns = stream.read!uint();
    uint lines = stream.read!uint();
    uint maxCount = stream.read!uint();
    bool isIsometric = stream.read!bool();
    int[] tileFrames = stream.read!(int[])();
    uint frameTime = stream.read!uint();
    Vec2i margin = stream.read!Vec2i();

    Atelier.res.store(rid, {
        Texture texture = Atelier.res.get!Texture(textureRID);
        Tileset tileset = new Tileset(texture, clip, columns, lines, maxCount);
        tileset.tileSize = tileSize;
        tileset.frameTime = frameTime;
        tileset.margin = margin;
        tileset.isIsometric = isIsometric;

        for (int tileId; tileId < tileFrames.length; tileId += 2) {
            tileset.setTileFrame(cast(short) tileFrames[tileId], cast(short) tileFrames[tileId + 1]);
        }
        return tileset;
    });
}
