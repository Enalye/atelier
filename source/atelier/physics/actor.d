module atelier.physics.actor;

import std.math;

import atelier.common;
import atelier.core;
import atelier.physics.system;
import atelier.physics.collider;
import atelier.physics.solid;
import atelier.world;

final class ActorCollider : Collider {
    private {
        SolidCollider _riding;
        float _bounciness = 0f;
    }

    @property {
        float bounciness() const {
            return _bounciness;
        }

        float bounciness(float bounciness_) {
            return _bounciness = bounciness_;
        }
    }

    this(Vec3u size_, float bounciness_) {
        super(size_);
        _type = Type.actor;
        _bounciness = bounciness_;
    }

    this(ActorCollider other) {
        super(other);
        _bounciness = other._bounciness;
    }

    override Collider fetch() {
        return new ActorCollider(this);
    }

    override void moveTile(Vec3i moveDir,
        Physics.CollisionHit.Type type = Physics.CollisionHit.Type.none) {
        if (moveDir == Vec3i.zero)
            return;

        Vec3i stepDir = moveDir.sign();
        Atelier.log("STEP: ", stepDir);

        Vec3i walkDir;
        Vec3i totalMoveDir;
        while (walkDir != moveDir) {
            bool[3] axis;
            Vec3i[3] potentialWalks;

            potentialWalks[0] = walkDir;
            potentialWalks[1] = walkDir;
            potentialWalks[2] = walkDir;
            potentialWalks[0].x += stepDir.x;
            potentialWalks[1].y += stepDir.y;
            potentialWalks[2].z += stepDir.z;

            float[3] dists;

            Vec3f v = cast(Vec3f) moveDir;

            dists[0] = v.cross(cast(Vec3f) potentialWalks[0]).lengthSquared();
            dists[1] = v.cross(cast(Vec3f) potentialWalks[1]).lengthSquared();
            dists[2] = v.cross(cast(Vec3f) potentialWalks[2]).lengthSquared();

            Vec3f maxDir;
            maxDir.x = moveDir.x != 0 ? dists[0] : int.max;
            maxDir.y = moveDir.y != 0 ? dists[1] : int.max;
            maxDir.z = moveDir.z != 0 ? dists[2] : int.max;

            if (maxDir.x < maxDir.y) {
                if (maxDir.x < maxDir.z) {
                    walkDir.x += stepDir.x;
                    axis[0] = true;
                }
                else if (maxDir.x > maxDir.z) {
                    walkDir.z += stepDir.z;
                    axis[2] = true;
                }
                else {
                    walkDir.x += stepDir.x;
                    axis[0] = true;
                    walkDir.z += stepDir.z;
                    axis[2] = true;
                }
            }
            else if (maxDir.x > maxDir.y) {
                if (maxDir.y < maxDir.z) {
                    walkDir.y += stepDir.y;
                    axis[1] = true;
                }
                else if (maxDir.y > maxDir.z) {
                    walkDir.z += stepDir.z;
                    axis[2] = true;
                }
                else {
                    walkDir.y += stepDir.y;
                    axis[1] = true;
                    walkDir.z += stepDir.z;
                    axis[2] = true;
                }
            }
            else {
                if (maxDir.y < maxDir.z) {
                    walkDir.x += stepDir.x;
                    axis[0] = true;
                    walkDir.y += stepDir.y;
                    axis[1] = true;
                }
                else if (maxDir.y > maxDir.z) {
                    walkDir.z += stepDir.z;
                    axis[2] = true;
                }
                else {
                    walkDir.x += stepDir.x;
                    axis[0] = true;
                    walkDir.y += stepDir.y;
                    axis[1] = true;
                    walkDir.z += stepDir.z;
                    axis[2] = true;
                }
            }

            if (axis[0]) {
                Vec3i hitPosition = entity.getTilePosition() + Vec3i(stepDir.x, 0, 0);
                Physics.TerrainHit terrainHit = Atelier.physics.hitTileTerrain(hitPosition, hitbox);
                if (terrainHit.isColliding) {
                    //Physics.CollisionHit data;
                    //data.normal = terrainHit.normal;
                    //data.type = hitType;
                    //entity.onCollide(data);
                }
                else {
                    //_moveTileRaw(entity, Vec3i(stepDir.x, 0, 0), terrainHit.height);
                    totalMoveDir.x += stepDir.x;
                }
            }
            if (axis[1]) {
                Vec3i hitPosition = entity.getTilePosition() + Vec3i(0, stepDir.y, 0);
                Physics.TerrainHit terrainHit = Atelier.physics.hitTileTerrain(hitPosition, hitbox);
                if (terrainHit.isColliding) {
                    //Physics.CollisionHit data;
                    //data.normal = terrainHit.normal;
                    //data.type = hitType;
                    //entity.onCollide(data);
                }
                else {
                    //_moveTileRaw(entity, Vec3i(0, stepDir.y, 0), terrainHit.height);
                    totalMoveDir.y += stepDir.y;
                }
            }
            if (axis[2]) {
                Vec3i hitPosition = entity.getTilePosition() + Vec3i(0, 0, stepDir.z);
                Physics.TerrainHit terrainHit = Atelier.physics.hitTileTerrain(hitPosition, hitbox);
                if (terrainHit.isColliding) {
                    //Physics.CollisionHit data;
                    //data.normal = terrainHit.normal;
                    //data.type = hitType;
                    //entity.onCollide(data);
                }
                else {
                    //_moveTileRaw(entity, Vec3i(0, 0, stepDir.z), terrainHit.height);
                    totalMoveDir.z += stepDir.z;
                }
            }
        }

        if (totalMoveDir != Vec3i.zero) {
            _moveTileRaw(entity, totalMoveDir, 0);
        }
    }

