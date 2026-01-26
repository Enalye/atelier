module atelier.etabli.media.res.entity.parameter;

import std.array : split, join;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.ui;
import atelier.render;
import atelier.world.entity : BaseEntityData;
import atelier.etabli.ui;
import atelier.etabli.media.res.entity.data;

package final class ParameterWindow : UIElement {
    private {
        // Repulsor
        RepulsorData _repulsor;
        SelectButton _repulsorTypeBtn;
        IntegerField _repulsorRadiusField, _repulsorHeightField;
    }

    mixin GraphicDataEntityParameter;
    mixin BaseDataEntityParameter;
    mixin ColliderDataEntityParameter;
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

        setupEntityGraphicsParameters(vlist, graphics, auxGraphics);
        setupEntityBaseParameters(vlist, baseEntityData);
        setupEntityColliderParameters(vlist, hitbox);
        setupEntityHurtboxParameters(vlist, hurtbox);

        {
            LabelSeparator sep = new LabelSeparator("Répulsion", Atelier.theme.font);
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

    RepulsorData getRepulsor() {
        return _repulsor;
    }
}
