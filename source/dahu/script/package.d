/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script;

import grimoire;

import dahu.script.input;
import dahu.script.spline;
import dahu.script.ui;

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
    return [&loadLibInput, &loadLibSpline, &loadLibUI];
}
