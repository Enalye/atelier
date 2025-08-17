module atelier.etabli.media.res.entity_render.render_edit;

import std.array : split;
import std.conv : to, ConvException;
import atelier;
import atelier.etabli.ui;
import atelier.etabli.media.res.entity_render.render_data;

final class EntityEditRenderData : Modal {
    private {
        EntityRenderData _data;
        TextField _nameField;
        SelectButton _typeBtn, _layerBtn;
        RessourceButton _ridBtn;
        Checkbox _defaultBtn;
        bool _isDirty = false;
    }

    this(EntityRenderData data = null) {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(500f, 480f));

        bool isNew = false;
        if (data) {
            _data = data;
        }
        else {
            _data = new EntityRenderData;
            isNew = true;
        }

        if (isNew) {
            _isDirty = true;
        }

        {
            Label title = new Label(isNew ? "Nouveau Rendu" : "Éditer le Rendu",
                Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 4f));
            addUI(title);
        }

        {
            IconButton exitBtn = new IconButton("editor:exit");
            exitBtn.setAlign(UIAlignX.right, UIAlignY.top);
            exitBtn.setPosition(Vec2f(4f, 4f));
            exitBtn.addEventListener("click", &removeUI);
            addUI(exitBtn);
        }

        {
            HBox validationBox = new HBox;
            validationBox.setAlign(UIAlignX.right, UIAlignY.bottom);
            validationBox.setPosition(Vec2f(10f, 10f));
            validationBox.setSpacing(8f);
            addUI(validationBox);

            if (isNew) {
                NeutralButton cancelBtn = new NeutralButton("Annuler");
                cancelBtn.addEventListener("click", &removeUI);
                validationBox.addUI(cancelBtn);

                AccentButton createBtn = new AccentButton("Créer");
                createBtn.addEventListener("click", {
                    dispatchEvent("render.new", false);
                });
                validationBox.addUI(createBtn);
            }
            else {
                DangerButton removeBtn = new DangerButton("Supprimer");
                removeBtn.addEventListener("click", {
                    dispatchEvent("render.remove", false);
                });
                validationBox.addUI(removeBtn);

                NeutralButton cancelBtn = new NeutralButton("Annuler");
                cancelBtn.addEventListener("click", &removeUI);
                validationBox.addUI(cancelBtn);

                AccentButton applyBtn = new AccentButton("Appliquer");
                applyBtn.addEventListener("click", {
                    dispatchEvent("render.apply", false);
                });
                validationBox.addUI(applyBtn);
            }
        }

        VBox vbox;
        vbox = new VBox;
        vbox.setAlign(UIAlignX.left, UIAlignY.top);
        vbox.setChildAlign(UIAlignX.left);
        vbox.setSpacing(8f);
        vbox.setPosition(Vec2f(16f, 32f));
        addUI(vbox);

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Name:", Atelier.theme.font));

            _nameField = new TextField;
            _nameField.value = _data.name;
            _nameField.addEventListener("value", {
                _data.name = _nameField.value;
                _isDirty = true;
            });
            hlayout.addUI(_nameField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Valeur par défaut:", Atelier.theme.font));

            _defaultBtn = new Checkbox(_data.isDefault);
            _defaultBtn.addEventListener("value", {
                _data.isDefault = _defaultBtn.value();
                _isDirty = true;
            });
            hlayout.addUI(_defaultBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Type:", Atelier.theme.font));

            _typeBtn = new SelectButton([
                "sprite", "animation", "multidiranimation"
            ], _data.type);
            _data.type = _typeBtn.value;
            _typeBtn.addEventListener("value", {
                _data.type = _typeBtn.value();
                _ridBtn.setTypes([_data.type]);
                _isDirty = true;
            });
            hlayout.addUI(_typeBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("RID:", Atelier.theme.font));

            _ridBtn = new RessourceButton(_data.rid, _data.type, [_data.type]);
            _data.rid = _ridBtn.getName();
            _ridBtn.addEventListener("value", {
                _data.rid = _ridBtn.getName();
                _isDirty = true;
            });
            hlayout.addUI(_ridBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Ancre - x:", Atelier.theme.font));

            NumberField anchorXField = new NumberField;
            anchorXField.value = _data.anchor.x;
            anchorXField.setRange(0f, 1f);
            anchorXField.setStep(0.1f);
            anchorXField.addEventListener("value", {
                _data.anchor.x = anchorXField.value();
                _isDirty = true;
            });
            hlayout.addUI(anchorXField);

            hlayout.addUI(new Label("y:", Atelier.theme.font));

            NumberField anchorYField = new NumberField;
            anchorYField.value = _data.anchor.y;
            anchorYField.setRange(0f, 1f);
            anchorYField.setStep(0.1f);
            anchorYField.addEventListener("value", {
                _data.anchor.y = anchorYField.value();
                _isDirty = true;
            });
            hlayout.addUI(anchorYField);

            IconButton defaultBtn = new IconButton("editor:revert");
            defaultBtn.addEventListener("click", {
                _data.anchor.x = 0.5f;
                anchorXField.value(_data.anchor.x);
                _data.anchor.y = 1f;
                anchorYField.value(_data.anchor.y);
                _isDirty = true;
            });
            hlayout.addUI(defaultBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Pivot - x:", Atelier.theme.font));

            NumberField pivotXField = new NumberField;
            pivotXField.value = _data.pivot.x;
            pivotXField.setRange(0f, 1f);
            pivotXField.setStep(0.1f);
            pivotXField.addEventListener("value", {
                _data.pivot.x = pivotXField.value();
                _isDirty = true;
            });
            hlayout.addUI(pivotXField);

            hlayout.addUI(new Label("y:", Atelier.theme.font));

            NumberField pivotYField = new NumberField;
            pivotYField.value = _data.pivot.y;
            pivotYField.setRange(0f, 1f);
            pivotYField.setStep(0.1f);
            pivotYField.addEventListener("value", {
                _data.pivot.y = pivotYField.value();
                _isDirty = true;
            });
            hlayout.addUI(pivotYField);

            IconButton defaultBtn = new IconButton("editor:revert");
            defaultBtn.addEventListener("click", {
                _data.pivot.x = 0.5f;
                pivotXField.value(_data.pivot.x);
                _data.pivot.y = 1f;
                pivotYField.value(_data.pivot.y);
                _isDirty = true;
            });
            hlayout.addUI(defaultBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Position - x:", Atelier.theme.font));

            IntegerField offsetXField = new IntegerField;
            offsetXField.value = _data.offset.x;
            offsetXField.addEventListener("value", {
                _data.offset.x = offsetXField.value();
                _isDirty = true;
            });
            hlayout.addUI(offsetXField);

            hlayout.addUI(new Label("y:", Atelier.theme.font));

            IntegerField offsetYField = new IntegerField;
            offsetYField.value = _data.offset.y;
            offsetYField.addEventListener("value", {
                _data.offset.y = offsetYField.value();
                _isDirty = true;
            });
            hlayout.addUI(offsetYField);

            IconButton defaultBtn = new IconButton("editor:revert");
            defaultBtn.addEventListener("click", {
                _data.offset.x = 0;
                offsetXField.value(_data.offset.x);
                _data.offset.y = 0;
                offsetYField.value(_data.offset.y);
                _isDirty = true;
            });
            hlayout.addUI(defaultBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Tourne avec l'angle:", Atelier.theme.font));

            Checkbox isRotatingCheck = new Checkbox(_data.isRotating);
            isRotatingCheck.addEventListener("value", {
                _data.isRotating = isRotatingCheck.value;
                _isDirty = true;
            });
            hlayout.addUI(isRotatingCheck);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Angle:", Atelier.theme.font));

            IntegerField angleOffsetField = new IntegerField;
            angleOffsetField.value = _data.angleOffset;
            angleOffsetField.addEventListener("value", {
                _data.angleOffset = angleOffsetField.value();
                _isDirty = true;
            });
            hlayout.addUI(angleOffsetField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Rendu:", Atelier.theme.font));

            SelectButton blendBtn = new SelectButton([
                __traits(allMembers, Blend)
            ], to!string(_data.blend));
            try {
                _data.blend = to!Blend(blendBtn.value());
            }
            catch (Exception e) {
                _data.blend = Blend.alpha;
            }
            blendBtn.addEventListener("value", {
                try {
                    _data.blend = to!Blend(blendBtn.value());
                }
                catch (Exception e) {
                    _data.blend = Blend.alpha;
                }
                _isDirty = true;
            });
            hlayout.addUI(blendBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Derrière Aux.:", Atelier.theme.font));

            TextField isBehindField = new TextField();
            isBehindField.setAllowedCharacters(" 01");
            isBehindField.addEventListener("value", {
                _data.isBehind.length = 0;
                foreach (element; isBehindField.value.split(' ')) {
                    try {
                        _data.isBehind ~= to!uint(element);
                    }
                    catch (ConvException e) {
                    }
                }

                _isDirty = true;
            });
            hlayout.addUI(isBehindField);

            string value;
            foreach (i; _data.isBehind) {
                value ~= to!string(i) ~ " ";
            }
            isBehindField.value = value;
        }
    }

    EntityRenderData getData() {
        return _data;
    }

    bool isDirty() {
        return _isDirty;
    }
}
