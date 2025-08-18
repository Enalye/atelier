module atelier.etabli.media.res.particle.player;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.etabli.ui;
import atelier.etabli.media.res.particle.editor;
import atelier.etabli.media.res.entity_render;

package final class MediaPlayer : UIElement {
    private {
        Container _container;
        IconButton _playBtn, _emitBtn, _clearBtn, _reloadBtn;
        SelectButton _imgSelect;
        IntegerField _delayField;
        bool _isPlaying;
    }

    @property {
        bool isRunning() const {
            return _isPlaying;
        }
    }

    this() {
        setSize(Vec2f(getParentWidth(), 200f));
        setAlign(UIAlignX.center, UIAlignY.bottom);

        _container = new Container;
        _container.setSize(getSize());
        addUI(_container);

        HBox hbox = new HBox;
        hbox.setAlign(UIAlignX.center, UIAlignY.center);
        hbox.setSpacing(32f);
        addUI(hbox);

        {
            VBox vbox = new VBox;
            vbox.setChildAlign(UIAlignX.left);
            hbox.addUI(vbox);

            vbox.addUI(new Label("Délai par Trame:", Atelier.theme.font));

            _delayField = new IntegerField;
            _delayField.setMinValue(1);
            vbox.addUI(_delayField);
        }

        _playBtn = new IconButton("editor:play");
        _playBtn.addEventListener("click", &_onPlay);
        hbox.addUI(_playBtn);

        _emitBtn = new IconButton("editor:play-once");
        _emitBtn.addEventListener("click", &_onEmit);
        hbox.addUI(_emitBtn);

        _clearBtn = new IconButton("editor:clear");
        _clearBtn.addEventListener("click", &_onClear);
        hbox.addUI(_clearBtn);

        _reloadBtn = new IconButton("editor:reload");
        _reloadBtn.addEventListener("click", &_onReload);
        hbox.addUI(_reloadBtn);

        {
            _imgSelect = new SelectButton([], "");
            _imgSelect.addEventListener("value", {
                dispatchEvent("particle_graphic", false);
            });
            hbox.addUI(_imgSelect);
        }

        addEventListener("size", &_onSize);
        addEventListener("update", &_onUpdate);
    }

    private void _onSize() {
        _container.setSize(getSize());
    }

    private void _onUpdate() {
        if (Atelier.input.isDown(InputEvent.KeyButton.Button.space)) {
            _onPlay();
        }
    }

    void stop() {
        if (_isPlaying) {
            _isPlaying = false;
            _playBtn.setIcon("editor:play");
        }
    }

    private void _onPlay() {
        if (_isPlaying) {
            _isPlaying = false;
            _playBtn.setIcon("editor:play");
            dispatchEvent("particle_stop", false);
        }
        else {
            _isPlaying = true;
            _playBtn.setIcon("editor:pause");
            dispatchEvent("particle_start", false);
        }
    }

    private void _onEmit() {
        dispatchEvent("particle_emit", false);
    }

    private void _onClear() {
        dispatchEvent("particle_clear", false);
    }

    private void _onReload() {
        version (AtelierEtabli) {
            Atelier.script.setCustomFiles(Atelier.etabli.getScripts());
            Atelier.script.reload();
            Atelier.script.start();
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
}
