module atelier.etabli.media.res.scene.entity.settings.note;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;
import atelier.etabli.media.res.scene.entity.settings.base;

package(atelier.etabli.media.res.scene) class NoteSettings : BaseEntitySettings {
    private {
    }

    this(SceneDefinition.Entity entity) {
        super(entity, "Note");
    }

    override void loadProperties() {
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

            IntegerField sizeXField = new IntegerField;
            sizeXField.value = _entity.note.size.x;
            sizeXField.addEventListener("value", {
                _entity.note.size = Vec2i(sizeXField.value, _entity.note.size.y);
                setDirty();
            });
            hlayout.addUI(sizeXField);

            hlayout.addUI(new Label("y:", Atelier.theme.font));

            IntegerField sizeYField = new IntegerField;
            sizeYField.value = _entity.note.size.y;
            sizeYField.addEventListener("value", {
                _entity.note.size = Vec2i(_entity.note.size.x, sizeYField.value);
                setDirty();
            });
            hlayout.addUI(sizeYField);
        }
    }
}
