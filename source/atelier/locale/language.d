module atelier.locale.language;

import atelier.core;

final class Language {
    private {
        string _id;
        string[string] _values;
    }

    @property {
        string id() const {
            return _id;
        }
    }

    this(string id_) {
        _id = id_;
    }

    void store(string key, string value) {
        _values[key] = value;
    }

    string get(string key) {
        auto p = key in _values;
        if (p is null) {
            Atelier.log("[ATELIER] La clé `", key, "` n’est pas définie pour la langue `", _id, "`");
            return key;
        }
        return *p;
    }
}
