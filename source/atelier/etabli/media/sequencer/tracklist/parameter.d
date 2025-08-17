module atelier.etabli.media.sequencer.tracklist.parameter;

import atelier;
import atelier.etabli.core;
import atelier.etabli.ui;

package final class TracklistSequencerParameterWindow : UIElement {
    private {
        IntegerField _blocksField;
        AccentButton _playBtn;
        DangerButton _recordBtn;
    }

    this(uint blocks) {
        VList vlist = new VList;
        vlist.setPosition(Vec2f(8f, 8f));
        vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        vlist.setAlign(UIAlignX.left, UIAlignY.top);
        vlist.setColor(Atelier.theme.surface);
        vlist.setSpacing(8f);
        vlist.setChildAlign(UIAlignX.left);
        addUI(vlist);

        {
            LabelSeparator sep = new LabelSeparator("Propriétés", Atelier.theme.font);
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
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            _playBtn = new AccentButton("Lecture");
            _playBtn.addEventListener("click", {
                play();
                dispatchEvent("property_play", false);
            });
            hlayout.addUI(_playBtn);

            _recordBtn = new DangerButton("Enregistrer");
            _recordBtn.addEventListener("click", {
                record();
                dispatchEvent("property_record", false);
            });
            hlayout.addUI(_recordBtn);
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
            _recordBtn.isEnabled = true;
        }
    }

    private void _onRecordMidi() {
        if (!midiIsPlaying()) {
            _recordBtn.removeEventListener("update", &_onPlayMidi);
            _recordBtn.setText("Enregistrer");
            _playBtn.isEnabled = true;
        }
    }

    void play() {
        if (!midiIsPlaying()) {
            _recordBtn.isEnabled = false;
            _playBtn.setText("Pause");
            _playBtn.addEventListener("update", &_onPlayMidi);
        }
    }

    void record() {
        if (!midiIsPlaying()) {
            _playBtn.isEnabled = false;
            _recordBtn.setText("Annuler");
            _recordBtn.addEventListener("update", &_onRecordMidi);
        }
    }

    uint getBlocks() {
        return _blocksField.value();
    }
}
