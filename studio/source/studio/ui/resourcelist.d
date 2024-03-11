/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.resourcelist;

import ciel;

final class ResourceList : Surface {
    private {
        Rectangle _rect;
    }

    this() {
        setAlign(UIAlignX.left, UIAlignY.bottom);
        setSize(Vec2f(200f, Ciel.height - 50f));

        addEventListener("windowSize", {
            setSize(Vec2f(200f, Ciel.height - 50f));
        });

        VBox box = new VBox;
        box.setSpacing(10f);
        addUI(box);

        box.addUI(new PrimaryButton("Primary"));
        box.addUI(new SecondaryButton("Secondary"));
        box.addUI(new OutlinedButton("Outlined"));
        box.addUI(new GhostButton("Ghost"));
        box.addUI(new DangerButton("Danger"));
    }
}
