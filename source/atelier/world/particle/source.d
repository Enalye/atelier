module atelier.world.particle.source;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.world.particle.effect;
import atelier.world.particle.element;
import atelier.world.particle.system;
import atelier.world.particle.particle;

final class ParticleSource {
    private {
        Particle _particle;
        Vec3i _position;
        Array!ParticleElement _elements;
        Array!(ParticleEffect!ParticleSource) _effects;
        Farfadet[] _instructions;
        uint _pc, _frame;
    }

    uint waitFrame;

    @property {
        Particle particle() {
            return _particle;
        }

        bool isRunning() const {
            return _pc < _instructions.length || _elements.length || _effects.length || _frame <= waitFrame;
        }

        uint frame() const {
            return _frame;
        }
    }

    this(Particle particle_, Farfadet ffd) {
        _particle = particle_;
        _instructions = ffd.getNodes();
        _elements = new Array!ParticleElement;
        _effects = new Array!(ParticleEffect!ParticleSource);
    }

    void addEffect(ParticleEffect!ParticleSource effect) {
        _effects ~= effect;
    }

    ParticleElement create(string id) {
        ParticleElement element = _particle.create(id);

        if (element) {
            _elements ~= element;
        }

        return element;
    }

    void update(ParticleSystem system) {
        while (_pc < _instructions.length && _frame >= waitFrame) {
            Farfadet instruction = _instructions[_pc];
            system.callSourceFunction(this, instruction);
            _pc++;
        }

        foreach (i, effect; _effects) {
            if (!effect.process(this)) {
                _effects.mark(i);
            }
        }
        _effects.sweep();

        foreach (i, element; _elements) {
            element.update(system);
            if (!element.isRunning) {
                _elements.mark(i);
            }
        }
        _elements.sweep();

        _frame++;
    }

    void draw(Texture texture, Vec2f offset, float zoom = 1f) {
        foreach (i, element; _elements) {
            element.draw(texture, offset, zoom);
        }
    }
}
