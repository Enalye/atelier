/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.resourcelist;

import atelier;

final class ResourceList : Surface {
    private {
        Rectangle _rect;
    }

    this() {
        setAlign(UIAlignX.left, UIAlignY.bottom);
        setSize(Vec2f(200f, Atelier.window.height - 50f));

        addEventListener("windowSize", {
            setSize(Vec2f(200f, Atelier.window.height - 50f));
        });
    }
}
