module atelier.world.behavior.teleporter;

import std.math;
import atelier.common;
import atelier.world.entity;
import atelier.world.behavior.base;

final class DefaultTeleporterBehavior : Behavior {
    private {
        Actor _actor;
        uint _direction;
        bool _isExit;
    }

    this(Actor actor_, uint direction_, bool isExit) {
        _actor = actor_;
        _direction = direction_ % 8;
        _isExit = isExit;
        _actor.setBehavior(this);
    }

    override void onUnregister() {
    }

    override void update() {
        Vec2f acceldir = Vec2f.angled(degToRad((_direction * -45f) - 90f)) * (_isExit ? 0.3f : 0.65f);
        _actor.angle = radToDeg(acceldir.angle()) + 90f;
        _actor.accelerate(Vec3f(acceldir, 0f));
    }
}
