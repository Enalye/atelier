module atelier.core.loader.light;

import farfadet;
import atelier.common;
import atelier.physics;
import atelier.render;
import atelier.world;
import atelier.core.runtime;
import atelier.core.loader.util;

package void compileLight(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    stream.write!string(rid);

    BaseLightData data;
    data.load(ffd);

    data.serialize(stream);
}

package void loadLight(InStream stream) {
    const string rid = stream.read!string();

    BaseLightData data;
    data.deserialize(stream);

    Atelier.res.store(rid, { return new BaseLight(data); });
}
