/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.res.invalid;

import atelier;
import farfadet;
import studio.editors.res.base;

final class InvalidResourceEditor : ResourceBaseEditor {
    private {

    }

    this(Farfadet ffd, Vec2f size) {
        super(ffd, size);

        Label label = new Label("Ressource `" ~ ffd.name ~ "` non-reconnu", Atelier.theme.font);
        label.setAlign(UIAlignX.center, UIAlignY.center);
        addUI(label);
    }
}
