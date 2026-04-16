module atelier.etabli.media.res.phoneme;

import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;
import atelier.etabli.media.spectralimage;
import atelier.etabli.ui;

final class PhonemeResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        string _soundRID;
        Phoneme _phoneme;
        PhonemePlayer _phonemePlayer;
        SpectralView _spectralView;
        MediaPlayer _player;
        bool _isPlaying;
        ParameterWindow _parameterWindow;
    }

    @property {
        bool isPlaying() const {
            return _isPlaying;
        }
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);
        _phoneme = new Phoneme;

        if (ffd.hasNode("sound")) {
            _soundRID = ffd.getNode("sound").get!string(0);
        }

        if (ffd.hasNode("volume")) {
            //_volume = ffd.getNode("volume").get!float(0);
        }

        if (ffd.hasNode("offset")) {
            _phoneme.offset = ffd.getNode("offset").get!float(0);
        }

        if (ffd.hasNode("cutoff")) {
            _phoneme.cutoff = ffd.getNode("cutoff").get!float(0);
        }

        if (ffd.hasNode("consonant")) {
            _phoneme.consonant = ffd.getNode("consonant").get!float(0);
        }

        if (ffd.hasNode("vowel")) {
            _phoneme.vowel = ffd.getNode("vowel").get!float(0);
        }

        if (ffd.hasNode("isLooping")) {
            _phoneme.isLooping = ffd.getNode("isLooping").get!bool(0);
        }

        if (ffd.hasNode("attack")) {
            _phoneme.attack = ffd.getNode("attack").get!float(0);
        }

        _spectralView = new SpectralView(this);
        _spectralView.setAlign(UIAlignX.center, UIAlignY.top);
        addUI(_spectralView);

        _player = new MediaPlayer(this);
        _player.addEventListener("tool", {
            _spectralView.setTool(_player.getTool());
        });
        addUI(_player);
        _parameterWindow = new ParameterWindow(path(), _soundRID, _phoneme);
        _soundRID = _parameterWindow.getSound();
        setSoundRID(_soundRID);

        _parameterWindow.addEventListener("property_file", {
            _soundRID = _parameterWindow.getSound();
            setSoundRID(_soundRID);
            setDirty();
        });

        _parameterWindow.addEventListener("property_volume", {
            //_volume = _parameterWindow.getVolume();
            //if (_phoneme) {
            //    _phoneme.volume = _volume;
            //}
            setDirty();
        });

        _parameterWindow.addEventListener("property_data", { setDirty(); });

        addEventListener("size", &_onSize);
        addEventListener("update", &_onUpdate);
        //_parameterWindow.addEventListener("size", &_onSize);
    }

    private void _onUpdate() {
        if (_phonemePlayer && !_isPlaying) {
            if (!_phonemePlayer.isAlive)
                _phonemePlayer = null;
        }
    }

    private void _onSize() {
        _spectralView.setSize(Vec2f(getWidth(), getHeight() - 200f));
        _player.setWidth(getWidth());
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("phoneme");
        node.add(_name);
        node.addNode("sound").add(_soundRID);
        node.addNode("offset").add(_phoneme.offset);
        node.addNode("consonant").add(_phoneme.consonant);
        node.addNode("vowel").add(_phoneme.vowel);
        node.addNode("cutoff").add(_phoneme.cutoff);
        node.addNode("isLooping").add(_phoneme.isLooping);
        node.addNode("attack").add(_phoneme.attack);

        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    void play() {
        if (!_phoneme) {
            return;
        }

        _phonemePlayer = new PhonemePlayer(_phoneme, 1f);
        Atelier.audio.play(_phonemePlayer);
        _isPlaying = true;
    }

    void stop() {
        if (_phonemePlayer) {
            _isPlaying = false;
            _phonemePlayer.stop();
        }
    }

    float getPlayingPosition() const {
        if (!_phonemePlayer)
            return 0f;
        return (_phonemePlayer.currentPosition * _phoneme.sampleRate) / _phoneme.samples;
    }

    float getOffsetPosition() const {
        if (!_phoneme.sound)
            return 0f;
        return _phoneme.offset * _phoneme.sound.sampleRate / cast(float) _phoneme.sound.samples;
    }

    void setOffsetPosition(float position) {
        setDirty();

        if (!_phoneme.sound)
            return;

        _phoneme.offset = position * _phoneme.sound.samples / cast(float) _phoneme.sound.sampleRate;
        _parameterWindow.setStart(_phoneme.offset);
    }

    float getCutoffPosition() const {
        if (!_phoneme.sound)
            return 0f;
        return _phoneme.cutoff * _phoneme.sound.sampleRate / cast(float) _phoneme.sound.samples;
    }

    void setCutoffPosition(float position) {
        setDirty();

        if (!_phoneme.sound)
            return;

        _phoneme.cutoff = position * _phoneme.sound.samples / cast(float) _phoneme.sound.sampleRate;
        _parameterWindow.setEnd(_phoneme.cutoff);
    }

    void setRegionPosition(float position, float startPos) {
        setDirty();

        if (!_phoneme.sound)
            return;

        startPos = startPos * _phoneme.sound.samples / cast(float) _phoneme.sound.sampleRate;
        position = position * _phoneme.sound.samples / cast(float) _phoneme.sound.sampleRate;

        if (position < startPos) {
            _phoneme.offset = position;
            _phoneme.cutoff = startPos;
        }
        else {
            _phoneme.cutoff = position;
            _phoneme.offset = startPos;
        }

        _parameterWindow.setStart(_phoneme.offset);
        _parameterWindow.setEnd(_phoneme.cutoff);
    }

    float getConsonantPosition() const {
        if (!_phoneme.sound)
            return 0f;
        return _phoneme.consonant * _phoneme.sound.sampleRate / cast(float) _phoneme.sound.samples;
    }

    void setConsonantPosition(float position) {
        setDirty();

        if (!_phoneme.sound)
            return;

        _phoneme.consonant = position * _phoneme.sound.samples / cast(
            float) _phoneme.sound.sampleRate;
        _parameterWindow.setConsonant(_phoneme.consonant);
    }

    float getVowelPosition() const {
        if (!_phoneme.sound)
            return 0f;
        return _phoneme.vowel * _phoneme.sound.sampleRate / cast(float) _phoneme.sound.samples;
    }

    void setVowelPosition(float position) {
        setDirty();

        if (!_phoneme.sound)
            return;

        _phoneme.vowel = position * _phoneme.sound.samples / cast(float) _phoneme
            .sound.sampleRate;
        _parameterWindow.setVowel(_phoneme.vowel);
    }

    void setLoopRegionPosition(float position, float startPos) {
        setDirty();

        if (!_phoneme.sound)
            return;

        startPos = startPos * _phoneme.sound.samples / cast(float) _phoneme.sound.sampleRate;
        position = position * _phoneme.sound.samples / cast(float) _phoneme.sound.sampleRate;

        if (position < startPos) {
            _phoneme.consonant = position;
            _phoneme.vowel = startPos;
        }
        else {
            _phoneme.vowel = position;
            _phoneme.consonant = startPos;
        }

        _parameterWindow.setConsonant(_phoneme.consonant);
        _parameterWindow.setVowel(_phoneme.vowel);
    }

    void setAttackPosition(float position) {
        setDirty();

        if (!_phoneme.sound)
            return;

        _phoneme.attack = position * _phoneme.sound.samples / cast(
            float) _phoneme
            .sound.sampleRate - _phoneme.offset;
        _parameterWindow.setAttack(_phoneme.attack);
    }

    float getAttackPosition() const {
        if (!_phoneme.sound)
            return 0f;
        return (_phoneme.attack + _phoneme.offset) * _phoneme.sound.sampleRate / cast(
            float) _phoneme.sound.samples;
    }

    bool isLooping() const {
        return _phoneme.isLooping;
    }

    override void onClose() {
        stop();
    }

    void setSoundRID(string rid) {
        stop();

        _phoneme.sound = Atelier.etabli.getSound(rid);
        _phonemePlayer = null;

        if (!_phoneme.sound)
            return;

        if (_spectralView) {
            _spectralView.setSound(_phoneme.sound);
        }
    }
}

