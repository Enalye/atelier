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
import studio.ui;

abstract class ResourceBaseEditor : UIElement {
    static ResourceBaseEditor create(Farfadet ffd, Vec2f size) {
        Studio.reloadResources();

        switch (ffd.name) {
        case "sprite":
            return new SpriteResourceEditor(ffd, size);
        default:
            return new InvalidResourceEditor(ffd, size);
        }
    }

    this(Vec2f windowSize) {
        focusable = true;

        setAlign(UIAlignX.right, UIAlignY.top);
        setPosition(Vec2f(0f, 35f));
        setSize(Vec2f(windowSize.x - 250f, windowSize.y - 35f));

        addEventListener("parentSize", &_onParentSize);
        addEventListener("register", &_onParentSize);
    }

    private void _onParentSize() {
        if (!isAlive())
            return;
        setSize(Vec2f(getParentWidth() - 250f, getParentHeight() - 35f));
    }

    abstract Farfadet save(Farfadet);
}
