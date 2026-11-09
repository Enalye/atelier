module atelier.common.serializer;

mixin template Serializer() {
    import farfadet;
    import atelier.common.stream : InStream, OutStream;

    void load(const(Farfadet) ffd) {
        static foreach (member; __traits(allMembers, typeof(this))) {
            static if (isFarfadetCompatible!(typeof(__traits(getMember, typeof(this), member)))) {
                static if (is(Unqual!(typeof(__traits(getMember, typeof(this), member))) == U[], U) &&
                    is(U == struct)) {
                    mixin("foreach (node; ffd.getNodes(\"", member, "\")) {
                        ", U, " element;
                        element.load(node);
                        member ~= element;
                    }");
                }
                else static if (isFarfadetValueType!(typeof(__traits(getMember, typeof(this), member))) ||
                    is(typeof(__traits(getMember, typeof(this), member)) == struct)) {
                    mixin("if (ffd.hasNode(\"", member, "\")) {",
                        member, " = ffd.getNode(\"", member, "\").get!(",
                        typeof(__traits(getMember, typeof(this), member)),
                        ")(0);
                    }");
                }
            }
        }
    }

    void save(Farfadet ffd) const {
        static foreach (member; __traits(allMembers, typeof(this))) {
            static if (isFarfadetCompatible!(typeof(__traits(getMember, typeof(this), member)))) {
                static if (is(Unqual!(typeof(__traits(getMember, typeof(this), member))) == U[], U) &&
                    is(U == struct)) {
                    foreach (element; member) {
                        mixin(element, ".save(ffd.addNode(\"", member, "\"));");
                    }
                }
                else static if (isFarfadetValueType!(typeof(__traits(getMember, typeof(this), member))) ||
                    is(typeof(__traits(getMember, typeof(this), member)) == struct)) {
                    mixin("ffd.addNode(\"", member, "\").add!(",
                        typeof(__traits(getMember, typeof(this), member)),
                        ")(", member, ");");
                }
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
