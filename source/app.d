/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
import atelier.cli;

void main(string[] args) {
    version (AtelierDev) {
        args = args[0] ~ ["run", "test"];
    }

    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }

    try {
        parseCli(args);
    }
    catch (Exception e) {
        import std.stdio;

        writeln("Erreur: ", e.msg);
        foreach (trace; e.info) {
            writeln("at: ", trace);
        }
    }
}
