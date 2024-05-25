/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.render.font.truetype;

import std.conv : to;
import std.exception : enforce;
import std.file : read;
import std.string : toStringz, fromStringz;

import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.render.texture;
import atelier.render.writabletexture;
import atelier.render.font.font, atelier.render.font.glyph;

/// Police correspondant à un fichier TrueType
final class TrueTypeFont : Font, Resource!TrueTypeFont {
    private {
        TTF_Font* _trueTypeFont;
        uint _size, _outline;
        Glyph[dchar] _cache, _outlineCache;
        bool _isSmooth;
        int _posX, _posY;
        int _surfaceW = 1024, _surfaceH = 1024;
        int _height, _ascent, _descent, _lineSkip;
        WritableTexture _texture;
    }

    @property {
        /// Taille de la police
        int size() const {
            return _height;
        }
        /// Jusqu’où peut monter un caractère au-dessus la ligne
        int ascent() const {
            return _ascent;
        }
        /// Jusqu’où peut descendre un caractère en-dessous la ligne
        int descent() const {
            return _descent;
        }
        /// Distance entre chaque ligne
        int lineSkip() const {
            return _lineSkip;
        }
        /// Taille de la bordure
        int outline() const {
            return _outline;
        }
    }

    /// Copy ctor
    this(TrueTypeFont font) {
        _trueTypeFont = font._trueTypeFont;
        _size = font._size;
        _outline = font._outline;
        _height = font._height;
        _ascent = font._ascent;
        _descent = font._descent;
        _lineSkip = font._lineSkip;
    }

    static TrueTypeFont fromMemory(const(ubyte)[] data, uint size_ = 12u, uint outline_ = 0) {
        return new TrueTypeFont(data, size_, outline_);
    }

    static TrueTypeFont fromResource(const string filePath, uint size_ = 12u, uint outline_ = 0) {
        const(ubyte)[] data = Atelier.res.read(filePath);
        return new TrueTypeFont(data, size_, outline_);
    }

    static TrueTypeFont fromFile(const string filePath, uint size_ = 12u, uint outline_ = 0) {
        const(ubyte)[] data = cast(const(ubyte)[]) read(filePath);
        return new TrueTypeFont(data, size_, outline_);
    }

