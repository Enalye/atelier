module atelier.etabli.media.res.scene.entity.settings.trigger;

import atelier.common;
import atelier.ui;
import atelier.core;
import atelier.render;

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
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("Actif ?", Atelier.theme.font));

            Checkbox isActiveCheck = new Checkbox;
            isActiveCheck.value = _entity.trigger.isActive;
            isActiveCheck.addEventListener("value", {
                _entity.trigger.isActive = isActiveCheck.value;
                setDirty();
            });
            hlayout.addUI(isActiveCheck);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("Unique ?", Atelier.theme.font));

            Checkbox isActiveOnceCheck = new Checkbox;
            isActiveOnceCheck.value = _entity.trigger.isActiveOnce;
            isActiveOnceCheck.addEventListener("value", {
                _entity.trigger.isActiveOnce = isActiveOnceCheck.value;
                setDirty();
            });
            hlayout.addUI(isActiveOnceCheck);
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

            IntegerField colliderXField = new IntegerField;
            colliderXField.value = _entity.trigger.collider.x;
            colliderXField.addEventListener("value", {
                _entity.trigger.collider = Vec3i(colliderXField.value, _entity.trigger.collider.yz);
                setDirty();
            });
            hlayout.addUI(colliderXField);

            hlayout.addUI(new Label("y:", Atelier.theme.font));

            IntegerField colliderYField = new IntegerField;
            colliderYField.value = _entity.trigger.collider.y;
            colliderYField.addEventListener("value", {
                _entity.trigger.collider = Vec3i(_entity.trigger.collider.x, colliderYField.value, _entity
                    .trigger.collider.z);
                setDirty();
            });
            hlayout.addUI(colliderYField);

            hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("z:", Atelier.theme.font));

            IntegerField colliderZField = new IntegerField;
            colliderZField.value = _entity.trigger.collider.z;
            colliderZField.addEventListener("value", {
                _entity.trigger.collider = Vec3i(_entity.trigger.collider.xy, colliderZField.value);
                setDirty();
            });
            hlayout.addUI(colliderZField);
        }
    }
}
