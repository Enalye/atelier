module atelier.common.factory;

import std.typecons;
import std.algorithm : count;
import std.conv : to;
import std.exception : enforce;
import std.traits : isCopyable;

import farfadet;
import atelier.common.stream;

/// Gestionnaire d’objets
final class Factory {
    private {
        void*[string] _caches;
    }

    /// Données d’une ressource
    static struct ObjectData(T) if (is(T == class)) {
        /// Construit le prototype de la ressource
        T delegate() builder;
    }

    /// Cache pour les ressources d’un type donné
    static private final class Cache(T) if (is(T == class)) {
        private {
            ObjectData!(T)[string] _data;
        }

        /// Ajoute le chargeur d’une ressource
        void setBuilder(string name, T delegate() builder) {
            ObjectData!T data;
            data.builder = builder;
            _data[name] = data;
        }

        /// Récupère le prototype d’une ressource
        T build(string name) {
            auto p = (name in _data);
            enforce(p, "la ressource `" ~ name ~ "` n’existe pas");
            return p.builder();
        }

        /// Récupère le prototype d’une ressource
        T tryBuild(string name) {
            auto p = (name in _data);
            return p ? p.builder() : null;
        }

        /// Vérifie la présence d’une ressource
        bool has(string name) {
            auto p = (name in _data);
            return (p !is null);
        }
    }

    /// Init
    this() {
    }

    /// Definit une nouvelle ressource
    void store(T)(string name, T delegate() builder) if (is(T == class)) {
        auto p = T.stringof in _caches;
        Cache!T cache;

        if (p) {
            cache = cast(Cache!T)*p;
        }
        else {
            cache = new Cache!T;
            _caches[T.stringof] = cast(void*) cache;
        }

        cache.setBuilder(name, builder);
    }

    /// Retourne une ressource
    T build(T)(string name) if (is(T == class)) {
        auto p = T.stringof in _caches;
        enforce(p, "la ressource `" ~ name ~ "` n’existe pas");
        return cast(T)(cast(Cache!T)*p).build(name);
    }

    /// Retourne une ressource
    T tryBuild(T)(string name) if (is(T == class)) {
        auto p = T.stringof in _caches;
        return p ? cast(T)(cast(Cache!T)*p).tryBuild(name) : null;
    }

    /// Vérifie la présence d’une ressource
    bool has(T)(string name) if (is(T == class)) {
        auto p = T.stringof in _caches;
        if (!p)
            return false;
        return (cast(Cache!T)*p).has(name);
    }
}
