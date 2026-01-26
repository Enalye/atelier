module atelier.world.entity.behavior.unit;

import std.math;

import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.world.entity.base;
import atelier.world.entity.component;
import atelier.world.entity.behavior.base;

final class UnitBehavior : EntityBehavior {
    private {
        UnitComponent _component;
    }

    void setGravity(float value) {
        _component.gravity = value;
    }

    void setFrictionBrake(float value) {
        _component.frictionBrake = value;
    }

    override void setup() {
        _component = entity.getComponent!UnitComponent();
    }

    override void update() {
        //if (!_isEnabled)
        //    return;

        float maxSpeed = 2.5f;
        float accelSpeed = 1f;
        Vec3f velocity = entity.velocity;
        Vec3f accel = entity.getAccel();

        float friction = Atelier.world.getMaterial(entity.getBaseMaterial()).friction;
        Vec2f velocity2d = velocity.xy;
        Vec2f accel2d = accel.xy;
        float accelFriction = friction;
        Vec3i position = entity.getPosition();

        int baseZ = entity.getBaseZ();

        if (position.z < baseZ) {
            //velocity.z = 0f;
            position.z = baseZ;
        }
        else if (position.z > baseZ) {
            friction = 0.2f;

            /*if (_isHovering) {
                accelFriction = 2f;
                maxSpeed = 1f;
                accelSpeed = 0.4f;
            }
            else {*/
            velocity.z -= _component.gravity;
            accelFriction = 0.2f;
            //}
        }

        Vec2f frictionVel = velocity2d * friction * 0.2f * _component.frictionBrake;

        if (abs(velocity2d.x) < 0.02f && accel2d.x == 0f)
            velocity2d.x = 0f;

        if (abs(velocity2d.y) < 0.02f && accel2d.y == 0f)
            velocity2d.y = 0f;

        float velLen = velocity.length();
        if (velLen <= maxSpeed) {
            float dot = accel2d.dot(frictionVel);
            if (dot >= 0f) {
                frictionVel -= accel2d * dot;
            }
        }
        accel2d = accel2d * (accelFriction * accelSpeed * 10f / 60f);
        velocity2d = velocity2d + accel2d;
        velocity2d += _avoidCliffs(accel2d) * friction * _component.frictionBrake;

        float m = max(velLen, maxSpeed);
        float nm = velocity.length();
        if (nm > m) {
            velocity *= m / nm;
        }

        float zFriction = velocity.z * 0.1f;
        /*if (_isHovering) {
            if (isOnGround()) {
                move(Vec3f(0f, 0f, 1f));
            }
            _hoverHeight = approach(_hoverHeight, getBaseZ() + 6, 0.1f);
            float zDelta = _hoverHeight - position.z;
            if (abs(zDelta) > 0.02f) {
                _accel.z = zDelta / 500f;
            }
            else {
                velocity.z = 0f;
            }
            zFriction = 0f;
        }*/

        velocity.z += accel.z * accelFriction;
        accel = Vec3f(accel2d, accel.z);
        velocity = Vec3f(velocity2d - frictionVel, velocity.z - zFriction);

        entity.setAccel(accel);
        entity.setVelocity(velocity);
        entity.move(velocity);
    }

    private Vec2f _avoidCliffs(Vec2f dir) {
        Vec2f force = Vec2f.zero;

        Collider collider = entity.getCollider();
        if (!collider)
            return force;

        int baseZ = -16;
        Vec3i position3d = entity.getPosition();
        Vec2i position2d = position3d.xy;

        {
            Physics.TerrainHit terrainHit = Atelier.physics.hitTerrain(position3d, Vec3i.zero);
            Physics.SolidUnderHit solidUnderHit = Atelier.physics.getSolidUnder(position3d);
            baseZ = max(terrainHit.height, solidUnderHit.baseZ);
        }

        Vec3i[4] corners = [
            Vec3i(collider.left, collider.up, collider.bottom),
            Vec3i(collider.right, collider.up, collider.bottom),
            Vec3i(collider.left, collider.down, collider.bottom),
            Vec3i(collider.right, collider.down, collider.bottom)
        ];

        int[4] heights;
        int maxHeight = baseZ;

        for (uint i; i < 4; ++i) {
            Physics.TerrainHit terrainHit = Atelier.physics.hitTerrain(corners[i], Vec3i.zero);
            Physics.SolidUnderHit solidUnderHit = Atelier.physics.getSolidUnder(corners[i]);

            heights[i] = max(terrainHit.height, solidUnderHit.baseZ);
            if (heights[i] > maxHeight)
                maxHeight = heights[i];
        }

        if (maxHeight > (baseZ + 8)) {
            for (uint i; i < 4; ++i) {
                if (heights[i] == maxHeight) {
                    force += (cast(Vec2f)(corners[i].xy - position2d));
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
}
