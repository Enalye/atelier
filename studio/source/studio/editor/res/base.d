/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editor.res.base;

import atelier;
import farfadet;
import studio.editor.res.animation;
import studio.editor.res.editor;
import studio.editor.res.grid;
import studio.editor.res.invalid;
import studio.editor.res.music;
import studio.editor.res.ninepatch;
import studio.editor.res.particle;
import studio.editor.res.scene;
import studio.editor.res.sound;
import studio.editor.res.sprite;
import studio.editor.res.texture;
import studio.editor.res.tilemap;
import studio.editor.res.tileset;
import studio.editor.res.truetype;
import studio.ui;

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

    static ResourceBaseEditor create(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        Studio.reloadResources();

        switch (ffd.name) {
        case "texture":
            return new TextureResourceEditor(editor, path_, ffd, size);
        case "sprite":
            return new SpriteResourceEditor(editor, path_, ffd, size);
        case "ninepatch":
            return new NinePatchResourceEditor(editor, path_, ffd, size);
        case "animation":
            return new AnimationResourceEditor(editor, path_, ffd, size);
        case "tileset":
            return new TilesetResourceEditor(editor, path_, ffd, size);
        case "tilemap":
            return new TilemapResourceEditor(editor, path_, ffd, size);
        case "particle":
            return new ParticleResourceEditor(editor, path_, ffd, size);
        case "sound":
            return new SoundResourceEditor(editor, path_, ffd, size);
        case "music":
            return new MusicResourceEditor(editor, path_, ffd, size);
        case "truetype":
            return new TrueTypeResourceEditor(editor, path_, ffd, size);
        case "scene":
            return new SceneResourceEditor(editor, path_, ffd, size);
        case "grid":
            switch (ffd.getNode("type").get!string(0)) {
            case "bool":
                return new GridResourceEditor!bool(editor, path_, ffd, size);
            case "int":
                return new GridResourceEditor!int(editor, path_, ffd, size);
            case "uint":
                return new GridResourceEditor!uint(editor, path_, ffd, size);
            case "float":
                return new GridResourceEditor!float(editor, path_, ffd, size);
            default:
                break;
            }
            goto default;
        default:
            return new InvalidResourceEditor(editor, path_, ffd, size);
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
}
