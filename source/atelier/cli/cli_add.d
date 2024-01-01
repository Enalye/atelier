/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.cli.cli_add;

import std.stdio, std.file, std.path;
import std.exception;

import atelier.common;

void cliAdd(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string dirName = baseName(dir);

    string jsonPath = buildNormalizedPath(dir, Atelier_Project_File);
    enforce(exists(jsonPath),
        "aucun projet `" ~ Atelier_Project_File ~ "` trouvable dans `" ~ dir ~ "`");

    Json json = new Json(jsonPath);

    string appName = cli.getRequiredParam(0);
    string srcPath = setExtension(appName, "gr");

    if (cli.hasOption(Atelier_Project_Source_Node)) {
        Cli.Result.Option option = cli.getOption(Atelier_Project_Source_Node);
        srcPath = buildNormalizedPath(option.getRequiredParam(0));
    }

    {
        Json configurationsNode = json.getObject(Atelier_Project_Configurations_Node);
        enforce(configurationsNode.getString(Atelier_Project_Name_Node) != appName,
            "le nom `" ~ appName ~ "` est déjà utilisé");
    }

    {
        Json programNode = new Json;
        programNode.set(Atelier_Project_Name_Node, appName);
        programNode.set(Atelier_Project_Source_Node, srcPath);

        {
            Json windowNode = new Json;
            windowNode.set("enabled", true);
            windowNode.set("width", Atelier_Window_Width_Default);
            windowNode.set("height", Atelier_Window_Height_Default);
            programNode.set("window", windowNode);
        }

        Json[] programNodes = json.getObjects(Atelier_Project_DefaultConfigurationName, []);

        foreach (Json node; programNodes) {
            enforce(node.getString(Atelier_Project_Name_Node) != appName,
                "le nom `" ~ appName ~ "` est déjà utilisé");
        }
        programNodes ~= programNode;
        json.set(Atelier_Project_DefaultConfigurationName, programNodes);
    }

    json.save(jsonPath);

    writeln("Ajout de `" ~ appName ~ "` dans `", dirName, "`");
}
