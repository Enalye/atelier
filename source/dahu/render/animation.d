/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.render.animation;

import std.conv : to;
import std.exception : enforce;

import bindbc.sdl;

import dahu.common;
import dahu.core;

import dahu.render.drawable;
import dahu.render.image;
import dahu.render.texture;
import dahu.render.tileset;

/// Série d’images joués séquenciellement
final class Animation : Drawable {
    private {
        Texture _texture;
        int _frame;
        uint _currentTick;
        bool _isRunning = true;
    }

    @property {
        pragma(inline) override uint width() const {
            return _texture.width;
        }

        pragma(inline) override uint height() const {
            return _texture.height;
        }

        /// L’animation est en cours de lecture ?
        bool isPlaying() const {
            return _isRunning;
        }
    }

    uint frameTime;

    int[] frames;

    uint columns, lines, maxCount;

    bool repeat = true;

    int marginX, marginY;

    /// Ctor
    this(string name, Vec4i clip_, uint columns_, uint lines_, uint maxCount_ = 0) {
        _texture = fetchPrototype!Texture(name);
        clip = clip_;
        sizeX = clip_.z;
        sizeY = clip_.w;
        columns = columns_;
        lines = lines_;
        maxCount = maxCount_;
    }

    /// Copie
    this(Animation anim) {
        super(anim);
        _texture = anim._texture;
        _frame = anim._frame;
        _currentTick = anim._currentTick;
        _isRunning = anim._isRunning;
        frameTime = anim.frameTime;
        frames = anim.frames;
        columns = anim.columns;
        lines = anim.lines;
        maxCount = anim.maxCount;
        repeat = anim.repeat;
        marginX = anim.marginX;
        marginY = anim.marginY;
    }

    /// Démarre l’animation du début
    void start() {
        _currentTick = 0;
        _frame = 0;
        _isRunning = true;
    }

    /// Arrête complètement l’animation
    void stop() {
        _currentTick = 0;
        _frame = 0;
        _isRunning = false;
    }

    /// Pause l’animation
    void pause() {
        _isRunning = false;
    }

    /// Continue l’animation
    void resume() {
        _isRunning = true;
    }

    /// Avance l’animation
    void update() {
        if (!_isRunning) {
            return;
        }

        _currentTick++;
        if (_currentTick >= frameTime) {
            _currentTick = 0;

            if (!frames.length) {
                _frame = -1;
            }
            else {
                _frame++;
                if (_frame >= frames.length) {
                    if (repeat) {
                        _frame = 0;
                    }
                    else {
                        _frame = (cast(int) frames.length) - 1;
                        _isRunning = false;
                    }
                }
            }
        }
    }

    /// Render the current frame.
    override void draw(float x, float y) {
        if (_frame < 0 || !frames.length)
            return;

        if (_frame >= frames.length)
            _frame = 0;

        const int id = frames[_frame];

        Vec2i coord = Vec2i(id % columns, id / columns);

        Vec4i imageClip = Vec4i(clip.x + coord.x * (clip.z + marginX),
            clip.y + coord.y * (clip.w + marginY), clip.z, clip.w);

        _texture.color = color;
        _texture.blend = blend;
        _texture.alpha = alpha;
        _texture.draw(x, y, sizeX, sizeY, imageClip, angle, pivot, flipX, flipY);
    }
}
