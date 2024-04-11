/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.base;

import std.file;
import std.path;
import atelier;
import studio.editors.imageviewer;
import studio.editors.fontviewer;
import studio.editors.audioviewer;
import studio.editors.texteditor;
import studio.editors.invalid;

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
        case ".gr":
            return new TextEditor(path, windowSize);
        default:
            return new InvalidContentEditor(path, windowSize);
        }
    }

    this(string path_, Vec2f windowSize) {
        _path = path_;
        focusable = true;

        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(250f, 35f));
        setSize(Vec2f(windowSize.x - 500f, windowSize.y - 35f));

        addEventListener("parentSize", &_onParentSize);
        addEventListener("register", &_onParentSize);
        addEventListener("register", &focus);
    }

    private void _onParentSize() {
        if(!isAlive())
            return;
        setSize(Vec2f(getParentWidth() - 500f, getParentHeight() - 35f));
    }
}
