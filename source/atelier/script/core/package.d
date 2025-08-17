module atelier.script.core;

import grimoire;

import atelier.script.core.runtime;
import atelier.script.core.theme;

package(atelier.script) GrModuleLoader[] getLibLoaders_core() {
    return [
        &loadLibCore_runtime,
        &loadLibCore_theme
    ];
}