module atelier.render.font.pixelfont;

import std.conv : to;
import atelier.common;
import atelier.render.font.font;
import atelier.render.font.glyph;
import atelier.render.imagedata;
import atelier.render.util;
import atelier.render.writabletexture;

abstract class PixelFont : Font {
    void addCharacter(dchar ch, int[] glyphData, int width, int height, int descent);
}
