/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editor.res.editor;

import atelier;
import farfadet;
import studio.ui;
import studio.editor.base;
import studio.editor.res.base;
import studio.editor.res.item;

final class ResourceEditor : ContentEditor {
    private {
        ResourceList _list;
        ResourceBaseEditor[] _editors;
        ResourceBaseEditor _currentEditor;
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
            _currentEditor = ResourceBaseEditor.create(this, path(), ffd,
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
        ffd.save(path());
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
}

private final class ResourceList : UIElement {
    private {
        Farfadet _ffd;
        Container _container;
        TextField _searchField;
        VList _list;
        ResourceItem _selectedItem;
        ResourceEditor _editor;
    }

    this(ResourceEditor editor) {
        _editor = editor;
        /*setAlign(UIAlignX.right, UIAlignY.top);
        setSize(Vec2f(250f, 0f));
        setSizeLock(true, false);*/

        _container = new Container;
        addUI(_container);

        VBox vbox = new VBox;
        vbox.setPosition(Vec2f(4f, 32f));
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

            NeutralButton editBtn = new NeutralButton("Modifier");
            editBtn.addEventListener("click", &_onEditItem);
            hbox.addUI(editBtn);

            DangerButton remBtn = new DangerButton("Supprimer");
            remBtn.addEventListener("click", &_onRemoveItem);
            hbox.addUI(remBtn);
        }

        addEventListener("size", &_onSize);
        addEventListener("globalkey", &_onKey);
    }

    void setList(Farfadet ffd) {
        _ffd = ffd;
        _rebuildList();
    }

    void save(Farfadet ffd, ResourceBaseEditor editor) {
        foreach (item; cast(ResourceItem[]) _list.getList()) {
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
        foreach (node; _ffd.getNodes()) {
            _list.addList(new ResourceItem(this, node));
        }
    }

    private void _onSize() {
        _list.setSize(Vec2f(getWidth(), max(0f, getHeight() - 112f)));
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
            Farfadet ffd = _ffd.addNode(modal.getType()).add(modal.getName());
            _rebuildList();
            _editor.setDirty();

            foreach (item; cast(ResourceItem[]) _list.getList()) {
                if (item._ffd == ffd) {
                    select(item);
                    break;
                }
            }
        });
        Atelier.ui.pushModalUI(modal);
    }

    private void _onEditItem() {
        if (!_selectedItem)
            return;

        Farfadet ffd = _selectedItem._ffd;
        auto modal = new EditResourceItem(ffd.get!string(0));
        modal.addEventListener("apply", {
            ffd.clear();
            ffd.add(modal.getName());
            _rebuildList();
            _editor.setDirty();
        });
        Atelier.ui.pushModalUI(modal);
    }

    private void _onRemoveItem() {
        if (!_selectedItem)
            return;

        Farfadet ffd = _selectedItem._ffd;
        auto modal = new RemoveResourceItem(ffd.get!string(0));
        modal.addEventListener("apply", {
            _ffd.removeNode(ffd);
            _rebuildList();
            _editor.setDirty();
            select(null);
        });
        Atelier.ui.pushModalUI(modal);
    }

    protected void select(ResourceItem item_) {
        if (_selectedItem != item_) {
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
    }

    private void moveUp(ResourceItem item_) {
        Farfadet[] nodes = _ffd.getNodes();
        _ffd.clearNodes(false);
        for (size_t i = 1; i < nodes.length; ++i) {
            if (nodes[i] == item_._ffd) {
                nodes[i] = nodes[i - 1];
                nodes[i - 1] = item_._ffd;
                break;
            }
        }
        _ffd.setNodes(nodes);
        _rebuildList();

        foreach (ResourceItem item; cast(ResourceItem[]) _list.getList()) {
            if (item._ffd == item_._ffd) {
                select(item);
            }
        }
    }

    private void moveDown(ResourceItem item_) {
        Farfadet[] nodes = _ffd.getNodes();
        _ffd.clearNodes(false);
        for (size_t i = 0; (i + 1) < nodes.length; ++i) {
            if (nodes[i] == item_._ffd) {
                nodes[i] = nodes[i + 1];
                nodes[i + 1] = item_._ffd;
                break;
            }
        }
        _ffd.setNodes(nodes);
        _rebuildList();

        foreach (ResourceItem item; cast(ResourceItem[]) _list.getList()) {
            if (item._ffd == item_._ffd) {
                select(item);
            }
        }
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
        IconButton _upBtn, _downBtn;
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

    Farfadet getFarfadet() {
        return _ffd;
    }

    void setFarfadet(Farfadet ffd) {
        _ffd = ffd;
        _name = ffd.get!string(0);
        _label.text = _name;
        _icon.setIcon("editor:ffd-" ~ _ffd.name);
    }
}
