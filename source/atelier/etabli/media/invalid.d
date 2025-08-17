module atelier.etabli.media.invalid;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.etabli.media.base;

final class InvalidContentEditor : ContentEditor {
    private {

    }

    this(string path_, Vec2f windowSize) {
        super(path_, windowSize);

        Label label = new Label("Format non-reconnu", Atelier.theme.font);
        label.setAlign(UIAlignX.center, UIAlignY.center);
        addUI(label);
    }
}
