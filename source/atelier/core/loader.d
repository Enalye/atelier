/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.core.loader;

import std.conv : to, ConvException;
import std.exception : enforce;
import std.file;
import std.format : format;
import std.path;

import farfadet;
import atelier.audio;
import atelier.common;
import atelier.scene;
import atelier.render;
import atelier.core.data;
import atelier.core.runtime;

/// Initialise les ressources
void setupDefaultResourceLoaders(ResourceManager res) {
    loadInternalData(res);
    res.setLoader("texture", &_compileTexture, &_loadTexture);
    res.setLoader("sprite", &_compileSprite, &_loadSprite);
    res.setLoader("animation", &_compileAnimation, &_loadAnimation);
    res.setLoader("ninepatch", &_compileNinepatch, &_loadNinepatch);
    res.setLoader("tileset", &_compileTileset, &_loadTileset);
    res.setLoader("tilemap", &_compileTilemap, &_loadTilemap);
    res.setLoader("sound", &_compileSound, &_loadSound);
    res.setLoader("music", &_compileMusic, &_loadMusic);
    res.setLoader("truetype", &_compileTtf, &_loadTtf);
    res.setLoader("bitmapfont", &_compileBitmapFont, &_loadBitmapFont);
    res.setLoader("particle", &_compileParticle, &_loadParticle);
    res.setLoader("level", &_compileLevel, &_loadLevel);
}

/// Crée des textures
private void _compileTexture(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);
    string filePath;
    bool hasFilePath;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "file":
            filePath = node.get!string(0);
            hasFilePath = true;
            break;
        default:
            break;
        }
    }
    enforce(hasFilePath, format!"`%s` ne défini pas `file`"(rid));

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
}

private void _loadTexture(InStream stream) {
    string rid = stream.read!string();
    string filePath = stream.read!string();

    Atelier.res.store(rid, {
        Texture texture = new Texture(filePath);
        return texture;
    });
}

/// Crée des sprites
private void _compileSprite(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);
    string textureRID;
    Vec4i clip = Vec4i(-1, -1, -1, -1);
    bool hasTexture, hasClip;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "texture":
            textureRID = node.get!string(0);
            hasTexture = true;
            break;
        case "clip":
            clip.x = node.get!int(0);
            clip.y = node.get!int(1);
            clip.z = node.get!int(2);
            clip.w = node.get!int(3);
            hasClip = true;
            break;
        default:
            break;
        }
    }

    enforce(hasTexture, format!"`%s` ne défini pas `texture`"(rid));

    stream.write!string(rid);
    stream.write!string(textureRID);

    if (hasClip) {
        stream.write!int(clip.x);
        stream.write!int(clip.y);
        stream.write!int(clip.z);
        stream.write!int(clip.w);
    }
    else {
        stream.write!int(-1);
    }
}

private void _loadSprite(InStream stream) {
    string rid = stream.read!string();
    string textureRID = stream.read!string();
    Vec4i clip;
    bool hasClip;

    clip.x = stream.read!int();

    if (clip.x >= 0) {
        clip.y = stream.read!int();
        clip.z = stream.read!int();
        clip.w = stream.read!int();
        hasClip = true;
    }

    Atelier.res.store(rid, {
        Texture texture = Atelier.res.get!Texture(textureRID);
        if (!hasClip) {
            clip.x = 0;
            clip.y = 0;
            clip.z = texture.width;
            clip.w = texture.height;
        }
        Sprite sprite = new Sprite(texture, clip);
        return sprite;
    });
}

/// Crée des Ninepatch
private void _compileNinepatch(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);
    string textureRID;
    Vec4i clip = Vec4i(-1, -1, -1, -1);
    bool hasTexture, hasClip;
    int top, bottom, left, right;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "texture":
            textureRID = node.get!string(0);
            hasTexture = true;
            break;
        case "clip":
            clip.x = node.get!int(0);
            clip.y = node.get!int(1);
            clip.z = node.get!int(2);
            clip.w = node.get!int(3);
            hasClip = true;
            break;
        case "top":
            top = node.get!int(0);
            break;
        case "bottom":
            bottom = node.get!int(0);
            break;
        case "left":
            left = node.get!int(0);
            break;
        case "right":
            right = node.get!int(0);
            break;
        default:
            break;
        }
    }

    enforce(hasTexture, format!"`%s` ne défini pas `texture`"(rid));

    stream.write!string(rid);
    stream.write!string(textureRID);

    if (hasClip) {
        stream.write!int(clip.x);
        stream.write!int(clip.y);
        stream.write!int(clip.z);
        stream.write!int(clip.w);
    }
    else {
        stream.write!int(-1);
    }

    stream.write!int(top);
    stream.write!int(bottom);
    stream.write!int(left);
    stream.write!int(right);
}