private final class ParameterWindow : UIElement {
    private {
        ResourceButton _soundSelect;
        HSlider _volumeSlider;
        Checkbox _loopCB;
        NumberField _offsetField, _cutoffField;
        NumberField _consonantField, _vowelField;
        NumberField _attackField;
        Phoneme _phoneme;
    }

    this(string resPath, string soundRID, Phoneme phoneme) {
        string p = buildNormalizedPath(relativePath(resPath, Atelier.etabli.getMediaDir()));
        auto split = pathSplitter(p);
        if (!split.empty) {
            p = split.front;
        }
        _phoneme = phoneme;

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
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Fichier:", Atelier.theme.font));

            _soundSelect = new ResourceButton(soundRID, "sound", ["sound"]);
            _soundSelect.setWidth(200f);
            _soundSelect.addEventListener("value", {
                dispatchEvent("property_file", false);
            });
            hlayout.addUI(_soundSelect);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Volume:", Atelier.theme.font));

            _volumeSlider = new HSlider;
            _volumeSlider.setWidth(200f);
            _volumeSlider.minValue = 0f;
            _volumeSlider.maxValue = 1f;
            _volumeSlider.steps = 100;
            //_volumeSlider.fvalue = volume;
            _volumeSlider.addEventListener("value", {
                dispatchEvent("property_volume", false);
            });
            hlayout.addUI(_volumeSlider);
        }

