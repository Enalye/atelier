module atelier.etabli.core.midi.player;

import std.algorithm : clamp, sort;
import std.conv : to;
import core.thread;

import minuit;

import atelier.common;
import atelier.etabli.core.midi.clock;
import atelier.etabli.core.midi.device;

private {
    enum ChannelCount = 16;

    struct ChannelData {
        InstrumentEvent[] instrumentEvents;
        size_t instrumentTop;

        InitEvent[] initEvents;
        size_t initTop;

        NoteEvent[] noteEvents;
        size_t startNoteTop, endNoteTop;

        EffectEvent[] effectEvents;
        size_t startEffectTop, endEffectTop;

        void start() {
            instrumentEvents.length = 0;
            instrumentTop = 0;
            initEvents.length = 0;
            initTop = 0;
            noteEvents.length = 0;
            startNoteTop = 0;
            endNoteTop = 0;
            effectEvents.length = 0;
            startEffectTop = 0;
            endEffectTop = 0;
        }

        void setup() {
            sort!((a, b) => (a.block < b.block))(instrumentEvents);
            sort!((a, b) => (a.block < b.block))(initEvents);
            sort!((a, b) => (a.startBlock < b.startBlock))(noteEvents);
            sort!((a, b) => (a.startBlock < b.startBlock))(effectEvents);
        }

        void scale(double factor) {
            for (size_t i; i < noteEvents.length; ++i) {
                instrumentEvents[i].time *= factor;
                initEvents[i].time *= factor;
                noteEvents[i].startTime *= factor;
                noteEvents[i].endTime *= factor;
                effectEvents[i].startTime *= factor;
                effectEvents[i].endTime *= factor;
            }
        }
    }

    MnOutput _output;
    MidiThread _thread;
    TempoEvent[] _tempoEvents;
    __gshared ChannelData[ChannelCount] _channels;

    uint _patternChannel;
    double _patternStart = 0;
    double _patternDuration = 0;
    double _patternScale = 0;
    double _patternSteps = 0;
}

private final class TempoEvent {
    double startBlock, endBlock;
    float startValue, endValue;

    SplineFunc spline;

    double integrate(double t) {
        if (t <= 0) {
            return 0;
        }

        double value = 0;
        double steps = 100.0;
        double step = t / steps;

        for (double i = 0; i <= t; i += step) {
            value += lerp(startValue, endValue, spline(t));
        }

        value /= steps;

        return (60_000.0 * t) / value;
    }
}

private final class NoteEvent {
    double startBlock, endBlock;
    double startTime, endTime;
    uint value, velocity;
}

private {
    immutable ubyte[] _ccList = [
        1, 5, 7, 10, 11, 64, 65, 66, 67, 68, 71, 72, 73, 74, 75, 76, 77, 78, 84,
        91, 93
    ];
}

private final class EffectEvent {
    double startBlock, endBlock;
    double startTime, endTime;
    float startValue, endValue;
    uint type;
    SplineFunc spline;

    void apply(MnOutput output, ubyte channel, double time) {
        import std.math : round;

        if (type >= _ccList.length + 2)
            return;

        float t = (time - startTime) / (endTime - startTime);
        float value = lerp(startValue, endValue, spline(t));

        switch (type) {
        case 1: // Pitch Bend
            value += 8192f;
            break;
        case 5: // Panning
            value += 64f;
            break;
        default:
            break;
        }

        int ivalue = cast(int) round(value);

        switch (type) {
        case 0: // After Touch
            ivalue = clamp(ivalue, 0, 127);
            output.send(MnMidiStatus.AfterTouch | channel, cast(ubyte) ivalue);
            break;
        case 1: // Pitch Bend
            ivalue = clamp(ivalue, 0, 16_383);
            ubyte msb = (ivalue & 0x3F80) >> 7;
            ubyte lsb = ivalue & 0x7F;
            output.send(MnMidiStatus.PitchBend | channel, lsb, msb);
            break;
        default:
            ivalue = clamp(ivalue, 0, 127);
            output.send(MnMidiStatus.ControlChange | channel, _ccList[type - 2], cast(ubyte) ivalue);
            break;
        }
    }
}

private final class InstrumentEvent {
    double block;
    double time;
    uint pc, msb, lsb;
}

private final class InitEvent {
    double block;
    double time;
    int[] values;

