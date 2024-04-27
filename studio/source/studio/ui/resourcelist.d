/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.resourcelist;

import std.algorithm.searching;
import std.algorithm.mutation;
import std.array;
import std.file;
import std.path;
import std.string;
import std.typecons : No;
import atelier;
import studio.project;
import studio.ui.editor;

final class ResourceList : Surface {
    private {
        SelectButton _mediaSelect;
        string _currentMedia;
        VList _list;
        string[] _unfoldedFolders;
        TextField _searchField;
    }

    this() {
        setAlign(UIAlignX.left, UIAlignY.bottom);
        setSize(Vec2f(250f, Atelier.window.height - 35f));

        addEventListener("windowSize", {
            setSize(Vec2f(250f, Atelier.window.height - 35f));
            _list.setHeight(max(0f, getHeight() - 102f));
        });

        reload();
    }

    void updateRessourceFolders() {
        reload();
    }

    void reload() {
        clearUI();
        _unfoldedFolders.length = 0;

        if (!Project.isOpen)
            return;

        VBox vbox = new VBox;
        vbox.setPosition(Vec2f(0f, 16f));
        vbox.setSpacing(16f);
        vbox.setAlign(UIAlignX.left, UIAlignY.top);
        vbox.setChildAlign(UIAlignX.left);
        addUI(vbox);

        string[] folders;
        foreach (name, isArchived; Project.getMedias()) {
            folders ~= name;
        }

        if (folders.length) {
            {
                HBox hbox = new HBox;
                hbox.setMargin(Vec2f(16f, 0f));
                hbox.setSpacing(4f);
                vbox.addUI(hbox);

                hbox.addUI(new Label("Dossier:", Atelier.theme.font));

                _mediaSelect = new SelectButton(folders, _currentMedia);
                _mediaSelect.addEventListener("value", &rebuildList);
                hbox.addUI(_mediaSelect);

                _currentMedia = _mediaSelect.value;
            }
            {
                HBox hbox = new HBox;
                hbox.setSpacing(4f);
                hbox.setMargin(Vec2f(16f, 0f));
                vbox.addUI(hbox);

                hbox.addUI(new Icon("editor:magnify"));
                _searchField = new TextField;
                _searchField.setWidth(200f);
                _searchField.addEventListener("value", &rebuildList);
                hbox.addUI(_searchField);
            }
        }

        _list = new VList;
        _list.setSize(Vec2f(getWidth(), max(0f, getHeight() - 102f)));
        vbox.addUI(_list);

        rebuildList();
    }

    void rebuildList() {
        _list.clearList();
        if (!_mediaSelect)
            return;
        _currentMedia = _mediaSelect.value;

        string search = _searchField ? _searchField.value : "";
        string mediaPath = buildNormalizedPath(Project.getMediaDir(), _currentMedia);

        if (search.length) {
            if (exists(mediaPath)) {
                foreach (entry; dirEntries(mediaPath, SpanMode.depth)) {
                    if (entry.isDir() || entry.indexOf(search, No.caseSentitive) == -1)
                        continue;

                    _list.addList(new FileItem(this, entry.name, 0));
                }
                return;
            }
        }
        foreach (elt; _buildFolder(mediaPath, 0)) {
            _list.addList(elt);
        }

        string[] nlist;
        foreach (folder; _unfoldedFolders) {
            if (exists(folder)) {
                nlist ~= folder;
            }
        }
        _unfoldedFolders = nlist;
    }

    Item[] _buildFolder(string path, uint depth) {
        Item[] result;

        if (exists(path)) {
            foreach (entry; dirEntries(path, SpanMode.shallow)) {
                if (entry.isDir()) {
                    bool isUnfolded = _unfoldedFolders.canFind(entry.name);
                    result ~= new FolderItem(this, entry.name, depth, isUnfolded);
                    if (isUnfolded) {
                        result ~= _buildFolder(entry.name, depth + 1);
                    }
                }
                else {
                    result ~= new FileItem(this, entry.name, depth);
                }
            }
        }
        return result;
    }

    void unfold(string path) {
        float position = _list.getContentPosition();
        if (!_unfoldedFolders.canFind(path)) {
            _unfoldedFolders ~= path;
        }
        Item[] items = cast(Item[]) _list.getList();
        for (size_t i; i < items.length; ++i) {
            if (items[i].getPath() == path) {
                uint depth = items[i]._depth;
                if (i + 1 < items.length) {
                    items = items[0 .. i + 1] ~ _buildFolder(path, depth + 1) ~ items[i + 1 .. $];
                }
                else {
                    items = items[0 .. i + 1] ~ _buildFolder(path, depth + 1);
                }
                break;
            }
        }
        _list.clearList();
        foreach (Item item; items) {
            _list.addList(item);
        }
        _list.setContentPosition(position);
    }

