/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.audio.lowpass;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_lowpass(GrModule mod) {
    mod.setModule("audio.lowpass");
    mod.setModuleInfo(GrLocale.fr_FR, "Filtre passe-bas audio");

    GrType lowPassType = mod.addNative("AudioLowPassFilter", [], "AudioEffect");

    mod.addConstructor(&_ctor, lowPassType);
}

private void _ctor(GrCall call) {
    AudioLowPassFilter lowPass = new AudioLowPassFilter;
    lowPass.leftDamping = .8f;
    lowPass.rightDamping = .8f;
    call.setNative(lowPass);
}