module atelier.etabli.media.res.entity.data.base;

mixin template BaseDataEntityParameter() {
    import std.array : split, join;

    import atelier.common;
    import atelier.core;
    import atelier.ui;
    import atelier.world;
    import atelier.etabli.ui;

    private {
        BaseEntityData _baseEntityData;
    }

    void setupEntityBaseParameters(VList vlist, BaseEntityData data) {
        _baseEntityData = data;

        {
            LabelSeparator sep = new LabelSeparator("Propriétés", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Contrôleur:", Atelier.theme.font));

            TextField controllerField = new TextField;
            controllerField.value = _baseEntityData.controller;
            controllerField.addEventListener("value", {
                _baseEntityData.controller = controllerField.value;
                dispatchEvent("property_base");
            });
            hlayout.addUI(controllerField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Comportement:", Atelier.theme.font));

            TextField behaviorField = new TextField;
            behaviorField.value = _baseEntityData.behavior;
            behaviorField.addEventListener("value", {
                _baseEntityData.behavior = behaviorField.value;
                dispatchEvent("property_base");
            });
            hlayout.addUI(behaviorField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Ombre:", Atelier.theme.font));

            ResourceButton shadowField = new ResourceButton(_baseEntityData.shadow, "shadow",
                ["shadow"], true);
            if (_baseEntityData.shadow != shadowField.getName()) {
                _baseEntityData.shadow = shadowField.getName();
                dispatchEvent("property_base");
            }
            shadowField.addEventListener("value", {
                _baseEntityData.shadow = shadowField.getName();
                dispatchEvent("property_base");
            });
            hlayout.addUI(shadowField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Ordre Z:", Atelier.theme.font));

            IntegerField zOrderOffsetField = new IntegerField;
            zOrderOffsetField.value = _baseEntityData.zOrderOffset;
            zOrderOffsetField.addEventListener("value", {
                _baseEntityData.zOrderOffset = zOrderOffsetField.value;
                dispatchEvent("property_base");
            });
            hlayout.addUI(zOrderOffsetField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Tags:", Atelier.theme.font));

            TextField tagsField = new TextField;
            tagsField.value = _baseEntityData.tags.join(' ');
            tagsField.addEventListener("value", {
                _baseEntityData.tags.length = 0;
                foreach (element; tagsField.value.split(' ')) {
                    _baseEntityData.tags ~= element;
                }
                dispatchEvent("property_base");
            });
            hlayout.addUI(tagsField);
        }
    }

    BaseEntityData getBaseEntityData() {
        return _baseEntityData;
    }
}
