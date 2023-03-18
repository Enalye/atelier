/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module cli;

import std.stdio;
import std.string;
import std.algorithm;

import runtime;

enum DH_VERSION = "v0.0.0";

void parseCommand(string[] args) {
    if (args.length > 1) {
        args = args[1 .. $];

        switch (args[0]) {
        case "help":
            displayHelp(args[1 .. $]);
            break;
        case "version":
            writeln(DH_VERSION);
            break;
        case "init":
            initProject();
            break;
        case "run":
            runProject();
            break;
        case "build":
            buildProject();
            break;
        default:
            displayHelp();
            writeln("Unknown command `", args[0], "`.");
            break;
        }
    }
    else {
        runProject();
    }
}

void displayHelp(string[] args = []) {
    string command;
    string txt;
    string[] commands;
    string[] commandsDescription;

    if (args.length)
        command = args[0];

    switch (command) {
    case "init":
        txt = "init [<directory>]";
        break;
    case "run":
        txt = "run [<directory>]";
        break;
    case "build":
        txt = "build [<directory>]";
        break;
    default:
        commands = [
            "init [<directory>]", "run [<directory>]", "build [<directory>]"
        ];
        commandsDescription = [
            "creates a new project", "executes a project", "exports a project"
        ];
        break;
    }

    txt = "Usage: dahu" ~ (command.length ? " " ~ command : "") ~ "\n";

    assert(commands.length == commandsDescription.length, "command list mismatch");

    size_t offset;

    if (commands.length) {
        foreach (string cmd; commands) {
            offset = max(offset, cmd.length + 4);
        }
    }

    if (commands.length) {
        txt ~= "\nCommands:\n";

        for (size_t i; i < commands.length; ++i) {
            string cmdLine = "  " ~ commands[i];
            cmdLine = leftJustify(cmdLine, offset);
            cmdLine ~= commandsDescription[i] ~ "\n";
            txt ~= cmdLine;
        }
    }

    writeln(txt);
}

void runProject() {
    writeln("running app");

    Runtime rt = new Runtime();
    rt.run();
}

void initProject() {
    writeln("initializing app");
}

void buildProject() {
    writeln("building app");
}
