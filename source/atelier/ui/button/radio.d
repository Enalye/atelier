/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.button.radio;

import std.exception : enforce;
import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.button.button;

final class RadioGroup {
    private {
        RadioButton[] _buttons;
        int _value;
    }

    @property {
        int value() const {
            return _value;
        }
    }

    private bool add(RadioButton button, bool isChecked) {
        if (isChecked) {
            _check(null, false);
        }

        _buttons ~= button;
        // Le premier élément est coché par défaut
        return (_buttons.length == 1) || isChecked;
    }

    private void _check(RadioButton button_, bool dispatch) {
        foreach (i, button; _buttons) {
            button._updateValue(button == button_, dispatch);
            if (button == button_) {
                _value = cast(int) i;
            }
        }
    }

    private void enable(bool isEnabled) {
        foreach (RadioButton button; _buttons) {
            button.isEnabled = isEnabled;
            if (isEnabled) {
                button._onEnable();
            }
            else {
                button._onDisable();
            }
        }
    }
}

final class RadioButton : Button!Circle {
    private {
        Circle _outlineCircle, _checkCircle;
        RadioGroup _group;
        bool _value;
    }

    @property {
        bool value() const {
            return _value;
        }
    }

    this(RadioGroup group, bool isChecked = false) {
        enforce(group, "groupe non-spécifié");
        _group = group;
        _value = _group.add(this, isChecked);
        setSize(Vec2f(24f, 24f));

        _outlineCircle = Circle.outline(24f, 2f);
        _outlineCircle.position = getCenter();
        _outlineCircle.anchor = Vec2f.half;
        _outlineCircle.color = _value ? Atelier.theme.accent : Atelier.theme.neutral;
        addImage(_outlineCircle);

        _checkCircle = Circle.fill(14f);
        _checkCircle.position = getCenter();
        _checkCircle.anchor = Vec2f.half;
        _checkCircle.color = Atelier.theme.accent;
        _checkCircle.isVisible = _value;
        addImage(_checkCircle);

        setFxColor(_value ? Atelier.theme.accent : Atelier.theme.neutral);

        addEventListener("click", &_onClick);

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);

        addEventListener("enable", { _group.enable(true); });
        addEventListener("disable", { _group.enable(false); });
    }

    void check() {
        _group._check(this, false);
    }

    private void _check() {
        _group._check(this, true);
    }

    private void _onEnable() {
        _outlineCircle.alpha = Atelier.theme.activeOpacity;
        _checkCircle.alpha = Atelier.theme.activeOpacity;

        if (isHovered) {
            _onMouseEnter();
        }
        else {
            _onMouseLeave();
        }

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onDisable() {
        _outlineCircle.alpha = Atelier.theme.inactiveOpacity;
        _checkCircle.alpha = Atelier.theme.inactiveOpacity;

        removeEventListener("mouseenter", &_onMouseEnter);
        removeEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onMouseEnter() {
        Color rgb = _value ? Atelier.theme.accent : Atelier.theme.neutral;
        HSLColor hsl = HSLColor.fromColor(rgb);
        hsl.l = hsl.l * .8f;
        _outlineCircle.color = hsl.toColor();
        _checkCircle.color = _outlineCircle.color;
    }

    private void _onMouseLeave() {
        _outlineCircle.color = _value ? Atelier.theme.accent : Atelier.theme.neutral;
        _checkCircle.color = _outlineCircle.color;
    }

    private void _onClick() {
        if (!_value)
            _check();
    }

    private void _updateValue(bool value_, bool dispatch) {
        if (_value == value_)
            return;

        _value = value_;
        setFxColor(_value ? Atelier.theme.accent : Atelier.theme.neutral);

        _checkCircle.isVisible = _value;

        if (isHovered) {
            _onMouseEnter();
        }
        else {
            _onMouseLeave();
        }

        if (dispatch) {
            dispatchEvent("value", false);
        }
    }
}
