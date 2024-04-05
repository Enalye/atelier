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

    static ContentEditor create(string path) {
        switch (extension(path)) {
        case ".png":
        case ".bmp":
        case ".jpg":
        case ".jpeg":
        case ".gif":
            return new ImageViewer(path);
        case ".ogg":
        case ".wav":
        case ".mp3":
            return new AudioViewer(path);
        case ".ttf":
            return new FontViewer(path);
        case ".txt":
        case ".log":
        case ".ini":
        case ".md":
        case ".gr":
            return new TextEditor(path);
        default:
            return new InvalidContentEditor(path);
        }
    }

    this(string path_) {
        _path = path_;
        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(250f, 35f));
        setSize(Vec2f(Atelier.window.width - 500f, Atelier.window.height - 35f));

        addEventListener("parentSize", &_onParentSize);
        addEventListener("register", &_onParentSize);
    }

    private void _onParentSize() {
        setSize(Vec2f(getParentWidth() - 500f, getParentHeight() - 35f));
    }
}
