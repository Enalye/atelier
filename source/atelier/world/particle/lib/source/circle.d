module atelier.world.particle.lib.source.circle;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle.lib.source) void particle_loadElementLibrary_circle(
    ParticleSystem system) {
    // circle
    system.addSourceFunc(&_spawnCircle, "spawnCircle");
    system.addSourceParam("spawnCircle", "id", [
            ParticleParam("element", ParticleParam.Type.string_)
        ]);
    system.addSourceParam("spawnCircle", "count", [
            ParticleParam("nombre", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addSourceParam("spawnCircle", "distance", [
            ParticleParam("distance", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_)
        ]);
    system.addSourceParam("spawnCircle", "spread", [
            ParticleParam("angle", ParticleParam.Type.float_),
            ParticleParam("variance", ParticleParam.Type.float_),
            ParticleParam("ouverture", ParticleParam.Type.float_)
        ]);
    system.addSourceParam("spawnCircle", "delay", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addSourceParam("spawnCircle", "generations", [
            ParticleParam("nombre", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
}

private final class SpawnCircle : ParticleEffect!ParticleSource {
    private {
        struct Data {
            string id;
            Vec2u count;
            Vec2f distance = Vec2f.zero;
            Vec3f spread = Vec3f.zero;
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
        float angle = Atelier.rng.randVariance(_data.spread.x, _data.spread.y) - (
            _data.spread.z / 2f);
        float distance = Atelier.rng.randVariance(_data.distance.x, _data.distance.y);
        float spreadPerParticle = _data.spread.z / cast(float) particleCount;

        for (uint i; i < particleCount; ++i) {
            ParticleElement element = source.create(_data.id);
            if (element) {
                element.distance = distance;
                element.angle = angle;

                angle += spreadPerParticle;
            }
        }
    }
}

private void _spawnCircle(ParticleSource source, Farfadet ffd) {
    source.addEffect(new SpawnCircle(source, ffd));
}
