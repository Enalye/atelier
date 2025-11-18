module atelier.common.material;

import atelier.common.serializer;

struct Material {
    string name;
    float friction = 1f;

    mixin Serializer;
}
