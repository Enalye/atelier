/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.menu.item;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.button;
import atelier.ui.core;
import atelier.ui.menu.bar;

final class MenuItem : TextButton!RoundedRectangle {
    private {
        RoundedRectangle _background;
        Label _label;
        MenuBar _bar;
        uint _id;
    }

    this(MenuBar bar, uint id, string text) {
        super(text);
        _bar = bar;
        _id = id;

        setAlign(UIAlignX.left, UIAlignY.top);
        setFxColor(Atelier.theme.neutral);
        setTextColor(Atelier.theme.onNeutral);
        setPadding(Vec2f(48f, 8f));
        setTextAlign(UIAlignX.left, 16f);

        _background = RoundedRectangle.fill(getSize(), Atelier.theme.corner);
        _background.color = Atelier.theme.accent;
        _background.anchor = Vec2f.zero;
        _background.alpha = 1f;
        _background.isVisible = false;
        addImage(_background);

        addEventListener("mouseenter", { _background.isVisible = true; });
        addEventListener("mouseleave", { _background.isVisible = false; });
        addEventListener("click", { _bar.toggleMenu(_id); });
        addEventListener("size", { _background.size = getSize(); });
    }
}
