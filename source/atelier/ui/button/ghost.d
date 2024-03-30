/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.button.ghost;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.button.button;

final class GhostButton : TextButton!RoundedRectangle {
    private {
        RoundedRectangle _background;
    }

    this(string text_) {
        super(text_);

        setFxColor(Atelier.theme.neutral);
        setTextColor(Atelier.theme.accent);

        _background = RoundedRectangle.fill(getSize(), Atelier.theme.corner);
        _background.color = Atelier.theme.neutral;
        _background.anchor = Vec2f.zero;
        _background.alpha = .5f;
        _background.isVisible = false;
        addImage(_background);

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);

        addEventListener("enable", &_onEnable);
        addEventListener("disable", &_onDisable);
    }

    private void _onEnable() {
        setTextColor(Atelier.theme.accent);

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onDisable() {
        _background.isVisible = false;
        setTextColor(Atelier.theme.neutral);

        removeEventListener("mouseenter", &_onMouseEnter);
        removeEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onMouseEnter() {
        _background.isVisible = true;
    }

    private void _onMouseLeave() {
        _background.isVisible = false;
    }
}
