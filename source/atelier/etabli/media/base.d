module atelier.etabli.media.base;

import std.file;
import std.path;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.etabli.media.codeeditor;
import atelier.etabli.media.imageviewer;
import atelier.etabli.media.fontviewer;
import atelier.etabli.media.audioviewer;
import atelier.etabli.media.texteditor;
import atelier.etabli.media.res;
import atelier.etabli.media.sequencer;
import atelier.etabli.media.invalid;
import atelier.etabli.ui;

abstract class ContentEditor : UIElement {
    private {
        string _path;

        alias CreateContentEditorFunc = ContentEditor function(string, Vec2f);
        static CreateContentEditorFunc[string] _createContentEditorFuncs;
    }

    @property {
        string path() const {
            return _path;
        }
    }

    static add(string type, CreateContentEditorFunc func) {
        _createContentEditorFuncs[type] = func;
    }

    static ContentEditor create(string path, Vec2f windowSize) {
        auto p = extension(path) in _createContentEditorFuncs;
        if (p !is null) {
            return (*p)(path, windowSize);
        }

        return new InvalidContentEditor(path, windowSize);
    }

    this(string path_, Vec2f windowSize) {
        _path = path_;
        focusable = true;

        setAlign(UIAlignX.right, UIAlignY.top);
        setPosition(Vec2f(0f, 35f));
        setSize(Vec2f(windowSize.x - 250f, windowSize.y - 35f));

        /*addEventListener("parentSize", &_onParentSize);
        addEventListener("register", &_onParentSize);
        addEventListener("register", &focus);*/
    }

    final void setDirty() {
        Atelier.etabli.setDirty(path(), true);
    }

    private void _onParentSize() {
        if (!isAlive())
            return;
        setSize(Vec2f(max(0f, getParentWidth() - 250f), max(0f, getParentHeight() - 35f)));
    }

    UIElement getPanel() {
        return null;
    }

    UIElement getRightPanel() {
        return null;
    }

    void onClose() {
    }

    void save() {
    }

    void saveView() {
    }

    void loadView() {
    }
}
