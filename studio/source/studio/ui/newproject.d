/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.newproject;

import ciel;

final class NewProject : Modal {
    private {
    }

    this() {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(500f, 300f));

        /*auto path = new PathField;
        path.setPosition(Vec2f(10f, 10f));
        addUI(path);*/

        HBox validationBox = new HBox;
        validationBox.setAlign(UIAlignX.right, UIAlignY.bottom);
        validationBox.setPosition(Vec2f(10f, 10f));
        validationBox.setSpacing(8f);
        addUI(validationBox);

        auto cancelBtn = new SecondaryButton("Annuler");
        cancelBtn.addEventListener("click", { remove(); });
        validationBox.addUI(cancelBtn);

        auto createBtn = new PrimaryButton("Créer");
        validationBox.addUI(createBtn);
    }
}
