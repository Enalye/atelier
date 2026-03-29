module atelier.world.particle.lib.source.point;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.particle;
import atelier.world.particle.source;
import atelier.world.particle.system;

package(atelier.world.particle.lib.source) void particle_loadElementLibrary_point(
    ParticleSystem system) {
    // point
    system.addSourceFunc(&_spawnPoint, "spawnPoint");
    system.addSourceParam("spawnPoint", "id", [
            ParticleParam("element", ParticleParam.Type.string_)
        ]);
    system.addSourceParam("spawnPoint", "delay", [
            ParticleParam("frames", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
    system.addSourceParam("spawnPoint", "generations", [
            ParticleParam("nombre", ParticleParam.Type.uint_),
            ParticleParam("variance", ParticleParam.Type.uint_)
        ]);
}

private final class SpawnPoint : ParticleEffect!ParticleSource {
    private {
        struct Data {
            string id;
            Vec2u generations;
            Vec2u delay;

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
        source.create(_data.id);
    }
}

private void _spawnPoint(ParticleSource source, Farfadet ffd) {
    source.addEffect(new SpawnPoint(source, ffd));
}
