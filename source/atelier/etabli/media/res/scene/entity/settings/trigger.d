module atelier.etabli.media.res.scene.entity.settings.trigger;

import atelier;
import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;
import atelier.etabli.media.res.scene.entity.settings.base;

package(atelier.etabli.media.res.scene) class TriggerSettings : BaseEntitySettings {
    private {
    }

    this(SceneDefinition.Entity entity) {
        super(entity, "Déclencheur");
    }

    override void loadProperties() {
        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("Événement:", Atelier.theme.font));

            TextField eventField = new TextField;
            eventField.value = _entity.trigger.event;
            eventField.addEventListener("value", {
                _entity.trigger.event = eventField.value;
                setDirty();
            });
            hlayout.addUI(eventField);
        }

        {
            LabelSeparator title = new LabelSeparator("Taille", Atelier.theme.font);
            title.setColor(Atelier.theme.neutral);
            title.setPadding(Vec2f(284f, 0f));
            title.setSpacing(8f);
            title.setLineWidth(1f);
            addProperty(title);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("x:", Atelier.theme.font));

            IntegerField hitboxXField = new IntegerField;
            hitboxXField.value = _entity.trigger.hitbox.x;
            hitboxXField.addEventListener("value", {
                _entity.trigger.hitbox = Vec3i(hitboxXField.value, _entity.trigger.hitbox.yz);
                setDirty();
            });
            hlayout.addUI(hitboxXField);

            hlayout.addUI(new Label("y:", Atelier.theme.font));

            IntegerField hitboxYField = new IntegerField;
            hitboxYField.value = _entity.trigger.hitbox.y;
            hitboxYField.addEventListener("value", {
                _entity.trigger.hitbox = Vec3i(_entity.trigger.hitbox.x, hitboxYField.value, _entity
                    .trigger.hitbox.z);
                setDirty();
            });
            hlayout.addUI(hitboxYField);

            hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("z:", Atelier.theme.font));

            IntegerField hitboxZField = new IntegerField;
            hitboxZField.value = _entity.trigger.hitbox.z;
            hitboxZField.addEventListener("value", {
                _entity.trigger.hitbox = Vec3i(_entity.trigger.hitbox.xy, hitboxZField.value);
                setDirty();
            });
            hlayout.addUI(hitboxZField);
        }
    }
}