    override bool move(Vec3f moveDir,
        Physics.CollisionHit.Type hitType = Physics.CollisionHit.Type.none) {
        Vec3f subMove = entity.getSubPosition();

        if (moveDir.x >= 10 || moveDir.x <= -10 ||
            moveDir.y >= 10 || moveDir.y <= -10 ||
            moveDir.z >= 10 || moveDir.z <= -10 ||
            isNaN(moveDir.x) || isNaN(moveDir.y) || isNaN(moveDir.z) ||
            isInfinity(moveDir.x) || isInfinity(moveDir.y) || isInfinity(moveDir.z)) {
            Atelier.log("[Atelier] Entité en survitesse: ", moveDir);
            return false;
        }

        subMove += moveDir;
        Vec3i gridMovement = cast(Vec3i) subMove.round();
        subMove -= cast(Vec3f) gridMovement;
        entity.setSubPosition(subMove);

        if (gridMovement == Vec3i.zero)
            return true;

        Vec3i stepDir = gridMovement.sign();

        Vec3i walkDir;
        while (walkDir != gridMovement) {
            bool[3] axis;
            Vec3i[3] potentialWalks;

            potentialWalks[0] = walkDir;
            potentialWalks[1] = walkDir;
            potentialWalks[2] = walkDir;
            potentialWalks[0].x += stepDir.x;
            potentialWalks[1].y += stepDir.y;
            potentialWalks[2].z += stepDir.z;

            float[3] dists;

            Vec3f v = cast(Vec3f) gridMovement;

            dists[0] = v.cross(cast(Vec3f) potentialWalks[0]).lengthSquared();
            dists[1] = v.cross(cast(Vec3f) potentialWalks[1]).lengthSquared();
            dists[2] = v.cross(cast(Vec3f) potentialWalks[2]).lengthSquared();

            Vec3f maxDir;
            maxDir.x = gridMovement.x != 0 ? dists[0] : int.max;
            maxDir.y = gridMovement.y != 0 ? dists[1] : int.max;
            maxDir.z = gridMovement.z != 0 ? dists[2] : int.max;

            if (maxDir.x < maxDir.y) {
                if (maxDir.x < maxDir.z) {
                    walkDir.x += stepDir.x;
                    axis[0] = true;
                }
                else if (maxDir.x > maxDir.z) {
                    walkDir.z += stepDir.z;
                    axis[2] = true;
                }
                else {
                    walkDir.x += stepDir.x;
                    axis[0] = true;
                    walkDir.z += stepDir.z;
                    axis[2] = true;
                }
            }
            else if (maxDir.x > maxDir.y) {
                if (maxDir.y < maxDir.z) {
                    walkDir.y += stepDir.y;
                    axis[1] = true;
                }
                else if (maxDir.y > maxDir.z) {
                    walkDir.z += stepDir.z;
                    axis[2] = true;
                }
                else {
                    walkDir.y += stepDir.y;
                    axis[1] = true;
                    walkDir.z += stepDir.z;
                    axis[2] = true;
                }
            }
            else {
                if (maxDir.y < maxDir.z) {
                    walkDir.x += stepDir.x;
                    axis[0] = true;
                    walkDir.y += stepDir.y;
                    axis[1] = true;
                }
                else if (maxDir.y > maxDir.z) {
                    walkDir.z += stepDir.z;
                    axis[2] = true;
                }
                else {
                    walkDir.x += stepDir.x;
                    axis[0] = true;
                    walkDir.y += stepDir.y;
                    axis[1] = true;
                    walkDir.z += stepDir.z;
                    axis[2] = true;
                }
            }

            if (axis[0]) {
                Vec3i hitPosition = entity.getPosition() + Vec3i(stepDir.x, 0, 0);
                Physics.TerrainHit terrainHit = Atelier.physics.hitTerrain(hitPosition, hitbox);
                if (terrainHit.isColliding) {
                    Physics.CollisionHit data;
                    bool isLeft;
                    switch (terrainHit.shape) with (Physics.Shape) {
                    case slopeLeft:
                    case startSlopeLeft:
                    case middleSlopeLeft:
                    case endSlopeLeft:
                        isLeft = true;
                        goto case slopeRight;
                    case slopeRight:
                    case startSlopeRight:
                    case middleSlopeRight:
                    case endSlopeRight:
                        int deltaZ = terrainHit.height - hitPosition.z;
                        if ((stepDir.x > 0 && isLeft) ||
                            (stepDir.x < 0 && !isLeft)) {
                            goto default;
                        }
                        Physics.SolidHit solidHitUp = Atelier.physics.collidesAt(hitPosition + Vec3i(0,
                                0, deltaZ), hitbox);
                        if (solidHitUp.isColliding) {
                            data.normal = Vec3f(0, 0, deltaZ > 0 ? -1 : 1);
                            data.type = hitType;
                            entity.onCollide(data);
                        }
                        else {
                            entity.moveRaw(Vec3i(stepDir.x, 0, deltaZ),
                                terrainHit.height, Atelier.world.scene.getMaterial(
                                    entity.getPosition()));
                        }
                        break;
                    default:
                        data.normal = terrainHit.normal;
                        data.type = hitType;
                        entity.onCollide(data);
                        break;
                    }
                    break;
                }
                else {
                    Physics.SolidHit solidHit = Atelier.physics.collidesAt(hitPosition, hitbox);
                    if (solidHit.isColliding) {
                        Physics.CollisionHit data;
                        switch (solidHit.solid.shape) with (SolidCollider.Shape) {
                        case slopeLeft:
                        case slopeRight:
                            int deltaZ = solidHit.baseZ - hitPosition.z;
                            if ((stepDir.x > 0 && solidHit.solid.shape == SolidCollider.Shape.slopeLeft) ||
                                (stepDir.x < 0 &&
                                    solidHit.solid.shape == SolidCollider.Shape.slopeRight)) {
                                goto default;
                            }
                            Physics.SolidHit solidHitUp = Atelier.physics.collidesAt(hitPosition + Vec3i(0,
                                    0, deltaZ), hitbox);
                            if (solidHitUp.isColliding) {
                                data.solid = solidHit.solid;
                                data.entity = solidHit.solid.entity;
                                data.normal = Vec3f(0, 0, deltaZ > 0 ? -1 : 1);
                                data.type = hitType;
                                entity.onCollide(data);
                            }
                            else {
                                entity.moveRaw(Vec3i(stepDir.x, 0, deltaZ),
                                    solidHit.baseZ, solidHit.solid.entity.getMaterial());
                            }
                            break;
                        default:
                            data.solid = solidHit.solid;
                            data.entity = solidHit.solid.entity;
                            data.normal = Vec3f(-stepDir.x, 0, 0);
                            data.type = hitType;
                            entity.onCollide(data);
                            break;
                        }
                        break;
                    }
                    else {
                        _moveRaw(entity, Vec3i(stepDir.x, 0, 0), terrainHit.height);
                    }
                }
            }
            if (axis[1]) {
                Vec3i hitPosition = entity.getPosition() + Vec3i(0, stepDir.y, 0);
                Physics.TerrainHit terrainHit = Atelier.physics.hitTerrain(hitPosition, hitbox);
                if (terrainHit.isColliding) {
                    Physics.CollisionHit data;
                    bool isUp;
                    switch (terrainHit.shape) with (Physics.Shape) {
                    case slopeUp:
                    case startSlopeUp:
                    case middleSlopeUp:
                    case endSlopeUp:
                        isUp = true;
                        goto case slopeDown;
                    case slopeDown:
                    case startSlopeDown:
                    case middleSlopeDown:
                    case endSlopeDown:
                        int deltaZ = terrainHit.height - hitPosition.z;
                        if ((stepDir.y > 0 && isUp) ||
                            (stepDir.y < 0 && !isUp)) {
                            goto default;
                        }
                        Physics.TerrainHit terrainHitUp = Atelier.physics.hitTerrain(hitPosition + Vec3i(0,
                                0, deltaZ), hitbox);
                        if (terrainHitUp.isColliding) {
                            data.normal = Vec3f(0, 0, deltaZ > 0 ? -1 : 1);
                            data.type = hitType;
                            entity.onCollide(data);
                        }
                        else {
                            entity.moveRaw(Vec3i(0, stepDir.y, deltaZ),
                                terrainHit.height, Atelier.world.scene.getMaterial(
                                    entity.getPosition()));
                        }
                        break;
                    default:
                        data.normal = terrainHit.normal;
                        data.type = hitType;
                        entity.onCollide(data);
                        break;
                    }
                    break;
                }
                else {
                    Physics.SolidHit solidHit = Atelier.physics.collidesAt(hitPosition, hitbox);
                    if (solidHit.isColliding) {
                        Physics.CollisionHit data;
                        switch (solidHit.solid.shape) with (SolidCollider.Shape) {
                        case slopeUp:
                        case slopeDown:
                            int deltaZ = solidHit.baseZ - hitPosition.z;
                            if ((stepDir.y > 0 && solidHit.solid.shape == SolidCollider.Shape.slopeUp) ||
                                (stepDir.y < 0 &&
                                    solidHit.solid.shape == SolidCollider.Shape.slopeDown)) {
                                goto default;
                            }
                            Physics.SolidHit solidHitUp = Atelier.physics.collidesAt(hitPosition + Vec3i(0,
                                    0, deltaZ), hitbox);
                            if (solidHitUp.isColliding) {
                                data.solid = solidHit.solid;
                                data.entity = solidHit.solid.entity;
                                data.normal = Vec3f(0, 0, deltaZ > 0 ? -1 : 1);
                                data.type = hitType;
                                entity.onCollide(data);
                            }
                            else {
                                entity.moveRaw(Vec3i(0, stepDir.y, deltaZ),
                                    solidHit.baseZ, solidHit.solid.entity.getMaterial());
                            }
                            break;
                        default:
                            data.solid = solidHit.solid;
                            data.entity = solidHit.solid.entity;
                            data.normal = Vec3f(0, -stepDir.y, 0);
                            data.type = hitType;
                            entity.onCollide(data);
                            break;
                        }
                        break;
                    }
                    else {
                        _moveRaw(entity, Vec3i(0, stepDir.y, 0), terrainHit.height);
                    }
                }
            }
            if (axis[2]) {
                Vec3i hitPosition = entity.getPosition() + Vec3i(0, 0, stepDir.z);
                Physics.TerrainHit terrainHit = Atelier.physics.hitTerrain(hitPosition, hitbox);
                if (terrainHit.isColliding) {
                    Physics.CollisionHit data;
                    data.normal = Vec3f(0f, 0f, 1f);
                    data.type = hitType;
                    entity.onCollide(data);
                }
                else {
                    Physics.SolidHit solidHit = Atelier.physics.collidesAt(hitPosition, hitbox);
                    if (solidHit.isColliding) {
                        Physics.CollisionHit data;
                        data.solid = solidHit.solid;
                        data.entity = solidHit.solid.entity;
                        data.normal = Vec3f(0, 0, -stepDir.z);
                        data.type = hitType;
                        entity.onCollide(data);
                        break;
                    }
                    else {
                        _moveRaw(entity, Vec3i(0, 0, stepDir.z), terrainHit.height);
                    }
                }
            }
        }

        return true;
    }

