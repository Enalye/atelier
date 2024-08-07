/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.navigation.tabgroup;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.button;
import atelier.ui.core;
import atelier.ui.navigation.list;

final class TabGroup : UIElement {
    private {
        string _value;
    }

    @property {
        string value() {
            return _value;
        }
    }

    this() {
        setHeight(32f);
        setSizeLock(false, true);

        addEventListener("size", &_onSize);
    }

    private void _onSize() {
        float count = getChildren().length;
        float childWidth = 0f;
        if (count > 0) {
            childWidth = getWidth() / count;
        }
        float posX = 0f;
        foreach (child; getChildren()) {
            child.setWidth(childWidth);
            child.setPosition(Vec2f(posX, 0f));
            posX += childWidth;
        }

        import std.stdio;

        writeln("onSize: ", getWidth(), ", ", count, ", ", childWidth);
    }

    bool hasTab(string id) {
        Tab[] tabs = cast(Tab[]) getChildren().array;

        foreach (Tab tab; tabs) {
            if (tab._id == id && tab.isAlive())
                return true;
        }
        return false;
    }

    void addTab(string name, string id, string icon = "") {
        Tab tab = new Tab(this, name, id, icon);
        addUI(tab);
        _onSize();
        select(tab);
    }

    void select(string id) {
        Tab[] tabs = cast(Tab[]) getChildren().array;

        bool hasValue;
        foreach (Tab tab; tabs) {
            if (tab._id == id) {
                hasValue = true;
            }
            tab.updateValue(tab._id == id);
        }

        if (!tabs.length) {
            if (_value != "") {
                _value = "";
                dispatchEvent("value", false);
                return;
            }
        }

        if (!hasValue) {
            tabs[0].updateValue(true);
            _value = tabs[0]._id;
        }

        if (_value != id) {
            _value = id;
            dispatchEvent("value", false);
        }
    }

    private void select(Tab tab_) {
        Tab[] tabs = cast(Tab[]) getChildren().array;

        foreach (Tab tab; tabs) {
            tab.updateValue(tab_ == tab);
        }

        if (_value != tab_._id) {
            _value = tab_._id;
            dispatchEvent("value", false);
        }
    }

    private void unselect(Tab tab_) {
        Tab[] tabs = cast(Tab[]) getChildren().array;

        for (int i; i < (cast(int) tabs.length); ++i) {
            if (tab_ == tabs[i]) {
                if (i > 0) {
                    tabs[i - 1].updateValue(true);
                    _value = tabs[i - 1]._id;
                }
                else if (i + 1 < tabs.length) {
                    tabs[i + 1].updateValue(true);
                    _value = tabs[i + 1]._id;
                }
                break;
            }
        }

        if (tabs.length <= 1)
            _value = "";

        dispatchEvent("value", false);
    }
}

private final class Tab : UIElement {
    private {
        TabGroup _group;
        Rectangle _rect;
        Label _nameLabel;
        string _id;
        Icon _icon;
        bool _isSelected;
    }

    this(TabGroup group, string name, string id, string icon) {
        _group = group;
        _id = id;
        setAlign(UIAlignX.left, UIAlignY.top);

        if (icon.length) {
            _icon = new Icon(icon);
            _icon.setAlign(UIAlignX.left, UIAlignY.center);
            _icon.setPosition(Vec2f(8f, 0f));
            addUI(_icon);
        }
        _nameLabel = new Label(name, Atelier.theme.font);
        _nameLabel.setAlign(UIAlignX.center, UIAlignY.center);
        addUI(_nameLabel);

        setHeight(32f);

        /*if (_icon) {
            setSize(Vec2f(_nameLabel.getWidth() + _icon.getWidth() + 32f, 32f));
        }
        else {
            setSize(Vec2f(_nameLabel.getWidth() + 16f, 32f));
        }*/

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.container;
        addImage(_rect);

        addEventListener("click", &_onClick);
        addEventListener("size", { _rect.size = getSize(); });
    }

    private void _onClick() {
        if (_isSelected)
            return;

        _group.select(this);
    }

    private void updateValue(bool value) {
        _isSelected = value;
        _rect.color = _isSelected ? Atelier.theme.foreground : Atelier.theme.container;
    }
}
