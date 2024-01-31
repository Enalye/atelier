/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script.audio.fader;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_fader(GrLibDefinition library) {
    GrType faderType = library.addNative("AudioFader", [], "AudioEffect");
    GrType splineType = grGetEnumType("Spline");

    library.addConstructor(&_ctor, faderType);

    library.addProperty(&_isFadeIn!"get", &_isFadeIn!"set", "isFadeIn", faderType, grBool);
    library.addProperty(&_spline!"get", &_spline!"set", "spline", faderType, splineType);
    library.addProperty(&_duration!"get", &_duration!"set", "duration", faderType, grFloat);
    library.addProperty(&_delay!"get", &_delay!"set", "delay", faderType, grFloat);
}

private void _ctor(GrCall call) {
    AudioFader fader = new AudioFader;
    call.setNative(fader);
}

private void _isFadeIn(string op)(GrCall call) {
    AudioFader fader = call.getNative!AudioFader(0);

    static if (op == "set") {
        fader.isFadeIn = call.getBool(1);
    }

    call.setBool(fader.isFadeIn);
}

private void _spline(string op)(GrCall call) {
    AudioFader fader = call.getNative!AudioFader(0);

    static if (op == "set") {
        fader.spline = call.getEnum!Spline(1);
    }

    call.setEnum(fader.spline);
}

private void _duration(string op)(GrCall call) {
    AudioFader fader = call.getNative!AudioFader(0);

    static if (op == "set") {
        fader.duration = call.getFloat(1);
    }

    call.setFloat(fader.duration);
}

private void _delay(string op)(GrCall call) {
    AudioFader fader = call.getNative!AudioFader(0);

    static if (op == "set") {
        fader.delay = call.getFloat(1);
    }

    call.setFloat(fader.delay);
}
