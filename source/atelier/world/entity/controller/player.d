module atelier.world.entity.controller.player;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.world.entity;
import atelier.world.entity.controller.base;
import atelier.world.entity.controller.state;

final class DefaultPlayerController : EntityController {
    private {
        uint _direction;
        Timer _timer;
    }

    this() {
        super("move");
        addUpdate("move", &_onMoveUpdate);
        addUpdate("enter", &_onEnterUpdate);
        addUpdate("exit", &_onExitUpdate);

        addSceneEnter("move", &_onSceneEnter);
        addSceneExit("move", &_onSceneExit);
    }

    private void _onSceneEnter(uint direction_) {
        _direction = direction_ % 8;
        setState("enter");
    }

    private void _onSceneExit(uint direction_) {
        _direction = direction_ % 8;
        _timer.start(60);
        setState("");
    }

    private void _onMoveUpdate() {
        Vec2f acceldir = Vec2f.zero;
        Vec2f movedir = Atelier.input.getActionVector("left", "right", "up", "down");

        if (movedir != Vec2f.zero) {
            movedir.normalize();
            entity.setAngle(radToDeg(movedir.angle()));
            acceldir += movedir * 1f;
        }

        entity.setAccel(Vec3f(acceldir, 0f));
    }

    private void _onEnterUpdate() {
        _timer.update();
        Vec2f acceldir = Vec2f.angled(degToRad((_direction * -45f - 90f))) * 0.65f;
        entity.setAngle(radToDeg(acceldir.angle()));
        entity.setAccel(Vec3f(acceldir, 0f));

        if (!_timer.isRunning) {
            setState("move");
        }
    }

    private void _onExitUpdate() {
        _timer.update();
        Vec2f acceldir = Vec2f.angled(degToRad((_direction * -45f - 90f))) * 0.3f;
        entity.setAngle(radToDeg(acceldir.angle()));
        entity.setAccel(Vec3f(acceldir, 0f));

        Atelier.log(_timer.value01());
        if (!_timer.isRunning) {
            setState("move");
        }
    }
}
