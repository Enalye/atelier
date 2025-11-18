module atelier.core.loader.material;

import farfadet;
import atelier.common;
import atelier.physics;
import atelier.render;
import atelier.world;
import atelier.core.runtime;
import atelier.core.loader.util;

package void compileMaterial(string path, const Farfadet ffd, OutStream stream) {
    const uint id = ffd.get!uint(0);
    stream.write!uint(id);

    Material material;
    material.load(ffd);

    material.serialize(stream);
}

package void loadMaterial(InStream stream) {
    const uint id = stream.read!uint();

    Material material;
    material.deserialize(stream);

    Atelier.world.setMaterial(id, material);
}
