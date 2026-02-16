module atelier.etabli.media.res.particle.parameter;

import std.algorithm : sort;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;
import atelier.world;
import atelier.etabli.ui;
import atelier.etabli.media.res.entity.data;
import atelier.etabli.media.res.particle.player;

package final class ParameterWindow : UIElement {
    private {
        ParticleSystem _system;
        ParticleDataItem _item;
        ParticleStepItem _selectedStep;
        VList _list, _stepsList;
        VBox _paramBox;

        NeutralButton _upBtn, _downBtn, _duplicateBtn;
        DangerButton _removeBtn;
    }

    this(ParticleSystem system) {
        _system = system;

        _list = new VList;
        _list.setPosition(Vec2f(8f, 8f));
        _list.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        _list.setAlign(UIAlignX.left, UIAlignY.top);
        _list.setColor(Atelier.theme.surface);
        _list.setSpacing(8f);
        _list.setChildAlign(UIAlignX.left);
        addUI(_list);

        _list.isVisible = false;
        _list.isEnabled = false;

        {
            LabelSeparator sep = new LabelSeparator("Étapes", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            _list.addList(sep);
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(8f);
            _list.addList(hbox);

            _stepsList = new VList;
            _stepsList.setSize(Vec2f(300f, 500f));

            AccentButton addBtn = new AccentButton("Ajouter");
            addBtn.addEventListener("click", {
                NewEntry modal = new NewEntry("Ajouter", _item.isSource(), _system);
                modal.addEventListener("entry.apply", {
                    Farfadet ffd = new Farfadet(false);
                    ffd.name = modal.getType();
                    ParticleStepItem newItem = new ParticleStepItem(this, ffd);

                    if (_selectedStep) {
                        ParticleStepItem[] items;

                        items = cast(ParticleStepItem[]) _stepsList.getList();
                        _stepsList.clearList();

                        int index;
                        for (int i = 0; i < items.length; ++i) {
                            if (items[i] == _selectedStep) {
                                index = i;
                                break;
                            }
                        }
                        items.length++;
                        for (int i = (cast(int) items.length) - 2; i > index; --i) {
                            items[i + 1] = items[i];
                        }
                        items[index + 1] = newItem;

                        foreach (ParticleStepItem item; items) {
                            _stepsList.addList(item);
                        }
                    }
                    else {
                        _stepsList.addList(newItem);
                    }

                    Atelier.ui.popModalUI();

                    select(newItem);
                });
                Atelier.ui.pushModalUI(modal);
            });
            hbox.addUI(addBtn);

            _duplicateBtn = new NeutralButton("Dupliquer");
            _duplicateBtn.addEventListener("click", {
                if (!_selectedStep)
                    return;

                ParticleStepItem newItem = new ParticleStepItem(_selectedStep);
                ParticleStepItem[] items;

                items = cast(ParticleStepItem[]) _stepsList.getList();
                _stepsList.clearList();

                int index;
                for (int i = 0; i < items.length; ++i) {
                    if (items[i] == _selectedStep) {
                        index = i;
                        break;
                    }
                }
                items.length++;
                for (int i = (cast(int) items.length) - 2; i > index; --i) {
                    items[i + 1] = items[i];
                }
                items[index + 1] = newItem;

                foreach (ParticleStepItem item; items) {
                    _stepsList.addList(item);
                }

                select(newItem);
            });
            hbox.addUI(_duplicateBtn);

            _removeBtn = new DangerButton("Supprimer");
            _removeBtn.addEventListener("click", {
                if (!_selectedStep)
                    return;

                ParticleStepItem[] items;

                foreach (item; cast(ParticleStepItem[]) _stepsList.getList()) {
                    if (item == _selectedStep)
                        continue;

                    items ~= item;
                }
                _stepsList.clearList();

                foreach (ParticleStepItem item; items) {
                    _stepsList.addList(item);
                }

                _selectedStep = null;
                _updateParameters();
            });
            hbox.addUI(_removeBtn);

            hbox = new HBox;
            hbox.setSpacing(8f);
            _list.addList(hbox);

            _upBtn = new NeutralButton("Haut");
            _upBtn.addEventListener("click", {
                if (!_selectedStep)
                    return;

                ParticleStepItem[] items;

                items = cast(ParticleStepItem[]) _stepsList.getList();
                _stepsList.clearList();

                for (size_t i = 1; i < items.length; ++i) {
                    if (items[i] == _selectedStep) {
                        items[i] = items[i - 1];
                        items[i - 1] = _selectedStep;
                        break;
                    }
                }

                foreach (ParticleStepItem item; items) {
                    _stepsList.addList(item);
                }
            });
            hbox.addUI(_upBtn);

            _downBtn = new NeutralButton("Bas");
            _downBtn.addEventListener("click", {
                if (!_selectedStep)
                    return;

                ParticleStepItem[] items;

                items = cast(ParticleStepItem[]) _stepsList.getList();
                _stepsList.clearList();

                for (size_t i = 0; (i + 1) < items.length; ++i) {
                    if (items[i] == _selectedStep) {
                        items[i] = items[i + 1];
                        items[i + 1] = _selectedStep;
                        break;
                    }
                }

                foreach (ParticleStepItem item; items) {
                    _stepsList.addList(item);
                }
            });
            hbox.addUI(_downBtn);

            _list.addList(_stepsList);
        }

        {
            _paramBox = new VBox;
            _paramBox.setChildAlign(UIAlignX.left);
            _paramBox.setSpacing(8f);
            _list.addList(_paramBox);
        }

        addEventListener("size", {
            _list.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });

        _updateParameters();
    }

    void setItem(ParticleDataItem item) {
        _item = item;

        if (_item) {
            _list.isVisible = true;
            _list.isEnabled = true;

            _stepsList.clearList();
            foreach (step; _item.getSteps()) {
                auto elt = new ParticleStepItem(this, step);
                _stepsList.addList(elt);
            }
        }
        else {
            _list.isVisible = false;
            _list.isEnabled = false;
        }

        _selectedStep = null;
        _updateParameters();
    }

    private void _updateItem() {
        Farfadet[] steps;
        foreach (item; cast(ParticleStepItem[]) _stepsList.getList()) {
            steps ~= item.getFarfadet();
        }
        if (_selectedStep) {
            _selectedStep.updateDisplay();
        }
        _item.setSteps(steps);
    }

    private void _updateParameters() {
        bool hasSelected = _selectedStep !is null;

        _upBtn.isEnabled = hasSelected;
        _downBtn.isEnabled = hasSelected;
        _duplicateBtn.isEnabled = hasSelected;
        _removeBtn.isEnabled = hasSelected;

        _paramBox.clearUI();

        if (hasSelected) {
            string type = _selectedStep.getType();
            Farfadet ffd = _selectedStep.getFarfadet();

            Farfadet outFfd = new Farfadet(false);

            if (_item.isSource()) {
                ParticleSystem.SourceCommand command = _system.getSource(type);

                _generateCommand(type, command.params, ffd, outFfd);
                foreach (key, value; command.subParams) {
                    _generateCommand(key, value, ffd, outFfd, true);
                }
            }
            else {
                ParticleSystem.ElementCommand command = _system.getElement(type);

                _generateCommand(type, command.params, ffd, outFfd);
                foreach (key, value; command.subParams) {
                    _generateCommand(key, value, ffd, outFfd, true);
                }
            }

            _selectedStep.setFarfadet(outFfd);
        }
    }

    private void _generateCommand(string name, ParticleParam[] params, Farfadet ffd, Farfadet outFfd, bool isSubValue = false) {
        LabelSeparator sep = new LabelSeparator(name, Atelier.theme.font);
        sep.setColor(Atelier.theme.neutral);
        sep.setPadding(Vec2f(284f, 0f));
        sep.setSpacing(8f);
        sep.setLineWidth(1f);
        _paramBox.addUI(sep);

        bool hasValue;
        if (isSubValue) {
            if (ffd.hasNode(name)) {
                ffd = ffd.getNode(name);
                hasValue = true;
            }

            outFfd = outFfd.addNode(name);
        }
        else {
            hasValue = true;
        }
        outFfd.name = name;

        foreach (i, param; params) {
            _generateParam(i, param, ffd, hasValue, outFfd);
        }
    }

    private void _generateParam(size_t index, ParticleParam param, Farfadet ffd, bool hasValue, Farfadet outFfd) {
        HLayout hlayout = new HLayout;
        hlayout.setPadding(Vec2f(284f, 0f));
        _paramBox.addUI(hlayout);

        hlayout.addUI(new Label(param.name, Atelier.theme.font));

        hasValue = hasValue && (ffd.getCount() > index);

        final switch (param.type) with (ParticleParam.Type) {
        case bool_:
            Checkbox check = new Checkbox(hasValue ? ffd.get!bool(index) : 0);
            hlayout.addUI(check);

            outFfd.addOrSet!bool(index, check.value);
            check.addEventListener("value", {
                outFfd.addOrSet!bool(index, check.value);
                _updateItem();
            });
            break;
        case uint_:
            IntegerField field = new IntegerField;
            field.setMinValue(0);
            field.value = hasValue ? ffd.get!uint(index) : 0;
            hlayout.addUI(field);

            outFfd.addOrSet!uint(index, field.value);
            field.addEventListener("value", {
                outFfd.addOrSet!uint(index, field.value);
                _updateItem();
            });
            break;
        case int_:
            IntegerField field = new IntegerField;
            field.value = hasValue ? ffd.get!int(index) : 0;
            hlayout.addUI(field);

            outFfd.addOrSet!int(index, field.value);
            field.addEventListener("value", {
                outFfd.addOrSet!int(index, field.value);
                _updateItem();
            });
            break;
        case float_:
            NumberField field = new NumberField;
            field.value = hasValue ? ffd.get!float(index) : 0f;
            hlayout.addUI(field);

            outFfd.addOrSet!float(index, field.value);
            field.addEventListener("value", {
                outFfd.addOrSet!float(index, field.value);
                _updateItem();
            });
            break;
        case float01:
            HSlider slider = new HSlider;
            slider.setWidth(200f);
            slider.minValue = 0f;
            slider.maxValue = 1f;
            slider.steps = 100;
            slider.fvalue = hasValue ? ffd.get!float(index) : 0f;
            hlayout.addUI(slider);

            outFfd.addOrSet!float(index, slider.fvalue);
            slider.addEventListener("value", {
                outFfd.addOrSet!float(index, slider.fvalue);
                _updateItem();
            });
            break;
        case string_:
            TextField field = new TextField;
            field.value = hasValue ? ffd.get!string(index) : "";
            hlayout.addUI(field);

            outFfd.addOrSet!string(index, field.value);
            field.addEventListener("value", {
                outFfd.addOrSet!string(index, field.value);
                _updateItem();
            });
            break;
        case enum_:
            CarouselButton field = new CarouselButton(
                param.enumList,
                hasValue ? ffd.get!string(index) : "");
            hlayout.addUI(field);

            outFfd.addOrSet!string(index, field.value);
            field.addEventListener("value", {
                outFfd.addOrSet!string(index, field.value);
                _updateItem();
            });
            break;
        case spline:
            CarouselButton splineSelect = new CarouselButton([
                __traits(allMembers, Spline)
            ], hasValue ? ffd.get!string(index) : "", false);
            hlayout.addUI(splineSelect);

            SplineGraph splineGraph = new SplineGraph();
            splineGraph.setSpline(splineSelect.value);
            hlayout.addUI(splineGraph);

            outFfd.addOrSet!string(index, splineSelect.value);
            splineSelect.addEventListener("value", {
                splineGraph.setSpline(splineSelect.value);
                outFfd.addOrSet!string(index, splineSelect.value);
                _updateItem();
            });
            break;
        case color:
            ColorButton colorBtn = new ColorButton;
            colorBtn.value = hasValue ? ffd.get!Color(index) : Color.white;
            hlayout.addUI(colorBtn);

            outFfd.addOrSet!Color(index, colorBtn.value);
            colorBtn.addEventListener("value", {
                outFfd.addOrSet!Color(index, colorBtn.value);
                _updateItem();
            });
            break;
        }
    }

    protected void select(ParticleStepItem item_) {
        size_t i;
        foreach (ParticleStepItem item; cast(ParticleStepItem[]) _stepsList.getList()) {
            if (item == item_) {
                _stepsList.moveToElement(i);
            }
            item.updateSelection(item == item_);
            i++;
        }

        _selectedStep = item_;
        _updateParameters();
    }
}

private final class NewEntry : Modal {
    private {
        SelectButton _typeBtn;
    }

    this(string title_, bool isSource, ParticleSystem system) {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(300f, 200f));

        {
            Label title = new Label(title_, Atelier.theme.font);
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

        VBox vbox;
        vbox = new VBox;
        vbox.setAlign(UIAlignX.center, UIAlignY.center);
        vbox.setChildAlign(UIAlignX.left);
        vbox.setSpacing(8f);
        addUI(vbox);

        {
            HBox hbox = new HBox;
            vbox.addUI(hbox);

            hbox.addUI(new Label("Type: ", Atelier.theme.font));

            string[] types;
            if (isSource)
                types = system.getSourceFunctions();
            else
                types = system.getElementFunctions();

            sort!((a, b) => (a < b))(types);
            _typeBtn = new SelectButton(types, "", true);
            hbox.addUI(_typeBtn);
        }

        {
            HBox validationBox = new HBox;
            validationBox.setAlign(UIAlignX.right, UIAlignY.bottom);
            validationBox.setPosition(Vec2f(10f, 10f));
            validationBox.setSpacing(8f);
            addUI(validationBox);

            NeutralButton cancelBtn = new NeutralButton("Annuler");
            cancelBtn.addEventListener("click", &removeUI);
            validationBox.addUI(cancelBtn);

            AccentButton createBtn = new AccentButton("Ajouter");
            createBtn.addEventListener("click", {
                dispatchEvent("entry.apply", false);
            });
            validationBox.addUI(createBtn);
        }
    }

    string getType() const {
        return _typeBtn.value;
    }
}

private final class ParticleStepItem : UIElement {
    private {
        Label _nameLabel;
        Rectangle _rect;
        HBox _hbox;
        IconButton _upBtn, _downBtn;
        bool _isSelected;
        ParameterWindow _parameter;
        Farfadet _ffd;
    }

    this(ParticleStepItem other) {
        _parameter = other._parameter;
        _ffd = new Farfadet(other._ffd);

        _setup();
    }

    this(ParameterWindow parameter, Farfadet ffd) {
        _parameter = parameter;
        _ffd = ffd;

        _setup();
    }

    private void _setup() {
        setSize(Vec2f(300f, 48f));

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.surface;
        addImage(_rect);

        _nameLabel = new Label("", Atelier.theme.font);
        _nameLabel.setAlign(UIAlignX.left, UIAlignY.center);
        _nameLabel.setPosition(Vec2f(16f, 0f));
        _nameLabel.textColor = Atelier.theme.onNeutral;
        addUI(_nameLabel);

        updateDisplay();

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
        addEventListener("click", &_onClick);
    }

    private void _onMouseEnter() {
        if (_isSelected) {
            _rect.color = Atelier.theme.accent;
            _nameLabel.textColor = Atelier.theme.onAccent;
        }
        else {
            _rect.color = Atelier.theme.foreground;
            _nameLabel.textColor = Atelier.theme.onNeutral;
        }
    }

    private void _onMouseLeave() {
        if (_isSelected) {
            _rect.color = Atelier.theme.accent;
            _nameLabel.textColor = Atelier.theme.onAccent;
        }
        else {
            _rect.color = Atelier.theme.surface;
            _nameLabel.textColor = Atelier.theme.onNeutral;
        }
    }

    private void updateDisplay() {
        _nameLabel.text = _ffd.generate(1, false);
    }

    protected void updateSelection(bool select_) {
        if (_isSelected == select_)
            return;

        _isSelected = select_;

        if (isHovered) {
            _onMouseEnter();
        }
        else {
            _onMouseLeave();
        }
    }

    private void _onClick() {
        _parameter.select(this);
    }

    string getType() const {
        return _ffd.name;
    }

    Farfadet getFarfadet() {
        return _ffd;
    }

    void setFarfadet(Farfadet ffd) {
        _ffd = ffd;
    }
}
