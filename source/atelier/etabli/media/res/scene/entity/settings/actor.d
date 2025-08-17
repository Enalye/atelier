module atelier.etabli.media.res.scene.entity.settings.actor;

import atelier;
import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;
import atelier.etabli.media.res.scene.entity.settings.base;

package(atelier.etabli.media.res.scene) class ActorSettings : BaseEntitySettings {
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

            RessourceButton btn = new RessourceButton(_entity.actor.rid, "actor", [
                    "actor"
                ]);
            btn.addEventListener("value", {
                _entity.actor.rid = btn.getName();
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

            _graphicBtn = new SelectButton(_entity.actor.getGraphicList(), _entity.actor.graphic);
            _graphicBtn.addEventListener("value", {
                _entity.actor.graphic = _graphicBtn.value();
                setDirty();
            });
            hlayout.addUI(_graphicBtn);
        }

        {
            Knob dirKnob = new Knob;
            dirKnob.setSize(Vec2f(128f, 128f));
            dirKnob.setRange(0f, 360f);
            dirKnob.value = _entity.actor.angle;
            dirKnob.addEventListener("value", {
                _entity.actor.angle = dirKnob.value;
                setDirty();
            });
            addProperty(dirKnob);
        }
    }

    private void _reloadGraphic() {
        _graphicBtn.setItems(_entity.actor.getGraphicList());
        _graphicBtn.value = _entity.actor.graphic;
    }
}
