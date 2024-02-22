/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.scene.component;

import atelier.audio;
import atelier.common;
import atelier.scene.entity;

abstract class EntityComponent {
    private {
        Entity _entity;
    }

    @property {
        Entity entity() {
            return _entity;
        }

        package Entity entity(Entity entity_) {
            return _entity = entity_;
        }
    }

    void update();
}

final class AudioComponent : EntityComponent {
    private {
        AudioBus _audioBus;
        AudioSpacializer _audioSpacializer;
    }

    this() {
        _audioBus = new AudioBus;
        _audioBus.connectToMaster();
        _audioSpacializer = new AudioSpacializer;
        _audioSpacializer.minDistance = 20f;
        _audioSpacializer.maxDistance = 2_000f;
        _audioSpacializer.attenuationSpline = Spline.sineInOut;
        _audioSpacializer.orientationSpline = Spline.sineInOut;
        _audioBus.addEffect(_audioSpacializer);
    }

    override void update() {
        _audioSpacializer.position = _entity.scenePosition();
    }

    void play(AudioPlayer player) {
        _audioBus.play(player);
    }

    void addEffect(AudioEffect effect) {
        _audioBus.addEffect(effect);
    }

    void connectTo(AudioBus bus) {
        _audioBus.connectTo(bus);
    }

    void connectToMaster() {
        _audioBus.connectToMaster();
    }

    void disconnect() {
        _audioBus.disconnect();
    }
}
