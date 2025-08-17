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

    mod.addProperty(&_leftDamping!"get", &_leftDamping!"set",
        "leftDamping", lowPassType, grFloat);
    mod.addProperty(&_rightDamping!"get", &_rightDamping!"set",
        "rightDamping", lowPassType, grFloat);
}

private void _ctor(GrCall call) {
    call.setNative(new AudioLowPassFilter);
}

private void _leftDamping(string op)(GrCall call) {
    AudioLowPassFilter lowPass = call.getNative!AudioLowPassFilter(0);

    static if (op == "set") {
        lowPass.leftDamping = call.getFloat(1);
    }

    call.setFloat(lowPass.leftDamping);
}

private void _rightDamping(string op)(GrCall call) {
    AudioLowPassFilter lowPass = call.getNative!AudioLowPassFilter(0);

    static if (op == "set") {
        lowPass.rightDamping = call.getFloat(1);
    }

    call.setFloat(lowPass.rightDamping);
}
