/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.script;

import grimoire;

import dahu.script.common;
import dahu.script.input;
import dahu.script.render;
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
    GrLibLoader[] loaders;

    static foreach (pack; [
            &getLibLoaders_common, &getLibLoaders_input,
            &getLibLoaders_render, &getLibLoaders_ui,
        ]) {
        loaders ~= pack();
    }

    return loaders;
}
