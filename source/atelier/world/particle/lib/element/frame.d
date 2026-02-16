module atelier.world.particle.lib.element.frame;

import farfadet;
import atelier.common;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle) void particle_loadElementLibrary_frame(ParticleSystem system) {
    // wait
    system.addElementFunc(&_wait, "wait", [
            ParticleParam("frames", ParticleParam.Type.uint_)
        ]);

    // time
    system.addElementFunc(&_time, "time", [
            ParticleParam("frames", ParticleParam.Type.uint_)
        ]);
}

private void _wait(ParticleElement element, Farfadet ffd) {
    element.waitFrame = element.frame + ffd.get!uint(0);
}

private void _time(ParticleElement element, Farfadet ffd) {
    element.waitFrame = ffd.get!uint(0);
}
