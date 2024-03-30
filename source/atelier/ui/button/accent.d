/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.button.accent;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.button.button;

final class AccentButton : TextButton!RoundedRectangle {
    private {
        RoundedRectangle _background;
    }

    this(string text_) {
        super(text_);

        setFxColor(Atelier.theme.accent);
        setTextColor(Atelier.theme.onAccent);

        _background = RoundedRectangle.fill(getSize(), Atelier.theme.corner);
        _background.color = Atelier.theme.accent;
        _background.anchor = Vec2f.zero;
        addImage(_background);

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);

        addEventListener("enable", &_onEnable);
        addEventListener("disable", &_onDisable);
    }

    private void _onEnable() {
        _background.alpha = Atelier.theme.activeOpacity;
        setTextColor(Atelier.theme.onAccent);

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onDisable() {
        _background.alpha = Atelier.theme.inactiveOpacity;
        setTextColor(Atelier.theme.neutral);

        removeEventListener("mouseenter", &_onMouseEnter);
        removeEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onMouseEnter() {
        Color rgb = Atelier.theme.accent;
        HSLColor hsl = HSLColor.fromColor(rgb);
        hsl.l = hsl.l * .8f;
        _background.color = hsl.toColor();
    }

    private void _onMouseLeave() {
        _background.color = Atelier.theme.accent;
    }
}
