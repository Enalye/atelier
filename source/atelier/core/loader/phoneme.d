module atelier.core.loader.phoneme;

import std.exception : enforce;
import std.format : format;

import farfadet;
import atelier.common;
import atelier.audio;
import atelier.core.runtime;

package void compilePhoneme(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    stream.write!string(rid);
    PhonemeData data;

    data.load(ffd);
    data.serialize(stream);
}

package void loadPhoneme(InStream stream) {
    string rid = stream.read!string();

    PhonemeData data;
    data.deserialize(stream);

    Atelier.res.store(rid, {
        Sound sound = Atelier.res.get!Sound(data.sound);
        Phoneme phoneme = new Phoneme(data, sound);
        return phoneme;
    });
}
