module atelier.world.particle.lib.element;

import farfadet;

import atelier.common;
import atelier.world.particle.system;
import atelier.world.particle.lib.element.alpha;
import atelier.world.particle.lib.element.angle;
import atelier.world.particle.lib.element.blend;
import atelier.world.particle.lib.element.clip;
import atelier.world.particle.lib.element.color;
import atelier.world.particle.lib.element.distance;
import atelier.world.particle.lib.element.flip;
import atelier.world.particle.lib.element.frame;
import atelier.world.particle.lib.element.origin;
import atelier.world.particle.lib.element.position;
import atelier.world.particle.lib.element.scale;
import atelier.world.particle.lib.element.sprite_angle;

package(atelier.world.particle) void particle_loadElementLibrary(ParticleSystem system) {
    foreach (func; [
            &particle_loadElementLibrary_alpha,
            &particle_loadElementLibrary_angle,
            &particle_loadElementLibrary_blend,
            &particle_loadElementLibrary_clip,
            &particle_loadElementLibrary_color,
            &particle_loadElementLibrary_distance,
            &particle_loadElementLibrary_flip,
            &particle_loadElementLibrary_frame,
            &particle_loadElementLibrary_origin,
            &particle_loadElementLibrary_position,
            &particle_loadElementLibrary_scale,
            &particle_loadElementLibrary_spriteAngle,
        ]) {
        func(system);
    }
}
