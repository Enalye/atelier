/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.audio.sound;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_sound(GrLibDefinition library) {
    library.setModule("audio.sound");
    library.setModuleInfo(GrLocale.fr_FR, "Représente un fichier audio.
Le son est entièrement décodé en mémoire.
Il est recommandé de reserver cette classe pour des fichiers peu volumineux.");
    library.setModuleDescription(GrLocale.fr_FR,
        "Sound est une ressource définie dans un fichier `.res` (voir la page [ressources](/resources#Sound)).");

    GrType soundType = library.addNative("Sound");

    library.addConstructor(&_ctor, soundType, [grString]);

    library.setDescription(GrLocale.fr_FR, "Lance la lecture sur le bus `master`.");
    library.setParameters(["sound"]);
    library.addFunction(&_play, "play", [soundType]);

    //library.addProperty(&_volume!"get", &_volume!"set", "volume", soundType, grFloat);
}

private void _ctor(GrCall call) {
    Sound sound = Atelier.res.get!Sound(call.getString(0));
    call.setNative(sound);
}

private void _play(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    Atelier.audio.play(new SoundPlayer(sound));
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
