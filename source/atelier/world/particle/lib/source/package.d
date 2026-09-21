module atelier.world.particle.lib.source;

import farfadet;

import atelier.world.particle.system;
import atelier.world.particle.lib.source.circle;
import atelier.world.particle.lib.source.ellipsis;
import atelier.world.particle.lib.source.order;
import atelier.world.particle.lib.source.frame;
import atelier.world.particle.lib.source.point;
import atelier.world.particle.lib.source.rectangle;

package(atelier.world.particle) void particle_loadSourceLibrary(ParticleSystem system) {
    foreach (func; [
            &particle_loadSourceLibrary_circle,
            &particle_loadSourceLibrary_ellipsis,
            &particle_loadSourceLibrary_order,
            &particle_loadSourceLibrary_frame,
            &particle_loadSourceLibrary_point,
            &particle_loadSourceLibrary_rectangle,
        ]) {
        func(system);
    }
}
