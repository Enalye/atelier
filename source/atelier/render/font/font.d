module atelier.render.font.font;

import atelier.common;
import atelier.render.texture;
import atelier.render.font.glyph;
import atelier.render.font.truetype;

/// Font that renders text to texture.
interface Font {
    @property {
        /// Taille de la police
        int size() const;
        /// Jusqu’où peut monter un caractère au-dessus la ligne
        int ascent() const;
        /// Jusqu’où peut descendre un caractère en-dessous la ligne
        int descent() const;
        /// Distance entre chaque ligne
        int lineSkip() const;
        /// Taille de la bordure
        int outline() const;
    }

    int getKerning(dchar prevChar, dchar currChar);

    Glyph getGlyph(dchar character);
    Glyph getGlyphOutline(dchar character);
}
