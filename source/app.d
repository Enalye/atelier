/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
import dahu.cli;

void main(string[] args) {
    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }

    try {
        parseCommand(args);
    }
    catch (Exception e) {
        import std.stdio;

        writeln("Erreur: ", e.msg);
        foreach (trace; e.info) {
            writeln("at: ", trace);
        }
    }
}
