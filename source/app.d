/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */

import std.stdio;
import std.exception;
import std.string;

import dahu.cli;

void main(string[] args) {
    writeln("yo");
    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }
    
    parseCommand(args);
}
