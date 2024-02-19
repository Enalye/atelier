/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.core.loader;

import std.exception : enforce;
import std.file;
import std.format : format;
import std.path;

import farfadet;
import atelier.audio;
import atelier.common;
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
    res.setLoader("sound", &_compileSound, &_loadSound);
    res.setLoader("music", &_compileMusic, &_loadMusic);
    res.setLoader("truetype", &_compileTtf, &_loadTtf);
    res.setLoader("bitmapfont", &_compileBitmapFont, &_loadBitmapFont);
}

/// Crée des textures
private void _compileTexture(string path, const Farfadet ffd, OutStream stream) {
    string name = ffd.get!string(0);
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
    enforce(hasFilePath, format!"`%s` ne défini pas `file`"(name));

    stream.write!string(name);
    stream.write!string(path ~ filePath);
}

private void _loadTexture(InStream stream) {
    string name = stream.read!string();
    string filePath = stream.read!string();

    Atelier.res.store(name, {
        Texture texture = new Texture(filePath);
        return texture;
    });
}

/// Crée des sprites
private void _compileSprite(string path, const Farfadet ffd, OutStream stream) {
    string name = ffd.get!string(0);
    string textureName;
    Vec4i clip = Vec4i(-1, -1, -1, -1);
    bool hasTexture, hasClip;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "texture":
            textureName = node.get!string(0);
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

    enforce(hasTexture, format!"`%s` ne défini pas `texture`"(name));

    stream.write!string(name);
    stream.write!string(textureName);

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
    string name = stream.read!string();
    string file = stream.read!string();
    Vec4i clip;
    bool hasClip;

    clip.x = stream.read!int();

    if (clip.x >= 0) {
        clip.y = stream.read!int();
        clip.z = stream.read!int();
        clip.w = stream.read!int();
        hasClip = true;
    }

    Atelier.res.store(name, {
        Texture texture = Atelier.res.get!Texture(file);
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
    string name = ffd.get!string(0);
    string textureName;
    Vec4i clip = Vec4i(-1, -1, -1, -1);
    bool hasTexture, hasClip;
    int top, bottom, left, right;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "texture":
            textureName = node.get!string(0);
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

    enforce(hasTexture, format!"`%s` ne défini pas `texture`"(name));

    stream.write!string(name);
    stream.write!string(textureName);

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
    string name = stream.read!string();
    string file = stream.read!string();
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

    Atelier.res.store(name, {
        Texture texture = Atelier.res.get!Texture(file);
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
    string name = ffd.get!string(0);
    string textureName;
    Vec4i clip = Vec4i(-1, -1, -1, -1);
    Vec2i margin;
    bool hasTexture, hasClip;
    int frameTime, columns, lines, maxCount;
    int[] frames;
    bool repeat;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "texture":
            textureName = node.get!string(0);
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

    enforce(hasTexture, format!"`%s` ne défini pas `texture`"(name));

    stream.write!string(name);
    stream.write!string(textureName);

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
    string name = stream.read!string();
    string file = stream.read!string();
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

    Atelier.res.store(name, {
        Texture texture = Atelier.res.get!Texture(file);
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
    string name = ffd.get!string(0);
    string textureName;
    Vec4i clip = Vec4i(-1, -1, -1, -1);
    Vec2i margin;
    bool hasTexture, hasClip;
    int frameTime, columns, lines, maxCount;
    int[] tileFrames;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "texture":
            textureName = node.get!string(0);
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

    enforce(hasTexture, format!"`%s` ne défini pas `texture`"(name));

    stream.write!string(name);
    stream.write!string(textureName);

    if (hasClip) {
        stream.write!int(clip.x);
        stream.write!int(clip.y);
        stream.write!int(clip.z);
        stream.write!int(clip.w);
    }
    else {
        stream.write!int(-1);
    }

    stream.write!int(columns);
    stream.write!int(lines);
    stream.write!int(maxCount);
    stream.write!(int[])(tileFrames);
    stream.write!int(frameTime);
    stream.write!int(margin.x);
    stream.write!int(margin.y);
}

private void _loadTileset(InStream stream) {
    string name = stream.read!string();
    string file = stream.read!string();
    Vec4i clip;
    bool hasClip;

    clip.x = stream.read!int();

    if (clip.x >= 0) {
        clip.y = stream.read!int();
        clip.z = stream.read!int();
        clip.w = stream.read!int();
        hasClip = true;
    }

    int columns = stream.read!int();
    int lines = stream.read!int();
    int maxCount = stream.read!int();
    int[] tileFrames = stream.read!(int[])();
    int frameTime = stream.read!int();

    Vec2i margin;
    margin.x = stream.read!int();
    margin.y = stream.read!int();

    Atelier.res.store(name, {
        Texture texture = Atelier.res.get!Texture(file);
        if (!hasClip) {
            clip.x = 0;
            clip.y = 0;
            clip.z = texture.width;
            clip.w = texture.height;
        }

        Tileset tileset = new Tileset(texture, clip, columns, lines, maxCount);
        tileset.frameTime = frameTime;
        tileset.margin = margin;

        for (int tileId; tileId < tileFrames.length; tileId += 2) {
            tileset.setTileFrame(cast(short) tileFrames[tileId], cast(short) tileFrames[tileId + 1]);
        }
        return tileset;
    });
}

/// Crée un son
private void _compileSound(string path, const Farfadet ffd, OutStream stream) {
    string name = ffd.get!string(0);
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
    enforce(hasFilePath, format!"`%s` ne défini pas `file`"(name));

    stream.write!string(name);
    stream.write!string(path ~ filePath);
    stream.write!float(volume);
}

private void _loadSound(InStream stream) {
    string name = stream.read!string();
    string file = stream.read!string();
    float volume = stream.read!float();

    Atelier.res.store(name, {
        Sound sound = new Sound(file);
        sound.volume = volume;
        return sound;
    });
}

/// Crée une musique
private void _compileMusic(string path, const Farfadet ffd, OutStream stream) {
    string name = ffd.get!string(0);
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
    enforce(hasFilePath, format!"`%s` ne défini pas `file`"(name));

    stream.write!string(name);
    stream.write!string(path ~ filePath);
    stream.write!float(volume);
    stream.write!float(loopStart);
    stream.write!float(loopEnd);
}

private void _loadMusic(InStream stream) {
    string name = stream.read!string();
    string file = stream.read!string();
    float volume = stream.read!float();
    float loopStart = stream.read!float();
    float loopEnd = stream.read!float();

    Atelier.res.store(name, {
        Music music = new Music(file);
        music.volume = volume;
        music.loopStart = loopStart;
        music.loopEnd = loopEnd;
        return music;
    });
}

private void _compileTtf(string path, const Farfadet ffd, OutStream stream) {
    string name = ffd.get!string(0);
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
    enforce(hasFilePath, format!"`%s` ne défini pas `file`"(name));
    enforce(hasSize, format!"`%s` ne défini pas `size`"(name));

    stream.write!string(name);
    stream.write!string(path ~ filePath);
    stream.write!int(size);
    stream.write!int(outline);
}

private void _loadTtf(InStream stream) {
    string name = stream.read!string();
    string file = stream.read!string();
    int size = stream.read!int();
    int outline = stream.read!int();

    Atelier.res.store(name, {
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
    string name = ffd.get!string(0);
    string textureName;
    Metrics[] metricsList;
    int size, ascent, descent;
    bool hasTexture, hasSize, hasAscent, hasDescent;

    foreach (node; ffd.nodes) {
        switch (node.name) {
        case "texture":
            textureName = node.get!string(0);
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

    enforce(hasTexture, format!"`%s` ne défini pas `texture`"(name));
    enforce(hasSize, format!"`%s` ne défini pas `size`"(name));
    enforce(hasAscent, format!"`%s` ne défini pas `ascent`"(name));
    enforce(hasDescent, format!"`%s` ne défini pas `descent`"(name));

    stream.write!string(name);
    stream.write!string(textureName);
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
    string name = stream.read!string();
    string textureName = stream.read!string();
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

    Atelier.res.store(name, {
        Texture texture = Atelier.res.get!Texture(textureName);
        BitmapFont font = new BitmapFont(texture, size, ascent, descent);

        foreach (ref Metrics metrics; metricsList) {
            font.addCharacter(metrics.ch, metrics.advance, metrics.offsetX,
                metrics.offsetY, metrics.width, metrics.height, metrics.posX,
                metrics.posY, metrics.kerningChar, metrics.kerningOffset);
        }
        return font;
    });
}
