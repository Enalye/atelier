/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.button.icon;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.core;
import atelier.ui.button.button;

final class IconButton : Button!RoundedRectangle {
    private {
        RoundedRectangle _background;
        Icon _icon;
    }

    this(string icon) {
        setFxColor(Atelier.theme.neutral);

        _icon = new Icon(icon);
        _icon.setAlign(UIAlignX.center, UIAlignY.center);
        addUI(_icon);

        setSize(_icon.getSize() + Vec2f(8f, 8f));

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
        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onDisable() {
        _background.isVisible = false;
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
