module atelier.etabli.core.midi.clock;

import std.datetime;

private {
    __gshared bool _isRunning;
    __gshared long _ticksElapsed;
    __gshared MonoTime _timeStarted;
    __gshared double _timeScale;
}

void initMidiClock() {
    _isRunning = false;
    _ticksElapsed = 0;
    _timeScale = 1f;
}

void startMidiClock() {
    _isRunning = true;
    _timeStarted = MonoTime.currTime;
}

void pauseMidiClock() {
    if (_isRunning) {
        if (_timeScale > .99 && _timeScale < 1.01) {
            _ticksElapsed += MonoTime.currTime.ticks - _timeStarted.ticks;
        }
        else {
            _ticksElapsed += cast(long)((MonoTime.currTime.ticks - _timeStarted.ticks) * _timeScale);
        }
    }
    _isRunning = false;
}

void stopMidiClock() {
    _isRunning = false;
    _ticksElapsed = 0;
}

bool isMidiClockRunning() {
    return _isRunning;
}

void setMidiClockTimeScale(double timeScale) {
    if (_isRunning) {
        if (_timeScale > .99 && _timeScale < 1.01) {
            _ticksElapsed += MonoTime.currTime.ticks - _timeStarted.ticks;
        }
        else {
            _ticksElapsed += cast(long)((MonoTime.currTime.ticks - _timeStarted.ticks) * _timeScale);
        }
    }
    _timeStarted = MonoTime.currTime;
    _timeScale = timeScale;
}

long getMidiTime() {
    enum hnsecsPerSecond = convert!("seconds", "hnsecs")(1);
    immutable hnsecsMeasured = convClockFreq(_ticksElapsed,
        MonoTime.ticksPerSecond, hnsecsPerSecond);

    Duration duration;
    if (_isRunning) {
        if (_timeScale > .99 && _timeScale < 1.01) {
            duration = MonoTime.currTime - _timeStarted + hnsecs(hnsecsMeasured);
        }
        else {
            long ticksElapsed = cast(long)(
                (MonoTime.currTime.ticks - _timeStarted.ticks) * _timeScale);

            immutable hnsecsMeasured2 = convClockFreq(ticksElapsed,
                MonoTime.ticksPerSecond, hnsecsPerSecond);
            duration = hnsecs(hnsecsMeasured2 + hnsecsMeasured);
        }
    }
    else {
        duration = hnsecs(hnsecsMeasured);
    }

    return duration.total!"msecs";
}

void setMidiTime(long time) {
    enum hnsecsPerSecond = convert!("seconds", "hnsecs")(1);
    _ticksElapsed = convClockFreq(dur!"msecs"(time).total!"hnsecs",
        hnsecsPerSecond, MonoTime.ticksPerSecond);
    _timeStarted = MonoTime.currTime;
}
