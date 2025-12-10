module atelier.etabli.media.res.grid.toolbox;

import std.conv : to;
import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;
import atelier.etabli.common;
import atelier.etabli.ui;
import atelier.etabli.media.res.base;

package class Toolbox(T) : Modal {
    private {
        ToolGroup _toolGroup;
        int _tool;
        VBox _vbox;
        HLayout _sizeLayout;
        IntegerField _sizeField;
        static if (is(T == float)) {
            HLayout _valueLayout, _stepLayout, _softenLayout, _easingLayout, _toleranceLayout;
            NumberField _valueField, _stepField, _toleranceField;
            Checkbox _softenCheck;
            CarouselButton _easingCarousel;
        }
        else static if (is(T == uint) || is(T == int)) {
            HLayout _valueLayout, _stepLayout, _softenLayout, _easingLayout, _toleranceLayout;
            IntegerField _valueField, _stepField, _toleranceField;
            Checkbox _softenCheck;
            CarouselButton _easingCarousel;
        }
        else static if (is(T == bool)) {
            HLayout _valueLayout;
            Checkbox _valueCheck;
        }
    }

    this() {
        setSize(Vec2f(312f, 256f));
        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(258f, 75f));

        {
            Label title = new Label("Outils", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 8f));
            addUI(title);
        }

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.center, UIAlignY.top);
            hbox.setPosition(Vec2f(0f, 32f));
            hbox.setSpacing(4f);
            addUI(hbox);

            _toolGroup = new ToolGroup;
            static if (is(T == float) || is(T == uint) || is(T == int)) {
                auto keyList = ["selection", "pen", "bucket", "elevation"];
            }
            else static if (is(T == bool)) {
                auto keyList = ["selection", "pen", "bucket"];
            }
            foreach (key; keyList) {
                ToolButton btn = new ToolButton(_toolGroup,
                    "editor:" ~ key ~ "-button", key == "selection");
                btn.setSize(Vec2f(32f, 32f));
                hbox.addUI(btn);
            }
        }

        _vbox = new VBox;
        _vbox.setAlign(UIAlignX.left, UIAlignY.top);
        _vbox.setPosition(Vec2f(8f, 76f));
        _vbox.setSpacing(8f);
        _vbox.setChildAlign(UIAlignX.left);
        addUI(_vbox);

        const float toolWidth = getWidth() - 16f;

        addEventListener("update", {
            if (_toolGroup.value != _tool) {
                _tool = _toolGroup.value;
                _onToolChange();
            }
        });

        {
            _sizeLayout = new HLayout;
            _sizeLayout.setPadding(Vec2f(toolWidth, 32f));

            Label label = new Label("Taille: ", Atelier.theme.font);
            _sizeLayout.addUI(label);

            _sizeField = new IntegerField;
            _sizeField.setRange(1, 32);
            _sizeField.addEventListener("value", { dispatchEvent("tool", false); });
            _sizeLayout.addUI(_sizeField);
        }

        static if (is(T == float) || is(T == uint) || is(T == int)) {
            {
                _valueLayout = new HLayout;
                _valueLayout.setPadding(Vec2f(toolWidth, 32f));

                _valueLayout.addUI(new Label("Valeur:", Atelier.theme.font));

                static if (is(T == float)) {
                    _valueField = new NumberField;
                }
                else static if (is(T == uint) || is(T == int)) {
                    _valueField = new IntegerField;
                    static if (is(T == uint)) {
                        _valueField.setMinValue(0);
                    }
                }
                _valueLayout.addUI(_valueField);
            }

            {
                _stepLayout = new HLayout;
                _stepLayout.setPadding(Vec2f(toolWidth, 32f));

                _stepLayout.addUI(new Label("Pas:", Atelier.theme.font));

                static if (is(T == float)) {
                    _stepField = new NumberField;
                }
                else static if (is(T == uint) || is(T == int)) {
                    _stepField = new IntegerField;
                }
                _stepLayout.addUI(_stepField);
            }

            {
                _toleranceLayout = new HLayout;
                _toleranceLayout.setPadding(Vec2f(toolWidth, 32f));

                _toleranceLayout.addUI(new Label("Tolérance:", Atelier.theme.font));

                static if (is(T == float)) {
                    _toleranceField = new NumberField;
                    _toleranceField.setMinValue(0f);
                }
                else static if (is(T == uint) || is(T == int)) {
                    _toleranceField = new IntegerField;
                    _toleranceField.setMinValue(0);
                }
                _toleranceLayout.addUI(_toleranceField);
            }

            {
                _softenLayout = new HLayout;
                _softenLayout.setPadding(Vec2f(toolWidth, 32f));

                _softenLayout.addUI(new Label("Adoucir ?", Atelier.theme.font));

                _softenCheck = new Checkbox;
                _softenCheck.addEventListener("value", {
                    _easingCarousel.isEnabled = _softenCheck.value;
                });
                _softenLayout.addUI(_softenCheck);
            }

            {
                _easingLayout = new HLayout;
                _easingLayout.setPadding(Vec2f(toolWidth, 32f));

                _easingLayout.addUI(new Label("Interpolation:", Atelier.theme.font));

                _easingCarousel = new CarouselButton([
                    __traits(allMembers, Spline)
                ], "linear");
                _easingCarousel.isEnabled = false;
                _easingLayout.addUI(_easingCarousel);
            }
        }
        else static if (is(T == bool)) {
            {
                _valueLayout = new HLayout;
                _valueLayout.setPadding(Vec2f(toolWidth, 32f));

                _valueLayout.addUI(new Label("Valeur:", Atelier.theme.font));

                _valueCheck = new Checkbox;
                _valueLayout.addUI(_valueCheck);
            }
        }

        _onToolChange();
    }

    private void _onToolChange() {
        _vbox.clearUI();

        switch (_toolGroup.value()) {
        case 0:
            break;
        case 1:
            _vbox.addUI(_valueLayout);
            _vbox.addUI(_sizeLayout);

            static if (is(T == float) || is(T == uint) || is(T == int)) {
                _vbox.addUI(_softenLayout);
                _vbox.addUI(_easingLayout);
            }
            break;
        case 2:
            _vbox.addUI(_valueLayout);

            static if (is(T == float) || is(T == uint) || is(T == int)) {
                _vbox.addUI(_toleranceLayout);
            }
            break;
        case 3:
            static if (is(T == float) || is(T == uint) || is(T == int)) {
                _vbox.addUI(_stepLayout);
                _vbox.addUI(_sizeLayout);

                _vbox.addUI(_softenLayout);
                _vbox.addUI(_easingLayout);
            }
            break;
        default:
            break;
        }

        dispatchEvent("tool", false);
    }

    int getTool() const {
        return _toolGroup.value();
    }

    int getBrushSize() {
        return _sizeField.value;
    }

    T getBrushValue() {
        static if (is(T == float) || is(T == uint) || is(T == int)) {
            return _valueField.value;
        }
        else static if (is(T == bool)) {
            return _valueCheck.value;
        }
    }

    void setBrushValue(T value) {
        static if (is(T == float) || is(T == uint) || is(T == int)) {
            _valueField.value = value;
        }
        else static if (is(T == bool)) {
            _valueCheck.value = value;
        }
    }

    static if (is(T == float) || is(T == uint) || is(T == int)) {
        T getBrushStep() {
            return _stepField.value;
        }

        T getBrushTolerance() {
            return _toleranceField.value;
        }

        bool getBrushSoften() {
            return _softenCheck.value;
        }

        Spline getBrushSpline() {
            return to!Spline(_easingCarousel.value);
        }
    }
}
