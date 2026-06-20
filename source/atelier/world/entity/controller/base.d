module atelier.world.entity.controller.base;

import atelier.common;
import atelier.core;
import atelier.world.controller;
import atelier.world.entity.base;
import atelier.world.entity.controller.state;

abstract class EntityController : ControllerWrapper {
    private {
        string _id;
        Entity _entity;
        EntityControllerState[string] _states;
        EntityControllerState _currentState;
        string _defaultId, _currentStateId;
    }

    @property {
        Entity entity() {
            return _entity;
        }

        string id() const {
            return _id;
        }
    }

    this(string defaultId) {
        _defaultId = defaultId;
    }

    final void setup(Entity entity_, string id_) {
        _isRunning = true;
        _entity = entity_;
        _id = id_;
        setState(_defaultId);
    }

    private void _addCallback(string type, T)(string stateId, T callback) {
        _states.update(stateId, {
            EntityControllerState state = new EntityControllerState(stateId);
            mixin("state.add", type, "(callback);");
            return state;
        }, (EntityControllerState state) {
            mixin("state.add", type, "(callback);");
        });
    }

    final void addUpdate(string stateId, EntityControllerState.OnUpdateCallback callback) {
        _addCallback!("Update")(stateId, callback);
    }

    final void addStart(string stateId, EntityControllerState.OnStartCallback callback) {
        _addCallback!("Start")(stateId, callback);
    }

    final void addEnd(string stateId, EntityControllerState.OnEndCallback callback) {
        _addCallback!("End")(stateId, callback);
    }

    final void addEvent(string stateId, EntityControllerState.OnEventCallback callback) {
        _addCallback!("Event")(stateId, callback);
    }

    final void addCollide(string stateId, EntityControllerState.OnCollideCallback callback) {
        _addCallback!("Collide")(stateId, callback);
    }

    final void addSquish(string stateId, EntityControllerState.OnSquishCallback callback) {
        _addCallback!("Squish")(stateId, callback);
    }

    final void addImpact(string stateId, EntityControllerState.OnImpactCallback callback) {
        _addCallback!("Impact")(stateId, callback);
    }

    final void addSceneEnter(string stateId, EntityControllerState.OnSceneEnterCallback callback) {
        _addCallback!("SceneEnter")(stateId, callback);
    }

    final void addSceneExit(string stateId, EntityControllerState.OnSceneExitCallback callback) {
        _addCallback!("SceneExit")(stateId, callback);
    }

    final void addTransition(string stateId, string nextId, EntityControllerState
            .TransitionCallback callback) {
        _states.update(stateId, {
            EntityControllerState state = new EntityControllerState(stateId);
            state.addTransition(nextId, callback);
            return state;
        }, (EntityControllerState state) {
            state.addTransition(nextId, callback);
        });
    }

    final string getState() const {
        return _currentStateId;
    }

    final void setState(string stateId) {
        if (_currentStateId == stateId)
            return;

        if (_currentState) {
            _currentState.onEnd();
        }

        auto pState = stateId in _states;
        if (pState) {
            _currentStateId = stateId;
            _currentState = *pState;

            if (_currentState) {
                _currentState.onStart();
            }
        }
        else {
            _currentStateId = stateId;
            _currentState = null;
        }
    }

    void onStart() {
    }

    void onEnd() {
    }

    void onEnable() {
    }

    void onDisable() {
    }

    void onUpdate() {
    }

    final void onEvent(string event) {
        if (!_currentState)
            return;

        _currentState.onEvent(event);
    }

    final void onSceneExit(uint direction) {
        if (!_currentState)
            return;

        _currentState.onSceneExit(direction);
    }

    final void onSceneEnter(uint direction) {
        if (!_currentState)
            return;

        _currentState.onSceneEnter(direction);
    }

    final void onCollide(Entity other, Vec3f normal) {
        if (!_currentState)
            return;

        _currentState.onCollide(other, normal);
    }

    final void onSquish(Vec3f normal) {
        if (!_currentState)
            return;

        _currentState.onSquish(normal);
    }

    final void onImpact(Entity other, Vec3f normal) {
        if (!_currentState)
            return;

        _currentState.onImpact(other, normal);
    }

    package(atelier.world) final void unregister() {
        if (_currentState) {
            _currentState.onEnd();
            _currentState = null;
            _currentStateId.length = 0;
        }

        _isRunning = false;
    }

    final override void update() {
        onUpdate();

        if (_currentState) {
        __checkTransition:
            string stateId = _currentState.checkTransitions();
            if (_currentStateId != stateId) {
                if (_currentState) {
                    _currentState.onEnd();
                }
                auto pState = stateId in _states;
                if (pState) {
                    _currentStateId = stateId;
                    _currentState = *pState;

                    if (_currentState) {
                        _currentState.onStart();
                    }
                    goto __checkTransition;
                }
                else {
                    _currentStateId = stateId;
                    _currentState = null;
                }
            }
        }

        if (_currentState) {
            _currentState.onUpdate();
        }
    }
}
