/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.cli.cli_add;

import std.stdio, std.file, std.path;
import std.exception;

import dahu.common;

void cliAdd(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string dirName = baseName(dir);

    string jsonPath = buildNormalizedPath(dir, Dahu_Project_File);
    enforce(exists(jsonPath),
        "aucun projet `" ~ Dahu_Project_File ~ "` trouvable dans `" ~ dir ~ "`");

    Json json = new Json(jsonPath);

    string appName = cli.getRequiredParam(0);
    string srcPath = setExtension(appName, "gr");

    if (cli.hasOption(Dahu_Project_Source_Node)) {
        Cli.Result.Option option = cli.getOption(Dahu_Project_Source_Node);
        srcPath = buildNormalizedPath(option.getRequiredParam(0));
    }

    {
        Json configurationsNode = json.getObject(Dahu_Project_Configurations_Node);
        enforce(configurationsNode.getString(Dahu_Project_Name_Node) != appName,
            "le nom `" ~ appName ~ "` est déjà utilisé");
    }

    {
        Json programNode = new Json;
        programNode.set(Dahu_Project_Name_Node, appName);
        programNode.set(Dahu_Project_Source_Node, srcPath);

        {
            Json windowNode = new Json;
            windowNode.set("enabled", true);
            windowNode.set("width", Dahu_Window_Width_Default);
            windowNode.set("height", Dahu_Window_Height_Default);
            programNode.set("window", windowNode);
        }

        Json[] programNodes = json.getObjects(Dahu_Project_DefaultConfigurationName, []);

        foreach (Json node; programNodes) {
            enforce(node.getString(Dahu_Project_Name_Node) != appName,
                "le nom `" ~ appName ~ "` est déjà utilisé");
        }
        programNodes ~= programNode;
        json.set(Dahu_Project_DefaultConfigurationName, programNodes);
    }

    json.save(jsonPath);

    writeln("Ajout de `" ~ appName ~ "` dans `", dirName, "`");
}
