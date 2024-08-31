/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.ui.select.button;

import std.algorithm.searching : canFind;
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
        string _value;
        Label _label;
        Color _buttonColor;
    }

    @property {
        string value() const {
            return _value;
        }

        string value(string value_) {
            if (_value == value_)
                return _value;

            if (_items.canFind(value_)) {
                _value = value_;
                _label.text = _value;
            }
            return _value;
        }
    }

    this(string[] items, string defaultItem, bool isAccent = false) {
        _items = items;
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

        if (_items.length)
            _value = _items[0];
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

    void setItems(string[] items) {
        if (_list) {
            _list.remove();
        }

        Vec2f size = getSize();
        _list = new SelectList(this);
        foreach (item; _items) {
            _list.add(item);
            _label.text = item;
            size = size.max(_label.getSize() + Vec2f(24f, 8f));
        }
        _label.text = _value;

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
