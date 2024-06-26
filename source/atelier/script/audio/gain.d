/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.audio.gain;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_gain(GrModule mod) {
    mod.setModule("audio.gain");
    mod.setModuleInfo(GrLocale.fr_FR, "Amplifie l’audio");

    GrType gainType = mod.addNative("AudioGain", [], "AudioEffect");

    mod.addConstructor(&_ctor, gainType);

    mod.addProperty(&_volume!"get", &_volume!"set", "volume", gainType, grFloat);
}

private void _ctor(GrCall call) {
    AudioGain gain = new AudioGain;
    call.setNative(gain);
}

private void _volume(string op)(GrCall call) {
    AudioGain gain = call.getNative!AudioGain(0);

    static if (op == "set") {
        gain.volume = call.getFloat(1);
    }

    call.setFloat(gain.volume);
}
