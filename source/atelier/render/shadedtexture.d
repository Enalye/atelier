module atelier.render.shadedtexture;

import std.algorithm.comparison : min, max;
import std.conv : to;
import std.exception : enforce;
import std.math : sqrt;
import std.string : toStringz;

import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.render.image;
import atelier.render.renderer;
import atelier.render.writabletexture;
import atelier.render.imagedata;

final class ShadedTexture : Resource!ShadedTexture {
    private {
        SDL_Surface* _surface;
        WritableTexture _texture;
    }

    Color sourceColorA = Color.white;
    Color sourceColorB = Color.black;
    Color targetColorA = Color.white;
    Color targetColorB = Color.white;

    float sourceAlphaA = 1f;
    float sourceAlphaB = 1f;
    float targetAlphaA = 1f;
    float targetAlphaB = 0f;

    Spline spline = Spline.linear;

    @property {
        ImageData data() {
            return _texture;
        }
    }

    /// Accès à la ressource
    ShadedTexture fetch() {
        if (!_texture)
            generate();
        return this;
    }

    static ShadedTexture fromSurface(SDL_Surface* surface) {
        enforce(surface, "invalid surface");
        return new ShadedTexture(surface);
    }

    /// Chargé depuis la mémoire
    static ShadedTexture fromMemory(const(ubyte)[] data) {
        SDL_RWops* rw = SDL_RWFromConstMem(cast(const(void)*) data.ptr, cast(int) data.length);
        SDL_Surface* surface = IMG_Load_RW(rw, 1);
        return ShadedTexture.fromSurface(surface);
    }

    /// Chargé depuis le système de ressources
    static ShadedTexture fromResource(string filePath) {
        const(ubyte)[] data = Atelier.res.read(filePath);
        SDL_RWops* rw = SDL_RWFromConstMem(cast(const(void)*) data.ptr, cast(int) data.length);
        SDL_Surface* surface = IMG_Load_RW(rw, 1);
        enforce(surface, "impossible d’ouvrir le fichier `" ~ filePath ~ "`");
        return new ShadedTexture(surface);
    }

    /// Chargé depuis un fichier
    static ShadedTexture fromFile(string filePath) {
        SDL_Surface* surface = IMG_Load(toStringz(filePath));
        enforce(surface, "impossible d’ouvrir le fichier `" ~ filePath ~ "`");
        return new ShadedTexture(surface);
    }

    private this(SDL_Surface* surface_) {
        _surface = surface_;
    }

    void generate() {
        _texture = new WritableTexture(_surface.w, _surface.h);

        Grid!uint values = new Grid!uint(_surface.w, _surface.h);
        uint* pixels = cast(uint*) _surface.pixels;
        values.defaultValue = 0x0;
        for (uint y; y < _surface.h; ++y) {
            for (uint x; x < _surface.w; ++x) {
                values.setValue(x, y, pixels[y * _surface.w + x]);
            }
        }

        Vec2i[] innerBorders;
        Vec2i[] outerBorders;
        Vec2i[] insides;
        Vec2i[] gradiants;
        float[] gradiantValues;

        Vec2i[4] neighbors = [
            Vec2i(-1, 0), Vec2i(0, -1), Vec2i(1, 0), Vec2i(0, 1)
        ];

        uint sourceValueA = (((cast(uint)(sourceAlphaA * 255f)) & 0xff) << 24) | sourceColorA.toHex();
        uint sourceValueB = (((cast(uint)(sourceAlphaB * 255f)) & 0xff) << 24) | sourceColorB.toHex();

        for (uint y; y < _surface.h; ++y) {
            for (uint x; x < _surface.w; ++x) {
                uint color = values.getValue(x, y);
                if (color == sourceValueA) {
                    foreach (ref neighbor; neighbors) {
                        Vec2i coords = Vec2i(x, y) + neighbor;
                        if (values.getValue(coords.x, coords.y) != sourceValueA) {
                            innerBorders ~= Vec2i(x, y);
                            break;
                        }
                    }
                    insides ~= Vec2i(x, y);
                }
                else if (color == sourceValueB) {
                    foreach (ref neighbor; neighbors) {
                        Vec2i coords = Vec2i(x, y) + neighbor;
                        uint neighborColor = values.getValue(coords.x, coords.y);
                        if (neighborColor != sourceValueB && neighborColor != sourceValueA) {
                            outerBorders ~= Vec2i(x, y);
                            break;
                        }
                    }
                    gradiants ~= Vec2i(x, y);
                }
            }
        }

        gradiantValues.length = gradiants.length;
        foreach (i, ref gradiant; gradiants) {
            Vec2i nearestInnerBorder;
            float nearestInnerDistance = _surface.w * _surface.h;
            nearestInnerDistance *= nearestInnerDistance;

            foreach (innerBorder; innerBorders) {
                float distSq = gradiant.distanceSquared(innerBorder);
                if (distSq < nearestInnerDistance) {
                    nearestInnerBorder = innerBorder;
                    nearestInnerDistance = distSq;
                }
            }

            Vec2i nearestOuterBorder;
            float nearestOuterDistance = _surface.w * _surface.h;
            nearestOuterDistance *= nearestOuterDistance;

            foreach (outerBorder; outerBorders) {
                float distSq = gradiant.distanceSquared(outerBorder);
                if (distSq < nearestOuterDistance) {
                    nearestOuterBorder = outerBorder;
                    nearestOuterDistance = distSq;
                }
            }

            if (nearestInnerDistance > 0f) {
                nearestInnerDistance = sqrt(nearestInnerDistance);
            }

            if (nearestOuterDistance > 0f) {
                nearestOuterDistance = sqrt(nearestOuterDistance);
            }

            float totalDistance = nearestInnerDistance + nearestOuterDistance;
            float t = totalDistance > 0f ? (nearestInnerDistance / totalDistance) : 0f;

            gradiantValues[i] = t;
        }

        struct RasterData {
            Vec2i[] insides;
            Vec2i[] gradiants;
            float[] gradiantValues;
            Color targetColorA;
            Color targetColorB;
            float targetAlphaA;
            float targetAlphaB;
            SplineFunc spline;
        }

        RasterData rasterData;
        rasterData.insides = insides;
        rasterData.gradiants = gradiants;
        rasterData.gradiantValues = gradiantValues;
        rasterData.targetColorA = targetColorA;
        rasterData.targetColorB = targetColorB;
        rasterData.targetAlphaA = targetAlphaA;
        rasterData.targetAlphaB = targetAlphaB;
        rasterData.spline = getSplineFunc(spline);

        _texture.update(function(uint* dest, uint texWidth, uint texHeight, void* data_) {
            RasterData* data = cast(RasterData*) data_;

            uint targetValueA = (data.targetColorA.toHex() << 8) | (
                (cast(uint)(data.targetAlphaA * 255f)) & 0xff);

            foreach (coords; data.insides) {
                dest[coords.y * texWidth + coords.x] = targetValueA;
            }

            HSLColor targetHslA = HSLColor.fromColor(data.targetColorA);
            HSLColor targetHslB = HSLColor.fromColor(data.targetColorB);

            for (uint i; i < data.gradiants.length; ++i) {
                float t = data.spline(data.gradiantValues[i]);
                Color color = targetHslA.lerp(targetHslB, t).toColor();
                float alpha = clamp(lerp(data.targetAlphaA, data.targetAlphaB, t), 0f, 1f);
                uint value = (color.toHex() << 8) | ((cast(uint)(alpha * 255f)) & 0xff);
                dest[data.gradiants[i].y * texWidth + data.gradiants[i].x] = value;
            }

        }, &rasterData);
    }
}
