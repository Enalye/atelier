module atelier.etabli.media.res.shadow.toolbox;

import std.conv : to;
import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.etabli.ui;
import atelier.etabli.media.res.base;

package class Toolbox : Modal {
    private {
        HSlider _altitudeSlider;
        Knob _dirKnob;
    }

    this() {
        setSize(Vec2f(256f, 256f));
        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(258f, 75f));

        {
            Label title = new Label("Outils", Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 4f));
            addUI(title);
        }

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.center, UIAlignY.top);
        vbox.setPosition(Vec2f(0f, 32f));
        vbox.setSpacing(16f);
        vbox.setChildAlign(UIAlignX.center);
        addUI(vbox);

        {
            _dirKnob = new Knob;
            _dirKnob.setSize(Vec2f(128f, 128f));
            _dirKnob.setRange(0f, 360f);
            _dirKnob.setAngleOffset(180f);
            _dirKnob.value = 0f;
            vbox.addUI(_dirKnob);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(getWidth() - 16f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Altitude:", Atelier.theme.font));

            _altitudeSlider = new HSlider;
            _altitudeSlider.steps = 100;
            hlayout.addUI(_altitudeSlider);
        }
    }

    float getAltitude() {
        return _altitudeSlider.fvalue;
    }

    float getAngle() {
        return _dirKnob.value;
    }
}
