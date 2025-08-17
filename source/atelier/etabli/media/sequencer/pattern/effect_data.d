module atelier.etabli.media.sequencer.pattern.effect_data;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.sequencer.pattern.editor;
import atelier.etabli.media.sequencer.pattern.effect;

package class PatternSequencerEffectDataWindow : Modal {
    private {
        Effect _effect;
        IntegerField _startField, _endField;
        HSlider _startSlider, _endSlider;
        SplineGraph _splineGraph;
    }

    this(Effect effect) {
        _effect = effect;
        setSize(Vec2f(450f, 200f));
        setAlign(UIAlignX.left, UIAlignY.top);

        {
            Label title = new Label(_effect.getTitle(), Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 8f));
            addUI(title);
        }

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.center, UIAlignY.top);
        vbox.setPosition(Vec2f(0f, 32f));
        vbox.setSpacing(8f);
        addUI(vbox);

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            _startSlider = new HSlider;
            _startSlider.setWidth(320f);
            _startSlider.minValue = _effect.getMinValue();
            _startSlider.maxValue = _effect.getMaxValue();
            _startSlider.steps = _effect.getRange();
            _startSlider.ivalue = _effect.startValue;
            _startSlider.addEventListener("value", {
                _effect.startValue = _startSlider.ivalue;
                _startField.value = _effect.startValue;
                dispatchEvent("value", false);
            });
            hlayout.addUI(_startSlider);

            _startField = new IntegerField;
            _startField.setRange(_effect.getMinValue(), _effect.getMaxValue());
            _startField.value = _effect.startValue;
            _startField.addEventListener("value", {
                _effect.startValue = _startField.value;
                _startSlider.ivalue = _effect.startValue;
                dispatchEvent("value", false);
            });
            hlayout.addUI(_startField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            _endSlider = new HSlider;
            _endSlider.setWidth(320f);
            _endSlider.minValue = _effect.getMinValue();
            _endSlider.maxValue = _effect.getMaxValue();
            _endSlider.steps = _effect.getRange();
            _endSlider.ivalue = _effect.endValue;
            _endSlider.addEventListener("value", {
                _effect.endValue = _endSlider.ivalue;
                _endField.value = _effect.endValue;
                dispatchEvent("value", false);
            });
            hlayout.addUI(_endSlider);

            _endField = new IntegerField;
            _endField.setRange(_effect.getMinValue(), _effect.getMaxValue());
            _endField.value = _effect.endValue;
            _endField.addEventListener("value", {
                _effect.endValue = _endField.value;
                _endSlider.ivalue = _effect.endValue;
                dispatchEvent("value", false);
            });
            hlayout.addUI(_endField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Interpolation:", Atelier.theme.font));

            auto _splineSelector = new CarouselButton([
                __traits(allMembers, Spline)
            ], _effect.spline, false);
            _splineSelector.addEventListener("value", {
                _effect.spline = _splineSelector.value;
                _splineGraph.setSpline(_effect.spline);
            });
            hlayout.addUI(_splineSelector);

            _splineGraph = new SplineGraph();
            _splineGraph.setSpline(_effect.spline);
            hlayout.addUI(_splineGraph);
        }

        addEventListener("update", {
            addEventListener("clickoutside", &removeUI);
        });
    }
}
