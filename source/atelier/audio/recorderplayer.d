module atelier.audio.recorderplayer;

import audioformats;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.config;
import atelier.audio.effect;
import atelier.audio.player;
import atelier.audio.recorder;

final class RecorderPlayer : AudioPlayer {
    private {
        AudioInputRecorder _recorder;
    }

    this(AudioInputRecorder recorder) {
        _recorder = recorder;
    }

    override size_t process(out float[Atelier_Audio_BufferSize] buffer) {
        size_t count = _recorder.read(buffer);
        if (!_recorder.isAlive() && count == 0) {
            remove();
        }
        return count;
    }
}