    void fold(string path) {
        float position = _list.getContentPosition();
        _unfoldedFolders.remove!(a => a == path)();
        Item[] items = cast(Item[]) _list.getList();
        _list.clearList();
        for (size_t i; i < items.length; ++i) {
            if (items[i].getPath() != path && startsWith(items[i].getPath(), path)) {
                continue;
            }
            _list.addList(items[i]);
        }
        _list.setContentPosition(position);
    }
}

private Color[] _indentColor = [
    Color.fromHex(0x868be4), Color.fromHex(0xa484c9), Color.fromHex(0xca8dbc),
    Color.fromHex(0xee93b4), Color.fromHex(0xff9eb5),
];

private enum _indentOffset = 4f;

private abstract class Item : UIElement {
    private {
        Rectangle _rect;
        string _name, _path;
        uint _depth;
    }

    this() {
        addEventListener("draw", &_onDraw);
    }

    string getPath() const {
        return _path;
    }

    private void _onDraw() {
        for (uint i; i < _depth; ++i) {
            Atelier.renderer.drawRect(Vec2f(i * _indentOffset, 0f),
                Vec2f(_indentOffset, 32f), _indentColor[i % _indentColor.length], .5f, true);
        }
    }
}

private final class FolderItem : Item {
    private {
        ResourceList _rlist;
        Sprite _arrowSprite, _folderSprite;
        bool _isFolded;
    }

    this(ResourceList rlist, string path_, uint depth_, bool isUnfolded) {
        _rlist = rlist;
        _path = path_;
        _name = baseName(_path);
        _depth = depth_;
        _isFolded = !isUnfolded;

        setSize(Vec2f(250f, 32f));

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.foreground;
        _rect.isVisible = false;
        addImage(_rect);

        if (_isFolded) {
            _arrowSprite = Atelier.res.get!Sprite("editor:arrow-right");
            _folderSprite = Atelier.res.get!Sprite("editor:folder-close");
        }
        else {
            _arrowSprite = Atelier.res.get!Sprite("editor:arrow-down");
            _folderSprite = Atelier.res.get!Sprite("editor:folder-open");
        }
        _arrowSprite.anchor = Vec2f(0f, .5f);
        _folderSprite.anchor = Vec2f(0f, .5f);
        _arrowSprite.position = Vec2f(8f + _depth * _indentOffset, getCenter().y);
        _folderSprite.position = Vec2f(32f + _depth * _indentOffset, getCenter().y);

        addImage(_arrowSprite);
        addImage(_folderSprite);

        Label label = new Label(_name, Atelier.theme.font);
        label.setAlign(UIAlignX.left, UIAlignY.center);
        label.setPosition(Vec2f(64f + _depth * _indentOffset, 0f));
        addUI(label);

        addEventListener("mouseenter", { _rect.isVisible = true; });

        addEventListener("mouseleave", { _rect.isVisible = false; });

        addEventListener("click", &toggle);
    }

    void toggle() {
        _isFolded = !_isFolded;

        _arrowSprite.remove();
        _folderSprite.remove();

        if (_isFolded) {
            _arrowSprite = Atelier.res.get!Sprite("editor:arrow-right");
            _folderSprite = Atelier.res.get!Sprite("editor:folder-close");
            _rlist.fold(_path);
        }
        else {
            _arrowSprite = Atelier.res.get!Sprite("editor:arrow-down");
            _folderSprite = Atelier.res.get!Sprite("editor:folder-open");
            _rlist.unfold(_path);
        }

        _arrowSprite.anchor = Vec2f(0f, .5f);
        _folderSprite.anchor = Vec2f(0f, .5f);
        _arrowSprite.position = Vec2f(8f + _depth * _indentOffset, getCenter().y);
        _folderSprite.position = Vec2f(32f + _depth * _indentOffset, getCenter().y);

        addImage(_arrowSprite);
        addImage(_folderSprite);
    }
}

private final class FileItem : Item {
    this(ResourceList rlist, string path_, uint depth_) {
        _path = path_;
        _name = baseName(_path);
        _depth = depth_;

        setSize(Vec2f(250f, 32f));

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
        icon.setPosition(Vec2f(32f + _depth * _indentOffset, 0f));
        addUI(icon);

        Label label = new Label(_name, Atelier.theme.font);
        label.setAlign(UIAlignX.left, UIAlignY.center);
        label.setPosition(Vec2f(64f + _depth * _indentOffset, 0f));
        addUI(label);

        addEventListener("mouseenter", { _rect.isVisible = true; });
        addEventListener("mouseleave", { _rect.isVisible = false; });
        addEventListener("click", &_onClick);
    }

    private void _onClick() {
        Editor.editFile(_path);
    }
}
