/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editor.invalid;

import atelier;
import studio.editor.base;

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
