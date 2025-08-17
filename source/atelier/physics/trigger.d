module atelier.physics.trigger;

import std.algorithm : canFind;
import std.conv : to;
import std.math;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.physics.actor;
import atelier.physics.collider;
import atelier.physics.system;

final class TriggerCollider : Collider {
    private {
        bool _isActiveOnce;
        bool _isActive;
    }

    @property {
        bool isActiveOnce() const {
            return _isActiveOnce;
        }

        bool isActiveOnce(bool value) {
            return _isActiveOnce = value;
        }

        bool isActive() const {
            return _isActive;
        }

        bool isActive(bool value) {
            return _isActive = value;
        }
    }

    this(Vec3u size_) {
        super(size_);
        _type = Type.trigger;
    }

    this(TriggerCollider other) {
        super(other);
    }

    override Collider fetch() {
        return new TriggerCollider(this);
    }

    override void moveTile(Vec3i moveDir, Physics.CollisionHit.Type type = Physics
            .CollisionHit.Type.none) {
    }

    override void move(Vec3f moveDir,
        Physics.CollisionHit.Type hitType = Physics.CollisionHit.Type.none) {
        entity.moveRaw(moveDir);
    }
}
