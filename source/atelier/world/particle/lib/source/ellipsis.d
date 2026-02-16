module atelier.world.particle.lib.source.ellipsis;

import std.math;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle.lib.source) void particle_loadElementLibrary_ellipsis(
    ParticleSystem system) {
    // ellipsis
    system.addSourceFunc(&_spawnEllipsis, "spawnEllipsis");
    system.addSourceParam("spawnEllipsis", "id", [
            ParticleParam("element", ParticleParam.Type.string_)
        ]);
    system.addSourceParam("spawnEllipsis", "count", [
            ParticleParam("nombre", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addSourceParam("spawnEllipsis", "size", [
            ParticleParam("x", ParticleParam.Type.float_),
            ParticleParam("y", ParticleParam.Type.float_),
            ParticleParam("z", ParticleParam.Type.float_)
        ]);
    system.addSourceParam("spawnEllipsis", "delay", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addSourceParam("spawnEllipsis", "generations", [
            ParticleParam("nombre", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
}

private final class SpawnEllipsis : ParticleEffect!ParticleSource {
    private {
        struct Data {
            string id;
            Vec2u count;
            Vec3f size = Vec3f.zero;
            Vec2u delay;
            Vec2u generations;

            mixin Serializer;
        }

        Timer _timer;
        Data _data;
        uint _generation, _maxGeneration;
    }

    this(ParticleSource source, Farfadet ffd) {
        _data.load(ffd);

        _maxGeneration = Atelier.rng.randVariance(_data.generations.x, _data
                .generations.y);
    }

    bool process(ParticleSource source) {
        if (_timer.isRunning()) {
            _timer.update();
            return true;
        }

        uint duration = Atelier.rng.randVariance(_data.delay.x, _data.delay.y);
        _timer.start(duration);
        if (_generation < _maxGeneration) {
            _generation++;
            emit(source);
            return true;
        }
        return false;
    }

    void emit(ParticleSource source) {
        uint particleCount = Atelier.rng.randVariance(_data.count.x, _data.count.y);

        for (uint i; i < particleCount; ++i) {
            ParticleElement element = source.create(_data.id);
            if (element) {
                float phi = Atelier.rng.rand01() * PI * 2f;
                float rho = Atelier.rng.rand01();
                Vec3f pos = Vec3f(sqrt(rho) * Vec2f.angled(phi), 1f);
                element.origin = pos * _data.size / 2f;
            }
        }
    }
}

private void _spawnEllipsis(ParticleSource source, Farfadet ffd) {
    source.addEffect(new SpawnEllipsis(source, ffd));
}
