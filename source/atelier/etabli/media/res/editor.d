module atelier.etabli.media.res.editor;

import std.string;

import farfadet;
import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.render;
import atelier.etabli.ui;
import atelier.etabli.media.base;
import atelier.etabli.media.res.entity;
import atelier.etabli.media.res.animation;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.grid;
import atelier.etabli.media.res.instrument;
import atelier.etabli.media.res.invalid;
import atelier.etabli.media.res.item;
import atelier.etabli.media.res.multidiranimation;
import atelier.etabli.media.res.music;
import atelier.etabli.media.res.ninepatch;
import atelier.etabli.media.res.particle;
import atelier.etabli.media.res.scene;
import atelier.etabli.media.res.shadedtexture;
import atelier.etabli.media.res.shadow;
import atelier.etabli.media.res.sound;
import atelier.etabli.media.res.sprite;
import atelier.etabli.media.res.terrain;
import atelier.etabli.media.res.texture;
import atelier.etabli.media.res.tilemap;
import atelier.etabli.media.res.tileset;
import atelier.etabli.media.res.truetype;

final class ResourceEditor : ContentEditor {
    private {
        ResourceList _list;
        ResourceBaseEditor[] _editors;
        ResourceBaseEditor _currentEditor;

        alias CreateResourceEditorFunc = ResourceBaseEditor function(ResourceEditor, string, Farfadet, Vec2f);
        static CreateResourceEditorFunc[string] _createResourceEditorFuncs;
    }

    static add(string type, CreateResourceEditorFunc func) {
        _createResourceEditorFuncs[type] = func;
    }

    static ResourceBaseEditor create(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        Atelier.etabli.reloadResources();

        auto p = ffd.name in _createResourceEditorFuncs;
        if (p !is null) {
            return (*p)(editor, path_, ffd, size);
        }

        return new InvalidResourceEditor(editor, path_, ffd, size);
    }

    static string[] getResourceTypes() {
        return _createResourceEditorFuncs.keys;
    }

    this(string path_, Vec2f windowSize) {
        super(path_, windowSize);

        _list = new ResourceList(this);

        addEventListener("register", {
            if (_currentEditor)
                addUI(_currentEditor);
        });
        addEventListener("unregister", {
            if (_currentEditor)
                _currentEditor.removeUI();
        });

        _reloadList();
        {
            ResourceItem[] elements = cast(ResourceItem[]) _list._list.getList();
            if (elements.length > 0) {
                _list.select(elements[0]);
            }
        }
    }

    private void _reloadList() {
        onClose();
        Farfadet ffd = Farfadet.fromFile(path);
        _list.setList(ffd);
    }

    protected void select(Farfadet ffd) {
        if (_currentEditor) {
            _currentEditor.onClose();
            _currentEditor.removeUI();
            _currentEditor = null;
        }

        if (!ffd) {
            dispatchEvent("panel", false);
            return;
        }

        string type = ffd.name;
        string rid;
        if (ffd.getCount() > 0) {
            rid = ffd.get!string(0);
        }

        foreach (editor; _editors) {
            if (editor.type == type && editor.rid == rid) {
                _currentEditor = editor;
                break;
            }
        }
        if (!_currentEditor) {
            _currentEditor = ResourceEditor.create(this, path(), ffd,
                Vec2f(getWidth() - _list.getWidth(), getHeight()));
            _currentEditor.setAlign(UIAlignX.left, UIAlignY.top);
            _editors ~= _currentEditor;
        }

        addUI(_currentEditor);
        dispatchEvent("panel", false);
    }

    override void save() {
        Farfadet ffd = new Farfadet;
        _list.save(ffd, _currentEditor);

        try {
            ffd.save(path());
        }
        catch (Exception e) {
            Atelier.log("Échec de la sauvegarde: ", e.msg);
        }
    }

    override UIElement getPanel() {
        return _list;
    }

    override UIElement getRightPanel() {
        if (_currentEditor) {
            return _currentEditor.getPanel();
        }
        else {
            return null;
        }
    }

    override void onClose() {
        foreach (ResourceBaseEditor editor; _editors) {
            editor.onClose();
        }
    }

    private ResourceBaseEditor getCurrentEditor() {
        return _currentEditor;
    }

    override void saveView() {
        ResourceItem item = _list.getItem();

        if (item) {
            view.index = _list.getItemIndex(item);
            view.type = item._ffd.name;
            _currentEditor.saveView();
        }
        else {
            view.index = 0;
            view.type = "";
        }
    }

