module atelier.etabli.ui.newfile;

import std.array;
import std.path;
import std.file;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui.studio;

final class NewFile : Modal {
    private {
        SelectButton _mediaSelector, _typeSelector;
        TextField _pathField, _nameField;
        Label _pathErrorLabel, _nameErrorLabel;
        string _finalPath;
        AccentButton _createBtn;
        VBox _vbox;
    }

    this() {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(500f, 500f));

        {
            Label title = new Label("Nouveau Fichier", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 4f));
            addUI(title);
        }

        {
            IconButton exitBtn = new IconButton("editor:exit");
            exitBtn.setAlign(UIAlignX.right, UIAlignY.top);
            exitBtn.setPosition(Vec2f(4f, 4f));
            exitBtn.addEventListener("click", &removeUI);
            addUI(exitBtn);
        }

        {
            HBox validationBox = new HBox;
            validationBox.setAlign(UIAlignX.right, UIAlignY.bottom);
            validationBox.setPosition(Vec2f(10f, 10f));
            validationBox.setSpacing(8f);
            addUI(validationBox);

            auto cancelBtn = new NeutralButton("Annuler");
            cancelBtn.addEventListener("click", &removeUI);
            validationBox.addUI(cancelBtn);

            _createBtn = new AccentButton("Créer");
            _createBtn.isEnabled = false;
            _createBtn.addEventListener("click", {
                dispatchEvent("newFile", false);
            });
            validationBox.addUI(_createBtn);
        }

        {
            _vbox = new VBox;
            _vbox.setAlign(UIAlignX.center, UIAlignY.center);
            _vbox.setChildAlign(UIAlignX.left);
            addUI(_vbox);
        }

        string[] medias;
        foreach (entry; dirEntries(Atelier.etabli.getMediaDir(), SpanMode.shallow)) {
            if (!entry.isDir() || baseName(entry) !in Atelier.etabli.getMediaFolders())
                continue;

            medias ~= baseName(entry);
        }

        if (medias.length == 0) {
            Label errorLabel = new Label("Aucun dossier média de défini", Atelier.theme.font);
            errorLabel.textColor = Atelier.theme.danger;
            _vbox.addUI(errorLabel);
        }
        {
            HLayout mediaBox = new HLayout;
            mediaBox.setPadding(Vec2f(451f, 78f));
            _vbox.addUI(mediaBox);

            mediaBox.addUI(new Label("Média:", Atelier.theme.font));

            _mediaSelector = new SelectButton(medias, "");
            _mediaSelector.addEventListener("value", &_onMediaChange);
            mediaBox.addUI(_mediaSelector);
        }
        {
            VBox pathBox = new VBox;
            pathBox.setChildAlign(UIAlignX.left);
            pathBox.setSpacing(8f);
            _vbox.addUI(pathBox);

            pathBox.addUI(new Label("Dossier:", Atelier.theme.font));

            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            pathBox.addUI(hbox);

            _pathField = new TextField;
            _pathField.setWidth(400f);
            _pathField.addEventListener("value", &_onChangeField);
            hbox.addUI(_pathField);

            auto browseBtn = new NeutralButton("…");
            browseBtn.addEventListener("click", {
                auto browser = new BrowseDir(buildNormalizedPath(Atelier.etabli.getMediaDir(),
                    _mediaSelector.value));
                browser.addEventListener("value", {
                    import std.stdio;

                    writeln(browser.value);
                    writeln(buildNormalizedPath(Atelier.etabli.getMediaDir(), _mediaSelector.value));
                    writeln(asRelativePath(browser.value,
                    buildNormalizedPath(Atelier.etabli.getMediaDir(), _mediaSelector.value)));
                    _pathField.value = asRelativePath(browser.value,
                    buildNormalizedPath(Atelier.etabli.getMediaDir(), _mediaSelector.value)).array;
                    Atelier.ui.popModalUI();
                });
                Atelier.ui.pushModalUI(browser);
            });
            hbox.addUI(browseBtn);

            _pathErrorLabel = new Label("", Atelier.theme.font);
            _pathErrorLabel.textColor = Atelier.theme.danger;
            _pathErrorLabel.isVisible = false;
            pathBox.addUI(_pathErrorLabel);
        }
        {
            VBox nameBox = new VBox;
            nameBox.setChildAlign(UIAlignX.left);
            nameBox.setSpacing(8f);
            _vbox.addUI(nameBox);

            nameBox.addUI(new Label("Fichier média:", Atelier.theme.font));

            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            nameBox.addUI(hbox);

            _nameField = new TextField;
            _nameField.setWidth(400f);
            _nameField.addEventListener("value", &_onChangeField);
            hbox.addUI(_nameField);

            //hbox.addUI(new Label(".ffd", Atelier.theme.font));

            _typeSelector = new SelectButton([".ffd", ".gr", ".seq"], ".ffd");
            _typeSelector.addEventListener("value", &_onChangeField);
            hbox.addUI(_typeSelector);

            _nameErrorLabel = new Label("", Atelier.theme.font);
            _nameErrorLabel.textColor = Atelier.theme.danger;
            _nameErrorLabel.isVisible = false;
            nameBox.addUI(_nameErrorLabel);
        }
    }

    private void _onChangeField() {
        bool hasNameError = false;
        bool hasPathError = false;
        string dirPath;
        string finalPath;

        dirPath = buildNormalizedPath(Atelier.etabli.getMediaDir(), _mediaSelector.value, _pathField
                .value);
        finalPath = setExtension(buildNormalizedPath(dirPath, _nameField.value), ".ffd");

        if (!_nameField.value.length) {
            _nameErrorLabel.text = "Le nom du fichier est vide";
            hasNameError = true;
        }
        else if (extension(_nameField.value).length > 0) {
            _nameErrorLabel.text = "L’extension `" ~ extension(_nameField.value) ~ "` est en trop";
            hasNameError = true;
        }
        else if (exists(finalPath)) {
            _nameErrorLabel.text = "Un fichier portant ce nom existe déjà à cet emplacement";
            hasNameError = true;
        }

        if (!exists(dirPath)) {
            _pathErrorLabel.text = "Le chemin n’existe pas";
            hasPathError = true;
        }

        _nameErrorLabel.isVisible = hasNameError;
        _pathErrorLabel.isVisible = hasPathError;

        _createBtn.isEnabled = !hasNameError && !hasPathError;
    }

    private void _onMediaChange() {
        _pathField.value = "";
        _onChangeField();
    }

    string getFilePath() {
        string dirPath, finalPath;

        dirPath = buildNormalizedPath(Atelier.etabli.getMediaDir(), _mediaSelector.value, _pathField
                .value);
        finalPath = setExtension(buildNormalizedPath(dirPath,
                _nameField.value), _typeSelector.value);

        return finalPath;
    }
}
