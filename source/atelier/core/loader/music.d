/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.core.loader.music;

import farfadet;
import atelier.common;
import atelier.audio;
import atelier.core.runtime;

/// Crée une musique
package void compileMusic(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept(["file", "volume", "loopStart", "loopEnd"]);
    string filePath = ffd.getNode("file", 1).get!string(0);

    float volume = 1f;
    if (ffd.hasNode("volume")) {
        volume = ffd.getNode("volume", 1).get!float(0);
    }
    float loopStart = -1f;
    if (ffd.hasNode("loopStart")) {
        loopStart = ffd.getNode("loopStart", 1).get!float(0);
    }

    float loopEnd = -1f;
    if (ffd.hasNode("loopEnd")) {
        loopEnd = ffd.getNode("loopEnd", 1).get!float(0);
    }

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
    stream.write!float(volume);
    stream.write!float(loopStart);
    stream.write!float(loopEnd);
}

package void loadMusic(InStream stream) {
    string rid = stream.read!string();
    string file = stream.read!string();
    float volume = stream.read!float();
    float loopStart = stream.read!float();
    float loopEnd = stream.read!float();

    Atelier.res.store(rid, {
        Music music = new Music(file);
        music.volume = volume;
        music.loopStart = loopStart;
        music.loopEnd = loopEnd;
        return music;
    });
}
