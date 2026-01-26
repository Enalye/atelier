module atelier.world.entity.controller.player;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.world.entity;
import atelier.world.entity.controller.base;
import atelier.world.entity.controller.state;

final class DefaultPlayerController : EntityController {
    override void onStart() {
        addState("move", new DefaultMoveState);
        addState("enter", new DefaultEnterState);
        addState("exit", new DefaultExitState);
        setDefaultState("move");
    }
}

final class DefaultMoveState : EntityControllerState {
    override void onSceneEnter(uint direction_) {
        runState("enter");
    }

    override void onUpdate() {
        Vec2f acceldir = Vec2f.zero;
        Vec2f movedir = Atelier.input.getActionVector("left", "right", "up", "down");

        if (movedir != Vec2f.zero) {
            movedir.normalize();
            entity.angle = radToDeg(movedir.angle());
            acceldir += movedir * 1f;
        }

        entity.setAccel(Vec3f(acceldir, 0f));
    }
}

final class DefaultEnterState : EntityControllerState {
    private {
        uint _direction;
    }

    override void onStartSceneEnter(uint direction_) {
        _direction = direction_ % 8;
    }

    override void onSceneExit(uint direction_) {
        runState("exit");
    }

    override void onUpdate() {
        Vec2f acceldir = Vec2f.angled(degToRad((_direction * -45f))) * 0.65f;
        entity.angle = radToDeg(acceldir.angle());
        entity.setAccel(Vec3f(acceldir, 0f));
    }
}

final class DefaultExitState : EntityControllerState {
    private {
        uint _direction;
        Timer _timer;
    }

    override void onStartSceneExit(uint direction_) {
        _direction = direction_ % 8;
        _timer.start(60);
    }

    override void onUpdate() {
        _timer.update();
        Vec2f acceldir = Vec2f.angled(degToRad((_direction * -45f))) * 0.3f;
        entity.angle = radToDeg(acceldir.angle());
        entity.setAccel(Vec3f(acceldir, 0f));

        if (!_timer.isRunning) {
            runState("move");
        }
    }
}
