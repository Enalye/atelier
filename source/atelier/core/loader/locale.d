module atelier.core.loader.locale;

import farfadet;
import atelier.common;
import atelier.core;
import atelier.locale;

package void compileLocale(string path, const Farfadet ffd, OutStream stream) {
    const string langID = ffd.get!string(0);

    stream.write!string(langID);
    stream.write!size_t(ffd.getNodes().length);

    foreach (node; ffd.getNodes()) {
        stream.write!string(node.name);
        stream.write!string(node.get!string(0));
    }
}

package void loadLocale(InStream stream) {
    const string langID = stream.read!string();
    size_t count = stream.read!size_t();

    Language lang = Atelier.locale.getLanguage(langID);

    for (size_t i; i < count; ++i) {
        string key = stream.read!string();
        string value = stream.read!string();
        lang.store(key, value);
    }
}
