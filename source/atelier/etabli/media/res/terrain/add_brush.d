module atelier.etabli.media.res.terrain.add_brush;

import std.format;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

final class AddBrushElement : Modal {
    private {
        TextField _nameField;
        SelectButton _materialSelect;
        IntegerField _idField;
        AccentButton _applyBtn;
    }

    this() {
        setSize(Vec2f(400f, 200f));

        { // Titre
            Label titleLabel = new Label("Nouveau Pinceau", Atelier.theme.font);
            titleLabel.setAlign(UIAlignX.center, UIAlignY.top);
            titleLabel.setPosition(Vec2f(0f, 4f));
            addUI(titleLabel);
        }

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.center, UIAlignY.center);
        vbox.setSpacing(8f);
        addUI(vbox);

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(250f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Nom:", Atelier.theme.font));

            _nameField = new TextField;
            _nameField.addEventListener("value", &_onUpdateName);
            hlayout.addUI(_nameField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(250f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("ID:", Atelier.theme.font));

            _idField = new IntegerField();
            _idField.setRange(0, 255);
            hlayout.addUI(_idField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(250f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Matériau:", Atelier.theme.font));

            string[] materialList;
            foreach (i, mat; Atelier.world.getMaterials()) {
                materialList ~= format("%d - %s", i, mat.name);
            }
            _materialSelect = new SelectButton(materialList, "");
            hlayout.addUI(_materialSelect);
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

    uint getID() const {
        return cast(uint) _idField.value();
    }

    int getMaterial() const {
        return _materialSelect.ivalue();
    }
}
