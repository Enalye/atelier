/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editor.base;

import std.file;
import std.path;
import atelier;
import studio.editor.codeeditor;
import studio.editor.imageviewer;
import studio.editor.fontviewer;
import studio.editor.audioviewer;
import studio.editor.texteditor;
import studio.editor.res;
import studio.editor.invalid;
import studio.ui;

abstract class ContentEditor : UIElement {
    private {
        string _path;
    }

    @property {
        string path() const {
            return _path;
        }
    }

    static ContentEditor create(string path, Vec2f windowSize) {
        switch (extension(path)) {
        case ".png":
        case ".bmp":
        case ".jpg":
        case ".jpeg":
        case ".gif":
            return new ImageViewer(path, windowSize);
        case ".ogg":
        case ".wav":
        case ".mp3":
            return new AudioViewer(path, windowSize);
        case ".ttf":
            return new FontViewer(path, windowSize);
        case ".txt":
        case ".log":
        case ".ini":
        case ".md":
            return new TextEditor(path, windowSize);
        case ".gr":
            return new CodeEditor(path, windowSize);
        case ".ffd":
            return new ResourceEditor(path, windowSize);
        default:
            return new InvalidContentEditor(path, windowSize);
        }
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
        Studio.setDirty(path(), true);
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
}