private void _loadNinepatch(InStream stream) {
    string rid = stream.read!string();
    string textureRID = stream.read!string();
    Vec4i clip;
    bool hasClip;

    clip.x = stream.read!int();

    if (clip.x >= 0) {
        clip.y = stream.read!int();
        clip.z = stream.read!int();
        clip.w = stream.read!int();
        hasClip = true;
    }

    int top = stream.read!int();
    int bottom = stream.read!int();
    int left = stream.read!int();
    int right = stream.read!int();

    Atelier.res.store(rid, {
        Texture texture = Atelier.res.get!Texture(textureRID);
        if (!hasClip) {
            clip.x = 0;
            clip.y = 0;
            clip.z = texture.width;
            clip.w = texture.height;
        }
        NinePatch ninePatch = new NinePatch(texture, clip, top, bottom, left, right);
        return ninePatch;
    });
}

/// Crée des Animations
private void _compileAnimation(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);
    string textureRID;
    Vec4i clip = Vec4i(-1, -1, -1, -1);
    Vec2i margin;
    bool hasTexture, hasClip;
    int frameTime, columns, lines, maxCount;
    int[] frames;
    bool repeat;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "texture":
            textureRID = node.get!string(0);
            hasTexture = true;
            break;
        case "clip":
            clip.x = node.get!int(0);
            clip.y = node.get!int(1);
            clip.z = node.get!int(2);
            clip.w = node.get!int(3);
            hasClip = true;
            break;
        case "frameTime":
            frameTime = node.get!int(0);
            break;
        case "frames":
            frames = node.get!(int[])(0);
            break;
        case "repeat":
            repeat = node.get!bool(0);
            break;
        case "columns":
            columns = node.get!int(0);
            break;
        case "lines":
            lines = node.get!int(0);
            break;
        case "maxCount":
            maxCount = node.get!int(0);
            break;
        case "margin":
            margin = Vec2i(node.get!int(0), node.get!int(1));
            break;
        default:
            break;
        }
    }

    enforce(hasTexture, format!"`%s` ne défini pas `texture`"(rid));

    stream.write!string(rid);
    stream.write!string(textureRID);

    if (hasClip) {
        stream.write!int(clip.x);
        stream.write!int(clip.y);
        stream.write!int(clip.z);
        stream.write!int(clip.w);
    }
    else {
        stream.write!int(-1);
    }

    stream.write!(int[])(frames);
    stream.write!int(frameTime);
    stream.write!bool(repeat);
    stream.write!int(columns);
    stream.write!int(lines);
    stream.write!int(maxCount);
    stream.write!int(margin.x);
    stream.write!int(margin.y);
}

private void _loadAnimation(InStream stream) {
    string rid = stream.read!string();
    string textureRID = stream.read!string();
    Vec4i clip;
    bool hasClip;

    clip.x = stream.read!int();

    if (clip.x >= 0) {
        clip.y = stream.read!int();
        clip.z = stream.read!int();
        clip.w = stream.read!int();
        hasClip = true;
    }

    int[] frames = stream.read!(int[])();
    int frameTime = stream.read!int();
    bool repeat = stream.read!bool();
    int columns = stream.read!int();
    int lines = stream.read!int();
    int maxCount = stream.read!int();

    Vec2i margin;
    margin.x = stream.read!int();
    margin.y = stream.read!int();

    Atelier.res.store(rid, {
        Texture texture = Atelier.res.get!Texture(textureRID);
        if (!hasClip) {
            clip.x = 0;
            clip.y = 0;
            clip.z = texture.width;
            clip.w = texture.height;
        }

        Animation animation = new Animation(texture, clip, columns, lines, maxCount);
        animation.margin = margin;
        animation.repeat = repeat;
        animation.frames = frames;
        animation.frameTime = frameTime;
        return animation;
    });
}

