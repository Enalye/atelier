/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.tabbar;

import ciel;

final class TabBar : Surface {
    private {
        Rectangle _rect;
    }

    this() {
        setSize(Vec2f(Ciel.width, 25f));

        addEventListener("windowSize", {
            setSize(Vec2f(Ciel.width, 25f));
        });
    }
}
