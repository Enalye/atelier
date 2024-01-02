/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.cli.parser;

import std.stdio;
import std.string;
import std.algorithm;

import atelier.common;
import atelier.cli.cli_add;
import atelier.cli.cli_default;
import atelier.cli.cli_export;
import atelier.cli.cli_init;
import atelier.cli.cli_run;

void parseCli(string[] args) {
    Cli cli = new Cli("atelier");
    cli.setDefault(&cliDefault);
    cli.addOption("v", "version", "Affiche la version du programme");
    cli.addOption("h", "help", "Affiche l’aide", [], ["command"]);
    cli.addCommand(&cliVersion, "version", "Affiche la version du programme");
    cli.addCommand(&cliHelp, "help", "Affiche l’aide", [], ["command"]);

    cli.addCommand(&cliInit, "init", "Crée un projet vide", [], ["directory"]);
    cli.addCommandOption("init", "h", "help", "Affiche l’aide de la commande");
    cli.addCommandOption("init", "a", "app", "Change le nom de l’application", [
            "name"
        ]);
    cli.addCommandOption("init", "s", "source", "Change le chemin du fichier source", [
            "path"
        ]);

    cli.addCommand(&cliAdd, "add", "Ajoute un programme au projet", ["name"]);
    cli.addCommandOption("add", "h", "help", "Affiche l’aide de la commande");
    cli.addCommandOption("add", "s", "source", "Change le chemin du fichier source", [
            "path"
        ]);

    cli.addCommand(&cliRun, "run", "Exécute un programme", [], ["dir"]);
    cli.addCommandOption("run", "h", "help", "Affiche l’aide de la commande");
    cli.addCommandOption("run", "c", "config",
        "Exécute la configuration spécifiée", ["config"]);

    cli.addCommand(&cliExport, "export", "Exporte un projet", [], ["name"]);
    cli.addCommandOption("export", "h", "help", "Affiche l’aide de la commande");
    cli.parse(args);
/*
    if (args.length > 1) {
        args = args[1 .. $];

        switch (args[0]) {
        case "help":
            displayHelp(args[1 .. $]);
            break;
        case "version":
            writeln(Atelier_Version_Display);
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
    }*/
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

    txt = "Usage: atelier" ~ (command.length ? " " ~ command : "") ~ "\n";

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
/*
void runProject() {
    writeln("running app");

    Atelier rt = new Atelier();
    rt.run();
}

void initProject() {
    writeln("initializing app");
}

void buildProject() {
    writeln("building app");
}
*/