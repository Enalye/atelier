/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.propertyeditor;

import ciel;

final class PropertyEditor : Surface {
    private {
    }

    this() {
        setAlign(UIAlignX.right, UIAlignY.bottom);
        setSize(Vec2f(200f, Ciel.height - 50f));

        addEventListener("windowSize", {
            setSize(Vec2f(200f, Ciel.height - 50f));
        });
    }
}
