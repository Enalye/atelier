module atelier.world.entity.shot;

import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.render;
import atelier.world.entity.base;
import atelier.world.entity.controller;

final class Shot : Entity, Resource!Shot {
    mixin EntityController;

    private {
        bool _hasTtl;
        uint _ttl, _time, _delay;
        bool _hasBounces;
        uint _bounces, _currentBounce;

        enum State {
            spawn,
            normal,
            fading,
            impact
        }

        State _state = State.spawn;
        Timer _stateTimer;
        bool _isGrazed = false;
    }

    @property {
        bool isGrazed() const {
            return _isGrazed;
        }

        bool isGrazed(bool value) {
            return _isGrazed = value;
        }
    }

    this() {
    }

    this(Shot other) {
        super(other);
        _hasTtl = other._hasTtl;
        _ttl = other._ttl;
        _hasBounces = other._hasBounces;
        _bounces = other._bounces;
        _shadow = false;

        _stateTimer.start(_delay);
        _state = State.spawn;
    }

    Shot fetch() {
        return new Shot(this);
    }

    void setupCollider(Vec3u size_) {
        if (_collider) {
            _collider.setEntity(null);
            _collider.unregister();
        }
        _collider = new ShotCollider(size_);
        _collider.setEntity(this);
    }

    ShotCollider getCollider() {
        return cast(ShotCollider) _collider;
    }

    void setTtl(bool hasTtl_, uint ttl_) {
        _hasTtl = hasTtl_;
        _ttl = ttl_;
    }

    void setBounces(bool hasBounces_, uint bounces_) {
        _hasBounces = hasBounces_;
        _bounces = bounces_;
    }

    void setDelay(uint delay_) {
        _delay = delay_;

        // evil hack :)
        _stateTimer.start(_delay);
    }

    override void onCollide(Physics.CollisionHit hit) {
        final switch (hit.type) with (Physics.CollisionHit.Type) {
        case none:
            _currentBounce++;

            if (_hasBounces && _currentBounce > _bounces) {
                if (_hurtbox)
                    _hurtbox.unregister();
                if (_collider)
                    _collider.unregister();
                isRegistered = false;
            }
            else {
                Vec3f normal = cast(Vec3f) hit.normal;
                normal.z = 0f;

                if (normal.lengthSquared() > 0f) {
                    Vec3f bounceVec = _velocity.dot(normal) * normal;
                    _velocity += -2f * bounceVec;
                    angle = radToDeg(_velocity.xy.angle());
                }
            }
            break;
        case squish:
            isRegistered = false;
            break;
        case impact:
            if (_hurtbox)
                _hurtbox.unregister();
            if (_collider)
                _collider.unregister();
            _state = State.impact;
            _stateTimer.start(30);
            break;
        }
    }

    override void updateMovement() {
        _stateTimer.update();

        final switch (_state) with (State) {
        case spawn:
            if (_stateTimer.isRunning) {
                if (_graphic) {
                    float alpha = lerp(0f, 1f, easeInOutSine(_stateTimer.value01));
                    Vec2f scale = Vec2f.one * lerp(2f, 1f, easeInOutSine(_stateTimer.value01));
                    _graphic.setAlpha(alpha);
                    _graphic.setScale(scale);
                }
            }
            else {
                _state = State.normal;

                if (_graphic) {
                    _graphic.setAlpha(1f);
                    _graphic.setScale(Vec2f.one);
                }

                if (_hasTtl) {
                    _stateTimer.start(_ttl);
                }
            }
            break;
        case normal:
            if (_hasTtl && !_stateTimer.isRunning) {
                _state = State.fading;
                _stateTimer.start(30);
                setGraphic("fading");

                if (_hurtbox)
                    _hurtbox.unregister();
                if (_collider)
                    _collider.unregister();
                setShadow(false);
            }
            _velocity += _acceleration;
            move(_velocity);
            break;
        case fading:
            if (!_stateTimer.isRunning) {
                isRegistered = false;
            }
            else {
                float alpha = lerp(1f, 0f, easeInOutSine(_stateTimer.value01));

                if (_graphic) {
                    _graphic.setAlpha(alpha);
                }
            }
            _velocity += _acceleration;
            move(_velocity);
            break;
        case impact:
            if (!_stateTimer.isRunning) {
                isRegistered = false;
            }
            else {
                float alpha = lerp(1f, 0f, easeInOutSine(_stateTimer.value01));
                Vec2f scale = Vec2f.one * lerp(1f, 2f, easeInOutSine(_stateTimer.value01));

                if (_graphic) {
                    _graphic.setAlpha(alpha);
                    _graphic.setScale(scale);
                    _graphic.setBlend(Blend.additive);
                }
            }
            _velocity += _acceleration;
            move(_velocity);
            break;
        }
    }
}
