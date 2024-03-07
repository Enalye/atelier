/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.taskbar;

import etabli;

final class TaskBar : UIElement {
    private {
    }

    this() {
        setSize(Vec2f(Etabli.window.width, 25f));

        addEventListener("windowSize", {
            setSize(Vec2f(Etabli.window.width, 25f));
        });

        addEventListener("draw", {
            Etabli.renderer.drawRect(Vec2f.zero, getSize(), Color.fromHex(0x303030), 1f, true);
        });
    }
}
