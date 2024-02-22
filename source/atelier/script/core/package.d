/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.core;

import grimoire;

import atelier.script.core.runtime;

package(atelier.script) GrLibLoader[] getLibLoaders_core() {
    return [
        &loadLibCore_runtime
    ];
}