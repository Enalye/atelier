/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.panel.modal;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.core;

class Modal : UIElement {
    private {
        RoundedRectangle _background, _outline;
    }

    this() {
        movable = true;

        _background = RoundedRectangle.fill(getSize(), Atelier.theme.corner);
        _background.anchor = Vec2f.zero;
        _background.color = Atelier.theme.surface;
        addImage(_background);

        _outline = RoundedRectangle.outline(getSize(), Atelier.theme.corner, 1f);
        _outline.anchor = Vec2f.zero;
        _outline.color = Atelier.theme.neutral;
        addImage(_outline);

        addEventListener("size", &_onSizeChange);
    }

    private void _onSizeChange() {
        _background.size = getSize();
        _outline.size = getSize();
    }
}
