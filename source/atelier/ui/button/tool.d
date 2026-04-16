/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.button.tool;

import std.exception : enforce;
import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.core;
import atelier.ui.button.button;

final class ToolGroup {
    private {
        ToolButton[] _buttons;
        int _value;
    }

    @property {
        int value() const {
            return _value;
        }

        int value(int value_) {
            if (_value != value_ && value_ < _buttons.length) {
                _check(_buttons[value_], true);
            }
            return _value;
        }
    }

    private bool add(ToolButton button, bool isChecked) {
        if (isChecked) {
            _check(null, false);
        }

        _buttons ~= button;
        // Le premier élément est coché par défaut
        return (_buttons.length == 1) || isChecked;
    }

    private void _check(ToolButton button_, bool dispatch) {
        foreach (i, button; _buttons) {
            button._updateValue(button == button_, dispatch);
            if (button == button_) {
                _value = cast(int) i;
            }
        }
    }

    private void enable(bool isEnabled) {
        foreach (ToolButton button; _buttons) {
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

final class ToolButton : Button!RoundedRectangle {
    private {
        RoundedRectangle _background;
        Icon _icon;
        Label _label;
        ToolGroup _group;
        bool _value;
    }

    @property {
        bool value() const {
            return _value;
        }
    }

    this(ToolGroup group, string icon, bool isChecked = false) {
        this(group, icon, "", isChecked);
    }

    this(ToolGroup group, string icon, string text, bool isChecked = false) {
        enforce(group, "groupe non-spécifié");
        _group = group;
        _value = _group.add(this, isChecked);

        if (icon.length) {
            _icon = new Icon(icon);
            addUI(_icon);
        }
        if (text.length) {
            _label = new Label(text, Atelier.theme.font);
            addUI(_label);
        }

        _updateElements();

        _background = RoundedRectangle.outline(getSize(), Atelier.theme.corner, 2f);
        _background.anchor = Vec2f.zero;
        _background.color = _value ? Atelier.theme.accent : Atelier.theme.neutral;
        _background.filled = _value;
        addImage(_background);

        setFxColor(_value ? Atelier.theme.accent : Atelier.theme.neutral);

        addEventListener("click", &_onClick);

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);

        addEventListener("enable", { _group.enable(true); });
        addEventListener("disable", { _group.enable(false); });

        addEventListener("size", { _background.size = getSize(); });
    }

    private void _updateElements() {
        if (_label && _icon) {
            _icon.setAlign(UIAlignX.left, UIAlignY.center);
            _label.setAlign(UIAlignX.right, UIAlignY.center);

            Vec2f size_ = Vec2f(12f, 8f);
            size_.x = _label.getWidth() + _icon.getWidth();
            size_.y = max(_label.getHeight(), _icon.getHeight());
            setSize(size_);
        }
        else if (_label) {
            _label.setAlign(UIAlignX.center, UIAlignY.center);
            setSize(_label.getSize() + Vec2f(8f, 8f));
        }
        else if (_icon) {
            _icon.setAlign(UIAlignX.center, UIAlignY.center);
            setSize(_icon.getSize() + Vec2f(8f, 8f));
        }
        else {
            setSize(Vec2f(8f, 8f));
        }
    }

    void setIcon(string icon) {
        if (icon.length) {
            if (!_icon) {
                _icon = new Icon(icon);
                addUI(_icon);
            }
            else {
                _icon.setIcon(icon);
            }
        }
        else {
            if (_icon) {
                _icon.removeUI();
            }

            _icon = null;
        }
        _updateElements();
    }

    void setIconColor(Color color_) {
        if (!_icon)
            return;

        _icon.color = color_;
    }

    void setText(string text) {
        if (text.length) {
            if (!_label) {
                _label = new Label(text, Atelier.theme.font);
                addUI(_label);
            }
            else {
                _label.text = text;
            }
        }
        else {
            if (_label) {
                _label.removeUI();
            }

            _label = null;
        }
        _updateElements();
    }

    void check() {
        _group._check(this, false);
    }

    private void _check() {
        _group._check(this, true);
    }

    private void _onEnable() {
        _background.alpha = Atelier.theme.activeOpacity;

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
        if (!_value)
            _check();
    }

    private void _updateValue(bool value_, bool dispatch) {
        if (_value == value_)
            return;

        _value = value_;
        setFxColor(_value ? Atelier.theme.accent : Atelier.theme.neutral);

        _background.filled = _value;

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
