module atelier.ui.select.button;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.button;
import atelier.ui.core;
import atelier.ui.select.list;

final class SelectButton : Button!RoundedRectangle {
    private {
        RoundedRectangle _background;
        SelectList _list;
        bool _isDisplayed;
        string[] _items;
        uint _ivalue;
        Label _label;
        Color _buttonColor;
        UIAlignX _listAlignX = UIAlignX.left;
        UIAlignY _listAlignY = UIAlignY.top;
    }

    @property {
        string value() const {
            if (!_items.length)
                return "";

            return _items[_ivalue];
        }

        string value(string value_) {
            if (!_items.length) {
                _ivalue = 0;
                return "";
            }

            if (_items[_ivalue] == value_)
                return _items[_ivalue];

            for (uint i; i < _items.length; ++i) {
                if (_items[i] == value_) {
                    _ivalue = i;
                    _label.text = _items[_ivalue];
                }
            }

            return _items[_ivalue];
        }

        uint ivalue() const {
            return _ivalue;
        }

        uint ivalue(uint ivalue_) {
            if (_ivalue == ivalue_ || ivalue_ > _items.length)
                return _ivalue;

            _ivalue = ivalue_;
            _label.text = _items[_ivalue];

            return _ivalue;
        }
    }

    this(string[] items, string defaultItem, bool isAccent = false) {
        _items = items.dup;
        _buttonColor = isAccent ? Atelier.theme.accent : Atelier.theme.neutral;

        _label = new Label("", Atelier.theme.font);
        _label.setAlign(UIAlignX.center, UIAlignY.center);
        _label.textColor = Atelier.theme.onAccent;
        addUI(_label);

        Vec2f size = Vec2f.zero;
        _list = new SelectList(this);
        foreach (item; _items) {
            _list.add(item);
            _label.text = item;
            size = size.max(_label.getSize());
        }

        setSize(size + Vec2f(24f, 8f));
        _label.text = value(defaultItem);

        setFxColor(_buttonColor);

        _background = RoundedRectangle.fill(getSize(), Atelier.theme.corner);
        _background.color = _buttonColor;
        _background.anchor = Vec2f.zero;
        addImage(_background);

        addEventListener("mouseenter", {
            Color rgb = _buttonColor;
            HSLColor hsl = HSLColor.fromColor(rgb);
            hsl.l = hsl.l * .8f;
            _background.color = hsl.toColor();
        });
        addEventListener("mouseleave", { _background.color = _buttonColor; });
        addEventListener("click", &_onClick);
        addEventListener("size", { _background.size = getSize(); });
    }

    void setListAlign(UIAlignX alignX, UIAlignY alignY) {
        _listAlignX = alignX;
        _listAlignY = alignY;
    }

    UIAlignX getListAlignX() const {
        return _listAlignX;
    }

    UIAlignY getListAlignY() const {
        return _listAlignY;
    }

    void setItems(string[] items) {
        if (_list) {
            _list.removeUI();
        }

        _items = items.dup;

        Vec2f size = getSize();
        _list = new SelectList(this);
        foreach (item; _items) {
            _list.add(item);
            _label.text = item;
            size = size.max(_label.getSize() + Vec2f(24f, 8f));
        }
        _label.text = _items.length > 0 ? _items[_ivalue] : "";

        setSize(size);
    }

    private void _onClick() {
        if (_isDisplayed) {
            removeMenu();
        }
        else {
            displayMenu();
        }
    }

    package void removeMenu() {
        _list.startRemove();
    }

    package void displayMenu() {
        _list.runState("visible");
        UIManager manager = getManager();
        manager.pushModalUI(_list);
    }
}
