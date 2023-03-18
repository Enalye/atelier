/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module render.texture;

import std.string;
import std.exception;
import std.algorithm.comparison : clamp;

import bindbc.sdl;

import common;
import render.renderer;

/// Indicate if something is mirrored.
enum Flip {
    none,
    horizontal,
    vertical,
    both
}

package SDL_RendererFlip getSDLFlip(Flip flip) {
    final switch (flip) with (Flip) {
    case both:
        return cast(SDL_RendererFlip)(SDL_FLIP_HORIZONTAL | SDL_FLIP_VERTICAL);
    case horizontal:
        return SDL_FLIP_HORIZONTAL;
    case vertical:
        return SDL_FLIP_VERTICAL;
    case none:
        return SDL_FLIP_NONE;
    }
}

/// Blending algorithm \
/// none: Paste everything without transparency \
/// modular: Multiply color value with the destination \
/// additive: Add color value with the destination \
/// alpha: Paste everything with transparency (Default one)
enum Blend {
    none,
    modular,
    additive,
    alpha
}

/// Returns the SDL blend flag.
package SDL_BlendMode getSDLBlend(Blend blend) {
    final switch (blend) with (Blend) {
    case alpha:
        return SDL_BLENDMODE_BLEND;
    case additive:
        return SDL_BLENDMODE_ADD;
    case modular:
        return SDL_BLENDMODE_MOD;
    case none:
        return SDL_BLENDMODE_NONE;
    }
}

/// Base rendering class.
final class Texture {
    private {
        bool _isLoaded = false, _ownData, _isSmooth;
        SDL_Texture* _texture = null;
        SDL_Surface* _surface = null;
        uint _width, _height;
        Color _color = Color.white;
        float _alpha = 1f;
        Blend _blend = Blend.alpha;
    }

    @property {
        /// loaded ?
        bool isLoaded() const {
            return _isLoaded;
        }
        /// Width in texels.
        uint width() const {
            return _width;
        }
        /// Height in texels.
        uint height() const {
            return _height;
        }

        /// Color added to the canvas.
        Color color() const {
            return _color;
        }
        /// Ditto
        Color color(Color color_) {
            _color = color_;
            auto sdlColor = _color.toSDL();
            SDL_SetTextureColorMod(_texture, sdlColor.r, sdlColor.g, sdlColor.b);
            return _color;
        }

        /// Alpha
        float alpha() const {
            return _alpha;
        }
        /// Ditto
        float alpha(float alpha_) {
            _alpha = alpha_;
            SDL_SetTextureAlphaMod(_texture, cast(ubyte)(clamp(_alpha, 0f, 1f) * 255f));
            return _alpha;
        }

        /// Blending algorithm.
        Blend blend() const {
            return _blend;
        }
        /// Ditto
        Blend blend(Blend blend_) {
            _blend = blend_;
            SDL_SetTextureBlendMode(_texture, getSDLBlend(_blend));
            return _blend;
        }

        /// underlaying surface
        package SDL_Surface* surface() const {
            return cast(SDL_Surface*) _surface;
        }
    }

    /// Ctor
    this(const Texture texture) {
        _isLoaded = texture._isLoaded;
        _texture = cast(SDL_Texture*) texture._texture;
        _surface = cast(SDL_Surface*) texture._surface;
        _width = texture._width;
        _height = texture._height;
        _isSmooth = texture._isSmooth;
        _blend = texture._blend;
        _color = texture._color;
        _alpha = texture._alpha;
        _ownData = false;
    }

    /// Ctor
    this(SDL_Surface* surface_, bool preload_ = false, bool isSmooth_ = false) {
        _isSmooth = isSmooth_;
        if (preload_) {
            _surface = surface_;
            _width = _surface.w;
            _height = _surface.h;
        }
        else
            load(surface_);
    }

    /// Ctor
    this(string path, bool preload_ = false, bool isSmooth_ = false) {
        _isSmooth = isSmooth_;
        if (preload_) {
            _surface = IMG_Load(toStringz(path));
            _width = _surface.w;
            _height = _surface.h;
            _ownData = true;
        }
        else
            load(path);
    }

    ~this() {
        unload();
    }

    /// Call it if you set the preload flag on ctor.
    void postload() {
        enforce(null != _surface, "invalid surface");
        enforce(null != sdlRenderer, "the renderer does not exist");

        if (null != _texture)
            SDL_DestroyTexture(_texture);
        if (_isSmooth)
            SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1");
        _texture = SDL_CreateTextureFromSurface(sdlRenderer, _surface);
        enforce(null != _texture, "error occurred while converting a surface to a texture format");
        if (_isSmooth)
            SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "0");
        updateSettings();
        _isLoaded = true;
    }

    package void load(SDL_Surface* surface_) {
        if (_surface && _ownData)
            SDL_FreeSurface(_surface);
        _surface = surface_;

        enforce(null != _surface, "invalid surface");
        enforce(null != sdlRenderer, "the renderer does not exist");

        if (null != _texture)
            SDL_DestroyTexture(_texture);

        if (_isSmooth)
            SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1");
        _texture = SDL_CreateTextureFromSurface(sdlRenderer, _surface);
        if (_isSmooth)
            SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "0");

        enforce(null != _texture, "error occurred while converting a surface to a texture format.");
        updateSettings();

        _width = _surface.w;
        _height = _surface.h;

        _isLoaded = true;
        _ownData = true;
    }

    /// Load from file
    void load(string path) {
        if (_surface && _ownData)
            SDL_FreeSurface(_surface);
        _surface = IMG_Load(toStringz(path));

        enforce(null != _surface, "can't load image file `" ~ path ~ "`");
        enforce(null != sdlRenderer, "the renderer does not exist");

        if (_isSmooth)
            SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "1");
        _texture = SDL_CreateTextureFromSurface(sdlRenderer, _surface);
        if (_isSmooth)
            SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "0");

        if (null == _texture)
            throw new Exception("Error occurred while converting `" ~ path ~
                    "` to a texture format.");
        updateSettings();

        _width = _surface.w;
        _height = _surface.h;

        _isLoaded = true;
        _ownData = true;
    }

    /// Free image data
    void unload() {
        if (!_ownData)
            return;
        if (_surface)
            SDL_FreeSurface(_surface);
        if (_texture)
            SDL_DestroyTexture(_texture);
        _isLoaded = false;
    }

    private void updateSettings() {
        auto sdlColor = _color.toSDL();
        SDL_SetTextureBlendMode(_texture, getSDLBlend(_blend));
        SDL_SetTextureColorMod(_texture, sdlColor.r, sdlColor.g, sdlColor.b);
        SDL_SetTextureAlphaMod(_texture, cast(ubyte)(clamp(_alpha, 0f, 1f) * 255f));
    }

    /// Dessine la texture
    void draw(float x, float y, float w, float h, Vec4i clip, double angle,
        Vec2f pivot = Vec2f.zero, bool flipX = false, bool flipY = false) const {
        enforce(_isLoaded, "can't render the texture: asset not loaded");

        SDL_Rect sdlSrc = clip.toSdlRect();
        SDL_FRect sdlDest = {x, y, w, h};
        SDL_FPoint sdlPivot = {pivot.x, pivot.y};

        SDL_RenderCopyExF(sdlRenderer, cast(SDL_Texture*) _texture, &sdlSrc, //
            &sdlDest, angle, null, //
            (flipX ? SDL_FLIP_HORIZONTAL
                : SDL_FLIP_NONE) | //
            (flipY ? SDL_FLIP_VERTICAL : SDL_FLIP_NONE));
    }
}
