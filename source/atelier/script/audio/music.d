/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.audio.music;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_music(GrLibDefinition library) {
    GrType musicType = library.addNative("Music");

    library.addConstructor(&_ctor, musicType, [grString]);
    library.addFunction(&_play, "play", [musicType]);

    //library.addProperty(&_volume!"get", &_volume!"set", "volume", musicType, grFloat);
}

private void _ctor(GrCall call) {
    Music music = Atelier.res.get!Music(call.getString(0));
    call.setNative(music);
}

private void _play(GrCall call) {
    Music music = call.getNative!Music(0);
    Atelier.audio.play(music);
}
/*
private void _volume(string op)(GrCall call) {
    Music music = call.getNative!Music(0);

    static if (op == "set") {
        music.volume = call.getFloat(1);
    }
    call.setFloat(music.volume);
}

private void _music(string c)(GrCall call) {
    Music music = new SMusic;
    mixin("music = Music.", c, ";");
    call.setNative(music);
}*/
