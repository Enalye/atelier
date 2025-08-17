module atelier.etabli.media.sequencer.tracklist.tempo_data;

import atelier;
import atelier.etabli.media.sequencer.tracklist.editor;
import atelier.etabli.media.sequencer.tracklist.tempo;
import atelier.etabli.ui;

package class TracklistSequencerTempoDataWindow : Modal {
    private {
        Tempo _tempo;
        IntegerField _startField, _endField;
        HSlider _startSlider, _endSlider;
        SplineGraph _splineGraph;
    }

    this(Tempo tempo) {
        _tempo = tempo;
        setSize(Vec2f(450f, 200f));
        setAlign(UIAlignX.left, UIAlignY.top);

        {
            Label title = new Label("Tempo", Atelier.theme.font);
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
            _startSlider.minValue = 0;
            _startSlider.maxValue = 500;
            _startSlider.steps = 501;
            _startSlider.ivalue = _tempo.startValue;
            _startSlider.addEventListener("value", {
                _tempo.startValue = _startSlider.ivalue;
                _startField.value = _tempo.startValue;
                dispatchEvent("value", false);
            });
            hlayout.addUI(_startSlider);

            _startField = new IntegerField;
            _startField.setRange(0, 500);
            _startField.value = _tempo.startValue;
            _startField.addEventListener("value", {
                _tempo.startValue = _startField.value;
                _startSlider.ivalue = _tempo.startValue;
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
            _endSlider.minValue = 0;
            _endSlider.maxValue = 500;
            _endSlider.steps = 501;
            _endSlider.ivalue = _tempo.endValue;
            _endSlider.addEventListener("value", {
                _tempo.endValue = _endSlider.ivalue;
                _endField.value = _tempo.endValue;
                dispatchEvent("value", false);
            });
            hlayout.addUI(_endSlider);

            _endField = new IntegerField;
            _endField.setRange(0, 500);
            _endField.value = _tempo.endValue;
            _endField.addEventListener("value", {
                _tempo.endValue = _endField.value;
                _endSlider.ivalue = _tempo.endValue;
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
            ], _tempo.spline, false);
            _splineSelector.addEventListener("value", {
                _tempo.spline = _splineSelector.value;
                _splineGraph.setSpline(_tempo.spline);
            });
            hlayout.addUI(_splineSelector);

            _splineGraph = new SplineGraph();
            _splineGraph.setSpline(_tempo.spline);
            hlayout.addUI(_splineGraph);
        }

        addEventListener("update", {
            addEventListener("clickoutside", &removeUI);
        });
    }
}
