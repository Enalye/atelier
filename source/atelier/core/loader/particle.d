module atelier.core.loader.particle;

import std.conv : to, ConvException;
import std.exception : enforce;
import std.format : format;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.world;
import atelier.core.runtime;
import atelier.core.loader.util;

package void compileParticle(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    stream.write!string(rid);
    stream.write!string(ffd.generate(0, false));
}

package void loadParticle(InStream stream) {
    const string rid = stream.read!string();
    Farfadet ffd = Farfadet.fromString(stream.read!string()).getNode("particle");

    Atelier.res.store(rid, {
        Particle particle = new Particle;
        particle.load(ffd);
        return particle;
    });
}
