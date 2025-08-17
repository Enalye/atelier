module atelier.physics.shot;

import std.algorithm : canFind;
import std.conv : to;
import std.math;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.physics.actor;
import atelier.physics.collider;
import atelier.physics.system;

final class ShotCollider : Collider {
    private {
    }

    @property {
    }

    this(Vec3u size_) {
        super(size_);
        _type = Type.shot;
    }

    this(ShotCollider other) {
        super(other);
    }

    override Collider fetch() {
        return new ShotCollider(this);
    }

    override void moveTile(Vec3i moveDir, Physics.CollisionHit.Type type = Physics
            .CollisionHit.Type.none) {
    }

    override void move(Vec3f moveDir,
        Physics.CollisionHit.Type hitType = Physics.CollisionHit.Type.none) {
        Vec3f subMove = entity.getSubPosition();
        subMove += moveDir;
        Vec3i gridMovement = cast(Vec3i) subMove.round();
        subMove -= cast(Vec3f) gridMovement;
        entity.setSubPosition(subMove);

        if (gridMovement == Vec3i.zero)
            return;

        Vec3i stepDir = gridMovement.sign();

        Vec3i walkDir;
        __checkLoop: while (walkDir != gridMovement) {
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
                    data.normal = terrainHit.normal;
                    entity.onCollide(data);
                    break __checkLoop;
                }
                else {
                    Physics.SolidHit solidHit = Atelier.physics.collidesAt(hitPosition, hitbox);
                    if (solidHit.isColliding) {
                        Physics.CollisionHit data;
                        data.solid = solidHit.solid;
                        data.normal = Vec3f(-stepDir.x, 0, 0);
                        entity.onCollide(data);
                        break __checkLoop;
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
                    data.normal = terrainHit.normal;
                    entity.onCollide(data);
                    break __checkLoop;
                }
                else {
                    Physics.SolidHit solidHit = Atelier.physics.collidesAt(hitPosition, hitbox);
                    if (solidHit.isColliding) {
                        Physics.CollisionHit data;
                        data.solid = solidHit.solid;
                        data.normal = Vec3f(0, -stepDir.y, 0);
                        entity.onCollide(data);
                        break __checkLoop;
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
                    entity.onCollide(data);
                    break __checkLoop;
                }
                else {
                    Physics.SolidHit solidHit = Atelier.physics.collidesAt(hitPosition, hitbox);
                    if (solidHit.isColliding) {
                        Physics.CollisionHit data;
                        data.solid = solidHit.solid;
                        data.normal = Vec3f(0, 0, -stepDir.z);
                        entity.onCollide(data);
                        break __checkLoop;
                    }
                    else {
                        _moveRaw(entity, Vec3i(0, 0, stepDir.z), terrainHit.height);
                    }
                }
            }
        }
    }

    private void _moveRaw(Entity entity, Vec3i dir, int baseZ) {
        entity.moveRaw(dir, baseZ, 0);
    }
}
