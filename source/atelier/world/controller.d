module atelier.world.controller;

import atelier.common;

abstract class ControllerWrapper {
    protected {
        bool _isRunning;
    }

    @property {
        bool isRunning() const {
            return _isRunning;
        }
    }

    void update();
}
