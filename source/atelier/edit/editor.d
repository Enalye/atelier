/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.edit.editor;

import atelier.common;
import atelier.core;
import atelier.ui;

final class Editor : UIElement {
    private {

    }

    this() {
        setSize(cast(Vec2f) Atelier.renderer.size);
        setAlign(UIAlignX.right, UIAlignY.bottom);
        setPosition(Vec2f(10f, 10f));

        addEventListener("windowSize", {
            setSize(cast(Vec2f) Atelier.renderer.size);
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Color.blue, 1f, true);
        });
    }
}
