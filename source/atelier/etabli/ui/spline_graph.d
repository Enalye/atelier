module atelier.etabli.ui.spline_graph;

import std.conv : to;
import std.math : round;
import atelier;

final class SplineGraph : UIElement {
    private {
        WritableTexture _texture;
        Sprite _sprite;
    }

    this() {
        setSize(Vec2f(64f, 64f));

        _texture = new WritableTexture(64, 64);
        _sprite = new Sprite(_texture);
        _sprite.anchor = Vec2f.zero;

        addImage(_sprite);
    }

    void setSpline(string value) {
        try {
            Spline spline = to!Spline(value);
            SplineFunc splineFunc = getSplineFunc(spline);

            _texture.update(function(uint* dest, uint texWidth, uint texHeight, void* data_) {
                SplineFunc func = *cast(SplineFunc*) data_;

                for (int i; i < (texWidth * texHeight); ++i) {
                    dest[i] = 0xff;
                }

                for (int ix; ix < texWidth; ++ix) {
                    float t = ix / cast(float) texWidth;
                    t = (1f - func(t)) * 0.5f + 0.25f;

                    for (int i = 1; i <= 3; ++i) {
                        int iy = clamp(cast(int) round(i * 0.25f * texHeight), 0, texHeight - 1);
                        uint index = iy * texWidth + ix;
                        dest[index] = 0xffffff10;
                    }

                    {
                        int iy = clamp(cast(int) round(t * texHeight), 0, texHeight - 1);
                        uint index = iy * texWidth + ix;
                        int g = cast(int) lerp(0f, 255f, t);
                        int b = cast(int) lerp(255f, 0f, t);
                        dest[index] = 0x000000ff | (g << 16) | (b << 8);
                    }
                }

            }, &splineFunc);
        }
        catch (Exception e) {
        }
    }
}
