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
    library.setModule("audio.music");
    library.setModuleInfo(GrLocale.fr_FR, "Représente un fichier audio");

    GrType musicType = library.addNative("Music");

    library.addConstructor(&_ctor, musicType, [grString]);

    library.addFunction(&_play, "play", [musicType]);
    library.addFunction(&_playTrack, "playTrack", [musicType, grFloat]);
    library.addFunction(&_stopTrack, "stopTrack", [grFloat]);
    library.addFunction(&_pauseTrack, "pauseTrack", [grFloat]);
    library.addFunction(&_resumeTrack, "resumeTrack", [grFloat]);
    library.addFunction(&_pushTrack, "pushTrack", [musicType, grFloat]);
    library.addFunction(&_popTrack, "popTrack", [grFloat, grFloat, grFloat]);

    //library.addProperty(&_volume!"get", &_volume!"set", "volume", musicType, grFloat);
}

private void _ctor(GrCall call) {
    Music music = Atelier.res.get!Music(call.getString(0));
    call.setNative(music);
}

private void _play(GrCall call) {
    Music music = call.getNative!Music(0);
    Atelier.audio.play(new MusicPlayer(music));
}

private void _playTrack(GrCall call) {
    Music music = call.getNative!Music(0);
    float fadeOut = call.getFloat(1);
    Atelier.audio.playTrack(music, fadeOut);
}

private void _stopTrack(GrCall call) {
    float fadeOut = call.getFloat(0);
    Atelier.audio.stopTrack(fadeOut);
}

private void _pauseTrack(GrCall call) {
    float fadeOut = call.getFloat(0);
    Atelier.audio.pauseTrack(fadeOut);
}

private void _resumeTrack(GrCall call) {
    float fadeIn = call.getFloat(0);
    Atelier.audio.resumeTrack(fadeIn);
}

private void _pushTrack(GrCall call) {
    Music music = call.getNative!Music(0);
    float fadeOut = call.getFloat(1);
    Atelier.audio.pushTrack(music, fadeOut);
}

private void _popTrack(GrCall call) {
    float fadeOut = call.getFloat(0);
    float delay = call.getFloat(1);
    float fadeIn = call.getFloat(2);
    Atelier.audio.popTrack(fadeOut, delay, fadeIn);
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
