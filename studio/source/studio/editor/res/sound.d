/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editor.res.sound;

import std.file;
import std.path;
import std.math : abs;
import atelier;
import farfadet;
import studio.editor.res.base;
import studio.editor.res.editor;
import studio.editor.spectralimage;
import studio.project;
import studio.ui;

final class SoundResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        string _filePath, _fullFilePath;
        float _volume;
        Sound _sound;
        Music _music;
        MusicPlayer _musicPlayer;
        SpectralView _spectralView;
        MediaPlayer _player;
        bool _isPlaying;
        float _startPosition = 0f;
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

        if (ffd.hasNode("file")) {
            _filePath = ffd.getNode("file").get!string(0);
        }

        _volume = 1f;
        if (ffd.hasNode("volume")) {
            _volume = ffd.getNode("volume").get!float(0);
        }

        _spectralView = new SpectralView(this);
        _spectralView.setAlign(UIAlignX.center, UIAlignY.top);
        addUI(_spectralView);

        _player = new MediaPlayer(this);
        addUI(_player);
        _parameterWindow = new ParameterWindow(path(), _filePath, _volume);
        _filePath = _parameterWindow.getFile();
        setFile(_filePath);

        _parameterWindow.addEventListener("property_file", {
            _filePath = _parameterWindow.getFile();
            setFile(_filePath);
            setDirty();
        });

        _parameterWindow.addEventListener("property_volume", {
            _volume = _parameterWindow.getVolume();
            if (_music) {
                _music.volume = _volume;
            }
            setDirty();
        });

        addEventListener("size", &_onSize);
        //_parameterWindow.addEventListener("size", &_onSize);
    }

    private void _onSize() {
        _spectralView.setSize(Vec2f(getWidth(), getHeight() - 200f));
        _player.setWidth(getWidth());
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("sound");
        node.add(_name);
        node.addNode("file").add(_filePath);
        node.addNode("volume").add(_volume);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    void play() {
        if (!_music && _fullFilePath.length && exists(_fullFilePath)) {
            _music = Music.fromFile(_fullFilePath);
            _music.volume = _volume;
        }

        if (!_musicPlayer) {
            _musicPlayer = new MusicPlayer(_music, 0f,
                _startPosition * _music.samples / _music.sampleRate);
            Atelier.audio.play(_musicPlayer);
            _isPlaying = true;
        }
        else if (_isPlaying) {
            _isPlaying = false;
            _musicPlayer.pause();
        }
        else {
            _isPlaying = true;
            _musicPlayer.resume();
        }
    }

    void stop() {
        if (_musicPlayer) {
            _isPlaying = false;
            _musicPlayer.stop();
            _musicPlayer = null;
        }
    }

    float getPlayingPosition() const {
        if (!_musicPlayer)
            return 0f;
        return (_musicPlayer.currentPosition * _music.sampleRate) / _music.samples;
    }

    float getStartPosition() const {
        return _startPosition;
    }

    void setStartPosition(float position) {
        _startPosition = position;

        if (isPlaying()) {
            if (_musicPlayer) {
                _musicPlayer.stop();
                _musicPlayer = new MusicPlayer(_music, 0f,
                    _startPosition * _music.samples / _music.sampleRate);
                Atelier.audio.play(_musicPlayer);
                _isPlaying = true;
            }
        }
    }

    override void onClose() {
        stop();
    }

    void setFile(string filePath) {
        stop();

        if (!filePath.length)
            return;

        filePath = buildNormalizedPath(dirName(path()), filePath);

        if (!exists(filePath))
            return;

        _fullFilePath = filePath;
        _sound = Sound.fromFile(_fullFilePath);
        _musicPlayer = null;
        _music = null;
        if (_spectralView) {
            _spectralView.setSound(_sound);
        }
    }
}

private final class ParameterWindow : UIElement {
    private {
        SelectButton _fileSelect;
        HSlider _volumeSlider;
    }