    private void _moveTileRaw(Entity entity, Vec3i dir, int baseZ) {
        //int material = Atelier.world.scene.getTileMaterial(entity.getTilePosition());
        //entity.moveTileRaw(dir, baseZ, material);
        Atelier.log("movetileraw: ", dir);
        entity.moveTileRaw(dir);
    }

    private void _moveRaw(Entity entity, Vec3i dir, int baseZ) {
        Physics.SolidUnderHit hit = Atelier.physics.getSolidUnder(this);

        int material;
        if (hit.isUnder && hit.baseZ >= baseZ) {
            baseZ = hit.baseZ;
            material = hit.solid.entity.getMaterial();
        }
        else {
            material = Atelier.world.scene.getMaterial(entity.getPosition());
        }

        entity.moveRaw(dir, baseZ, material);
    }

    /// Est-ce que l’acteur est sur le solide ?
    bool isRiding(SolidCollider solid) {
        return (solid.left <= right) && (solid.right >= left) &&
            (solid.up <= down) && (solid.down >= up) && (solid.top == bottom);
    }

    /// Vérifie s’il y a collision entre ce solide et une boite
    Physics.ActorHit collidesWith(Vec3i point_, Vec3i hitbox_) {
        Physics.ActorHit hit;
        hit.actor = this;

        //if (!_isTempCollidable || !_isCollidable) {
        //    return hit;
        //}

        point_.x -= hitbox_.x - (hitbox_.x >> 1);
        point_.y -= hitbox_.y - (hitbox_.y >> 1);

        if (!((left < (point_.x + hitbox_.x)) && (up < (point_.y + hitbox_.y)) &&
                (bottom < (point_.z + hitbox_.z)) && (right > point_.x) && (down > point_.y)
                && (top > point_.z)))
            return hit;

        hit.isColliding = true;
        return hit;
    }
}
