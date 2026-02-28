module atelier.etabli.media.res.scene.entity.settings.teleporter;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;
import atelier.etabli.media.res.scene.entity.settings.base;

package(atelier.etabli.media.res.scene) class TeleporterSettings : BaseEntitySettings {
    private {
    }

    this(SceneDefinition.Entity entity) {
        super(entity, "Téléporteur");
    }

    override void loadProperties() {
        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("Scène:", Atelier.theme.font));

            ResourceButton btn = new ResourceButton(_entity.teleporter.scene, "scene", [
                    "scene"
                ]);
            btn.addEventListener("value", {
                _entity.teleporter.scene = btn.getName();
                setDirty();
            });
            hlayout.addUI(btn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("Cible:", Atelier.theme.font));

            TextField destField = new TextField;
            destField.value = _entity.teleporter.target;
            destField.addEventListener("value", {
                _entity.teleporter.target = destField.value;
                setDirty();
            });
            hlayout.addUI(destField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("Direction:", Atelier.theme.font));

            SelectButton btn = new SelectButton([
                "Nord", "Nord-Ouest", "Ouest", "Sud-Ouest", "Sud", "Sud-Est",
                "Est", "Nord-Est"
            ], "Nord");
            btn.ivalue = _entity.teleporter.direction;
            btn.addEventListener("value", {
                _entity.teleporter.direction = btn.ivalue();
                setDirty();
            });
            hlayout.addUI(btn);
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

            hlayout.addUI(new Label("Actif ?", Atelier.theme.font));

            Checkbox isActiveCheck = new Checkbox;
            isActiveCheck.value = _entity.teleporter.isActive;
            isActiveCheck.addEventListener("value", {
                _entity.teleporter.isActive = isActiveCheck.value;
                setDirty();
            });
            hlayout.addUI(isActiveCheck);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("x:", Atelier.theme.font));

            IntegerField colliderXField = new IntegerField;
            colliderXField.value = _entity.teleporter.collider.x;
            colliderXField.addEventListener("value", {
                _entity.teleporter.collider = Vec3i(colliderXField.value, _entity
                    .teleporter.collider.yz);
                setDirty();
            });
            hlayout.addUI(colliderXField);

            hlayout.addUI(new Label("y:", Atelier.theme.font));

            IntegerField colliderYField = new IntegerField;
            colliderYField.value = _entity.teleporter.collider.y;
            colliderYField.addEventListener("value", {
                _entity.teleporter.collider = Vec3i(_entity.teleporter.collider.x, colliderYField.value, _entity
                    .teleporter.collider.z);
                setDirty();
            });
            hlayout.addUI(colliderYField);

            hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("z:", Atelier.theme.font));

            IntegerField colliderZField = new IntegerField;
            colliderZField.value = _entity.teleporter.collider.z;
            colliderZField.addEventListener("value", {
                _entity.teleporter.collider = Vec3i(_entity.teleporter.collider.xy, colliderZField
                    .value);
                setDirty();
            });
            hlayout.addUI(colliderZField);
        }
    }
}
