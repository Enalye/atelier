module atelier.audio.recorder;

import audioformats;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.config;

abstract class AudioRecorder {
    private {
        bool _isAlive = true;
        SDL_AudioStream* _stream;
    }

    @property {
        final bool isAlive() const {
            return _isAlive;
        }
    }

    this(ubyte channels = Atelier_Audio_Channels, uint frequency = Atelier_Audio_SampleRate) {
        _stream = SDL_NewAudioStream(AUDIO_F32, channels, frequency, AUDIO_F32,
            Atelier_Audio_Channels, Atelier_Audio_SampleRate);
    }

    final void remove() {
        _isAlive = false;
    }

    final void write(in float[Atelier_Audio_BufferSize] buffer) {
        const int rc = SDL_AudioStreamPut(_stream, buffer.ptr,
            cast(int)(buffer.length * float.sizeof));
        if (rc < 0) {
            remove();
        }
    }

    protected final size_t _read(out float[Atelier_Audio_BufferSize] buffer) {
        int framesRead = SDL_AudioStreamGet(_stream, buffer.ptr,
            cast(int)(float.sizeof * Atelier_Audio_BufferSize));
        framesRead >>= 2;
        return framesRead;
    }

    abstract void process();
}

final class AudioInputRecorder : AudioRecorder {
    size_t read(out float[Atelier_Audio_BufferSize] buffer) {
        return _read(buffer);
    }

    override void process() {
    }
}

final class AudioFileRecorder : AudioRecorder {
    private {
        AudioStream _output;
        bool _hasClosed;
    }

    this(string path) {
        EncodingOptions options;
        options.sampleFormat = AudioSampleFormat.fp32;
        options.enableDither = true;

        _output.openToFile(path, AudioFileFormat.wav, Atelier_Audio_SampleRate,
            Atelier_Audio_Channels, options);
    }

    override void process() {
        float[Atelier_Audio_BufferSize] buffer;
        size_t count = _read(buffer);

        if (!_hasClosed) {
            _output.writeSamplesFloat(buffer[0 .. count]);
        }

        if (!_isAlive) {
            _hasClosed = true;
            _output.flush();
            _output.destroy();
        }
    }
}
