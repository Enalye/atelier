module atelier.etabli.ui.ressource_selector;

import std.algorithm.searching;
import std.algorithm.mutation;
import std.array;
import std.path;
import std.string;
import std.typecons : No;
import std.file;
import std.string;

import atelier;

import atelier.etabli.ui.studio;

final class RessourceButton : Button!RoundedRectangle {
    private {
        RoundedRectangle _background;
        string[] _types;
        string _name, _type;
        Icon _icon;
        Label _label;
    }

    this(string name_, string type_, string[] types_) {
        _name = name_;
        _type = type_;
        _types = types_;

        if (!Atelier.etabli.hasResource(_type, _name)) {
            _name.length = 0;
            string[] list = Atelier.etabli.getResourceList(_type);
            if (list.length > 0) {
                _name = list[0];
            }
        }

        setSize(Vec2f(200f, 24f));
        setFxColor(Atelier.theme.neutral);

        HBox hbox = new HBox;
        hbox.setAlign(UIAlignX.center, UIAlignY.center);
        hbox.setSpacing(8f);
        hbox.isEnabled = false;
        addUI(hbox);

        _icon = new Icon("editor:ffd-" ~ _type);
        hbox.addUI(_icon);

        _label = new Label(_name, Atelier.theme.font);
        hbox.addUI(_label);

        _background = RoundedRectangle.fill(getSize(), Atelier.theme.corner);
        _background.color = Atelier.theme.neutral;
        _background.anchor = Vec2f.zero;
        addImage(_background);

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);

        addEventListener("enable", &_onEnable);
        addEventListener("disable", &_onDisable);

        addEventListener("click", &_onClick);
    }

    private void _onEnable() {
        _background.alpha = Atelier.theme.activeOpacity;
        _background.color = Atelier.theme.neutral;

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onDisable() {
        _background.alpha = Atelier.theme.inactiveOpacity;
        _background.color = Atelier.theme.neutral;

        removeEventListener("mouseenter", &_onMouseEnter);
        removeEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onMouseEnter() {
        Color rgb = Atelier.theme.neutral;
        HSLColor hsl = HSLColor.fromColor(rgb);
        hsl.l = hsl.l * .8f;
        _background.color = hsl.toColor();
    }

    private void _onMouseLeave() {
        _background.color = Atelier.theme.neutral;
    }

    private void _onClick() {
        RessourceSelectorModal modal = new RessourceSelectorModal(_name, _type, _types);
        modal.addEventListener("ressourceSelector", {
            _name = modal.getName();
            _type = modal.getType();
            _label.text = _name;
            _icon.setIcon("editor:ffd-" ~ _type);
            dispatchEvent("value", false);
            Atelier.ui.popModalUI();
        });
        Atelier.ui.pushModalUI(modal);
    }

    void setTypes(string[] types) {
        _types = types;
    }

    string getName() const {
        return _name;
    }

    string getType() const {
        return _type;
    }

    void setValue(string type_, string name_) {
        _type = type_;
        _name = name_;

        if (!Atelier.etabli.hasResource(_type, _name)) {
            _name.length = 0;
            string[] list = Atelier.etabli.getResourceList(_type);
            if (list.length > 0) {
                _name = list[0];
            }
        }

        _label.text = _name;
        _icon.setIcon("editor:ffd-" ~ _type);
    }
}

private final class RessourceSelectorModal : Modal {
    private {
        TextField _searchField;
        VList _fileList;
        RessourceItem[] _ressourceItems;
        size_t _selectedItemIndex;
        string[] _types;
        string _type, _name;
        string _oldType, _oldName;
    }

    this(string name_, string type_, string[] types_) {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(500f, 500f));
        _types = types_;
        _oldType = type_;
        _oldName = name_;

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.center, UIAlignY.center);
        vbox.setChildAlign(UIAlignX.center);
        vbox.setSpacing(4f);
        addUI(vbox);

        {
            Label title = new Label("Sélectionner une ressource", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            vbox.addUI(title);
        }

        {
            IconButton exitBtn = new IconButton("editor:exit");
            exitBtn.setAlign(UIAlignX.right, UIAlignY.top);
            exitBtn.setPosition(Vec2f(4f, 4f));
            exitBtn.addEventListener("click", &removeUI);
            addUI(exitBtn);
        }

        {
            _searchField = new TextField;
            _searchField.setAlign(UIAlignX.left, UIAlignY.top);
            _searchField.setWidth(400f);
            _searchField.addEventListener("value", &_onSearch);
            vbox.addUI(_searchField);

            Atelier.ui.setFocus(_searchField);
        }

        {
            _fileList = new VList;
            _fileList.setSize(Vec2f(492f, 432f));
            vbox.addUI(_fileList);
        }

        _onSearch();

        addEventListener("globalkey", &_onKey);
    }

    private void _onKey() {
        InputEvent.KeyButton event = Atelier.ui.input().asKeyButton();

        if (!event.isPressed())
            return;

        switch (event.button) with (InputEvent.KeyButton.Button) {
        case enter:
        case enter2:
        case numEnter:
            if (_selectedItemIndex < _ressourceItems.length) {
                validate(_ressourceItems[_selectedItemIndex].getName(),
                    _ressourceItems[_selectedItemIndex].getType());
            }
            break;
        case escape:
            this.removeUI();
            break;
        case up:
            if (_selectedItemIndex == 0) {
                _selectedItemIndex = _ressourceItems.length > 0 ?
                    (cast(ptrdiff_t) _ressourceItems.length - 1) : 0;
            }
            else {
                _selectedItemIndex--;
            }
            _updateSelectedItem();
            break;
        case down:
            _selectedItemIndex++;
            if (_selectedItemIndex >= _ressourceItems.length) {
                _selectedItemIndex = 0;
            }
            _updateSelectedItem();
            break;
        default:
            break;
        }
    }

    private void _updateSelectedItem() {
        if (_selectedItemIndex < _ressourceItems.length) {
            _fileList.moveToElement(_ressourceItems[_selectedItemIndex].elementIndex);
        }
        for (size_t i; i < _ressourceItems.length; ++i) {
            _ressourceItems[i].setSelected(i == _selectedItemIndex);
        }
    }

    private void _onSearch() {
        _fileList.clearList();
        _ressourceItems.length = 0;
        _selectedItemIndex = 0;

        string search = _searchField.value;
        size_t elementIndex;

        foreach (type; _types) {
            bool isInit = true;
            foreach (res; Atelier.etabli.getResourceList(type)) {
                if (res.indexOf(search, No.caseSentitive) == -1)
                    continue;

                if (isInit) {
                    isInit = false;
                    _fileList.addList(new TypeItem(type));
                    elementIndex++;
                }

                bool isOldValue = (res == _oldName && type == _oldType);
                RessourceItem item = new RessourceItem(this, isOldValue, res, type, search);
                item.elementIndex = elementIndex;
                _ressourceItems ~= item;
                _fileList.addList(item);
                elementIndex++;
            }
        }

        _updateSelectedItem();
    }

    string getName() {
        return _name;
    }

    string getType() {
        return _type;
    }

    void validate(string name_, string type_) {
        _type = type_;
        _name = name_;
        dispatchEvent("ressourceSelector", false);
    }
}

