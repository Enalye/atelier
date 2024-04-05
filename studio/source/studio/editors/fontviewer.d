/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.fontviewer;

import atelier;
import studio.editors.base;

final class FontViewer : ContentEditor {
    private {
        TrueTypeFont _font;
        Label _label;
    }

    this(string path_) {
        super(path_);

        _font = TrueTypeFont.fromFile(path_);
        _label = new Label("Voix ambiguë d'un cœur qui, au zéphyr, préfère les jattes de kiwis.", _font);
        _label.setAlign(UIAlignX.center, UIAlignY.center);
        addUI(_label);
    }
}
