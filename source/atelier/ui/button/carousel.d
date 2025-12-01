module atelier.ui.button.carousel;

import std.conv : to;
import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.core;
import atelier.ui.button.neutral;

final class CarouselButton : UIElement {
    private {
        RoundedRectangle _background;
        Label _label;
        string[] _items;
        size_t _index;
        string _value;
    }

    @property {
        uint ivalue() const {
            return cast(uint) _index;
        }

        uint ivalue(uint ivalue_) {
            if (_index == ivalue_ || ivalue_ > _items.length)
                return cast(uint) _index;

            _index = ivalue_;
            _value = _items[_index];
            _label.text = _value;

            return cast(uint) _index;
        }

        string value() const {
            return _value;
        }

        string value(string value_) {
            if (_value == value_)
                return _value;

            for (size_t i; i < _items.length; ++i) {
                if (_items[i] == value_) {
                    _index = i;
                    _value = value_;
                    _label.text = _value;
                    break;
                }
            }

            return _value;
        }
    }

    this(string[] items, string defaultItem, bool isAccent = false) {
        _items = items.dup;

        _label = new Label("", Atelier.theme.font);
        _label.setAlign(UIAlignX.center, UIAlignY.center);
        _label.textColor = Atelier.theme.onAccent;
        addUI(_label);

        _background = RoundedRectangle.fill(getSize(), Atelier.theme.corner);
        _background.color = isAccent ? Atelier.theme.accent : Atelier.theme.neutral;
        _background.anchor = Vec2f.zero;
        addImage(_background);

        NeutralButton previousBtn = new NeutralButton("<");
        previousBtn.setAlign(UIAlignX.left, UIAlignY.center);
        previousBtn.addEventListener("click", &_onPrevious);
        addUI(previousBtn);

        NeutralButton nextBtn = new NeutralButton(">");
        nextBtn.setAlign(UIAlignX.right, UIAlignY.center);
        nextBtn.addEventListener("click", &_onNext);
        addUI(nextBtn);

        {
            Vec2f sz = Vec2f.zero;

            foreach (item; _items) {
                Vec2f textSize = getSizeOfText(Atelier.theme.font, to!dstring(item), 1f, 0f);
                sz = sz.max(textSize);
            }

            sz.y = max(sz.y, previousBtn.getHeight());
            sz.x += previousBtn.getWidth() + nextBtn.getWidth() + 24f;
            setSize(sz);
        }
        _background.size = getSize();

        if (_items.length)
            _value = _items[0];
        _label.text = value(defaultItem);
    }

    private void _onPrevious() {
        if (_index > 0) {
            _index--;
        }
        else if (_items.length > 0) {
            _index = (cast(ptrdiff_t) _items.length) - 1;
        }

        if (_items.length > 0 && _index < _items.length) {
            _value = _items[_index];
            _label.text = _value;
            dispatchEvent("value", false);
        }
    }

    private void _onNext() {
        _index++;
        if (_index >= _items.length)
            _index = 0;

        if (_items.length > 0 && _index < _items.length) {
            _value = _items[_index];
            _label.text = _value;
            dispatchEvent("value", false);
        }
    }
}
