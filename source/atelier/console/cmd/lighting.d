module atelier.console.cmd.lighting;

import atelier.common;
import atelier.core;
import atelier.console.system;
import atelier.console.command;

package void _lightingCmd(Console console) {
    // light <F:strength>
    ConsoleCommand light = console.addCommand("light");
    light.addParameter("strength", ConsoleType.float_);
    light.setHint("Éclairage de la scène");
    light.setCallback(&_light);

    //cli.addCommand(&_darkness, "darkness", "Assombrit la scène");
    //cli.addCommand(&_addlight, "addlight", "Ajoute une lumière");
    //cli.addCommand(&_removelight, "removelight", "Retire une lumière");
}

private void _light(ConsoleCall call) {
    float value = clamp(call.getArgument!float("strength"), 0f, 1f);
    Atelier.world.lighting.setBrightness(value);
    call.console.log("Luminosité réglée sur ", value);
}
/*
private void _darkness(Cli.Result cli) {
    call.console.log("Non-implémenté");
}

private void _addlight(Cli.Result cli) {
    call.console.log("Non-implémenté");
}

private void _removelight(Cli.Result cli) {
    call.console.log("Non-implémenté");
}
*/
