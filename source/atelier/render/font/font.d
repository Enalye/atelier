/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.render.font.font;

import atelier.common;
import atelier.render.texture;
import atelier.render.font.glyph;
import atelier.render.font.truetype;

/// Font that renders text to texture.
interface Font {
    @property {
        /// Default font size
        int size() const;
        /// Where the top is above the baseline
        int ascent() const;
        /// Where the bottom is below the baseline
        int descent() const;
        /// Distance between each baselines
        int lineSkip() const;
    }

    int getKerning(dchar prevChar, dchar currChar);

    Glyph getGlyph(dchar character);
}