    override void loadView() {
        _list.selectByIndex(view.index);
        ResourceItem item = _list.getItem();

        if (item && view.type == item._ffd.name) {
            _currentEditor.loadView();
        }
    }
}

private {
    struct EditorView {
        size_t index;
        string type;
    }

    EditorView view;
}

private final class ResourceList : UIElement {
    private {
        Farfadet _ffd;
        Container _container;
        TextField _searchField;
        VList _list;
        ResourceItem _selectedItem;
        ResourceEditor _editor;
        NeutralButton _dupBtn;
        DangerButton _remBtn;
        ResourceItem[] _items;
    }

    this(ResourceEditor editor) {
        _editor = editor;

        _container = new Container;
        addUI(_container);

        VBox vbox = new VBox;
        vbox.setPosition(Vec2f(4f, 8f));
        vbox.setAlign(UIAlignX.right, UIAlignY.top);
        vbox.setChildAlign(UIAlignX.right);
        vbox.setSpacing(8f);
        addUI(vbox);

        {
            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            hbox.setMargin(Vec2f(16f, 0f));
            vbox.addUI(hbox);

            hbox.addUI(new Icon("editor:magnify"));
            _searchField = new TextField;
            _searchField.setWidth(200f);
            _searchField.addEventListener("value", &_rebuildList);
            hbox.addUI(_searchField);
        }

        _list = new VList;
        vbox.addUI(_list);

        {
            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            vbox.addUI(hbox);

            AccentButton addBtn = new AccentButton("Ajouter");
            addBtn.addEventListener("click", &_onAddItem);
            hbox.addUI(addBtn);

            _dupBtn = new NeutralButton("Dupliquer");
            _dupBtn.addEventListener("click", &_onDuplicateItem);
            _dupBtn.isEnabled = false;
            hbox.addUI(_dupBtn);

            _remBtn = new DangerButton("Supprimer");
            _remBtn.addEventListener("click", &_onRemoveItem);
            _remBtn.isEnabled = false;
            hbox.addUI(_remBtn);
        }

        addEventListener("size", &_onSize);
        addEventListener("globalkey", &_onKey);
    }

    ResourceItem getItem() {
        return _selectedItem;
    }

    void setList(Farfadet ffd) {
        _ffd = ffd;

        _items.length = 0;
        foreach (node; _ffd.getNodes()) {
            _items ~= new ResourceItem(this, node);
        }
        _rebuildList();
    }

    void save(Farfadet ffd, ResourceBaseEditor editor) {
        foreach (item; _items) {
            if (item == _selectedItem) {
                Farfadet node = editor.save(ffd);
                _selectedItem.setFarfadet(node);
            }
            else {
                ffd.addNode(item.getFarfadet());
            }
        }
    }

    private void _rebuildList() {
        _list.clearList();
        string search = _searchField ? _searchField.value.toLower : "";
        foreach (item; _items) {
            if ((search.length == 0) || item.getName().toLower.indexOf(search) != -1) {
                _list.addList(item);
            }
        }
    }

    private void _onSize() {
        _list.setSize(Vec2f(getWidth(), max(0f, getHeight() - 88f)));
        _container.setSize(getSize());
    }

    private void _onKey() {
        InputEvent.KeyButton event = getManager().input.asKeyButton();

        if (event.isPressed() && hasControlModifier()) {
            switch (event.button) with (InputEvent.KeyButton.Button) {
            case up:
                ResourceItem[] items = cast(ResourceItem[]) _list.getList();
                for (size_t i; i < items.length; ++i) {
                    if (_selectedItem == items[i]) {
                        if (i == 0) {
                            this.select(items[$ - 1]);
                        }
                        else {
                            this.select(items[i - 1]);
                        }
                        break;
                    }
                }
                break;
            case down:
                ResourceItem[] items = cast(ResourceItem[]) _list.getList();
                for (size_t i; i < items.length; ++i) {
                    if (_selectedItem == items[i]) {
                        if (i + 1 >= items.length) {
                            this.select(items[0]);
                        }
                        else {
                            this.select(items[i + 1]);
                        }
                        break;
                    }
                }
                break;
            default:
                break;
            }
        }
    }

    bool hasControlModifier() const {
        return Atelier.input.isPressed(InputEvent.KeyButton.Button.leftControl) ||
            Atelier.input.isPressed(InputEvent.KeyButton.Button.rightControl);
    }