    private this(const(ubyte)[] data, uint size_, uint outline_) {
        _size = size_;
        _outline = outline_;
        SDL_RWops* rw = SDL_RWFromConstMem(cast(const(void)*) data.ptr, cast(int) data.length);

        assert(_size != 0u, "can't render a font with no size");
        if (null != _trueTypeFont)
            TTF_CloseFont(_trueTypeFont);
        _trueTypeFont = TTF_OpenFontRW(rw, 1, _size);
        assert(_trueTypeFont, "can't load font");

        TTF_SetFontKerning(_trueTypeFont, 1);
        _height = TTF_FontHeight(_trueTypeFont);
        _ascent = TTF_FontAscent(_trueTypeFont);
        _descent = TTF_FontDescent(_trueTypeFont);
        _lineSkip = TTF_FontLineSkip(_trueTypeFont);

        _texture = new WritableTexture(_surfaceW, _surfaceH);
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

    private void _cacheGlyph(dchar ch, Glyph* glyph, Glyph* outlineGlyph) {
        int xmin, xmax, ymin, ymax, advance;
        /*if (_outline == 0) {
            if (-1 == TTF_GlyphMetrics32(_trueTypeFont, ch, &xmin, &xmax,
                    &ymin, &ymax, &advance))
                return new BasicGlyph();

            SDL_Color whiteColor = Color.white.toSDL();
            whiteColor.a = 0;

            TTF_SetFontOutline(_trueTypeFont, _outline);

            SDL_Surface* surface = TTF_RenderGlyph32_Blended(_trueTypeFont, ch, whiteColor);
            enforce(surface, "échec lors de la génération du glyphe TTF");

            SDL_Surface* convertedSurface = SDL_ConvertSurfaceFormat(surface,
                SDL_PIXELFORMAT_RGBA8888, 0);
            enforce(convertedSurface, "échec lors de la conversion de la texture");

            if (_posX + surface.w >= _surfaceW) {
                _posX = 0;
                _posY += _ascent - _descent;

                if (_posY + (_ascent - _descent) > _surfaceH) {
                    _posY = 0;
                    _texture = new WritableTexture(_surfaceW, _surfaceH);
                }
            }

            _texture.update(Vec4u(_posX, _posY, surface.w, surface.h),
                (cast(uint*) convertedSurface.pixels)[0 .. (surface.w * surface.h)]);

            // On peut pas faire confiance à SDL_TTF
            if (ymin < _descent)
                _descent = ymin;

            if (ymax > _ascent)
                _ascent = ymax;

            Glyph metrics = new BasicGlyph(true, advance, 0, _ascent, convertedSurface.w,
                convertedSurface.h, _posX, _posY, convertedSurface.w,
                convertedSurface.h, _texture);

            //Glyph metrics = new BasicGlyph(true, advance, 0, ymax, surface.w,
            //    ymax - ymin, _posX, _posY + (descent_ - (ymin < descent_ ? descent_
            //        : ymin)) + (surface.h - (ymax - ymin)), surface.w, ymax - ymin, _texture);

            _posX += convertedSurface.w;

            import std.stdio;

            writeln("`", ch, "`, ascent: ", _ascent, " descent:", _descent, ", ymin: ", ymin,
                " ymax: ", ymax, " xmin: ", xmin, " xmax: ", xmax, ", surfW: ", surface.w, " surfH: ",
                surface.h, " offY: ", metrics.offsetY, ", height: ", metrics.height);

            SDL_FreeSurface(surface);
            SDL_FreeSurface(convertedSurface);

            _cache[ch] = metrics;
            return metrics;
        }
        else {*/
        if (-1 == TTF_GlyphMetrics32(_trueTypeFont, ch, &xmin, &xmax, &ymin, &ymax, &advance)) {
            Glyph metrics = new BasicGlyph();
            if (glyph)
                *glyph = metrics;
            if (outlineGlyph)
                *outlineGlyph = metrics;
        }

        SDL_Color whiteColor = Color.white.toSDL();
        whiteColor.a = 0;

        SDL_Surface* surface, outlineSurface, convertedSurface, convertedOutlineSurface;

        if (_outline > 0) {
            TTF_SetFontOutline(_trueTypeFont, _outline);

            outlineSurface = TTF_RenderGlyph32_Blended(_trueTypeFont, ch, whiteColor);
            enforce(outlineSurface, "échec lors de la génération du glyphe TTF");

            TTF_SetFontOutline(_trueTypeFont, 0);

            convertedOutlineSurface = SDL_ConvertSurfaceFormat(outlineSurface,
                SDL_PIXELFORMAT_RGBA8888, 0);
            enforce(convertedOutlineSurface, "échec lors de la conversion de la texture");
        }

        {
            surface = TTF_RenderGlyph32_Blended(_trueTypeFont, ch, whiteColor);
            enforce(surface, "échec lors de la génération du glyphe TTF");

            convertedSurface = SDL_ConvertSurfaceFormat(surface, SDL_PIXELFORMAT_RGBA8888, 0);
            enforce(convertedSurface, "échec lors de la conversion de la texture");
        }
        /*SDL_Rect srcRect = {0, 0, surface.w, surface.h};
            SDL_Rect dstRect = {_outline, _outline, surface.w, surface.h};

            SDL_BlitSurface(surface, &srcRect, outlineSurface, &dstRect);*/

        int glyphsHeight = _outline > 0 ? max(convertedSurface.h, convertedOutlineSurface.h)
            : convertedSurface.h;

        // On peut pas faire confiance à SDL_TTF
        if (ymin < _descent)
            _descent = ymin;

        if (ymax > _ascent)
            _ascent = ymax;

        {
            if (_posX + convertedSurface.w >= _surfaceW) {
                _posX = 0;
                _posY += glyphsHeight;

                if (_posY + glyphsHeight > _surfaceH) {
                    _posY = 0;
                    _texture = new WritableTexture(_surfaceW, _surfaceH);
                }
            }

            _texture.update(Vec4u(_posX, _posY, convertedSurface.w,
                    convertedSurface.h),
                (cast(uint*) convertedSurface.pixels)[0 .. (convertedSurface.w * convertedSurface.h)]);

            Glyph metrics = new BasicGlyph(true, advance, 0, _ascent, convertedSurface.w,
                convertedSurface.h, _posX, _posY, convertedSurface.w,
                convertedSurface.h, _texture);
            _cache[ch] = metrics;

            if (glyph) {
                *glyph = metrics;
            }

            _posX += convertedSurface.w;

            SDL_FreeSurface(surface);
            SDL_FreeSurface(convertedSurface);
        }

        if (_outline > 0) {
            if (_posX + convertedOutlineSurface.w >= _surfaceW) {
                _posX = 0;
                _posY += glyphsHeight;

                if (_posY + glyphsHeight > _surfaceH) {
                    _posY = 0;
                    _texture = new WritableTexture(_surfaceW, _surfaceH);
                }
            }

            _texture.update(Vec4u(_posX, _posY, convertedOutlineSurface.w,
                    convertedOutlineSurface.h), (cast(uint*) convertedOutlineSurface.pixels)[0 .. (
                        convertedOutlineSurface.w * convertedOutlineSurface.h)]);

            Glyph metrics = new BasicGlyph(true, advance, 0, _ascent,
                convertedOutlineSurface.w, convertedOutlineSurface.h,
                _posX, _posY, convertedOutlineSurface.w, convertedOutlineSurface.h, _texture);
            _outlineCache[ch] = metrics;

            if (outlineGlyph) {
                *outlineGlyph = metrics;
            }

            _posX += convertedOutlineSurface.w;

            SDL_FreeSurface(outlineSurface);
            SDL_FreeSurface(convertedOutlineSurface);
        }
        /*
            import std.stdio;

            writeln("`", ch, "`, ascent: ", _ascent, " descent:", _descent, ", ymin: ", ymin,
                " ymax: ", ymax, " xmin: ", xmin, " xmax: ", xmax, ", surfW: ", surface.w, " surfH: ",
                surface.h, " offY: ", metrics.offsetY, ", height: ", metrics.height);*/
        //}
    }

    int getKerning(dchar prevChar, dchar currChar) {
        return TTF_GetFontKerningSizeGlyphs32(_trueTypeFont, prevChar, currChar);
    }

    Glyph getGlyph(dchar ch) {
        Glyph* glyph = ch in _cache;
        if (glyph)
            return *glyph;

        Glyph pGlyph;
        _cacheGlyph(ch, &pGlyph, null);
        return pGlyph;
    }

    Glyph getGlyphOutline(dchar ch) {
        if (_outline <= 0)
            return new BasicGlyph();

        Glyph* glyph = ch in _outlineCache;
        if (glyph)
            return *glyph;

        Glyph pGlyph;
        _cacheGlyph(ch, null, &pGlyph);
        return pGlyph;
    }
}
