module atelier.etabli.media.res.scene.entity.settings.teleporter;

import atelier;
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

            RessourceButton btn = new RessourceButton(_entity.teleporter.scene, "scene", [
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

            hlayout.addUI(new Label("x:", Atelier.theme.font));

            IntegerField hitboxXField = new IntegerField;
            hitboxXField.value = _entity.teleporter.hitbox.x;
            hitboxXField.addEventListener("value", {
                _entity.teleporter.hitbox = Vec3i(hitboxXField.value, _entity.teleporter.hitbox.yz);
                setDirty();
            });
            hlayout.addUI(hitboxXField);

            hlayout.addUI(new Label("y:", Atelier.theme.font));

            IntegerField hitboxYField = new IntegerField;
            hitboxYField.value = _entity.teleporter.hitbox.y;
            hitboxYField.addEventListener("value", {
                _entity.teleporter.hitbox = Vec3i(_entity.teleporter.hitbox.x, hitboxYField.value, _entity
                    .teleporter.hitbox.z);
                setDirty();
            });
            hlayout.addUI(hitboxYField);

            hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("z:", Atelier.theme.font));

            IntegerField hitboxZField = new IntegerField;
            hitboxZField.value = _entity.teleporter.hitbox.z;
            hitboxZField.addEventListener("value", {
                _entity.teleporter.hitbox = Vec3i(_entity.teleporter.hitbox.xy, hitboxZField.value);
                setDirty();
            });
            hlayout.addUI(hitboxZField);
        }
    }
}
