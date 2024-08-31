/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.button.toggle;

import std.algorithm.comparison;
import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.core;
import atelier.ui.button.button;

final class ToggleButton : Button!Capsule {
    private {
        Capsule _background, _selection;
        Label _inactiveLabel, _activeLabel;
        bool _value;
        Timer _clickTimer;
        float _startPosition = 0f, _endPosition = 0f;
        float _selectionWidth = 0f;
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

    this(string inactiveText, string activeText, bool isChecked = false) {
        _value = isChecked;

        _inactiveLabel = new Label(inactiveText, Atelier.theme.font);
        _inactiveLabel.setAlign(UIAlignX.left, UIAlignY.center);
        _inactiveLabel.textColor = _value ? Atelier.theme.onAccent : Atelier.theme.neutral;
        addUI(_inactiveLabel);

        _activeLabel = new Label(activeText, Atelier.theme.font);
        _activeLabel.setAlign(UIAlignX.right, UIAlignY.center);
        _activeLabel.textColor = _value ? Atelier.theme.accent : Atelier.theme.onAccent;
        addUI(_activeLabel);

        _selectionWidth = max(_inactiveLabel.getWidth(), _activeLabel.getWidth()) + 6f;
        setSize(Vec2f(_selectionWidth * 2f + 12f, Atelier.theme.font.size + 6f));

        _inactiveLabel.setPosition(Vec2f(3f + (_selectionWidth - _inactiveLabel.getWidth()) / 2f,
                0f));
        _activeLabel.setPosition(Vec2f(3f + (_selectionWidth - _activeLabel.getWidth()) / 2f, 0f));

        _background = Capsule.fill(getSize());
        _background.color = _value ? Atelier.theme.accent : Atelier.theme.neutral;
        _background.anchor = Vec2f.zero;
        addImage(_background);

        _selection = Capsule.fill(Vec2f(_selectionWidth, Atelier.theme.font.size));
        _selection.color = Atelier.theme.onNeutral;
        _selection.anchor = Vec2f.half;
        _selection.position = Vec2f(_value ?
                getWidth() - (_selectionWidth / 2f + 3f) : _selectionWidth / 2f + 3f,
                getHeight() / 2f);
        addImage(_selection);

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
        _selection.alpha = Atelier.theme.activeOpacity;

        _activeLabel.textColor = _value ? Atelier.theme.accent : Atelier.theme.onAccent;
        _inactiveLabel.textColor = _value ? Atelier.theme.onAccent : Atelier.theme.neutral;

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
        _selection.alpha = Atelier.theme.inactiveOpacity;
        _inactiveLabel.textColor = Atelier.theme.neutral;
        _activeLabel.textColor = Atelier.theme.neutral;

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

        _startPosition = _selection.position.x;
        _endPosition = _value ? getWidth() - (_selectionWidth / 2f + 3f) : _selectionWidth / 2f + 3f;

        _activeLabel.textColor = _value ? Atelier.theme.accent : Atelier.theme.onAccent;
        _inactiveLabel.textColor = _value ? Atelier.theme.onAccent : Atelier.theme.neutral;
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
            _selection.size = Vec2f(lerp(_selectionWidth / 4f, _selectionWidth,
                    easeOutBounce(_clickTimer.value01())), _selection.size.y);

            _selection.position.x = lerp(_startPosition, _endPosition,
                easeOutElastic(_clickTimer.value01()));
        }
    }
}
