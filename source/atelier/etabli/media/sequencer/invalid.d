module atelier.etabli.media.sequencer.invalid;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.media.sequencer.base;
import atelier.etabli.media.sequencer.editor;

package final class InvalidSequencerEditor : SequencerBaseEditor {
    private {
        Farfadet _ffd;
    }

    this(SequencerEditor editor, string path_, Farfadet ffd, Vec2f size) {
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