        {
            LabelSeparator sep = new LabelSeparator("Échantillon", Atelier.theme.font);
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

            hlayout.addUI(new Label("Début (sec.):", Atelier.theme.font));

            _offsetField = new NumberField;
            _offsetField.value = _phoneme.offset;
            _offsetField.addEventListener("value", {
                dispatchEvent("property_data");
            });
            hlayout.addUI(_offsetField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Fin (sec.):", Atelier.theme.font));

            _cutoffField = new NumberField;
            _cutoffField.value = _phoneme.cutoff;
            _cutoffField.addEventListener("value", {
                dispatchEvent("property_data");
            });
            hlayout.addUI(_cutoffField);
        }

        {
            LabelSeparator sep = new LabelSeparator("Boucle", Atelier.theme.font);
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

            hlayout.addUI(new Label("Boucle ?", Atelier.theme.font));

            _loopCB = new Checkbox(_phoneme.isLooping);
            _loopCB.addEventListener("value", {
                _phoneme.isLooping = _loopCB.value;
                _consonantField.isEnabled = _phoneme.isLooping;
                _vowelField.isEnabled = _phoneme.isLooping;
                dispatchEvent("property_data");
            });
            hlayout.addUI(_loopCB);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Consonne (sec.):", Atelier.theme.font));

            _consonantField = new NumberField;
            _consonantField.value = _phoneme.consonant;
            _consonantField.isEnabled = _phoneme.isLooping;
            _consonantField.addEventListener("value", {
                dispatchEvent("property_data");
            });
            hlayout.addUI(_consonantField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Voyelle (sec.):", Atelier.theme.font));

            _vowelField = new NumberField;
            _vowelField.value = _phoneme.vowel;
            _vowelField.isEnabled = _phoneme.isLooping;
            _vowelField.addEventListener("value", {
                dispatchEvent("property_data");
            });
            hlayout.addUI(_vowelField);
        }

        {
            LabelSeparator sep = new LabelSeparator("Autre", Atelier.theme.font);
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

            hlayout.addUI(new Label("Attaque (sec.):", Atelier.theme.font));

            _attackField = new NumberField;
            _attackField.value = _phoneme.attack;
            _attackField.addEventListener("value", {
                dispatchEvent("property_data");
            });
            hlayout.addUI(_attackField);
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    string getSound() const {
        return _soundSelect.getName();
    }

    void setStart(float value) {
        Atelier.ui.blockEvents = true;
        _offsetField.value = value;
        Atelier.ui.blockEvents = false;
    }

    void setEnd(float value) {
        Atelier.ui.blockEvents = true;
        _cutoffField.value = value;
        Atelier.ui.blockEvents = false;
    }

    void setConsonant(float value) {
        Atelier.ui.blockEvents = true;
        _consonantField.value = value;
        Atelier.ui.blockEvents = false;
    }

    void setVowel(float value) {
        Atelier.ui.blockEvents = true;
        _vowelField.value = value;
        Atelier.ui.blockEvents = false;
    }

    void setAttack(float value) {
        Atelier.ui.blockEvents = true;
        _attackField.value = value;
        Atelier.ui.blockEvents = false;
    }
}

private final class MediaPlayer : UIElement {
    private {
        PhonemeResourceEditor _editor;
        Container _container;
        IconButton _playBtn;
        ToolGroup _toolGroup;
        int _tool;
    }

    this(PhonemeResourceEditor editor) {
        _editor = editor;
        setSize(Vec2f(editor.getWidth(), 200f));
        setAlign(UIAlignX.center, UIAlignY.bottom);

        _container = new Container;
        _container.setSize(getSize());
        addUI(_container);

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.left, UIAlignY.top);
            hbox.setSpacing(4f);
            hbox.setPosition(Vec2f(4f, 4f));
            addUI(hbox);

            _toolGroup = new ToolGroup;

            foreach (key; [
                    "Début", "Fin", "Début + Fin", "Consonne", "Voyelle",
                    "Consonne + Voyelle", "Attaque"
                ]) {
                ToolButton btn = new ToolButton(_toolGroup, "", key);
                hbox.addUI(btn);
            }
        }

        {
            HBox hbox = new HBox;
            hbox.setAlign(UIAlignX.center, UIAlignY.center);
            hbox.setSpacing(32f);
            addUI(hbox);

            _playBtn = new IconButton("editor:play");
            _playBtn.addEventListener("mousedown", &_onPlay);
            _playBtn.addEventListener("mouseup", &_onStop);
            hbox.addUI(_playBtn);
        }

        addEventListener("size", &_onSize);
        addEventListener("update", &_onUpdate);
    }

    int getTool() const {
        return _toolGroup.value();
    }

    private void _onSize() {
        _container.setSize(getSize());
    }

    private void _onUpdate() {
        if (Atelier.input.isDown(InputEvent.KeyButton.Button.space)) {
            _onPlay();
        }
        else if (Atelier.input.isUp(InputEvent.KeyButton.Button.space)) {
            _onStop();
        }

        if (_toolGroup.value != _tool) {
            _tool = _toolGroup.value;
            dispatchEvent("tool", false);
        }
    }

    private void _onPlay() {
        _editor.play();
        _playBtn.setIcon("editor:pause");
    }

    private void _onStop() {
        _editor.stop();
        _playBtn.setIcon("editor:play");
    }
}

private final class SpectralView : UIElement {
    private {
        PhonemeResourceEditor _editor;
        SpectralImage[] _images;
        Sound _sound;
        float _zoom = 1f;
        int _tool;
        float _startToolPos = 0f;
    }

