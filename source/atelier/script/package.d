/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.script;

import grimoire;

import atelier.script.common;
import atelier.script.core;
import atelier.script.input;
import atelier.script.render;
import atelier.script.scene;
import atelier.script.ui;

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
            &getLibLoaders_common, &getLibLoaders_core, &getLibLoaders_input,
            &getLibLoaders_render, &getLibLoaders_scene, &getLibLoaders_ui,
        ]) {
        loaders ~= pack();
    }

    return loaders;
}
