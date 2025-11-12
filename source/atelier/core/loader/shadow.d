module atelier.core.loader.shadow;

import farfadet;
import atelier.common;
import atelier.physics;
import atelier.render;
import atelier.world;
import atelier.core.runtime;
import atelier.core.loader.util;

package void compileShadow(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    stream.write!string(rid);

    ShadowData data;
    data.load(ffd);

    data.serialize(stream);
}

package void loadShadow(InStream stream) {
    const string rid = stream.read!string();

    ShadowData data;
    data.deserialize(stream);

    Atelier.res.store(rid, { return new Shadow(data); });
}
