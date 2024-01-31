/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.audio.soundplayer;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_soundPlayer(GrLibDefinition library) {
    GrType soundPlayerType = library.addNative("SoundPlayer", [], "AudioPlayer");
    GrType soundType = grGetNativeType("Sound");

    library.addConstructor(&_ctor, soundPlayerType, [soundType]);

    //library.addProperty(&_volume!"get", &_volume!"set", "volume", soundType, grFloat);
}

private void _ctor(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    call.setNative(new SoundPlayer(sound));
}
/*
private void _volume(string op)(GrCall call) {
    Sound sound = call.getNative!Sound(0);

    static if (op == "set") {
        sound.volume = call.getFloat(1);
    }
    call.setFloat(sound.volume);
}

private void _sound(string c)(GrCall call) {
    Sound sound = new SSound;
    mixin("sound = Sound.", c, ";");
    call.setNative(sound);
}*/
