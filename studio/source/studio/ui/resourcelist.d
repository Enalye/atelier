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
        auto z = new AccentButton("Accent");
        auto d = new NeutralButton("Neutral");
        auto e = new OutlinedButton("Outlined");
        auto f = new GhostButton("Ghost");
        auto g = new DangerButton("Danger");
        auto rg = new RadioGroup;
        auto rg1 = new RadioButton(rg);
        auto rg2 = new RadioButton(rg);
        auto rg3 = new RadioButton(rg);

        auto h = new HSlider();
        h.steps = 5;
        auto i = new TextField();
        auto j = new NumberField();

        auto btn = new ToggleButton("Inactive", "Active", true);
        btn.addEventListener("click", {
            z.isEnabled = !z.isEnabled;
            a.isEnabled = !a.isEnabled;
            b.isEnabled = !b.isEnabled;
            c.isEnabled = !c.isEnabled;
            d.isEnabled = !d.isEnabled;
            e.isEnabled = !e.isEnabled;
            f.isEnabled = !f.isEnabled;
            g.isEnabled = !g.isEnabled;
            h.isEnabled = !h.isEnabled;
            i.isEnabled = !i.isEnabled;
            j.isEnabled = !j.isEnabled;
            rg1.isEnabled = !rg1.isEnabled;
        });

        box.addUI(btn);
        box.addUI(z);
        box.addUI(d);
        box.addUI(e);
        box.addUI(f);
        box.addUI(g);
        box.addUI(h);
        box.addUI(i);
        box.addUI(j);
        box.addUI(a);
        box.addUI(b);
        box.addUI(c);
        box.addUI(rg1);
        box.addUI(rg2);
        box.addUI(rg3);
    }
}