private final class TypeItem : UIElement {
    private {
        string _name;
    }

    this(string name) {
        _name = name;

        setSize(Vec2f(492f, 32f));

        LabelSeparator sep = new LabelSeparator(_name, Atelier.theme.font);
        sep.setColor(Atelier.theme.neutral);
        sep.setPadding(Vec2f(284f, 0f));
        sep.setSpacing(8f);
        sep.setLineWidth(1f);
        addUI(sep);
    }
}

private final class RessourceItem : UIElement {
    private {
        RessourceSelectorModal _ressourceSelector;
        Rectangle _rect;
        string _name, _type;
        bool _isSelected;
    }

    protected size_t elementIndex;

    this(RessourceSelectorModal ressourceSelector, bool isOldValue, string name_,
        string type_, string search) {
        _ressourceSelector = ressourceSelector;
        _type = type_;
        _name = name_;

        setSize(Vec2f(492f, 24f));

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.foreground;
        _rect.isVisible = false;
        addImage(_rect);

        if (isOldValue) {
            Icon icon = new Icon("editor:checkmark");
            icon.setAlign(UIAlignX.left, UIAlignY.center);
            icon.setPosition(Vec2f(4f, 0f));
            icon.color = Atelier.theme.accent;
            addUI(icon);
        }

        {
            Icon icon = new Icon("editor:ffd-" ~ _type);
            icon.setAlign(UIAlignX.left, UIAlignY.center);
            icon.setPosition(Vec2f(32f, 0f));
            addUI(icon);
        }

        ColoredLabel nameLabel = new ColoredLabel(_name, Atelier.theme.font);
        nameLabel.setAlign(UIAlignX.left, UIAlignY.center);
        nameLabel.setPosition(Vec2f(64f, 0f));
        addUI(nameLabel);

        ptrdiff_t index = -1;
        size_t startSearch = 0;
        if (search.length > 0) {
            for (;;) {
                index = indexOf(_name[startSearch .. $], search, No.caseSentitive);
                if (index < 0)
                    break;

                index += startSearch;

                ColoredLabel.Token token1, token2;
                token1.index = index;
                token1.textColor = Atelier.theme.accent;
                nameLabel.tokens ~= token1;

                token2.index = index + search.length;
                token2.textColor = Atelier.theme.onNeutral;
                nameLabel.tokens ~= token2;

                startSearch = index + search.length;
            }
        }

        {
            Label dirLabel = new Label(_type, Atelier.theme.font);
            dirLabel.setAlign(UIAlignX.right, UIAlignY.center);
            dirLabel.setPosition(Vec2f(64f, 0f));
            dirLabel.textColor = Atelier.theme.neutral;
            addUI(dirLabel);
        }

        addEventListener("mouseenter", {
            if (!_isSelected)
                _rect.isVisible = true;
        });
        addEventListener("mouseleave", {
            if (!_isSelected)
                _rect.isVisible = false;
        });
        addEventListener("click", &_onClick);
    }

    void setSelected(bool isSelected_) {
        _isSelected = isSelected_;

        if (_isSelected) {
            HSLColor hsl = HSLColor.fromColor(Atelier.theme.accent);
            hsl.l = hsl.l * 0.5f;
            _rect.color = hsl.toColor();
            _rect.isVisible = true;
        }
        else {
            _rect.color = Atelier.theme.foreground;
            _rect.isVisible = isHovered();
        }
    }

    string getName() const {
        return _name;
    }

    string getType() const {
        return _type;
    }

    private void _onClick() {
        _ressourceSelector.validate(_name, _type);
    }
}
