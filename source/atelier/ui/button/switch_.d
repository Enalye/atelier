/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.button.switch_;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.button.button;

final class SwitchButton : Button!Capsule {
    private {
        Capsule _background;
        Circle _circle;
        bool _value;
        Timer _clickTimer;
        float _startPosition = 0f, _endPosition = 0f;
    }

    @property {
        bool value() const {
            return _value;
        }

        bool value(bool value_) {
            _updateValue(value_, false);
            return _value;
        }
    }

    this(bool isChecked = false) {
        setSize(Vec2f(48f, 24f));
        _value = isChecked;

        _background = Capsule.fill(getSize());
        _background.anchor = Vec2f.zero;
        _background.color = _value ? Atelier.theme.accent : Atelier.theme.neutral;
        addImage(_background);

        _circle = Circle.fill(18f);
        _circle.color = Atelier.theme.onNeutral;
        _circle.anchor = Vec2f.half;
        _circle.position = Vec2f(_value ? 36f : 12f, getHeight() / 2f);
        addImage(_circle);

        setFxColor(_value ? Atelier.theme.accent : Atelier.theme.neutral);

        addEventListener("click", &_onClick);
        addEventListener("update", &_onUpdate);

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);

        addEventListener("enable", &_onEnable);
        addEventListener("disable", &_onDisable);
    }

    private void _onEnable() {
        _background.alpha = Atelier.theme.activeOpacity;
        _circle.alpha = Atelier.theme.activeOpacity;

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
        _background.alpha = Atelier.theme.inactiveOpacity;
        _circle.alpha = Atelier.theme.inactiveOpacity;

        removeEventListener("mouseenter", &_onMouseEnter);
        removeEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onMouseEnter() {
        Color rgb = _value ? Atelier.theme.accent : Atelier.theme.neutral;
        HSLColor hsl = HSLColor.fromColor(rgb);
        hsl.l = hsl.l * .8f;
        _background.color = hsl.toColor();
    }

    private void _onMouseLeave() {
        _background.color = _value ? Atelier.theme.accent : Atelier.theme.neutral;
    }

    private void _onClick() {
        _updateValue(!_value, true);
    }

    private void _updateValue(bool value_, bool dispatch) {
        if (_value == value_)
            return;

        _value = value_;
        _clickTimer.start(60);

        _startPosition = _circle.position.x;
        _endPosition = _value ? 36f : 12f;

        setFxColor(_value ? Atelier.theme.accent : Atelier.theme.neutral);

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

    private void _onUpdate() {
        if (_clickTimer.isRunning) {
            _clickTimer.update();
            _circle.radius = lerp(10f, 18f, easeOutBounce(_clickTimer.value01()));

            _circle.position.x = lerp(_startPosition, _endPosition,
                easeOutElastic(_clickTimer.value01()));
        }
    }
}
