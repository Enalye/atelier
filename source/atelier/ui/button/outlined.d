/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.button.outlined;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.button.button;

final class OutlinedButton : TextButton!RoundedRectangle {
    private {
        RoundedRectangle _background;
    }

    this(string text_) {
        super(text_);

        setFxColor(Atelier.theme.accent);
        setTextColor(Atelier.theme.accent);

        _background = RoundedRectangle.outline(getSize(), Atelier.theme.corner, 2f);
        _background.color = Atelier.theme.accent;
        _background.anchor = Vec2f.zero;
        _background.thickness = 2f;
        addImage(_background);

        addEventListener("size", { _background.size = getSize(); });

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);

        addEventListener("enable", &_onEnable);
        addEventListener("disable", &_onDisable);
    }

    private void _onEnable() {
        _background.alpha = Atelier.theme.activeOpacity;
        _background.color = Atelier.theme.accent;
        setTextColor(Atelier.theme.accent);

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onDisable() {
        _background.filled = false;
        _background.alpha = Atelier.theme.inactiveOpacity;
        _background.color = Atelier.theme.neutral;
        setTextColor(Atelier.theme.neutral);

        removeEventListener("mouseenter", &_onMouseEnter);
        removeEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onMouseEnter() {
        setTextColor(Atelier.theme.onAccent);
        _background.filled = true;
    }

    private void _onMouseLeave() {
        setTextColor(Atelier.theme.accent);
        _background.filled = false;
    }
}
