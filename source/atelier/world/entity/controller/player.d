module atelier.world.entity.controller.player;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.world.entity;
import atelier.world.entity.controller.behavior;

final class DefaultPlayerController : Controller!Actor {
    override void onStart() {
        setBehavior(new DefaultMoveBehavior);
    }

    override void onTeleport(uint direction, bool isExit) {
        setBehavior(new DefaultTeleporterBehavior(direction, isExit));
    }
}

final class DefaultMoveBehavior : Behavior!Actor {
    override void update() {
        Vec2f acceldir = Vec2f.zero;
        Vec2f movedir = Atelier.input.getActionVector("left", "right", "up", "down");

        if (movedir != Vec2f.zero) {
            movedir.normalize();
            entity.angle = radToDeg(movedir.angle()) + 90f;
            acceldir += movedir * 1f;
        }

        entity.accelerate(Vec3f(acceldir, 0f));
    }
}

final class DefaultTeleporterBehavior : Behavior!Actor {
    private {
        uint _direction;
        bool _isExit;
    }

    this(uint direction_, bool isExit) {
        _direction = direction_ % 8;
        _isExit = isExit;
    }

    override void update() {
        Vec2f acceldir = Vec2f.angled(degToRad((_direction * -45f) - 90f)) * (_isExit ? 0.3f : 0.65f);
        entity.angle = radToDeg(acceldir.angle()) + 90f;
        entity.accelerate(Vec3f(acceldir, 0f));
    }
}
