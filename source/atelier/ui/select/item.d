/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.select.item;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.button;
import atelier.ui.core;
import atelier.ui.select.button;

final class SelectItem : TextButton!RoundedRectangle {
    private {
        RoundedRectangle _background;
        Label _label;
        SelectButton _button;
    }

    this(SelectButton button, string text) {
        super(text);
        _button = button;

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
        addEventListener("click", { _button.value = text; _button.removeMenu(); });
        addEventListener("size", { _background.size = getSize(); });
    }
}
