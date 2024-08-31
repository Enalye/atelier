/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.ui.button.color;

import std.conv : to;
import std.math : round;
import std.format;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui.core;
import atelier.ui.input;
import atelier.ui.navigation;
import atelier.ui.panel;
import atelier.ui.slider;
import atelier.ui.button.button;
import atelier.ui.button.icon;
import atelier.ui.button.neutral;
import atelier.ui.button.accent;

final class ColorButton : Button!RoundedRectangle {
    private {
        RoundedRectangle _backgroundRect, _colorRect;
    }

    @property {
        Color value() const {
            return _colorRect.color;
        }

        Color value(Color color_) {
            _colorRect.color = color_;
            return color_;
        }
    }

    this() {
        setFxColor(Atelier.theme.neutral);
        setSize(Vec2f(32f, 32f));

        _backgroundRect = RoundedRectangle.fill(Vec2f(32f, 32f), Atelier.theme.corner);
        _backgroundRect.color = Atelier.theme.neutral;
        _backgroundRect.anchor = Vec2f.zero;
        addImage(_backgroundRect);

        _colorRect = RoundedRectangle.fill(Vec2f(24f, 24f), Atelier.theme.corner);
        _colorRect.color = Atelier.theme.neutral;
        _colorRect.anchor = Vec2f.half;
        _colorRect.position = Vec2f(16f, 16f);
        addImage(_colorRect);

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);

        addEventListener("enable", &_onEnable);
        addEventListener("disable", &_onDisable);

        addEventListener("click", &_onClick);
    }

    private void _onEnable() {
        _backgroundRect.alpha = Atelier.theme.activeOpacity;
        _backgroundRect.color = Atelier.theme.neutral;

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onDisable() {
        _backgroundRect.alpha = Atelier.theme.inactiveOpacity;
        _backgroundRect.color = Atelier.theme.neutral;

        removeEventListener("mouseenter", &_onMouseEnter);
        removeEventListener("mouseleave", &_onMouseLeave);
    }

    private void _onMouseEnter() {
        Color rgb = Atelier.theme.neutral;
        HSLColor hsl = HSLColor.fromColor(rgb);
        hsl.l = hsl.l * .8f;
        _backgroundRect.color = hsl.toColor();
    }

    private void _onMouseLeave() {
        _backgroundRect.color = Atelier.theme.neutral;
    }

    private void _onClick() {
        UIManager manager = getManager();
        if (manager) {
            ColorPicker colorPicker = new ColorPicker(_colorRect.color);
            colorPicker.addEventListener("value", {
                manager.popModalUI();

                if (_colorRect.color != colorPicker.getColor()) {
                    _colorRect.color = colorPicker.getColor();
                    dispatchEvent("value", false);
                }
            });
            manager.pushModalUI(colorPicker);
        }
    }
}

final class ColorPicker : Modal {
    private {
        TabGroup _systemTab;
        HLayout _rgbLayout, _hslLayout;
        TextField _hexField;

        IntegerField _rField, _gField, _bField;
        HSlider _rSlider, _gSlider, _bSlider;

        IntegerField _hField, _sField, _lField;
        HSlider _hSlider, _sSlider, _lSlider;

        SDL_Color _originColor, _color;
        ubyte _r, _g, _b;
        uint _hex, _h, _s, _l;
        RoundedRectangle _previewOriginRect, _previewRect;
    }

    this(Color color_) {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(600f, 320f));
        _originColor = color_.toSDL();
        _color = _originColor;

        {
            _r = _color.r;
            _g = _color.g;
            _b = _color.b;
            _hex = (_r << 16) | (_g << 8) | _b;
            HSLColor hsl = HSLColor.fromColor(Color.fromHex(_hex));
            _h = cast(uint) round(hsl.h);
            _s = cast(uint) round(hsl.s * 100f);
            _l = cast(uint) round(hsl.l * 100f);
        }

