/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script;

import grimoire;

import atelier.script.audio;
import atelier.script.common;
import atelier.script.core;
import atelier.script.input;
import atelier.script.render;
import atelier.script.world;
import atelier.script.ui;

/// Charge la bibliothèque
GrLibrary getEngineLibrary() {
    GrLibrary library = new GrLibrary(0);

    foreach (loader; getLibraryLoaders()) {
        library.addModule(loader);
    }

    return library;
}

/// Retourne les fonctions de chargement de la bibliothèque
private GrModuleLoader[] getLibraryLoaders() {
    GrModuleLoader[] loaders;

    static foreach (pack; [
            &getLibLoaders_audio, &getLibLoaders_common, &getLibLoaders_core,
            &getLibLoaders_input, &getLibLoaders_render,
            &getLibLoaders_world, &getLibLoaders_ui,
        ]) {
        loaders ~= pack();
    }

    return loaders;
}
