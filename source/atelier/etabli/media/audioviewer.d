module atelier.etabli.media.audioviewer;

import std.conv : to;
import std.math;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.etabli.media.base;
import atelier.etabli.media.spectralimage;

final class AudioViewer : ContentEditor {
    private {
        Sound _sound;
        Music _music;
        MusicPlayer _musicPlayer;
        SpectralView _spectralView;
        MediaPlayer _player;
        bool _isPlaying;
        float _startPosition = 0f;
    }

    @property {
        bool isPlaying() const {
            return _isPlaying;
        }
    }

    this(string path_, Vec2f windowSize) {
        super(path_, windowSize);

        _sound = Sound.fromFile(path_);

        _spectralView = new SpectralView(this);
        _spectralView.setAlign(UIAlignX.center, UIAlignY.top);
        addUI(_spectralView);

        _player = new MediaPlayer(this);
        addUI(_player);

        addEventListener("size", &_onSize);
    }

    private void _onSize() {
        _spectralView.setSize(Vec2f(getWidth(), getHeight() - 200f));
        _player.setWidth(getWidth());
    }

    void play() {
        if (!_music) {
            _music = Music.fromFile(path());
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
}

private final class MediaPlayer : UIElement {
    private {
        AudioViewer _viewer;
        Container _container;
        IconButton _playBtn, _stopBtn;
    }

    this(AudioViewer viewer) {
        _viewer = viewer;
        setSize(Vec2f(viewer.getWidth(), 200f));
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
        _viewer.play();
        if (_viewer.isPlaying) {
            _playBtn.setIcon("editor:pause");
        }
        else {
            _playBtn.setIcon("editor:play");
        }
    }

    private void _onStop() {
        _viewer.stop();
        _playBtn.setIcon("editor:play");
    }
}

private final class SpectralView : UIElement {
    private {
        AudioViewer _viewer;
        SpectralImage[] _images;
        float _zoom = 1f;
    }

    this(AudioViewer viewer) {
        _viewer = viewer;
        setSize(Vec2f(_viewer.getWidth(), _viewer.getHeight() - 200f));

        for (int channel; channel < _viewer._sound.channels; ++channel) {
            SpectralImage image = new SpectralImage(Vec2f(getWidth(),
                    getHeight() / _viewer._sound.channels), _viewer._sound, 0);
            image.anchor = Vec2f(.5f, 0f);
            image.position = Vec2f(getCenter().x, channel * (getHeight() / _viewer._sound.channels));
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

    private void _onSize() {
        for (int channel; channel < _viewer._sound.channels; ++channel) {
            float ratio = _images[channel].virtualSize / _images[channel].size.x;
            _images[channel].size = Vec2f(getWidth(), getHeight() / _viewer._sound.channels);
            _images[channel].virtualSize = _images[channel].size.x * ratio;
            _images[channel].position = Vec2f(getCenter().x,
                channel * (getHeight() / _viewer._sound.channels));
        }
    }

    private void _onWheel() {
        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        float zoomDelta = 1f + (ev.wheel.sum() * 0.25f);
        _zoom *= zoomDelta;

        float mouseOffset = getMousePosition().x - getCenter().x;
        for (int channel; channel < _viewer._sound.channels; ++channel) {
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

        for (int channel; channel < _viewer._sound.channels; ++channel) {
            float pos = _images[channel].virtualPosition;
            pos -= ev.deltaPosition.x / _images[channel].virtualSize;
            pos = clamp(pos, 0f, 1f);
            _images[channel].virtualPosition = pos;
        }
    }

    private void _onDraw() {
        if (_images.length > 0) {
            float playPos = _viewer.getStartPosition();
            playPos *= _images[0].virtualSize;
            playPos -= _images[0].virtualPosition * _images[0].virtualSize;
            playPos += getWidth() / 2f;
            Atelier.renderer.drawRect(Vec2f(playPos, 0f), Vec2f(1f,
                    getHeight()), Atelier.theme.foreground, 1f, true);

            playPos = _viewer.getPlayingPosition();
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
            _viewer.setStartPosition(pos);
        }
    }
}
