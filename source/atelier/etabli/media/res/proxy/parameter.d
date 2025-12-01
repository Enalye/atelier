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
    mixin GraphicDataEntityParameter;
    mixin BaseDataEntityParameter;
    mixin HurtboxDataEntityParameter;

    this(EntityRenderData[] graphics, EntityRenderData[] auxGraphics, BaseEntityData baseEntityData, HurtboxData hurtbox) {
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
        setupEntityHurtboxParameters(vlist, hurtbox);

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
    }
}
