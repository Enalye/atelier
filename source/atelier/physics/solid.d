module atelier.physics.solid;

import std.algorithm : canFind;
import std.conv : to;
import std.math;

import atelier.common;
import atelier.core;
import atelier.physics.actor;
import atelier.physics.collider;
import atelier.physics.system;

final class SolidCollider : Collider {
    enum Shape {
        box,
        slopeUp,
        slopeDown,
        slopeLeft,
        slopeRight,
    }

    private {
        bool _isTempCollidable = true;
        bool _isCollidable = true;
        float _bounciness = 0f;
        Shape _shape = Shape.box;
    }

    @property {
        float bounciness() const {
            return _bounciness;
        }

        float bounciness(float bounciness_) {
            return _bounciness = bounciness_;
        }

        Shape shape() const {
            return _shape;
        }
    }

    this(Vec3u size_, string shape_, float bounciness_) {
        super(size_);
        _type = Type.solid;
        try {
            _shape = to!Shape(shape_);
        }
        catch (Exception e) {
            Atelier.log(shape_, " n’est pas une forme de solide valide");
            _shape = Shape.box;
        }
        _bounciness = bounciness_;
    }

    this(SolidCollider other) {
        super(other);
        _isCollidable = other._isCollidable;
        _shape = other._shape;
        _bounciness = other._bounciness;
    }

    override Collider fetch() {
        return new SolidCollider(this);
    }

    override void moveTile(Vec3i moveDir, Physics.CollisionHit.Type type = Physics
            .CollisionHit.Type.none) {
    }

    override void move(Vec3f moveDir, Physics.CollisionHit.Type type = Physics
            .CollisionHit.Type.none) {
        Vec3f _moveRemaining = entity.getSubPosition() + moveDir;
        Vec3i _position = entity.getPosition();

        int moveX = cast(int) round(_moveRemaining.x);
        int moveY = cast(int) round(_moveRemaining.y);
        int moveZ = cast(int) round(_moveRemaining.z);

        if (moveX || moveY || moveZ) {
            const ActorCollider[] ridingActors = getAllRidingActors();

            _isTempCollidable = false;

            if (moveX) {
                _moveRemaining.x -= moveX;
                _position.x += moveX;
                entity.setPositionRaw(_position, _moveRemaining);

                if (moveX > 0) {
                    foreach (ActorCollider actor; Atelier.physics.getAllActors()) {
                        Physics.SolidHit solidHit = overlapsWith(actor);
                        if (solidHit.isColliding) {
                            actor.move(Vec3f(right - actor.left, 0, 0),
                                Physics.CollisionHit.Type.squish);
                        }
                        else if (ridingActors.canFind(actor)) {
                            actor.move(Vec3f(moveX, 0, 0), Physics.CollisionHit.Type.none);
                        }
                    }
                }
                else {
                    foreach (ActorCollider actor; Atelier.physics.getAllActors()) {
                        Physics.SolidHit solidHit = overlapsWith(actor);
                        if (solidHit.isColliding) {
                            actor.move(Vec3f(left - actor.right, 0, 0),
                                Physics.CollisionHit.Type.squish);
                        }
                        else if (ridingActors.canFind(actor)) {
                            actor.move(Vec3f(moveX, 0, 0), Physics.CollisionHit.Type.none);
                        }
                    }
                }
            }

            if (moveY) {
                _moveRemaining.y -= moveY;
                _position.y += moveY;
                entity.setPositionRaw(_position, _moveRemaining);

                if (moveY > 0) {
                    foreach (ActorCollider actor; Atelier.physics.getAllActors()) {
                        Physics.SolidHit solidHit = overlapsWith(actor);
                        if (solidHit.isColliding) {
                            actor.move(Vec3f(0, up - actor.down, 0),
                                Physics.CollisionHit.Type.squish);
                        }
                        else if (ridingActors.canFind(actor)) {
                            actor.move(Vec3f(0, moveY, 0), Physics.CollisionHit.Type.none);
                        }
                    }
                }
                else {
                    foreach (ActorCollider actor; Atelier.physics.getAllActors()) {
                        Physics.SolidHit solidHit = overlapsWith(actor);
                        if (solidHit.isColliding) {
                            actor.move(Vec3f(0, down - actor.up, 0),
                                Physics.CollisionHit.Type.squish);
                        }
                        else if (ridingActors.canFind(actor)) {
                            actor.move(Vec3f(0, moveY, 0), Physics.CollisionHit.Type.none);
                        }
                    }
                }
            }

            if (moveZ) {
                _moveRemaining.z -= moveZ;
                _position.z += moveZ;
                entity.setPositionRaw(_position, _moveRemaining);

                if (moveZ > 0) {
                    foreach (ActorCollider actor; Atelier.physics.getAllActors()) {
                        Physics.SolidHit solidHit = overlapsWith(actor);
                        if (solidHit.isColliding) {
                            actor.move(Vec3f(0, top - actor.bottom, 0),
                                Physics.CollisionHit.Type.squish);
                        }
                        else if (ridingActors.canFind(actor)) {
                            actor.move(Vec3f(0, 0, moveZ), Physics.CollisionHit.Type.none);
                        }
                    }
                }
                else {
                    foreach (ActorCollider actor; Atelier.physics.getAllActors()) {
                        Physics.SolidHit solidHit = overlapsWith(actor);
                        if (solidHit.isColliding) {
                            actor.move(Vec3f(0, bottom - actor.top, 0),
                                Physics.CollisionHit.Type.squish);
                        }
                        else if (ridingActors.canFind(actor)) {
                            actor.move(Vec3f(0, 0, moveZ), Physics.CollisionHit.Type.none);
                        }
                    }
                }
            }

            _isTempCollidable = true;
        }
    }

