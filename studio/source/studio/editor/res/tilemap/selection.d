/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.editor.res.tilemap.selection;

import atelier;

struct TilesSelection {
    int[][] tiles;
    uint width, height;
    bool isValid;

    void flipH() {
        if (!isValid)
            return;
        int[][] result = new int[][](width, height);
        for (int iy; iy < height; ++iy) {
            for (int ix; ix < width; ++ix) {
                result[width - (ix + 1)][iy] = tiles[ix][iy];
            }
        }
        tiles = result;
    }

    void flipV() {
        if (!isValid)
            return;
        int[][] result = new int[][](width, height);
        for (int iy; iy < height; ++iy) {
            for (int ix; ix < width; ++ix) {
                result[ix][height - (iy + 1)] = tiles[ix][iy];
            }
        }
        tiles = result;
    }

    int getFirst(int default_ = -1) const {
        if (width > 0 && height > 0)
            return tiles[0][0];
        return default_;
    }
}
