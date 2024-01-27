module atelier.audio.device;

import core.thread;
import std.exception : enforce;
import std.stdio;
import std.string;
import bindbc.sdl;

import atelier.audio.bus;

/// Représente un périphérique audio
final class AudioDevice {
    private {
        /// Représente le périphérique audio
        SDL_AudioDeviceID _deviceId;
        AudioBus _masterBus;
    }

    @property {
    }

    /// Init
    this(AudioBus masterBus, int frequency, ushort bufferSize, string deviceName = "") {
        _masterBus = masterBus;
        _openAudio(deviceName, frequency, bufferSize);
    }

    /// Déinit
    ~this() {
        _closeAudio();
    }

    /// Initialise le module audio
    private void _openAudio(string deviceName, int frequency, ushort bufferSize) {
        SDL_AudioSpec desired, obtained;

        desired.freq = frequency;
        desired.channels = 2;
        desired.samples = bufferSize;
        desired.format = AUDIO_F32;
        desired.callback = &_callback;
        desired.userdata = cast(void*) _masterBus;

        if (deviceName.length) {
            const(char)* deviceCStr = toStringz(deviceName);
            _deviceId = SDL_OpenAudioDevice(deviceCStr, 0, &desired, &obtained, 0);
        }
        else {
            _deviceId = SDL_OpenAudioDevice(null, 0, &desired, &obtained, 0);
        }
        play();
    }

    /// Ferme le module audio
    private void _closeAudio() {
        SDL_CloseAudioDevice(_deviceId);
        _deviceId = 0;
    }

    void play() {
        SDL_PauseAudioDevice(_deviceId, 0);
    }

    void stop() {
        SDL_PauseAudioDevice(_deviceId, 1);
    }

    static private extern (C) void _callback(void* userData, ubyte* stream, int len) nothrow {
        len >>= 2; // 8 bit -> 32 bit
        float* buffer = cast(float*) stream;

        AudioBus masterBus = cast(AudioBus) userData;

        for (int i; i < len; i++) {
            buffer[i] = 0f;
        }

        try {
            masterBus.render(buffer, len);
        }
        catch (Exception e) {
        }
    }
}
