module atelier.etabli.ui.resourcemanager;

import std.path;
import std.file;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui.studio;

final class ResourceFolderManager : Modal {
    private {
        VList _list;
    }

    this() {
        setSize(Vec2f(700f, 500f));

        Label titleLabel = new Label("Dossiers de Ressources", Atelier.theme.font);
        titleLabel.setAlign(UIAlignX.center, UIAlignY.top);
        titleLabel.setPosition(Vec2f(0f, 4f));
        addUI(titleLabel);

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.center, UIAlignY.center);
        vbox.setChildAlign(UIAlignX.left);
        vbox.setSpacing(8f);
        addUI(vbox);

        AccentButton addBtn = new AccentButton("+ Ajouter");
        addBtn.setAlign(UIAlignX.left, UIAlignY.top);
        addBtn.setPosition(Vec2f(4f, 32f));
        addBtn.addEventListener("click", &_onAddFolder);
        vbox.addUI(addBtn);

        _list = new VList;
        _list.setSize(Vec2f(650f, 400f));
        _list.setPosition(Vec2f(0f, 8f));
        vbox.addUI(_list);

        foreach (name, isArchived; Atelier.etabli.getMediaFolders()) {
            auto elt = new ResourceFolderElement(name, isArchived);
            _list.addList(elt);
        }

        HBox hbox = new HBox;
        hbox.setAlign(UIAlignX.right, UIAlignY.bottom);
        hbox.setPosition(Vec2f(4f, 4f));
        hbox.setSpacing(8f);
        addUI(hbox);

        NeutralButton cancelBtn = new NeutralButton("Annuler");
        cancelBtn.addEventListener("click", &removeUI);
        hbox.addUI(cancelBtn);

        AccentButton applyBtn = new AccentButton("Appliquer");
        applyBtn.addEventListener("click", &_onApply);
        hbox.addUI(applyBtn);
    }

    private void _onAddFolder() {
        auto elt = new ResourceFolderElement("", true);
        _list.addList(elt);
    }

    private void _onApply() {
        bool[string] folders;
        auto list = cast(ResourceFolderElement[]) _list.getList();
        foreach (elt; list) {
            folders[elt._nameField.value] = elt._archivedCheckbox.value;
        }
        Atelier.etabli.setMediaFolders(folders);
        dispatchEvent("updateRessourceFolders", false);
        removeUI();
    }
}

final class ResourceFolderElement : UIElement {
    private {
        Label _errorLabel;
        TextField _nameField;
        Checkbox _archivedCheckbox;
        DangerButton _removeBtn;
    }

    this(string name_, bool isArchived_) {
        setSize(Vec2f(630f, 48f));

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.left, UIAlignY.center);
            hbox.setSpacing(8f);
            addUI(hbox);

            hbox.addUI(new Label("Dossier:", Atelier.theme.font));

            _nameField = new TextField;
            _nameField.setWidth(150f);
            _nameField.value = name_;
            _nameField.addEventListener("value", &_onNameChange);
            hbox.addUI(_nameField);

            _errorLabel = new Label("", Atelier.theme.font);
            _errorLabel.textColor = Atelier.theme.danger;
            _errorLabel.isVisible = false;
            hbox.addUI(_errorLabel);
        }

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.right, UIAlignY.center);
            hbox.setSpacing(16f);
            addUI(hbox);

            hbox.addUI(new Label("Archiver:", Atelier.theme.font));

            _archivedCheckbox = new Checkbox(isArchived_);
            hbox.addUI(_archivedCheckbox);

            _removeBtn = new DangerButton("Retirer");
            _removeBtn.addEventListener("click", &removeUI);
            hbox.addUI(_removeBtn);
        }

        _onNameChange();
    }

    private void _onNameChange() {
        if (!_nameField.value.length) {
            _errorLabel.isVisible = true;
            _errorLabel.text = "Dossier vide";
            return;
        }

        string path = buildNormalizedPath(Atelier.etabli.getMediaDir(), _nameField.value);
        if (!exists(path)) {
            _errorLabel.isVisible = true;
            _errorLabel.text = "Dossier inexistant";
            return;
        }

        _errorLabel.isVisible = false;
    }
}
