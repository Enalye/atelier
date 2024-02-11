/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.scene.particle;

import std.random;
import std.math;
import atelier.common;
import atelier.core;
import atelier.render;
import atelier.scene.entity;
import atelier.scene.scene;

private final class Particle {
    int frame, ttl;

    Vec2f origin = Vec2f.zero;
    Vec2f position = Vec2f.zero;
    float speed = 0f;

    float angle = 0f;
    float spin = 0f;

    Vec2f pivot = Vec2f.zero;
    float pivotAngle = 0f;
    float pivotSpin = 0f;
    float pivotDistance = 0f;

    float spriteAngle = 0f;
    float spriteSpin = 0f;

    Vec2f scale = Vec2f.one;
    Color color = Color.white;
    float alpha = 1f;

    void update() {
        pivotAngle += pivotSpin;
        spriteAngle += spriteSpin;
        if (pivotDistance) {
            pivot = Vec2f.angled(pivotAngle) * pivotDistance;
        }
        if (speed) {
            position += Vec2f.angled(angle) * speed;
        }
        frame++;
    }

    void draw() {
    }
}

enum ParticleMode {
    spread,
    rectangle,
    ellipsis
}

final class ParticleSource {
    private {
        Array!Particle _particles;
        ParticleEffect[] _effects;
        Scene _scene;

        Sprite _sprite;
        Vec2f _spriteSize = Vec2f.one;

        bool _isAlive = true;
        bool _isRelativePosition;
        bool _isRelativeSpriteAngle;
        bool _isAttachedToScene;
        Entity _attachedEntity;
        uint _interval;
        int _emitterTime;
        uint _minCount, _maxCount;
        uint _minLifetime, _maxLifetime;

        Blend _blend = Blend.alpha;
        ParticleMode _mode = ParticleMode.rectangle;

        // Spread
        float _minAngle = 0f, _maxAngle = 0f, _spreadAngle = 0f;
        float _minDistance = 0f, _maxDistance = 0f;

        // Zone
        Vec2f _area = Vec2f.zero;
    }

    Vec2f position = Vec2f.zero;

    @property {
        bool isAlive() const {
            return _isAlive;
        }
    }

    this() {
        _particles = new Array!Particle;
    }

    package void setScene(Scene scene_) {
        _scene = scene_;
    }

    void addEffect(ParticleEffect effect) {
        _effects ~= effect;
    }

    void update() {
        if (_interval > 0) {
            _emitterTime--;
            if (_emitterTime <= 0) {
                _emitterTime = _interval;
                emit();
            }
        }

        Vec2f origin;
        if (_isRelativePosition) {
            origin = position;
            if (_attachedEntity) {
                origin += _attachedEntity.scenePosition();
            }
            else if (_isAttachedToScene && _scene) {
                origin += _scene.position;
            }
        }

        foreach (i, particle; _particles) {
            foreach (ParticleEffect effect; _effects) {
                if (particle.frame >= effect.getStartFrame() &&
                    particle.frame <= effect.getEndFrame()) {
                    effect.update(particle);
                }
            }
            if (_isRelativePosition)
                particle.origin = origin;
            particle.update();

            if (particle.frame > particle.ttl) {
                _particles.mark(i);
            }
        }
        _particles.sweep();
    }

    Vec2f getOrigin() {
        Vec2f origin = position;
        if (_attachedEntity) {
            origin += _attachedEntity.scenePosition();
        }
        else if (_isAttachedToScene && _scene) {
            origin += _scene.position;
        }
        return origin;
    }

    void draw(Vec2f origin) {
        if (!_sprite)
            return;

        _sprite.blend = _blend;
        foreach (particle; _particles) {
            _sprite.color = particle.color;
            _sprite.alpha = particle.alpha;
            _sprite.size = particle.scale * _spriteSize;
            if (_isRelativeSpriteAngle) {
                _sprite.angle = radToDeg(particle.angle + particle.spriteAngle);
            }
            else {
                _sprite.angle = radToDeg(particle.spriteAngle);
            }
            _sprite.draw(origin + particle.origin + particle.position + particle.pivot);
        }
    }

