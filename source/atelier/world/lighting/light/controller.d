module atelier.world.lighting.light.controller;

import atelier.common;
import atelier.world.controller;
import atelier.world.lighting.light.light;

abstract class LightController : ControllerWrapper {
    private {
        Light _light;
    }

    @property {
        Light light() {
            return _light;
        }
    }

    final void setup(Light light_) {
        _isRunning = true;
        _light = light_;
    }

    package(atelier.world) final void unregister() {
        onClose();
        _isRunning = false;
    }

    void onUpdate() {
    }

    void onStart() {
    }

    void onClose() {
    }
}