    void apply(MnOutput output, ubyte channel) {
        for (uint i; i < _ccList.length; ++i) {
            int ivalue;

            if (i < values.length) {
                ivalue = values[i];
            }
            else {
                switch (i) {
                case 6: // Expression
                    ivalue = 127;
                    break;
                case 4: // Volume
                    ivalue = 100;
                    break;
                default:
                    ivalue = 0;
                    break;
                }
            }

            switch (i) {
            case 1: // Pitch Bend
                ivalue += 8192;
                break;
            case 5: // Panning
                ivalue += 64;
                break;
            default:
                break;
            }

            switch (i) {
            case 0: // After Touch
                ivalue = clamp(ivalue, 0, 127);
                output.send(MnMidiStatus.AfterTouch | channel, cast(ubyte) ivalue);
                break;
            case 1: // Pitch Bend
                ivalue = clamp(ivalue, 0, 16_383);
                ubyte msb = (ivalue & 0x3F80) >> 7;
                ubyte lsb = ivalue & 0x7F;
                output.send(MnMidiStatus.PitchBend | channel, lsb, msb);
                break;
            default:
                ivalue = clamp(ivalue, 0, 127);
                output.send(MnMidiStatus.ControlChange | channel, _ccList[i - 2], cast(ubyte) ivalue);
                break;
            }
        }
    }
}

void midiStartSession() {
    midiClosePattern();
    _tempoEvents.length = 0;
    for (size_t ch; ch < ChannelCount; ++ch) {
        _channels[ch].start();
    }
}

void midiEndSession() {
    sort!((a, b) => (a.startBlock < b.startBlock))(_tempoEvents);
    for (size_t ch; ch < ChannelCount; ++ch) {
        _channels[ch].setup();
    }
}

void midiAddTempoEvent(uint start, uint duration, uint startValue, uint endValue, string spline_) {
    TempoEvent event = new TempoEvent;
    event.startBlock = start;
    event.endBlock = start + duration;
    event.startValue = startValue;
    event.endValue = endValue;
    Spline spline = Spline.linear;
    try {
        spline = to!Spline(spline_);
    }
    catch (Exception e) {

    }
    event.spline = getSplineFunc(spline);
    _tempoEvents ~= event;
}

void midiOpenPattern(uint channel, uint start, uint duration, uint steps) {
    _patternChannel = channel;
    _patternStart = start;
    _patternDuration = duration;
    _patternSteps = steps;
    _patternScale = _patternDuration / _patternSteps;
}

void midiClosePattern() {
    _patternChannel = 0;
    _patternStart = 0;
    _patternDuration = 0;
    _patternScale = 0;
    _patternSteps = 0;
}

void midiSetPatternInstrument(uint pc, uint msb, uint lsb) {
    InstrumentEvent event = new InstrumentEvent;
    event.block = _patternStart;
    event.pc = pc;
    event.msb = msb;
    event.lsb = lsb;
    _channels[_patternChannel].instrumentEvents ~= event;
}

void midiSetPatternInitialState(int[] initializationValues) {
    InitEvent event = new InitEvent;
    event.block = _patternStart;
    event.values = initializationValues;
    _channels[_patternChannel].initEvents ~= event;
}

void midiAddNoteEvent(uint start, uint duration, uint note, uint velocity) {
    NoteEvent event = new NoteEvent;
    event.startBlock = start * _patternScale + _patternStart;
    event.endBlock = (start + duration) * _patternScale + _patternStart;
    event.value = note;
    event.velocity = velocity;
    _channels[_patternChannel].noteEvents ~= event;
}

void midiAddEffectEvent(uint start, uint duration, uint type, uint startValue,
    uint endValue, string spline_) {
    EffectEvent event = new EffectEvent;
    event.startBlock = start * _patternScale + _patternStart;
    event.endBlock = (start + duration) * _patternScale + _patternStart;
    event.type = type;
    event.startValue = startValue;
    event.endValue = endValue;
    Spline spline = Spline.linear;
    try {
        spline = to!Spline(spline_);
    }
    catch (Exception e) {

    }
    event.spline = getSplineFunc(spline);
    _channels[_patternChannel].effectEvents ~= event;
}

void midiPlayNote(uint note, uint velocity) {
    if (!_output) {
        _output = getMidiOut();
    }

    note = clamp(note, 0, 127);
    velocity = clamp(velocity, 0, 127);

    _output.send(cast(ubyte)(MnMidiStatus.NoteOn | 0), cast(ubyte) note, cast(ubyte) velocity);
}

