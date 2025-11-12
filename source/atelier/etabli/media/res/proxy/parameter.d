module atelier.etabli.media.res.proxy.parameter;

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

package final class ParameterWindow : UIElement {
    private {
        // Hurtbox
        HurtboxData _hurtbox;
        SelectButton _hurtTypeBtn, _hurtFactionBtn;
        IntegerField _hurtMinRadiusField, _hurtMaxRadiusField, _hurtHeightField;
        IntegerField _hurtAngleField, _hurtAngleDeltaField;
        IntegerField _hurtOffsetDistanceField, _hurtOffsetAngleField;
    }

    mixin GraphicDataEntityParameter;
    mixin BaseDataEntityParameter;

    this(EntityRenderData[] graphics, EntityRenderData[] auxGraphics, BaseEntityData baseEntityData, HurtboxData hurtbox_) {
        VList vlist = new VList;
        vlist.setPosition(Vec2f(8f, 8f));
        vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        vlist.setAlign(UIAlignX.left, UIAlignY.top);
        vlist.setColor(Atelier.theme.surface);
        vlist.setSpacing(8f);
        vlist.setChildAlign(UIAlignX.left);
        addUI(vlist);

        _hurtbox = hurtbox_;

        setupEntityGraphicsParameters(vlist, graphics, auxGraphics);
        setupEntityBaseParameters(vlist, baseEntityData);

        {
            LabelSeparator sep = new LabelSeparator("Dégats", Atelier.theme.font);
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

            hlayout.addUI(new Label("Faction:", Atelier.theme.font));

            string[] hurtFactions = "none" ~ [
                __traits(allMembers, Hurtbox.Faction)
            ];
            _hurtFactionBtn = new SelectButton(hurtFactions, _hurtbox.faction);
            _hurtFactionBtn.addEventListener("value", {
                _hurtbox.faction = _hurtFactionBtn.value;
                dispatchEvent("property_hurtbox", false);
            });
            hlayout.addUI(_hurtFactionBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Type:", Atelier.theme.font));

            string[] hurtTypes = "none" ~ [__traits(allMembers, Hurtbox.Type)];
            _hurtTypeBtn = new SelectButton(hurtTypes, _hurtbox.type);
            _hurtTypeBtn.addEventListener("value", {
                _hurtbox.type = _hurtTypeBtn.value;
                dispatchEvent("property_hurtbox", false);
            });
            hlayout.addUI(_hurtTypeBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rayon Min:", Atelier.theme.font));

            _hurtMinRadiusField = new IntegerField;
            _hurtMinRadiusField.value = _hurtbox.minRadius;
            _hurtMinRadiusField.isEnabled = (_hurtbox.type != "none");
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

            hlayout.addUI(new Label("Rayon Max:", Atelier.theme.font));

            _hurtMaxRadiusField = new IntegerField;
            _hurtMaxRadiusField.value = _hurtbox.maxRadius;
            _hurtMaxRadiusField.isEnabled = (_hurtbox.type != "none");
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

            hlayout.addUI(new Label("Hauteur:", Atelier.theme.font));

            _hurtHeightField = new IntegerField;
            _hurtHeightField.value = _hurtbox.height;
            _hurtHeightField.isEnabled = (_hurtbox.type != "none");
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

            hlayout.addUI(new Label("Orientation:", Atelier.theme.font));

            _hurtAngleField = new IntegerField;
            _hurtAngleField.value = _hurtbox.angle;
            _hurtAngleField.isEnabled = (_hurtbox.type != "none");
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

            hlayout.addUI(new Label("Ouverture:", Atelier.theme.font));

            _hurtAngleDeltaField = new IntegerField;
            _hurtAngleDeltaField.value = _hurtbox.angleDelta;
            _hurtAngleDeltaField.isEnabled = (_hurtbox.type != "none");
            _hurtAngleDeltaField.setRange(0, 180);
            _hurtAngleDeltaField.addEventListener("value", {
                _hurtbox.angleDelta = _hurtAngleDeltaField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtAngleDeltaField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Décalage Distance:", Atelier.theme.font));

            _hurtOffsetDistanceField = new IntegerField;
            _hurtOffsetDistanceField.value = _hurtbox.offsetDist;
            _hurtOffsetDistanceField.isEnabled = (_hurtbox.type != "none");
            _hurtOffsetDistanceField.addEventListener("value", {
                _hurtbox.offsetDist = _hurtOffsetDistanceField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtOffsetDistanceField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Décalage Angle:", Atelier.theme.font));

            _hurtOffsetAngleField = new IntegerField;
            _hurtOffsetAngleField.value = _hurtbox.offsetAngle;
            _hurtOffsetAngleField.isEnabled = (_hurtbox.type != "none");
            _hurtOffsetAngleField.addEventListener("value", {
                _hurtbox.offsetAngle = _hurtOffsetAngleField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtOffsetAngleField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Bouge ?", Atelier.theme.font));
            hlayout.addUI(new Checkbox());
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });

        addEventListener("property_hurtbox", {
            bool isHurtboxEnabled = (_hurtbox.type != "none");
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
