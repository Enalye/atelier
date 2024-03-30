/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.panel.surface;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.core;

class Surface : UIElement {
    private {
        Rectangle _background;
    }

    this() {
        _background = new Rectangle(getSize(), true, 1f);
        _background.color = Atelier.theme.surface;
        _background.anchor = Vec2f.zero;
        addImage(_background);

        addEventListener("size", &_onSizeChange);
    }

    private void _onSizeChange() {
        _background.size = getSize();
    }
}
