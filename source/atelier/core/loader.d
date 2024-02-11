/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.core.loader;

import std.file;
import std.path;
import std.stdio;

import atelier.common, atelier.render;
import atelier.core.runtime;
import atelier.audio;

/// Initialise les ressources
void setupDefaultResourceLoaders(ResourceManager res) {
    res.setLoader("image", &_compileImage, &_loadImage);
    res.setLoader("sound", &_compileSound, &_loadSound);
    res.setLoader("music", &_compileMusic, &_loadMusic);
    res.setLoader("truetype", &_compileTtf, &_loadTtf);
}

/// Crée des sprites
private void _compileImage(string path, Json json, OutStream stream) {
    stream.write!string(path ~ Archive.Separator ~ json.getString("file"));

    Json[] atlas = json.getObjects("atlas");
    stream.write!uint(cast(uint) atlas.length);
    foreach (Json elementNode; atlas) {
        stream.write!string(elementNode.getString("name"));
        string type = elementNode.getString("type");
        stream.write!string(type);

        Vec4i clip = Vec4i(-1, -1, -1, -1);

        if (elementNode.has("clip")) {
            Json clipNode = elementNode.getObject("clip");
            clip.x = clipNode.getInt("x", clip.x);
            clip.y = clipNode.getInt("y", clip.y);
            clip.z = clipNode.getInt("w", clip.z);
            clip.w = clipNode.getInt("h", clip.w);
        }

        stream.write!int(clip.x);
        stream.write!int(clip.y);
        stream.write!int(clip.z);
        stream.write!int(clip.w);

        switch (type) {
        case "animation":
            stream.write!(int[])(elementNode.getInts("frames", []));
            stream.write!int(elementNode.getInt("frameTime", 1));
            stream.write!bool(elementNode.getBool("repeat", false));
            stream.write!int(elementNode.getInt("columns", 1));
            stream.write!int(elementNode.getInt("lines", 1));
            stream.write!int(elementNode.getInt("maxCount", 0));

            if (elementNode.has("margin")) {
                Json marginNode = elementNode.getObject("margin");
                stream.write!int(marginNode.getInt("x", 0));
                stream.write!int(marginNode.getInt("y", 0));
            }
            else {
                stream.write!int(0);
                stream.write!int(0);
            }
            break;
        case "ninepatch":
            stream.write!int(elementNode.getInt("top", 0));
            stream.write!int(elementNode.getInt("bottom", 0));
            stream.write!int(elementNode.getInt("left", 0));
            stream.write!int(elementNode.getInt("right", 0));
            break;
        case "tileset":
            stream.write!int(elementNode.getInt("columns", 1));
            stream.write!int(elementNode.getInt("lines", 1));
            stream.write!int(elementNode.getInt("maxCount", 0));
            stream.write!(int[])(elementNode.getInts("tileFrames", []));
            stream.write!int(elementNode.getInt("frameTime", 1));
            break;
        default:
            break;
        }
    }
}

private void _loadImage(InStream stream) {
    string file = stream.read!string();
    Texture texture = new Texture(file);

    uint nbSprites = stream.read!uint();
    for (int i; i < nbSprites; ++i) {
        string name = stream.read!string();
        string type = stream.read!string();

        Vec4i clip;

        clip.x = stream.read!int();
        clip.y = stream.read!int();
        clip.z = stream.read!int();
        clip.w = stream.read!int();

        if (clip.x == -1)
            clip.x = 0;
        if (clip.y == -1)
            clip.y = 0;
        if (clip.z == -1)
            clip.z = texture.width;
        if (clip.w == -1)
            clip.w = texture.height;

        switch (type) {
        case "sprite":
            Atelier.res.store(name, {
                Sprite sprite = new Sprite(texture, clip);
                return sprite;
            });
            break;
        case "animation":
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
                Animation animation = new Animation(texture, clip, columns, lines, maxCount);
                animation.margin = margin;
                animation.repeat = repeat;
                animation.frames = frames;
                animation.frameTime = frameTime;
                return animation;
            });
            break;
        case "ninepatch":
            int top = stream.read!int();
            int bottom = stream.read!int();
            int left = stream.read!int();
            int right = stream.read!int();

            Atelier.res.store(name, {
                NinePatch ninePatch = new NinePatch(texture, clip, top, bottom, left, right);
                return ninePatch;
            });
            break;
        case "tileset":
            int columns = stream.read!int();
            int lines = stream.read!int();
            int maxCount = stream.read!int();
            int[] tileFrames = stream.read!(int[])();
            int frameTime = stream.read!int();

            Atelier.res.store(name, {
                Tileset tileset = new Tileset(texture, clip, columns, lines, maxCount);
                tileset.frameTime = frameTime;

                for (int tileId; tileId < tileFrames.length; tileId += 2) {
                    tileset.setTileFrame(cast(short) tileFrames[tileId],
                        cast(short) tileFrames[tileId + 1]);
                }
                return tileset;
            });
            break;
        default:
            break;
        }
    }
}

/// Crée un son
private void _compileSound(string path, Json json, OutStream stream) {
    stream.write!string(json.getString("name"));
    stream.write!string(path ~ Archive.Separator ~ json.getString("file"));
    stream.write!float(json.getFloat("volume", 1f));
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
private void _compileMusic(string path, Json json, OutStream stream) {
    stream.write!string(json.getString("name"));
    stream.write!string(path ~ Archive.Separator ~ json.getString("file"));
    stream.write!float(json.getFloat("volume", 1f));
    stream.write!float(json.getFloat("loopStart", -1f));
    stream.write!float(json.getFloat("loopEnd", -1f));
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

private void _compileTtf(string path, Json json, OutStream stream) {
    stream.write!string(json.getString("name"));
    stream.write!string(path ~ Archive.Separator ~ json.getString("file"));
    stream.write!int(json.getInt("size"));
    stream.write!int(json.getInt("outline", 0));
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
