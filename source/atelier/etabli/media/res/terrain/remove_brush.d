module atelier.etabli.media.res.terrain.remove_brush;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;

final class RemoveBrushElement : Modal {
    this(string name) {
        setSize(Vec2f(300f, 100f));

        { // Titre
            Label titleLabel = new Label("Supprimer le Pinceau `" ~ name ~ "` ?",
                Atelier.theme.font);
            titleLabel.setAlign(UIAlignX.center, UIAlignY.top);
            titleLabel.setPosition(Vec2f(0f, 4f));
            addUI(titleLabel);
        }

        { // Validation
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.right, UIAlignY.bottom);
            hbox.setPosition(Vec2f(4f, 4f));
            hbox.setSpacing(8f);
            addUI(hbox);

            NeutralButton cancelBtn = new NeutralButton("Annuler");
            cancelBtn.addEventListener("click", &removeUI);
            hbox.addUI(cancelBtn);

            DangerButton applyBtn = new DangerButton("Supprimer");
            applyBtn.addEventListener("click", &_onApply);
            hbox.addUI(applyBtn);
        }
    }

    private void _onApply() {
        dispatchEvent("apply", false);
        removeUI();
    }
}
