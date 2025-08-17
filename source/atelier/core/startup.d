module atelier.core.startup;

import farfadet;
import grimoire;
import std.file;
import std.path;
import atelier.common;
import atelier.core.loader;
import atelier.core.runtime;
import atelier.core.logger;

/*
void startup(string[] args) {
    Cli cli = new Cli("atelier");
    cli.setDefault(&cliDefault);
    cli.addCommand(&cliTest, "test", "");
    //cli.addCommand(&cliScene, "scene", "charge une scène", ["rid"]);
    try {
        cli.parse(args);
    }
    catch (CliException e) {
        Atelier.log("\033[1;91mErreur:\033[0;0m " ~ e.msg);

        if (e.command.length) {
            Atelier.log("\n", cli.getHelp(e.command));
        }
        else {
            Atelier.log("\n", cli.getHelp());
        }
    }
}
*/ /*
Atelier _boot() {
    Atelier atelier = new Atelier(false, Atelier_Window_Width,
        Atelier_Window_Height, Atelier_Window_Title, loader);

    

    atelier.loadResources();

    atelier.window.setIcon(Atelier_Window_Icon);
    return atelier;
}*/
/*
void cliDefault(Cli.Result cli) {
    Atelier atelier = _boot();
    atelier.run();
}

void cliTest(Cli.Result cli) {
    Atelier atelier = _boot();
    atelier.renderer.setPixelSharpness(2);
    Atelier.addStartCommand("loadscene test_niveau");
    atelier.run();
}
*/
