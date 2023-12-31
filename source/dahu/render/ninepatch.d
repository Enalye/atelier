/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.render.ninepatch;

import std.conv : to;
import std.algorithm.comparison : min;
import std.exception;

import bindbc.sdl;

import dahu.common;
import dahu.core;

import dahu.render.drawable;
import dahu.render.graphic;
import dahu.render.texture;
import dahu.render.writabletexture;
import dahu.render.util;

/// Render a resizable repeated sprite with borders. (ex: bubble speech).
final class NinePatch : Graphic, Drawable, Resource!NinePatch {
    private {
        SDL_Surface* _surface;
        int _surfaceWidth, _surfaceHeight;
        WritableTexture _cache;
        Vec4i _clip;
        int _top, _bottom, _left, _right;
        bool _isDirty = true;
        bool _ownSurface;

        float _sizeX = 0f, _sizeY = 0f;
    }

    @property {
        pragma(inline) uint width() const {
            return _cache.width;
        }

        pragma(inline) uint height() const {
            return _cache.height;
        }

        pragma(inline) float sizeX() const {
            return _sizeX;
        }

        pragma(inline) float sizeX(float sizeX_) {
            if ((cast(int) _sizeX) != (cast(int) sizeX_)) {
                _isDirty = true;
            }
            _sizeX = sizeX_;
            return _sizeX;
        }

        pragma(inline) float sizeY() const {
            return _sizeY;
        }

        pragma(inline) float sizeY(float sizeY_) {
            if ((cast(int) _sizeY) != (cast(int) sizeY_)) {
                _isDirty = true;
            }
            _sizeY = sizeY_;
            return _sizeY;
        }

        /// Texture's region used.
        Vec4i clip() {
            return _clip;
        }
        /// Ditto
        Vec4i clip(const Vec4i clip_) {
            if (_clip == clip_)
                return _clip;
            _clip = clip_;
            _isDirty = true;
            return _clip;
        }

        /// The top border offset.
        int top() const {
            return _top;
        }
        /// Ditto
        int top(int top_) {
            if (_top == top_)
                return _top;
            _top = top_;
            _isDirty = true;
            return _top;
        }

        /// The bottom border offset.
        int bottom() const {
            return _bottom;
        }
        /// Ditto
        int bottom(int bottom_) {
            if (_bottom == bottom_)
                return _bottom;
            _bottom = bottom_;
            _isDirty = true;
            return _bottom;
        }

        /// The left border offset.
        int left() const {
            return _left;
        }
        /// Ditto
        int left(int left_) {
            if (_left == left_)
                return _left;
            _left = left_;
            _isDirty = true;
            return _left;
        }

        /// The right border offset.
        int right() const {
            return _right;
        }
        /// Ditto
        int right(int right_) {
            if (_right == right_)
                return _right;
            _right = right_;
            _isDirty = true;
            return _right;
        }

        /// The texture used to render.
        Texture texture(Texture texture_) {
            if (_ownSurface && _surface)
                SDL_FreeSurface(_surface);

            _surface = SDL_ConvertSurfaceFormat(texture_.surface, SDL_PIXELFORMAT_RGBA8888, 0);
            enforce(null != _surface, "can't format surface");
            _surfaceWidth = texture_.width;
            _surfaceHeight = texture_.height;
            _ownSurface = true;
            _isDirty = true;
            return texture_;
        }
    }

    /// Ctor
    this(string name, Vec4i clip_, int top_, int bottom_, int left_, int right_) {
        Texture tex = Dahu.res.get!Texture(name);

        _surface = SDL_ConvertSurfaceFormat(tex.surface, SDL_PIXELFORMAT_RGBA8888, 0);
        enforce(_surface, "can't format surface");
        _surfaceWidth = tex.width;
        _surfaceHeight = tex.height;
        _ownSurface = true;

        _clip = clip_;
        _top = top_;
        _bottom = bottom_;
        _left = left_;
        _right = right_;
        sizeX = _clip.z;
        sizeY = _clip.w;
        _isDirty = true;
    }

    /// Copie
    this(NinePatch ninePatch) {
        super(ninePatch);
        _surface = ninePatch._surface;
        _sizeX = ninePatch._sizeX;
        _sizeY = ninePatch._sizeY;
        _surfaceWidth = ninePatch._surfaceWidth;
        _surfaceHeight = ninePatch._surfaceHeight;
        _ownSurface = false;
        _clip = ninePatch._clip;
        _top = ninePatch._top;
        _bottom = ninePatch._bottom;
        _left = ninePatch._left;
        _right = ninePatch._right;
        _isDirty = true;
    }

    ~this() {
        if (_ownSurface && _surface)
            SDL_FreeSurface(_surface);
    }

    /// Accès à la ressource
    NinePatch fetch() {
        return new NinePatch(this);
    }

    void update() {
    }

