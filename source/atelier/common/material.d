module atelier.common.material;

import atelier.common.serializer;

struct MaterialData {
    uint slot;
    float friction = 1f;

    mixin Serializer;
}

struct Material {
    string name;
    float friction = 1f;
}