    private void _onAddItem() {
        auto modal = new AddResourceItem;
        modal.addEventListener("apply", {
            string type = modal.getType();
            string subType;
            switch (type) {
            case "grid (bool)":
                type = "grid";
                subType = "bool";
                break;
            case "grid (int)":
                type = "grid";
                subType = "int";
                break;
            case "grid (uint)":
                type = "grid";
                subType = "uint";
                break;
            case "grid (float)":
                type = "grid";
                subType = "float";
                break;
            default:
                break;
            }

            Farfadet ffd = new Farfadet;
            ffd.name = type;
            ffd.add(modal.getName());

            if (subType.length) {
                ffd.addNode("type").add!string(subType);
            }
            ResourceItem item = new ResourceItem(this, ffd);

            if (_selectedItem) {
                size_t index = getItemIndex(_selectedItem);
                if (index >= _items.length) {
                    _items ~= item;
                }
                else {
                    _items = _items[0 .. index + 1] ~ item ~ _items[index + 1 .. $];
                }
            }
            else {
                _items ~= item;
            }

            _rebuildList();
            _editor.setDirty();
            select(item);
        });
        Atelier.ui.pushModalUI(modal);
    }

    private void _onDuplicateItem() {
        if (!_selectedItem)
            return;

        Farfadet ffdInfo = _selectedItem.getFarfadet();
        auto modal = new DuplicateResourceItem(ffdInfo.get!string(0), ffdInfo.name);
        modal.addEventListener("apply", {
            if (_selectedItem) {
                Farfadet ffd = new Farfadet;
                Farfadet node = _editor.getCurrentEditor().save(ffd);
                _selectedItem.setFarfadet(node);
            }
            Farfadet ffdToDup = _selectedItem.getFarfadet();
            size_t index = getItemIndex(_selectedItem);

            Farfadet newFfd = new Farfadet;
            newFfd.name = ffdToDup.name;
            newFfd.add(modal.getName());

            foreach (node; ffdToDup.getNodes()) {
                newFfd.addNode(node);
            }

            ResourceItem item = new ResourceItem(this, newFfd);
            if (index >= _items.length) {
                _items ~= item;
            }
            else {
                _items = _items[0 .. index + 1] ~ item ~ _items[index + 1 .. $];
            }

            _rebuildList();
            _editor.setDirty();
            select(item);
        });
        Atelier.ui.pushModalUI(modal);
    }

    private void _onEditItem(ResourceItem item_) {
        if (!item_)
            return;

        auto modal = new EditResourceItem(item_.getName());
        modal.addEventListener("apply", {
            item_.setName(modal.getName());
            _rebuildList();
            select(item_);
            _editor.setDirty();
        });
        Atelier.ui.pushModalUI(modal);
    }

    private void _onRemoveItem() {
        if (!_selectedItem)
            return;

        auto modal = new RemoveResourceItem(_selectedItem.getName());
        modal.addEventListener("apply", {
            ResourceItem[] items;
            foreach (item; _items) {
                if (item != _selectedItem) {
                    items ~= item;
                }
            }
            _items = items;
            _selectedItem = null;

            _rebuildList();
            _editor.setDirty();
            select(null);
            _editor.select(null);
        });
        Atelier.ui.pushModalUI(modal);
    }

    protected size_t getItemIndex(ResourceItem item_) {
        size_t i;
        foreach (ResourceItem item; _items) {
            if (item_ == item) {
                return i;
            }
            i++;
        }
        return 0;
    }

    protected void selectByIndex(size_t index) {
        if (index >= _items.length) {
            select(null);
        }
        else {
            select(_items[index]);
        }
    }

    protected void select(ResourceItem item_) {
        if (_selectedItem != item_) {
            if (_selectedItem) {
                Farfadet ffd = new Farfadet;
                Farfadet node = _editor.getCurrentEditor().save(ffd);
                _selectedItem.setFarfadet(node);
            }
            _selectedItem = item_;
            _editor.select(_selectedItem ? _selectedItem.getFarfadet() : null);
        }

        size_t i;
        foreach (ResourceItem item; cast(ResourceItem[]) _list.getList()) {
            if (item == item_) {
                _list.moveToElement(i);
            }
            item.updateSelection(item == item_);
            i++;
        }

        _dupBtn.isEnabled = _selectedItem !is null;
        _remBtn.isEnabled = _selectedItem !is null;
    }

