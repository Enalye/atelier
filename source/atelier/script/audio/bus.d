/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.audio.bus;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_bus(GrLibDefinition library) {
    GrType busType = library.addNative("AudioBus");
    GrType playerType = grGetNativeType("AudioPlayer");
    GrType soundType = grGetNativeType("Sound");
    GrType musicType = grGetNativeType("Music");
    GrType effectType = grGetNativeType("AudioEffect");

    library.addConstructor(&_ctor, busType);

    library.addFunction(&_play, "play", [busType, playerType]);
    library.addFunction(&_playSound, "play", [busType, soundType]);
    library.addFunction(&_playMusic, "play", [busType, musicType]);
    library.addFunction(&_addEffect, "addEffect", [busType, effectType]);
}

private void _ctor(GrCall call) {
    AudioBus bus = new AudioBus();
    bus.connectToMaster();
    call.setNative(bus);
}

private void _play(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    AudioPlayer player = call.getNative!AudioPlayer(1);
    bus.play(player);
}

private void _playSound(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    Sound sound = call.getNative!Sound(1);
    bus.play(new SoundPlayer(sound));
}

private void _playMusic(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    Music music = call.getNative!Music(1);
    bus.play(new MusicPlayer(music));
}

private void _addEffect(GrCall call) {
    AudioBus bus = call.getNative!AudioBus(0);
    AudioEffect effect = call.getNative!AudioEffect(1);
    bus.addEffect(effect);
}
