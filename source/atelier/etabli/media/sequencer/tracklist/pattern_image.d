module atelier.etabli.media.sequencer.tracklist.pattern_image;

import std.conv : to;
import std.algorithm.comparison : min, max;
import std.math : ceil, abs;
import atelier;

final class PatternImage : Image {
    private {
        Vec2f _size = Vec2f.zero;
        float _radius = 0f;
        float _thickness = 1f;
        bool _isDirty;

        struct Note {
            uint note, start, end, velocity;
        }

        Note[] _notes;
        uint _steps;
        WritableTexture _cache;
    }

    @property {
        Vec2f size() const {
            return _size;
        }

        Vec2f size(Vec2f size_) {
            if (_size != size_) {
                _size = size_;
                _isDirty = true;
            }
            return _size;
        }

        float radius() const {
            return _radius;
        }

        float radius(float radius_) {
            if (_radius != radius_) {
                _radius = radius_;
                _isDirty = true;
            }
            return _radius;
        }
    }

    this(Vec2f size_, float radius_) {
        _size = size_;
        _radius = radius_;
        _isDirty = true;
    }

    void clearNotes() {
        _notes.length = 0;
        _isDirty = true;
    }

    void addNote(uint note, uint start, uint end, uint velocity) {
        _notes ~= Note(note, start, end, velocity);
        _isDirty = true;
    }

    void setSteps(uint steps) {
        _steps = steps;
    }

    override void update() {
    }

