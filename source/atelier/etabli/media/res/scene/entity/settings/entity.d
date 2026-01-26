module atelier.etabli.media.res.scene.entity.settings.entity;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;
import atelier.etabli.media.res.scene.entity.settings.base;

package(atelier.etabli.media.res.scene) class EntitySettings : BaseEntitySettings {
    private {
        SelectButton _graphicBtn;
    }

    this(SceneDefinition.Entity entity) {
        super(entity, "Acteur");
    }

    override void loadProperties() {
        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("Acteur:", Atelier.theme.font));

            ResourceButton btn = new ResourceButton(_entity.entity.rid, "entity", [
                    "entity"
                ]);
            btn.addEventListener("value", {
                _entity.entity.rid = btn.getName();
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

            _graphicBtn = new SelectButton(_entity.entity.getGraphicList(), _entity.entity.graphic);
            _graphicBtn.addEventListener("value", {
                _entity.entity.graphic = _graphicBtn.value();
                setDirty();
            });
            hlayout.addUI(_graphicBtn);
        }

        {
            Knob dirKnob = new Knob;
            dirKnob.setSize(Vec2f(128f, 128f));
            dirKnob.setRange(0f, 360f);
            dirKnob.setAngleOffset(180f);
            dirKnob.value = _entity.entity.angle;
            dirKnob.addEventListener("value", {
                _entity.entity.angle = dirKnob.value;
                setDirty();
            });
            addProperty(dirKnob);
        }
    }

    private void _reloadGraphic() {
        _graphicBtn.setItems(_entity.entity.getGraphicList());
        _graphicBtn.value = _entity.entity.graphic;
    }
}
