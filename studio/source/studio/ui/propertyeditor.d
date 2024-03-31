/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.propertyeditor;

import atelier;

final class PropertyEditor : Surface {
    private {
    }

    this() {
        setAlign(UIAlignX.right, UIAlignY.bottom);
        setSize(Vec2f(200f, Atelier.window.height - 50f));

        addEventListener("windowSize", {
            setSize(Vec2f(200f, Atelier.window.height - 50f));
        });
    }
}
