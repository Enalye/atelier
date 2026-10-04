module atelier.etabli.media.res.entity.toolbox;

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
import atelier.etabli.media.res.entity.data;

package class Toolbox : Modal {
    private {
        SelectButton _imgSelect;
        Knob _dirKnob;
    }

    this() {
        setSize(Vec2f(256f, 300f));
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
            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            vbox.addUI(hbox);

            hbox.addUI(new Label("Graphique:", Atelier.theme.font));

            _imgSelect = new SelectButton([], "");
            _imgSelect.addEventListener("value", {
                dispatchEvent("toolbox", false);
            });
            hbox.addUI(_imgSelect);
        }

        {
            _dirKnob = new Knob;
            _dirKnob.setSize(Vec2f(128f, 128f));
            _dirKnob.setRange(0f, 360f);
            _dirKnob.setAngleOffset(180f);
            _dirKnob.value = 0f;
            vbox.addUI(_dirKnob);
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            vbox.addUI(hbox);

            IconButton playBtn = new IconButton("editor:play");
            playBtn.addEventListener("click", {
                dispatchEvent("toolbox_resume", false);
            });
            hbox.addUI(playBtn);

            IconButton pauseBtn = new IconButton("editor:pause");
            pauseBtn.addEventListener("click", {
                dispatchEvent("toolbox_pause", false);
            });
            hbox.addUI(pauseBtn);

            IconButton startBtn = new IconButton("editor:play-back");
            startBtn.addEventListener("click", {
                dispatchEvent("toolbox_start", false);
            });
            hbox.addUI(startBtn);

            IconButton stopBtn = new IconButton("editor:stop");
            stopBtn.addEventListener("click", {
                dispatchEvent("toolbox_stop", false);
            });
            hbox.addUI(stopBtn);
        }

        {
            HBox hbox = new HBox;
            hbox.setSpacing(4f);
            vbox.addUI(hbox);

            NeutralButton nextTickBtn = new NeutralButton("Tick suivant");
            nextTickBtn.addEventListener("click", {
                dispatchEvent("toolbox_nextTick", false);
            });
            hbox.addUI(nextTickBtn);

            NeutralButton nextFrameBtn = new NeutralButton("Frame suivante");
            nextFrameBtn.addEventListener("click", {
                dispatchEvent("toolbox_nextFrame", false);
            });
            hbox.addUI(nextFrameBtn);
        }
    }

    void setRenders(EntityRenderData[] renders) {
        string[] imgs;
        foreach (render; renders) {
            imgs ~= render.name();
        }
        _imgSelect.setItems(imgs);
    }

    size_t getRender() {
        return _imgSelect.ivalue();
    }

    float getDir() {
        return _dirKnob.value;
    }
}
