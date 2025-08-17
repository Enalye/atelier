module atelier.common.conv;

import std.conv : to, ConvException;

T asEnum(T)(string value, T default_) {
    try {
        return to!(T)(value);
    }
    catch (ConvException e) {
        return default_;
    }
}

T asEnum(T)(string value) {
    try {
        return to!(T)(value);
    }
    catch (ConvException e) {
        return T.init;
    }
}

string[] asList(T)() {
    return [__traits(allMembers, T)];
}
