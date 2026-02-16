module atelier.world.particle.lib.element.flip;

import std.conv : to, ConvException;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle) void particle_loadElementLibrary_flip(ParticleSystem system) {
    // flipX
    system.addElementFunc(&_flipX, "flipX", [
            ParticleParam("miroir", ParticleParam.Type.bool_)
        ]);

    // flipY
    system.addElementFunc(&_flipY, "flipY", [
            ParticleParam("miroir", ParticleParam.Type.bool_)
        ]);
}

private void _flipX(ParticleElement element, Farfadet ffd) {
    element.flipX = ffd.get!bool(0);
}

private void _flipY(ParticleElement element, Farfadet ffd) {
    element.flipY = ffd.get!bool(0);
}
