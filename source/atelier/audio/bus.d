module atelier.audio.bus;

import std.stdio;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.voice;

final class AudioBus {
    private {
        bool _isMaster;
        AudioBus _parentBus;
        Array!AudioBus _busses;
        Array!Voice _voices;
        bool _isAlive = true;
    }

    @property {
        bool isAlive() const {
            return _isAlive;
        }
    }

    package static AudioBus createMaster() {
        AudioBus masterBus = new AudioBus;
        masterBus._isMaster = true;
        return masterBus;
    }

    this() {
        _busses = new Array!AudioBus;
        _voices = new Array!Voice;
    }

    void play(Voice voice) {
        _voices ~= voice;
    }

    void connectToMaster() {
        if (_isMaster)
            return;

        connectTo(Atelier.audio.master);
    }

    void connectTo(AudioBus bus) {
        if (_isMaster)
            return;

        disconnect();
        _parentBus = bus;
        _parentBus._busses ~= this; // TODO: Mutexer tout ça
    }

    void disconnect() {
        if (_isMaster)
            return;

        if (_parentBus) {
            foreach (i, childBus; _parentBus._busses) {
                if (childBus == this) {
                    _parentBus._busses.mark(i);
                    break;
                }
            }
            _parentBus._busses.sweep();
        }
    }

    void render(float* buffer, size_t len) {
        foreach (bus; _busses) {
            bus.render(buffer, len);
        }

        foreach (i, voice; _voices) {
            voice.render(buffer, len);

            if (!voice.isAlive)
                _voices.mark(i);
        }

        _voices.sweep();
    }
}