    private void _cacheTexture() {
        _isDirty = false;

        _cache = (_size.x >= 1f && _size.y >= 1f) ? new WritableTexture(cast(uint) _size.x,
            cast(uint) _size.y) : null;

        if (!_cache)
            return;

        if (_radius * 2f > min(_size.x, _size.y)) {
            _radius = min(_size.x, _size.y) / 2f;
        }

        struct RasterNote {
            uint y, x, x2, v;
        }

        struct RasterData {
            float radius;
            float thickness;
            bool filled;
            RasterNote[] rasterNotes;
            uint noteHeight;
        }

        RasterData rasterData;
        rasterData.radius = _radius;
        rasterData.thickness = _thickness;

        uint minNote = 127, maxNote = 0;
        for (uint i; i < _notes.length; ++i) {
            if (_notes[i].note < minNote)
                minNote = _notes[i].note;
            if (_notes[i].note > maxNote)
                maxNote = _notes[i].note;
        }

        maxNote++;
        minNote--;

        for (uint i; i < _notes.length; ++i) {
            RasterNote rNote;
            float y = clamp(rlerp(maxNote, minNote, _notes[i].note), 0f, 1f) * _size.y;
            float x = clamp(rlerp(0, _steps, _notes[i].start), 0f, 1f) * _size.x;
            float x2 = clamp(rlerp(0, _steps, _notes[i].end), 0f, 1f) * _size.x;
            rNote.y = cast(uint) y;
            rNote.x = cast(uint) x;
            rNote.x2 = cast(uint) x2;
            rNote.v = 255 - clamp(cast(uint)((_notes[i].velocity / 127f) * 255f), 0, 255);
            rasterData.rasterNotes ~= rNote;
        }
        if (_notes.length) {
            rasterData.noteHeight = cast(uint)(_size.y / (maxNote - minNote));
        }
        else {
            rasterData.noteHeight = 0;
        }

        _cache.update(function(uint* dest, uint texWidth, uint texHeight, void* data_) {
            RasterData* data = cast(RasterData*) data_;
            int corner = cast(int) data.radius;
            const offsetY = (texHeight - corner) * texWidth;
            const texInternalW = texWidth - (corner * 2);

            // Coins supérieurs
            for (int iy; iy < corner; ++iy) {
                // Coin haut gauche
                for (int ix; ix < corner; ++ix) {
                    Vec2f point = Vec2f(ix, iy) + .5f;
                    float dist = point.distance(Vec2f(corner, corner));
                    float value = clamp(dist - corner, 0f, 1f);

                    dest[iy * texWidth + ix] = 0xFFFFFF00 | (cast(ubyte) lerp(255f, 0f, value));
                }

                // Coin haut droite
                for (int ix; ix < corner; ++ix) {
                    Vec2f point = Vec2f(ix, iy) + .5f;
                    float dist = point.distance(Vec2f(0f, corner));
                    float value = clamp(dist - corner, 0f, 1f);

                    dest[(iy + 1) * texWidth + (ix - corner)] = 0xFFFFFF00 | (cast(ubyte) lerp(255f,
                        0f, value));
                }
            }

            // Coins inférieurs
            for (int iy; iy < corner; ++iy) {
                // Coin bas gauche
                for (int ix; ix < corner; ++ix) {
                    Vec2f point = Vec2f(ix, iy) + .5f;
                    float dist = point.distance(Vec2f(corner, 0f));
                    float value = clamp(dist - corner, 0f, 1f);

                    dest[iy * texWidth + ix + offsetY] = 0xFFFFFF00 | (cast(ubyte) lerp(255f,
                        0f, value));
                }

                // Coin bas droite
                for (int ix; ix < corner; ++ix) {
                    Vec2f point = Vec2f(ix, iy) + .5f;
                    float dist = point.distance(Vec2f.zero);
                    float value = clamp(dist - corner, 0f, 1f);

                    dest[(iy + 1) * texWidth + ix + offsetY - corner] = 0xFFFFFF00 | (cast(ubyte) lerp(255f,
                        0f, value));
                }
            }

            // Bord supérieur
            for (int iy; iy < corner; ++iy) {
                for (int ix; ix < texInternalW; ++ix) {
                    dest[iy * texWidth + ix + corner] = 0xFFFFFFFF;
                }
            }

            // Bord inférieur
            for (int iy; iy < corner; ++iy) {
                for (int ix; ix < texInternalW; ++ix) {
                    dest[iy * texWidth + ix + corner + offsetY] = 0xFFFFFFFF;
                }
            }

            // Bords latéraux
            for (int iy = corner; iy < (texHeight - corner); ++iy) {
                // Bord gauche
                for (int ix; ix < corner; ++ix) {
                    dest[iy * texWidth + ix] = 0xFFFFFFFF;
                }

                // Bord droite
                for (int ix; ix < corner; ++ix) {
                    dest[(iy + 1) * texWidth + (ix - corner)] = 0xFFFFFFFF;
                }
            }

            // Centre
            for (int iy = corner; iy < (texHeight - corner); ++iy) {
                for (int ix = corner; ix < (texWidth - corner); ++ix) {
                    dest[iy * texWidth + ix] = 0xFFFFFFFF;
                }
            }

            for (int i = 0; i < data.rasterNotes.length; ++i) {
                uint y = data.rasterNotes[i].y;
                uint x = data.rasterNotes[i].x;
                uint x2 = data.rasterNotes[i].x2;
                uint v = data.rasterNotes[i].v;

                for (int iy = y; iy < y + data.noteHeight; ++iy) {
                    for (int ix = x; ix < x2; ++ix) {
                        dest[iy * texWidth + ix] = 0xFFFFFF00 | (cast(ubyte) v);
                    }
                }
            }

        }, &rasterData);
    }

    /// Redimensionne l’image pour qu’elle puisse tenir dans une taille donnée
    override void fit(Vec2f size_) {
        size = to!Vec2f(clip.zw).fit(size_);
    }

    /// Redimensionne l’image pour qu’elle puisse contenir une taille donnée
    override void contain(Vec2f size_) {
        size = to!Vec2f(clip.zw).contain(size_);
    }

    override void draw(Vec2f origin = Vec2f.zero) {
        if (_isDirty)
            _cacheTexture();

        if (!_cache)
            return;

        _cache.color = color;
        _cache.blend = blend;
        _cache.alpha = alpha;
        _cache.draw(origin + (position - anchor * size), _size, Vec4u(0, 0,
                _cache.width, _cache.height), angle, pivot, flipX, flipY);
    }
}
