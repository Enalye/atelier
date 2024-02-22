/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.render.font.truetype;

import std.conv : to;
import std.string : toStringz, fromStringz;

import bindbc.sdl;

import atelier.common;
import atelier.core;

import atelier.render.texture;
import atelier.render.font.font, atelier.render.font.glyph;

/// Font that load a TTF file.
final class TrueTypeFont : Font, Resource!TrueTypeFont {
    private {
        TTF_Font* _trueTypeFont;
        int _size, _outline;
        Glyph[dchar] _cache;
        bool _isSmooth;
    }

    @property {
        /// Default font size
        int size() const {
            return TTF_FontHeight(_trueTypeFont);
        }
        /// Where the top is above the baseline
        int ascent() const {
            return TTF_FontAscent(_trueTypeFont);
        }
        /// Where the bottom is below the baseline
        int descent() const {
            return TTF_FontDescent(_trueTypeFont);
        }
        /// Distance between each baselines
        int lineSkip() const {
            return TTF_FontLineSkip(_trueTypeFont);
        }
    }

    /// Copy ctor
    this(TrueTypeFont font) {
        _trueTypeFont = font._trueTypeFont;
        _size = font._size;
        _outline = font._outline;
    }

    /// Ctor
    this(const string filePath, int size_ = 12u, int outline_ = 0) {
        const(ubyte)[] data = Atelier.res.read(filePath);
        SDL_RWops* rw = SDL_RWFromConstMem(cast(const(void)*) data.ptr, cast(int) data.length);
        _size = size_;
        _outline = outline_;

        assert(_size != 0u, "can't render a font with no size");
        if (null != _trueTypeFont)
            TTF_CloseFont(_trueTypeFont);
        _trueTypeFont = TTF_OpenFontRW(rw, 1, _size);
        assert(_trueTypeFont, "can't load font");

        TTF_SetFontKerning(_trueTypeFont, 1);
    }

    ~this() {
        if (null != _trueTypeFont)
            TTF_CloseFont(_trueTypeFont);
    }

    TrueTypeFont fetch() {
        return this;
    }

    /// Toggle the glyph smoothing
    void setSmooth(bool isSmooth_) {
        if (isSmooth_ != _isSmooth)
            _cache.clear();
        _isSmooth = isSmooth_;
    }

    private Glyph _cacheGlyph(dchar ch) {
        int xmin, xmax, ymin, ymax, advance;
        if (_outline == 0) {
            if (-1 == TTF_GlyphMetrics32(_trueTypeFont, ch, &xmin, &xmax,
                    &ymin, &ymax, &advance))
                return new BasicGlyph();

            auto aa = Color.white.toSDL();
            aa.a = 0;

            SDL_Surface* surface = TTF_RenderGlyph32_Blended(_trueTypeFont, ch, aa);
            assert(surface);
            Texture texture = new Texture(surface, _isSmooth);
            assert(texture);

            Glyph metrics = new BasicGlyph(true, advance, 0, 0, texture.width,
                texture.height, 0, 0, texture.width, texture.height, texture);
            _cache[ch] = metrics;
            return metrics;
        }
        else {
            if (-1 == TTF_GlyphMetrics32(_trueTypeFont, ch, &xmin, &xmax,
                    &ymin, &ymax, &advance))
                return new BasicGlyph();

            TTF_SetFontOutline(_trueTypeFont, _outline);

            SDL_Surface* surfaceOutline = TTF_RenderGlyph32_Blended(_trueTypeFont,
                ch, Color.black.toSDL());
            assert(surfaceOutline);

            TTF_SetFontOutline(_trueTypeFont, 0);

            SDL_Surface* surface = TTF_RenderGlyph32_Blended(_trueTypeFont, ch, Color.white.toSDL());
            assert(surface);

            SDL_Rect srcRect = {0, 0, surface.w, surface.h};
            SDL_Rect dstRect = {_outline, _outline, surface.w, surface.h};

            SDL_BlitSurface(surface, &srcRect, surfaceOutline, &dstRect);

            Texture texture = new Texture(surfaceOutline, _isSmooth);
            assert(texture);
            SDL_FreeSurface(surface);
            Glyph metrics = new BasicGlyph(true, advance, 0, 0, texture.width,
                texture.height, 0, 0, texture.width, texture.height, texture);
            _cache[ch] = metrics;
            return metrics;
        }
    }

    int getKerning(dchar prevChar, dchar currChar) {
        return TTF_GetFontKerningSizeGlyphs32(_trueTypeFont, prevChar, currChar);
    }

    Glyph getGlyph(dchar ch) {
        Glyph* glyph = ch in _cache;
        if (glyph)
            return *glyph;
        return _cacheGlyph(ch);
    }
}
