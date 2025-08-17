module atelier.etabli.media.sequencer.pattern.velocity;

import atelier;
import atelier.etabli.media.sequencer.pattern.editor;
import atelier.etabli.media.sequencer.pattern.note;

package class PatternSequencerVelocityWindow : Modal {
    private {
        Note _note;
        IntegerField _field;
        HSlider _slider;
    }

    this(Note note) {
        _note = note;
        setSize(Vec2f(250f, 75f));
        setAlign(UIAlignX.left, UIAlignY.top);

        {
            Label title = new Label("Vélocité", Atelier.theme.font);
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

            _slider = new HSlider;
            _slider.setWidth(128f);
            _slider.minValue = 0;
            _slider.maxValue = 127;
            _slider.steps = 128;
            _slider.ivalue = _note.velocity;
            _slider.addEventListener("value", {
                _note.velocity = _slider.ivalue;
                _field.value = _note.velocity;
                dispatchEvent("value", false);
            });
            hbox.addUI(_slider);

            _field = new IntegerField;
            _field.setRange(0, 127);
            _field.value = _note.velocity;
            _field.addEventListener("value", {
                _note.velocity = _field.value;
                _slider.ivalue = _note.velocity;
                dispatchEvent("value", false);
            });
            hbox.addUI(_field);
        }

        addEventListener("update", {
            addEventListener("clickoutside", &removeUI);
        });
    }
}
