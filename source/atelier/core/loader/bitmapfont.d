module atelier.core.loader.bitmapfont;

import std.exception : enforce;
import std.format : format;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

package struct Metrics {
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

package void compileBitmapFont(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept(["texture", "size", "ascent", "descent"]);

    string textureRID = ffd.getNode("texture", 1).get!string(0);
    int size = ffd.getNode("size", 1).get!int(0);
    int ascent = ffd.getNode("ascent", 1).get!int(0);
    int descent = ffd.getNode("descent", 1).get!int(0);

    Metrics[] metricsList;
    foreach (node; ffd.getNodes("char", 1)) {
        node.accept(["advance", "offset", "size", "pos", "kerning"]);

        Metrics metrics;
        metrics.ch = node.get!dchar(0);
        metrics.advance = ffd.getNode("advance", 1).get!int(0);

        Farfadet offsetNode = node.getNode("offset", 2);
        metrics.offsetX = offsetNode.get!int(0);
        metrics.offsetY = offsetNode.get!int(1);

        Farfadet sizeNode = node.getNode("size", 2);
        metrics.width = sizeNode.get!int(0);
        metrics.height = sizeNode.get!int(1);

        Farfadet posNode = node.getNode("pos", 2);
        metrics.posX = posNode.get!int(0);
        metrics.posY = posNode.get!int(1);

        foreach (charNode; node.getNodes("kerning", 2)) {
            metrics.kerningChar ~= node.get!dchar(0);
            metrics.kerningOffset ~= node.get!int(1);
            metricsList ~= metrics;
        }
    }

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

package void loadBitmapFont(InStream stream) {
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