    ActorCollider[] getAllRidingActors() {
        ActorCollider[] ridingActors;

        foreach (actor; Atelier.physics.getAllActors()) {
            if (actor.isRiding(this)) {
                ridingActors ~= actor;
            }
        }

        return ridingActors;
    }

    /// Vérifie s’il y a collision entre ce solide et une boite
    Physics.SolidHit collidesWith(Vec3i point_, Vec3i hitbox_) {
        Physics.SolidHit hit;
        hit.solid = this;

        if (!_isTempCollidable || !_isCollidable) {
            return hit;
        }

        point_.x -= hitbox_.x - (hitbox_.x >> 1);
        point_.y -= hitbox_.y - (hitbox_.y >> 1);

        if (!((left < (point_.x + hitbox_.x)) && (up < (point_.y + hitbox_.y)) &&
                (bottom < (point_.z + hitbox_.z)) && (right > point_.x) && (down > point_.y)))
            return hit;

        final switch (_shape) with (Shape) {
        case box:
            hit.baseZ = top;
            break;
        case slopeUp:
            float t = clamp((point_.y - up) / cast(float) hitbox.y, 0f, 1f);
            hit.baseZ = cast(int) round(lerp(cast(float) top, cast(float) bottom, t));
            break;
        case slopeDown:
            float t = clamp((down - (point_.y + hitbox_.y)) / cast(float) hitbox.y, 0f, 1f);
            hit.baseZ = cast(int) round(lerp(cast(float) top, cast(float) bottom, t));
            break;
        case slopeLeft:
            float t = clamp((point_.x - left) / cast(float) hitbox.x, 0f, 1f);
            hit.baseZ = cast(int) round(lerp(cast(float) top, cast(float) bottom, t));
            break;
        case slopeRight:
            float t = clamp((right - (point_.x + hitbox_.x)) / cast(float) hitbox.x, 0f, 1f);
            hit.baseZ = cast(int) round(lerp(cast(float) top, cast(float) bottom, t));
            break;
        }

        hit.isColliding = hit.baseZ > point_.z;
        return hit;
    }

    /// Vérifie si un acteur est à l’intérieur du solide
    Physics.SolidHit overlapsWith(ActorCollider actor) {
        Physics.SolidHit hit;
        hit.solid = this;

        if (!_isCollidable) {
            return hit;
        }

        if (!((left < actor.right) && (up < actor.down) && (bottom < actor.top) &&
                (right > actor.left) && (down > actor.up)))
            return hit;

        final switch (_shape) with (Shape) {
        case box:
            hit.baseZ = top;
            break;
        case slopeUp:
            float t = clamp((actor.up - up) / cast(float) hitbox.y, 0f, 1f);
            hit.baseZ = cast(int) round(lerp(cast(float) top, cast(float) bottom, t));
            break;
        case slopeDown:
            float t = clamp((down - actor.down) / cast(float) hitbox.y, 0f, 1f);
            hit.baseZ = cast(int) round(lerp(cast(float) top, cast(float) bottom, t));
            break;
        case slopeLeft:
            float t = clamp((actor.left - left) / cast(float) hitbox.x, 0f, 1f);
            hit.baseZ = cast(int) round(lerp(cast(float) top, cast(float) bottom, t));
            break;
        case slopeRight:
            float t = clamp((right - actor.right) / cast(float) hitbox.x, 0f, 1f);
            hit.baseZ = cast(int) round(lerp(cast(float) top, cast(float) bottom, t));
            break;
        }

        hit.isColliding = hit.baseZ > actor.bottom;
        return hit;
    }

    int getBaseZ(ActorCollider actor) {
        if (!_isCollidable) {
            return -16;
        }

        if (!((left < actor.right) && (up < actor.down) && (bottom < actor.top) &&
                (right > actor.left) && (down > actor.up)))
            return -16;

        final switch (_shape) with (Shape) {
        case box:
            return top;
        case slopeUp:
            float t = clamp((actor.up - up) / cast(float) hitbox.y, 0f, 1f);
            return cast(int) round(lerp(cast(float) top, cast(float) bottom, t));
        case slopeDown:
            float t = clamp((down - actor.down) / cast(float) hitbox.y, 0f, 1f);
            return cast(int) round(lerp(cast(float) top, cast(float) bottom, t));
        case slopeLeft:
            float t = clamp((actor.left - left) / cast(float) hitbox.x, 0f, 1f);
            return cast(int) round(lerp(cast(float) top, cast(float) bottom, t));
        case slopeRight:
            float t = clamp((right - actor.right) / cast(float) hitbox.x, 0f, 1f);
            return cast(int) round(lerp(cast(float) top, cast(float) bottom, t));
        }
    }
}
