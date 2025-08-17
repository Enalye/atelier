module atelier.core.loader.pixelfont;

import std.exception : enforce;
import std.format : format;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

private struct PixelFontData {
    int ascent;
    int descent;
    int lineSkip;
    int size;
    int spacing;
    string pixelfontset;

    mixin Serializer;
}

package void compilePixelFont(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    stream.write!string(rid);
    PixelFontData data;
    data.load(ffd);
    data.serialize(stream);
}

package void loadPixelFont(T : PixelFont)(InStream stream) {
    string rid = stream.read!string();

    PixelFontData data;
    data.deserialize(stream);

    Atelier.res.store(rid, {
        PixelFontSet pixelFontSet = Atelier.res.get!PixelFontSet(data.pixelfontset);

        T font = new T(data.ascent, data.descent, data.lineSkip, data.size, data.spacing);
        foreach (glyph; pixelFontSet.getGlyphs()) {
            font.addCharacter(glyph.ch, glyph.pixels, glyph.width, glyph.height, glyph.descent);
        }
        return font;
    });
}
