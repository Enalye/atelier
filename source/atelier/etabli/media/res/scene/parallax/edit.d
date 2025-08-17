module atelier.etabli.media.res.scene.parallax.edit;

import atelier;
import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;

final class EditParallaxElement : Modal {
    private {
        TextField _nameField;
        IntegerField _widthField, _heightField;
        NumberField _distanceField;
        RessourceButton _tilesetSelect;

        AccentButton _applyBtn;
        SceneDefinition.ParallaxLayer _layer;
    }

    this(SceneDefinition.ParallaxLayer layer) {
        _layer = layer;

        setSize(Vec2f(400f, 250f));

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

            hbox.addUI(new Label("Largeur:", Atelier.theme.font));

            _widthField = new IntegerField;
            _widthField.value = _layer.getWidth();
            _widthField.setMinValue(0);
            hbox.addUI(_widthField);

            hbox.addUI(new Label("Hauteur:", Atelier.theme.font));

            _heightField = new IntegerField;
            _heightField.value = _layer.getHeight();
            _heightField.setMinValue(0);
            hbox.addUI(_heightField);
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            vbox.addUI(hbox);

            hbox.addUI(new Label("Distance:", Atelier.theme.font));

            _distanceField = new NumberField;
            _distanceField.setMinValue(1f);
            _distanceField.value = _layer.distance;
            hbox.addUI(_distanceField);
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            vbox.addUI(hbox);

            hbox.addUI(new Label("Tileset:", Atelier.theme.font));

            _tilesetSelect = new RessourceButton(_layer.tilesetRID, "tileset", [
                    "tileset"
                ]);
            hbox.addUI(_tilesetSelect);
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

    string getTileset() const {
        return _tilesetSelect.getName();
    }

    float getDistance() const {
        return _distanceField.value();
    }

    uint getWidth() const {
        return _widthField.value();
    }

    uint getHeight() const {
        return _heightField.value();
    }
}
