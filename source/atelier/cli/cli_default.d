/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.cli.cli_default;

import std.stdio;

import atelier.common;

void cliDefault(Cli.Result cli) {
    if (cli.hasOption("version")) {
        writeln("Atelier version " ~ Atelier_Version_Display);
    } else if (cli.hasOption("help")) {
        if (cli.optionalParamCount() >= 1)
            writeln(cli.getHelp(cli.getOptionalParam(0)));
        else
            writeln(cli.getHelp());
    }
}

void cliVersion(Cli.Result cli) {
    writeln("Atelier version " ~ Atelier_Version_Display);
}

void cliHelp(Cli.Result cli) {
    if (cli.optionalParamCount() >= 1)
        writeln(cli.getHelp(cli.getOptionalParam(0)));
    else
        writeln(cli.getHelp());
}
