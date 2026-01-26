module atelier.etabli.media.res.entity.data.hurtbox;

mixin template HurtboxDataEntityParameter() {
    import std.array : split, join;
    import std.format : format;

    import atelier.common;
    import atelier.core;
    import atelier.physics;
    import atelier.ui;
    import atelier.world;
    import atelier.etabli.ui;

    private {
        HurtboxData _hurtbox;
        CarouselButton _hurtLayerBtn;
        IntegerField _hurtMinRadiusField, _hurtMaxRadiusField, _hurtHeightField;
        IntegerField _hurtAngleField, _hurtAngleDeltaField;
        IntegerField _hurtOffsetDistanceField, _hurtOffsetAngleField;
    }

    void setupEntityHurtboxParameters(VList vlist, HurtboxData data) {
        _hurtbox = data;

        {
            LabelSeparator sep = new LabelSeparator("Dégats", Atelier
                    .theme.font);
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

            hlayout.addUI(new Label("Calque:", Atelier.theme.font));

            string[33] layers;
            layers[0] = "Aucun";
            for (uint i; i < 32; ++i) {
                layers[i + 1] = format("%d - \"%s\"",
                    i + 1,
                    Atelier.physics.getHurtboxLayer(i).name);
            }

            _hurtLayerBtn = new CarouselButton(layers, "");
            _hurtLayerBtn.ivalue = _hurtbox.hasHurtbox ? (_hurtbox.layer + 1) : 0;
            _hurtLayerBtn.addEventListener("value", {
                _hurtbox.hasHurtbox = _hurtLayerBtn.ivalue > 0;
                if (_hurtbox.hasHurtbox) {
                    _hurtbox.layer = _hurtLayerBtn.ivalue - 1;
                }
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtLayerBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rayon Min:", Atelier.theme.font));

            _hurtMinRadiusField = new IntegerField;
            _hurtMinRadiusField.value = _hurtbox.minRadius;
            _hurtMinRadiusField.isEnabled = _hurtbox.hasHurtbox;
            _hurtMinRadiusField.setMinValue(0);
            _hurtMinRadiusField.addEventListener("value", {
                _hurtbox.minRadius = _hurtMinRadiusField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtMinRadiusField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rayon Max:", Atelier
                    .theme.font));

            _hurtMaxRadiusField = new IntegerField;
            _hurtMaxRadiusField.value = _hurtbox.maxRadius;
            _hurtMaxRadiusField.isEnabled = _hurtbox.hasHurtbox;
            _hurtMaxRadiusField.setMinValue(0);
            _hurtMaxRadiusField.addEventListener("value", {
                _hurtbox.maxRadius = _hurtMaxRadiusField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtMaxRadiusField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Hauteur:", Atelier
                    .theme.font));

            _hurtHeightField = new IntegerField;
            _hurtHeightField.value = _hurtbox.height;
            _hurtHeightField.isEnabled = _hurtbox.hasHurtbox;
            _hurtHeightField.setMinValue(0);
            _hurtHeightField.addEventListener("value", {
                _hurtbox.height = _hurtHeightField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtHeightField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Orientation:", Atelier
                    .theme.font));

            _hurtAngleField = new IntegerField;
            _hurtAngleField.value = _hurtbox.angle;
            _hurtAngleField.isEnabled = _hurtbox.hasHurtbox;
            _hurtAngleField.setRange(0, 360);
            _hurtAngleField.addEventListener("value", {
                _hurtbox.angle = _hurtAngleField.value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtAngleField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Ouverture:", Atelier
                    .theme.font));

            _hurtAngleDeltaField = new IntegerField;
            _hurtAngleDeltaField.value = _hurtbox.angleDelta;
            _hurtAngleDeltaField.isEnabled = _hurtbox.hasHurtbox;
            _hurtAngleDeltaField.setRange(0, 180);
            _hurtAngleDeltaField.addEventListener("value", {
                _hurtbox.angleDelta = _hurtAngleDeltaField
                    .value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtAngleDeltaField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Décalage Distance:", Atelier
                    .theme.font));

            _hurtOffsetDistanceField = new IntegerField;
            _hurtOffsetDistanceField.value = _hurtbox
                .offsetDist;
            _hurtOffsetDistanceField.isEnabled = _hurtbox.hasHurtbox;
            _hurtOffsetDistanceField.addEventListener("value", {
                _hurtbox.offsetDist = _hurtOffsetDistanceField
                    .value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtOffsetDistanceField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Décalage Angle:", Atelier
                    .theme.font));

            _hurtOffsetAngleField = new IntegerField;
            _hurtOffsetAngleField.value = _hurtbox.offsetAngle;
            _hurtOffsetAngleField.isEnabled = _hurtbox.hasHurtbox;
            _hurtOffsetAngleField.addEventListener("value", {
                _hurtbox.offsetAngle = _hurtOffsetAngleField
                    .value;
                dispatchEvent("property_hurtbox");
            });
            hlayout.addUI(_hurtOffsetAngleField);
        }

        addEventListener("property_hurtbox", {
            bool isHurtboxEnabled = _hurtbox.hasHurtbox;
            _hurtMinRadiusField.isEnabled = isHurtboxEnabled;
            _hurtMaxRadiusField.isEnabled = isHurtboxEnabled;
            _hurtHeightField.isEnabled = isHurtboxEnabled;
            _hurtAngleField.isEnabled = isHurtboxEnabled;
            _hurtAngleDeltaField.isEnabled = isHurtboxEnabled;
            _hurtOffsetDistanceField.isEnabled = isHurtboxEnabled;
            _hurtOffsetAngleField.isEnabled = isHurtboxEnabled;
        });
    }

    HurtboxData getHurtbox() {
        return _hurtbox;
    }
}
