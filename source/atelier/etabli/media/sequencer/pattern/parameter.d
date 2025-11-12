module atelier.etabli.media.sequencer.pattern.parameter;

import atelier.common;
import atelier.core;
import atelier.ui;
import atelier.render;

import atelier.etabli.core;
import atelier.etabli.ui;

package final class PatternSequencerParameterWindow : UIElement {
    private {
        ResourceButton _instrumentSelect;
        IntegerField _stepsField, _barsField, _bpmField, _blocksField;
        IntegerField[] _initializationFields;
        SelectButton _scaleSelect, _tonicSelect;
        AccentButton _playBtn;
    }

    this(string instrument, uint steps, uint bars, uint bpm, uint blocks,
        string scale, string tonic, int[] initializationValues) {
        VList vlist = new VList;
        vlist.setPosition(Vec2f(8f, 8f));
        vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        vlist.setAlign(UIAlignX.left, UIAlignY.top);
        vlist.setColor(Atelier.theme.surface);
        vlist.setSpacing(8f);
        vlist.setChildAlign(UIAlignX.left);
        addUI(vlist);

        {
            LabelSeparator sep = new LabelSeparator("Aperçu", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            _blocksField = new IntegerField();
            _blocksField.setMinValue(1);
            _blocksField.value = blocks;
            _blocksField.addEventListener("value", {
                dispatchEvent("property", false);
            });

            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Blocs:", Atelier.theme.font));
            hlayout.addUI(_blocksField);
        }

        {
            _bpmField = new IntegerField();
            _bpmField.setMinValue(1);
            _bpmField.value = bpm;
            _bpmField.addEventListener("value", {
                dispatchEvent("property", false);
            });

            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("BPM:", Atelier.theme.font));
            hlayout.addUI(_bpmField);
        }

        {
            _playBtn = new AccentButton("Lecture");
            _playBtn.addEventListener("click", {
                play();
                dispatchEvent("property_play", false);
            });
            vlist.addList(_playBtn);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Gamme:", Atelier.theme.font));

            _scaleSelect = new SelectButton(["chromatic"], scale);
            _scaleSelect.addEventListener("value", {
                dispatchEvent("property", false);
            });
            hlayout.addUI(_scaleSelect);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Fondamentale:", Atelier.theme.font));

            _tonicSelect = new SelectButton([
                "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"
            ], tonic);
            _tonicSelect.addEventListener("value", {
                dispatchEvent("property", false);
            });
            hlayout.addUI(_tonicSelect);
        }

        {
            LabelSeparator sep = new LabelSeparator("Propriétés", Atelier.theme.font);
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

            hlayout.addUI(new Label("Instrument:", Atelier.theme.font));

            _instrumentSelect = new ResourceButton(instrument, "instrument", [
                    "instrument"
                ]);
            _instrumentSelect.addEventListener("value", {
                dispatchEvent("property", false);
            });
            hlayout.addUI(_instrumentSelect);
        }

        {
            _stepsField = new IntegerField();
            _stepsField.setMinValue(1);
            _stepsField.value = steps;
            _stepsField.addEventListener("value", {
                dispatchEvent("property", false);
            });

            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Divisions:", Atelier.theme.font));
            hlayout.addUI(_stepsField);
        }

        {
            _barsField = new IntegerField();
            _barsField.setMinValue(1);
            _barsField.value = bars;
            _barsField.addEventListener("value", {
                dispatchEvent("property", false);
            });

            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Div. par mesure:", Atelier.theme.font));
            hlayout.addUI(_barsField);
        }

        {
            LabelSeparator sep = new LabelSeparator("Initialisation", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        immutable string[] titles = [
            "After Touch", "Pitch Bend", "Modulation", "Portamento Time",
            "Volume", "Panpot", "Expression", "Hold 1", "Portamento",
            "Sostenuto", "Soft", "Legato Foot Switch", "Resonance",
            "Release Time", "Attack Time", "Cutoff", "Decay Time",
            "Vibrato Rate", "Vibrato Depth", "Vibrato Delay",
            "Portamento Control", "Reverb", "Chorus",
        ];

        for (uint i; i < titles.length; ++i) {
            IntegerField field = new IntegerField();

            uint minValue, maxValue;
            switch (i) {
            case 1: // Pitch Bend
                minValue = -8192;
                maxValue = 8191;
                break;
            case 5: // Panning
                minValue = -64;
                maxValue = 63;
                break;
            default:
                minValue = 0;
                maxValue = 127;
                break;
            }

            uint defaultValue;
            if (i < initializationValues.length) {
                defaultValue = initializationValues[i];
            }
            else {
                switch (i) {
                case 6: // Expression
                    defaultValue = 127;
                    break;
                case 4: // Volume
                    defaultValue = 100;
                    break;
                default:
                    defaultValue = 0;
                    break;
                }
            }
            field.setRange(minValue, maxValue);
            field.value = defaultValue;
            field.addEventListener("value", { dispatchEvent("property", false); });

            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label(titles[i] ~ ":", Atelier.theme.font));
            hlayout.addUI(field);

            _initializationFields ~= field;
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    private void _onPlayMidi() {
        if (!midiIsPlaying()) {
            _playBtn.removeEventListener("update", &_onPlayMidi);
            _playBtn.setText("Lecture");
        }
    }

    void play() {
        if (!midiIsPlaying()) {
            _playBtn.setText("Pause");
            _playBtn.addEventListener("update", &_onPlayMidi);
        }
    }

    string getInstrument() {
        return _instrumentSelect.getName();
    }

    uint getSteps() {
        return _stepsField.value();
    }

    uint getBars() {
        return _barsField.value();
    }

    uint getBPM() {
        return _bpmField.value();
    }

    uint getBlocks() {
        return _blocksField.value();
    }

    string getScale() {
        return _scaleSelect.value();
    }

    string getTonic() {
        return _tonicSelect.value();
    }

    int[] getInitializationValues() {
        int[] result;
        foreach (IntegerField field; _initializationFields) {
            result ~= field.value();
        }
        return result;
    }
}
