module atelier.common.serializer;

import farfadet;

mixin template Serializer() {
    void load(const(Farfadet) ffd) {
        static foreach (member; __traits(allMembers, typeof(this))) {
            static if (isFarfadetCompatible!(typeof(__traits(getMember, typeof(this), member)))) {
                mixin("if (ffd.hasNode(\"", member, "\")) {",
                    member, " = ffd.getNode(\"", member, "\").get!(",
                    typeof(__traits(getMember, typeof(this), member)),
                    ")(0);
                }");
            }
        }
    }

    void save(Farfadet ffd) const {
        static foreach (member; __traits(allMembers, typeof(this))) {
            static if (isFarfadetCompatible!(typeof(__traits(getMember, typeof(this), member)))) {
                mixin("ffd.addNode(\"", member, "\").add!(",
                    typeof(__traits(getMember, typeof(this), member)),
                    ")(", member, ");");
                //static if (member == "repeat") {
                //    static assert(typeof(__traits(getMember, typeof(this), member)).stringof == "const(bool)");
                //}
            }
        }
    }

    void serialize(OutStream stream) const {
        static foreach (member; __traits(allMembers, typeof(this))) {
            static if (isFarfadetCompatible!(typeof(__traits(getMember, typeof(this), member)))) {
                mixin("stream.write!(", typeof(__traits(getMember, typeof(this), member)), ")(", member, ");");
            }
        }
    }

    void deserialize(InStream stream) {
        static foreach (member; __traits(allMembers, typeof(this))) {
            static if (isFarfadetCompatible!(typeof(__traits(getMember, typeof(this), member)))) {
                mixin(member, " = stream.read!(", typeof(__traits(getMember, typeof(this), member)), ");");
            }
        }
    }
}