    this(PhonemeResourceEditor editor) {
        _editor = editor;
        setSize(Vec2f(_editor.getWidth(), _editor.getHeight() - 200f));
    }

    void setTool(int tool) {
        _tool = tool;
    }

    void setSound(Sound sound) {
        if (_sound != sound) {
            _sound = sound;
            _zoom = 1f;
            _images.length = 0;
            clearImages();

            removeEventListener("size", &_onSize);
            removeEventListener("wheel", &_onWheel);
            removeEventListener("mousedown", &_onMouseDown);
            removeEventListener("mouseup", &_onMouseUp);
            removeEventListener("draw", &_onDraw);
            removeEventListener("mousemove", &_onSetOffsetPosition);
            removeEventListener("mousemove", &_onSetCutoffPosition);
            removeEventListener("mousemove", &_onSetRegionPosition);
            removeEventListener("mousemove", &_onSetConsonantPosition);
            removeEventListener("mousemove", &_onSetVowelPosition);
            removeEventListener("mousemove", &_onSetLoopRegionPosition);
            removeEventListener("mousemove", &_onSetAttackPosition);

            if (_sound) {
                for (int channel; channel < _sound.channels; ++channel) {
                    SpectralImage image = new SpectralImage(Vec2f(getWidth(),
                            getHeight() / _sound.channels), _sound, 0);
                    image.anchor = Vec2f(.5f, 0f);
                    image.position = Vec2f(getCenter().x, channel * (getHeight() / _sound.channels));
                    addImage(image);

                    _images ~= image;
                }

                addEventListener("size", &_onSize);
                addEventListener("wheel", &_onWheel);
                addEventListener("mousedown", &_onMouseDown);
                addEventListener("mouseup", &_onMouseUp);
                addEventListener("draw", &_onDraw);
            }
        }
    }

