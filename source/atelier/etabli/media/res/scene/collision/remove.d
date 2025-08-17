module atelier.etabli.media.res.scene.collision.remove;

import atelier;
import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;

final class RemoveCollisionElement : Modal {
    this(SceneDefinition.CollisionLayer layer) {
        setSize(Vec2f(300f, 100f));

        { // Titre
            Label titleLabel = new Label("Supprimer le calque `" ~ layer.name ~ "` ?",
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
