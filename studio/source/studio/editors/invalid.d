/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.invalid;

import atelier;
import studio.editors.base;

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
