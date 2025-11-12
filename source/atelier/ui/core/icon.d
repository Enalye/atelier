module atelier.ui.core.icon;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.core.element;

final class Icon : UIElement {
    private {
        Sprite _icon;
    }

    this() {

    }

    this(string icon) {
        isEnabled = false;
        setIcon(icon);
    }

    void removeIcon() {
        if (_icon) {
            _icon.remove();
        }
    }

    void setIcon(string icon) {
        removeIcon();

        _icon = Atelier.res.get!Sprite(icon);
        _icon.anchor = Vec2f.zero;
        _icon.position = Vec2f.zero;
        setSize(_icon.size);
        addImage(_icon);
    }
}
