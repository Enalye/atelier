module atelier.etabli.media.res.entity_base.parameter;

mixin template GraphicDataEntityParameter() {
    import atelier.etabli.media.res.entity_base.render_data;
    import atelier.etabli.media.res.entity_base.render_edit;

    private {
        VList _graphicList, _auxGraphicList;
    }

    void setupEntityGraphicsParameters(VList vlist, EntityRenderData[] graphics, EntityRenderData[] auxGraphics) {
        {
            LabelSeparator sep = new LabelSeparator("Rendu", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rendus Principaux:", Atelier.theme.font));

            _graphicList = new VList;
            _graphicList.setSize(Vec2f(300f, 200f));

            AccentButton addBtn = new AccentButton("Ajouter");
            addBtn.addEventListener("click", {
                EntityEditGraphicData modal = new EntityEditGraphicData(null, false);
                modal.addEventListener("render.new", {
                    auto elt = new GraphicElement(modal.getData());
                    _graphicList.addList(elt);
                    elt.addEventListener("graphic", {
                        dispatchEvent("property_render", false);
                    });
                    dispatchEvent("property_render", false);
                    Atelier.ui.popModalUI();
                });
                Atelier.ui.pushModalUI(modal);
            });
            hlayout.addUI(addBtn);

            vlist.addList(_graphicList);

            foreach (render; graphics) {
                auto elt = new GraphicElement(render);
                elt.addEventListener("graphic", {
                    dispatchEvent("property_render", false);
                });
                _graphicList.addList(elt);
            }
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rendus Auxiliaires:", Atelier.theme.font));

            _auxGraphicList = new VList;
            _auxGraphicList.setSize(Vec2f(300f, 200f));

            AccentButton addBtn = new AccentButton("Ajouter");
            addBtn.addEventListener("click", {
                EntityEditGraphicData modal = new EntityEditGraphicData(null, true);
                modal.addEventListener("render.new", {
                    auto elt = new GraphicElement(modal.getData());
                    _auxGraphicList.addList(elt);
                    elt.addEventListener("graphic", {
                        dispatchEvent("property_auxGraphic", false);
                    });
                    dispatchEvent("property_auxGraphic", false);
                    Atelier.ui.popModalUI();
                });
                Atelier.ui.pushModalUI(modal);
            });
            hlayout.addUI(addBtn);

            vlist.addList(_auxGraphicList);

            foreach (render; auxGraphics) {
                auto elt = new GraphicElement(render);
                elt.addEventListener("graphic", {
                    dispatchEvent("property_auxGraphic", false);
                });
                _auxGraphicList.addList(elt);
            }
        }
    }

    private void moveUpGraphic(GraphicElement item_) {
        bool isAuxGraphic = item_._data.isAuxGraphic;
        GraphicElement[] elements;

        if (isAuxGraphic) {
            elements = cast(GraphicElement[]) _auxGraphicList.getList();
            _auxGraphicList.clearList();
        }
        else {
            elements = cast(GraphicElement[]) _graphicList.getList();
            _graphicList.clearList();
        }

        for (size_t i = 1; i < elements.length; ++i) {
            if (elements[i] == item_) {
                elements[i] = elements[i - 1];
                elements[i - 1] = item_;
                break;
            }
        }

        if (isAuxGraphic) {
            foreach (GraphicElement element; elements) {
                _auxGraphicList.addList(element);
            }
        }
        else {
            foreach (GraphicElement element; elements) {
                _graphicList.addList(element);
            }
        }
    }

    private void moveDownGraphic(GraphicElement item_) {
        bool isAuxGraphic = item_._data.isAuxGraphic;
        GraphicElement[] elements;

        if (isAuxGraphic) {
            elements = cast(GraphicElement[]) _auxGraphicList.getList();
            _auxGraphicList.clearList();
        }
        else {
            elements = cast(GraphicElement[]) _graphicList.getList();
            _graphicList.clearList();
        }

        for (size_t i = 0; (i + 1) < elements.length; ++i) {
            if (elements[i] == item_) {
                elements[i] = elements[i + 1];
                elements[i + 1] = item_;
                break;
            }
        }

        if (isAuxGraphic) {
            foreach (GraphicElement element; elements) {
                _auxGraphicList.addList(element);
            }
        }
        else {
            foreach (GraphicElement element; elements) {
                _graphicList.addList(element);
            }
        }
    }

    EntityRenderData[] getRenders() {
        GraphicElement[] elements = cast(GraphicElement[]) _graphicList.getList();
        EntityRenderData[] graphics;
        foreach (GraphicElement elt; elements) {
            graphics ~= elt.getData();
        }
        return graphics;
    }

    EntityRenderData[] getAuxRenders() {
        GraphicElement[] elements = cast(GraphicElement[]) _auxGraphicList.getList();
        EntityRenderData[] graphics;
        foreach (GraphicElement elt; elements) {
            graphics ~= elt.getData();
        }
        return graphics;
    }

    private final class GraphicElement : UIElement {
        private {
            EntityRenderData _data;
            Label _nameLabel, _typeLabel;
            Rectangle _rect;
            HBox _hbox;
            IconButton _upBtn, _downBtn;
            Icon _icon, _checkmark;
        }

        this(EntityRenderData data) {
            _data = new EntityRenderData(data);
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

            _icon = new Icon("editor:ffd-" ~ _data.type);
            _icon.setAlign(UIAlignX.left, UIAlignY.center);
            _icon.setPosition(Vec2f(16f, 0f));
            addUI(_icon);

            _checkmark = new Icon("editor:checkmark");
            _checkmark.setAlign(UIAlignX.left, UIAlignY.center);
            _checkmark.setPosition(Vec2f(40f, 0f));
            _checkmark.color = Atelier.theme.accent;
            _checkmark.isVisible = _data.isDefault;
            addUI(_checkmark);

            {
                _hbox = new HBox;
                _hbox.setAlign(UIAlignX.right, UIAlignY.center);
                _hbox.setPosition(Vec2f(12f, 0f));
                _hbox.setSpacing(2f);
                addUI(_hbox);

                _upBtn = new IconButton("editor:arrow-small-up");
                _upBtn.addEventListener("click", {
                    this.outer.moveUpGraphic(this);
                });
                _hbox.addUI(_upBtn);

                _downBtn = new IconButton("editor:arrow-small-down");
                _downBtn.addEventListener("click", {
                    this.outer.moveDownGraphic(this);
                });
                _hbox.addUI(_downBtn);

                _hbox.isVisible = false;
                _hbox.isEnabled = false;
            }

            _updateDisplay();

            addEventListener("mouseenter", &_onMouseEnter);
            addEventListener("mouseleave", &_onMouseLeave);
            addEventListener("click", &_onClick);
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

        private void _updateDisplay() {
            _nameLabel.text = _data.name;
            _typeLabel.text = _data.type ~ ": " ~ _data.rid;
            _icon.setIcon("editor:ffd-" ~ _data.type);
            _checkmark.isVisible = _data.isDefault;
        }

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
        }

        EntityRenderData getData() {
            return _data;
        }
    }
}

mixin template BaseDataEntityParameter() {
    import std.array : split, join;

    import atelier.common;
    import atelier.core;
    import atelier.ui;
    import atelier.world;
    import atelier.etabli.ui;

    private {
        BaseEntityData _baseEntityData;
    }

    void setupEntityBaseParameters(VList vlist, BaseEntityData data) {
        _baseEntityData = data;

        {
            LabelSeparator sep = new LabelSeparator("Propriétés", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Contrôleur:", Atelier.theme.font));

            TextField controllerField = new TextField;
            controllerField.value = _baseEntityData.controller;
            controllerField.addEventListener("value", {
                _baseEntityData.controller = controllerField.value;
                dispatchEvent("property_base");
            });
            hlayout.addUI(controllerField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Ombre:", Atelier.theme.font));

            ResourceButton shadowField = new ResourceButton(_baseEntityData.shadow, "shadow",
                ["shadow"], true);
            if (_baseEntityData.shadow != shadowField.getName()) {
                _baseEntityData.shadow = shadowField.getName();
                dispatchEvent("property_base");
            }
            shadowField.addEventListener("value", {
                _baseEntityData.shadow = shadowField.getName();
                dispatchEvent("property_base");
            });
            hlayout.addUI(shadowField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Ordre Z:", Atelier.theme.font));

            IntegerField zOrderOffsetField = new IntegerField;
            zOrderOffsetField.value = _baseEntityData.zOrderOffset;
            zOrderOffsetField.addEventListener("value", {
                _baseEntityData.zOrderOffset = zOrderOffsetField.value;
                dispatchEvent("property_base");
            });
            hlayout.addUI(zOrderOffsetField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Tags:", Atelier.theme.font));

            TextField tagsField = new TextField;
            tagsField.value = _baseEntityData.tags.join(' ');
            tagsField.addEventListener("value", {
                _baseEntityData.tags.length = 0;
                foreach (element; tagsField.value.split(' ')) {
                    _baseEntityData.tags ~= element;
                }
                dispatchEvent("property_base");
            });
            hlayout.addUI(tagsField);
        }
    }

    BaseEntityData getBaseEntityData() {
        return _baseEntityData;
    }
}

mixin template HurtboxDataEntityParameter() {
    import std.array : split, join;
    import std.format : format;

    import atelier.common;
    import atelier.core;
    import atelier.physics;
    import atelier.ui;
    import atelier.world;
    import atelier.etabli.ui;

    private {
        HurtboxData _hurtbox;
        CarouselButton _hurtLayerBtn;
        IntegerField _hurtMinRadiusField, _hurtMaxRadiusField, _hurtHeightField;
        IntegerField _hurtAngleField, _hurtAngleDeltaField;
        IntegerField _hurtOffsetDistanceField, _hurtOffsetAngleField;
    }

    void setupEntityHurtboxParameters(VList vlist, HurtboxData data) {
        _hurtbox = data;

        {
            LabelSeparator sep = new LabelSeparator("Dégats", Atelier
                    .theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Calque:", Atelier.theme.font));

            string[33] layers;
            layers[0] = "Aucun";
            for (uint i; i < 32; ++i) {
                layers[i + 1] = format("%d - \"%s\"",
                    i + 1,
                    Atelier.physics.getHurtboxLayer(i).name);
            }

            _hurtLayerBtn = new CarouselButton(layers, "");
            _hurtLayerBtn.ivalue = _hurtbox.hasHurtbox ? (_hurtbox.layer + 1) : 0;
            _hurtLayerBtn.addEventListener("value", {
                _hurtbox.hasHurtbox = _hurtLayerBtn.ivalue > 0;
                if (_hurtbox.hasHurtbox) {
                    _hurtbox.layer = _hurtLayerBtn.ivalue - 1;
                }
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtLayerBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rayon Min:", Atelier.theme.font));

            _hurtMinRadiusField = new IntegerField;
            _hurtMinRadiusField.value = _hurtbox.minRadius;
            _hurtMinRadiusField.isEnabled = _hurtbox.hasHurtbox;
            _hurtMinRadiusField.setMinValue(0);
            _hurtMinRadiusField.addEventListener("value", {
                _hurtbox.minRadius = _hurtMinRadiusField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtMinRadiusField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rayon Max:", Atelier
                    .theme.font));

            _hurtMaxRadiusField = new IntegerField;
            _hurtMaxRadiusField.value = _hurtbox.maxRadius;
            _hurtMaxRadiusField.isEnabled = _hurtbox.hasHurtbox;
            _hurtMaxRadiusField.setMinValue(0);
            _hurtMaxRadiusField.addEventListener("value", {
                _hurtbox.maxRadius = _hurtMaxRadiusField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtMaxRadiusField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Hauteur:", Atelier
                    .theme.font));

            _hurtHeightField = new IntegerField;
            _hurtHeightField.value = _hurtbox.height;
            _hurtHeightField.isEnabled = _hurtbox.hasHurtbox;
            _hurtHeightField.setMinValue(0);
            _hurtHeightField.addEventListener("value", {
                _hurtbox.height = _hurtHeightField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtHeightField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Orientation:", Atelier
                    .theme.font));

            _hurtAngleField = new IntegerField;
            _hurtAngleField.value = _hurtbox.angle;
            _hurtAngleField.isEnabled = _hurtbox.hasHurtbox;
            _hurtAngleField.setRange(0, 360);
            _hurtAngleField.addEventListener("value", {
                _hurtbox.angle = _hurtAngleField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtAngleField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Ouverture:", Atelier
                    .theme.font));

            _hurtAngleDeltaField = new IntegerField;
            _hurtAngleDeltaField.value = _hurtbox.angleDelta;
            _hurtAngleDeltaField.isEnabled = _hurtbox.hasHurtbox;
            _hurtAngleDeltaField.setRange(0, 180);
            _hurtAngleDeltaField.addEventListener("value", {
                _hurtbox.angleDelta = _hurtAngleDeltaField
                    .value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtAngleDeltaField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Décalage Distance:", Atelier
                    .theme.font));

            _hurtOffsetDistanceField = new IntegerField;
            _hurtOffsetDistanceField.value = _hurtbox
                .offsetDist;
            _hurtOffsetDistanceField.isEnabled = _hurtbox.hasHurtbox;
            _hurtOffsetDistanceField.addEventListener("value", {
                _hurtbox.offsetDist = _hurtOffsetDistanceField
                    .value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtOffsetDistanceField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Décalage Angle:", Atelier
                    .theme.font));

            _hurtOffsetAngleField = new IntegerField;
            _hurtOffsetAngleField.value = _hurtbox.offsetAngle;
            _hurtOffsetAngleField.isEnabled = _hurtbox.hasHurtbox;
            _hurtOffsetAngleField.addEventListener("value", {
                _hurtbox.offsetAngle = _hurtOffsetAngleField
                    .value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtOffsetAngleField);
        }

        addEventListener("property_hurtbox", {
            bool isHurtboxEnabled = _hurtbox.hasHurtbox;
            _hurtMinRadiusField.isEnabled = isHurtboxEnabled;
            _hurtMaxRadiusField.isEnabled = isHurtboxEnabled;
            _hurtHeightField.isEnabled = isHurtboxEnabled;
            _hurtAngleField.isEnabled = isHurtboxEnabled;
            _hurtAngleDeltaField.isEnabled = isHurtboxEnabled;
            _hurtOffsetDistanceField.isEnabled = isHurtboxEnabled;
            _hurtOffsetAngleField.isEnabled = isHurtboxEnabled;
        });
    }

    HurtboxData getHurtbox() {
        return _hurtbox;
    }
}
