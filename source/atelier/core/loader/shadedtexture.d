module atelier.core.loader.shadedtexture;

import std.conv : to;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

/// Crée des textures
package void compileShadedTexture(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    string filePath = ffd.getNode("file", 1).get!string(0);

    Color sourceColorA = Color.white;
    Color sourceColorB = Color.black;
    Color targetColorA = Color.white;
    Color targetColorB = Color.white;

    float sourceAlphaA = 1f;
    float sourceAlphaB = 1f;
    float targetAlphaA = 1f;
    float targetAlphaB = 0f;

    string spline = to!string(Spline.linear);

    if (ffd.hasNode("sourceColorA")) {
        sourceColorA = ffd.getNode("sourceColorA").get!Color(0);
    }

    if (ffd.hasNode("sourceColorB")) {
        sourceColorB = ffd.getNode("sourceColorB").get!Color(0);
    }

    if (ffd.hasNode("targetColorA")) {
        targetColorA = ffd.getNode("targetColorA").get!Color(0);
    }

    if (ffd.hasNode("targetColorB")) {
        targetColorB = ffd.getNode("targetColorB").get!Color(0);
    }

    if (ffd.hasNode("sourceAlphaA")) {
        sourceAlphaA = ffd.getNode("sourceAlphaA").get!float(0);
    }

    if (ffd.hasNode("sourceAlphaB")) {
        sourceAlphaB = ffd.getNode("sourceAlphaB").get!float(0);
    }

    if (ffd.hasNode("targetAlphaA")) {
        targetAlphaA = ffd.getNode("targetAlphaA").get!float(0);
    }

    if (ffd.hasNode("targetAlphaB")) {
        targetAlphaB = ffd.getNode("targetAlphaB").get!float(0);
    }

    if (ffd.hasNode("spline")) {
        spline = ffd.getNode("spline").get!string(0);
    }

    stream.write!string(rid);
    stream.write!string(path ~ filePath);
    stream.write!Color(sourceColorA);
    stream.write!Color(sourceColorB);
    stream.write!Color(targetColorA);
    stream.write!Color(targetColorB);
    stream.write!float(sourceAlphaA);
    stream.write!float(sourceAlphaB);
    stream.write!float(targetAlphaA);
    stream.write!float(targetAlphaB);
    stream.write!string(spline);
}

package void loadShadedTexture(InStream stream) {
    string rid = stream.read!string();
    string filePath = stream.read!string();

    Color sourceColorA = stream.read!Color();
    Color sourceColorB = stream.read!Color();
    Color targetColorA = stream.read!Color();
    Color targetColorB = stream.read!Color();
    float sourceAlphaA = stream.read!float();
    float sourceAlphaB = stream.read!float();
    float targetAlphaA = stream.read!float();
    float targetAlphaB = stream.read!float();
    Spline spline;

    try {
        spline = to!Spline(stream.read!string());
    }
    catch (Exception e) {
        spline = Spline.linear;
    }

    Atelier.res.store(rid, {
        ShadedTexture texture = ShadedTexture.fromResource(filePath);
        texture.sourceColorA = sourceColorA;
        texture.sourceColorB = sourceColorB;
        texture.targetColorA = targetColorA;
        texture.targetColorB = targetColorB;
        texture.sourceAlphaA = sourceAlphaA;
        texture.sourceAlphaB = sourceAlphaB;
        texture.targetAlphaA = targetAlphaA;
        texture.targetAlphaB = targetAlphaB;
        texture.spline = spline;
        return texture;
    });
}
