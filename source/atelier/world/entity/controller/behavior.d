module atelier.world.entity.controller.behavior;

import std.math;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.input;
import atelier.world.entity.base;
import atelier.world.entity.controller.base;

abstract class Behavior(T : Entity) {
    static assert(__traits(isAbstractClass, T) == false,
        "Behavior ne doit pas être utilisé sur des classes abstraites");

    private {
        Controller!T _controller;
        bool _isRunning = true;
    }

    @property {
        T entity() {
            return _controller.entity;
        }

        bool isRunning() const {
            return _isRunning;
        }
    }

    this() {
    }

    package final void setup(Controller!T controller) {
        _controller = controller;
    }

    void update();

    string onEvent(string event) {
        return "";
    }

    void onStart() {
    }

    void onClose() {
    }

    void onHit(Vec3f normal) {
    }

    void onSquish(Vec3f normal) {
    }

    void onImpact(Entity target, Vec3f normal) {
    }

    final void unregister() {
        _isRunning = false;
    }
}
