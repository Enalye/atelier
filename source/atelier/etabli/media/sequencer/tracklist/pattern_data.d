module atelier.etabli.media.sequencer.tracklist.pattern_data;

import atelier;
import atelier.etabli.media.sequencer.tracklist.editor;
import atelier.etabli.media.sequencer.tracklist.pattern;
import atelier.etabli.ui;

package class TracklistSequencerPatternDataWindow : Modal {
    private {
        Pattern _pattern;
        SelectButton _patternSelect;
        NeutralButton _editBtn;
    }

    this(Pattern pattern, TracklistSequencerEditor editor) {
        _pattern = pattern;
        setSize(Vec2f(225f, 125f));
        setAlign(UIAlignX.left, UIAlignY.top);

        {
            Label title = new Label("Motif: " ~ pattern.name, Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 8f));
            addUI(title);
        }

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.center, UIAlignY.top);
        vbox.setChildAlign(UIAlignX.right);
        vbox.setPosition(Vec2f(0f, 32f));
        vbox.setSpacing(8f);
        addUI(vbox);

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(200f, 0f));
            vbox.addUI(hlayout);

            hlayout.addUI(new Label("Motif:", Atelier.theme.font));

            _patternSelect = new SelectButton(editor.getPatternList(), _pattern.name);
            _patternSelect.addEventListener("value", {
                _pattern.name = _patternSelect.value;
            });
            hlayout.addUI(_patternSelect);
        }
        {
            _editBtn = new NeutralButton("Editer le motif");
            _editBtn.addEventListener("click", {
                removeUI();
                editor.selectPattern(_pattern.name);
            });
            vbox.addUI(_editBtn);
        }

        addEventListener("update", {
            addEventListener("clickoutside", &removeUI);
        });
    }
}
