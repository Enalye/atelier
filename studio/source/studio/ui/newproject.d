/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.newproject;

import std.path;
import std.file;
import atelier;

final class NewProject : Modal {
    private {
        TextField _nameField, _pathField, _configField, _sourceField;
        Label _nameErrorLabel, _pathErrorLabel, _configErrorLabel, _sourceErrorLabel;
        string _finalPath;
        AccentButton _createBtn;
    }

    @property {
        string path() const {
            return _finalPath;
        }

        string configName() const {
            return _configField.value;
        }

        string sourceFile() const {
            return setExtension(_sourceField.value, ".gr");
        }
    }

    this() {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(500f, 500f));

        Label title = new Label("Nouveau Projet", Atelier.theme.font);
        title.setAlign(UIAlignX.center, UIAlignY.top);
        title.setPosition(Vec2f(0f, 4f));
        addUI(title);

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.left, UIAlignY.center);
        vbox.setPosition(Vec2f(8f, 0f));
        vbox.setChildAlign(UIAlignX.left);
        vbox.setSpacing(16f);
        addUI(vbox);

        {
            VBox nameBox = new VBox;
            nameBox.setChildAlign(UIAlignX.left);
            nameBox.setSpacing(8f);
            vbox.addUI(nameBox);

            nameBox.addUI(new Label("Nom du projet:", Atelier.theme.font));

            _nameField = new TextField;
            _nameField.setWidth(400f);
            _nameField.addEventListener("value", &_onChangeField);
            nameBox.addUI(_nameField);

            _nameErrorLabel = new Label("", Atelier.theme.font);
            _nameErrorLabel.color = Atelier.theme.danger;
            _nameErrorLabel.isVisible = false;
            nameBox.addUI(_nameErrorLabel);
        }

        {
            VBox configBox = new VBox;
            configBox.setChildAlign(UIAlignX.left);
            configBox.setSpacing(8f);
            vbox.addUI(configBox);

            configBox.addUI(new Label("Configuration:", Atelier.theme.font));

            _configField = new TextField;
            _configField.value = "app";
            _configField.setWidth(400f);
            _configField.addEventListener("value", &_onChangeField);
            configBox.addUI(_configField);

            _configErrorLabel = new Label("", Atelier.theme.font);
            _configErrorLabel.color = Atelier.theme.danger;
            _configErrorLabel.isVisible = false;
            configBox.addUI(_configErrorLabel);
        }

        {
            VBox sourceBox = new VBox;
            sourceBox.setChildAlign(UIAlignX.left);
            sourceBox.setSpacing(8f);
            vbox.addUI(sourceBox);

            sourceBox.addUI(new Label("Fichier source:", Atelier.theme.font));

            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            sourceBox.addUI(hbox);

            _sourceField = new TextField;
            _sourceField.value = "app";
            _sourceField.setWidth(400f);
            _sourceField.addEventListener("value", &_onChangeField);
            hbox.addUI(_sourceField);

            hbox.addUI(new Label(".gr", Atelier.theme.font));

            _sourceErrorLabel = new Label("", Atelier.theme.font);
            _sourceErrorLabel.color = Atelier.theme.danger;
            _sourceErrorLabel.isVisible = false;
            sourceBox.addUI(_sourceErrorLabel);
        }

        {
            VBox pathBox = new VBox;
            pathBox.setChildAlign(UIAlignX.left);
            pathBox.setSpacing(8f);
            vbox.addUI(pathBox);

            pathBox.addUI(new Label("Dossier du projet:", Atelier.theme.font));

            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            pathBox.addUI(hbox);

            _pathField = new TextField;
            _pathField.value = getcwd();
            _pathField.setWidth(400f);
            _pathField.addEventListener("value", &_onChangeField);
            hbox.addUI(_pathField);

            auto browseBtn = new NeutralButton("…");
            browseBtn.addEventListener("click", {
                auto browser = new BrowseDir(_pathField.value);
                browser.addEventListener("value", {
                    _pathField.value = browser.value;
                    Atelier.ui.popModalUI();
                });
                Atelier.ui.pushModalUI(browser);
            });
            hbox.addUI(browseBtn);

            _pathErrorLabel = new Label("", Atelier.theme.font);
            _pathErrorLabel.color = Atelier.theme.danger;
            _pathErrorLabel.isVisible = false;
            pathBox.addUI(_pathErrorLabel);
        }

        HBox validationBox = new HBox;
        validationBox.setAlign(UIAlignX.right, UIAlignY.bottom);
        validationBox.setPosition(Vec2f(10f, 10f));
        validationBox.setSpacing(8f);
        addUI(validationBox);

        auto cancelBtn = new NeutralButton("Annuler");
        cancelBtn.addEventListener("click", { remove(); });
        validationBox.addUI(cancelBtn);

        _createBtn = new AccentButton("Créer");
        _createBtn.isEnabled = false;
        _createBtn.addEventListener("click", {
            dispatchEvent("newProject", false);
        });
        validationBox.addUI(_createBtn);

        _onChangeField();
    }

    private void _onChangeField() {
        _finalPath = buildNormalizedPath(_pathField.value, _nameField.value);
        bool hasNameError = false;
        bool hasConfigError = false;
        bool hasSourceError = false;
        bool hasPathError = false;

        if (!_nameField.value.length) {
            _nameErrorLabel.text = "Le nom du projet est vide";
            hasNameError = true;
        }
        else if (exists(_finalPath)) {
            _nameErrorLabel.text = "Un dossier portant ce nom existe déjà";
            hasNameError = true;
        }

        if (!_configField.value.length) {
            _configErrorLabel.text = "Le nom de la configuration est vide";
            hasConfigError = true;
        }

        if (!_sourceField.value.length) {
            _sourceErrorLabel.text = "Le fichier source n’est pas défini";
            hasSourceError = true;
        }

        if (!exists(_pathField.value)) {
            _pathErrorLabel.text = "Le chemin n’existe pas";
            hasPathError = true;
        }

        _nameErrorLabel.isVisible = hasNameError;
        _configErrorLabel.isVisible = hasConfigError;
        _sourceErrorLabel.isVisible = hasSourceError;
        _pathErrorLabel.isVisible = hasPathError;

        _createBtn.isEnabled = !hasNameError && !hasConfigError && !hasSourceError && !hasPathError;
    }
}
