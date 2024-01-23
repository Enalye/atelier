/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.audio.manager;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_manager(GrLibDefinition library) {
    GrType soundType = grGetNativeType("Sound");
    GrType entityType = grGetNativeType("Entity");


    library.addFunction(&_playSound, "playSound", [soundType]);
    //library.addFunction(&_playSoundEntity, "playSound", [entityType, soundType]);
    library.addFunction(&_playMusic, "playMusic", [soundType]);
    library.addFunction(&_stopMusic, "stopMusic");
    //library.addFunction(&_pauseMusic, "pauseMusic");
    //library.addFunction(&_resumeMusic, "resumeMusic");
    //library.addFunction(&_pushMusic, "pushMusic", [soundType]);
    //library.addFunction(&_popMusic, "popMusic");
    //library.addFunction(&_playInBetween, "playInBetween", [soundType]);
}

private void _playSound(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    Atelier.audio.play(sound);
}

private void _playMusic(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    //Atelier.audio.playMusic(sound);
}

private void _stopMusic(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    //Atelier.audio.playMusic(sound);
}