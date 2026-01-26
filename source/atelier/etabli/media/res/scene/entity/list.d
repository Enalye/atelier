module atelier.etabli.media.res.scene.entity.list;

import std.conv : to;
import std.string;
import std.typecons : No;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui;
import atelier.etabli.media.res.scene.common;

final class SceneEntityList : UIElement {
    private {
        TextField _searchField;
        TabGroup _tabs;
        VList _list;
        EntityElement[] _items;
        SceneDefinition.Entity _selectedEntity;
    }

    this(SceneDefinition.Entity[] entities) {
        foreach (SceneDefinition.Entity entity; entities) {
            _items ~= new EntityElement(entity);
        }

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.right, UIAlignY.top);
        vbox.setChildAlign(UIAlignX.right);
        vbox.setSpacing(8f);
        addUI(vbox);

        {
            LabelSeparator sep = new LabelSeparator("Entités", Atelier.theme.font);
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

        {
            string[] types = "*" ~ [
                __traits(allMembers, SceneDefinition.Entity.Type)
            ];

            _tabs = new TabGroup;
            _tabs.setWidth(300f);
            foreach (string type; types) {
                if (type == "*") {
                    _tabs.addTab("*", type, "");
                }
                else {
                    _tabs.addTab("", type, "editor:ffd-" ~ type);
                }
            }
            vbox.addUI(_tabs);

            _tabs.selectTab("*");
            _tabs.addEventListener("value", &_rebuildList);
        }

        _list = new VList;
        _list.setSize(Vec2f(300f, 855f));
        vbox.addUI(_list);

        vbox.addEventListener("size", { setSize(vbox.getSize()); });

        _rebuildList();
    }

    private void _rebuildList() {
        _list.clearList();
        string search = _searchField ? _searchField.value.toLower : "";
        foreach (item; _items) {
            bool catSearch = (_tabs.ivalue() == 0) || ((_tabs.ivalue() - 1) == item._entity.type());
            bool nameSearch = (search.length == 0) ||
                indexOf(item.getName(), search, No.caseSentitive) != -1;
            if (catSearch && nameSearch) {
                item.updateDisplay(search);
                _list.addList(item);
            }
        }
    }

    private void _centerEntity(SceneDefinition.Entity entity) {
        _selectedEntity = entity;
        dispatchEvent("entity_list_center", false);
    }

    private void _selectEntity(SceneDefinition.Entity entity) {
        _selectedEntity = entity;
        dispatchEvent("entity_list_select", false);
    }

    SceneDefinition.Entity getSelectedEntity() {
        return _selectedEntity;
    }

    private final class EntityElement : UIElement {
        private {
            SceneDefinition.Entity _entity;
            ColoredLabel _nameLabel;
            Label _typeLabel;
            Rectangle _rect;
            HBox _hbox;
            IconButton _viewBtn;
        }

        this(SceneDefinition.Entity entity) {
            _entity = entity;
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

            final switch (_entity.type) with (SceneDefinition.Entity.Type) {
            case entity:
                addEventListener("draw", &_onDraw);
                break;
            case trigger:
                _addIcon("editor:entity-trigger");
                break;
            case teleporter:
                _addIcon("editor:entity-teleporter");
                break;
            case note:
                _addIcon("editor:entity-note");
                break;
            case marker:
                _addIcon("editor:entity-marker");
                break;
            }

            {
                _hbox = new HBox;
                _hbox.setAlign(UIAlignX.right, UIAlignY.center);
                _hbox.setPosition(Vec2f(12f, 0f));
                _hbox.setSpacing(2f);
                addUI(_hbox);

                _viewBtn = new IconButton("editor:center-button");
                _viewBtn.addEventListener("click", {
                    this.outer._centerEntity(_entity);
                });
                _hbox.addUI(_viewBtn);

                _hbox.isVisible = false;
                _hbox.isEnabled = false;
            }

            addEventListener("mouseenter", &_onMouseEnter);
            addEventListener("mouseleave", &_onMouseLeave);
            addEventListener("click", { this.outer._selectEntity(_entity); });
        }

        private void _addIcon(string rid) {
            Icon icon = new Icon(rid);
            icon.setAlign(UIAlignX.left, UIAlignY.center);
            icon.setPosition(Vec2f(16f, 0f));
            addUI(icon);
        }

        string getName() {
            return _entity.entityData.name;
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

        private void _onDraw() {
            _entity.drawSnapshot(Vec2f.one * getHeight() / 2f);
        }

        void updateDisplay(string search) {
            _nameLabel.text = _entity.entityData.name;

            ptrdiff_t index = -1;
            size_t startSearch = 0;
            _nameLabel.tokens.length = 0;
            if (search.length > 0) {
                for (;;) {
                    index = indexOf(_entity.entityData.name[startSearch .. $],
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

            _typeLabel.text = _entity.getTypeInfo();
        }
    }
}
