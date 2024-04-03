/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.navigation.tabbar;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.button;
import atelier.ui.core;
import atelier.ui.navigation.list;

final class TabBar : UIElement {
    private {
        HList _list;
        string _value;
    }

    @property {
        string value() {
            return _value;
        }
    }

    this() {
        _list = new HList(3f);
        _list.setAlign(UIAlignX.left, UIAlignY.top);
        _list.setHeight(35f);
        addUI(_list);

        setSize(_list.getSize());
        setSizeLock(false, true);

        addEventListener("size", &_onSize);
    }

    private void _onSize() {
        _list.setWidth(getWidth());
    }

    void addTab(string name, string id, string icon = "") {
        Tab tab = new Tab(this, name, id, icon);
        _list.addList(tab);
        select(tab);
    }

    private void select(Tab tab_) {
        Tab[] tabs = cast(Tab[]) _list.getList();

        foreach (Tab tab; tabs) {
            tab.updateValue(tab_ == tab);
        }

        _value = tab_._id;
        dispatchEvent("value", false);
    }

    private void unselect(Tab tab_) {
        Tab[] tabs = cast(Tab[]) _list.getList();

        for (int i; i < (cast(int) tabs.length); ++i) {
            if (tab_ == tabs[i]) {
                if (i > 0) {
                    tabs[i - 1].updateValue(true);
                    _value = tabs[i - 1]._id;
                    break;
                }
            }
        }

        dispatchEvent("value", false);
    }
}

private final class Tab : UIElement {
    private {
        TabBar _bar;
        Rectangle _rect;
        Label _nameLabel;
        string _id;
        Icon _icon;
        IconButton _removeBtn;
        bool _isSelected;
    }

    this(TabBar bar, string name, string id, string icon) {
        _bar = bar;
        _id = id;

        if (icon.length) {
            _icon = new Icon(icon);
            _icon.setAlign(UIAlignX.left, UIAlignY.center);
            _icon.setPosition(Vec2f(8f, 0f));
            addUI(_icon);
        }
        _nameLabel = new Label(name, Atelier.theme.font);
        _nameLabel.setAlign(UIAlignX.center, UIAlignY.center);
        addUI(_nameLabel);

        _removeBtn = new IconButton("editor:exit");
        _removeBtn.setAlign(UIAlignX.right, UIAlignY.center);
        _removeBtn.setPosition(Vec2f(4f, 0f));
        _removeBtn.addEventListener("click", &_onRemove);
        _removeBtn.isVisible = false;
        addUI(_removeBtn);

        if (_icon) {
            setSize(Vec2f(_nameLabel.getWidth() + _icon.getWidth() + _removeBtn.getWidth() + 32f,
                    32f));
        }
        else {
            setSize(Vec2f(_nameLabel.getWidth() + _removeBtn.getWidth() + 16f, 32f));
        }

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.container;
        addImage(_rect);

        addEventListener("mouseenterinside", { _removeBtn.isVisible = true; });

        addEventListener("mouseleaveinside", { _removeBtn.isVisible = false; });

        addEventListener("click", &_onClick);
    }

    private void _onClick() {
        if (_isSelected)
            return;

        _bar.select(this);
    }

    private void updateValue(bool value) {
        _isSelected = value;
        _rect.color = _isSelected ? Atelier.theme.foreground : Atelier.theme.container;
    }

    private void _onRemove() {
        if (_isSelected) {
            _bar.unselect(this);
        }
        remove();
    }
}
