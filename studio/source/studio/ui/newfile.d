/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.newfile;

import std.array;
import std.path;
import std.file;
import atelier;
import studio.project;

final class NewFile : Modal {
    private {
        SelectButton _mediaSelector;
        TextField _pathField, _nameField;
        Label _pathErrorLabel, _nameErrorLabel;
        string _finalPath;
        AccentButton _createBtn;
        TabGroup _typeTab;
        VBox _vbox;
    }

    this(bool isSource) {
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
            _typeTab = new TabGroup;
            _typeTab.setAlign(UIAlignX.left, UIAlignY.top);
            _typeTab.setWidth(getWidth());
            _typeTab.setPosition(Vec2f(0f, 32f));
            addUI(_typeTab);

            _typeTab.addTab("Média", "media", "");
            _typeTab.addTab("Source", "source", "");
            _typeTab.selectTab("media");

            _typeTab.addEventListener("value", &_onTypeTab);
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
        _onTypeTab();
    }

    private void _onTypeTab() {
        _vbox.clearUI();

        switch (_typeTab.value) {
        case "media":
            if (Project.getMedias().length == 0) {
                Label errorLabel = new Label("Aucun dossier média de défini", Atelier.theme.font);
                errorLabel.textColor = Atelier.theme.danger;
                _vbox.addUI(errorLabel);
                break;
            }
            {
                VBox typeBox = new VBox;
                typeBox.setChildAlign(UIAlignX.left);
                typeBox.setSpacing(8f);
                _vbox.addUI(typeBox);

                typeBox.addUI(new Label("Média:", Atelier.theme.font));

                _mediaSelector = new SelectButton(Project.getMedias().keys, "");
                _mediaSelector.addEventListener("value", &_onMediaChange);
                typeBox.addUI(_mediaSelector);
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
                    auto browser = new BrowseDir(buildNormalizedPath(Project.getMediaDir(),
                        _mediaSelector.value));
                    browser.addEventListener("value", {
                        _pathField.value = asRelativePath(browser.value,
                        buildNormalizedPath(Project.getMediaDir(), _mediaSelector.value)).array;
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

                hbox.addUI(new Label(".ffd", Atelier.theme.font));

                _nameErrorLabel = new Label("", Atelier.theme.font);
                _nameErrorLabel.textColor = Atelier.theme.danger;
                _nameErrorLabel.isVisible = false;
                nameBox.addUI(_nameErrorLabel);
            }
            break;
        case "source": {
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
                    auto browser = new BrowseDir(Project.getSourceDir());
                    browser.addEventListener("value", {
                        _pathField.value = asRelativePath(browser.value,
                        Project.getSourceDir()).array;
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

                nameBox.addUI(new Label("Fichier source:", Atelier.theme.font));

                HBox hbox = new HBox;
                hbox.setSpacing(4f);
                nameBox.addUI(hbox);

                _nameField = new TextField;
                _nameField.setWidth(400f);
                _nameField.addEventListener("value", &_onChangeField);
                hbox.addUI(_nameField);

                hbox.addUI(new Label(".gr", Atelier.theme.font));

                _nameErrorLabel = new Label("", Atelier.theme.font);
                _nameErrorLabel.textColor = Atelier.theme.danger;
                _nameErrorLabel.isVisible = false;
                nameBox.addUI(_nameErrorLabel);
            }
            break;
        default:
            break;
        }
    }

    private void _onChangeField() {
        bool hasNameError = false;
        bool hasPathError = false;
        string dirPath;
        string finalPath;

        switch (_typeTab.value) {
        case "media":
            dirPath = buildNormalizedPath(Project.getMediaDir(),
                _mediaSelector.value, _pathField.value);
            finalPath = setExtension(buildNormalizedPath(dirPath, _nameField.value), ".ffd");
            break;
        case "source":
            dirPath = buildNormalizedPath(Project.getSourceDir(), _pathField.value);
            finalPath = setExtension(buildNormalizedPath(dirPath, _nameField.value), ".gr");
            break;
        default:
            break;
        }

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

        switch (_typeTab.value) {
        case "media":
            dirPath = buildNormalizedPath(Project.getMediaDir(),
                _mediaSelector.value, _pathField.value);
            finalPath = setExtension(buildNormalizedPath(dirPath, _nameField.value), ".ffd");
            break;
        case "source":
            dirPath = buildNormalizedPath(Project.getSourceDir(), _pathField.value);
            finalPath = setExtension(buildNormalizedPath(dirPath, _nameField.value), ".gr");
            break;
        default:
            break;
        }

        return finalPath;
    }
}
