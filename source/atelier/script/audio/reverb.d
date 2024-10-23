/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.audio.reverb;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_reverb(GrModule mod) {
    mod.setModule("audio.reverb");
    mod.setModuleInfo(GrLocale.fr_FR, "Règle la réverbération de l’audio");

    GrType reverbType = mod.addNative("AudioReverb", [], "AudioEffect");

    mod.addConstructor(&_ctor, reverbType, [grFloat, grFloat]);

    mod.addFunction(&_setMix, "setMix", [reverbType, grFloat, grFloat]);
}

private void _ctor(GrCall call) {
    AudioReverb reverb = new AudioReverb(call.getFloat(0), call.getFloat(1));
    call.setNative(reverb);
}

private void _setMix(GrCall call) {
    AudioReverb reverb = call.getNative!AudioReverb(0);
    reverb.setMix(call.getFloat(1), call.getFloat(2));
}
