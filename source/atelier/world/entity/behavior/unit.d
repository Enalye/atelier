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

    override void setup() {
        _component = entity.getComponent!UnitComponent();
    }

    override void update() {
        Vec3f velocity = entity.velocity;
        Vec3f accel = entity.getAccel();

        float friction = Atelier.world.getMaterial(entity.getBaseMaterial()).friction;
        Vec2f velocity2d = velocity.xy;
        Vec2f accel2d = accel.xy;
        Vec3i position = entity.getPosition();

        int baseZ = entity.getBaseZ();

        if (position.z < baseZ) {
            position.z = baseZ;
        }
        else if (position.z > baseZ) {
            velocity.z -= _component.gravity;
        }

        if (abs(velocity2d.x) < 0.02f && accel2d.x == 0f)
            velocity2d.x = 0f;

        if (abs(velocity2d.y) < 0.02f && accel2d.y == 0f)
            velocity2d.y = 0f;

        velocity2d = velocity2d + accel2d;

        velocity.z += accel.z;
        accel = Vec3f(accel2d * friction, accel.z);
        velocity = Vec3f(velocity2d, velocity.z);

        entity.setAccel(accel);
        entity.setVelocity(velocity);
        entity.move(velocity);
    }
}
