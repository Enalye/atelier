module atelier.etabli.media.res.invalid;

import atelier;
import farfadet;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;

final class InvalidResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
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
