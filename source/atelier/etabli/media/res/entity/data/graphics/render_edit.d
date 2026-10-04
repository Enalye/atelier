module atelier.etabli.media.res.entity.data.graphics.render_edit;

import std.algorithm.sorting : sort;
import std.array : split, join;
import std.conv : to, ConvException;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;
import atelier.etabli.ui;
import atelier.etabli.media.res.entity.data.graphics.render_data;

final class EntityEditGraphicData : Modal {
    private {
        EntityRenderData _data;
        TextField _nameField;
        SelectButton _typeBtn, _layerBtn;
        ResourceButton _ridBtn;
        VList _auxGraphicList;
        Checkbox _defaultBtn;
        bool _isDirty = false;
        EntityRenderData[] _auxGraphics;
    }

    this(EntityRenderData data, bool isAuxGraphic, EntityRenderData[] auxGraphics) {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(432f, 720f));

        _auxGraphics = auxGraphics;

        bool isNew = false;
        if (data) {
            _data = data;
        }
        else {
            _data = new EntityRenderData(isAuxGraphic);
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

            hlayout.addUI(new Label("Nom:", Atelier.theme.font));

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

            _ridBtn = new ResourceButton(_data.rid, _data.type, [_data.type]);
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
            }
            );
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

        if (_data.isAuxGraphic) {
            {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(400f, 0f));
                vbox.addUI(hlayout);

                hlayout.addUI(new Label("Derrière Auxiliaire:", Atelier.theme.font));

                TextField isBehindField = new TextField();
                isBehindField.setAllowedCharacters(" 01");
                isBehindField.addEventListener("value", {
                    _data.isBehind.length = 0;
                    foreach (element; isBehindField.value.split(
                        ' ')) {
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

            {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(400f, 0f));
                vbox.addUI(hlayout);

                hlayout.addUI(new Label("Ordre:", Atelier.theme.font));

                IntegerField orderField = new IntegerField;
                orderField.value = _data.order;
                orderField.addEventListener("value", {
                    _data.order = orderField.value();
                    _isDirty = true;
                });
                hlayout.addUI(orderField);
            }

            {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(400f, 0f));
                vbox.addUI(hlayout);

                hlayout.addUI(new Label("Emplacement:", Atelier.theme.font));

                IntegerField slotField = new IntegerField;
                slotField.setMinValue(0);
                slotField.value = _data.slot;
                slotField.addEventListener("value", {
                    _data.slot = slotField.value();
                    _isDirty = true;
                });
                hlayout.addUI(slotField);
            }
        }
        else {
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

                hlayout.addUI(new Label("Marge VFX - x:", Atelier.theme.font));

                IntegerField offsetXField = new IntegerField;
                offsetXField.value = _data.effectMargin.x;
                offsetXField.addEventListener("value", {
                    _data.effectMargin.x = offsetXField.value();
                    _isDirty = true;
                });
                hlayout.addUI(offsetXField);

                hlayout.addUI(new Label("y:", Atelier.theme.font));

                IntegerField offsetYField = new IntegerField;
                offsetYField.value = _data.effectMargin.y;
                offsetYField.addEventListener("value", {
                    _data.effectMargin.y = offsetYField.value();
                    _isDirty = true;
                });
                hlayout.addUI(offsetYField);

                IconButton defaultBtn = new IconButton("editor:revert");
                defaultBtn.addEventListener("click", {
                    _data.effectMargin.x = 0;
                    offsetXField.value(_data.effectMargin.x);
                    _data.effectMargin.y = 0;
                    offsetYField.value(_data.effectMargin.y);
                    _isDirty = true;
                });
                hlayout.addUI(defaultBtn);
            }

            {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(400f, 0f));
                vbox.addUI(hlayout);

                hlayout.addUI(new Label("Rendus Auxiliaires:", Atelier.theme.font));

                _auxGraphicList = new VList;
                _auxGraphicList.setSize(Vec2f(400f, 200f));

                AccentButton addBtn = new AccentButton("Ajouter");
                addBtn.addEventListener("click", {
                    EntityEditAuxData modal = new EntityEditAuxData(
                        EntityRenderData.AuxGraphicData(), _auxGraphics, true);
                    modal.addEventListener("aux.new", {
                        auto elt = new AuxElement(modal.getData());
                        _auxGraphicList.addList(elt);
                        elt.addEventListener("aux.dirty", { _isDirty = true; });
                        Atelier.ui.popModalUI();
                        _isDirty = true;
                    });
                    Atelier.ui.pushModalUI(modal);
                });
                hlayout.addUI(addBtn);

                vbox.addUI(_auxGraphicList);

                foreach (render; _data.auxGraphics) {
                    auto elt = new AuxElement(render);
                    elt.addEventListener("aux.dirty", { _isDirty = true; });
                    _auxGraphicList.addList(elt);
                }
            }
        }
    }

    private void moveUpGraphic(AuxElement item_) {
        AuxElement[] elements = cast(AuxElement[]) _auxGraphicList.getList();
        _auxGraphicList.clearList();

        for (size_t i = 1; i < elements.length; ++i) {
            if (elements[i] == item_) {
                elements[i] = elements[i - 1];
                elements[i - 1] = item_;
                break;
            }
        }

        foreach (AuxElement element; elements) {
            _auxGraphicList.addList(element);
        }
    }

    private void moveDownGraphic(AuxElement item_) {
        AuxElement[] elements = cast(AuxElement[]) _auxGraphicList.getList();
        _auxGraphicList.clearList();

        for (size_t i = 0; (i + 1) < elements.length; ++i) {
            if (elements[i] == item_) {
                elements[i] = elements[i + 1];
                elements[i + 1] = item_;
                break;
            }
        }

        foreach (AuxElement element; elements) {
            _auxGraphicList.addList(element);
        }
    }

    EntityRenderData getData() {
        if (!_data.isAuxGraphic) {
            AuxElement[] elements = cast(AuxElement[]) _auxGraphicList.getList();
            _data.auxGraphics.length = 0;
            for (size_t i = 0; i < elements.length; ++i) {
                _data.auxGraphics ~= elements[i].getData();
            }
        }

        return _data;
    }

    bool isDirty() {
        return _isDirty;
    }

    private final class AuxElement : UIElement {
        private {
            EntityRenderData.AuxGraphicData _data;
            Label _idLabel;
            Label _dirsLabel;
            Rectangle _rect;
            HBox _hbox;
            IconButton _upBtn, _downBtn;
            Icon _icon, _checkmark;
        }

        this(EntityRenderData.AuxGraphicData data) {
            _data = data;
            setSize(Vec2f(400f, 32f));

            _rect = Rectangle.fill(getSize());
            _rect.anchor = Vec2f.zero;
            _rect.color = Atelier.theme.foreground;
            _rect.isVisible = false;
            addImage(_rect);

            {
                HBox hbox = new HBox;
                hbox.setAlign(UIAlignX.left, UIAlignY.center);
                hbox.setPosition(Vec2f(16f, 0f));
                hbox.setSpacing(8f);
                hbox.isEnabled = false;
                addUI(hbox);

                _idLabel = new Label("", Atelier.theme.font);
                _idLabel.textColor = Atelier.theme.onNeutral;
                hbox.addUI(_idLabel);

                _dirsLabel = new Label("", Atelier.theme.font);
                _dirsLabel.textColor = Atelier.theme.neutral;
                hbox.addUI(_dirsLabel);
            }

            {
                _hbox = new HBox;
                _hbox.setAlign(UIAlignX.right, UIAlignY.center);
                _hbox.setPosition(Vec2f(12f, 0f));
                _hbox.setSpacing(2f);
                addUI(_hbox);

                _upBtn = new IconButton("editor:arrow-small-up");
                _upBtn.addEventListener("click", {
                    this.outer.moveUpGraphic(this);
                });
                _hbox.addUI(_upBtn);

                _downBtn = new IconButton("editor:arrow-small-down");
                _downBtn.addEventListener("click", {
                    this.outer.moveDownGraphic(this);
                });
                _hbox.addUI(_downBtn);

                _hbox.isVisible = false;
                _hbox.isEnabled = false;
            }

            _updateDisplay();

            addEventListener("mouseenter", &_onMouseEnter);
            addEventListener("mouseleave", &_onMouseLeave);
            addEventListener("click", &_onClick);
        }

        private void _onMouseEnter() {
            _rect.isVisible = true;
            _hbox.isVisible = true;
            _hbox.isEnabled = true;
        }

        private void _onMouseLeave() {
            _rect.isVisible = false;
            _hbox.isVisible = false;
            _hbox.isEnabled = false;
        }

        private void _updateDisplay() {
            _idLabel.text = _data.id;
            _dirsLabel.text = "";
            if (_data.dirs.length) {
                string txt = "(";
                for (int i; i < _data.dirs.length; ++i) {
                    if (i != 0) {
                        txt ~= ", ";
                    }
                    txt ~= to!string(_data.dirs[i]);
                }
                txt ~= ")";

                _dirsLabel.text = txt;
            }
        }

        private void _onClick() {
            EntityEditAuxData modal = new EntityEditAuxData(_data, _auxGraphics, false);
            modal.addEventListener("aux.apply", {
                _data = modal.getData();
                if (modal.isDirty()) {
                    dispatchEvent("aux.dirty", false);
                }
                _updateDisplay();
                Atelier.ui.popModalUI();
            });
            modal.addEventListener("aux.remove", {
                dispatchEvent("aux.dirty", false);
                Atelier.ui.popModalUI();
                removeUI();
            });
            Atelier.ui.pushModalUI(modal);
        }

        EntityRenderData.AuxGraphicData getData() {
            return _data;
        }
    }
}

