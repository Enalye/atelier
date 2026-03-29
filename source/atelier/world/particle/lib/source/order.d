module atelier.world.particle.lib.source.order;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle.lib.source) void particle_loadElementLibrary_order(
    ParticleSystem system) {
    // order
    system.addSourceFunc(&_order, "order", [
            ParticleParam("order", ParticleParam.Type.int_)
        ]);
}

private void _order(ParticleSource source, Farfadet ffd) {
    source.order = ffd.get!int(0);
}
