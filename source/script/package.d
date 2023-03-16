/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script;

import grimoire;

/// Charge la bibliothèque
GrLibrary loadLibrary() {
    GrLibrary library = new GrLibrary;

    foreach (loader; getLibraryLoaders()) {
        loader(library);
    }

    return library;
}

/// Retourne les fonctions de chargement de la bibliothèque
GrLibLoader[] getLibraryLoaders() {
    return [
    ];
}
