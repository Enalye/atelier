/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.tabbar;

import etabli;

final class TabBar : UIElement {
    private {
    }

    this() {
        setSize(Vec2f(Etabli.window.width, 25f));

        addEventListener("windowSize", {
            setSize(Vec2f(Etabli.window.width, 25f));
        });

        addEventListener("draw", {
            Etabli.renderer.drawRect(Vec2f.zero, getSize(), Color.fromHex(0x202020), 1f, true);
        });
    }
}
