module atelier.etabli.media.res.entity.data.hitbox;

mixin template HitboxDataEntityParameter() {
    import std.array : split, join;
    import std.format : format;

    import atelier.common;
    import atelier.core;
    import atelier.physics;
    import atelier.ui;
    import atelier.world;
    import atelier.etabli.ui;

    private {
        HitboxData _hitbox;
        CarouselButton _hitLayerBtn;
        IntegerField _hitMinRadiusField, _hitMaxRadiusField, _hitHeightField;
        IntegerField _hitAngleField, _hitAngleDeltaField;
        IntegerField _hitOffsetDistanceField, _hitOffsetAngleField;
    }

    void setupEntityHitboxParameters(VList vlist, HitboxData data) {
        _hitbox = data;

        {
            LabelSeparator sep = new LabelSeparator("Hitbox", Atelier
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
                    Atelier.physics.getHitboxLayer(i).name);
            }

            _hitLayerBtn = new CarouselButton(layers, "");
            _hitLayerBtn.ivalue = _hitbox.hasHitbox ? (_hitbox.layer + 1) : 0;
            _hitLayerBtn.addEventListener("value", {
                _hitbox.hasHitbox = _hitLayerBtn.ivalue > 0;
                if (_hitbox.hasHitbox) {
                    _hitbox.layer = _hitLayerBtn.ivalue - 1;
                }
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_hitLayerBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rayon Min:", Atelier.theme.font));

            _hitMinRadiusField = new IntegerField;
            _hitMinRadiusField.value = _hitbox.minRadius;
            _hitMinRadiusField.isEnabled = _hitbox.hasHitbox;
            _hitMinRadiusField.setMinValue(0);
            _hitMinRadiusField.addEventListener("value", {
                _hitbox.minRadius = _hitMinRadiusField.value;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_hitMinRadiusField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rayon Max:", Atelier
                    .theme.font));

            _hitMaxRadiusField = new IntegerField;
            _hitMaxRadiusField.value = _hitbox.maxRadius;
            _hitMaxRadiusField.isEnabled = _hitbox.hasHitbox;
            _hitMaxRadiusField.setMinValue(0);
            _hitMaxRadiusField.addEventListener("value", {
                _hitbox.maxRadius = _hitMaxRadiusField.value;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_hitMaxRadiusField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Hauteur:", Atelier
                    .theme.font));

            _hitHeightField = new IntegerField;
            _hitHeightField.value = _hitbox.height;
            _hitHeightField.isEnabled = _hitbox.hasHitbox;
            _hitHeightField.setMinValue(0);
            _hitHeightField.addEventListener("value", {
                _hitbox.height = _hitHeightField.value;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_hitHeightField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Orientation:", Atelier
                    .theme.font));

            _hitAngleField = new IntegerField;
            _hitAngleField.value = _hitbox.angle;
            _hitAngleField.isEnabled = _hitbox.hasHitbox;
            _hitAngleField.setRange(0, 360);
            _hitAngleField.addEventListener("value", {
                _hitbox.angle = _hitAngleField.value;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_hitAngleField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Ouverture:", Atelier
                    .theme.font));

            _hitAngleDeltaField = new IntegerField;
            _hitAngleDeltaField.value = _hitbox.angleDelta;
            _hitAngleDeltaField.isEnabled = _hitbox.hasHitbox;
            _hitAngleDeltaField.setRange(0, 180);
            _hitAngleDeltaField.addEventListener("value", {
                _hitbox.angleDelta = _hitAngleDeltaField
                    .value;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_hitAngleDeltaField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Décalage Distance:", Atelier
                    .theme.font));

            _hitOffsetDistanceField = new IntegerField;
            _hitOffsetDistanceField.value = _hitbox
                .offsetDist;
            _hitOffsetDistanceField.isEnabled = _hitbox.hasHitbox;
            _hitOffsetDistanceField.addEventListener("value", {
                _hitbox.offsetDist = _hitOffsetDistanceField
                    .value;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_hitOffsetDistanceField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Décalage Angle:", Atelier
                    .theme.font));

            _hitOffsetAngleField = new IntegerField;
            _hitOffsetAngleField.value = _hitbox.offsetAngle;
            _hitOffsetAngleField.isEnabled = _hitbox.hasHitbox;
            _hitOffsetAngleField.addEventListener("value", {
                _hitbox.offsetAngle = _hitOffsetAngleField
                    .value;
                dispatchEvent("property_hitbox");
            });
            hlayout.addUI(_hitOffsetAngleField);
        }

        addEventListener("property_hitbox", {
            bool isHitboxEnabled = _hitbox.hasHitbox;
            _hitMinRadiusField.isEnabled = isHitboxEnabled;
            _hitMaxRadiusField.isEnabled = isHitboxEnabled;
            _hitHeightField.isEnabled = isHitboxEnabled;
            _hitAngleField.isEnabled = isHitboxEnabled;
            _hitAngleDeltaField.isEnabled = isHitboxEnabled;
            _hitOffsetDistanceField.isEnabled = isHitboxEnabled;
            _hitOffsetAngleField.isEnabled = isHitboxEnabled;
        });
    }

    HitboxData getHitbox() {
        return _hitbox;
    }
}
