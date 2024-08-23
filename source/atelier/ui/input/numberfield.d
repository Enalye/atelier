/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.input.numberfield;

import std.algorithm.comparison : clamp;
import std.array : replace;
import std.conv : to;
import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.button;
import atelier.ui.core;
import atelier.ui.input.textfield;

final class ControlButton : TextButton!RoundedRectangle {
    private {
        RoundedRectangle _background;
    }

    this(string text_) {
        super(text_);

        setFxColor(Atelier.theme.neutral);
        setTextColor(Atelier.theme.accent);
        setSize(Vec2f(20f, 32f));

        _background = RoundedRectangle.fill(getSize(), Atelier.theme.corner);
        _background.color = Atelier.theme.neutral;
        _background.anchor = Vec2f.zero;
        _background.alpha = .5f;
        _background.isVisible = false;
        addImage(_background);

        addEventListener("mouseenter", { _background.isVisible = true; });
        addEventListener("mouseleave", { _background.isVisible = false; });

        addEventListener("enable", &_onEnable);
        addEventListener("disable", &_onDisable);
    }

    private void _onEnable() {
        setTextColor(Atelier.theme.accent);
    }

    private void _onDisable() {
        setTextColor(Atelier.theme.neutral);
    }
}

final class NumberField : UIElement {
    private {
        TextField _textField;
        ControlButton _decrementBtn, _incrementBtn;
        float _value = 0f;
        float _step = 1f;
        float _minValue = float.nan;
        float _maxValue = float.nan;
    }

    @property {
        float value() const {
            return _value;
        }

        float value(float value_) {
            value_ = clamp(value_, _minValue, _maxValue);
            if (_value != value_) {
                _value = value_;
                _textField.value = to!string(_value);
                dispatchEvent("value", false);
            }
            return _value;
        }
    }

    this() {
        setSize(Vec2f(100f, 32f));

        _textField = new TextField();
        _textField.value = "0";
        _textField.setAllowedCharacters("0123456789+-.,");
        _textField.setSize(getSize());
        _textField.setInnerMargin(4f, 30f);
        addUI(_textField);

        HBox box = new HBox;
        box.setAlign(UIAlignX.right, UIAlignY.center);
        box.setChildAlign(UIAlignY.center);
        addUI(box);

        _decrementBtn = new ControlButton("-");
        box.addUI(_decrementBtn);

        _incrementBtn = new ControlButton("+");
        box.addUI(_incrementBtn);

        _incrementBtn.addEventListener("click", { value(_value + _step); });
        _incrementBtn.addEventListener("echo", { value(_value + _step); });
        _decrementBtn.addEventListener("click", { value(_value - _step); });
        _decrementBtn.addEventListener("echo", { value(_value - _step); });
        _textField.addEventListener("value", &_onValue);

        addEventListener("enable", &_onEnableChange);
        addEventListener("disable", &_onEnableChange);
    }

    private void _onEnableChange() {
        _textField.isEnabled = isEnabled;
        _decrementBtn.isEnabled = isEnabled;
        _incrementBtn.isEnabled = isEnabled;
    }

    void setMinValue(int minValue) {
        _minValue = minValue;
        value(_value);
    }

    void setMaxValue(int maxValue) {
        _maxValue = maxValue;
        value(_value);
    }

    void setRange(float minValue, float maxValue) {
        _minValue = minValue;
        _maxValue = maxValue;
        value(_value);
    }

    private void _onValue() {
        try {
            string text = _textField.value;
            text = text.replace(',', '.');
            float value_ = clamp(to!float(text), _minValue, _maxValue);

            if (_value != value_) {
                _value = value_;
                dispatchEvent("value", false);
            }
        }
        catch (Exception e) {
            value(0f);
        }
    }
}

final class IntegerField : UIElement {
    private {
        TextField _textField;
        ControlButton _decrementBtn, _incrementBtn;
        int _value = 0;
        int _step = 1;
        int _minValue = int.min;
        int _maxValue = int.max;
    }

    @property {
        int value() const {
            return _value;
        }

        int value(int value_) {
            value_ = clamp(value_, _minValue, _maxValue);
            if (_value != value_) {
                _value = value_;
                _textField.value = to!string(_value);
                dispatchEvent("value", false);
            }
            return _value;
        }
    }

    this() {
        setSize(Vec2f(100f, 32f));

        _textField = new TextField();
        _textField.value = "0";
        _textField.setAllowedCharacters("0123456789+-");
        _textField.setSize(getSize());
        _textField.setInnerMargin(4f, 30f);
        addUI(_textField);

        HBox box = new HBox;
        box.setAlign(UIAlignX.right, UIAlignY.center);
        box.setChildAlign(UIAlignY.center);
        addUI(box);

        _decrementBtn = new ControlButton("-");
        box.addUI(_decrementBtn);

        _incrementBtn = new ControlButton("+");
        box.addUI(_incrementBtn);

        _incrementBtn.addEventListener("click", { value(_value + _step); });
        _incrementBtn.addEventListener("echo", { value(_value + _step); });
        _decrementBtn.addEventListener("click", { value(_value - _step); });
        _decrementBtn.addEventListener("echo", { value(_value - _step); });
        _textField.addEventListener("value", &_onValue);

        addEventListener("enable", &_onEnableChange);
        addEventListener("disable", &_onEnableChange);
    }

    private void _onEnableChange() {
        _textField.isEnabled = isEnabled;
        _decrementBtn.isEnabled = isEnabled;
        _incrementBtn.isEnabled = isEnabled;
    }

    void setMinValue(int minValue) {
        _minValue = minValue;
        value(_value);
    }

    void setMaxValue(int maxValue) {
        _maxValue = maxValue;
        value(_value);
    }

    void setRange(int minValue, int maxValue) {
        _minValue = minValue;
        _maxValue = maxValue;
        value(_value);
    }

    private void _onValue() {
        try {
            string text = _textField.value;
            int value_ = clamp(to!int(text), _minValue, _maxValue);
            if (_value != value_) {
                _value = value_;
                dispatchEvent("value", false);
            }
        }
        catch (Exception e) {
            value(0);
        }
    }
}
