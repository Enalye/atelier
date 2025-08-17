module atelier.render.font.pixelfontset;

import atelier.common;

final class PixelFontSet : Resource!PixelFontSet {
    struct Glyph {
        dchar ch;
        int[] pixels;
        int width;
        int height;
        int descent;
    }

    private {
        Glyph[] _glyphs;
    }

    PixelFontSet fetch() {
        return this;
    }

    void addCharacter(dchar ch, int[] pixels, int width, int height, int descent) {
        Glyph glyph;
        glyph.ch = ch;
        glyph.pixels = pixels;
        glyph.width = width;
        glyph.height = height;
        glyph.descent = descent;
        _glyphs ~= glyph;
    }

    Glyph[] getGlyphs() {
        return _glyphs;
    }
}
