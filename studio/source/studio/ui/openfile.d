/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.openfile;

import std.algorithm.searching;
import std.algorithm.mutation;
import std.array;
import std.path;
import std.string;
import std.typecons : No;
import std.file;
import std.string;
import atelier;
import studio.project;

final class OpenFile : Modal {
    private {
        TextField _searchField;
        VList _fileList;
        FileItem[] _fileItems;
        size_t _selectedItemIndex;
        string _path;
    }

    this() {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(500f, 500f));

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.center, UIAlignY.center);
        vbox.setChildAlign(UIAlignX.left);
        vbox.setSpacing(4f);
        addUI(vbox);

        {
            Label title = new Label("Ouvrir Fichier", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            vbox.addUI(title);
        }

        {
            IconButton exitBtn = new IconButton("editor:exit");
            exitBtn.setAlign(UIAlignX.right, UIAlignY.top);
            exitBtn.setPosition(Vec2f(4f, 4f));
            exitBtn.addEventListener("click", &remove);
            addUI(exitBtn);
        }

        {
            _searchField = new TextField;
            _searchField.setAlign(UIAlignX.left, UIAlignY.top);
            _searchField.setWidth(400f);
            _searchField.addEventListener("value", &_onSearch);
            vbox.addUI(_searchField);

            Atelier.ui.setFocus(_searchField);
        }

        {
            _fileList = new VList;
            _fileList.setSize(Vec2f(492f, 432f));
            vbox.addUI(_fileList);
        }

        _onSearch();

        addEventListener("globalkey", &_onKey);
    }

    private void _onKey() {
        InputEvent.KeyButton event = Atelier.ui.input().asKeyButton();

        if (!event.isPressed())
            return;

        switch (event.button) with (InputEvent.KeyButton.Button) {
        case enter:
        case enter2:
        case numEnter:
            if (_selectedItemIndex < _fileItems.length) {
                validate(_fileItems[_selectedItemIndex].getPath());
            }
            break;
        case escape:
            this.remove();
            break;
        case up:
            if (_selectedItemIndex == 0) {
                _selectedItemIndex = _fileItems.length > 0 ? (cast(ptrdiff_t) _fileItems.length - 1)
                    : 0;
            }
            else {
                _selectedItemIndex--;
            }
            _updateSelectedItem();
            break;
        case down:
            _selectedItemIndex++;
            if (_selectedItemIndex >= _fileItems.length) {
                _selectedItemIndex = 0;
            }
            _updateSelectedItem();
            break;
        default:
            break;
        }
    }

    private void _updateSelectedItem() {
        if (_selectedItemIndex < _fileItems.length) {
            _fileList.moveToElement(_fileItems[_selectedItemIndex].elementIndex);
        }
        for (size_t i; i < _fileItems.length; ++i) {
            _fileItems[i].setSelected(i == _selectedItemIndex);
        }
    }

    private void _onSearch() {
        _fileList.clearList();
        _fileItems.length = 0;
        _selectedItemIndex = 0;

        string[] folders;
        folders ~= Project.getSourceDir();
        foreach (string key; Project.getMedias().keys) {
            folders ~= buildNormalizedPath(Project.getMediaDir(), key);
        }

        string search = _searchField.value;
        size_t elementIndex;

        foreach (folder; folders) {
            if (exists(folder)) {
                bool isInit = true;
                foreach (entry; dirEntries(folder, SpanMode.depth)) {
                    if (entry.isDir())
                        continue;

                    if (entry.baseName.indexOf(search, No.caseSentitive) == -1)
                        continue;

                    if (isInit) {
                        isInit = false;
                        _fileList.addList(new DirItem(folder));
                        elementIndex++;
                    }

                    FileItem item = new FileItem(this, entry.name, folder, search);
                    item.elementIndex = elementIndex;
                    _fileItems ~= item;
                    _fileList.addList(item);
                    elementIndex++;
                }
            }
        }

        _updateSelectedItem();
    }

    string getFilePath() {
        return _path;
    }

    void validate(string path) {
        _path = path;
        dispatchEvent("openFile", false);
    }
}

