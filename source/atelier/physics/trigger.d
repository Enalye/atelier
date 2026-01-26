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
        bool _isActiveOnce = true;
        bool _isActive = true;
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

    override bool move(Vec3f moveDir,
        Physics.CollisionHit.Type hitType = Physics.CollisionHit.Type.none) {
        entity.moveRaw(moveDir);
        return true;
    }

    /// Vérifie s’il y a collision avec ce déclencheur
    bool collidesWith(Vec3i point_, Vec3i hitbox_) {
        point_.x -= hitbox_.x - (hitbox_.x >> 1);
        point_.y -= hitbox_.y - (hitbox_.y >> 1);

        if (!((left < (point_.x + hitbox_.x)) && (up < (point_.y + hitbox_.y)) &&
                (bottom < (point_.z + hitbox_.z)) && (right > point_.x) && (down > point_.y)
                && (top > point_.z)))
            return false;

        return true;
    }
}
