module atelier.etabli.media.res.scene.collision.edit;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;
import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;

final class EditCollisionElement : Modal {
    private {
        TextField _nameField;
        IntegerField _levelField;

        AccentButton _applyBtn;
        SceneDefinition.CollisionLayer _layer;
    }

    this(SceneDefinition.CollisionLayer layer) {
        _layer = layer;

        setSize(Vec2f(400f, 200f));

        { // Titre
            Label titleLabel = new Label("Modifier le calque", Atelier.theme.font);
            titleLabel.setAlign(UIAlignX.center, UIAlignY.top);
            titleLabel.setPosition(Vec2f(0f, 4f));
            addUI(titleLabel);
        }

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.center, UIAlignY.center);
        vbox.setChildAlign(UIAlignX.left);
        vbox.setSpacing(8f);
        addUI(vbox);

        {
            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            vbox.addUI(hbox);

            hbox.addUI(new Label("Nom:", Atelier.theme.font));

            _nameField = new TextField;
            _nameField.value = _layer.name;
            _nameField.addEventListener("value", &_onUpdateName);
            hbox.addUI(_nameField);
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            vbox.addUI(hbox);

            hbox.addUI(new Label("Niveau:", Atelier.theme.font));

            _levelField = new IntegerField;
            _levelField.value = _layer.level;
            hbox.addUI(_levelField);
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

            _applyBtn = new AccentButton("Modifier");
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

    int getLevel() const {
        return _levelField.value();
    }
}
