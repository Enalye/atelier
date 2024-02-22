/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
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

    library.setDescription(GrLocale.fr_FR, "Lance directement la lecture d’une musique.");
    library.setParameters(["music"]);
    library.addFunction(&_play, "play", [musicType]);

    library.setDescription(GrLocale.fr_FR, "Joue une nouvelle piste musical.
À la différence de `play` les fonctions comme `playTrack` et `pushTrack` sont limitées à une seule musique en même temps.
Jouer une nouvelle musique remplacera celle en cours et s’occupera de faire la transition entre les deux musiques automatiquement durant `fadeOut` secondes (grace à `AudioFader`).
Si aucune piste n’est en cours, la musique se lancera directement.");
    library.setParameters(["music", "fadeOut"]);
    library.addFunction(&_playTrack, "playTrack", [musicType, grFloat]);

    library.setDescription(GrLocale.fr_FR,
        "Interromp la piste musicale en cours avec un fondu de `fadeOut` secondes.");
    library.setParameters(["fadeOut"]);
    library.addFunction(&_stopTrack, "stopTrack", [grFloat]);

    library.setDescription(GrLocale.fr_FR,
        "Met en pause la piste musicale en cours avec un fondu de `fadeOut` secondes.");
    library.setParameters(["fadeOut"]);
    library.addFunction(&_pauseTrack, "pauseTrack", [grFloat]);

    library.setDescription(GrLocale.fr_FR,
        "Redémarre la piste en cours là où elle s’était arrêtée avec un fondu de `fadeIn` secondes.");
    library.setParameters(["fadeIn"]);
    library.addFunction(&_resumeTrack, "resumeTrack", [grFloat]);

    library.setDescription(GrLocale.fr_FR, "Remplace temporairement la piste musicale en cours par une nouvelle musique avec un fondu de `fadeOut` secondes.
Pour redémarrer l’ancienne piste à l’endroit où elle a été interrompu, il suffit d’appeler la fonction `popTrack`.");
    library.setParameters(["music", "fadeOut"]);
    library.addFunction(&_pushTrack, "pushTrack", [musicType, grFloat]);

    library.setDescription(GrLocale.fr_FR,
        "Termine la piste musicale en cours et reprend la dernière piste musicale interrompu via `pushTrack`.");
    library.setParameters(["fadeOut", "delay", "fadeIn"]);
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