/// Crée des Tilesets
private void _compileTileset(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);
    string textureRID;
    Vec4i clip = Vec4i(-1, -1, -1, -1);
    Vec2i margin;
    Vec2i tileSize;
    bool hasTexture, hasClip;
    int frameTime, columns, lines, maxCount;
    int[] tileFrames;
    bool isIsometric;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "texture":
            textureRID = node.get!string(0);
            hasTexture = true;
            break;
        case "clip":
            clip.x = node.get!int(0);
            clip.y = node.get!int(1);
            clip.z = node.get!int(2);
            clip.w = node.get!int(3);
            hasClip = true;

            if (tileSize.sum() == 0) {
                tileSize = clip.zw;
            }
            break;
        case "tileSize":
            tileSize = Vec2i(node.get!int(0), node.get!int(1));
            break;
        case "isIsometric":
            isIsometric = node.get!bool(0);
            break;
        case "frameTime":
            frameTime = node.get!int(0);
            break;
        case "tileFrame":
            tileFrames ~= node.get!int(0);
            tileFrames ~= node.get!int(1);
            break;
        case "columns":
            columns = node.get!int(0);
            break;
        case "lines":
            lines = node.get!int(0);
            break;
        case "maxCount":
            maxCount = node.get!int(0);
            break;
        case "margin":
            margin = Vec2i(node.get!int(0), node.get!int(1));
            break;
        default:
            break;
        }
    }

    enforce(hasTexture, format!"`%s` ne défini pas `texture`"(rid));

    stream.write!string(rid);
    stream.write!string(textureRID);

    if (hasClip) {
        stream.write!int(clip.x);
        stream.write!int(clip.y);
        stream.write!int(clip.z);
        stream.write!int(clip.w);
    }
    else {
        stream.write!int(-1);
    }

    stream.write!Vec2i(tileSize);
    stream.write!int(columns);
    stream.write!int(lines);
    stream.write!int(maxCount);
    stream.write!bool(isIsometric);
    stream.write!(int[])(tileFrames);
    stream.write!int(frameTime);
    stream.write!int(margin.x);
    stream.write!int(margin.y);
}

private void _loadTileset(InStream stream) {
    string rid = stream.read!string();
    string textureRID = stream.read!string();
    Vec4i clip;
    bool hasClip;

    clip.x = stream.read!int();

    if (clip.x >= 0) {
        clip.y = stream.read!int();
        clip.z = stream.read!int();
        clip.w = stream.read!int();
        hasClip = true;
    }

    Vec2i tileSize = stream.read!Vec2i();
    int columns = stream.read!int();
    int lines = stream.read!int();
    int maxCount = stream.read!int();
    bool isIsometric = stream.read!bool();
    int[] tileFrames = stream.read!(int[])();
    int frameTime = stream.read!int();

    Vec2i margin;
    margin.x = stream.read!int();
    margin.y = stream.read!int();

    Atelier.res.store(rid, {
        Texture texture = Atelier.res.get!Texture(textureRID);
        if (!hasClip) {
            clip.x = 0;
            clip.y = 0;
            clip.z = texture.width;
            clip.w = texture.height;
        }

        Tileset tileset = new Tileset(texture, clip, columns, lines, maxCount);
        tileset.tileSize = tileSize;
        tileset.frameTime = frameTime;
        tileset.margin = margin;
        tileset.isIsometric = isIsometric;

        for (int tileId; tileId < tileFrames.length; tileId += 2) {
            tileset.setTileFrame(cast(short) tileFrames[tileId], cast(short) tileFrames[tileId + 1]);
        }
        return tileset;
    });
}

/// Crée une tilemap
private void _compileTilemap(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);
    string tilesetRID;
    int width, height;
    bool hasTileset, hasSize;
    int[][] tiles;
    int[][] heightmap;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "tileset":
            tilesetRID = node.get!string(0);
            hasTileset = true;
            break;
        case "size":
            width = node.get!int(0);
            height = node.get!int(1);
            hasSize = true;
            break;
        case "tiles":
            tiles = node.get!(int[][])(0);
            break;
        case "heightmap":
            heightmap = node.get!(int[][])(0);
            break;
        default:
            break;
        }
    }
    enforce(hasTileset, format!"`%s` ne défini pas `tileset`"(rid));
    enforce(hasSize, format!"`%s` ne défini pas `size`"(rid));

    stream.write!string(rid);
    stream.write!int(width);
    stream.write!int(height);
    stream.write!string(tilesetRID);
    stream.write!(int[][])(tiles);
    stream.write!(int[][])(heightmap);
}