    this(string resPath, string filePath, float volume) {
        string p = buildNormalizedPath(relativePath(resPath, Project.getMediaDir()));
        auto split = pathSplitter(p);
        if (!split.empty) {
            p = split.front;
        }

        string dir = dirName(resPath);
        auto entries = dirEntries(buildNormalizedPath(Project.getMediaDir(), p), SpanMode.depth);
        string[] files;
        foreach (entry; entries) {
            if (!entry.isDir) {
                switch (extension(entry)) {
                case ".ogg":
                case ".wav":
                case ".mp3":
                    files ~= relativePath(entry, dir);
                    break;
                default:
                    break;
                }
            }
        }

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

            _fileSelect = new SelectButton(files, filePath);
            _fileSelect.setWidth(200f);
            _fileSelect.addEventListener("value", {
                dispatchEvent("property_file", false);
            });
            hlayout.addUI(_fileSelect);
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
            _volumeSlider.fvalue = volume;
            _volumeSlider.addEventListener("value", {
                dispatchEvent("property_volume", false);
            });
            hlayout.addUI(_volumeSlider);
        }

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    string getFile() const {
        return _fileSelect.value();
    }

    float getVolume() const {
        return _volumeSlider.fvalue;
    }
}

private final class MediaPlayer : UIElement {
    private {
        SoundResourceEditor _editor;
        Container _container;
        IconButton _playBtn, _stopBtn;
    }

    this(SoundResourceEditor editor) {
        _editor = editor;
        setSize(Vec2f(editor.getWidth(), 200f));
        setAlign(UIAlignX.center, UIAlignY.bottom);

        _container = new Container;
        _container.setSize(getSize());
        addUI(_container);

        HBox hbox = new HBox;
        hbox.setAlign(UIAlignX.center, UIAlignY.center);
        hbox.setSpacing(32f);
        addUI(hbox);

        _playBtn = new IconButton("editor:play");
        _playBtn.addEventListener("click", &_onPlay);
        hbox.addUI(_playBtn);

        _stopBtn = new IconButton("editor:stop");
        _stopBtn.addEventListener("click", &_onStop);
        hbox.addUI(_stopBtn);

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

    private void _onPlay() {
        _editor.play();
        if (_editor.isPlaying) {
            _playBtn.setIcon("editor:pause");
        }
        else {
            _playBtn.setIcon("editor:play");
        }
    }

    private void _onStop() {
        _editor.stop();
        _playBtn.setIcon("editor:play");
    }
}

private final class SpectralView : UIElement {
    private {
        SoundResourceEditor _editor;
        SpectralImage[] _images;
        Sound _sound;
        float _zoom = 1f;
    }

    this(SoundResourceEditor editor) {
        _editor = editor;
        setSize(Vec2f(_editor.getWidth(), _editor.getHeight() - 200f));
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
            removeEventListener("click", &_onClick);

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
                addEventListener("click", &_onClick);
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
    }

    private void _onMouseUp() {
        UIManager manager = getManager();
        InputEvent.MouseButton ev = manager.input.asMouseButton();

        if (ev.button == InputEvent.MouseButton.Button.right) {
            removeEventListener("mousemove", &_onDrag);
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

    private void _onDraw() {
        if (_images.length > 0) {
            float playPos = _editor.getStartPosition();
            playPos *= _images[0].virtualSize;
            playPos -= _images[0].virtualPosition * _images[0].virtualSize;
            playPos += getWidth() / 2f;
            Atelier.renderer.drawRect(Vec2f(playPos, 0f), Vec2f(1f,
                    getHeight()), Atelier.theme.foreground, 1f, true);

            playPos = _editor.getPlayingPosition();
            playPos *= _images[0].virtualSize;
            playPos -= _images[0].virtualPosition * _images[0].virtualSize;
            playPos += getWidth() / 2f;
            Atelier.renderer.drawRect(Vec2f(playPos, 0f), Vec2f(1f,
                    getHeight()), Atelier.theme.onAccent, 1f, true);
        }
    }

    private void _onClick() {
        UIManager manager = getManager();
        InputEvent.MouseButton ev = manager.input.asMouseButton();

        if (ev.button == InputEvent.MouseButton.Button.left) {
            float pos = _images[0].virtualPosition;
            float mouseOffset = getMousePosition().x - getCenter().x;
            pos += mouseOffset / _images[0].virtualSize;
            pos = clamp(pos, 0f, 1f);
            _editor.setStartPosition(pos);
        }
    }
}
