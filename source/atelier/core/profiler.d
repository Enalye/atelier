module atelier.core.profiler;

import std.algorithm.mutation : remove;
import std.conv : to;
import std.datetime;
import std.format;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

private class ProfilePass {
    private {
        long _startTime;
        double _duration;
        double _minDuration = 1000.0;
        double _maxDuration = 0.0;
        ulong _count;
    }

    void start() {
        _startTime = Clock.currStdTime();
    }

    void end() {
        _duration = (cast(double)(Clock.currStdTime() - _startTime) / 10_000.0);

        if (_duration < _minDuration) {
            _minDuration = _duration;
        }
        if (_duration > _maxDuration) {
            _maxDuration = _duration;
        }
        _count++;
    }

    double getDuration() const {
        return _duration;
    }

    double getMinDuration() const {
        return _minDuration;
    }

    double getMaxDuration() const {
        return _maxDuration;
    }

    ulong getCount() const {
        return _count;
    }
}

final class Profiler {
    private {
        ProfilerUI _ui;
        Font _font;

        ProfilePass[string] _passes;
        string[] _filters;
    }

    @property {
        bool isRunning() const {
            return _ui !is null;
        }
    }

    this() {
    }

    void setFont(Font font) {
        _font = font;
    }

    void open() {
        if (_ui)
            return;

        _ui = new ProfilerUI(this, _font);
        Atelier.ui.addUI(_ui);
    }

    void close() {
        if (!_ui)
            return;

        _ui.removeUI();
    }

    const(string[]) getFilters() const {
        return _filters;
    }

    void restartPasses() {
        _passes.clear();
    }

    void clearFilters() {
        _filters.length = 0;
        _passes.clear();
    }

    void addFilter(string name) {
        foreach (filter; _filters) {
            if (filter == name)
                return;
        }
        _filters ~= name;
    }

    void removeFilter(string name) {
        _filters.remove!(a => a == name)();
    }

    void startPass(string name) {
        if (!_ui)
            return;

        ProfilePass pass;
        auto p = name in _passes;
        if (p) {
            pass = *p;
        }
        else {
            foreach (filter; _filters) {
                if (filter == name) {
                    pass = new ProfilePass;
                    _passes[name] = pass;
                    break;
                }
            }
        }

        if (pass) {
            pass.start();
        }
    }

    void endPass(string name) {
        if (!_ui)
            return;

        ProfilePass pass;
        auto p = name in _passes;
        if (p) {
            pass = *p;
            pass.end();
        }
    }

    ProfilePass[string] getPasses() {
        return _passes;
    }
}

private final class ProfilerUI : UIElement {
    private {
        Profiler _profiler;
        Label _label;
    }

    this(Profiler profiler, Font font) {
        _profiler = profiler;
        setAlign(UIAlignX.right, UIAlignY.top);
        setPosition(Vec2f(8f, 8f));
        isEnabled = false;

        _label = new Label("", font);
        _label.setAlign(UIAlignX.left, UIAlignY.top);
        addUI(_label);
        setSize(_label.getSize());

        _label.addEventListener("size", { setSize(_label.getSize()); });

        addEventListener("update", &_onUpdate);
    }

    private void _onUpdate() {
        string result;
        foreach (name, pass; _profiler.getPasses()) {
            result ~= format("%s(ms): %.2f, min: %.2f, max: %.2f (%d)\n",
                name,
                pass.getDuration(),
                pass.getMinDuration(),
                pass.getMaxDuration(),
                pass.getCount());
        }

        _label.text = result;
    }
}
