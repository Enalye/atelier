/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.core.loader.truetype;

import std.exception : enforce;
import std.format : format;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

package void compileTrueType(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept(["file", "size", "outline"]);

    string filePath = ffd.getNode("file", 1).get!string(0);
    uint size = ffd.getNode("size", 1).get!uint(0);

    uint outline = 0;
    if (ffd.hasNode("outline")) {
        outline = ffd.getNode("outline", 1).get!uint(0);
    }

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
    stream.write!uint(size);
    stream.write!uint(outline);
}

package void loadTrueType(InStream stream) {
    string rid = stream.read!string();
    string file = stream.read!string();
    uint size = stream.read!uint();
    uint outline = stream.read!uint();

    Atelier.res.store(rid, {
        TrueTypeFont font = TrueTypeFont.fromResource(file, size, outline);
        return font;
    });
}
