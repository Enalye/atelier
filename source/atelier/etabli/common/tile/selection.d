module atelier.etabli.common.tile.selection;

import atelier.common;

struct TilesSelection(T) {
    T[][] tiles;
    uint width, height;
    bool isValid;
    T defaultValue;

    void flipH() {
        if (!isValid)
            return;
        T[][] result = new T[][](width, height);
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
        T[][] result = new T[][](width, height);
        for (int iy; iy < height; ++iy) {
            for (int ix; ix < width; ++ix) {
                result[ix][height - (iy + 1)] = tiles[ix][iy];
            }
        }
        tiles = result;
    }

    T getFirst(T default_ = defaultValue) const {
        if (width > 0 && height > 0)
            return tiles[0][0];
        return default_;
    }

    void replace(string op)(T maxValue, T default_ = defaultValue) {
        for (int iy; iy < height; ++iy) {
            for (int ix; ix < width; ++ix) {
                bool isReplacing;
                mixin("isReplacing = tiles[iy][ix] ", op, " maxValue;");
                if (isReplacing) {
                    tiles[iy][ix] = default_;
                }
            }
        }
    }
}
