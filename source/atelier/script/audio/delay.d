module atelier.script.audio.delay;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_delay(GrModule mod) {
    mod.setModule("audio.delay");
    mod.setModuleInfo(GrLocale.fr_FR, "Délai audio");

    GrType delayType = mod.addNative("AudioDelay", [], "AudioEffect");

    mod.addConstructor(&_ctor, delayType);

    mod.addProperty(&_leftDelay!"get", &_leftDelay!"set", "leftDelay", delayType, grFloat);
    mod.addProperty(&_rightDelay!"get", &_rightDelay!"set", "rightDelay", delayType, grFloat);
}

private void _ctor(GrCall call) {
    call.setNative(new AudioDelay);
}

private void _leftDelay(string op)(GrCall call) {
    AudioDelay delay = call.getNative!AudioDelay(0);

    static if (op == "set") {
        delay.leftDelay = call.getFloat(1);
    }

    call.setFloat(delay.leftDelay);
}

private void _rightDelay(string op)(GrCall call) {
    AudioDelay delay = call.getNative!AudioDelay(0);

    static if (op == "set") {
        delay.rightDelay = call.getFloat(1);
    }

    call.setFloat(delay.rightDelay);
}