    /// Render to the canvas.
    private void _cacheTexture() {
        _isDirty = false;
        if (_surface is null || _clip.z <= (_left + _right) || _clip.w <= (_top + _bottom))
            return;

        _cache = (_sizeX >= 1f && _sizeY >= 1f) ? new WritableTexture(cast(uint) _sizeX,
            cast(uint) _sizeY) : null;

        if (!_cache)
            return;

        struct RasterData {
            int top, right, bottom, left;
            int clipX, clipY, clipW, clipH;
            int texW, texH;
            uint* pixels;
        }

        RasterData rasterData;
        rasterData.top = _top;
        rasterData.right = _right;
        rasterData.bottom = _bottom;
        rasterData.left = _left;
        rasterData.clipX = _clip.x;
        rasterData.clipY = _clip.y;
        rasterData.clipW = _clip.z;
        rasterData.clipH = _clip.w;
        rasterData.texW = _surfaceWidth;
        rasterData.texH = _surfaceHeight;
        rasterData.pixels = cast(uint*) _surface.pixels;

        _cache.write(function(uint* dest, uint* src, uint texWidth, uint texHeight, void* data_) {
            RasterData* data = cast(RasterData*) data_;
            const offsetY = (texHeight - data.bottom) * texWidth;
            const clipInternalH = data.clipH - (data.top + data.bottom);
            const clipInternalW = data.clipW - (data.left + data.right);
            const texInternalW = texWidth - (data.left + data.right);

            // Top corners
            for (int iy; iy < data.top; ++iy) {
                // Top left corner
                for (int ix; ix < data.left; ++ix) {
                    dest[iy * texWidth + ix] = data.pixels[(
                            data.clipY + iy) * data.texW + data.clipX + ix];
                }

                // Top right corner
                for (int ix; ix < data.right; ++ix) {
                    dest[(iy + 1) * texWidth + (ix - data.right)] = data.pixels[(
                            data.clipY + iy) * data.texW + data.clipX + ix + (
                            data.clipW - data.right)];
                }
            }

            // Bottom corners
            for (int iy; iy < data.bottom; ++iy) {
                // Bottom left corner
                for (int ix; ix < data.left; ++ix) {
                    dest[iy * texWidth + ix + offsetY] = data.pixels[(data.clipY + iy + (
                            data.clipH - data.bottom)) * data.texW + data.clipX + ix];
                }

                // Bottom right corner
                for (int ix; ix < data.right; ++ix) {
                    dest[(iy + 1) * texWidth + ix + offsetY - data.right] = data.pixels[(
                            data.clipY + iy + (data.clipH - data.bottom)) * data.texW + data.clipX + ix + (
                            data.clipW - data.right)];
                }
            }

            if (clipInternalW > 0) {
                // Top edge
                for (int iy; iy < data.top; ++iy) {
                    int ix;
                    while (ix < texInternalW) {
                        dest[iy * texWidth + ix + data.left] = data.pixels[(
                                data.clipY + iy) * data.texW + data.clipX + (
                                ix % clipInternalW) + data.left];
                        ix++;
                    }
                }

                // Bottom edge
                for (int iy; iy < data.bottom; ++iy) {
                    int ix;
                    while (ix < texInternalW) {
                        dest[iy * texWidth + ix + data.left + offsetY] = data.pixels[(
                                data.clipY + iy + (data.clipH - data.bottom)) * data.texW + data.clipX + (
                                ix % clipInternalW) + data.left];
                        ix++;
                    }
                }
            }

            // Left and right edges
            if (clipInternalH > 0) {
                for (int iy; iy < (texHeight - (data.top + data.bottom)); ++iy) {
                    // Left edge
                    for (int ix; ix < data.left; ++ix) {
                        dest[(iy + data.top) * texWidth + ix] = data.pixels[(
                                data.clipY + (iy % clipInternalH) + data.top) *
                            data.texW + data.clipX + ix];
                    }

                    // Right edge
                    for (int ix; ix < data.right; ++ix) {
                        dest[(iy + data.top + 1) * texWidth + (ix - data.right)] = data.pixels[(
                                data.clipY + (iy % clipInternalH) + data.top) * data.texW + data.clipX + ix + (
                                data.clipW - data.right)];
                    }
                }
            }

            // Center
            if (clipInternalW > 0 && clipInternalH > 0) {
                for (int iy; iy < (texHeight - (data.top + data.bottom)); ++iy) {
                    for (int ix; ix < (texWidth - (data.left + data.right)); ++ix) {
                        dest[(iy + data.top) * texWidth + (ix + data.left)] = data.pixels[(
                                data.clipY + (iy % clipInternalH) + data.top) * data.texW + data.clipX + (
                                ix % clipInternalW) + data.left];
                    }
                }
            }
        }, &rasterData);
    }

    /// Render the NinePatch in this position.
    void draw(float x, float y) {
        if (_isDirty)
            _cacheTexture();

        if (!_cache)
            return;

        _cache.color = color;
        _cache.blend = blend;
        _cache.alpha = alpha;
        _cache.draw(x, y, _sizeX, _sizeY, Vec4i(0, 0, _cache.width,
                _cache.height), angle, pivotX, pivotY, flipX, flipY);
    }

    /// Redimensionne l’image pour qu’elle puisse tenir dans une taille donnée
    override void fit(float x, float y) {
        Vec2f size = to!Vec2f(clip.zw).fit(Vec2f(x, y));
        sizeX = size.x;
        sizeY = size.y;
    }

    /// Redimensionne l’image pour qu’elle puisse contenir une taille donnée
    override void contain(float x, float y) {
        Vec2f size = to!Vec2f(clip.zw).contain(Vec2f(x, y));
        sizeX = size.x;
        sizeY = size.y;
    }
}
