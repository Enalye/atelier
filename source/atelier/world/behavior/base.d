module atelier.world.behavior.base;

import std.math;
import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.input;
import atelier.world.entity;

abstract class Behavior {
    private {
        bool _isRunning = true;
    }

    @property {
        bool isRunning() const {
            return _isRunning;
        }
    }

    void update();
    void onUnregister();

    void onImpact() {
    }

    final void unregister() {
        _isRunning = false;
        onUnregister();
    }
}
