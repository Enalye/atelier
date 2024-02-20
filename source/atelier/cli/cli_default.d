/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.cli.cli_default;

import std.stdio;

import atelier.common;
import atelier.core;

void cliDefault(Cli.Result cli) {
    if (cli.hasOption("version")) {
        log("Atelier version " ~ Atelier_Version_Display);
    }
    else if (cli.hasOption("help")) {
        if (cli.optionalParamCount() >= 1)
            log(cli.getHelp(cli.getOptionalParam(0)));
        else
            log(cli.getHelp());
    }
}

void cliVersion(Cli.Result cli) {
    log("Atelier version " ~ Atelier_Version_Display);
}

void cliHelp(Cli.Result cli) {
    if (cli.optionalParamCount() >= 1)
        log(cli.getHelp(cli.getOptionalParam(0)));
    else
        log(cli.getHelp());
}