        {
            Label title = new Label("Couleur", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 4f));
            addUI(title);
        }

        {
            IconButton exitBtn = new IconButton("editor:exit");
            exitBtn.setAlign(UIAlignX.right, UIAlignY.top);
            exitBtn.setPosition(Vec2f(4f, 4f));
            exitBtn.addEventListener("click", &remove);
            addUI(exitBtn);
        }

        {
            _previewOriginRect = RoundedRectangle.fill(Vec2f(32f, 32f), Atelier.theme.corner);
            _previewOriginRect.color = Color.fromSDL(_originColor);
            _previewOriginRect.anchor = Vec2f.zero;
            _previewOriginRect.position = Vec2f(16f, 32f);
            addImage(_previewOriginRect);
        }

        {
            _previewRect = RoundedRectangle.fill(Vec2f(32f, 32f), Atelier.theme.corner);
            _previewRect.color = Color.fromSDL(_color);
            _previewRect.anchor = Vec2f.zero;
            _previewRect.position = Vec2f(56f, 32f);
            addImage(_previewRect);
        }

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.right, UIAlignY.top);
            hbox.setSpacing(8f);
            hbox.setPosition(Vec2f(16f, 32f));
            addUI(hbox);

            hbox.addUI(new Label("Hex:", Atelier.theme.font));

            _hexField = new TextField;
            _hexField.setAllowedCharacters("abcdefABCDEF0123456789");
            _hexField.value = format!"%06x"(_hex);
            _hexField.addEventListener("value", {
                try {
                    _hex = to!int(_hexField.value, 16);
                    _r = (_hex >> 16) & 0xff;
                    _g = (_hex >> 8) & 0xff;
                    _b = _hex & 0xff;
                    HSLColor hsl = HSLColor.fromColor(Color.fromHex(_hex));
                    _h = cast(uint) round(hsl.h);
                    _s = cast(uint) round(hsl.s * 100f);
                    _l = cast(uint) round(hsl.l * 100f);
                }
                catch (Exception e) {

                }

                _rSlider.ivalue = _r;
                _gSlider.ivalue = _g;
                _bSlider.ivalue = _b;

                _rField.value = _r;
                _gField.value = _g;
                _bField.value = _b;

                _hSlider.ivalue = _h;
                _sSlider.ivalue = _s;
                _lSlider.ivalue = _l;

                _hField.value = _h;
                _sField.value = _s;
                _lField.value = _l;

                _previewRect.color = Color.fromHex(_hex);
            });
            hbox.addUI(_hexField);
        }

        {
            _systemTab = new TabGroup;
            _systemTab.setAlign(UIAlignX.left, UIAlignY.top);
            _systemTab.setPosition(Vec2f(0f, 80f));
            _systemTab.setWidth(getWidth());

            _systemTab.addTab("RVB", "rgb");
            _systemTab.addTab("TSL", "hsl");
            _systemTab.selectTab("rgb");
            _systemTab.addEventListener("value", &_onSystemChange);
            addUI(_systemTab);
        }

        {
            _rgbLayout = new HLayout;
            _rgbLayout.setAlign(UIAlignX.center, UIAlignY.top);
            _rgbLayout.setPadding(Vec2f(256f, 0f));
            _rgbLayout.setPosition(Vec2f(8f, 128f));

            _hslLayout = new HLayout;
            _hslLayout.setAlign(UIAlignX.center, UIAlignY.top);
            _hslLayout.setPadding(Vec2f(256f, 0f));
            _hslLayout.setPosition(Vec2f(8f, 128f));
        }

        { // RVB
        {
                VBox vbox = new VBox;
                vbox.setSpacing(8f);
                _rgbLayout.addUI(vbox);

                foreach (key; ["R:", "G:", "B:"]) {
                    HLayout hlayout = new HLayout;
                    vbox.addUI(hlayout);
                    hlayout.setPadding(Vec2f(32f, 32f));
                    hlayout.addUI(new Label(key, Atelier.theme.font));
                }
            }
            {
                VBox vbox = new VBox;
                vbox.setSpacing(8f);
                _rgbLayout.addUI(vbox);

                _rSlider = new HSlider;
                _rSlider.setWidth(352f);
                _rSlider.minValue = 0;
                _rSlider.maxValue = 255;
                _rSlider.steps = 256;
                _rSlider.ivalue = _r;
                _rSlider.addEventListener("value", {
                    _r = cast(ubyte) _rSlider.ivalue;
                    _rField.value = _r;
                    _hex = (_r << 16) | (_hex & 0xffff);
                    _hexField.value = format!"%06x"(_hex);
                    _previewRect.color = Color.fromHex(_hex);
                    _updateHSL();
                });
                vbox.addUI(_rSlider);

                _gSlider = new HSlider;
                _gSlider.setWidth(352f);
                _gSlider.minValue = 0;
                _gSlider.maxValue = 255;
                _gSlider.steps = 256;
                _gSlider.ivalue = _g;
                _gSlider.addEventListener("value", {
                    _g = cast(ubyte) _gSlider.ivalue;
                    _gField.value = _g;
                    _hex = (_g << 8) | (_hex & 0xff00ff);
                    _hexField.value = format!"%06x"(_hex);
                    _previewRect.color = Color.fromHex(_hex);
                    _updateHSL();

                });
                vbox.addUI(_gSlider);

                _bSlider = new HSlider;
                _bSlider.setWidth(352f);
                _bSlider.minValue = 0;
                _bSlider.maxValue = 255;
                _bSlider.steps = 256;
                _bSlider.ivalue = _b;
                _bSlider.addEventListener("value", {
                    _b = cast(ubyte) _bSlider.ivalue;
                    _bField.value = _b;
                    _hex = _b | (_hex & 0xffff00);
                    _hexField.value = format!"%06x"(_hex);
                    _previewRect.color = Color.fromHex(_hex);
                    _updateHSL();
                });
                vbox.addUI(_bSlider);
            }

            {
                VBox vbox = new VBox;
                vbox.setSpacing(8f);
                _rgbLayout.addUI(vbox);

                _rField = new IntegerField;
                _rField.setRange(0, 255);
                _rField.value = _r;
                _rField.addEventListener("value", {
                    _r = cast(ubyte) _rField.value;
                    _rSlider.ivalue = _r;
                    _hex = (_r << 16) | (_hex & 0xffff);
                    _hexField.value = format!"%06x"(_hex);
                    _previewRect.color = Color.fromHex(_hex);
                    _updateHSL();
                });
                vbox.addUI(_rField);

                _gField = new IntegerField;
                _gField.value = _g;
                _gField.addEventListener("value", {
                    _g = cast(ubyte) _gField.value;
                    _gSlider.ivalue = _g;
                    _hex = (_g << 8) | (_hex & 0xff00ff);
                    _hexField.value = format!"%06x"(_hex);
                    _previewRect.color = Color.fromHex(_hex);
                    _updateHSL();
                });
                vbox.addUI(_gField);

                _bField = new IntegerField;
                _bField.value = _b;
                _bField.addEventListener("value", {
                    _b = cast(ubyte) _bField.value;
                    _bSlider.ivalue = _b;
                    _hex = _b | (_hex & 0xffff00);
                    _hexField.value = format!"%06x"(_hex);
                    _previewRect.color = Color.fromHex(_hex);
                    _updateHSL();
                });
                vbox.addUI(_bField);
            }
        }

        { // TSL
        {
                VBox vbox = new VBox;
                vbox.setSpacing(8f);
                _hslLayout.addUI(vbox);

                foreach (key; ["T:", "S:", "L:"]) {
                    HLayout hlayout = new HLayout;
                    vbox.addUI(hlayout);
                    hlayout.setPadding(Vec2f(32f, 32f));
                    hlayout.addUI(new Label(key, Atelier.theme.font));
                }
            }
            {
                VBox vbox = new VBox;
                vbox.setSpacing(8f);
                _hslLayout.addUI(vbox);

                _hSlider = new HSlider;
                _hSlider.setWidth(352f);
                _hSlider.minValue = 0;
                _hSlider.maxValue = 360;
                _hSlider.steps = 361;
                _hSlider.ivalue = _h;
                _hSlider.addEventListener("value", {
                    _h = _hSlider.ivalue;
                    _hField.value = _h;
                    _updateRGB();
                });
                vbox.addUI(_hSlider);

                _sSlider = new HSlider;
                _sSlider.setWidth(352f);
                _sSlider.minValue = 0;
                _sSlider.maxValue = 100;
                _sSlider.steps = 101;
                _sSlider.ivalue = _s;
                _sSlider.addEventListener("value", {
                    _s = _sSlider.ivalue;
                    _sField.value = _s;
                    _updateRGB();

                });
                vbox.addUI(_sSlider);

                _lSlider = new HSlider;
                _lSlider.setWidth(352f);
                _lSlider.minValue = 0;
                _lSlider.maxValue = 100;
                _lSlider.steps = 101;
                _lSlider.ivalue = _l;
                _lSlider.addEventListener("value", {
                    _l = _lSlider.ivalue;
                    _lField.value = _l;
                    _updateRGB();
                });
                vbox.addUI(_lSlider);
            }

            {
                VBox vbox = new VBox;
                vbox.setSpacing(8f);
                _hslLayout.addUI(vbox);

                _hField = new IntegerField;
                _hField.setRange(0, 360);
                _hField.value = _h;
                _hField.addEventListener("value", {
                    _h = _hField.value;
                    _hSlider.ivalue = _h;
                    _updateRGB();
                });
                vbox.addUI(_hField);

                _sField = new IntegerField;
                _sField.setRange(0, 100);
                _sField.value = _s;
                _sField.addEventListener("value", {
                    _s = _sField.value;
                    _sSlider.ivalue = _s;
                    _updateRGB();
                });
                vbox.addUI(_sField);

                _lField = new IntegerField;
                _lField.setRange(0, 100);
                _lField.value = _l;
                _lField.addEventListener("value", {
                    _l = _lField.value;
                    _lSlider.ivalue = _l;
                    _updateRGB();
                });
                vbox.addUI(_lField);
            }
        }

        {
            HBox validationBox = new HBox;
            validationBox.setAlign(UIAlignX.right, UIAlignY.bottom);
            validationBox.setPosition(Vec2f(10f, 10f));
            validationBox.setSpacing(8f);
            addUI(validationBox);

            NeutralButton resetBtn = new NeutralButton("Réinitialiser");
            resetBtn.addEventListener("click", &_resetColor);
            validationBox.addUI(resetBtn);

            NeutralButton cancelBtn = new NeutralButton("Annuler");
            cancelBtn.addEventListener("click", &remove);
            validationBox.addUI(cancelBtn);

            AccentButton applyBtn = new AccentButton("Appliquer");
            applyBtn.addEventListener("click", { dispatchEvent("value", false); });
            validationBox.addUI(applyBtn);
        }

        _onSystemChange();
    }

    private void _onSystemChange() {
        switch (_systemTab.value) {
        case "rgb":
            _hslLayout.remove();
            addUI(_rgbLayout);
            break;
        case "hsl":
            _rgbLayout.remove();
            addUI(_hslLayout);
            break;
        default:
            break;
        }
    }

    private void _updateRGB() {
        Color rgb = HSLColor(cast(float) _h, _s / 100f, _l / 100f).toColor();
        _hex = rgb.toHex();
        SDL_Color sdlColor = rgb.toSDL();
        _r = sdlColor.r;
        _g = sdlColor.g;
        _b = sdlColor.b;

        _rSlider.ivalue = _r;
        _gSlider.ivalue = _g;
        _bSlider.ivalue = _b;

        _rField.value = _r;
        _gField.value = _g;
        _bField.value = _b;

        _hexField.value = format!"%06x"(_hex);
        _previewRect.color = rgb;
    }

    private void _updateHSL() {
        HSLColor hsl = HSLColor.fromColor(Color.fromHex(_hex));
        _h = cast(uint) round(hsl.h);
        _s = cast(uint) round(hsl.s * 100f);
        _l = cast(uint) round(hsl.l * 100f);

        _hSlider.ivalue = _h;
        _sSlider.ivalue = _s;
        _lSlider.ivalue = _l;

        _hField.value = _h;
        _sField.value = _s;
        _lField.value = _l;
    }

    private void _resetColor() {
        _color = _originColor;

        Color rgb = Color.fromSDL(_color);
        _hex = rgb.toHex();

        _r = _color.r;
        _g = _color.g;
        _b = _color.b;

        _rSlider.ivalue = _r;
        _gSlider.ivalue = _g;
        _bSlider.ivalue = _b;

        _rField.value = _r;
        _gField.value = _g;
        _bField.value = _b;

        HSLColor hsl = HSLColor.fromColor(rgb);
        _h = cast(uint) round(hsl.h);
        _s = cast(uint) round(hsl.s * 100f);
        _l = cast(uint) round(hsl.l * 100f);

        _hSlider.ivalue = _h;
        _sSlider.ivalue = _s;
        _lSlider.ivalue = _l;

        _hField.value = _h;
        _sField.value = _s;
        _lField.value = _l;

        _hexField.value = format!"%06x"(_hex);
        _previewRect.color = rgb;
    }

    Color getColor() {
        return Color(_r, _g, _b);
    }
}