    private void _onSize() {
        for (int channel; channel < _sound.channels; ++channel) {
            float ratio = _images[channel].virtualSize / _images[channel].size.x;
            _images[channel].size = Vec2f(getWidth(), getHeight() / _sound.channels);
            _images[channel].virtualSize = _images[channel].size.x * ratio;
            _images[channel].position = Vec2f(getCenter().x,
                channel * (getHeight() / _sound.channels));
        }
    }

    private void _onWheel() {
        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        float zoomDelta = 1f + (ev.wheel.sum() * 0.25f);
        _zoom *= zoomDelta;

        float mouseOffset = getMousePosition().x - getCenter().x;
        for (int channel; channel < _sound.channels; ++channel) {
            float delta = mouseOffset / _images[channel].virtualSize;
            _images[channel].virtualSize = _images[channel].size.x * _zoom;
            float delta2 = mouseOffset / _images[channel].virtualSize;

            float pos = _images[channel].virtualPosition + (delta - delta2);
            pos = clamp(pos, 0f, 1f);
            _images[channel].virtualPosition = pos;
        }
    }

    private void _onMouseDown() {
        UIManager manager = getManager();
        InputEvent.MouseButton ev = manager.input.asMouseButton();

        if (ev.button == InputEvent.MouseButton.Button.right) {
            addEventListener("mousemove", &_onDrag);
        }
        else if (ev.button == InputEvent.MouseButton.Button.left) {
            switch (_tool) {
            case 0:
                addEventListener("mousemove", &_onSetOffsetPosition);
                _onSetOffsetPosition();
                break;
            case 1:
                addEventListener("mousemove", &_onSetCutoffPosition);
                _onSetCutoffPosition();
                break;
            case 2:
                addEventListener("mousemove", &_onSetRegionPosition);
                _startToolPos = _getMousePos();
                _editor.setOffsetPosition(_startToolPos);
                _editor.setCutoffPosition(_startToolPos);
                break;
            case 3:
                addEventListener("mousemove", &_onSetConsonantPosition);
                _onSetConsonantPosition();
                break;
            case 4:
                addEventListener("mousemove", &_onSetVowelPosition);
                _onSetVowelPosition();
                break;
            case 5:
                addEventListener("mousemove", &_onSetLoopRegionPosition);
                _startToolPos = _getMousePos();
                _editor.setConsonantPosition(_startToolPos);
                _editor.setVowelPosition(_startToolPos);
                break;
            case 6:
                addEventListener("mousemove", &_onSetAttackPosition);
                _startToolPos = _getMousePos();
                _editor.setAttackPosition(_startToolPos);
                break;
            default:
                break;
            }
        }
    }

    private void _onMouseUp() {
        UIManager manager = getManager();
        InputEvent.MouseButton ev = manager.input.asMouseButton();

        if (ev.button == InputEvent.MouseButton.Button.right) {
            removeEventListener("mousemove", &_onDrag);
        }
        else if (ev.button == InputEvent.MouseButton.Button.left) {
            switch (_tool) {
            case 0:
                removeEventListener("mousemove", &_onSetOffsetPosition);
                _onSetOffsetPosition();
                break;
            case 1:
                removeEventListener("mousemove", &_onSetCutoffPosition);
                _onSetCutoffPosition();
                break;
            case 2:
                removeEventListener("mousemove", &_onSetRegionPosition);
                _onSetRegionPosition();
                break;
            case 3:
                removeEventListener("mousemove", &_onSetConsonantPosition);
                _onSetConsonantPosition();
                break;
            case 4:
                removeEventListener("mousemove", &_onSetVowelPosition);
                _onSetVowelPosition();
                break;
            case 5:
                removeEventListener("mousemove", &_onSetLoopRegionPosition);
                _onSetLoopRegionPosition();
                break;
            case 6:
                removeEventListener("mousemove", &_onSetAttackPosition);
                _onSetAttackPosition();
                break;
            default:
                break;
            }
        }
    }

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();

        for (int channel; channel < _sound.channels; ++channel) {
            float pos = _images[channel].virtualPosition;
            pos -= ev.deltaPosition.x / _images[channel].virtualSize;
            pos = clamp(pos, 0f, 1f);
            _images[channel].virtualPosition = pos;
        }
    }

    private void _onSetOffsetPosition() {
        float pos = _getMousePos();
        _editor.setOffsetPosition(pos);
    }

