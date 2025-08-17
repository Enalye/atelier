module atelier.script.input;

import grimoire;

import atelier.script.input.event;
import atelier.script.input.input;

package(atelier.script) GrModuleLoader[] getLibLoaders_input() {
    return [
        &loadLibInput_event,
        &loadLibInput_input
    ];
}
