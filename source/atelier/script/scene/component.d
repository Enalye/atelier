/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.scene.component;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.scene;
import atelier.render;
import atelier.script.util;

package void loadLibScene_component(GrModule mod) {
    mod.setModule("scene.component");
    mod.setModuleInfo(GrLocale.fr_FR, "Composant d’une entité");

    GrType entityComponentType = mod.addNative("EntityComponent");
    GrType audioComponentType = mod.addNative("AudioComponent", [], "EntityComponent");
    GrType audioPlayerType = grGetNativeType("AudioPlayer");
    GrType audioBusType = grGetNativeType("AudioBus");
    GrType soundType = grGetNativeType("Sound");
    GrType musicType = grGetNativeType("Music");
    GrType effectType = grGetNativeType("AudioEffect");

    mod.setDescription(GrLocale.fr_FR, "Joue un son spacialisé au niveau de l’entité");
    mod.setParameters(["audio", "sound"]);
    mod.addFunction(&_playSound, "play", [audioComponentType, soundType]);

    mod.setDescription(GrLocale.fr_FR, "Joue une musique spacialisée au niveau de l’entité");
    mod.setParameters(["audio", "music"]);
    mod.addFunction(&_playMusic, "play", [audioComponentType, musicType]);

    mod.setDescription(GrLocale.fr_FR,
        "Lance un lecteur audio spacialisé au niveau de l’entité");
    mod.setParameters(["audio", "player"]);
    mod.addFunction(&_play, "play", [audioComponentType, audioPlayerType]);

    mod.setDescription(GrLocale.fr_FR, "Ajoute un effet audio au bus audio de l’entité");
    mod.setParameters(["audio", "effect"]);
    mod.addFunction(&_addEffect, "addEffect", [audioComponentType, effectType]);

    mod.setDescription(GrLocale.fr_FR, "Connecte le bus audio de l’entité à un autre bus");
    mod.setParameters(["audio", "bus"]);
    mod.addFunction(&_connectTo, "connectTo", [audioComponentType, audioBusType]);

    mod.setDescription(GrLocale.fr_FR, "Connecte le bus audio de l’entité au bus maître");
    mod.setParameters(["audio"]);
    mod.addFunction(&_connectToMaster, "connectToMaster", [audioComponentType]);

    mod.setDescription(GrLocale.fr_FR, "Déconnecte le bus audio de l’entité");
    mod.setParameters(["audio"]);
    mod.addFunction(&_disconnect, "disconnect", [audioComponentType]);
}

private void _playSound(GrCall call) {
    AudioComponent audioComponent = call.getNative!AudioComponent(0);
    Sound sound = call.getNative!Sound(1);
    audioComponent.play(new SoundPlayer(sound));
}

private void _playMusic(GrCall call) {
    AudioComponent audioComponent = call.getNative!AudioComponent(0);
    Music music = call.getNative!Music(1);
    audioComponent.play(new MusicPlayer(music));
}

private void _play(GrCall call) {
    AudioComponent audioComponent = call.getNative!AudioComponent(0);
    AudioPlayer player = call.getNative!AudioPlayer(1);
    audioComponent.play(player);
}

private void _addEffect(GrCall call) {
    AudioComponent audioComponent = call.getNative!AudioComponent(0);
    AudioEffect effect = call.getNative!AudioEffect(1);
    audioComponent.addEffect(effect);
}

private void _connectTo(GrCall call) {
    AudioComponent audioComponent = call.getNative!AudioComponent(0);
    AudioBus bus = call.getNative!AudioBus(1);
    audioComponent.connectTo(bus);
}

private void _connectToMaster(GrCall call) {
    AudioComponent audioComponent = call.getNative!AudioComponent(0);
    audioComponent.connectToMaster();
}

private void _disconnect(GrCall call) {
    AudioComponent audioComponent = call.getNative!AudioComponent(0);
    audioComponent.disconnect();
}
