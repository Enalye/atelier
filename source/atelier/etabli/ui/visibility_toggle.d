module atelier.etabli.ui.visibility_toggle;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

final class VisibilityToggle : Button!RoundedRectangle {
    private {
        Sprite _shownSprite, _hiddenSprite;
        bool _value;
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
        _value = isChecked;
        setSize(Vec2f(32f, 32f));

        _shownSprite = Atelier.res.get!Sprite("editor:shown");
        _shownSprite.isVisible = _value;
        _shownSprite.fit(getSize());
        _shownSprite.anchor = Vec2f(0f, .5f);
        _shownSprite.position = Vec2f(0f, getCenter().y);
        addImage(_shownSprite);

        _hiddenSprite = Atelier.res.get!Sprite("editor:hidden");
        _hiddenSprite.isVisible = !_value;
        _hiddenSprite.fit(getSize());
        _hiddenSprite.anchor = Vec2f(0f, .5f);
        _hiddenSprite.position = Vec2f(0f, getCenter().y);
        addImage(_hiddenSprite);

        setFxColor(_value ? Atelier.theme.accent : Atelier.theme.neutral);

        addEventListener("click", &_onClick);

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);

        addEventListener("enable", &_onEnable);
        addEventListener("disable", &_onDisable);
    }

    private void _onEnable() {
        _shownSprite.alpha = Atelier.theme.activeOpacity;
        _hiddenSprite.alpha = Atelier.theme.activeOpacity;

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onDisable() {
        _shownSprite.alpha = Atelier.theme.inactiveOpacity;
        _hiddenSprite.alpha = Atelier.theme.inactiveOpacity;

        removeEventListener("mouseenter", &_onMouseEnter);
        removeEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onMouseEnter() {
        Color rgb = _value ? Atelier.theme.accent : Atelier.theme.neutral;
        HSLColor hsl = HSLColor.fromColor(rgb);
        hsl.l = hsl.l * .8f;
        rgb = hsl.toColor();
        //_shownSprite.color = rgb;
        //_hiddenSprite.color = rgb;
    }

    private void _onMouseLeave() {
        //_shownSprite.color = Atelier.theme.neutral;
        //_hiddenSprite.color = Atelier.theme.neutral;
    }

    private void _onClick() {
        _updateValue(!_value, true);
    }

    private void _updateValue(bool value_, bool dispatch) {
        if (_value == value_)
            return;

        _value = value_;
        setFxColor(_value ? Atelier.theme.accent : Atelier.theme.neutral);

        _shownSprite.isVisible = _value;
        _hiddenSprite.isVisible = !_value;

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