private void _loadTilemap(InStream stream) {
    const string rid = stream.read!string();
    const int width = stream.read!int();
    const int height = stream.read!int();
    const string tilesetRID = stream.read!string();
    const int[][] tiles = stream.read!(int[][])();
    const int[][] heightmap = stream.read!(int[][])();

    Atelier.res.store(rid, {
        Tileset tileset = Atelier.res.get!Tileset(tilesetRID);
        Tilemap tilemap = new Tilemap(tileset, width, height);
        if (tiles.length)
            tilemap.setTiles(tiles);
        if (heightmap.length)
            tilemap.setTilesElevation(heightmap);
        return tilemap;
    });
}

/// Crée un son
private void _compileSound(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);
    string filePath;
    bool hasFilePath;
    float volume = 1f;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "file":
            filePath = node.get!string(0);
            hasFilePath = true;
            break;
        case "volume":
            volume = node.get!float(0);
            break;
        default:
            break;
        }
    }
    enforce(hasFilePath, format!"`%s` ne défini pas `file`"(rid));

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
    stream.write!float(volume);
}

private void _loadSound(InStream stream) {
    string rid = stream.read!string();
    string file = stream.read!string();
    float volume = stream.read!float();

    Atelier.res.store(rid, {
        Sound sound = new Sound(file);
        sound.volume = volume;
        return sound;
    });
}

/// Crée une musique
private void _compileMusic(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);
    string filePath;
    bool hasFilePath;
    float volume = 1f;
    float loopStart = -1f;
    float loopEnd = -1f;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "file":
            filePath = node.get!string(0);
            hasFilePath = true;
            break;
        case "volume":
            volume = node.get!float(0);
            break;
        case "loopStart":
            loopStart = node.get!float(0);
            break;
        case "loopEnd":
            loopEnd = node.get!float(0);
            break;
        default:
            break;
        }
    }
    enforce(hasFilePath, format!"`%s` ne défini pas `file`"(rid));

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
    stream.write!float(volume);
    stream.write!float(loopStart);
    stream.write!float(loopEnd);
}

private void _loadMusic(InStream stream) {
    string rid = stream.read!string();
    string file = stream.read!string();
    float volume = stream.read!float();
    float loopStart = stream.read!float();
    float loopEnd = stream.read!float();

    Atelier.res.store(rid, {
        Music music = new Music(file);
        music.volume = volume;
        music.loopStart = loopStart;
        music.loopEnd = loopEnd;
        return music;
    });
}

private void _compileTtf(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);
    string filePath;
    int size, outline;
    bool hasFilePath, hasSize;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "file":
            filePath = node.get!string(0);
            hasFilePath = true;
            break;
        case "size":
            size = node.get!int(0);
            hasSize = true;
            break;
        case "outline":
            outline = node.get!int(0);
            break;
        default:
            break;
        }
    }
    enforce(hasFilePath, format!"`%s` ne défini pas `file`"(rid));
    enforce(hasSize, format!"`%s` ne défini pas `size`"(rid));

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
    stream.write!int(size);
    stream.write!int(outline);
}

private void _loadTtf(InStream stream) {
    string rid = stream.read!string();
    string file = stream.read!string();
    int size = stream.read!int();
    int outline = stream.read!int();

    Atelier.res.store(rid, {
        TrueTypeFont font = new TrueTypeFont(file, size, outline);
        return font;
    });
}

private struct Metrics {
    dchar ch;
    int advance;
    int offsetX;
    int offsetY;
    int width;
    int height;
    int posX;
    int posY;
    dchar[] kerningChar;
    int[] kerningOffset;
}