    private void _onSetCutoffPosition() {
        float pos = _getMousePos();
        _editor.setCutoffPosition(pos);
    }

    private void _onSetConsonantPosition() {
        float pos = _getMousePos();
        _editor.setConsonantPosition(pos);
    }

    private void _onSetVowelPosition() {
        float pos = _getMousePos();
        _editor.setVowelPosition(pos);
    }

    private void _onSetRegionPosition() {
        float pos = _getMousePos();
        _editor.setRegionPosition(pos, _startToolPos);
    }

    private void _onSetLoopRegionPosition() {
        float pos = _getMousePos();
        _editor.setLoopRegionPosition(pos, _startToolPos);
    }

    private void _onSetAttackPosition() {
        float pos = _getMousePos();
        _editor.setAttackPosition(pos);
    }

    private void _onDraw() {
        if (_images.length > 0) {
            float playPos = 0f;

            playPos = _editor.getPlayingPosition();
            playPos *= _images[0].virtualSize;
            playPos -= _images[0].virtualPosition * _images[0].virtualSize;
            playPos += getWidth() / 2f;
            Atelier.renderer.drawRect(Vec2f(playPos, 0f), Vec2f(1f,
                    getHeight()), Atelier.theme.onAccent, 1f, true);

            float offsetPos;
            {
                playPos = _editor.getOffsetPosition();
                playPos *= _images[0].virtualSize;
                playPos -= _images[0].virtualPosition * _images[0].virtualSize;
                playPos += getWidth() / 2f;
                if (playPos > 0f) {
                    Atelier.renderer.drawRect(Vec2f(0f, 0f), Vec2f(playPos,
                            getHeight()), Color.blue, 0.4f, true);
                }
                offsetPos = playPos;
            }

            {
                playPos = _editor.getCutoffPosition();
                playPos *= _images[0].virtualSize;
                playPos -= _images[0].virtualPosition * _images[0].virtualSize;
                playPos += getWidth() / 2f;
                if (playPos < getWidth()) {
                    Atelier.renderer.drawRect(Vec2f(playPos, 0f), Vec2f(getWidth() - playPos,
                            getHeight()), Color.blue, 0.4f, true);
                }
            }

            float consonantPos;
            if (_editor.isLooping()) {
                playPos = _editor.getConsonantPosition();
                playPos *= _images[0].virtualSize;
                playPos -= _images[0].virtualPosition * _images[0].virtualSize;
                playPos += getWidth() / 2f;

                if (offsetPos < playPos && playPos > 0f) {
                    Atelier.renderer.drawRect(Vec2f(offsetPos, 0f), Vec2f(playPos - offsetPos,
                            getHeight()), Color.pink, 0.15f, true);
                }

                Atelier.renderer.drawRect(Vec2f(playPos, 0f), Vec2f(1f,
                        getHeight()), Color.red, 1f, true);

                consonantPos = playPos;
            }

            if (_editor.isLooping()) {
                playPos = _editor.getVowelPosition();
                playPos *= _images[0].virtualSize;
                playPos -= _images[0].virtualPosition * _images[0].virtualSize;
                playPos += getWidth() / 2f;

                if (consonantPos < playPos && playPos > 0f) {
                    Atelier.renderer.drawRect(Vec2f(consonantPos, 0f), Vec2f(playPos - consonantPos,
                            getHeight()), Color.yellow, 0.1f, true);
                }

                Atelier.renderer.drawRect(Vec2f(playPos, 0f), Vec2f(1f,
                        getHeight()), Color.yellow, 1f, true);
            }

            {
                playPos = _editor.getAttackPosition();
                playPos *= _images[0].virtualSize;
                playPos -= _images[0].virtualPosition * _images[0].virtualSize;
                playPos += getWidth() / 2f;
                if (playPos < getWidth()) {
                    Atelier.renderer.drawRect(Vec2f(playPos, 0f), Vec2f(1f,
                            getHeight()), Color.white, 1f, true);
                }
            }
        }
    }

    private float _getMousePos() {
        float pos = _images[0].virtualPosition;
        float mouseOffset = getMousePosition().x - getCenter().x;
        pos += mouseOffset / _images[0].virtualSize;
        pos = clamp(pos, 0f, 1f);
        return pos;
    }
}
