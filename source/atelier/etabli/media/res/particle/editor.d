module atelier.etabli.media.res.particle.editor;

import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.ui;
import atelier.world;
import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;
import atelier.etabli.media.res.entity.data;
import atelier.etabli.media.res.particle.parameter;
import atelier.etabli.media.res.particle.player;
import atelier.etabli.media.res.particle.source;

final class ParticleResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        ParameterWindow _parameterWindow;
        MediaPlayer _player;

        string _textureId;
        ParticleSystem _system;
        Particle _particle;

        Vec2f _originPosition = Vec2f.zero;
        float _zoom = 1f;
        int _time;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        _system = new ParticleSystem;
        _particle = new Particle;

        if (ffd.hasNode("texture")) {
            _textureId = ffd.getNode("texture").get!string(0);
        }

        _particle.load(_ffd);
        _particle.setup();
        _system.addParticle(_particle);

        _parameterWindow = new ParameterWindow(_system);

        _player = new MediaPlayer(_textureId, size.x, _ffd, _particle);
        addUI(_player);

        _player.addEventListener("item.select", {
            _parameterWindow.setItem(_player.getSelectedItem());
        });

        _player.addEventListener("property", {
            _textureId = _player.getTextureID();
            setDirty();

            _system.clear();
            if (_player.isRunning()) {
                _particle.setup();
                _system.addParticle(_particle);
            }
        });

        _parameterWindow.addEventListener("size", {
            _player.setWidth(getWidth() - _parameterWindow.getWidth());
        });

        _player.addEventListener("particle_start", {
            _particle.setup();
            _system.clear();
            _system.addParticle(_particle);
        });
        _player.addEventListener("particle_stop", { _system.clear(); });

        addEventListener("wheel", &_onWheel);
        addEventListener("mousedown", &_onMouseDown);
        addEventListener("mouseup", &_onMouseUp);
        addEventListener("mouseleave", {
            removeEventListener("mousemove", &_onDrag);
        });

        addEventListener("update", &_onUpdate);
        addEventListener("draw", &_onDraw);
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("particle").add(_name);
        node.addNode("texture").add(_textureId);
        foreach (key, value; _particle.getElementsInstructions()) {
            node.addNode(value);
        }
        foreach (key, value; _particle.getSourcesInstructions()) {
            node.addNode(value);
        }
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    private void _onMouseDown() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            addEventListener("mousemove", &_onDrag);
            break;
        default:
            break;
        }
    }

    private void _onMouseUp() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            removeEventListener("mousemove", &_onDrag);
            break;
        default:
            break;
        }
    }

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();
        _originPosition += ev.deltaPosition;
    }

    private void _onWheel() {
        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        float zoomDelta = 1f + (ev.wheel.sum() * 0.25f);

        Vec2f mouseOffset = getMousePosition() - getCenter();
        Vec2f delta = (mouseOffset - _originPosition) / _zoom;
        _zoom *= zoomDelta;
        _zoom = clamp(_zoom, 1f, 32f);
        Vec2f delta2 = (mouseOffset - _originPosition) / _zoom;

        _originPosition += (delta2 - delta) * _zoom;
    }

    private void _onUpdate() {
        if (_player.isRunning()) {
            _system.update();
            _time++;

            if (!_system.isPlaying()) {
                _time = 0;

                if (_player.isRepeating()) {
                    _system.clear();
                    _particle.setup();
                    _system.addParticle(_particle);
                }
                else {
                    _player.stop();
                }
            }
        }

        _player.setTime(_time);
    }

    private void _onDraw() {
        Vec2f size = getSize() - Vec2f(0f, _player.getHeight());
        Vec2f center = size / 2f;

        // dfmt off
        Vec2f shift = -((_originPosition) % (16f * _zoom));
        Vec2i checkerOffset = cast(Vec2i) (_originPosition / (16f * _zoom));
        Vec2f startPos = center - (_zoom * ((Vec2f.one * 16f).contain(size / 2f) + 11.5f) + shift);
        Vec2f endPos = startPos + _zoom * ((Vec2f.one * 16f).contain(size) + 32f);
        Vec2f blockSize = Vec2f.one * 16f * _zoom;
        for ({float y = startPos.y; int iy = 0; }  y <= endPos.y; y += blockSize.y, ++iy) {
            for ({float x = startPos.x; int ix = 0; } x <= endPos.x; x += blockSize.x, ++ix) {
                Atelier.renderer.drawRect(Vec2f(x, y), blockSize,
                ((ix + iy + checkerOffset.sum()) & 0b1) ? Atelier.theme.surface
                : Atelier.theme.container, 1f, true);
            }
        }
        // dfmt on

        center += _originPosition;
        Atelier.renderer.drawLine(Vec2f(0f, center.y), Vec2f(size.x, center.y), Color.white, 0.5f);
        Atelier.renderer.drawLine(Vec2f(center.x, 0f), Vec2f(center.x, size.y), Color.white, 0.5f);

        _system.draw(center, _zoom);
    }
}
