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

    ffd.accept(["file", "volume", "intro", "outro"]);
    string filePath = ffd.getNode("file", 1).get!string(0);

    float volume = 1f;
    if (ffd.hasNode("volume")) {
        volume = ffd.getNode("volume", 1).get!float(0);
    }
    float intro = -1f;
    if (ffd.hasNode("intro")) {
        intro = ffd.getNode("intro", 1).get!float(0);
    }

    float outro = -1f;
    if (ffd.hasNode("outro")) {
        outro = ffd.getNode("outro", 1).get!float(0);
    }

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
    stream.write!float(volume);
    stream.write!float(intro);
    stream.write!float(outro);
}

package void loadMusic(InStream stream) {
    string rid = stream.read!string();
    string file = stream.read!string();
    float volume = stream.read!float();
    float intro = stream.read!float();
    float outro = stream.read!float();

    Atelier.res.store(rid, {
        Music music = Music.fromResource(file);
        music.volume = volume;
        music.intro = intro;
        music.outro = outro;
        return music;
    });
}
