module atelier.etabli.media.fontviewer;

import atelier.common;
import atelier.render;
import atelier.ui;
import atelier.etabli.media.base;

final class FontViewer : ContentEditor {
    private {
        TrueTypeFont _font;
        Label _label;
    }

    this(string path_, Vec2f windowSize) {
        super(path_, windowSize);

        _font = TrueTypeFont.fromFile(path_);
        _label = new Label("Voix ambiguë d'un cœur qui, au zéphyr, préfère les jattes de kiwis.", _font);
        _label.setAlign(UIAlignX.center, UIAlignY.center);
        addUI(_label);
    }
}
