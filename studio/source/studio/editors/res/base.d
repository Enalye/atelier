/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.res.base;

import atelier;
import farfadet;
import studio.editors.res.invalid;

abstract class ResourceBaseEditor : UIElement {
    private {
        Farfadet _ffd;
    }

    static ResourceBaseEditor create(Farfadet ffd, Vec2f size) {
        switch (ffd.name) {
        default:
            return new InvalidResourceEditor(ffd, size);
        }
    }

    this(Farfadet ffd_, Vec2f windowSize) {
        _ffd = ffd_;
        focusable = true;

        setAlign(UIAlignX.right, UIAlignY.top);
        setPosition(Vec2f(0f, 35f));
        setSize(Vec2f(windowSize.x - 250f, windowSize.y - 35f));

        addEventListener("parentSize", &_onParentSize);
        addEventListener("register", &_onParentSize);
        addEventListener("register", &focus);
    }

    private void _onParentSize() {
        if (!isAlive())
            return;
        setSize(Vec2f(getParentWidth() - 250f, getParentHeight() - 35f));
    }
}
