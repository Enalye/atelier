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
    }

    private bool add(ToolButton button, bool isChecked) {
        if (isChecked) {
            check(null);
        }

        _buttons ~= button;
        // Le premier élément est coché par défaut
        return (_buttons.length == 1) || isChecked;
    }

    private void check(ToolButton button_) {
        foreach (i, button; _buttons) {
            button._updateValue(button == button_);
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
        ToolGroup _group;
        bool _value;
    }

    @property {
        bool value() const {
            return _value;
        }
    }

    this(ToolGroup group, string icon, bool isChecked = false) {
        enforce(group, "groupe non-spécifié");
        _group = group;
        _value = _group.add(this, isChecked);

        _icon = new Icon(icon);
        _icon.setAlign(UIAlignX.center, UIAlignY.center);
        addUI(_icon);

        setSize(_icon.getSize() + Vec2f(8f, 8f));

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

    void setIcon(string icon) {
        _icon.setIcon(icon);
        setSize(_icon.getSize() + Vec2f(8f, 8f));
    }

    void setIconColor(Color color_) {
        _icon.color = color_;
    }

    void check() {
        _group.check(this);
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
            check();
    }

    private void _updateValue(bool value_) {
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

        dispatchEvent("value", false);
    }
}
