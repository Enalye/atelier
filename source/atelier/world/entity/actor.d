module atelier.world.entity.actor;

import std.math;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.world.entity.base;
import atelier.world.entity.controller;
import atelier.world.entity.effect;

final class Actor : Entity, Resource!Actor {
    mixin EntityController;

    private {
        bool _isHovering;
        float _hoverHeight, _currentHoverHeight;
        float _gravity = 0.8f;
        float _frictionBrake = 1f;
        bool _isPlayer;
        Repulsor _repulsor;
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

        if (other._repulsor) {
            _repulsor = new Repulsor(other._repulsor);
            _repulsor.setEntity(this);
        }
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

    void setupCollider(Vec3u size_, float bounciness) {
        if (_collider) {
            _collider.setEntity(null);
        }
        _collider = new ActorCollider(size_, bounciness);

        if (_collider) {
            _collider.setEntity(this);
        }
    }

    ActorCollider getCollider() {
        return cast(ActorCollider) _collider;
    }

    void setupRepulsor(RepulsorData data) {
        if (_repulsor) {
            _repulsor.unregister();
            _repulsor = null;
        }

        if (data.type == "none")
            return;

        _repulsor = new Repulsor(this, data);
    }

    Repulsor getRepulsor() {
        return _repulsor;
    }

    override void onCollide(Physics.CollisionHit hit) {
        final switch (hit.type) with (Physics.CollisionHit.Type) {
        case none:
            Vec3f normal = hit.normal;
            if (normal.lengthSquared() > 0f) {
                Vec3f bounceVec = _velocity.dot(normal) * normal;
                float bounciness = hit.solid ? hit.solid.bounciness : 0f;
                bounciness += _collider ? (cast(ActorCollider) _collider).bounciness : 0f;
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
            onHit(hit.normal);
            break;
        case squish:
            onSquish(hit.normal);
            break;
        case impact:
            onImpact(hit.entity, hit.normal);
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
                accelSpeed = 0.4f;
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
        velocity2d += _avoidCliffs(acceleration2d);

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

    private Vec2f _avoidCliffs(Vec2f dir) {
        Vec2f force = Vec2f.zero;

        Collider collider = getCollider();
        if (!collider)
            return force;

        int baseZ = -16;
        Vec2i position = getPosition().xy;

        {
            Physics.TerrainHit result = Atelier.physics.hitTerrain(getPosition(), Vec3i.zero);
            baseZ = result.height;
        }

        Vec3i[4] corners = [
            Vec3i(_collider.left, _collider.up, _collider.bottom),
            Vec3i(_collider.right, _collider.up, _collider.bottom),
            Vec3i(_collider.left, _collider.down, _collider.bottom),
            Vec3i(_collider.right, _collider.down, _collider.bottom)
        ];

        int[4] heights;
        int maxHeight = baseZ;

        for (uint i; i < 4; ++i) {
            Physics.TerrainHit result = Atelier.physics.hitTerrain(corners[i], Vec3i.zero);
            heights[i] = result.height;
            if (result.height > maxHeight)
                maxHeight = result.height;
        }

        if (maxHeight != baseZ) {
            for (uint i; i < 4; ++i) {
                if (heights[i] == maxHeight) {
                    force += (cast(Vec2f)(corners[i].xy - position));
                }
            }
        }

        force.normalize();
        dir.normalize();

        float dot = dir.dot(force);
        if (dot <= 0f) {
            force -= dir * dot;
        }

        return force * 0.2f;
    }

    override void onRegisterEntity() {
        if (_repulsor) {
            _repulsor.register();
        }
    }

    override void onUnregisterEntity() {
        if (_repulsor) {
            _repulsor.unregister();
        }
    }
}