    void start(uint interval) {
        _interval = interval;
        _emitterTime = _interval;
        emit();
    }

    void stop() {
        _interval = 0;
        _emitterTime = 0;
    }

    void clear() {
        _particles.clear();
    }

    void remove() {
        _isAlive = false;
    }

    void emit() {
        final switch (_mode) with (ParticleMode) {
        case spread:
            _emitSpread();
            break;
        case rectangle:
            _emitRectangle();
            break;
        case ellipsis:
            _emitEllipsis();
            break;
        }
    }

    void setSprite(string id) {
        _sprite = Atelier.res.get!Sprite(id);
        _spriteSize = _sprite.size;
    }

    void setBlend(Blend blend) {
        _blend = blend;
    }

    void setRelativePosition(bool isRelative) {
        _isRelativePosition = isRelative;
    }

    void setRelativeSpriteAngle(bool isRelative) {
        _isRelativeSpriteAngle = isRelative;
    }

    void setLifetime(uint minLifetime, uint maxLifetime) {
        _minLifetime = minLifetime;
        _maxLifetime = maxLifetime;
    }

    void setCount(uint minCount, uint maxCount) {
        _minCount = minCount;
        _maxCount = maxCount;
    }

    void attachTo(Entity entity) {
        _isAttachedToScene = false;
        _attachedEntity = entity;
    }

    void attachToScene() {
        _isAttachedToScene = true;
        _attachedEntity = null;
    }

    void setMode(ParticleMode mode) {
        _mode = mode;
    }

    void setArea(float x, float y) {
        _area = Vec2f(x, y);
    }

    void setDistance(float minDistance, float maxDistance) {
        _minDistance = minDistance;
        _maxDistance = maxDistance;
    }

    void setSpread(float minAngle, float maxAngle, float spreadAngle) {
        _minAngle = minAngle;
        _maxAngle = maxAngle;
        _spreadAngle = spreadAngle;
    }

    private void _emitSpread() {
        uint particleCount = Atelier.rng.randi(_minCount, _maxCount);
        float distance = Atelier.rng.randf(_minDistance, _maxDistance);
        float angle = Atelier.rng.randf(_minAngle, _maxAngle) - (_spreadAngle / 2f);
        float spreadPerParticle = _spreadAngle / particleCount;

        Vec2f origin = getOrigin();
        for (int i; i < particleCount; ++i) {
            Particle particle = new Particle;
            particle.origin = origin;
            particle.position = Vec2f.angled(angle) * distance;
            particle.angle = angle;
            particle.pivotAngle = angle;
            particle.ttl = Atelier.rng.randi(_minLifetime, _maxLifetime);
            _particles ~= particle;

            angle += spreadPerParticle;
        }
    }

    private void _emitRectangle() {
        uint particleCount = Atelier.rng.randu(_minCount, _maxCount);
        float angle = Atelier.rng.randf(_minAngle, _maxAngle) - (_spreadAngle / 2f);
        float spreadPerParticle = _spreadAngle / particleCount;

        Vec2f origin = getOrigin();
        Vec2f offset = -_area / 2f;
        for (int i; i < particleCount; ++i) {
            float x = Atelier.rng.randf();
            float y = Atelier.rng.randf();

            Particle particle = new Particle;
            particle.origin = origin;
            particle.position = Vec2f(x, y) * _area + offset;
            particle.angle = angle;
            particle.pivotAngle = angle;
            particle.ttl = Atelier.rng.randi(_minLifetime, _maxLifetime);
            _particles ~= particle;

            angle += spreadPerParticle;
        }
    }

    private void _emitEllipsis() {
        uint particleCount = Atelier.rng.randi(_minCount, _maxCount);
        float angle = Atelier.rng.randf(_minAngle, _maxAngle) - (_spreadAngle / 2f);
        float spreadPerParticle = _spreadAngle / particleCount;

        Vec2f origin = getOrigin();

        for (int i; i < particleCount; ++i) {
            float phi = Atelier.rng.randf() * PI * 2f;
            float rho = Atelier.rng.randf();
            Vec2f pos = sqrt(rho) * Vec2f.angled(phi);

            Particle particle = new Particle;
            particle.origin = origin;
            particle.position = pos * _area / 2f;
            particle.angle = angle;
            particle.pivotAngle = angle;
            particle.ttl = Atelier.rng.randi(_minLifetime, _maxLifetime);
            _particles ~= particle;

            angle += spreadPerParticle;
        }
    }
}

