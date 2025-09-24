module atelier.script.audio.sound;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_sound(GrModule mod) {
    mod.setModule("audio.sound");
    mod.setModuleInfo(GrLocale.fr_FR, "Représente un fichier audio.
Le son est entièrement décodé en mémoire.
Il est recommandé de reserver cette classe pour des fichiers peu volumineux.");
    mod.setModuleDescription(GrLocale.fr_FR,
        "Sound est une ressource définie dans un fichier `.ffd` (voir la page [ressources](/resources#Sound)).");

    GrType soundType = mod.addNative("Sound");

    mod.addConstructor(&_ctor, soundType, [grString]);

    mod.setDescription(GrLocale.fr_FR, "Lance la lecture sur le bus `master`.");
    mod.setParameters(["sound"]);
    mod.addFunction(&_play, "play", [soundType]);

    mod.setDescription(GrLocale.fr_FR, "Lance la lecture sur le bus `master`.");
    mod.setParameters(["sound", "speed"]);
    mod.addFunction(&_play2, "play", [soundType, grFloat]);

    //mod.addProperty(&_volume!"get", &_volume!"set", "volume", soundType, grFloat);
}

private void _ctor(GrCall call) {
    Sound sound = Atelier.res.get!Sound(call.getString(0));
    call.setNative(sound);
}

private void _play(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    Atelier.audio.play(new SoundPlayer(sound));
}

private void _play2(GrCall call) {
    Sound sound = call.getNative!Sound(0);
    GrFloat speed = call.getFloat(1);
    Atelier.audio.play(new SoundPlayer(sound, speed));
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
