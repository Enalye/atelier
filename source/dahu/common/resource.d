/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.common.resource;

import std.typecons;
import std.algorithm : count;
import std.conv : to;
import std.traits : isCopyable;

import dahu.render;

private {
    void*[string] _caches;
    string[string] _cachesSubFolder;
}

/// Cache pour les ressources d’un type donné
private final class ResourceCache(T) {
    private {
        T[string] _data;
    }

    /// Ajoute le prototype d’une ressource
    void setPrototype(string name, T value) {
        _data[name] = value;
    }

    /// Récupère le prototype d’une ressource
    T getPrototype(string name) {
        auto p = (name in _data);
        assert(p, "Resource: no \'" ~ name ~ "\' loaded");
        return *p;
    }

    /// Récupère le prototype d’une ressource
    T getCopy(string name) {
        auto p = getPrototype(name);
        return new T(p);
    }
}

/// Crée un nouveau cache de ressources
void createResourceCache(T)() {
    static assert(!__traits(isAbstractClass, T),
        "fetch cannot instanciate the abstract class " ~ T.stringof);

    _caches[T.stringof] = cast(void*) new ResourceCache!T;
}

/// Ajoute un prototype dans le cache correspondant
void storePrototype(T)(string name, T prototype) {
    static assert(!__traits(isAbstractClass, T),
        "fetch cannot instanciate the abstract class " ~ T.stringof);

    auto p = T.stringof in _caches;
    ResourceCache!T cache;

    if (p) {
        cache = cast(ResourceCache!T)(*p);
    }
    else {
        cache = new ResourceCache!T;
        _caches[T.stringof] = cast(void*) cache;
    }

    cache.setPrototype(name, prototype);
}

/// Returne le prototype d’une ressource
T fetchPrototype(T)(string name) {
    static assert(!__traits(isAbstractClass, T),
        "fetch cannot instanciate the abstract class " ~ T.stringof);

    auto cache = T.stringof in _caches;
    assert(cache, "No cache declared of type " ~ T.stringof);
    return (cast(ResourceCache!T)*cache).getPrototype(name);
}

/// Returne une copie d’une ressource
T fetch(T)(string name) {
    static assert(!__traits(isAbstractClass, T),
        "fetch cannot instanciate the abstract class " ~ T.stringof);

    auto cache = T.stringof in _caches;
    assert(cache, "No cache declared of type " ~ T.stringof);
    return (cast(ResourceCache!T)*cache).getCopy(name);
}