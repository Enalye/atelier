module atelier.world.entity.controller.state;

import std.math;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.input;
import atelier.world.entity.base;
import atelier.world.entity.controller.base;

package final class EntityControllerState {
    alias OnUpdateCallback = void delegate();
    alias OnStartCallback = void delegate();
    alias OnEndCallback = void delegate();
    alias OnEventCallback = void delegate(string);
    alias OnCollideCallback = void delegate(Entity, Vec3f);
    alias OnSquishCallback = void delegate(Vec3f);
    alias OnImpactCallback = void delegate(Entity, Vec3f);
    alias OnSceneEnterCallback = void delegate(uint);
    alias OnSceneExitCallback = void delegate(uint);
    alias TransitionCallback = bool delegate();

    private {
        string _id;
        OnUpdateCallback[] _onUpdateList;
        OnStartCallback[] _onStartList;
        OnEndCallback[] _onEndList;
        OnEventCallback[] _onEventList;
        OnCollideCallback[] _onCollideList;
        OnSquishCallback[] _onSquishList;
        OnImpactCallback[] _onImpactList;
        OnSceneEnterCallback[] _onSceneEnterList;
        OnSceneExitCallback[] _onSceneExitList;
        TransitionCallback[][string] _transitions;
    }

    @property {
        string id() const {
            return _id;
        }
    }

    this(string id_) {
        _id = id_;
    }

    void addUpdate(OnUpdateCallback callback) {
        _onUpdateList ~= callback;
    }

    void addStart(OnStartCallback callback) {
        _onStartList ~= callback;
    }

    void addEnd(OnEndCallback callback) {
        _onEndList ~= callback;
    }

    void addEvent(OnEventCallback callback) {
        _onEventList ~= callback;
    }

    void addCollide(OnCollideCallback callback) {
        _onCollideList ~= callback;
    }

    void addSquish(OnSquishCallback callback) {
        _onSquishList ~= callback;
    }

    void addImpact(OnImpactCallback callback) {
        _onImpactList ~= callback;
    }

    void addSceneEnter(OnSceneEnterCallback callback) {
        _onSceneEnterList ~= callback;
    }

    void addSceneExit(OnSceneExitCallback callback) {
        _onSceneExitList ~= callback;
    }

    void addTransition(string id, TransitionCallback transition) {
        _transitions[id] ~= transition;
    }

    string checkTransitions() {
        foreach (nextId, transitions; _transitions) {
            foreach (transition; transitions) {
                if (transition())
                    return nextId;
            }
        }
        return _id;
    }

    void onUpdate() {
        foreach (callback; _onUpdateList) {
            callback();
        }
    }

    void onStart() {
        foreach (callback; _onStartList) {
            callback();
        }
    }

    void onEnd() {
        foreach (callback; _onEndList) {
            callback();
        }
    }

    void onEvent(string event) {
        foreach (callback; _onEventList) {
            callback(event);
        }
    }

    void onCollide(Entity target, Vec3f normal) {
        foreach (callback; _onCollideList) {
            callback(target, normal);
        }
    }

    void onSquish(Vec3f normal) {
        foreach (callback; _onSquishList) {
            callback(normal);
        }
    }

    void onImpact(Entity target, Vec3f normal) {
        foreach (callback; _onImpactList) {
            callback(target, normal);
        }
    }

    void onSceneExit(uint direction) {
        foreach (callback; _onSceneExitList) {
            callback(direction);
        }
    }

    void onSceneEnter(uint direction) {
        foreach (callback; _onSceneEnterList) {
            callback(direction);
        }
    }
}
/*
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

    void onCollide(Entity target, Vec3f normal) {
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
*/
