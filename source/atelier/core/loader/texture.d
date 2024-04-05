/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.core.loader.texture;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

/// Crée des textures
package void compileTexture(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept(["file"]);
    string filePath = ffd.getNode("file", 1).get!string(0);

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
}

package void loadTexture(InStream stream) {
    string rid = stream.read!string();
    string filePath = stream.read!string();

    Atelier.res.store(rid, {
        Texture texture = Texture.fromResource(filePath);
        return texture;
    });
}
