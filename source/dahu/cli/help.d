/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.cli.help;

import std.stdio : writeln;
import std.conv : to;

enum DH_Version = "v0.0.0";

void displayHelp() {
    string txt = "Dahu version " ~ to!string(DH_Version) ~ "
    Liste des commandes:
    aide > affiche cette aide.
    ";
    writeln(txt);
}

void displayVersion() {
    string txt = "Dahu version " ~ to!string(DH_Version) ~ "";
    writeln(txt);
}
