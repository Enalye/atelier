/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.cli.cli_default;

import std.stdio;

import dahu.common;

enum DH_Version = "0.1";

void cliDefault(Cli.Result cli) {
    if (cli.hasOption("version")) {
        writeln("Dahu version " ~ DH_Version);
    } else if (cli.hasOption("help")) {
        if (cli.optionalParamCount() >= 1)
            writeln(cli.getHelp(cli.getOptionalParam(0)));
        else
            writeln(cli.getHelp());
    }
}

void cliVersion(Cli.Result cli) {
    writeln("Dahu version " ~ DH_Version);
}

void cliHelp(Cli.Result cli) {
    if (cli.optionalParamCount() >= 1)
        writeln(cli.getHelp(cli.getOptionalParam(0)));
    else
        writeln(cli.getHelp());
}