void midiStopNote(uint note) {
    if (!_output) {
        _output = getMidiOut();
    }

    note = clamp(note, 0, 127);
    _output.send(cast(ubyte)(MnMidiStatus.NoteOff | 0), cast(ubyte) note, 0);
}

double[] midiProcess(uint blocksCount, double startBpm = 120.0) {
    double lastTempoBlock = 0;
    double lastTempoValue = startBpm;
    double lastTempoTotalTime = 0;
    size_t tempoTop = 0;

    double[] blocksTime;
    double currentBlock = 1.0;

    for (; tempoTop < _tempoEvents.length; ++tempoTop) {
        double startBlock = _tempoEvents[tempoTop].startBlock;
        double endBlock = _tempoEvents[tempoTop].endBlock;

        while (currentBlock <= startBlock) {
            double deltaBlock = currentBlock - lastTempoBlock;
            blocksTime ~= (deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
            currentBlock += 1.0;
        }

        for (uint ch; ch < ChannelCount; ++ch) {
            while (_channels[ch].instrumentTop < _channels[ch].instrumentEvents.length &&
                _channels[ch].instrumentEvents[_channels[ch].instrumentTop].block < startBlock) {
                double deltaBlock = _channels[ch].instrumentEvents[_channels[ch].instrumentTop].block -
                    lastTempoBlock;
                _channels[ch].instrumentEvents[_channels[ch].instrumentTop].time = (
                    deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
                _channels[ch].instrumentTop++;
            }

            while (_channels[ch].initTop < _channels[ch].initEvents.length &&
                _channels[ch].initEvents[_channels[ch].initTop].block < startBlock) {
                double deltaBlock = _channels[ch].initEvents[_channels[ch].initTop].block -
                    lastTempoBlock;
                _channels[ch].initEvents[_channels[ch].initTop].time = (
                    deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
                _channels[ch].initTop++;
            }

            while (_channels[ch].startNoteTop < _channels[ch].noteEvents.length &&
                _channels[ch].noteEvents[_channels[ch].startNoteTop].startBlock < startBlock) {
                double deltaBlock = _channels[ch].noteEvents[_channels[ch].startNoteTop].startBlock -
                    lastTempoBlock;
                _channels[ch].noteEvents[_channels[ch].startNoteTop].startTime = (
                    deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
                _channels[ch].startNoteTop++;
            }

            while (_channels[ch].startEffectTop < _channels[ch].effectEvents.length &&
                _channels[ch].effectEvents[_channels[ch].startEffectTop].startBlock < startBlock) {
                double deltaBlock = _channels[ch].effectEvents[_channels[ch].startEffectTop].startBlock -
                    lastTempoBlock;
                _channels[ch].effectEvents[_channels[ch].startEffectTop].startTime = (
                    deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
                _channels[ch].startEffectTop++;
            }
        }

        double deltaTempoStartBlock = startBlock - lastTempoBlock;
        double startTime = (deltaTempoStartBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
        lastTempoBlock = startBlock;
        lastTempoTotalTime = startTime;
        lastTempoValue = _tempoEvents[tempoTop].startValue;

        double blockDuration = endBlock - startBlock;

        while (currentBlock <= endBlock) {
            double deltaBlock = currentBlock - lastTempoBlock;
            double t = deltaBlock / blockDuration;
            double value = _tempoEvents[tempoTop].integrate(t);
            blocksTime ~= value + lastTempoTotalTime;
            currentBlock += 1.0;
        }

        for (uint ch; ch < ChannelCount; ++ch) {
            while (_channels[ch].instrumentTop < _channels[ch].instrumentEvents.length &&
                _channels[ch].instrumentEvents[_channels[ch].instrumentTop].block <= endBlock) {
                double deltaBlock = _channels[ch].instrumentEvents[_channels[ch].instrumentTop].block -
                    lastTempoBlock;
                double t = deltaBlock / blockDuration;
                double value = _tempoEvents[tempoTop].integrate(t);

                _channels[ch].instrumentEvents[_channels[ch].instrumentTop].time =
                    value + lastTempoTotalTime;
                _channels[ch].instrumentTop++;
            }

            while (_channels[ch].initTop < _channels[ch].initEvents.length &&
                _channels[ch].initEvents[_channels[ch].initTop].block <= endBlock) {
                double deltaBlock = _channels[ch].initEvents[_channels[ch].initTop].block -
                    lastTempoBlock;
                double t = deltaBlock / blockDuration;
                double value = _tempoEvents[tempoTop].integrate(t);

                _channels[ch].initEvents[_channels[ch].initTop].time = value + lastTempoTotalTime;
                _channels[ch].initTop++;
            }

            while (_channels[ch].startNoteTop < _channels[ch].noteEvents.length &&
                _channels[ch].noteEvents[_channels[ch].startNoteTop].startBlock <= endBlock) {
                double deltaBlock = _channels[ch].noteEvents[_channels[ch].startNoteTop].startBlock -
                    lastTempoBlock;
                double t = deltaBlock / blockDuration;
                double value = _tempoEvents[tempoTop].integrate(t);

                _channels[ch].noteEvents[_channels[ch].startNoteTop].startTime =
                    value + lastTempoTotalTime;
                _channels[ch].startNoteTop++;
            }

            while (_channels[ch].startEffectTop < _channels[ch].effectEvents.length &&
                _channels[ch].effectEvents[_channels[ch].startEffectTop].startBlock <= endBlock) {
                double deltaBlock = _channels[ch].effectEvents[_channels[ch].startEffectTop].startBlock -
                    lastTempoBlock;
                double t = deltaBlock / blockDuration;
                double value = _tempoEvents[tempoTop].integrate(t);

                _channels[ch].effectEvents[_channels[ch].startEffectTop].startTime =
                    value + lastTempoTotalTime;
                _channels[ch].startEffectTop++;
            }
        }

        double endTime = _tempoEvents[tempoTop].integrate(1.0) + lastTempoTotalTime;
        lastTempoBlock = startBlock;
        lastTempoTotalTime = endTime;
        lastTempoValue = _tempoEvents[tempoTop].endValue;
    }

    if (tempoTop + 1 >= _tempoEvents.length) {
        while (currentBlock <= blocksCount) {
            double deltaBlock = currentBlock - lastTempoBlock;
            blocksTime ~= (deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
            currentBlock += 1.0;
        }

        for (uint ch; ch < ChannelCount; ++ch) {
            while (_channels[ch].instrumentTop < _channels[ch].instrumentEvents.length) {
                double deltaBlock = _channels[ch].instrumentEvents[_channels[ch].instrumentTop].block -
                    lastTempoBlock;
                _channels[ch].instrumentEvents[_channels[ch].instrumentTop].time = (
                    deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
                _channels[ch].instrumentTop++;
            }

            while (_channels[ch].initTop < _channels[ch].initEvents.length) {
                double deltaBlock = _channels[ch].initEvents[_channels[ch].initTop].block -
                    lastTempoBlock;
                _channels[ch].initEvents[_channels[ch].initTop].time = (
                    deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
                _channels[ch].initTop++;
            }

            while (_channels[ch].startNoteTop < _channels[ch].noteEvents.length) {
                double deltaBlock = _channels[ch].noteEvents[_channels[ch].startNoteTop].startBlock -
                    lastTempoBlock;
                _channels[ch].noteEvents[_channels[ch].startNoteTop].startTime = (
                    deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
                _channels[ch].startNoteTop++;
            }

            while (_channels[ch].startEffectTop < _channels[ch].effectEvents.length) {
                double deltaBlock = _channels[ch].effectEvents[_channels[ch].startEffectTop].startBlock -
                    lastTempoBlock;
                _channels[ch].effectEvents[_channels[ch].startEffectTop].startTime = (
                    deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
                _channels[ch].startEffectTop++;
            }
        }
    }

    lastTempoBlock = 0;
    lastTempoValue = startBpm;
    lastTempoTotalTime = 0;
    tempoTop = 0;

    for (; tempoTop < _tempoEvents.length; ++tempoTop) {
        double startBlock = _tempoEvents[tempoTop].startBlock;
        double endBlock = _tempoEvents[tempoTop].endBlock;

        for (uint ch; ch < ChannelCount; ++ch) {
            while (_channels[ch].endNoteTop < _channels[ch].noteEvents.length &&
                _channels[ch].noteEvents[_channels[ch].endNoteTop].endBlock < startBlock) {
                double deltaBlock = _channels[ch].noteEvents[_channels[ch].endNoteTop].endBlock -
                    lastTempoBlock;
                _channels[ch].noteEvents[_channels[ch].endNoteTop].endTime = (
                    deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
                _channels[ch].endNoteTop++;
            }

            while (_channels[ch].endEffectTop < _channels[ch].effectEvents.length &&
                _channels[ch].effectEvents[_channels[ch].endEffectTop].endBlock < startBlock) {
                double deltaBlock = _channels[ch].effectEvents[_channels[ch].endEffectTop].endBlock -
                    lastTempoBlock;
                _channels[ch].effectEvents[_channels[ch].endEffectTop].endTime = (
                    deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
                _channels[ch].endEffectTop++;
            }
        }

        double deltaTempoStartBlock = startBlock - lastTempoBlock;
        double startTime = (deltaTempoStartBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
        lastTempoBlock = startBlock;
        lastTempoTotalTime = startTime;
        lastTempoValue = _tempoEvents[tempoTop].startValue;

        double blockDuration = endBlock - startBlock;

        for (uint ch; ch < ChannelCount; ++ch) {
            while (_channels[ch].endNoteTop < _channels[ch].noteEvents.length &&
                _channels[ch].noteEvents[_channels[ch].endNoteTop].endBlock <= endBlock) {
                double deltaBlock = _channels[ch].noteEvents[_channels[ch].endNoteTop].endBlock -
                    lastTempoBlock;
                double t = deltaBlock / blockDuration;
                double value = _tempoEvents[tempoTop].integrate(t);

                _channels[ch].noteEvents[_channels[ch].endNoteTop].endTime =
                    value + lastTempoTotalTime;
                _channels[ch].endNoteTop++;
            }

            while (_channels[ch].endEffectTop < _channels[ch].effectEvents.length &&
                _channels[ch].effectEvents[_channels[ch].endEffectTop].endBlock <= endBlock) {
                double deltaBlock = _channels[ch].effectEvents[_channels[ch].endEffectTop].endBlock -
                    lastTempoBlock;
                double t = deltaBlock / blockDuration;
                double value = _tempoEvents[tempoTop].integrate(t);

                _channels[ch].effectEvents[_channels[ch].endEffectTop].endTime =
                    value + lastTempoTotalTime;
                _channels[ch].endEffectTop++;
            }
        }

        double endTime = _tempoEvents[tempoTop].integrate(1.0) + lastTempoTotalTime;
        lastTempoBlock = startBlock;
        lastTempoTotalTime = endTime;
        lastTempoValue = _tempoEvents[tempoTop].endValue;
    }

    if (tempoTop + 1 >= _tempoEvents.length) {
        for (uint ch; ch < ChannelCount; ++ch) {
            while (_channels[ch].endNoteTop < _channels[ch].noteEvents.length) {
                double deltaBlock = _channels[ch].noteEvents[_channels[ch].endNoteTop].endBlock -
                    lastTempoBlock;
                _channels[ch].noteEvents[_channels[ch].endNoteTop].endTime = (
                    deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
                _channels[ch].endNoteTop++;
            }
        }

        for (uint ch; ch < ChannelCount; ++ch) {
            while (_channels[ch].endEffectTop < _channels[ch].effectEvents.length) {
                double deltaBlock = _channels[ch].effectEvents[_channels[ch].endEffectTop].endBlock -
                    lastTempoBlock;
                _channels[ch].effectEvents[_channels[ch].endEffectTop].endTime = (
                    deltaBlock * 60_000.0 / lastTempoValue) + lastTempoTotalTime;
                _channels[ch].endEffectTop++;
            }
        }
    }

    return blocksTime;
}

void midiPlay() {
    if (!_output) {
        _output = getMidiOut();
    }

    midiStop();

    if (!_output)
        return;

    _thread = new MidiThread;
    _thread.start();
}

void midiStop() {
    if (!_output) {
        _output = getMidiOut();
    }

    if (_thread) {
        _thread.isRunning = false;
        _thread = null;
    }

    if (!_output)
        return;

    foreach (ubyte c; 0 .. ChannelCount) {
        _output.send(0xB0 | c, 0x7B, 0x0);
    }
}

bool midiIsPlaying() {
    if (_thread) {
        return true;
    }
    return false;
}

bool midiIsFinished() {
    if (_thread) {
        return _thread.isFinished;
    }
    return false;
}

double midiGetTime() {
    if (_thread) {
        return _thread.midiTime;
    }
    return 0.0;
}

private final class MidiChannel {
    private {
        ubyte _channel;
        MnOutput _output;

        InstrumentEvent[] _instruments;
        size_t _instrumentTop;

        InitEvent[] _initStates;
        size_t _initTop;

        NoteEvent[] _notes;
        size_t _noteTop;
        Array!NoteEvent _playedNotes;

        EffectEvent[] _effects;
        size_t _effectTop;
        Array!EffectEvent _playedEffects;
    }

    this(ubyte channel, InstrumentEvent[] instruments, InitEvent[] initValues,
        NoteEvent[] notes, EffectEvent[] effects) {
        _channel = channel;
        _instruments = instruments;
        _initStates = initValues;
        _notes = notes;
        _effects = effects;
        _playedNotes = new Array!NoteEvent;
        _playedEffects = new Array!EffectEvent;
        _output = getMidiOut();
    }

    bool update(double time) {
        while (_instrumentTop < _instruments.length && _instruments[_instrumentTop].time <= time) {
            InstrumentEvent event = _instruments[_instrumentTop];

            _output.send(cast(ubyte)(MnMidiStatus.ControlChange | _channel), 0,
                cast(ubyte) event.msb);
            _output.send(cast(ubyte)(MnMidiStatus.ControlChange | _channel), 32,
                cast(ubyte) event.lsb);
            _output.send(cast(ubyte)(MnMidiStatus.ProgramChange | _channel), cast(ubyte) event.pc);
            _instrumentTop++;
        }

        while (_initTop < _initStates.length && _initStates[_initTop].time <= time) {
            InitEvent event = _initStates[_initTop];
            event.apply(_output, _channel);
            _initTop++;
        }

        while (_effectTop < _effects.length && _effects[_effectTop].startTime <= time) {
            _playedEffects ~= _effects[_effectTop];
            _effectTop++;
        }

        foreach (i, effect; _playedEffects) {
            effect.apply(_output, _channel, time);
            if (effect.endTime <= time) {
                _playedEffects.mark(i);
            }
        }
        _playedEffects.sweep();

        while (_noteTop < _notes.length && _notes[_noteTop].startTime <= time) {
            _playedNotes ~= _notes[_noteTop];
            _output.send(cast(ubyte)(MnMidiStatus.NoteOn | _channel),
                cast(ubyte) _notes[_noteTop].value, cast(ubyte) _notes[_noteTop].velocity);
            _noteTop++;
        }

        foreach (i, note; _playedNotes) {
            if (note.endTime <= time) {
                _output.send(cast(ubyte)(MnMidiStatus.NoteOff | _channel),
                    cast(ubyte) note.value, cast(ubyte) note.velocity);
                _playedNotes.mark(i);
            }
        }
        _playedNotes.sweep();

        return _playedNotes.length > 0 || _noteTop < _notes.length ||
            _playedEffects.length > 0 || _effectTop < _effects.length;
    }
}

private final class MidiThread : Thread {
    private {
    }

    shared bool isRunning;
    shared bool isFinished;
    shared double midiTime = 0.0;

    this() {
        initMidiClock();
        startMidiClock();

        super(&_run);
    }

    private void _run() {
        try {
            MidiChannel[ChannelCount] channels;

            for (ubyte ch; ch < ChannelCount; ++ch) {
                channels[ch] = new MidiChannel(ch, _channels[ch].instrumentEvents,
                    _channels[ch].initEvents, _channels[ch].noteEvents,
                    _channels[ch].effectEvents);
            }

            isRunning = true;
            double startTime = getMidiTime();
            midiTime = 0.0;
            while (isRunning) {
                double currentTime = getMidiTime() - startTime;
                currentTime /= 24.0;
                midiTime = currentTime;

                bool isPlaying = false;
                for (ubyte ch; ch < ChannelCount; ++ch) {
                    isPlaying = channels[ch].update(currentTime) || isPlaying;
                }

                if (!isPlaying) {
                    // On attend un temps raisonnable que le module sonore
                    // ait fini de jouer
                    uint i;
                    while (isRunning && i < 10) { // 10 * 100: 1sec
                        Thread.sleep(dur!("msecs")(100));
                        i++;
                    }
                    isRunning = false;
                    isFinished = true;
                }

                Thread.sleep(dur!("msecs")(1));
            }
        }
        catch (Exception e) {
            import std.stdio : writeln;

            writeln(e.msg);
        }
    }
}
