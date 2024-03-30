/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.menu.button;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.button;
import atelier.ui.core;
import atelier.ui.menu.bar;

final class MenuButton : TextButton!RoundedRectangle {
    private {
        RoundedRectangle _background;
        MenuBar _bar;
        Label _label;
        uint _id;
    }

    this(MenuBar bar, uint id, string text) {
        super(text);
        _bar = bar;
        _id = id;

        setFxColor(Atelier.theme.neutral);
        setTextColor(Atelier.theme.onNeutral);

        _background = RoundedRectangle.fill(getSize(), Atelier.theme.corner);
        _background.color = Atelier.theme.neutral;
        _background.anchor = Vec2f.zero;
        _background.alpha = .5f;
        _background.isVisible = false;
        addImage(_background);

        addEventListener("mouseenter", {
            _background.isVisible = true;
            _bar.switchMenu(_id);
        });
        addEventListener("mouseleave", {
            _background.isVisible = false;
            _bar.leaveMenu(_id);
        });
        addEventListener("click", { _bar.toggleMenu(_id); });
    }
}
