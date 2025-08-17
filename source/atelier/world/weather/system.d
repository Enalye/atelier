module atelier.world.weather.system;

import std.conv : to;
import atelier.common;
import atelier.world.weather.base;

final class Weather {
    private {
        BaseWeather _targetWeather;
        BaseWeather _currentWeather;
        Timer _timer;

        alias WeatherBuilder = BaseWeather function(float);
        static WeatherBuilder[string] _weatherBuilders;
    }

    static void add(string type, WeatherBuilder weatherBuilder) {
        _weatherBuilders[type] = weatherBuilder;
    }

    static string[] getList() {
        return _weatherBuilders.keys;
    }

    private static BaseWeather _create(string type, float value) {
        auto p = type in _weatherBuilders;
        if (p && (*p !is null)) {
            return (*p)(value);
        }
        return null;
    }

    this() {
        add("none", null);
    }

    private void _resetTransition() {
        if (_timer.isRunning()) {
            _currentWeather = _targetWeather;
            _targetWeather = null;
            _timer.stop();
        }
    }

    void set(string type, float value) {
        _resetTransition();
        _currentWeather = _create(type, value);
    }

    void run(string type, float value, uint duration) {
        _resetTransition();
        _targetWeather = _create(type, value);
        if (_currentWeather)
            _currentWeather.setAlpha(1f);
        if (_targetWeather)
            _targetWeather.setAlpha(0f);
        _timer.start(cast(int) duration);
    }

    void update() {
        if (_timer.isRunning()) {
            _timer.update();
            float t = easeInOutSine(_timer.value01());
            if (_currentWeather) {
                _currentWeather.setAlpha(1f - t);
            }
            if (_targetWeather) {
                _targetWeather.setAlpha(t);
            }

            if (!_timer.isRunning()) {
                _currentWeather = _targetWeather;
                _targetWeather = null;
            }
        }
        if (_currentWeather) {
            _currentWeather.update();
        }
        if (_targetWeather) {
            _targetWeather.update();
        }
    }

    void draw(Vec2f offset) {
        if (_currentWeather) {
            _currentWeather.draw(offset);
        }
        if (_targetWeather) {
            _targetWeather.draw(offset);
        }
    }
}
