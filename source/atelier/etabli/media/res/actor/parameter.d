module atelier.etabli.media.res.actor.parameter;

import std.array : split, join;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.ui;
import atelier.render;
import atelier.world.entity : BaseEntityData;
import atelier.etabli.ui;
import atelier.etabli.media.res.entity_base;

package struct HitboxData {
    bool hasHitbox = false;
    Vec3u size = Vec3u.zero;
    float bounciness = 0f;

    void load(Farfadet ffd) {
        hasHitbox = true;
        if (ffd.hasNode("size")) {
            size = ffd.getNode("size").get!Vec3u(0);
        }
        else {
            size = Vec3u.zero;
        }

        if (ffd.hasNode("bounciness")) {
            bounciness = ffd.getNode("bounciness").get!float(0);
        }
        else {
            bounciness = 0f;
        }
    }

    void save(Farfadet ffd) {
        Farfadet node = ffd.addNode("hitbox");
        node.addNode("size").add(size);
        node.addNode("bounciness").add(bounciness);
    }
}

package final class ParameterWindow : UIElement {
    private {
        // Hitbox
        HitboxData _hitbox;
        Checkbox _hasHitboxCheck;
        IntegerField _collXField, _collYField, _collZField;
        NumberField _bouncinessField;

        // Repulsor
        RepulsorData _repulsor;
        SelectButton _repulsorTypeBtn;
        IntegerField _repulsorRadiusField, _repulsorHeightField;
    }

    mixin GraphicDataEntityParameter;
    mixin BaseDataEntityParameter;
    mixin HurtboxDataEntityParameter;

    this(EntityRenderData[] graphics, EntityRenderData[] auxGraphics, HitboxData hitbox, RepulsorData repulsor, HurtboxData hurtbox, BaseEntityData baseEntityData) {
        VList vlist = new VList;
        vlist.setPosition(Vec2f(8f, 8f));
        vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        vlist.setAlign(UIAlignX.left, UIAlignY.top);
        vlist.setColor(Atelier.theme.surface);
        vlist.setSpacing(8f);
        vlist.setChildAlign(UIAlignX.left);
        addUI(vlist);

        _hitbox = hitbox;
        _hurtbox = hurtbox;

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

            _hasHitboxCheck = new Checkbox(_hitbox.hasHitbox);
            _hasHitboxCheck.addEventListener("value", {
                _hitbox.hasHitbox = _hasHitboxCheck.value;
                _collXField.isEnabled = _hitbox.hasHitbox;
                _collYField.isEnabled = _hitbox.hasHitbox;
                _collZField.isEnabled = _hitbox.hasHitbox;
                _bouncinessField.isEnabled = _hitbox.hasHitbox;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_hasHitboxCheck);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("x:", Atelier.theme.font));

            _collXField = new IntegerField;
            _collXField.value = hitbox.size.x;
            _collXField.setMinValue(0);
            _collXField.isEnabled = _hitbox.hasHitbox;
            _collXField.addEventListener("value", {
                _hitbox.size.x = _collXField.value;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_collXField);

            hlayout.addUI(new Label("y:", Atelier.theme.font));

            _collYField = new IntegerField;
            _collYField.value = hitbox.size.y;
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
            _collZField.value = hitbox.size.z;
            _collZField.setMinValue(0);
            _collZField.isEnabled = _hitbox.hasHitbox;
            _collZField.addEventListener("value", {
                _hitbox.size.z = _collZField.value;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_collZField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rebond:", Atelier.theme.font));

            _bouncinessField = new NumberField;
            _bouncinessField.setMinValue(0f);
            _bouncinessField.value = _hitbox.bounciness;
            _bouncinessField.isEnabled = _hitbox.hasHitbox;
            _bouncinessField.addEventListener("value", {
                _hitbox.bounciness = _bouncinessField.value;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_bouncinessField);
        }

        setupEntityHurtboxParameters(vlist, hurtbox);

        {
            LabelSeparator sep = new LabelSeparator("Répulsion Acteur/Acteur", Atelier.theme.font);
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

            hlayout.addUI(new Label("Type", Atelier.theme.font));

            string[] repulsorTypes = "none" ~ [
                __traits(allMembers, Repulsor.Type)
            ];
            _repulsorTypeBtn = new SelectButton(repulsorTypes, _repulsor.type);
            _repulsorTypeBtn.addEventListener("value", {
                _repulsor.type = _repulsorTypeBtn.value;
                dispatchEvent("property_repulsor", false);
            });
            hlayout.addUI(_repulsorTypeBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rayon:", Atelier.theme.font));

            _repulsorRadiusField = new IntegerField;
            _repulsorRadiusField.value = _repulsor.radius;
            _repulsorRadiusField.isEnabled = (_repulsor.type != "none");
            _repulsorRadiusField.setMinValue(0);
            _repulsorRadiusField.addEventListener("value", {
                _repulsor.radius = _repulsorRadiusField.value;
                dispatchEvent("property_repulsor");
            });
            hlayout.addUI(_repulsorRadiusField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Hauteur:", Atelier.theme.font));

            _repulsorHeightField = new IntegerField;
            _repulsorHeightField.value = _repulsor.height;
            _repulsorHeightField.isEnabled = (_repulsor.type != "none");
            _repulsorHeightField.setMinValue(0);
            _repulsorHeightField.addEventListener("value", {
                _repulsor.height = _repulsorHeightField.value;
                dispatchEvent("property_repulsor");
            });
            hlayout.addUI(_repulsorHeightField);
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });

        addEventListener("property_repulsor", {
            bool isRepulsorEnabled = (_repulsor.type != "none");
            _repulsorRadiusField.isEnabled = isRepulsorEnabled;
            _repulsorHeightField.isEnabled = isRepulsorEnabled;
        });
    }

    HitboxData getHitbox() {
        return _hitbox;
    }

    RepulsorData getRepulsor() {
        return _repulsor;
    }
}
