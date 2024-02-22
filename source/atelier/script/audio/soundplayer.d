/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.audio.soundplayer;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_soundPlayer(GrLibDefinition library) {
    library.setModule("audio.soundplayer");
    library.setModuleInfo(GrLocale.fr_FR, "Instance d’un son.
Implicitement créé quand `Sound` est passé à une fonction de type `play`.
Créer manuellement cet objet permet de lui appliquer des effets avant de lancer le son.\n
**Note**: SoundPlayer ne peut être lancé qu’une seule fois, après il devient invalide.");

    GrType soundPlayerType = library.addNative("SoundPlayer", [], "AudioPlayer");
    GrType soundType = grGetNativeType("Sound");

    library.setDescription(GrLocale.fr_FR, "Lance la lecture sur le bus `master`.");
    library.setParameters(["player"]);
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
