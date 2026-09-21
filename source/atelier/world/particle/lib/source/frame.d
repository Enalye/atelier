module atelier.world.particle.lib.source.frame;

import farfadet;
import atelier.common;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle) void particle_loadSourceLibrary_frame(ParticleSystem system) {
    // wait
    system.addSourceFunc(&_wait, "wait", [
            ParticleParam("frames", ParticleParam.Type.uint_)
        ]);

    // time
    system.addSourceFunc(&_time, "time", [
            ParticleParam("frames", ParticleParam.Type.uint_)
        ]);
}

private void _wait(ParticleSource source, Farfadet ffd) {
    source.waitFrame = source.frame + ffd.get!uint(0);
}

private void _time(ParticleSource source, Farfadet ffd) {
    source.waitFrame = ffd.get!uint(0);
}
