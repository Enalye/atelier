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
        string _value, _lastRemovedTab;
    }

    @property {
        string value() {
            return _value;
        }

        string lastRemovedTab() {
            return _lastRemovedTab;
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

    bool hasTab(string id) {
        Tab[] tabs = cast(Tab[]) _list.getList();

        foreach (Tab tab; tabs) {
            if (tab._id == id && tab.isAlive())
                return true;
        }
        return false;
    }

    void addTab(string name, string id, string icon = "") {
        Tab tab = new Tab(this, name, id, icon);
        _list.addList(tab);
        _selectTab(tab, false);
    }

    void clearTabs() {
        _list.clearList();
        dispatchEvent("close", false);
    }

    void setDirty(string id, bool isDirty) {
        Tab[] tabs = cast(Tab[]) _list.getList();
        foreach (Tab tab; tabs) {
            if (tab._id == id) {
                tab.setDirty(isDirty);
            }
        }
    }

    void selectTab(string id) {
        _selectTab(id, false);
    }

    private void _selectTab(string id, bool dispatch) {
        Tab[] tabs = cast(Tab[]) _list.getList();

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
                if (dispatch) {
                    dispatchEvent("value", false);
                }
                return;
            }
        }

        if (!hasValue) {
            tabs[0].updateValue(true);
            _value = tabs[0]._id;
        }

        if (_value != id) {
            _value = id;
            if (dispatch) {
                dispatchEvent("value", false);
            }
        }
    }

    private void _selectTab(Tab tab_, bool dispatch) {
        Tab[] tabs = cast(Tab[]) _list.getList();

        foreach (Tab tab; tabs) {
            tab.updateValue(tab_ == tab);
        }

        if (_value != tab_._id) {
            _value = tab_._id;
            if (dispatch) {
                dispatchEvent("value", false);
            }
        }
    }

    private void unselect(Tab tab_) {
        Tab[] tabs = cast(Tab[]) _list.getList();

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
        TabBar _bar;
        Rectangle _rect;
        Label _nameLabel;
        string _id;
        Icon _icon;
        IconButton _removeBtn;
        bool _isSelected;
        Circle _dirtyCircle;
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
        _nameLabel.setAlign(UIAlignX.left, UIAlignY.center);
        _nameLabel.setPosition(Vec2f(32f, 0f));
        addUI(_nameLabel);

        _removeBtn = new IconButton("editor:exit");
        _removeBtn.setAlign(UIAlignX.right, UIAlignY.center);
        _removeBtn.setPosition(Vec2f(4f, 0f));
        _removeBtn.addEventListener("click", &_onRemove);
        _removeBtn.isVisible = false;
        addUI(_removeBtn);

        _updateSize();

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.container;
        addImage(_rect);

        addEventListener("mouseenterinside", { _removeBtn.isVisible = true; });

        addEventListener("mouseleaveinside", { _removeBtn.isVisible = false; });

        addEventListener("click", &_onClick);
    }

    private void _updateSize() {
        if (_icon) {
            setSize(Vec2f(_nameLabel.getWidth() + _icon.getWidth() + _removeBtn.getWidth() + 32f + (_dirtyCircle ?
                    16f : 0f), 32f));
        }
        else {
            setSize(Vec2f(_nameLabel.getWidth() + _removeBtn.getWidth() + 16f + (_dirtyCircle ?
                    16f : 0f), 32f));
        }
        if (_rect) {
            _rect.size = getSize();
        }
    }

    void setDirty(bool isDirty) {
        if (isDirty && !_dirtyCircle) {
            _dirtyCircle = Circle.fill(getHeight() / 3f);
            _dirtyCircle.color = Atelier.theme.accent;
            _dirtyCircle.anchor = Vec2f(0f, .5f);
            _dirtyCircle.position = Vec2f(getWidth() - 24f, getHeight() / 2f);
            addImage(_dirtyCircle);
            _updateSize();
        }
        else if (!isDirty && _dirtyCircle) {
            _dirtyCircle.remove();
            _dirtyCircle = null;
            _updateSize();
        }
    }

    private void _onClick() {
        if (_isSelected)
            return;

        _bar._selectTab(this, true);
    }

    private void updateValue(bool value) {
        _isSelected = value;
        _rect.color = _isSelected ? Atelier.theme.foreground : Atelier.theme.container;
    }

    private void _onRemove() {
        if (_isSelected) {
            _bar.unselect(this);
        }
        removeUI();
        _bar._lastRemovedTab = _id;
        _bar.dispatchEvent("close", false);
    }
}
