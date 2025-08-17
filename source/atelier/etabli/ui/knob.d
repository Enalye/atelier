module atelier.etabli.ui.knob;

import std.math : PI, PI_2;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui;

final class Knob : UIElement {
    private {
        Circle _circle;
        float _value = 0f;
        float _minValue = 0f, _maxValue = 1f;
    }

    @property {
        float value() const {
            float val = (_value + PI) / (2f * PI);
            val = clamp(val, 0f, 1f);
            return lerp(_minValue, _maxValue, val);
        }

        float value(float value_) {
            float val = rlerp(_minValue, _maxValue, value_);
            val = clamp(val, 0f, 1f);
            _value = (val * 2f * PI) - PI;
            return _value;
        }
    }

    this() {
        setSize(Vec2f(32f, 32f));

        _circle = Circle.outline(getWidth(), 2f);
        _circle.color = Atelier.theme.onNeutral;
        _circle.anchor = Vec2f.zero;
        addImage(_circle);

        addEventListener("mousedown", &_onMouseDown);
        addEventListener("mouseup", {
            removeEventListener("mousemove", &_onMouseMove);
        });

        addEventListener("draw", &_onDraw);
        addEventListener("size", { _circle.radius = getWidth(); });
    }

    private void _onMouseDown() {
        Vec2f delta = getMousePosition() - getCenter();
        _value = delta.rotated(-PI_2).angle();
        addEventListener("mousemove", &_onMouseMove);
        dispatchEvent("value", false);
    }

    private void _onMouseMove() {
        Vec2f delta = getMousePosition() - getCenter();
        _value = delta.rotated(-PI_2).angle();
        dispatchEvent("value", false);
    }

    private void _onDraw() {
        Vec2f endLine = getCenter() + Vec2f.angled(_value + PI_2) * (getWidth() / 2f);
        Atelier.renderer.drawLine(getCenter(), endLine, Atelier.theme.accent, 1f);
    }

    void setRange(float minValue_, float maxValue_) {
        _minValue = minValue_;
        _maxValue = maxValue_;
    }
}
