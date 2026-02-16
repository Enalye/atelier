module atelier.world.particle.lib.source.rectangle;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle.lib.source) void particle_loadElementLibrary_rectangle(
    ParticleSystem system) {
    // rectangle
    system.addSourceFunc(&_spawnRectangle, "spawnRectangle");
    system.addSourceParam("spawnRectangle", "id", [
            ParticleParam("element", ParticleParam.Type.string_)
        ]);
    system.addSourceParam("spawnRectangle", "count", [
            ParticleParam("nombre", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addSourceParam("spawnRectangle", "size", [
            ParticleParam("x", ParticleParam.Type.float_),
            ParticleParam("y", ParticleParam.Type.float_),
            ParticleParam("z", ParticleParam.Type.float_)
        ]);
    system.addSourceParam("spawnRectangle", "delay", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addSourceParam("spawnRectangle", "generations", [
            ParticleParam("nombre", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
}

private final class SpawnRectangle : ParticleEffect!ParticleSource {
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

        for (int i; i < particleCount; ++i) {
            float x = Atelier.rng.rand01();
            float y = Atelier.rng.rand01();
            float z = Atelier.rng.rand01();

            ParticleElement element = source.create(_data.id);
            if (element) {
                element.origin = Vec3f(x, y, z) * (cast(Vec3f) _data.size);
            }
        }
    }
}

private void _spawnRectangle(ParticleSource source, Farfadet ffd) {
    source.addEffect(new SpawnRectangle(source, ffd));
}
