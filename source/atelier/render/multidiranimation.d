module atelier.render.multidiranimation;

import std.conv : to;
import std.exception : enforce;

import bindbc.sdl;

import atelier.common;
import atelier.core;

import atelier.render.image;
import atelier.render.sprite;
import atelier.render.imagedata;
import atelier.render.tileset;

/// Série d’images joués séquenciellement
final class MultiDirAnimation : Image, Resource!MultiDirAnimation {
    private {
        ImageData _imageData;
        int _frame;
        int _currentDir;
        uint _currentTick;
        bool _isRunning = true;
    }

    uint frameTime;

    int[] frames;

    uint columns = 1, lines = 1, maxCount = 1;

    bool repeat = true;

    Vec2i margin;

    Vec2f size = Vec2f.zero;

    Vec2i dirOffset;

    int[] dirIndexes, dirFlipXs;

    float dirAngle = 0f;
    float dirStartAngle = 90f;

    @property {
        pragma(inline) uint width() const {
            return _imageData.width;
        }

        pragma(inline) uint height() const {
            return _imageData.height;
        }

        /// L’animation est en cours de lecture ?
        bool isPlaying() const {
            return _isRunning;
        }

        /// L’état actuel de l’animation
        int frame() const {
            return _frame;
        }

        /// Ditto
        int frameId() const {
            if (_frame < 0 || !frames.length)
                return -1;

            if (_frame >= frames.length)
                return -1;

            return frames[_frame];
        }

        int currentDir() const {
            return _currentDir;
        }
    }

    /// Ctor
    this(ImageData imageData, Vec4u clip_, uint columns_, uint lines_, uint maxCount_ = 0) {
        _imageData = imageData;
        clip = clip_;
        size = to!Vec2f(clip_.zw);
        columns = columns_;
        lines = lines_;
        maxCount = maxCount_;
    }

    /// Copie
    this(MultiDirAnimation anim) {
        super(anim);
        _imageData = anim._imageData;
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
        dirStartAngle = anim.dirStartAngle;
        dirOffset = anim.dirOffset;
        dirIndexes = anim.dirIndexes;
        dirFlipXs = anim.dirFlipXs;
        size = anim.size;
    }

    /// Accès à la ressource
    MultiDirAnimation fetch() {
        return new MultiDirAnimation(this);
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

        if(dirIndexes.length) {
            float angleStep = 360f / dirIndexes.length;
            float angleDelta = angleBetweenDeg(dirStartAngle - angleStep / 2f, dirAngle);
            if (angleDelta < 0f)
                angleDelta += 360f;

            _currentDir = cast(uint)(angleDelta / angleStep);
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

        uint dirFrame;
        if (_currentDir < dirIndexes.length) {
            dirFrame = dirIndexes[_currentDir];
        }

        Vec4u imageClip = Vec4u(clip.x + coord.x * (clip.z + margin.x) + dirFrame * dirOffset.x,
            clip.y + coord.y * (clip.w + margin.y) + dirFrame * dirOffset.y, clip.z, clip.w);

        bool frameFlipX = flipX;
        if (_currentDir < dirFlipXs.length) {
            frameFlipX = (dirFlipXs[_currentDir] > 0) ? !frameFlipX : frameFlipX;
        }

        _imageData.color = color;
        _imageData.blend = blend;
        _imageData.alpha = alpha;
        _imageData.draw(origin + (position - anchor * size), size, imageClip,
            angle, pivot, frameFlipX, flipY);
    }
}
