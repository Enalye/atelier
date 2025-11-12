module atelier.etabli.media.res.particle.source;

import std.math;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.world;
import atelier.etabli.media.res.entity_base;
import atelier.etabli.media.res.particle.editor;

package final class EditorParticleSource {
    private {
        ParticleResourceEditor _editor;
        EntityGraphic[string] _graphics;
        ParticleData _data;
        Array!Particle _particles, _spawnedParticles;
        Timer _emitTimer, _delayTimer;
        GrEvent _grEvent;
        uint _generation;
    }

    @property {
        bool isRunning() const {
            return _emitTimer.isRunning();
        }
    }

    this(ParticleResourceEditor editor) {
        _editor = editor;
        _particles = new Array!Particle;
        _spawnedParticles = new Array!Particle;
    }

    void setGraphics(EntityRenderData[] renders) {
        _graphics.clear();
        //foreach (render; renders) {
        //    _graphics[render.name()] = render.createEntityGraphicData();
        //}
    }

    void setData(ParticleData data) {
        _data = data;
    }

    void update() {
        foreach (particle; _spawnedParticles) {
            _particles ~= particle;
        }
        _spawnedParticles.clear();

        if (_emitTimer.isRunning()) {
            _emitTimer.update();
            _delayTimer.update();

            if (_data.repeat && !_emitTimer.isRunning()) {
                _emitTimer.start();
                _delayTimer.start(_data.delay);
                _generation = 0;
            }
            else if (!_delayTimer.isRunning()) {
                _delayTimer.start(_data.delay);
                emit();
            }
        }

        foreach (i, particle; _particles) {
            particle.update();
            particle.updateMovement();
            particle.updateEntity();

            EntityGraphic graphic = particle.getGraphic();
            if (graphic) {
                graphic.update();
            }

            if (!particle.isRegistered) {
                _particles.mark(i);
                particle.onUnregister();
            }
        }
        _particles.sweep();
    }

    void draw(Vec2f offset) {
        foreach (particle; _particles) {
            particle.draw(offset);
        }
    }

    void start() {
        _emitTimer.start(_data.duration);
        _generation = 0;
        emit();
    }

    void stop() {
        _emitTimer.stop();
        _delayTimer.stop();
        _grEvent = null;
    }

    void clear() {
        _grEvent = null;
    }

    void emit() {
        if (!_grEvent) {
            _grEvent = Atelier.script.getEvent(_data.event, [
                    grGetNativeType("Particle")
                ]);
            if (!_grEvent)
                return;
        }

        switch (_data.mode) {
        case "spread":
            _emitSpread();
            break;
        case "rectangle":
            _emitRectangle();
            break;
        case "ellipsis":
            _emitEllipsis();
            break;
        default:
            break;
        }
        _generation++;
    }

    private void _emitSpread() {
        uint particleCount = Atelier.rng.randVariance(_data.quantity, _data.quantityVariance);
        float angle = Atelier.rng.randVariance(_data.angle, _data.angleVariance) - (
            _data.angleSpread / 2f);
        float distance = Atelier.rng.randVariance(_data.distance, _data.distanceVariance);
        float spreadPerParticle = _data.angleSpread / particleCount;
        bool _isVertical = false;

        for (int i; i < particleCount; ++i) {
            Particle particle = new Particle(_graphics, _generation, i, _grEvent);
            particle.setRelativeDistance(distance);
            particle.setRelativeAngle(angle); //vertical ?
            particle.angle = angle;
            //particle.pivotAngle = angle;
            _addParticle(particle);

            angle += spreadPerParticle;
        }
    }

    private void _emitRectangle() {
        uint particleCount = Atelier.rng.randVariance(_data.quantity, _data.quantityVariance);
        float angle = Atelier.rng.randVariance(_data.angle, _data.angleVariance) - (
            _data.angleSpread / 2f);
        float spreadPerParticle = _data.angleSpread / particleCount;

        Vec3f offset = -(cast(Vec3f) _data.size) / 2f;
        for (int i; i < particleCount; ++i) {
            float x = Atelier.rng.rand01();
            float y = Atelier.rng.rand01();
            float z = Atelier.rng.rand01();

            Particle particle = new Particle(_graphics, _generation, i, _grEvent);
            particle.setRelativePosition(Vec3f(x, y, z) * (cast(Vec3f) _data.size) + offset);
            particle.angle = angle;
            //particle.pivotAngle = angle;
            _addParticle(particle);

            angle += spreadPerParticle;
        }
    }

    private void _emitEllipsis() {
        uint particleCount = Atelier.rng.randVariance(_data.quantity, _data.quantityVariance);
        float angle = Atelier.rng.randVariance(_data.angle, _data.angleVariance) - (
            _data.angleSpread / 2f);
        float spreadPerParticle = _data.angleSpread / particleCount;

        for (int i; i < particleCount; ++i) {
            float phi = Atelier.rng.rand01() * PI * 2f;
            float rho = Atelier.rng.rand01();
            Vec3f pos = Vec3f(sqrt(rho) * Vec2f.angled(phi), 1f);

            Particle particle = new Particle(_graphics, _generation, i, _grEvent);
            particle.setRelativePosition(pos * _data.size / 2f);
            particle.angle = angle;
            _addParticle(particle);

            angle += spreadPerParticle;
        }
    }

    private void _addParticle(Particle particle) {
        particle.isRegistered = true;
        particle.onRegister();
        particle.setupPosition();
        _spawnedParticles ~= particle;
    }
}
