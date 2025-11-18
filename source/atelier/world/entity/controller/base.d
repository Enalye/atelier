module atelier.world.entity.controller.base;

import atelier.common;
import atelier.core;
import atelier.world.controller;
import atelier.world.entity.base;
import atelier.world.entity.controller.behavior;

abstract class Controller(T : Entity) : ControllerWrapper {
    static assert(__traits(isAbstractClass, T) == false,
        "Controller ne doit pas être utilisé sur des classes abstraites");

    private {
        T _entity;
        Behavior!T _behavior;
    }

    @property {
        T entity() {
            return _entity;
        }
    }

    final void setup(T entity_) {
        _isRunning = true;
        _entity = entity_;
    }

    final string sendEvent(string event) {
        if (!_behavior)
            return "";

        return _behavior.onEvent(event);
    }

    string onEvent(string event) {
        return "";
    }

    void onUpdate() {
    }

    void onStart() {
    }

    void onClose() {
    }

    void onTeleport(uint direction, bool isExit) {
    }

    final void onHit(Entity target, Vec3f normal) {
        if (!_behavior)
            return;

        _behavior.onHit(target, normal);
    }

    final void onSquish(Vec3f normal) {
        if (!_behavior)
            return;

        _behavior.onSquish(normal);
    }

    final void onImpact(Entity target, Vec3f normal) {
        if (!_behavior)
            return;

        _behavior.onImpact(target, normal);
    }

    package(atelier.world) final void unregister() {
        if (_behavior) {
            _behavior.onClose();
        }
        onClose();

        _isRunning = false;
    }

    final void setBehavior(Behavior!T behavior) {
        if (_behavior) {
            _behavior.onClose();
            _behavior = null;
        }

        _behavior = behavior;

        if (_behavior) {
            _behavior.setup(this);
            _behavior.onStart();
        }
    }

    final override void update() {
        onUpdate();

        if (!_entity.isRegistered) {
            _isRunning = false;
            onClose();
            return;
        }

        if (_behavior) {
            if (!_behavior.isRunning()) {
                _behavior.onClose();
                _behavior = null;
            }
            else {
                _behavior.update();
            }
        }
    }
}
