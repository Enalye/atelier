module atelier.world.particle.lib.element.clip;
import farfadet;
import atelier.common;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle) void particle_loadElementLibrary_clip(ParticleSystem system) {
    system.addElementFunc(&_clip, "clip", [
            ParticleParam("x", ParticleParam.Type.uint_),
            ParticleParam("y", ParticleParam.Type.uint_),
            ParticleParam("w", ParticleParam.Type.uint_),
            ParticleParam("h", ParticleParam.Type.uint_)
        ]);
    system.addElementFunc(&_addClip, "addClip", [
            ParticleParam("x", ParticleParam.Type.int_),
            ParticleParam("y", ParticleParam.Type.int_),
            ParticleParam("w", ParticleParam.Type.int_),
            ParticleParam("h", ParticleParam.Type.int_)
        ]);
}

private void _clip(ParticleElement element, Farfadet ffd) {
    element.clip = ffd.get!Vec4u(0);
}

private void _addClip(ParticleElement element, Farfadet ffd) {
    Vec4i clip = cast(Vec4i) element.clip;
    clip += ffd.get!Vec4i(0);
    element.clip += cast(Vec4u) clip.max(Vec4i.zero);
}
