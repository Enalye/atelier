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
        Farfadet _ffd;
    }

    this(string path_, Farfadet ffd, Vec2f size) {
        super(path_, size);
        _ffd = ffd;

        Label label = new Label("Ressource `" ~ ffd.name ~ "` non-reconnue", Atelier.theme.font);
        label.setAlign(UIAlignX.center, UIAlignY.center);
        addUI(label);
    }

    override Farfadet save(Farfadet ffd) {
        return ffd.addNode(_ffd);
    }

    override UIElement getPanel() {
        return null;
    }
}
