module atelier.etabli.media.res.entity.data.collider;

mixin template ColliderDataEntityParameter() {
    import std.array : split, join;
    import std.conv : to;
    import std.format : format;

    import atelier.common;
    import atelier.core;
    import atelier.physics;
    import atelier.ui;
    import atelier.world;
    import atelier.etabli.ui;

    private {
        ColliderData _collider;
        SelectButton _typeSelect, _shapeBtn;
        IntegerField _collXField, _collYField, _collZField;
        NumberField _bouncinessField;
    }

    void setupEntityColliderParameters(VList vlist, ColliderData data) {
        _collider = data;

        {
            LabelSeparator sep = new LabelSeparator("Collision", Atelier
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

            hlayout.addUI(new Label("Type:", Atelier
                    .theme.font));

            _typeSelect = new SelectButton([
                __traits(allMembers, ColliderData.Type)
            ], to!string(_collider.type));
            _collider.type = asEnum!(ColliderData.Type)(_typeSelect.value, ColliderData.Type.none);
            _typeSelect.addEventListener("value", {
                _collider.type = asEnum!(ColliderData.Type)(_typeSelect.value, ColliderData
                    .Type.none);
                _updateFields();
                dispatchEvent("property_collider");
            });
            hlayout.addUI(_typeSelect);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("x:", Atelier.theme.font));

            _collXField = new IntegerField;
            _collXField.value = _collider.size.x;
            _collXField.setMinValue(0);
            _collXField.addEventListener("value", {
                _collider.size.x = _collXField.value;
                dispatchEvent("property_collider");
            });
            hlayout.addUI(_collXField);

            hlayout.addUI(new Label("y:", Atelier.theme.font));

            _collYField = new IntegerField;
            _collYField.value = _collider.size.y;
            _collYField.setMinValue(0);
            _collYField.addEventListener("value", {
                _collider.size.y = _collYField.value;
                dispatchEvent("property_collider");
            });
            hlayout.addUI(_collYField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("z:", Atelier.theme.font));

            _collZField = new IntegerField;
            _collZField.value = _collider.size.z;
            _collZField.setMinValue(0);
            _collZField.addEventListener("value", {
                _collider.size.z = _collZField.value;
                dispatchEvent("property_collider");
            });
            hlayout.addUI(_collZField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Forme:", Atelier
                    .theme.font));

            _shapeBtn = new SelectButton([
                __traits(allMembers, SolidCollider.Shape)
            ], _collider.shape);
            _collider.shape = _shapeBtn.value;
            _shapeBtn.addEventListener("value", {
                _collider.shape = _shapeBtn.value;
                dispatchEvent("property_collider");
            });
            hlayout.addUI(_shapeBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Rebond:", Atelier.theme.font));

            _bouncinessField = new NumberField;
            _bouncinessField.setMinValue(0f);
            _bouncinessField.value = _collider.bounciness;
            _bouncinessField.addEventListener("value", {
                _collider.bounciness = _bouncinessField.value;
                dispatchEvent("property_collider");
            });
            hlayout.addUI(_bouncinessField);
        }

        _updateFields();
    }

    private void _updateFields() {
        final switch (_collider.type) with (ColliderData.Type) {
        case actor:
            _collXField.isEnabled = true;
            _collYField.isEnabled = true;
            _collZField.isEnabled = true;
            _shapeBtn.isEnabled = false;
            _bouncinessField.isEnabled = true;
            break;
        case solid:
            _collXField.isEnabled = true;
            _collYField.isEnabled = true;
            _collZField.isEnabled = true;
            _shapeBtn.isEnabled = true;
            _bouncinessField.isEnabled = true;
            break;
        case none:
        case shot:
            _collXField.isEnabled = false;
            _collYField.isEnabled = false;
            _collZField.isEnabled = false;
            _shapeBtn.isEnabled = false;
            _bouncinessField.isEnabled = false;
            break;
        }
    }

    ColliderData getCollider() {
        return _collider;
    }
}
