/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.scene.component;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.scene;
import atelier.render;
import atelier.script.util;

package void loadLibScene_component(GrLibDefinition library) {
    GrType entityComponentType = library.addNative("EntityComponent");
    GrType audioComponentType = library.addNative("AudioComponent", [], "EntityComponent");
    GrType audioPlayerType = grGetNativeType("AudioPlayer");
    GrType audioBusType = grGetNativeType("AudioBus");
    GrType soundType = grGetNativeType("Sound");
    GrType musicType = grGetNativeType("Music");
    GrType effectType = grGetNativeType("AudioEffect");

    library.addFunction(&_playSound, "play", [audioComponentType, soundType]);
    library.addFunction(&_playMusic, "play", [audioComponentType, musicType]);
    library.addFunction(&_play, "play", [audioComponentType, audioPlayerType]);
    library.addFunction(&_addEffect, "addEffect", [
            audioComponentType, effectType
        ]);
    library.addFunction(&_connectTo, "connectTo", [
            audioComponentType, audioBusType
        ]);
    library.addFunction(&_connectToMaster, "connectToMaster", [
            audioComponentType
        ]);
    library.addFunction(&_disconnect, "disconnect", [audioComponentType]);
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
