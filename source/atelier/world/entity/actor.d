module atelier.world.entity.actor;

import std.math;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.world.behavior;
import atelier.world.entity.base;
import atelier.world.entity.effect;

final class Actor : Entity, Resource!Actor {
    private {
        bool _isHovering;
        float _hoverHeight, _currentHoverHeight;
        float _gravity = 0.8f;
        float _frictionBrake = 1f;
        Behavior _behavior;
        bool _isPlayer;
    }

    @property {
        bool isHovering() const {
            return _isHovering;
        }

        bool isHovering(bool value) {
            if (_isHovering == value)
                return _isHovering;

            if (!_isHovering) {
                _isHovering = true;
                move(Vec3f(0f, 0f, 1f));
                _hoverHeight = max(getAltitude(), getBaseZ() + 6);
            }
            else {
                _isHovering = false;
            }

            return _isHovering;
        }

        bool isPlayer() const {
            return _isPlayer;
        }

        bool isPlayer(bool value) {
            return _isPlayer = value;
        }
    }

    this() {

    }

    this(Actor other) {
        super(other);
    }

    Actor fetch() {
        return new Actor(this);
    }

    void setGravity(float value) {
        _gravity = value;
    }

    void setFrictionBrake(float value) {
        _frictionBrake = value;
    }

    void setupCollider(Vec3u size_) {
        if (_collider) {
            _collider.setEntity(null);
        }
        _collider = new ActorCollider(size_);

        if (_collider) {
            _collider.setEntity(this);
        }
    }

    ActorCollider getCollider() {
        return cast(ActorCollider) _collider;
    }

    void setBehavior(Behavior behavior) {
        if (_behavior) {
            _behavior.unregister();
        }
        _behavior = behavior;
    }

    override void onCollide(Physics.CollisionHit hit) {
        final switch (hit.type) with (Physics.CollisionHit.Type) {
        case none:
            Vec3f normal = hit.normal;
            if (normal.lengthSquared() > 0f) {
                Vec3f bounceVec = _velocity.dot(normal) * normal;
                float bounciness = hit.solid ? hit.solid.bounciness : 0f;
                _velocity += -(1f + bounciness) * bounceVec;
            }
            if (normal.z > 0f) {
                _velocity.z = 0f;

                if (hit.solid && _collider) {
                    _baseZ = hit.solid.getBaseZ(cast(ActorCollider) _collider);
                    _baseMaterial = hit.solid.entity.getMaterial();
                }
                else {
                    _baseMaterial = Atelier.world.scene.getMaterial(_position);
                }
            }
            break;
        case squish:
            break;
        case impact:
            _velocity = Vec3f(hit.normal.xy * 2.5f, _velocity.z);
            setEffect(new FlashEffect(Color.white, 1f, 0, 30, Spline.sineInOut));

            if (_isPlayer) {
                Atelier.slowDown(0.2f, 5, 30, Spline.sineInOut, Spline.sineInOut);
                Atelier.world.camera.shake(1f);
                Atelier.world.camera.zoom(1.1f, 0, Spline.linear);
                Atelier.world.camera.zoom(1f, 30, Spline.sineInOut);
                Atelier.world.camera.blur(2f, 0, Spline.sineInOut);
                Atelier.world.camera.blur(0f, 30, Spline.sineInOut);
            }

            if (_behavior) {
                _behavior.onImpact();
            }
            break;
        }
    }

    override void updateMovement() {
        float maxSpeed = 2.5f;
        float accelSpeed = 1f;
        float friction = 1f;
        Vec2f velocity2d = _velocity.xy;
        Vec2f acceleration2d = _acceleration.xy;
        float accelFriction = friction;

        int baseZ = getBaseZ();

        if (_position.z < baseZ) {
            //_velocity.z = 0f;
            _position.z = baseZ;
        }
        else if (_position.z > baseZ) {
            friction = 0.2f;

            if (_isHovering) {
                accelFriction = 2f;
                maxSpeed = 1f;
                accelSpeed = 1f;
            }
            else {
                _velocity.z -= _gravity;
                accelFriction = 0.2f;
            }
        }

        Vec2f frictionVel = velocity2d * friction * 0.2f * _frictionBrake;

        if (abs(velocity2d.x) < 0.02f && acceleration2d.x == 0f)
            velocity2d.x = 0f;

        if (abs(velocity2d.y) < 0.02f && acceleration2d.y == 0f)
            velocity2d.y = 0f;

        float velLen = _velocity.length();
        if (velLen <= maxSpeed) {
            float dot = acceleration2d.dot(frictionVel);
            if (dot >= 0f) {
                frictionVel -= acceleration2d * dot;
            }
        }
        acceleration2d = acceleration2d * (accelFriction * accelSpeed * 10f / 60f);
        velocity2d = velocity2d + acceleration2d;

        float m = max(velLen, maxSpeed);
        float nm = _velocity.length();
        if (nm > m) {
            _velocity *= m / nm;
        }

        float zFriction = _velocity.z * 0.1f;
        if (_isHovering) {
            if (isOnGround()) {
                move(Vec3f(0f, 0f, 1f));
            }
            _hoverHeight = approach(_hoverHeight, getBaseZ() + 6, 0.1f);
            float zDelta = _hoverHeight - _position.z;
            if (abs(zDelta) > 0.02f) {
                _acceleration.z = zDelta / 500f;
            }
            else {
                _velocity.z = 0f;
            }
            zFriction = 0f;
        }

        _velocity.z += _acceleration.z * accelFriction;
        _acceleration = Vec3f(acceleration2d, _acceleration.z);
        _velocity = Vec3f(velocity2d - frictionVel, _velocity.z - zFriction);

        move(_velocity);
    }

    override void update() {
    }
}
