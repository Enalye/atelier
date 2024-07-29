/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editor.res.base;

import atelier;
import farfadet;
import studio.editor.res.animation;
import studio.editor.res.invalid;
import studio.editor.res.ninepatch;
import studio.editor.res.sprite;
import studio.editor.res.texture;
import studio.editor.res.tilemap;
import studio.editor.res.tileset;
import studio.ui;

abstract class ResourceBaseEditor : UIElement {
    private {
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

    static ResourceBaseEditor create(string path_, Farfadet ffd, Vec2f size) {
        Studio.reloadResources();

        switch (ffd.name) {
        case "texture":
            return new TextureResourceEditor(path_, ffd, size);
        case "sprite":
            return new SpriteResourceEditor(path_, ffd, size);
        case "ninepatch":
            return new NinePatchResourceEditor(path_, ffd, size);
        case "animation":
            return new AnimationResourceEditor(path_, ffd, size);
        case "tileset":
            return new TilesetResourceEditor(path_, ffd, size);
        case "tilemap":
            return new TilemapResourceEditor(path_, ffd, size);
        default:
            return new InvalidResourceEditor(path_, ffd, size);
        }
    }

    this(string path_, Farfadet ffd, Vec2f windowSize) {
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

    abstract Farfadet save(Farfadet);
    abstract UIElement getPanel();
}