private void _compileBitmapFont(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);
    string textureRID;
    Metrics[] metricsList;
    int size, ascent, descent;
    bool hasTexture, hasSize, hasAscent, hasDescent;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "texture":
            textureRID = node.get!string(0);
            hasTexture = true;
            break;
        case "size":
            size = node.get!int(0);
            break;
        case "ascent":
            ascent = node.get!int(0);
            break;
        case "descent":
            descent = node.get!int(0);
            break;
        case "char":
            Metrics metrics;
            metrics.ch = node.get!dchar(0);
            foreach (charNode; node.nodes) {
                switch (charNode.name) {
                case "advance":
                    metrics.advance = node.get!int(0);
                    break;
                case "offset":
                    metrics.offsetX = node.get!int(0);
                    metrics.offsetY = node.get!int(1);
                    break;
                case "size":
                    metrics.width = node.get!int(0);
                    metrics.height = node.get!int(1);
                    break;
                case "pos":
                    metrics.posX = node.get!int(0);
                    metrics.posY = node.get!int(1);
                    break;
                case "kerning":
                    metrics.kerningChar ~= node.get!dchar(0);
                    metrics.kerningOffset ~= node.get!int(1);
                    break;
                default:
                    break;
                }
                metricsList ~= metrics;
            }
            break;
        default:
            break;
        }
    }

    enforce(hasTexture, format!"`%s` ne défini pas `texture`"(rid));
    enforce(hasSize, format!"`%s` ne défini pas `size`"(rid));
    enforce(hasAscent, format!"`%s` ne défini pas `ascent`"(rid));
    enforce(hasDescent, format!"`%s` ne défini pas `descent`"(rid));

    stream.write!string(rid);
    stream.write!string(textureRID);
    stream.write!int(size);
    stream.write!int(ascent);
    stream.write!int(descent);

    stream.write!int(cast(int) metricsList.length);
    foreach (ref metrics; metricsList) {
        stream.write!dchar(metrics.ch);
        stream.write!int(metrics.advance);
        stream.write!int(metrics.offsetX);
        stream.write!int(metrics.offsetY);
        stream.write!int(metrics.width);
        stream.write!int(metrics.height);
        stream.write!int(metrics.posX);
        stream.write!int(metrics.posY);

        stream.write!int(cast(int) metrics.kerningChar.length);
        for (int i; i < metrics.kerningChar.length; i++) {
            stream.write!dchar(metrics.kerningChar[i]);
            stream.write!int(metrics.kerningOffset[i]);
        }
    }
}

private void _loadBitmapFont(InStream stream) {
    string rid = stream.read!string();
    string textureRID = stream.read!string();
    int size = stream.read!int();
    int ascent = stream.read!int();
    int descent = stream.read!int();

    Metrics[] metricsList;

    int charCount = stream.read!int();
    for (int i; i < charCount; ++i) {
        Metrics metrics;
        metrics.ch = stream.read!dchar();
        metrics.advance = stream.read!int();
        metrics.offsetX = stream.read!int();
        metrics.offsetY = stream.read!int();
        metrics.width = stream.read!int();
        metrics.height = stream.read!int();
        metrics.posX = stream.read!int();
        metrics.posY = stream.read!int();

        int kerningCount = stream.read!int();
        for (int k; k < kerningCount; ++k) {
            dchar ch = stream.read!dchar();
            int offset = stream.read!int();
            metrics.kerningChar ~= ch;
            metrics.kerningOffset ~= offset;
        }

        metricsList ~= metrics;
    }

    Atelier.res.store(rid, {
        Texture texture = Atelier.res.get!Texture(textureRID);
        BitmapFont font = new BitmapFont(texture, size, ascent, descent);

        foreach (ref Metrics metrics; metricsList) {
            font.addCharacter(metrics.ch, metrics.advance, metrics.offsetX,
                metrics.offsetY, metrics.width, metrics.height, metrics.posX,
                metrics.posY, metrics.kerningChar, metrics.kerningOffset);
        }
        return font;
    });
}

private struct ParticleEffectInfo {
    private {
        string _name;
        Vec2u _frames;
        Vec2f _startVec2f = Vec2f.zero;
        Vec2f _endVec2f = Vec2f.zero;
        float _startFloat = 0f;
        float _endFloat = 0f;
        Color _startColor = Color.white;
        Color _endColor = Color.white;
        Spline _spline;
        int _count;
        int _type;
    }

    void _setType(bool isInterval) {
        if (_type == 0) {
            _type = isInterval ? 2 : 1;
            return;
        }
        enforce(_type == (isInterval ? 2 : 1),
            "l’effet peut soit être de type intervalle, soit instantané");
    }

