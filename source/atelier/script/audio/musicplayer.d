/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.audio.musicplayer;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_musicPlayer(GrLibDefinition library) {
    library.setModule("audio.musicplayer");
    library.setModuleInfo(GrLocale.fr_FR, "Instance d’une musique");

    GrType musicPlayerType = library.addNative("MusicPlayer", [], "AudioPlayer");
    GrType musicType = grGetNativeType("Music");

    library.addConstructor(&_ctor, musicPlayerType, [musicType]);

    //library.addProperty(&_volume!"get", &_volume!"set", "volume", musicType, grFloat);
}

private void _ctor(GrCall call) {
    Music music = call.getNative!Music(0);
    call.setNative(new MusicPlayer(music));
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
