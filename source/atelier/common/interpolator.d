module atelier.common.interpolator;

import atelier.common.math;
import atelier.common.spline;
import atelier.common.timer;

/// Interpole progressivement une valeur entre plusieurs états possibles
struct Interpolator(T) {
    private struct Step {
        T value;
        uint duration;
        SplineFunc func;

        this(T value_, uint duration_, SplineFunc func_) {
            value = value_;
            duration = duration_;
            func = func_;
        }
    }

    private {
        Step[] _steps;
        T _origin, _value;
        uint _currentStep;
        Timer _timer;
    }

    @disable this();

    this(T value_) {
        _value = value_;
    }

    uint add(T value, uint duration, SplineFunc func) {
        uint index = cast(uint) _steps.length;
        _steps ~= Step(value, duration, func);
        return index;
    }

    void update() {
        if (_timer.isRunning()) {
            _timer.update();
            if (_timer.isRunning()) {
                _value = lerp(_origin, _steps[_currentStep].value, _steps[_currentStep].func(
                        _timer.value01()));
            }
            else {
                _value = _steps[_currentStep].value;
            }
        }
    }

    void set(T value) {
        _value = value;
        _timer.stop();
    }

    T get() {
        return _value;
    }

    void set(uint id) {
        if (id >= _steps.length)
            return;

        _currentStep = id;
        _value = _steps[_currentStep].value;
        _timer.stop();
    }

    void run(uint id) {
        if (id >= _steps.length || id == _currentStep)
            return;

        _origin = _value;
        _currentStep = id;
        _timer.start(_steps[_currentStep].duration);
    }
}