    private void moveUp(ResourceItem item_) {
        for (size_t i = 1; i < _items.length; ++i) {
            if (_items[i] == item_) {
                _items[i] = _items[i - 1];
                _items[i - 1] = item_;
                break;
            }
        }
        _rebuildList();

        foreach (ResourceItem item; cast(ResourceItem[]) _list.getList()) {
            if (item == item_) {
                select(item);
            }
        }
        _editor.setDirty();
    }

    private void moveDown(ResourceItem item_) {
        for (size_t i = 0; (i + 1) < _items.length; ++i) {
            if (_items[i] == item_) {
                _items[i] = _items[i + 1];
                _items[i + 1] = item_;
                break;
            }
        }
        _rebuildList();

        foreach (ResourceItem item; cast(ResourceItem[]) _list.getList()) {
            if (item == item_) {
                select(item);
            }
        }
        _editor.setDirty();
    }
}

private final class ResourceItem : UIElement {
    private {
        Farfadet _ffd;
        ResourceList _rlist;
        Rectangle _rect;
        Label _label;
        Icon _icon;
        bool _isSelected;
        string _name;
        HBox _hbox;
        IconButton _editBtn, _upBtn, _downBtn;
    }

    this(ResourceList rlist, Farfadet ffd) {
        _rlist = rlist;
        _ffd = ffd;
        setSize(Vec2f(241f, 32f));

        if (ffd.getCount() > 0)
            _name = ffd.get!string(0);

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.foreground;
        _rect.isVisible = false;
        addImage(_rect);

        _icon = new Icon("editor:ffd-" ~ ffd.name);
        _icon.setAlign(UIAlignX.left, UIAlignY.center);
        _icon.setPosition(Vec2f(32f, 0f));
        addUI(_icon);

        _label = new Label(_name, Atelier.theme.font);
        _label.setAlign(UIAlignX.left, UIAlignY.center);
        _label.setPosition(Vec2f(64f, 0f));
        addUI(_label);

        {
            _hbox = new HBox;
            _hbox.setAlign(UIAlignX.right, UIAlignY.center);
            _hbox.setSpacing(2f);
            addUI(_hbox);

            _editBtn = new IconButton("editor:gear");
            _editBtn.addEventListener("click", { _rlist._onEditItem(this); });
            _hbox.addUI(_editBtn);

            _upBtn = new IconButton("editor:arrow-small-up");
            _upBtn.addEventListener("click", { _rlist.moveUp(this); });
            _hbox.addUI(_upBtn);

            _downBtn = new IconButton("editor:arrow-small-down");
            _downBtn.addEventListener("click", { _rlist.moveDown(this); });
            _hbox.addUI(_downBtn);

            _hbox.isVisible = false;
            _hbox.isEnabled = false;
        }

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
        addEventListener("click", &_onClick);
    }

    private void _onMouseEnter() {
        if (_isSelected) {
            _rect.color = Atelier.theme.accent;
            _label.textColor = Atelier.theme.onAccent;
        }
        else {
            _rect.color = Atelier.theme.foreground;
            _label.textColor = Atelier.theme.onNeutral;
        }
        _rect.isVisible = true;
        _hbox.isVisible = true;
        _hbox.isEnabled = true;
    }

    private void _onMouseLeave() {
        if (_isSelected) {
            _rect.color = Atelier.theme.accent;
            _label.textColor = Atelier.theme.onAccent;
        }
        else {
            _rect.color = Atelier.theme.foreground;
            _label.textColor = Atelier.theme.onNeutral;
        }
        _rect.isVisible = _isSelected;
        _hbox.isVisible = false;
        _hbox.isEnabled = false;
    }

    private void _onClick() {
        _rlist.select(this);
    }

    protected void updateSelection(bool select_) {
        if (_isSelected == select_)
            return;

        _isSelected = select_;

        if (isHovered) {
            _onMouseEnter();
        }
        else {
            _onMouseLeave();
        }
    }

    string getName() {
        return _name;
    }

    void setName(string name_) {
        _name = name_;
        _ffd.clear();
        _ffd.add(_name);
        _label.text = _name;
    }

    Farfadet getFarfadet() {
        return _ffd;
    }

    void setFarfadet(Farfadet ffd) {
        _ffd = ffd;
        _ffd.clear();
        _ffd.add(_name);
        _icon.setIcon("editor:ffd-" ~ _ffd.name);
    }
}
