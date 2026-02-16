module atelier.world.particle.element;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.world.particle.effect;
import atelier.world.particle.system;

final class ParticleElement {
    private {
        uint _pc, _frame;
        Farfadet[] _instructions;
        Array!(ParticleEffect!ParticleElement) _effects;
    }

    Vec4u clip;
    Vec2f scale = Vec2f.one;
    float spriteAngle = 0f;
    bool flipX;
    bool flipY;

    Vec3f origin = Vec3f.zero;
    Vec3f position = Vec3f.zero;
    float distance = 0f;
    float angle = 0f;
    Blend blend = Blend.alpha;
    Color color = Color.white;
    float alpha = 1f;

    uint waitFrame;

    this(Farfadet ffd) {
        _instructions = ffd.getNodes();
        _effects = new Array!(ParticleEffect!ParticleElement);
    }

    @property {
        bool isRunning() const {
            return _pc < _instructions.length || _frame <= waitFrame || _effects.length;
        }

        uint frame() const {
            return _frame;
        }
    }

    void addEffect(ParticleEffect!ParticleElement effect) {
        _effects ~= effect;
    }

    void update(ParticleSystem system) {
        while (_pc < _instructions.length && _frame >= waitFrame) {
            Farfadet instruction = _instructions[_pc];
            system.callElementFunction(this, instruction);
            _pc++;
        }

        foreach (i, effect; _effects) {
            if (!effect.process(this)) {
                _effects.mark(i);
            }
        }
        _effects.sweep();

        _frame++;
    }

    void draw(Texture texture, Vec2f offset, float zoom = 1f) {
        Vec2f delta = origin.proj2D();
        delta += Vec2f.angled(degToRad(angle)) * distance;
        delta += position.proj2D();
        Vec2f size = (cast(Vec2f) clip.zw) * scale * zoom;
        texture.blend = blend;
        texture.color = color;
        texture.alpha = alpha;
        texture.draw((offset + delta * zoom) - size * 0.5f, size, clip, spriteAngle, Vec2f.half, flipX, flipY);
    }
}
