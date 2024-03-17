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

        addEventListener("windowSize", { setSize(Vec2f(200f, Ciel.height - 50f)); });

        VBox box = new VBox;
        box.setSpacing(10f);
        addUI(box);

        auto a = new SwitchButton();
        auto b = new ToggleButton("inactif", "actif");
        auto c = new Checkbox();

        auto btn = new PrimaryButton("Primary");
        btn.addEventListener("click", {
            a.value = !b.value;
            b.value = !c.value;
            c.value = !a.value;
        });

        auto rg = new RadioGroup;

        box.addUI(btn);
        box.addUI(new SecondaryButton("Secondary"));
        box.addUI(new OutlinedButton("Outlined"));
        box.addUI(new GhostButton("Ghost"));
        box.addUI(new DangerButton("Danger"));
        box.addUI(new HSlider());
        box.addUI(new TextField());
        box.addUI(new NumberField());
        box.addUI(a);
        box.addUI(b);
        box.addUI(c);
        box.addUI(new RadioButton(rg));
        box.addUI(new RadioButton(rg));
        box.addUI(new RadioButton(rg));
    }
}
