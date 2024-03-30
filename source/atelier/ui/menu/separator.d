/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.menu.separator;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.button;
import atelier.ui.core;
import atelier.ui.menu.bar;

final class MenuSeparator : UIElement {
    private {
        Rectangle _line;
    }

    this() {
        _line = new Rectangle(Vec2f(getWidth(), 2f), true, 2f);
        _line.color = Atelier.theme.neutral;
        _line.anchor = Vec2f(0f, 0.5f);
        _line.alpha = 1f;
        addImage(_line);

        addEventListener("size", { _line.size = Vec2f(getWidth(), 2f); });
    }
}
