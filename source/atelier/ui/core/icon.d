/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.ui.core.icon;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.core.element;

final class Icon : UIElement {
    private {
        Sprite _icon;
    }

    this(string icon) {
        isEnabled = false;
        setIcon(icon);
    }

    void setIcon(string icon) {
        if (_icon) {
            _icon.remove();
        }

        _icon = Atelier.res.get!Sprite(icon);
        _icon.anchor = Vec2f.zero;
        _icon.position = Vec2f.zero;
        setSize(_icon.size);
        addImage(_icon);
    }
}
