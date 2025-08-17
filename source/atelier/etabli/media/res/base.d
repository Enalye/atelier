module atelier.etabli.media.res.base;

import farfadet;
import atelier.common;
import atelier.ui;
import atelier.etabli.media.res.editor;
import atelier.etabli.ui;

abstract class ResourceBaseEditor : UIElement {
    private {
        ResourceEditor _editor;
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

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f windowSize) {
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

    void saveView() {
    }

    void loadView() {
    }
}
