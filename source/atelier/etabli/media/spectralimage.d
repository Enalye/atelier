module atelier.etabli.media.spectralimage;

import std.conv : to;
import std.math : floor, ceil;

import atelier.audio;
import atelier.common;
import atelier.core;
import atelier.render;
import atelier.ui;

final class SpectralImage : Image {
    private {
        Vec2f _size = Vec2f.zero;
        float _virtualSize = 0f;
        float _virtualPosition = 0.5f;
        Sound _sound;
        WritableTexture _cache;
        bool _isDirty;
        int _channelId;
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

        float virtualSize() const {
            return _virtualSize;
        }

        float virtualSize(float size_) {
            if (_virtualSize != size_) {
                _virtualSize = size_;
                _isDirty = true;
            }
            return _virtualSize;
        }

        float virtualPosition() const {
            return _virtualPosition;
        }

        float virtualPosition(float position_) {
            if (_virtualPosition != position_) {
                _virtualPosition = position_;
                _isDirty = true;
            }
            return _virtualPosition;
        }
    }

    this(Vec2f size_, Sound sound_, int channelId) {
        _size = size_;
        _virtualSize = _size.x;
        _sound = sound_;
        _channelId = channelId;
        _isDirty = true;
    }

    override void update() {
    }

    private void _cacheTexture() {
        _isDirty = false;

        _cache = (_size.x >= 1f && _size.y >= 1f) ? new WritableTexture(cast(uint) _size.x,
            cast(uint) _size.y) : null;

        if (!_cache)
            return;

        struct RasterData {
            const(float)[] samples;
            float start, end, ratio;
            int channelId, channelCount, sampleCount;
            uint color;
        }

        RasterData rasterData;
        rasterData.samples = _sound.buffer;

        float sizeRatio = _size.x / _virtualSize;
        rasterData.start = _virtualPosition - sizeRatio / 2f;
        rasterData.end = _virtualPosition + sizeRatio / 2f;
        rasterData.ratio = sizeRatio;
        rasterData.channelId = _channelId;
        rasterData.channelCount = cast(int) _sound.channels;
        rasterData.sampleCount = cast(int) _sound.samples;
        rasterData.color = (Atelier.theme.accent.toHex() << 8) | 0xff;

        _cache.update(function(uint* dest, uint texWidth, uint texHeight, void* data_) {
            RasterData* data = cast(RasterData*) data_;
            const(float)[] samples = data.samples;
            float samplesLength = cast(float) data.sampleCount;

            int samplesPerPixel = cast(int)((samplesLength / texWidth) * data.ratio);
            samplesPerPixel = min(data.sampleCount, samplesPerPixel);
            int step = max(1, samplesPerPixel / 32);

            for (int ix; ix < texWidth; ++ix) {
                float minAmplitude = 0f;
                float maxAmplitude = 0f;
                int index = cast(int) lerp(data.start * samplesLength,
                    data.end * samplesLength, (cast(float) ix) / cast(float) texWidth);

                if (index >= 0 && index < data.sampleCount) {
                    minAmplitude = samples[index * data.channelCount + data.channelId];
                    maxAmplitude = minAmplitude;
                }

                if (samplesPerPixel > 1) {
                    for (int index2 = index; index2 < index + samplesPerPixel; index2 += step) {
                        if (index2 >= 0 && index2 < data.sampleCount) {
                            float amplitude = samples[index2 * data.channelCount + data.channelId];
                            if (amplitude < minAmplitude)
                                minAmplitude = amplitude;
                            if (amplitude > maxAmplitude)
                                maxAmplitude = amplitude;
                        }
                    }
                }

                minAmplitude = 1f - ((clamp(minAmplitude, -1f, 1f) + 1f) / 2f);
                maxAmplitude = 1f - ((clamp(maxAmplitude, -1f, 1f) + 1f) / 2f);

                int upperBound = cast(int)(texHeight * maxAmplitude).floor();
                int lowerBound = cast(int)(texHeight * minAmplitude).ceil();

                upperBound = max(upperBound, 0);
                lowerBound = min(lowerBound, texHeight - 1);
                if (upperBound != 0 && lowerBound != 0) {
                    for (size_t iy; iy < texHeight; ++iy) {
                        dest[iy * texWidth + ix] = iy >= upperBound &&
                            iy <= lowerBound ? data.color : 0x00000000;
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
