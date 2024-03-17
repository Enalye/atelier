/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.core.loader.sound;

import farfadet;
import atelier.common;
import atelier.audio;
import atelier.core.runtime;

/// Crée un son
package void compileSound(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept(["file", "volume"]);
    string filePath = ffd.getNode("file", 1).get!string(0);

    float volume = 1f;
    if (ffd.hasNode("volume")) {
        volume = ffd.getNode("volume", 1).get!float(0);
    }

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
    stream.write!float(volume);
}

package void loadSound(InStream stream) {
    string rid = stream.read!string();
    string file = stream.read!string();
    float volume = stream.read!float();

    Atelier.res.store(rid, {
        Sound sound = new Sound(file);
        sound.volume = volume;
        return sound;
    });
}
