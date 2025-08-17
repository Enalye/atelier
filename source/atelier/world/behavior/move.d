module atelier.world.behavior.move;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.world.entity;
import atelier.world.behavior.base;

final class DefaultMoveBehavior : Behavior {
    private {
        Actor _actor;
    }

    this(Actor actor_) {
        _actor = actor_;
        _actor.setBehavior(this);
    }

    override void update() {
        Vec2f acceldir = Vec2f.zero;
        Vec2f movedir = Atelier.input.getActionVector("left", "right", "up", "down");

        if (movedir != Vec2f.zero) {
            movedir.normalize();
            _actor.angle = radToDeg(movedir.angle()) + 90f;
            acceldir += movedir * 1f;
        }

        _actor.accelerate(Vec3f(acceldir, 0f));
    }

    override void onUnregister() {
    }

    override void onImpact() {
    }
}
