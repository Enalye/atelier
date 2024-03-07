/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.propertyeditor;

import etabli;

final class PropertyEditor : UIElement {
    private {
    }

    this() {
        setAlign(UIAlignX.right, UIAlignY.bottom);
        setSize(Vec2f(200f, Etabli.window.height - 50f));

        addEventListener("windowSize", {
            setSize(Vec2f(200f, Etabli.window.height - 50f));
        });

        addEventListener("draw", {
            Etabli.renderer.drawRect(Vec2f.zero, getSize(), Color.fromHex(0x102030), 1f, true);
        });
    }
}