private final class EntityEditAuxData : Modal {
    private {
        EntityRenderData.AuxGraphicData _data;
        VList _auxGraphicList;
        Checkbox _defaultBtn;
        bool _isDirty = false;
    }

    this(EntityRenderData.AuxGraphicData data, EntityRenderData[] auxGraphicList, bool isNew) {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(500f, 450f));

        _data = data;

        if (isNew) {
            _isDirty = true;
        }

        {
            Label title = new Label(isNew ? "Nouveau Rendu Auxiliaire" : "Éditer le Rendu Auxiliaire",
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
                    dispatchEvent("aux.new", false);
                });
                validationBox.addUI(createBtn);
            }
            else {
                DangerButton removeBtn = new DangerButton("Supprimer");
                removeBtn.addEventListener("click", {
                    dispatchEvent("aux.remove", false);
                });
                validationBox.addUI(removeBtn);

                NeutralButton cancelBtn = new NeutralButton("Annuler");
                cancelBtn.addEventListener("click", &removeUI);
                validationBox.addUI(cancelBtn);

                AccentButton applyBtn = new AccentButton("Appliquer");
                applyBtn.addEventListener("click", {
                    dispatchEvent("aux.apply", false);
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

            hlayout.addUI(new Label("Aux:", Atelier.theme.font));

            string[] list;
            foreach (auxGraphic; auxGraphicList) {
                list ~= auxGraphic.name;
            }
            sort!((a, b) => (a < b))(list);

            SelectButton idBtn = new SelectButton(list, _data.id);
            _data.id = idBtn.value;
            idBtn.addEventListener("value", {
                _data.id = idBtn.value();
                _isDirty = true;
            });
            hlayout.addUI(idBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Directions (Filtre):", Atelier.theme.font));

            TextField dirsField = new TextField;
            dirsField.setAllowedCharacters(" 0123456789");
            dirsField.addEventListener("value", {
                _data.dirs.length = 0;
                foreach (element; dirsField.value.split(' ')) {
                    try {
                        _data.dirs ~= to!uint(element);
                    }
                    catch (ConvException e) {
                    }
                }

                _isDirty = true;
            });
            hlayout.addUI(dirsField);

            string value;
            foreach (i; _data.dirs) {
                value ~= to!string(i) ~ " ";
            }
            dirsField.value = value;
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Offsets X:", Atelier.theme.font));

            TextField xOffsetsField = new TextField;
            xOffsetsField.setAllowedCharacters(" 0123456789-");
            xOffsetsField.addEventListener("value", {
                _data.xOffsets.length = 0;
                foreach (element; xOffsetsField.value.split(' ')) {
                    try {
                        _data.xOffsets ~= to!int(element);
                    }
                    catch (ConvException e) {
                    }
                }

                _isDirty = true;
            });
            hlayout.addUI(xOffsetsField);

            string value;
            foreach (i; _data.xOffsets) {
                value ~= to!string(i) ~ " ";
            }
            xOffsetsField.value = value;
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Offsets Y:", Atelier.theme.font));

            TextField yOffsetsField = new TextField;
            yOffsetsField.setAllowedCharacters(" 0123456789-");
            yOffsetsField.addEventListener("value", {
                _data.yOffsets.length = 0;
                foreach (element; yOffsetsField.value.split(' ')) {
                    try {
                        _data.yOffsets ~= to!int(element);
                    }
                    catch (ConvException e) {
                    }
                }

                _isDirty = true;
            });
            hlayout.addUI(yOffsetsField);

            string value;
            foreach (i; _data.yOffsets) {
                value ~= to!string(i) ~ " ";
            }
            yOffsetsField.value = value;
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Offsets Angle:", Atelier.theme.font));

            TextField angleOffsetsField = new TextField;
            angleOffsetsField.setAllowedCharacters(" 0123456789.-");
            angleOffsetsField.addEventListener("value", {
                _data.angleOffsets.length = 0;
                foreach (element; angleOffsetsField.value.split(' ')) {
                    try {
                        _data.angleOffsets ~= to!float(element);
                    }
                    catch (ConvException e) {
                    }
                }

                _isDirty = true;
            });
            hlayout.addUI(angleOffsetsField);

            string value;
            foreach (i; _data.angleOffsets) {
                value ~= to!string(i) ~ " ";
            }
            angleOffsetsField.value = value;
        }

        Checkbox overrideIsBehindBtn;
        TextField isBehindField;

        {

            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Offsets Angle:", Atelier.theme.font));

            overrideIsBehindBtn = new Checkbox(_data.overrideIsBehind);
            overrideIsBehindBtn.addEventListener("value", {
                _data.overrideIsBehind = overrideIsBehindBtn.value;
                isBehindField.isEnabled = _data.overrideIsBehind;
                _isDirty = true;
            });
            hlayout.addUI(overrideIsBehindBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Derrière:", Atelier.theme.font));

            isBehindField = new TextField();
            isBehindField.isEnabled = _data.overrideIsBehind;
            isBehindField.setAllowedCharacters(" 01");
            isBehindField.addEventListener("value", {
                _data.isBehind.length = 0;
                foreach (element; isBehindField.value.split(
                    ' ')) {
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

    EntityRenderData.AuxGraphicData getData() {
        return _data;
    }

    bool isDirty() {
        return _isDirty;
    }
}
