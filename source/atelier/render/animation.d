/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.render.animation;

import std.conv : to;
import std.exception : enforce;

import bindbc.sdl;

import atelier.common;
import atelier.core;

import atelier.render.image;
import atelier.render.sprite;
import atelier.render.texture;
import atelier.render.tileset;

/// Série d’images joués séquenciellement
final class Animation : Image, Resource!Animation {
    private {
        Texture _texture;
        int _frame;
        uint _currentTick;
        bool _isRunning = true;
    }

    uint frameTime;

    int[] frames;

    uint columns, lines, maxCount;

    bool repeat = true;

    Vec2i margin;

    Vec2f size = Vec2f.zero;

    @property {
        pragma(inline) uint width() const {
            return _texture.width;
        }

        pragma(inline) uint height() const {
            return _texture.height;
        }

        /// L’animation est en cours de lecture ?
        bool isPlaying() const {
            return _isRunning;
        }
    }

    /// Ctor
    this(Texture texture, Vec4i clip_, uint columns_, uint lines_, uint maxCount_ = 0) {
        _texture = texture;
        clip = clip_;
        size = to!Vec2f(clip_.zw);
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
        margin = anim.margin;
        size = anim.size;
    }

    /// Accès à la ressource
    Animation fetch() {
        return new Animation(this);
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
    override void update() {
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

    /// Redimensionne l’image pour qu’elle puisse tenir dans une taille donnée
    override void fit(Vec2f size_) {
        size = to!Vec2f(clip.zw).fit(size_);
    }

    /// Redimensionne l’image pour qu’elle puisse contenir une taille donnée
    override void contain(Vec2f size_) {
        size = to!Vec2f(clip.zw).contain(size_);
    }

    /// Render the current frame.
    override void draw(Vec2f origin = Vec2f.zero) {
        if (_frame < 0 || !frames.length)
            return;

        if (_frame >= frames.length)
            _frame = 0;

        const int id = frames[_frame];

        Vec2i coord = Vec2i(id % columns, id / columns);

        Vec4i imageClip = Vec4i(clip.x + coord.x * (clip.z + margin.x),
            clip.y + coord.y * (clip.w + margin.y), clip.z, clip.w);

        _texture.color = color;
        _texture.blend = blend;
        _texture.alpha = alpha;
        _texture.draw(origin + (position - anchor * size), size, imageClip, angle, pivot, flipX, flipY);
    }
}
