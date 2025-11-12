module atelier.etabli.media.res.scene.entity.settings.prop;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;
import atelier.etabli.media.res.scene.entity.settings.base;

package(atelier.etabli.media.res.scene) class PropSettings : BaseEntitySettings {
    private {
        SelectButton _graphicBtn;
    }

    this(SceneDefinition.Entity entity) {
        super(entity, "Décors");
    }

    private void _reloadGraphic() {
        _graphicBtn.setItems(_entity.prop.getGraphicList());
        _graphicBtn.value = _entity.prop.graphic;
    }

    override void loadProperties() {
        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("Prop:", Atelier.theme.font));

            ResourceButton btn = new ResourceButton(_entity.prop.rid, "prop", [
                    "prop"
                ]);
            btn.addEventListener("value", {
                _entity.prop.rid = btn.getName();
                _reloadGraphic();
                setDirty();
            });
            hlayout.addUI(btn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("Graphique:", Atelier.theme.font));

            _graphicBtn = new SelectButton(_entity.prop.getGraphicList(), _entity.prop.graphic);
            _graphicBtn.addEventListener("value", {
                _entity.prop.graphic = _graphicBtn.value();
                setDirty();
            });
            hlayout.addUI(_graphicBtn);
        }

        {
            Knob dirKnob = new Knob;
            dirKnob.setSize(Vec2f(128f, 128f));
            dirKnob.setRange(0f, 360f);
            dirKnob.setAngleOffset(180f);
            dirKnob.value = _entity.prop.angle;
            dirKnob.addEventListener("value", {
                _entity.prop.angle = dirKnob.value;
                setDirty();
            });
            addProperty(dirKnob);
        }
    }
}
