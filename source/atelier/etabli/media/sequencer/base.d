module atelier.etabli.media.sequencer.base;

import atelier;
import farfadet;
import atelier.etabli.media.sequencer.editor;
import atelier.etabli.media.sequencer.invalid;
import atelier.etabli.media.sequencer.pattern;
import atelier.etabli.media.sequencer.tracklist;
import atelier.etabli.ui;

package abstract class SequencerBaseEditor : UIElement {
    private {
        SequencerEditor _editor;
        string _path, _type, _rid;
    }

    @property {
        string path() const {
            return _path;
        }

        string type() const {
            return _type;
        }

        string rid() const {
            return _rid;
        }
    }

    static SequencerBaseEditor create(SequencerEditor editor, string path_, Farfadet ffd, Vec2f size) {
        Atelier.etabli.reloadResources();

        switch (ffd.name) {
        case "tracklist":
            return new TracklistSequencerEditor(editor, path_, ffd, size);
        case "pattern":
            return new PatternSequencerEditor(editor, path_, ffd, size);
        default:
            return new InvalidSequencerEditor(editor, path_, ffd, size);
        }
    }

    this(SequencerEditor editor, string path_, Farfadet ffd, Vec2f windowSize) {
        _editor = editor;
        _path = path_;
        _type = ffd.name;
        if (ffd.getCount() > 0) {
            _rid = ffd.get!string(0);
        }
        focusable = true;

        setAlign(UIAlignX.right, UIAlignY.top);
        setSize(windowSize);

        addEventListener("parentSize", &_onParentSize);
        addEventListener("register", &_onParentSize);
    }

    private void _onParentSize() {
        if (!isAlive())
            return;
        setSize(getParentSize());
    }

    final void setDirty() {
        _editor.setDirty();
    }

    abstract Farfadet save(Farfadet);
    abstract UIElement getPanel();
    void onClose() {
    }

    string[] getPatternList() {
        return _editor.getPatternList();
    }

    Farfadet getPattern(string name) {
        return _editor.getPattern(name);
    }

    void selectPattern(string name) {
        _editor.selectPattern(name);
    }
}
