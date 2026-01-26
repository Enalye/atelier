module atelier.world.entity.controller.state;

import std.math;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.input;
import atelier.world.entity.base;
import atelier.world.entity.controller.base;

abstract class EntityControllerState {
    private {
        EntityController _controller;
        string _id;
        bool _isRunning = true;
    }

    @property {
        string id() const {
            return _id;
        }

        Entity entity() {
            return _controller.entity;
        }

        bool isRunning() const {
            return _isRunning;
        }
    }

    this() {
    }

    package final void setup(EntityController controller, string id_) {
        _controller = controller;
        _id = id_;
    }

    final void runState(string id) {
        if (_id == id || !_controller)
            return;

        _controller.runState(id);
    }

    final void runDefaultState() {
        if (!_controller)
            return;

        _controller.runDefaultState();
    }

    final void runPreviousState() {
        if (!_controller)
            return;

        _controller.runPreviousState();
    }

    string onEvent(string event) {
        return "";
    }

    bool canEnter(string prevState) {
        return true;
    }

    bool canExit(string nextState) {
        return true;
    }

    void onStart() {
    }

    void onStartHit(Entity target, Vec3f normal) {
    }

    void onStartSquish(Vec3f normal) {
    }

    void onStartImpact(Entity target, Vec3f normal) {
    }

    void onStartSceneExit(uint direction) {
    }

    void onStartSceneEnter(uint direction) {
    }

    void onUpdate() {
    }

    void onEnable() {
    }

    void onDisable() {
    }

    void onClose() {
    }

    void onHit(Entity target, Vec3f normal) {
    }

    void onSquish(Vec3f normal) {
    }

    void onImpact(Entity target, Vec3f normal) {
    }

    void onSceneExit(uint direction) {
    }

    void onSceneEnter(uint direction) {
    }

    final void unregister() {
        _isRunning = false;
    }
}
