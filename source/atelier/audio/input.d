module atelier.audio.input;

import core.thread;
import std.exception : enforce;
import std.stdio;
import std.string;
import bindbc.sdl;

import atelier.common;
import atelier.audio.recorder;
import atelier.audio.config;

/// Représente un périphérique audio
final class AudioInput {
    private {
        /// Représente le périphérique audio
        SDL_AudioDeviceID _deviceId;
        Array!AudioRecorder _recorders;
    }

    @property {
    }

    /// Init
    this(string deviceName = "") {
        _recorders = new Array!AudioRecorder;
        _openAudio(deviceName);
    }

    /// Déinit
    ~this() {
        clear();
        _closeAudio();
    }

    void clear() {
        foreach (recorder; _recorders) {
            recorder.remove();
            recorder.process();
        }
        _recorders.clear();
    }

    void record(AudioRecorder recorder) {
        _recorders ~= recorder;
    }

    /// Initialise le module audio
    private void _openAudio(string deviceName) {
        SDL_AudioSpec desired, obtained;

        desired.freq = Atelier_Audio_SampleRate;
        desired.channels = Atelier_Audio_Channels;
        desired.samples = Atelier_Audio_FrameSize;
        desired.format = AUDIO_F32;
        desired.callback = &_callback;
        desired.userdata = cast(void*) _recorders;

        if (deviceName.length) {
            const(char)* deviceCStr = toStringz(deviceName);
            _deviceId = SDL_OpenAudioDevice(deviceCStr, 1, &desired, &obtained, 0);
        }
        else {
            _deviceId = SDL_OpenAudioDevice(null, 1, &desired, &obtained, 0);
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

        Array!AudioRecorder recorders = cast(Array!AudioRecorder) userData;
        float* buffer = cast(float*) stream;

        try {
            foreach (i, recorder; recorders) {
                recorder.write(buffer[0 .. Atelier_Audio_BufferSize]);
                recorder.process();
                if (!recorder.isAlive) {
                    recorders.mark(i);
                }
            }
            recorders.sweep();
        }
        catch (Exception e) {
        }
    }
}