abstract class ParticleEffect {
    private {
        uint _startFrame, _endFrame;
    }

    void setFrames(uint startFrame, uint endFrame) {
        if (startFrame > endFrame) {
            _startFrame = endFrame;
            _endFrame = startFrame;
        }
        else {
            _startFrame = startFrame;
            _endFrame = endFrame;
        }
    }

    final int getStartFrame() const {
        return _startFrame;
    }

    final int getEndFrame() const {
        return _endFrame;
    }

    final float getProgress(int frame) const {
        if (_endFrame == _startFrame)
            return 1f;
        return (cast(float)(frame - _startFrame)) / cast(float)(_endFrame - _startFrame);
    }

    void update(Particle particle);
}

final class OnceParticleEffect(T, string FieldName) : ParticleEffect {
    private {
        T _minValue, _maxValue;
    }

    this(T minValue, T maxValue) {
        _minValue = minValue;
        _maxValue = maxValue;
    }

    override void update(Particle particle) {
        mixin("particle.", FieldName, " = lerp(_minValue, _maxValue, Atelier.rng.randf());");
    }
}

final class IntervalParticleEffect(T, string FieldName) : ParticleEffect {
    private {
        T _startValue, _endValue;
        SplineFunc _splineFunc;
    }

    this(T startValue, T endValue, SplineFunc splineFunc) {
        _startValue = startValue;
        _endValue = endValue;
        _splineFunc = splineFunc;
    }

    override void update(Particle particle) {
        float t = getProgress(particle.frame);
        mixin("particle.", FieldName, " = lerp(_startValue, _endValue, _splineFunc(t));");
    }
}

alias SpeedParticleEffect = OnceParticleEffect!(float, "speed");
alias SpeedIntervalParticleEffect = IntervalParticleEffect!(float, "speed");
alias AngleParticleEffect = OnceParticleEffect!(float, "angle");
alias AngleIntervalParticleEffect = IntervalParticleEffect!(float, "angle");
alias SpinParticleEffect = OnceParticleEffect!(float, "spin");
alias SpinIntervalParticleEffect = IntervalParticleEffect!(float, "spin");
alias PivotAngleParticleEffect = OnceParticleEffect!(float, "pivotAngle");
alias PivotAngleIntervalParticleEffect = IntervalParticleEffect!(float, "pivotAngle");
alias PivotSpinParticleEffect = OnceParticleEffect!(float, "pivotSpin");
alias PivotSpinIntervalParticleEffect = IntervalParticleEffect!(float, "pivotSpin");
alias PivotDistanceParticleEffect = OnceParticleEffect!(float, "pivotDistance");
alias PivotDistanceIntervalParticleEffect = IntervalParticleEffect!(float, "pivotDistance");
alias SpriteAngleParticleEffect = OnceParticleEffect!(float, "spriteAngle");
alias SpriteAngleIntervalParticleEffect = IntervalParticleEffect!(float, "spriteAngle");
alias SpriteSpinParticleEffect = OnceParticleEffect!(float, "spriteSpin");
alias SpriteSpinIntervalParticleEffect = IntervalParticleEffect!(float, "spriteSpin");
alias ScaleParticleEffect = OnceParticleEffect!(Vec2f, "scale");
alias ScaleIntervalParticleEffect = IntervalParticleEffect!(Vec2f, "scale");
alias ColorParticleEffect = OnceParticleEffect!(Color, "color");
alias ColorIntervalParticleEffect = IntervalParticleEffect!(Color, "color");
alias AlphaParticleEffect = OnceParticleEffect!(float, "alpha");
alias AlphaIntervalParticleEffect = IntervalParticleEffect!(float, "alpha");
