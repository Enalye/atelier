/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.core.loader.sprite;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

/// Crée des sprites
package void compileSprite(string path, const Farfadet ffd, OutStream stream) {
    string rid = ffd.get!string(0);

    ffd.accept(["texture", "clip"]);
    string textureRID = ffd.getNode("texture", 1).get!string(0);

    Vec4u clip;
    Farfadet clipNode = ffd.getNode("clip", 4);
    clip.x = clipNode.get!uint(0);
    clip.y = clipNode.get!uint(1);
    clip.z = clipNode.get!uint(2);
    clip.w = clipNode.get!uint(3);

    stream.write!string(rid);
    stream.write!string(textureRID);
    stream.write!Vec4u(clip);
}

package void loadSprite(InStream stream) {
    string rid = stream.read!string();
    string textureRID = stream.read!string();
    Vec4u clip = stream.read!Vec4u();

    Atelier.res.store(rid, {
        Texture texture = Atelier.res.get!Texture(textureRID);
        Sprite sprite = new Sprite(texture, clip);
        return sprite;
    });
}
