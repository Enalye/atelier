module atelier.etabli.media.res.scene.selection;

import atelier.common;
import atelier.ui;
import atelier.render;

package(atelier.etabli.media.res.scene) struct TilesSelection {
    int[][] tiles;
    uint width, height;
    bool isValid;

    void flipH() {
        if (!isValid)
            return;
        int[][] result = new int[][](height, width);
        for (int iy; iy < height; ++iy) {
            for (int ix; ix < width; ++ix) {
                result[iy][width - (ix + 1)] = tiles[iy][ix];
            }
        }
        tiles = result;
    }

    void flipV() {
        if (!isValid)
            return;
        int[][] result = new int[][](height, width);
        for (int iy; iy < height; ++iy) {
            for (int ix; ix < width; ++ix) {
                result[height - (iy + 1)][ix] = tiles[iy][ix];
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
