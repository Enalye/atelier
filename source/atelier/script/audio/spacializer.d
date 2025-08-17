module atelier.script.audio.spacializer;

import grimoire;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.script.util;

package void loadLibAudio_spacializer(GrModule mod) {
    mod.setModule("audio.spacializer");
    mod.setModuleInfo(GrLocale.fr_FR, "Délai audio");

    GrType spacializerType = mod.addNative("AudioSpacializer", [], "AudioEffect");
    GrType vec2fType = grGetNativeType("Vec2", [grFloat]);
    GrType splineType = grGetEnumType("Spline");

    mod.addConstructor(&_ctor, spacializerType);

    mod.addProperty(&_position!"get", &_position!"set", "position", spacializerType, vec2fType);
    mod.addProperty(&_attenuationSpline!"get", &_attenuationSpline!"set",
        "attenuationSpline", spacializerType, splineType);
    mod.addProperty(&_orientationSpline!"get", &_orientationSpline!"set",
        "orientationSpline", spacializerType, splineType);
    mod.addProperty(&_minDistance!"get", &_minDistance!"set",
        "minDistance", spacializerType, grFloat);
    mod.addProperty(&_maxDistance!"get", &_maxDistance!"set",
        "maxDistance", spacializerType, grFloat);
    mod.addProperty(&_minVolume!"get", &_minVolume!"set", "minVolume",
        spacializerType, grFloat);
    mod.addProperty(&_maxVolume!"get", &_maxVolume!"set", "maxVolume",
        spacializerType, grFloat);
}

private void _ctor(GrCall call) {
    call.setNative(new AudioSpacializer);
}

private void _position(string op)(GrCall call) {
    AudioSpacializer spacializer = call.getNative!AudioSpacializer(0);

    static if (op == "set") {
        spacializer.position = call.getNative!SVec2f(1);
    }

    call.setNative(svec2(spacializer.position));
}

private void _attenuationSpline(string op)(GrCall call) {
    AudioSpacializer spacializer = call.getNative!AudioSpacializer(0);

    static if (op == "set") {
        spacializer.attenuationSpline = call.getEnum!Spline(1);
    }

    call.setEnum(spacializer.attenuationSpline);
}

private void _orientationSpline(string op)(GrCall call) {
    AudioSpacializer spacializer = call.getNative!AudioSpacializer(0);

    static if (op == "set") {
        spacializer.orientationSpline = call.getEnum!Spline(1);
    }

    call.setEnum(spacializer.orientationSpline);
}

private void _minDistance(string op)(GrCall call) {
    AudioSpacializer spacializer = call.getNative!AudioSpacializer(0);

    static if (op == "set") {
        spacializer.minDistance = call.getFloat(1);
    }

    call.setFloat(spacializer.minDistance);
}

private void _maxDistance(string op)(GrCall call) {
    AudioSpacializer spacializer = call.getNative!AudioSpacializer(0);

    static if (op == "set") {
        spacializer.maxDistance = call.getFloat(1);
    }

    call.setFloat(spacializer.maxDistance);
}

private void _minVolume(string op)(GrCall call) {
    AudioSpacializer spacializer = call.getNative!AudioSpacializer(0);

    static if (op == "set") {
        spacializer.minVolume = call.getFloat(1);
    }

    call.setFloat(spacializer.minVolume);
}

private void _maxVolume(string op)(GrCall call) {
    AudioSpacializer spacializer = call.getNative!AudioSpacializer(0);

    static if (op == "set") {
        spacializer.maxVolume = call.getFloat(1);
    }

    call.setFloat(spacializer.maxVolume);
}
