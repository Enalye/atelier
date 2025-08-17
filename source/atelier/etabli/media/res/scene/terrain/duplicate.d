module atelier.etabli.media.res.scene.terrain.duplicate;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

final class DuplicateTerrainElement : Modal {
    private {
        TextField _nameField;
        AccentButton _applyBtn;
    }

    this(string name) {
        setSize(Vec2f(400f, 150f));

        { // Titre
            Label titleLabel = new Label("Dupliquer le calque `" ~ name ~ "`", Atelier.theme.font);
            titleLabel.setAlign(UIAlignX.center, UIAlignY.top);
            titleLabel.setPosition(Vec2f(0f, 4f));
            addUI(titleLabel);
        }

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.center, UIAlignY.center);
            hbox.setSpacing(8f);
            addUI(hbox);

            hbox.addUI(new Label("Nom:", Atelier.theme.font));

            _nameField = new TextField;
            _nameField.addEventListener("value", &_onUpdateName);
            hbox.addUI(_nameField);
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

            _applyBtn = new AccentButton("Créer");
            _applyBtn.isEnabled = false;
            _applyBtn.addEventListener("click", &_onApply);
            hbox.addUI(_applyBtn);
        }
    }

    private void _onApply() {
        dispatchEvent("apply", false);
        removeUI();
    }

    private void _onUpdateName() {
        _applyBtn.isEnabled = _nameField.value.length > 0;
    }

    string getName() const {
        return _nameField.value;
    }
}
