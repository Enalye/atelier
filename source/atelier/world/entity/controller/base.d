module atelier.world.entity.controller.base;

import atelier.common;
import atelier.core;
import atelier.world.controller;
import atelier.world.entity.base;
import atelier.world.entity.controller.state;

abstract class EntityController : ControllerWrapper {
    private {
        Entity _entity;
        string _currentStateId, _lastStateId, _defaultStateId;
        bool _isStartingState = true;
        EntityControllerState[string] _states;
        EntityControllerState _currentState;
    }

    @property {
        Entity entity() {
            return _entity;
        }
    }

    final void setup(Entity entity_) {
        _isRunning = true;
        _entity = entity_;
    }

    final string sendEvent(string event) {
        return onEvent(event);
    }

    void onUpdate() {
    }

    string onEvent(string event) {
        return "";
    }

    void onStart() {
    }

    void onEnable() {
    }

    void onDisable() {
    }

    void onClose() {
    }

    final void onSceneExit(uint direction) {
        if (!_currentState)
            return;

        string stateId = _currentStateId;
        _currentState.onSceneExit(direction);
        if (stateId != _currentStateId) {
            _currentState.onStartSceneExit(direction);
        }
    }

    final void onSceneEnter(uint direction) {
        if (!_currentState)
            return;

        string stateId = _currentStateId;
        _currentState.onSceneEnter(direction);
        if (stateId != _currentStateId) {
            _currentState.onStartSceneEnter(direction);
        }
    }

    final void onHit(Entity other, Vec3f normal) {
        if (!_currentState)
            return;

        string stateId = _currentStateId;
        _currentState.onHit(other, normal);
        if (stateId != _currentStateId) {
            _currentState.onStartHit(other, normal);
        }
    }

    final void onSquish(Vec3f normal) {
        if (!_currentState)
            return;

        string stateId = _currentStateId;
        _currentState.onSquish(normal);
        if (stateId != _currentStateId) {
            _currentState.onStartSquish(normal);
        }
    }

    final void onImpact(Entity other, Vec3f normal) {
        if (!_currentState)
            return;

        string stateId = _currentStateId;
        _currentState.onImpact(other, normal);
        if (stateId != _currentStateId) {
            _currentState.onStartImpact(other, normal);
        }
    }

    package(atelier.world) final void unregister() {
        if (_currentState) {
            _currentState.onClose();
            _currentState = null;
        }
        onClose();
        _isRunning = false;
    }

    final void addState(string id, EntityControllerState state) {
        state.setup(this, id);
        _states[id] = state;
    }

    final void setDefaultState(string id) {
        _defaultStateId = id;
    }

    final void runPreviousState() {
        runState(_lastStateId);
    }

    final void runDefaultState() {
        runState(_defaultStateId);
    }

    final void runState(string id) {
        if (_currentStateId == id)
            return;

        auto p = id in _states;
        if (!p)
            return;

        if (_currentState) {
            _currentState.onClose();

            if (_currentState.canExit(id) && p.canEnter(_currentState.id)) {
                _lastStateId = _currentStateId;
                _currentStateId = id;
                _currentState = *p;
                _currentState.onStart();
            }
        }
        else {
            _lastStateId = _currentStateId;
            _currentStateId = id;
            _currentState = *p;
            _currentState.onStart();
        }
    }

    final override void update() {
        onUpdate();

        if (!_entity.isRegistered) {
            _isRunning = false;
            if (_currentState) {
                _currentState.onClose();
                _currentState = null;
            }
            onClose();
            return;
        }

        if (!_currentState && _defaultStateId.length) {
            runDefaultState();
        }

        if (_currentState) {
            if (!_currentState.isRunning()) {
                _currentState.onClose();
                _currentState = null;
            }
            else {
                _currentState.onUpdate();
            }
        }
    }
}
