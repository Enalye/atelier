/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.audio.sound;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_sound(GrLibDefinition library) {
    GrType soundType = library.addNative("Sound");

    library.addConstructor(&_ctor, soundType, [grString]);
    library.addFunction(&_play, "play", [soundType]);

    //library.addProperty(&_volume!"get", &_volume!"set", "volume", soundType, grFloat);
}

private void _ctor(GrCall call) {
    Sound sound = Atelier.res.get!Sound(call.getString(0));
    call.setNative(sound);
}

private void _play(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    Atelier.audio.play(sound);
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
