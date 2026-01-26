module atelier.world.particle;

import std.random;
import std.math;
import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world.scene;
import atelier.world.system;
import atelier.world.entity;

/+
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
}

enum ParticleMode {
    spread,
    rectangle,
    ellipsis
}

final class ParticleSource : Resource!ParticleSource {
    private {
        Array!Particle _particles;
        ParticleEffect[] _effects;

        Sprite _sprite;
        Vec2f _spriteSize = Vec2f.one;

        bool _isVisible = true;
        bool _isRelativePosition;
        bool _isRelativeSpriteAngle;
        bool _isAttachedToCamera;
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
        Vec2f _origin = Vec2f.zero;
    }

    Vec2f position = Vec2f.zero;
    string name;
    string[] tags;

    @property {
        bool isVisible() const {
            return _isVisible;
        }

        bool isVisible(bool isVisible_) {
            return _isVisible = isVisible_;
        }
    }

    this() {
        _particles = new Array!Particle;
    }

    this(ParticleSource source) {
        _particles = new Array!Particle;

        _emitterTime = 0;
        _interval = 0;

        // Les effets n’ont pas d’état interne,
        // on peut se permettre une copie superficielle.
        _effects = source._effects;

        position = source.position;
        name = source.name;
        tags = source.tags;

        _sprite = new Sprite(source._sprite);
        _spriteSize = source._spriteSize;

        _isRelativePosition = source._isRelativePosition;
        _isRelativeSpriteAngle = source._isRelativeSpriteAngle;
        _minCount = source._minCount;
        _maxCount = source._maxCount;
        _minLifetime = source._minLifetime;
        _maxLifetime = source._maxLifetime;

        _blend = source._blend;
        _mode = source._mode;
        _minAngle = source._minAngle;
        _maxAngle = source._maxAngle;
        _spreadAngle = source._spreadAngle;
        _minDistance = source._minDistance;
        _maxDistance = source._maxDistance;
        _area = source._area;
    }

    ParticleSource fetch() {
        return new ParticleSource(this);
    }

    void addEffect(ParticleEffect effect) {
        _effects ~= effect;
    }

    void clearEffects() {
        _effects.length = 0;
    }

    void update(Vec2f offset) {
        if (_interval > 0) {
            _emitterTime--;
            if (_emitterTime <= 0) {
                _emitterTime = _interval;
                emit();
            }
        }

        _origin = position + offset;
        /*if (_isRelativePosition) {
            origin += position;
            if (_attachedEntity) {
                origin += _attachedEntity.scenePosition();
            }
            else if (_isAttachedToCamera && scene) {
                origin += scene.globalPosition;
            }
        }*/

        foreach (i, particle; _particles) {
            foreach (ParticleEffect effect; _effects) {
                if (particle.frame >= effect.getStartFrame() &&
                    particle.frame <= effect.getEndFrame()) {
                    effect.update(particle);
                }
            }
            if (_isRelativePosition)
                particle.origin = _origin;
            particle.update();

            if (particle.frame > particle.ttl) {
                _particles.mark(i);
            }
        }
        _particles.sweep();
    }

    void draw(Vec2f origin) {
        if (!_sprite || !_isVisible)
            return;

        _sprite.blend = _blend;
        foreach (particle; _particles) {
            _sprite.color = particle.color;
            _sprite.alpha = particle.alpha;
            _sprite.size = particle.scale * _spriteSize;
            if (_isRelativeSpriteAngle) {
                _sprite.angle = particle.angle + particle.spriteAngle;
            }
            else {
                _sprite.angle = particle.spriteAngle;
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
        /*if (scene) {
            scene.removeParticleSource(this);
        }*/
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

    void setSprite(string rid) {
        _sprite = Atelier.res.get!Sprite(rid);
        _spriteSize = _sprite.size;
    }

    void setSprite(Sprite sprite) {
        _sprite = sprite;
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
    /*
    void attachTo(EntityID entity) {
        _isAttachedToCamera = false;
        //_attachedEntity = entity;
    }

    void attachToCamera() {
        _isAttachedToCamera = true;
        //_attachedEntity = null;
    }*/

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
        _minAngle = degToRad(minAngle);
        _maxAngle = degToRad(maxAngle);
        _spreadAngle = degToRad(spreadAngle);
    }

    private void _emitSpread() {
        uint particleCount = Atelier.rng.rand(_minCount, _maxCount);
        float distance = Atelier.rng.rand(_minDistance, _maxDistance);
        float angle = Atelier.rng.rand(_minAngle, _maxAngle) - (_spreadAngle / 2f);
        float spreadPerParticle = _spreadAngle / particleCount;

        for (int i; i < particleCount; ++i) {
            Particle particle = new Particle;
            particle.origin = _origin;
            particle.position = Vec2f.angled(angle) * distance;
            particle.angle = angle;
            particle.pivotAngle = angle;
            particle.ttl = Atelier.rng.rand(_minLifetime, _maxLifetime);
            _particles ~= particle;

            angle += spreadPerParticle;
        }
    }

    private void _emitRectangle() {
        uint particleCount = Atelier.rng.rand(_minCount, _maxCount);
        float angle = Atelier.rng.rand(_minAngle, _maxAngle) - (_spreadAngle / 2f);
        float spreadPerParticle = _spreadAngle / particleCount;

        Vec2f offset = -_area / 2f;
        for (int i; i < particleCount; ++i) {
            float x = Atelier.rng.rand01();
            float y = Atelier.rng.rand01();

            Particle particle = new Particle;
            particle.origin = _origin;
            particle.position = Vec2f(x, y) * _area + offset;
            particle.angle = angle;
            particle.pivotAngle = angle;
            particle.ttl = Atelier.rng.rand(_minLifetime, _maxLifetime);
            _particles ~= particle;

            angle += spreadPerParticle;
        }
    }

    private void _emitEllipsis() {
        uint particleCount = Atelier.rng.rand(_minCount, _maxCount);
        float angle = Atelier.rng.rand(_minAngle, _maxAngle) - (_spreadAngle / 2f);
        float spreadPerParticle = _spreadAngle / particleCount;

        for (int i; i < particleCount; ++i) {
            float phi = Atelier.rng.rand01() * PI * 2f;
            float rho = Atelier.rng.rand01();
            Vec2f pos = sqrt(rho) * Vec2f.angled(phi);

            Particle particle = new Particle;
            particle.origin = _origin;
            particle.position = pos * _area / 2f;
            particle.angle = angle;
            particle.pivotAngle = angle;
            particle.ttl = Atelier.rng.rand(_minLifetime, _maxLifetime);
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
        mixin("particle.", FieldName, " = lerp(_minValue, _maxValue, Atelier.rng.rand01());");
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
+/
