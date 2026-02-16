module atelier.world.particle.effect;

import atelier.common;
import atelier.world.particle.element;

interface ParticleEffect(T) {
    bool process(T);
}
