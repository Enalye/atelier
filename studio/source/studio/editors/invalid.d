/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.invalid;

import atelier;

abstract class ContentEditor : UIElement {
    private {
        string _path;
    }

    @property {
        string path() const {
            return _path;
        }
    }

    this(string path_) {
        _path = path_;
        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(250f, 35f));
        setSize(Vec2f(Atelier.window.width - 500f, Atelier.window.height - 35f));

        addEventListener("parentSize", &_onParentSize);
    }

    private void _onParentSize() {
        setSize(Vec2f(getParentWidth() - 500f, getParentHeight() - 35f));
    }
}

final class InvalidContentEditor : ContentEditor {
    private {

    }

    this(string path_) {
        super(path_);

        Label label = new Label("Format non-recconnu", Atelier.theme.font);
        label.setAlign(UIAlignX.center, UIAlignY.center);
        addUI(label);
    }
}
