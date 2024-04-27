/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editors.resourceeditor;

import atelier;
import farfadet;
import studio.editors.base;

final class ResourceEditor : ContentEditor {
    private {
        ResourceList _list;
    }

    this(string path_, Vec2f windowSize) {
        super(path_, windowSize);

        _list = new ResourceList;
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
}

private final class ResourceList : UIElement {
    private {
        Farfadet _ffd;
        Container _container;
        TextField _searchField;
        VList _list;
    }

    this() {
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
}

private final class ResourceItem : UIElement {
    private {
        Rectangle _rect;
        string _name;
    }

    this(ResourceList rlist, Farfadet ffd) {
        setSize(Vec2f(250f, 32f));

        _name = ffd.get!string(0);

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.foreground;
        _rect.isVisible = false;
        addImage(_rect);

        Icon icon = new Icon("editor:ffd-" ~ ffd.name);
        icon.setAlign(UIAlignX.left, UIAlignY.center);
        icon.setPosition(Vec2f(32f, 0f));
        addUI(icon);

        Label label = new Label(_name, Atelier.theme.font);
        label.setAlign(UIAlignX.left, UIAlignY.center);
        label.setPosition(Vec2f(64f, 0f));
        addUI(label);

        addEventListener("mouseenter", { _rect.isVisible = true; });
        addEventListener("mouseleave", { _rect.isVisible = false; });
        addEventListener("click", &_onClick);
    }

    private void _onClick() {

    }
}
