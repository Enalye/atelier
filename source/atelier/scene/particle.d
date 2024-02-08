/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.scene.particle;

import std.random;
import atelier.common;
import atelier.render;
import atelier.scene.entity;

private final class Particle {
    int frame, ttl;

    Vec2f origin = Vec2f.zero;
    Vec2f position = Vec2f.zero;
    float speed = 0f;

    float angle = 0f;
    float angleSpeed = 0f;

    Vec2f pivot = Vec2f.zero;
    float pivotAngle = 0f;
    float pivotAngleSpeed = 0f;
    float pivotDistance = 0f;

    void update() {
        pivotAngle += pivotAngleSpeed;
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

abstract class ParticleSource {
    private {
        Array!Particle _particles;
        ParticleEffect[] _effects;

        Sprite _sprite;

        bool _isAlive = true;
        bool _isRelativePosition;
        Vec2f _position = Vec2f.zero;
        Entity _attachedEntity;
        uint _interval;
        int _emitterTime;
        uint _minCount, _maxCount;
        uint _minLifetime, _maxLifetime;
    }

    @property {
        bool isAlive() const {
            return _isAlive;
        }
    }

    this() {
        _particles = new Array!Particle;
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
            origin = _position;
            if (_attachedEntity) {
                origin += _attachedEntity.scenePosition();
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
        Vec2f origin = _position;
        if (_attachedEntity) {
            origin += _attachedEntity.scenePosition();
        }
        return origin;
    }

    void draw(Vec2f origin) {
        if (!_sprite)
            return;

        foreach (particle; _particles) {
            _sprite.draw(origin + particle.origin + particle.position + particle.pivot);
        }
    }

    final void start(uint interval) {
        _interval = interval;
        _emitterTime = _interval;
        emit();
    }

    final void stop() {
        _interval = 0;
        _emitterTime = 0;
    }

    final void clear() {
        _particles.clear();
    }

    final void remove() {
        _isAlive = false;
    }

    void emit();

    final void setSprite(Sprite sprite) {
        _sprite = sprite;
    }

    final void setRelativePosition(bool isRelative) {
        _isRelativePosition = isRelative;
    }

    final void setLifetime(uint minLifetime, uint maxLifetime) {
        _minLifetime = minLifetime;
        _maxLifetime = maxLifetime;
    }

    final void setCount(uint minCount, uint maxCount) {
        _minCount = minCount;
        _maxCount = maxCount;
    }

    final void attachTo(Entity entity) {
        _attachedEntity = entity;
    }
}

final class CircularParticleSource : ParticleSource {
    private {
        float _minAngle = 0f, _maxAngle = 0f, _spreadAngle = 0f;
        float _minDistance = 0f, _maxDistance = 0f;
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

    override void emit() {
        uint particleCount = uniform!"[]"(_minCount, _maxCount);
        float distance = uniform!"[]"(_minDistance, _maxDistance);
        float angle = uniform!"[]"(_minAngle, _maxAngle) - (_spreadAngle / 2f);
        float spreadPerParticle = _spreadAngle / particleCount;

        for (int i; i < particleCount; ++i) {
            Particle particle = new Particle;
            particle.origin = getOrigin();
            particle.position = Vec2f.angled(angle) * distance;
            particle.angle = angle;
            particle.pivotAngle = angle;
            particle.ttl = uniform!"[]"(_minLifetime, _maxLifetime);
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
        mixin("particle.", FieldName, " = uniform!\"[]\"(_minValue, _maxValue);");
    }
}

final class IntervalParticleEffect(T, string FieldName) : ParticleEffect {
    private {
        float _startValue, _endValue;
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
alias AngleSpeedParticleEffect = OnceParticleEffect!(float, "angleSpeed");
alias AngleSpeedIntervalParticleEffect = IntervalParticleEffect!(float, "angleSpeed");
alias PivotAngleParticleEffect = OnceParticleEffect!(float, "pivotAngle");
alias PivotAngleIntervalParticleEffect = IntervalParticleEffect!(float, "pivotAngle");
alias PivotAngleSpeedParticleEffect = OnceParticleEffect!(float, "pivotAngleSpeed");
alias PivotAngleSpeedIntervalParticleEffect = IntervalParticleEffect!(float, "pivotAngleSpeed");
alias PivotDistanceParticleEffect = OnceParticleEffect!(float, "pivotDistance");
alias PivotDistanceIntervalParticleEffect = IntervalParticleEffect!(float, "pivotDistance");
