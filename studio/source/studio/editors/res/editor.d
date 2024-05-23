/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.res.editor;

import atelier;
import farfadet;
import studio.editors.base;
import studio.editors.res.base;

final class ResourceEditor : ContentEditor {
    private {
        ResourceList _list;
        ResourceBaseEditor _currentEditor;
    }

    this(string path_, Vec2f windowSize) {
        super(path_, windowSize);

        _list = new ResourceList(this);
        _list.setHeight(getHeight());
        addUI(_list);

        addEventListener("size", &_onSize);

        _reloadList();
    }

    private void _onSize() {
        _list.setHeight(getHeight());
    }

    private void _reloadList() {
        Farfadet ffd = Farfadet.fromFile(path);
        _list.setList(ffd);
    }

    protected void select(Farfadet ffd) {
        if (_currentEditor) {
            _currentEditor.remove();
        }

        _currentEditor = ResourceBaseEditor.create(path(), ffd,
            Vec2f(getWidth() - _list.getWidth(), getHeight()));
        _currentEditor.setAlign(UIAlignX.left, UIAlignY.top);
        addUI(_currentEditor);
    }

    void save() {
        Farfadet ffd = new Farfadet;
        _list.save(ffd, _currentEditor);
        ffd.save(path());
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
        setAlign(UIAlignX.right, UIAlignY.top);
        setSize(Vec2f(250f, 0f));
        setSizeLock(true, false);

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
        _list.setSize(Vec2f(getWidth(), 400f));
        vbox.addUI(_list);

        {
            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            hbox.setMargin(Vec2f(16f, 0f));
            vbox.addUI(hbox);

            AccentButton addBtn = new AccentButton("+ Ajouter");
            addBtn.addEventListener("click", &_onAddItem);
            hbox.addUI(addBtn);

            DangerButton remBtn = new DangerButton("Supprimer");
            remBtn.addEventListener("click", &_onRemoveItem);
            hbox.addUI(remBtn);
        }

        addEventListener("size", &_onSize);
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
        _container.setSize(getSize());
    }

    private void _onAddItem() {
    }

    private void _onRemoveItem() {
    }

    protected void select(ResourceItem item_) {
        if (_selectedItem != item_) {
            _selectedItem = item_;
            _editor.select(_selectedItem.getFarfadet());
        }

        foreach (ResourceItem item; cast(ResourceItem[]) _list.getList()) {
            item.updateSelection(item == item_);
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
    }

    this(ResourceList rlist, Farfadet ffd) {
        _rlist = rlist;
        _ffd = ffd;
        setSize(Vec2f(250f, 32f));

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

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
        addEventListener("click", &_onClick);
    }

    private void _onMouseEnter() {
        if (_isSelected) {
            _rect.color = Atelier.theme.accent;
            _label.color = Atelier.theme.onAccent;
        }
        else {
            _rect.color = Atelier.theme.foreground;
            _label.color = Atelier.theme.onNeutral;
        }
        _rect.isVisible = true;
    }

    private void _onMouseLeave() {
        _rect.isVisible = _isSelected;
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
