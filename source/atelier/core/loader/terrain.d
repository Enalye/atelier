module atelier.core.loader.terrain;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.core.runtime;

package void compileTerrain(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    //TerrainMap terrain = new TerrainMap(ffd);
    stream.write!string(rid);
    //terrain.serialize(stream);
}

package void loadTerrain(InStream stream) {
    const string rid = stream.read!string();
    //TerrainMap terrain = new TerrainMap;
    //terrain.deserialize(stream);
    //Atelier.res.store(rid, { return terrain; });
}