private final class DirItem : UIElement {
    private {
        string _name, _path;
    }

    this(string name) {
        _name = baseName(name);

        setSize(Vec2f(492f, 32f));

        LabelSeparator sep = new LabelSeparator(_name, Atelier.theme.font);
        sep.setColor(Atelier.theme.neutral);
        sep.setPadding(Vec2f(284f, 0f));
        sep.setSpacing(8f);
        sep.setLineWidth(1f);
        addUI(sep);
    }
}

private final class FileItem : UIElement {
    private {
        OpenFile _openFile;
        Rectangle _rect;
        string _name, _path;
        bool _isSelected;
    }

    protected size_t elementIndex;

    this(OpenFile openFile, string path_, string basePath, string search) {
        _openFile = openFile;
        _path = path_;
        _name = baseName(_path);

        setSize(Vec2f(492f, 24f));

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.foreground;
        _rect.isVisible = false;
        addImage(_rect);

        Icon icon;
        switch (extension(_name)) {
        case ".png":
        case ".bmp":
        case ".jpg":
        case ".jpeg":
        case ".gif":
            icon = new Icon("editor:file-image");
            break;
        case ".ogg":
        case ".wav":
        case ".mp3":
            icon = new Icon("editor:file-audio");
            break;
        case ".ttf":
            icon = new Icon("editor:file-font");
            break;
        case ".gr":
            icon = new Icon("editor:file-grimoire");
            break;
        case ".ffd":
            icon = new Icon("editor:file-farfadet");
            break;
        default:
            icon = new Icon("editor:file");
            break;
        }
        icon.setAlign(UIAlignX.left, UIAlignY.center);
        icon.setPosition(Vec2f(32f, 0f));
        addUI(icon);

        ColoredLabel nameLabel = new ColoredLabel(_name, Atelier.theme.font);
        nameLabel.setAlign(UIAlignX.left, UIAlignY.center);
        nameLabel.setPosition(Vec2f(64f, 0f));
        addUI(nameLabel);

        ptrdiff_t index = -1;
        size_t startSearch = 0;
        if (search.length > 0) {
            for (;;) {
                index = indexOf(_name[startSearch .. $], search, No.caseSentitive);
                if (index < 0)
                    break;

                index += startSearch;

                ColoredLabel.Token token1, token2;
                token1.index = index;
                token1.textColor = Atelier.theme.accent;
                nameLabel.tokens ~= token1;

                token2.index = index + search.length;
                token2.textColor = Atelier.theme.onNeutral;
                nameLabel.tokens ~= token2;

                startSearch = index + search.length;
            }
        }

        {
            string relPath = asRelativePath(dirName(_path), basePath).array;
            if (relPath.length) {
                Label dirLabel = new Label(relPath, Atelier.theme.font);
                dirLabel.setAlign(UIAlignX.right, UIAlignY.center);
                dirLabel.setPosition(Vec2f(64f, 0f));
                dirLabel.textColor = Atelier.theme.neutral;
                addUI(dirLabel);
            }
        }
        addEventListener("mouseenter", {
            if (!_isSelected)
                _rect.isVisible = true;
        });
        addEventListener("mouseleave", {
            if (!_isSelected)
                _rect.isVisible = false;
        });
        addEventListener("click", &_onClick);
    }

    void setSelected(bool isSelected_) {
        _isSelected = isSelected_;

        if (_isSelected) {
            HSLColor hsl = HSLColor.fromColor(Atelier.theme.accent);
            hsl.l = hsl.l * 0.5f;
            _rect.color = hsl.toColor();
            _rect.isVisible = true;
        }
        else {
            _rect.color = Atelier.theme.foreground;
            _rect.isVisible = isHovered();
        }
    }

    string getPath() const {
        return _path;
    }

    private void _onClick() {
        _openFile.validate(_path);
    }
}
