module atelier.core.loader.animation;

import std.exception : enforce;
import std.format : format;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

/// Crée des Animations
package void compileAnimation(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    string textureRID = ffd.getNode("texture", 1).get!string(0);

    Vec4u clip = ffd.getNode("clip", 4).get!Vec4u(0);

    uint[] frameTimes;
    if (ffd.hasNode("frameTimes")) {
        frameTimes = ffd.getNode("frameTimes", 1).get!(uint[])(0);
    }

    int[] frames;
    if (ffd.hasNode("frames")) {
        frames = ffd.getNode("frames", 1).get!(int[])(0);
    }

    bool repeat;
    if (ffd.hasNode("repeat")) {
        repeat = ffd.getNode("repeat", 1).get!bool(0);
    }

    int repeatIndex;
    if (ffd.hasNode("repeatIndex")) {
        repeatIndex = ffd.getNode("repeatIndex", 1).get!int(0);
    }

    uint columns;
    if (ffd.hasNode("columns")) {
        columns = ffd.getNode("columns", 1).get!int(0);
    }

    uint lines;
    if (ffd.hasNode("lines")) {
        lines = ffd.getNode("lines", 1).get!int(0);
    }

    uint maxCount = columns * lines;
    if (ffd.hasNode("maxCount")) {
        maxCount = ffd.getNode("maxCount", 1).get!int(0);
    }

    Vec2i margin;
    if (ffd.hasNode("margin")) {
        margin = ffd.getNode("margin", 2).get!Vec2i(0);
    }

    int[] flipsX;
    if (ffd.hasNode("flipsX")) {
        flipsX = ffd.getNode("flipsX", 1).get!(int[])(0);
    }

    int[] flipsY;
    if (ffd.hasNode("flipsY")) {
        flipsY = ffd.getNode("flipsY", 1).get!(int[])(0);
    }

    stream.write!string(rid);
    stream.write!string(textureRID);
    stream.write!Vec4u(clip);
    stream.write!(int[])(frames);
    stream.write!(uint[])(frameTimes);
    stream.write!bool(repeat);
    stream.write!int(repeatIndex);
    stream.write!uint(columns);
    stream.write!uint(lines);
    stream.write!uint(maxCount);
    stream.write!Vec2i(margin);
    stream.write!(int[])(flipsX);
    stream.write!(int[])(flipsY);
}

package void loadAnimation(InStream stream) {
    string rid = stream.read!string();
    string textureRID = stream.read!string();
    Vec4u clip = stream.read!Vec4u();
    int[] frames = stream.read!(int[])();
    uint[] frameTimes = stream.read!(uint[])();
    bool repeat = stream.read!bool();
    int repeatIndex = stream.read!int();
    uint columns = stream.read!uint();
    uint lines = stream.read!uint();
    uint maxCount = stream.read!uint();
    Vec2i margin = stream.read!Vec2i();
    int[] flipsX = stream.read!(int[])();
    int[] flipsY = stream.read!(int[])();

    Atelier.res.store(rid, {
        Texture texture = Atelier.res.get!Texture(textureRID);
        Animation animation = new Animation(texture, clip, columns, lines, maxCount);
        animation.margin = margin;
        animation.repeat = repeat;
        animation.repeatIndex = repeatIndex;
        animation.frames = frames;
        animation.frameTimes = frameTimes;
        animation.flipsX = flipsX;
        animation.flipsY = flipsY;
        return animation;
    });
}
