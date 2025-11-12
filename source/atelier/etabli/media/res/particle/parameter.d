module atelier.etabli.media.res.particle.parameter;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;
import atelier.world;
import atelier.etabli.ui;
import atelier.etabli.media.res.entity_base;

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

    mixin GraphicDataEntityParameter;
    mixin BaseDataEntityParameter;

    this(EntityRenderData[] graphics, EntityRenderData[] auxGraphics, BaseEntityData baseEntityData, HitboxData hitbox, ParticleData particle) {
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

        setupEntityGraphicsParameters(vlist, graphics, auxGraphics);
        setupEntityBaseParameters(vlist, baseEntityData);

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

    HitboxData getHitbox() {
        return _hitbox;
    }

    ParticleData getParticle() {
        return _particle;
    }
}
