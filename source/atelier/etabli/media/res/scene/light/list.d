module atelier.etabli.media.res.scene.light.list;

import std.conv : to;
import std.string;
import std.typecons : No;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui;
import atelier.etabli.media.res.scene.common;

final class SceneLightList : UIElement {
    private {
        TextField _searchField;
        VList _list;
        LightElement[] _items;
        SceneDefinition.Light _selectedLight;
    }

    this(SceneDefinition.Light[] entities) {
        foreach (SceneDefinition.Light light; entities) {
            _items ~= new LightElement(light);
        }

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.right, UIAlignY.top);
        vbox.setChildAlign(UIAlignX.right);
        vbox.setSpacing(8f);
        addUI(vbox);

        {
            LabelSeparator sep = new LabelSeparator("Lumières", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(300f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vbox.addUI(sep);
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            hbox.setMargin(Vec2f(16f, 0f));
            vbox.addUI(hbox);

            hbox.addUI(new Icon("editor:magnify"));

            _searchField = new TextField;
            _searchField.setWidth(250f);
            _searchField.addEventListener("value", &_rebuildList);
            hbox.addUI(_searchField);
        }

        _list = new VList;
        _list.setSize(Vec2f(300f, 895f));
        vbox.addUI(_list);

        vbox.addEventListener("size", { setSize(vbox.getSize()); });

        _rebuildList();
    }

    private void _rebuildList() {
        _list.clearList();
        string search = _searchField ? _searchField.value.toLower : "";
        foreach (item; _items) {
            bool nameSearch = (search.length == 0) ||
                indexOf(item.getName(), search, No.caseSentitive) != -1;
            if (nameSearch) {
                item.updateDisplay(search);
                _list.addList(item);
            }
        }
    }

    private void _centerLight(SceneDefinition.Light light) {
        _selectedLight = light;
        dispatchEvent("light_list_center", false);
    }

    private void _selectLight(SceneDefinition.Light light) {
        _selectedLight = light;
        dispatchEvent("light_list_select", false);
    }

    SceneDefinition.Light getSelectedLight() {
        return _selectedLight;
    }

    private final class LightElement : UIElement {
        private {
            SceneDefinition.Light _light;
            ColoredLabel _nameLabel;
            Label _typeLabel;
            Rectangle _rect;
            HBox _hbox;
            IconButton _viewBtn;
        }

        this(SceneDefinition.Light light) {
            _light = light;
            setSize(Vec2f(284f, 48f));

            _rect = Rectangle.fill(getSize());
            _rect.anchor = Vec2f.zero;
            _rect.color = Atelier.theme.foreground;
            _rect.isVisible = false;
            addImage(_rect);

            _nameLabel = new ColoredLabel("", Atelier.theme.font);
            _nameLabel.setAlign(UIAlignX.left, UIAlignY.top);
            _nameLabel.setPosition(Vec2f(64f, 4f));
            addUI(_nameLabel);

            _typeLabel = new Label("", Atelier.theme.font);
            _typeLabel.setAlign(UIAlignX.left, UIAlignY.bottom);
            _typeLabel.setPosition(Vec2f(64f, 4f));
            _typeLabel.textColor = Atelier.theme.neutral;
            addUI(_typeLabel);

            string rid = _light.icon();
            if (rid.length) {
                Sprite icon = Atelier.etabli.getSprite(rid);
                icon.anchor = Vec2f.half;
                icon.position = Vec2f.one * getHeight() / 2f;
                addImage(icon);
            }

            {
                _hbox = new HBox;
                _hbox.setAlign(UIAlignX.right, UIAlignY.center);
                _hbox.setPosition(Vec2f(12f, 0f));
                _hbox.setSpacing(2f);
                addUI(_hbox);

                _viewBtn = new IconButton("editor:center-button");
                _viewBtn.addEventListener("click", {
                    this.outer._centerLight(_light);
                });
                _hbox.addUI(_viewBtn);

                _hbox.isVisible = false;
                _hbox.isEnabled = false;
            }

            addEventListener("mouseenter", &_onMouseEnter);
            addEventListener("mouseleave", &_onMouseLeave);
            addEventListener("click", { this.outer._selectLight(_light); });
        }

        string getName() {
            return _light.data.name;
        }

        private void _onMouseEnter() {
            _rect.isVisible = true;
            _hbox.isVisible = true;
            _hbox.isEnabled = true;
        }

        private void _onMouseLeave() {
            _rect.isVisible = false;
            _hbox.isVisible = false;
            _hbox.isEnabled = false;
        }

        void updateDisplay(string search) {
            _nameLabel.text = _light.data.name;

            ptrdiff_t index = -1;
            size_t startSearch = 0;
            _nameLabel.tokens.length = 0;
            if (search.length > 0) {
                for (;;) {
                    index = indexOf(_light.data.name[startSearch .. $],
                        search, No.caseSentitive);
                    if (index < 0)
                        break;

                    index += startSearch;

                    ColoredLabel.Token token1, token2;
                    token1.index = index;
                    token1.textColor = Atelier.theme.accent;
                    _nameLabel.tokens ~= token1;

                    token2.index = index + search.length;
                    token2.textColor = Atelier.theme.onNeutral;
                    _nameLabel.tokens ~= token2;

                    startSearch = index + search.length;
                }
            }
            else {
                ColoredLabel.Token token;
                token.index = 0;
                token.textColor = Atelier.theme.onNeutral;
                _nameLabel.tokens ~= token;
            }

            _typeLabel.text = _light.getTypeInfo();
        }
    }
}
