module atelier.core.loader.pixelfontset;

import std.exception : enforce;
import std.format : format;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

private struct PixelFontGlyphData {
    int[] pixels;
    int width;
    int height;
    int descent;

    mixin Serializer;
}

package void compilePixelFontSet(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    stream.write!string(rid);
    stream.write!size_t(ffd.getNodeCount("glyph"));
    foreach (glyphNode; ffd.getNodes("glyph")) {
        stream.write!dchar(glyphNode.get!dchar(0));
        PixelFontGlyphData data;
        data.load(glyphNode);
        data.serialize(stream);
    }
}

package void loadPixelFontSet(InStream stream) {
    string rid = stream.read!string();

    PixelFontSet pixelFontSet = new PixelFontSet;

    size_t glyphCount = stream.read!size_t();
    for (size_t i; i < glyphCount; ++i) {
        dchar ch = stream.read!dchar();
        PixelFontGlyphData data;
        data.deserialize(stream);
        pixelFontSet.addCharacter(ch, data.pixels, data.width, data.height, data.descent);
    }

    Atelier.res.store(rid, { return pixelFontSet; });
}
