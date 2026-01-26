module atelier.console.cmd.world;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.console.system;

package void _worldCmd(Cli cli) {
    cli.addCommand(&_setscene, "setscene", "Change le niveau", ["S:rid"]);
    cli.addCommand(&_wf, "wf", "Test filigrane");
}

private void _setscene(Cli.Result cli) {
    string rid = cli.getRequiredParamAs!string(0);
    if (Atelier.res.has!Scene(rid)) {
        Atelier.console.log("Chargement du niveau `", rid, "`");
        Atelier.world.load(rid);
    }
    else {
        Atelier.console.log("Le niveau `", rid, "` n’existe pas");
    }
}

private void _wf(Cli.Result cli) {
    //Atelier.world.runScene("test_niveau", "east");
}
