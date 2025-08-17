module atelier.core.loader.scene;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.world;
import atelier.core.runtime;

package void compileScene(string path, const Farfadet ffd, OutStream stream) {
    const string rid = ffd.get!string(0);
    Scene scene = new Scene;
    scene.load(ffd);
    stream.write!string(rid);
    scene.serialize(stream);
}

package void loadScene(InStream stream) {
    const string rid = stream.read!string();
    Scene scene = new Scene;
    scene.deserialize(stream);
    Atelier.res.store(rid, { scene.setup(); return scene; });
}
