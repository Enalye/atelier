/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.world.audio;

import atelier.common;
import atelier.core;
import atelier.audio;
import atelier.world.scene;
import atelier.world.world;
import atelier.world.camera;

package(atelier.world) void registerSystems_audio(World world) {
    world.registerSystem!SystemUpdater("audio", &_updateSystem);
}

struct AudioComponent {
    AudioBus bus;
    AudioSpacializer spacializer;
    AudioDelay delay;
    AudioLowPassFilter lowPass;
    float angle;
    bool isInit;

    void onInit() {
        angle = 0f;
        isInit = true;
        bus = new AudioBus;
        bus.connectToMaster();

        spacializer = new AudioSpacializer;
        spacializer.minDistance = 20f;
        spacializer.maxDistance = 1_000f;
        spacializer.attenuationSpline = Spline.sineInOut;
        spacializer.orientationSpline = Spline.sineInOut;
        bus.addEffect(spacializer);

        delay = new AudioDelay;
        bus.addEffect(delay);

        lowPass = new AudioLowPassFilter;
        bus.addEffect(lowPass);
    }

    void onDestroy() {
        disconnect();
        bus = null;
        spacializer = null;
        delay = null;
        lowPass = null;
    }

    void play(AudioPlayer player) {
        bus.play(player);
    }

    void addEffect(AudioEffect effect) {
        bus.addEffect(effect);
    }

    void connectTo(AudioBus bus) {
        bus.connectTo(bus);
    }

    void connectToMaster() {
        bus.connectToMaster();
    }

    void disconnect() {
        bus.disconnect();
    }

    void spacialize(Vec2f position) {
        float d = position.normalized.dot(Vec2f.right.rotated(angle));
        bool withDelay = isInit;
        isInit = false;
        if (d < 0f) {
            if (withDelay) {
                delay.leftDelay = 0f;
                delay.rightDelay = -0.002f * d;
            }
            lowPass.leftDamping = 0f;
            lowPass.rightDamping = -d * 0.9f;
        }
        else if (d > 0f) {
            if (withDelay) {
                delay.rightDelay = 0f;
                delay.leftDelay = 0.002f * d;
            }
            lowPass.leftDamping = d * 0.9f;
            lowPass.rightDamping = 0f;
        }
        else {
            if (withDelay) {
                delay.leftDelay = 0f;
                delay.rightDelay = 0f;
            }
            lowPass.leftDamping = 0f;
            lowPass.rightDamping = 0f;
        }

        spacializer.position = position.rotated(angle);
    }
}

private void _updateSystem(Scene scene, void* context) {
    Vec2f cameraPosition = Atelier.world.camera.getPosition();

    foreach (id, audio; scene.getComponentPool!AudioComponent()) {
        PositionComponent* position = scene.getComponent!PositionComponent(id);
        Vec2f offset = (position.worldPosition - cameraPosition);
        audio.spacialize(offset);
    }
}
