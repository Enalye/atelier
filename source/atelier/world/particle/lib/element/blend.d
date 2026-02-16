module atelier.world.particle.lib.element.blend;

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

package(atelier.world.particle) void particle_loadElementLibrary_blend(ParticleSystem system) {
    // blend
    system.addElementFunc(&_blend, "blend", [
            ParticleParam("blend", ParticleParam.Type.enum_, [
                    __traits(allMembers, Blend)
                ])
        ]);
}

private void _blend(ParticleElement element, Farfadet ffd) {
    try {
        element.blend = to!Blend(ffd.get!string(0));
    }
    catch (ConvException e) {
        element.blend = Blend.alpha;
        Atelier.log("Blending non reconnu ̀ ", ffd.get!string(0), "`");
    }
}
