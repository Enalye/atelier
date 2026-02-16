module atelier.world.particle.lib.source;

import farfadet;

import atelier.world.particle.system;
import atelier.world.particle.lib.source.circle;
import atelier.world.particle.lib.source.ellipsis;
import atelier.world.particle.lib.source.rectangle;

package(atelier.world.particle) void particle_loadSourceLibrary(ParticleSystem system) {
    foreach (func; [
            &particle_loadElementLibrary_circle,
            &particle_loadElementLibrary_ellipsis,
            &particle_loadElementLibrary_rectangle,
        ]) {
        func(system);
    }
}
