/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.audio.musicplayer;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_musicPlayer(GrModule mod) {
    mod.setModule("audio.musicplayer");
    mod.setModuleInfo(GrLocale.fr_FR, "Instance d’une musique.
Implicitement créé quand `Music` est passé à une fonction de type `play`.
Créer manuellement cet objet permet de lui appliquer des effets avant de lancer la musique.\n
**Note**: MusicPlayer ne peut être lancé qu’une seule fois, après il devient invalide.");

    GrType musicPlayerType = mod.addNative("MusicPlayer", [], "AudioPlayer");
    GrType musicType = grGetNativeType("Music");

    mod.setParameters(["music"]);
    mod.addConstructor(&_ctor, musicPlayerType, [musicType]);

    //mod.addProperty(&_volume!"get", &_volume!"set", "volume", musicType, grFloat);
    mod.addFunction(&_pause, "pause", [musicPlayerType, grFloat]);
    mod.addFunction(&_resume, "resume", [musicPlayerType, grFloat]);
    mod.addFunction(&_stop, "stop", [musicPlayerType, grFloat]);
}

private void _ctor(GrCall call) {
    Music music = call.getNative!Music(0);
    call.setNative(new MusicPlayer(music));
}

private void _pause(GrCall call) {
    MusicPlayer player = call.getNative!MusicPlayer(0);
    player.pause(call.getFloat(1));
}

private void _resume(GrCall call) {
    MusicPlayer player = call.getNative!MusicPlayer(0);
    player.resume(call.getFloat(1));
}

private void _stop(GrCall call) {
    MusicPlayer player = call.getNative!MusicPlayer(0);
    player.stop(call.getFloat(1));
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
