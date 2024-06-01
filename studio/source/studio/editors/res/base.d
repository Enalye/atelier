/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.res.base;

import atelier;
import farfadet;
import studio.editors.res.invalid;
import studio.editors.res.sprite;
import studio.editors.res.texture;
import studio.editors.res.ninepatch;
import studio.editors.res.animation;
import studio.ui;

abstract class ResourceBaseEditor : UIElement {
    private {
        string _path;
    }

    @property {
        string path() const {
            return _path;
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
        default:
            return new InvalidResourceEditor(path_, ffd, size);
        }
    }

    this(string path_, Vec2f windowSize) {
        _path = path_;
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
