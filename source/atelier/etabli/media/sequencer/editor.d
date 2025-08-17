module atelier.etabli.media.sequencer.editor;

import std.string;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.base;
import atelier.etabli.media.sequencer.base;
import atelier.etabli.media.sequencer.item;

final class SequencerEditor : ContentEditor {
    private {
        SequencerList _list;
        SequencerBaseEditor[] _editors;
        SequencerBaseEditor _currentEditor;
    }

    this(string path_, Vec2f windowSize) {
        super(path_, windowSize);

        _list = new SequencerList(this);

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
            SequencerItem[] elements = cast(SequencerItem[]) _list._list.getList();
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
            _currentEditor = SequencerBaseEditor.create(this, path(), ffd,
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
        foreach (SequencerBaseEditor editor; _editors) {
            editor.onClose();
        }
    }

    private SequencerBaseEditor getCurrentEditor() {
        return _currentEditor;
    }

    string[] getPatternList() {
        return _list._patternList;
    }

    Farfadet getPattern(string name) {
        foreach (item; cast(SequencerItem[]) _list._list.getList()) {
            if (item._ffd.name == "pattern" && item.getName() == name) {
                return item._ffd;
            }
        }
        return null;
    }

    void selectPattern(string name) {
        _list.selectPattern(name);
    }
}

private final class SequencerList : UIElement {
    private {
        Farfadet _ffd;
        Container _container;
        TextField _searchField;
        VList _list;
        SequencerItem _selectedItem;
        SequencerEditor _editor;
        NeutralButton _dupBtn;
        DangerButton _remBtn;

        SequencerItem[] _items;
        string[] _patternList;
    }

    this(SequencerEditor editor) {
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

    void setList(Farfadet ffd) {
        _ffd = ffd;

        _items.length = 0;
        foreach (node; _ffd.getNodes()) {
            _items ~= new SequencerItem(this, node);
        }
        _rebuildList();
    }

    void save(Farfadet ffd, SequencerBaseEditor editor) {
        foreach (item; cast(SequencerItem[]) _list.getList()) {
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
        _patternList.length = 0;
        string search = _searchField ? _searchField.value.toLower : "";
        foreach (item; _items) {
            if ((search.length == 0) || item.getName().toLower.indexOf(search) != -1) {
                _list.addList(item);
            }
            if (item._ffd.name == "pattern") {
                _patternList ~= item._name;
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
                SequencerItem[] items = cast(SequencerItem[]) _list.getList();
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
                SequencerItem[] items = cast(SequencerItem[]) _list.getList();
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
        auto modal = new AddSequencerItem;
        modal.addEventListener("apply", {
            Farfadet ffd = new Farfadet;
            ffd.name = modal.getType();
            ffd.add(modal.getName());

            SequencerItem item = new SequencerItem(this, ffd);

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
        auto modal = new DuplicateSequencerItem(ffdInfo.get!string(0), ffdInfo.name);
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

            SequencerItem item = new SequencerItem(this, newFfd);
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

    private void _onEditItem(SequencerItem item_) {
        if (!item_)
            return;

        auto modal = new EditSequencerItem(item_.getName());
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

        auto modal = new RemoveSequencerItem(_selectedItem.getName());
        modal.addEventListener("apply", {
            SequencerItem[] items;
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

    void selectPattern(string name) {
        foreach (SequencerItem item; cast(SequencerItem[]) _list.getList()) {
            if (item._ffd.name == "pattern" && item.getName() == name) {
                select(item);
                return;
            }
        }
    }

    protected size_t getItemIndex(SequencerItem item_) {
        size_t i;
        foreach (SequencerItem item; _items) {
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

    protected void select(SequencerItem item_) {
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
        foreach (SequencerItem item; cast(SequencerItem[]) _list.getList()) {
            if (item == item_) {
                _list.moveToElement(i);
            }
            item.updateSelection(item == item_);
            i++;
        }

        _dupBtn.isEnabled = _selectedItem !is null;
        _remBtn.isEnabled = _selectedItem !is null;
    }

    private void moveUp(SequencerItem item_) {
        for (size_t i = 1; i < _items.length; ++i) {
            if (_items[i] == item_) {
                _items[i] = _items[i - 1];
                _items[i - 1] = item_;
                break;
            }
        }
        _rebuildList();

        foreach (SequencerItem item; cast(SequencerItem[]) _list.getList()) {
            if (item == item_) {
                select(item);
            }
        }
        _editor.setDirty();
    }

    private void moveDown(SequencerItem item_) {
        for (size_t i = 0; (i + 1) < _items.length; ++i) {
            if (_items[i] == item_) {
                _items[i] = _items[i + 1];
                _items[i + 1] = item_;
                break;
            }
        }
        _rebuildList();

        foreach (SequencerItem item; cast(SequencerItem[]) _list.getList()) {
            if (item == item_) {
                select(item);
            }
        }
        _editor.setDirty();
    }
}

private final class SequencerItem : UIElement {
    private {
        Farfadet _ffd;
        SequencerList _rlist;
        Rectangle _rect;
        Label _label;
        Icon _icon;
        bool _isSelected;
        string _name;
        HBox _hbox;
        IconButton _editBtn, _upBtn, _downBtn;
    }

    this(SequencerList rlist, Farfadet ffd) {
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

        _icon = new Icon("editor:seq-" ~ ffd.name);
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
        _icon.setIcon("editor:seq-" ~ _ffd.name);
    }
}
