module atelier.core.loader.ninepatch;

import std.exception : enforce;
import std.format : format;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

/// Crée des Ninepatch
package void compileNinepatch(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    string textureRID = ffd.getNode("texture", 1).get!string(0);

    Vec4u clip;
    {
        Farfadet clipNode = ffd.getNode("clip", 4);
        clip.x = clipNode.get!uint(0);
        clip.y = clipNode.get!uint(1);
        clip.z = clipNode.get!uint(2);
        clip.w = clipNode.get!uint(3);
    }

    int top;
    if (ffd.hasNode("top")) {
        top = ffd.getNode("top", 1).get!int(0);
    }

    int bottom;
    if (ffd.hasNode("bottom")) {
        bottom = ffd.getNode("bottom", 1).get!int(0);
    }

    int left;
    if (ffd.hasNode("left")) {
        left = ffd.getNode("left", 1).get!int(0);
    }

    int right;
    if (ffd.hasNode("right")) {
        right = ffd.getNode("right", 1).get!int(0);
    }

    stream.write!string(rid);
    stream.write!string(textureRID);
    stream.write!Vec4u(clip);
    stream.write!int(top);
    stream.write!int(bottom);
    stream.write!int(left);
    stream.write!int(right);
}

package void loadNinepatch(InStream stream) {
    string rid = stream.read!string();
    string textureRID = stream.read!string();
    Vec4u clip = stream.read!Vec4u();
    int top = stream.read!int();
    int bottom = stream.read!int();
    int left = stream.read!int();
    int right = stream.read!int();

    Atelier.res.store(rid, {
        Texture texture = Atelier.res.get!Texture(textureRID);
        NinePatch ninePatch = new NinePatch(texture, clip, top, bottom, left, right);
        return ninePatch;
    });
}
