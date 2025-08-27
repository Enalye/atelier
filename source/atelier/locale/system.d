module atelier.locale.system;

import atelier.common;
import atelier.core;
import atelier.locale.language;

final class Locale {
    private {
        Language[string] _languages;
        Language _current;
    }

    string get(string key) {
        if (!_current) {
            Atelier.log("[ATELIER] Aucune locale de définie");
            return key;
        }
        return _current.get(key);
    }

    Language getLanguage(string id) {
        auto p = id in _languages;
        if (p is null) {
            Language lang = new Language(id);
            if (!_languages.length) {
                _current = lang;
            }
            _languages[id] = lang;
            return lang;
        }
        return *p;
    }

    string[] getLanguageIDs() {
        return _languages.keys;
    }
}
