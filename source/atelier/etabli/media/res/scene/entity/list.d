module atelier.etabli.media.res.scene.entity.list;

import std.conv : to;
import std.string;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui;
import atelier.etabli.media.res.scene.common;

final class SceneEntityList : UIElement {
    private {
        TextField _searchField;
        VList _list;
        EntityElement[] _items;
    }

    this(SceneDefinition.Entity[] entities) {
        foreach (SceneDefinition.Entity entity; entities) {
            _items ~= new EntityElement(entity);
        }

        VBox vbox = new VBox;
        vbox.setPosition(Vec2f(4f, 8f));
        vbox.setAlign(UIAlignX.right, UIAlignY.top);
        vbox.setChildAlign(UIAlignX.right);
        vbox.setSpacing(8f);
        addUI(vbox);

        {
            LabelSeparator sep = new LabelSeparator("Entités", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
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
            _searchField.setWidth(200f);
            _searchField.addEventListener("value", &_rebuildList);
            hbox.addUI(_searchField);
        }

        _list = new VList;
        _list.setSize(Vec2f(284f, 800f));
        vbox.addUI(_list);

        vbox.addEventListener("size", { setSize(vbox.getSize()); });

        _rebuildList();
    }

    private void _rebuildList() {
        _list.clearList();
        string search = _searchField ? _searchField.value.toLower : "";
        foreach (item; _items) {
            if ((search.length == 0) || item.getName().toLower.indexOf(search) != -1) {
                _list.addList(item);
            }
        }
    }

    private final class EntityElement : UIElement {
        private {
            SceneDefinition.Entity _entity;
            Label _nameLabel, _typeLabel;
            Rectangle _rect;
            HBox _hbox;
            IconButton _viewBtn;
            Icon _icon;
        }

        this(SceneDefinition.Entity entity) {
            _entity = entity;
            setSize(Vec2f(300f, 48f));

            _rect = Rectangle.fill(getSize());
            _rect.anchor = Vec2f.zero;
            _rect.color = Atelier.theme.foreground;
            _rect.isVisible = false;
            addImage(_rect);

            _nameLabel = new Label("", Atelier.theme.font);
            _nameLabel.setAlign(UIAlignX.left, UIAlignY.top);
            _nameLabel.setPosition(Vec2f(64f, 4f));
            _nameLabel.textColor = Atelier.theme.onNeutral;
            addUI(_nameLabel);

            _typeLabel = new Label("", Atelier.theme.font);
            _typeLabel.setAlign(UIAlignX.left, UIAlignY.bottom);
            _typeLabel.setPosition(Vec2f(64f, 4f));
            _typeLabel.textColor = Atelier.theme.neutral;
            addUI(_typeLabel);

            //_icon = new Icon("editor:ffd-" ~ _data.type);
            //_icon.setAlign(UIAlignX.left, UIAlignY.center);
            //_icon.setPosition(Vec2f(16f, 0f));
            //addUI(_icon);

            {
                _hbox = new HBox;
                _hbox.setAlign(UIAlignX.right, UIAlignY.center);
                _hbox.setPosition(Vec2f(12f, 0f));
                _hbox.setSpacing(2f);
                addUI(_hbox);

                _viewBtn = new IconButton("editor:shown");
                _viewBtn.addEventListener("click", {
                    //TODO: Centrer la vue
                });
                _hbox.addUI(_viewBtn);

                _hbox.isVisible = false;
                _hbox.isEnabled = false;
            }

            _updateDisplay();

            addEventListener("mouseenter", &_onMouseEnter);
            addEventListener("mouseleave", &_onMouseLeave);
            addEventListener("click", {
                //TODO: Sélectionner l’entité
            });

            addEventListener("draw", &_onDraw);
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

        private void _updateDisplay() {
            _nameLabel.text = _entity.entityData.name;
            string typeName = to!string(_entity.type);
            _typeLabel.text = typeName; // ~ ": " ~ _entity.entityData.rid;
            //_icon.setIcon("editor:ffd-" ~ typeName);
            //_checkmark.isVisible = _data.isDefault;
        }
        /*
        private void _onClick() {
            EntityEditGraphicData modal = new EntityEditGraphicData(_data, _data.isAuxGraphic);
            modal.addEventListener("render.apply", {
                _data = modal.getData();
                if (modal.isDirty()) {
                    dispatchEvent("graphic", false);
                }
                _updateDisplay();
                Atelier.ui.popModalUI();
            });
            modal.addEventListener("render.remove", {
                dispatchEvent("graphic", false);
                Atelier.ui.popModalUI();
                removeUI();
            });
            Atelier.ui.pushModalUI(modal);
        }*/
    }
}
