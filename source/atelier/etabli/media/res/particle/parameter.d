module atelier.etabli.media.res.particle.parameter;

import atelier;
import farfadet;
import atelier.etabli.ui;
import atelier.etabli.media.res.entity_render;

package struct HitboxData {
    Vec3u size = Vec3u.zero;
    bool hasHitbox;

    void load(Farfadet ffd) {
        size = Vec3u.zero;
        hasHitbox = ffd.hasNode("hitbox");

        if (!hasHitbox)
            return;

        ffd = ffd.getNode("hitbox");

        if (ffd.hasNode("size")) {
            size = ffd.getNode("size").get!Vec3u(0);
        }
    }

    void save(Farfadet ffd) {
        if (hasHitbox) {
            Farfadet node = ffd.addNode("hitbox");
            node.addNode("size").add(size);
        }
    }
}

package final class ParameterWindow : UIElement {
    private {
        // Rendu
        VList _renderList;

        // Collision
        HitboxData _hitbox;
        Checkbox _hitboxCheck;
        IntegerField _collXField, _collYField, _collZField;

        // Particule
        ParticleData _particle;
        SelectButton _modeBtn;
        Checkbox _repeatCheck;
        IntegerField _durationField, _delayField;
        IntegerField _quantityField, _quantityVarianceField;
        NumberField _sizeXField, _sizeYField, _sizeZField;
        NumberField _distanceField, _distanceVarianceField;
        NumberField _angleField, _angleVarianceField, _angleSpreadField;
        TextField _eventField;
        SelectButton _layerBtn;
    }

    this(EntityRenderData[] renders, HitboxData hitbox, ParticleData particle) {
        VList vlist = new VList;
        vlist.setPosition(Vec2f(8f, 8f));
        vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        vlist.setAlign(UIAlignX.left, UIAlignY.top);
        vlist.setColor(Atelier.theme.surface);
        vlist.setSpacing(8f);
        vlist.setChildAlign(UIAlignX.left);
        addUI(vlist);

        _hitbox = hitbox;
        _particle = particle;

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

            hlayout.addUI(new Label("Rendus:", Atelier.theme.font));

            _renderList = new VList;
            _renderList.setSize(Vec2f(300f, 200f));

            AccentButton addBtn = new AccentButton("Ajouter");
            addBtn.addEventListener("click", {
                EntityEditRenderData modal = new EntityEditRenderData();
                modal.addEventListener("render.new", {
                    auto elt = new RenderElement(this, modal.getData());
                    _renderList.addList(elt);
                    elt.addEventListener("render", {
                        dispatchEvent("property_render", false);
                    });
                    dispatchEvent("property_render", false);
                    Atelier.ui.popModalUI();
                });
                Atelier.ui.pushModalUI(modal);
            });
            hlayout.addUI(addBtn);

            vlist.addList(_renderList);

            foreach (render; renders) {
                auto elt = new RenderElement(this, render);
                elt.addEventListener("render", {
                    dispatchEvent("property_render", false);
                });
                _renderList.addList(elt);
            }
        }

        {
            LabelSeparator sep = new LabelSeparator("Collision", Atelier.theme.font);
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

            hlayout.addUI(new Label("Solide ?", Atelier.theme.font));

            _hitboxCheck = new Checkbox(_hitbox.hasHitbox);
            _hitboxCheck.addEventListener("value", {
                _hitbox.hasHitbox = _hitboxCheck.value;
                _collXField.isEnabled = _hitbox.hasHitbox;
                _collYField.isEnabled = _hitbox.hasHitbox;
                _collZField.isEnabled = _hitbox.hasHitbox;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_hitboxCheck);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("x:", Atelier.theme.font));

            _collXField = new IntegerField;
            _collXField.value = _hitbox.size.x;
            _collXField.setMinValue(0);
            _collXField.isEnabled = _hitbox.hasHitbox;
            _collXField.addEventListener("value", {
                _hitbox.size.x = _collXField.value;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_collXField);

            hlayout.addUI(new Label("y:", Atelier.theme.font));

            _collYField = new IntegerField;
            _collYField.value = _hitbox.size.y;
            _collYField.setMinValue(0);
            _collYField.isEnabled = _hitbox.hasHitbox;
            _collYField.addEventListener("value", {
                _hitbox.size.y = _collYField.value;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_collYField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("z:", Atelier.theme.font));

            _collZField = new IntegerField;
            _collZField.value = _hitbox.size.z;
            _collZField.setMinValue(0);
            _collZField.isEnabled = _hitbox.hasHitbox;
            _collZField.addEventListener("value", {
                _hitbox.size.z = _collZField.value;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_collZField);
        }

        {
            LabelSeparator sep = new LabelSeparator("Particule", Atelier.theme.font);
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

            hlayout.addUI(new Label("Mode:", Atelier.theme.font));

            _modeBtn = new SelectButton([__traits(allMembers, ParticleMode)], _particle.mode);
            _modeBtn.setWidth(200f);
            _modeBtn.addEventListener("value", {
                _particle.mode = _modeBtn.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_modeBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Durée:", Atelier.theme.font));

            _durationField = new IntegerField;
            _durationField.value = _particle.duration;
            _durationField.setMinValue(0);
            _durationField.addEventListener("value", {
                _particle.duration = _durationField.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_durationField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Boucle ?", Atelier.theme.font));

            _repeatCheck = new Checkbox(_particle.repeat);
            _repeatCheck.addEventListener("value", {
                _particle.repeat = _repeatCheck.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_repeatCheck);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Délai:", Atelier.theme.font));

            _delayField = new IntegerField;
            _delayField.value = _particle.delay;
            _delayField.setMinValue(0);
            _delayField.addEventListener("value", {
                _particle.delay = _delayField.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_delayField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Quantité:", Atelier.theme.font));

            _quantityField = new IntegerField;
            _quantityField.value = _particle.quantity;
            _quantityField.setMinValue(0);
            _quantityField.addEventListener("value", {
                _particle.quantity = _quantityField.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_quantityField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Q.Variance:", Atelier.theme.font));

            _quantityVarianceField = new IntegerField;
            _quantityVarianceField.value = _particle.quantityVariance;
            _quantityVarianceField.setMinValue(0);
            _quantityVarianceField.addEventListener("value", {
                _particle.quantityVariance = _quantityVarianceField.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_quantityVarianceField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Taille X:", Atelier.theme.font));

            _sizeXField = new NumberField;
            _sizeXField.value = _particle.size.x;
            _sizeXField.setMinValue(0);
            _sizeXField.addEventListener("value", {
                _particle.size.x = _sizeXField.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_sizeXField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Taille Y:", Atelier.theme.font));

            _sizeYField = new NumberField;
            _sizeYField.value = _particle.size.y;
            _sizeYField.setMinValue(0);
            _sizeYField.addEventListener("value", {
                _particle.size.y = _sizeYField.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_sizeYField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Taille Z:", Atelier.theme.font));

            _sizeZField = new NumberField;
            _sizeZField.value = _particle.size.z;
            _sizeZField.setMinValue(0);
            _sizeZField.addEventListener("value", {
                _particle.size.z = _sizeZField.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_sizeZField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Distance:", Atelier.theme.font));

            _distanceField = new NumberField;
            _distanceField.value = _particle.distance;
            _distanceField.setMinValue(0);
            _distanceField.addEventListener("value", {
                _particle.distance = _distanceField.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_distanceField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("D.Variance:", Atelier.theme.font));

            _distanceVarianceField = new NumberField;
            _distanceVarianceField.value = _particle.distanceVariance;
            _distanceVarianceField.setMinValue(0);
            _distanceVarianceField.addEventListener("value", {
                _particle.distanceVariance = _distanceVarianceField.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_distanceVarianceField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Angle:", Atelier.theme.font));

            _angleField = new NumberField;
            _angleField.value = _particle.angle;
            _angleField.setMinValue(0);
            _angleField.addEventListener("value", {
                _particle.angle = _angleField.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_angleField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("A.Variance:", Atelier.theme.font));

            _angleVarianceField = new NumberField;
            _angleVarianceField.value = _particle.angleVariance;
            _angleVarianceField.setMinValue(0);
            _angleVarianceField.addEventListener("value", {
                _particle.angleVariance = _angleVarianceField.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_angleVarianceField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("A.Écart:", Atelier.theme.font));

            _angleSpreadField = new NumberField;
            _angleSpreadField.value = _particle.angleSpread;
            _angleSpreadField.setMinValue(0);
            _angleSpreadField.addEventListener("value", {
                _particle.angleSpread = _angleSpreadField.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_angleSpreadField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Événement:", Atelier.theme.font));

            _eventField = new TextField;
            _eventField.value = _particle.event;
            _eventField.addEventListener("value", {
                _particle.event = _eventField.value;
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_eventField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Calque:", Atelier.theme.font));

            _layerBtn = new SelectButton(asList!(Entity.Layer)(), _particle.layer);
            _layerBtn.setListAlign(UIAlignX.right, UIAlignY.bottom);
            _particle.layer = _layerBtn.value;
            _layerBtn.addEventListener("value", {
                _particle.layer = _layerBtn.value();
                dispatchEvent("property_particle", false);
            });
            hlayout.addUI(_layerBtn);
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });

        addEventListener("property_particle", &_onModeChange);

        _onModeChange();
    }

    private void _onModeChange() {
        switch (_particle.mode) {
        case "spread":
            _sizeXField.isEnabled = false;
            _sizeYField.isEnabled = false;
            _sizeZField.isEnabled = false;
            _distanceField.isEnabled = true;
            _distanceVarianceField.isEnabled = true;
            _angleField.isEnabled = true;
            _angleVarianceField.isEnabled = true;
            _angleSpreadField.isEnabled = true;
            break;
        case "rectangle":
        case "ellipsis":
            _sizeXField.isEnabled = true;
            _sizeYField.isEnabled = true;
            _sizeZField.isEnabled = true;
            _distanceField.isEnabled = false;
            _distanceVarianceField.isEnabled = false;
            _angleField.isEnabled = false;
            _angleVarianceField.isEnabled = false;
            _angleSpreadField.isEnabled = false;
            break;
        default:
            _sizeXField.isEnabled = false;
            _sizeYField.isEnabled = false;
            _sizeZField.isEnabled = false;
            _distanceField.isEnabled = false;
            _distanceVarianceField.isEnabled = false;
            _angleField.isEnabled = false;
            _angleVarianceField.isEnabled = false;
            _angleSpreadField.isEnabled = false;
            break;
        }
    }

    EntityRenderData[] getRenders() {
        RenderElement[] elements = cast(RenderElement[]) _renderList.getList();
        EntityRenderData[] renders;
        foreach (RenderElement elt; elements) {
            renders ~= elt.getData();
        }
        return renders;
    }

    HitboxData getHitbox() {
        return _hitbox;
    }

    ParticleData getParticle() {
        return _particle;
    }

    private void moveUp(RenderElement item_) {
        RenderElement[] elements = cast(RenderElement[]) _renderList.getList();
        _renderList.clearList();

        for (size_t i = 1; i < elements.length; ++i) {
            if (elements[i] == item_) {
                elements[i] = elements[i - 1];
                elements[i - 1] = item_;
                break;
            }
        }

        foreach (RenderElement element; elements) {
            _renderList.addList(element);
        }
    }

    private void moveDown(RenderElement item_) {
        RenderElement[] elements = cast(RenderElement[]) _renderList.getList();
        _renderList.clearList();

        for (size_t i = 0; (i + 1) < elements.length; ++i) {
            if (elements[i] == item_) {
                elements[i] = elements[i + 1];
                elements[i + 1] = item_;
                break;
            }
        }

        foreach (RenderElement element; elements) {
            _renderList.addList(element);
        }
    }
}

private final class RenderElement : UIElement {
    private {
        ParameterWindow _param;
        EntityRenderData _data;
        Label _nameLabel, _typeLabel;
        Rectangle _rect;
        HBox _hbox;
        IconButton _upBtn, _downBtn;
        Icon _icon, _checkmark;
    }

    this(ParameterWindow param, EntityRenderData data) {
        _param = param;
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
            _upBtn.addEventListener("click", { _param.moveUp(this); });
            _hbox.addUI(_upBtn);

            _downBtn = new IconButton("editor:arrow-small-down");
            _downBtn.addEventListener("click", { _param.moveDown(this); });
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
        EntityEditRenderData modal = new EntityEditRenderData(_data);
        modal.addEventListener("render.apply", {
            _data = modal.getData();
            if (modal.isDirty()) {
                dispatchEvent("render", false);
            }
            _updateDisplay();
            Atelier.ui.popModalUI();
        });
        modal.addEventListener("render.remove", {
            dispatchEvent("render", false);
            Atelier.ui.popModalUI();
            removeUI();
        });
        Atelier.ui.pushModalUI(modal);
    }

    EntityRenderData getData() {
        return _data;
    }
}