    void parse(const Farfadet ffd) {
        _name = ffd.name;

        foreach (node; ffd.nodes) {
            switch (node.name) {
            case "frame":
                uint frame = node.get!uint(0);
                _frames = Vec2u(frame, frame);
                _setType(false);
                break;
            case "frames":
                _frames = Vec2u(node.get!uint(0), node.get!uint(1));
                _setType(true);
                break;
            case "spline":
                _setType(true);
                try {
                    _spline = to!Spline(node.get!string(0));
                }
                catch (ConvException e) {
                    enforce(false, "spline `" ~ node.get!string(0) ~ "` n’est pas valide");
                }
                break;
            case "start":
            case "min":
                _setType(node.name == "start");

                switch (_name) {
                case "scale":
                    _startVec2f = Vec2f(node.get!float(0), node.get!float(1));
                    break;
                case "color":
                    _startColor = Color(node.get!float(0), node.get!float(1), node.get!float(2));
                    break;
                default:
                    _startFloat = node.get!float(0);
                    break;
                }
                break;
            case "end":
            case "max":
                _setType(node.name == "end");

                switch (_name) {
                case "scale":
                    _endVec2f = Vec2f(node.get!float(0), node.get!float(1));
                    break;
                case "color":
                    _endColor = Color(node.get!float(0), node.get!float(1), node.get!float(2));
                    break;
                default:
                    _endFloat = node.get!float(0);
                    break;
                }
                break;
            default:
                enforce(false, "`" ~ _name ~ "` ne définit pas le nœud `" ~ node.name ~ "`");
                break;
            }
        }
    }

    void serialize(OutStream stream) {
        stream.write!string(_name);
        stream.write!int(_type);
        if (_type == 1) {
            stream.write!uint(_frames.x);
        }
        else if (_type == 2) {
            stream.write!uint(_frames.x);
            stream.write!uint(_frames.y);
            stream.write!Spline(_spline);
        }

        switch (_name) {
        case "scale":
            stream.write!Vec2f(_startVec2f);
            stream.write!Vec2f(_endVec2f);
            break;
        case "color":
            stream.write!Color(_startColor);
            stream.write!Color(_endColor);
            break;
        default:
            stream.write!float(_startFloat);
            stream.write!float(_endFloat);
            break;
        }
    }

    void deserialize(InStream stream) {
        _name = stream.read!string();
        _type = stream.read!int();
        if (_type == 1) {
            _frames.x = stream.read!uint();
        }
        else if (_type == 2) {
            _frames.x = stream.read!uint();
            _frames.y = stream.read!uint();
            _spline = stream.read!Spline();
        }

        switch (_name) {
        case "scale":
            _startVec2f = stream.read!Vec2f();
            _endVec2f = stream.read!Vec2f();
            break;
        case "color":
            _startColor = stream.read!Color();
            _endColor = stream.read!Color();
            break;
        default:
            _startFloat = stream.read!float();
            _endFloat = stream.read!float();
            break;
        }
    }
}

private void _compileParticle(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    string sprite;
    Blend blend = Blend.alpha;
    bool isRelativePosition, isRelativeSpriteAngle;
    Vec2u lifetime, count;
    ParticleMode mode;
    Vec2f area = Vec2f.zero, distance = Vec2f.zero;
    Vec2f angle = Vec2f.zero;
    float spreadAngle = 0f;
    ParticleEffectInfo[] effects;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "sprite":
            sprite = node.get!string(0);
            break;
        case "blend":
            blend = to!Blend(node.get!string(0));
            break;
        case "isRelativePosition":
            isRelativePosition = node.get!bool(0);
            break;
        case "isRelativeSpriteAngle":
            isRelativeSpriteAngle = node.get!bool(0);
            break;
        case "lifetime":
            lifetime = Vec2u(node.get!uint(0), node.get!uint(1));
            break;
        case "count":
            count = Vec2u(node.get!uint(0), node.get!uint(1));
            break;
        case "mode":
            mode = to!ParticleMode(node.get!string(0));
            break;
        case "area":
            area = Vec2f(node.get!float(0), node.get!float(1));
            break;
        case "distance":
            distance = Vec2f(node.get!float(0), node.get!float(1));
            break;
        case "spread":
            angle = Vec2f(node.get!float(0), node.get!float(1));
            spreadAngle = node.get!float(2);
            break;
        case "speed":
        case "angle":
        case "spin":
        case "pivotAngle":
        case "pivotSpin":
        case "pivotDistance":
        case "spriteAngle":
        case "spriteSpin":
        case "scale":
        case "color":
        case "alpha":
            ParticleEffectInfo effect;
            effect.parse(node);
            effects ~= effect;
            break;
        default:
            enforce(false, "`particle` ne définit pas le nœud `" ~ node.name ~ "`");
            break;
        }
    }

    stream.write!string(rid);
    stream.write!string(sprite);
    stream.write!Blend(blend);
    stream.write!bool(isRelativePosition);
    stream.write!bool(isRelativeSpriteAngle);
    stream.write!Vec2u(lifetime);
    stream.write!Vec2u(count);
    stream.write!ParticleMode(mode);
    stream.write!Vec2f(area);
    stream.write!Vec2f(distance);
    stream.write!Vec2f(angle);
    stream.write!float(spreadAngle);

    stream.write!uint(cast(uint) effects.length);
    foreach (ref ParticleEffectInfo effect; effects) {
        effect.serialize(stream);
    }
}

