module atelier.world.behavior.base;

import std.math;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.input;
import atelier.world.entity;

abstract class Behavior {
    private {
        Entity _entity;
        bool _isRunning = true;
    }

    @property {
        Entity entity() {
            return _entity;
        }

        bool isRunning() const {
            return _isRunning;
        }
    }

    this(Entity entity_) {
        _entity = entity_;
        _entity.setBehavior(this);
    }

    void update();
    void onUnregister();

    void onSquish(Vec3f normal) {
    }

    void onImpact(Vec3f normal) {
    }

    final void unregister() {
        _isRunning = false;
        onUnregister();
    }
}
