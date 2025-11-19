module atelier.core.loader.material;

import farfadet;
import atelier.common;
import atelier.physics;
import atelier.render;
import atelier.world;
import atelier.core.runtime;
import atelier.core.loader.util;

package void compileMaterial(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    stream.write!string(rid);

    MaterialData material;
    material.load(ffd);

    material.serialize(stream);
}

package void loadMaterial(InStream stream) {
    const string rid = stream.read!string();

    MaterialData material;
    material.deserialize(stream);

    Atelier.world.addMaterial(rid, material);
}
