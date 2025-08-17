module atelier.core.loader.multidiranimation;

import std.exception : enforce;
import std.format : format;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

/// Crée des Animations
package void compileMultiDirAnimation(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    string textureRID = ffd.getNode("texture", 1).get!string(0);

    Vec4u clip = ffd.getNode("clip", 4).get!Vec4u(0);

    uint frameTime;
    if (ffd.hasNode("frameTime")) {
        frameTime = ffd.getNode("frameTime", 1).get!uint(0);
    }

    int[] frames;
    if (ffd.hasNode("frames")) {
        frames = ffd.getNode("frames", 1).get!(int[])(0);
    }

    bool repeat;
    if (ffd.hasNode("repeat")) {
        repeat = ffd.getNode("repeat", 1).get!bool(0);
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

    float dirStartAngle = 90f;
    if (ffd.hasNode("dirStartAngle")) {
        dirStartAngle = ffd.getNode("dirStartAngle", 1).get!float(0);
    }

    Vec2i dirOffset;
    if (ffd.hasNode("dirOffset")) {
        dirOffset = ffd.getNode("dirOffset", 2).get!Vec2i(0);
    }

    int[] dirIndexes;
    if (ffd.hasNode("dirIndexes")) {
        dirIndexes = ffd.getNode("dirIndexes", 1).get!(int[])(0);
    }

    int[] dirFlipXs;
    if (ffd.hasNode("dirFlipXs")) {
        dirFlipXs = ffd.getNode("dirFlipXs", 1).get!(int[])(0);
    }

    stream.write!string(rid);
    stream.write!string(textureRID);
    stream.write!Vec4u(clip);
    stream.write!(int[])(frames);
    stream.write!uint(frameTime);
    stream.write!bool(repeat);
    stream.write!uint(columns);
    stream.write!uint(lines);
    stream.write!uint(maxCount);
    stream.write!Vec2i(margin);
    stream.write!float(dirStartAngle);
    stream.write!Vec2i(dirOffset);
    stream.write!(int[])(dirIndexes);
    stream.write!(int[])(dirFlipXs);
}

package void loadMultiDirAnimation(InStream stream) {
    string rid = stream.read!string();
    string textureRID = stream.read!string();
    Vec4u clip = stream.read!Vec4u();
    int[] frames = stream.read!(int[])();
    uint frameTime = stream.read!uint();
    bool repeat = stream.read!bool();
    uint columns = stream.read!uint();
    uint lines = stream.read!uint();
    uint maxCount = stream.read!uint();
    Vec2i margin = stream.read!Vec2i();
    float dirStartAngle = stream.read!float();
    Vec2i dirOffset = stream.read!Vec2i();
    int[] dirIndexes = stream.read!(int[])();
    int[] dirFlipXs = stream.read!(int[])();

    Atelier.res.store(rid, {
        Texture texture = Atelier.res.get!Texture(textureRID);
        MultiDirAnimation animation = new MultiDirAnimation(texture, clip,
            columns, lines, maxCount);
        animation.margin = margin;
        animation.repeat = repeat;
        animation.frames = frames;
        animation.frameTime = frameTime;
        animation.dirStartAngle = dirStartAngle;
        animation.dirOffset = dirOffset;
        animation.dirIndexes = dirIndexes;
        animation.dirFlipXs = dirFlipXs;
        return animation;
    });
}
