/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.audio.gain;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_gain(GrLibDefinition library) {
    GrType gainType = library.addNative("AudioGain", [], "AudioEffect");

    library.addConstructor(&_ctor, gainType);

    library.addProperty(&_volume!"get", &_volume!"set", "volume", gainType, grFloat);
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
