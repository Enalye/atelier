module atelier.etabli.media.res.scene.entity.settings.base;

import std.array : split, join;
import atelier;
import atelier.etabli.ui;
import atelier.etabli.media.res.scene.common;

package(atelier.etabli.media.res.scene) abstract class BaseEntitySettings : UIElement {
    protected {
        VBox _vbox;
        SceneDefinition.Entity _entity;
        SelectButton _graphicBtn;
        TextField _nameField;
        TextField _tagsField;
        IntegerField _posXField, _posYField, _posZField;
        SelectButton _layerBtn;
    }

    this(SceneDefinition.Entity entity, string titleName) {
        _entity = entity;
        setSize(Vec2f(284f, 448f));
        setAlign(UIAlignX.left, UIAlignY.top);

        _vbox = new VBox;
        _vbox.setAlign(UIAlignX.left, UIAlignY.top);
        _vbox.setSpacing(8f);
        _vbox.setChildAlign(UIAlignX.center);
        addUI(_vbox);

        {
            LabelSeparator title = new LabelSeparator(titleName, Atelier.theme.font);
            title.setColor(Atelier.theme.neutral);
            title.setPadding(Vec2f(284f, 0f));
            title.setSpacing(8f);
            title.setLineWidth(1f);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 8f));
            addProperty(title);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("Nom:", Atelier.theme.font));

            _nameField = new TextField;
            _nameField.value = _entity.entityData.name;
            _nameField.addEventListener("value", {
                _entity.entityData.name = _nameField.value;
                setDirty();
            });
            hlayout.addUI(_nameField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("Tags:", Atelier.theme.font));

            _tagsField = new TextField;
            _tagsField.value = _entity.entityData.tags.join(' ');
            _tagsField.addEventListener("value", {
                _entity.entityData.tags.length = 0;
                foreach (element; _tagsField.value.split(' ')) {
                    _entity.entityData.tags ~= element;
                }
                setDirty();
            });
            hlayout.addUI(_tagsField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("x:", Atelier.theme.font));

            _posXField = new IntegerField;
            _posXField.value = _entity.entityData.position.x;
            _posXField.addEventListener("value", {
                _entity.entityData.position = Vec3i(_posXField.value, _entity
                    .entityData.position.yz);
                setDirty();
            });
            hlayout.addUI(_posXField);

            hlayout.addUI(new Label("y:", Atelier.theme.font));

            _posYField = new IntegerField;
            _posYField.value = _entity.entityData.position.y;
            _posYField.addEventListener("value", {
                _entity.entityData.position = Vec3i(_entity.entityData.position.x, _posYField.value, _entity
                    .entityData.position.z);
                setDirty();
            });
            hlayout.addUI(_posYField);

            hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("z:", Atelier.theme.font));

            _posZField = new IntegerField;
            _posZField.value = _entity.entityData.position.z;
            _posZField.addEventListener("value", {
                _entity.entityData.position = Vec3i(_entity.entityData.position.xy, _posZField
                    .value);
                setDirty();
            });
            hlayout.addUI(_posZField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            addProperty(hlayout);

            hlayout.addUI(new Label("Calque:", Atelier.theme.font));

            _layerBtn = new SelectButton(asList!(Entity.Layer)(), _entity.entityData.layer);
            _layerBtn.setListAlign(UIAlignX.right, UIAlignY.top);
            _entity.entityData.layer = _layerBtn.value;
            _layerBtn.addEventListener("value", {
                _entity.entityData.layer = _layerBtn.value();
                setDirty();
            });
            hlayout.addUI(_layerBtn);
        }

        loadProperties();

        {
            DangerButton btn = new DangerButton("Supprimer");
            btn.addEventListener("click", {
                dispatchEvent("entity_remove", false);
            });
            addProperty(btn);
        }

        addEventListener("entity_update", &_updateEntity);
    }

    private void _updateEntity() {
        _posXField.value = _entity.tempPosition.x;
        _posYField.value = _entity.tempPosition.y;
        _posZField.value = _entity.tempPosition.z;
        setDirty();
    }

    abstract void loadProperties();

    final void addProperty(UIElement element) {
        _vbox.addUI(element);
    }

    final void setDirty() {
        dispatchEvent("property_dirty", false);
    }
}