private void _loadParticle(InStream stream) {
    const string rid = stream.read!string();
    const string sprite = stream.read!string();
    const Blend blend = stream.read!Blend();
    const bool isRelativePosition = stream.read!bool();
    const bool isRelativeSpriteAngle = stream.read!bool();
    const Vec2u lifetime = stream.read!Vec2u();
    const Vec2u count = stream.read!Vec2u();
    const ParticleMode mode = stream.read!ParticleMode();
    const Vec2f area = stream.read!Vec2f();
    const Vec2f distance = stream.read!Vec2f();
    const Vec2f angle = stream.read!Vec2f();
    const float spreadAngle = stream.read!float();

    const uint effectCount = stream.read!uint();
    ParticleEffectInfo[] effects = new ParticleEffectInfo[effectCount];
    for (uint i; i < effectCount; ++i) {
        effects[i].deserialize(stream);
    }

    Atelier.res.store(rid, {
        ParticleSource source = new ParticleSource;
        source.setSprite(sprite);
        source.setBlend(blend);
        source.setRelativePosition(isRelativePosition);
        source.setRelativeSpriteAngle(isRelativeSpriteAngle);
        source.setLifetime(lifetime.x, lifetime.y);
        source.setCount(count.x, count.y);
        source.setMode(mode);
        source.setArea(area.x, area.y);
        source.setDistance(distance.x, distance.y);
        source.setSpread(angle.x, angle.y, spreadAngle);

        foreach (ref ParticleEffectInfo info; effects) {
            ParticleEffect effect;

            if (info._type == 1) {
                switch (info._name) {
                case "speed":
                    effect = new SpeedParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "angle":
                    effect = new AngleParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "spin":
                    effect = new SpinParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "pivotAngle":
                    effect = new PivotAngleParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "pivotSpin":
                    effect = new PivotSpinParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "pivotDistance":
                    effect = new PivotDistanceParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "spriteAngle":
                    effect = new SpriteAngleParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "spriteSpin":
                    effect = new SpriteSpinParticleEffect(info._startFloat, info._endFloat);
                    break;
                case "scale":
                    effect = new ScaleParticleEffect(info._startVec2f, info._endVec2f);
                    break;
                case "color":
                    effect = new ColorParticleEffect(info._startColor, info._endColor);
                    break;
                case "alpha":
                    effect = new AlphaParticleEffect(info._startFloat, info._endFloat);
                    break;
                default:
                    break;
                }
            }
            else if (info._type == 2) {
                SplineFunc splineFunc = getSplineFunc(info._spline);

                switch (info._name) {
                case "speed":
                    effect = new SpeedIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "angle":
                    effect = new AngleIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "spin":
                    effect = new SpinIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "pivotAngle":
                    effect = new PivotAngleIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "pivotSpin":
                    effect = new PivotSpinIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "pivotDistance":
                    effect = new PivotDistanceIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "spriteAngle":
                    effect = new SpriteAngleIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "spriteSpin":
                    effect = new SpriteSpinIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                case "scale":
                    effect = new ScaleIntervalParticleEffect(info._startVec2f,
                        info._endVec2f, splineFunc);
                    break;
                case "color":
                    effect = new ColorIntervalParticleEffect(info._startColor,
                        info._endColor, splineFunc);
                    break;
                case "alpha":
                    effect = new AlphaIntervalParticleEffect(info._startFloat,
                        info._endFloat, splineFunc);
                    break;
                default:
                    break;
                }
            }

            if (effect) {
                effect.setFrames(info._frames.x, info._frames.y);
                source.addEffect(effect);
            }
        }

        return source;
    });
}

private void _compileLevel(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    LevelBuilder level = new LevelBuilder(ffd);
    stream.write!string(rid);
    level.serialize(stream);
}

private void _loadLevel(InStream stream) {
    const string rid = stream.read!string();
    LevelBuilder level = new LevelBuilder;
    level.deserialize(stream);
    Atelier.res.store(rid, { return level; });
}
