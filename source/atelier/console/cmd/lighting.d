module atelier.console.cmd.lighting;

import atelier.common;
import atelier.core;
import atelier.console.system;

package void _lightingCmd(Cli cli) {
    cli.addCommand(&_light, "light", "Éclairage de la scène", ["F:strength"]);

    cli.addCommand(&_darkness, "darkness", "Assombrit la scène");
    cli.addCommand(&_addlight, "addlight", "Ajoute une lumière");
    cli.addCommand(&_removelight, "removelight", "Retire une lumière");
}

private void _light(Cli.Result cli) {
    float value = clamp(cli.getRequiredParamAs!float(0), 0f, 1f);
    Atelier.world.lighting.setBrightness(value);
    Atelier.console.log("Luminosité réglée sur ", value);
}

private void _darkness(Cli.Result cli) {
    Atelier.console.log("Non-implémenté");
}

private void _addlight(Cli.Result cli) {
    Atelier.console.log("Non-implémenté");
}

private void _removelight(Cli.Result cli) {
    Atelier.console.log("Non-implémenté");
}
