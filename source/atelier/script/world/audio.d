/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.world.audio;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.audio;
import atelier.world;
import atelier.script.util;

package void loadLibWorld_audio(GrModule mod) {
    mod.setModule("world.audio");
    mod.setModuleInfo(GrLocale.fr_FR, "Gestion des entités sur une grille");
    mod.setModuleExample(GrLocale.fr_FR, "scene.setTilePosition(entity, 0, 0);");

    GrType sceneType = grGetNativeType("Scene");
    GrType entityType = grUInt;
    GrType audioPlayerType = grGetNativeType("AudioPlayer");
    GrType audioBusType = grGetNativeType("AudioBus");
    GrType soundType = grGetNativeType("Sound");
    GrType musicType = grGetNativeType("Music");
    GrType effectType = grGetNativeType("AudioEffect");

    mod.setDescription(GrLocale.fr_FR, "Joue un son spacialisé au niveau de l’entité");
    mod.setParameters(["scene", "entity", "sound"]);
    mod.addFunction(&_playSound, "playAudio", [sceneType, entityType, soundType]);

    mod.setDescription(GrLocale.fr_FR, "Joue une musique spacialisée au niveau de l’entité");
    mod.setParameters(["scene", "entity", "music"]);
    mod.addFunction(&_playMusic, "playAudio", [sceneType, entityType, musicType]);

    mod.setDescription(GrLocale.fr_FR,
        "Lance un lecteur audio spacialisé au niveau de l’entité");
    mod.setParameters(["scene", "entity", "player"]);
    mod.addFunction(&_play, "playAudio", [
            sceneType, entityType, audioPlayerType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute un effet audio au bus audio de l’entité");
    mod.setParameters(["scene", "entity", "effect"]);
    mod.addFunction(&_addEffect, "addAudioEffect", [
            sceneType, entityType, effectType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Connecte le bus audio de l’entité à un autre bus");
    mod.setParameters(["scene", "entity", "bus"]);
    mod.addFunction(&_connectTo, "connectAudioTo", [
            sceneType, entityType, audioBusType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Connecte le bus audio de l’entité au bus maître");
    mod.setParameters(["scene", "entity"]);
    mod.addFunction(&_connectToMaster, "connectAudioToMaster", [
            sceneType, entityType
        ]);

    mod.setDescription(GrLocale.fr_FR, "Déconnecte le bus audio de l’entité");
    mod.setParameters(["scene", "entity"]);
    mod.addFunction(&_disconnect, "disconnectAudio", [sceneType, entityType]);
}

private void _playSound(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    AudioComponent* audio = scene.getOrAddComponent!AudioComponent(id);
    Sound sound = call.getNative!Sound(2);
    audio.play(new SoundPlayer(sound));
}

private void _playMusic(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    AudioComponent* audio = scene.getOrAddComponent!AudioComponent(id);
    Music music = call.getNative!Music(2);
    audio.play(new MusicPlayer(music));
}

private void _play(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    AudioComponent* audio = scene.getOrAddComponent!AudioComponent(id);
    AudioPlayer player = call.getNative!AudioPlayer(2);
    audio.play(player);
}

private void _addEffect(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    AudioComponent* audio = scene.getOrAddComponent!AudioComponent(id);
    AudioEffect effect = call.getNative!AudioEffect(2);
    audio.addEffect(effect);
}

private void _connectTo(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    AudioComponent* audio = scene.getOrAddComponent!AudioComponent(id);
    AudioBus bus = call.getNative!AudioBus(2);
    audio.connectTo(bus);
}

private void _connectToMaster(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    AudioComponent* audio = scene.getOrAddComponent!AudioComponent(id);
    audio.connectToMaster();
}

private void _disconnect(GrCall call) {
    Scene scene = call.getNative!Scene(0);
    EntityID id = call.getUInt(1);
    AudioComponent* audio = scene.getOrAddComponent!AudioComponent(id);
    audio.disconnect();
}
