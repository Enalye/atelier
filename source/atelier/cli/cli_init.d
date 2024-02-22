/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.cli.cli_init;

import std.stdio, std.file, std.path;
import std.exception;

import atelier.common;
import atelier.core;

private enum Default_SourceFileContent = `
event app {
    // Début du programme
    print("Bonjour le monde !");
}
`;

private enum Default_GitIgnoreContent = `
# Dossiers
export/

# Fichiers
*.pqt
*.grb
*.dh
`;

void cliInit(Cli.Result cli) {
    if (cli.hasOption("help")) {
        log(cli.getHelp(cli.name));
        return;
    }

    string dir = getcwd();
    string dirName = baseName(dir);

    if (cli.optionalParamCount() == 1) {
        enforce(isValidPath(cli.getOptionalParam(0)), "chemin non valide");
        dirName = baseName(cli.getOptionalParam(0));
        dir = buildNormalizedPath(dir, cli.getOptionalParam(0));

        if (!exists(dir))
            mkdir(dir);
    }
    enforce(!extension(dirName).length, "le nom du projet ne peut pas être un fichier");

    string appName = dirName;
    string srcPath = setExtension("app", "gr");

    if (cli.hasOption("app")) {
        Cli.Result.Option option = cli.getOption("app");
        appName = option.getRequiredParam(0);
    }

    if (cli.hasOption(Atelier_Project_Source_Node)) {
        Cli.Result.Option option = cli.getOption(Atelier_Project_Source_Node);
        srcPath = buildNormalizedPath(option.getRequiredParam(0));
    }

    Json json = new Json;
    json.set(Atelier_Project_DefaultConfiguration_Node, appName);

    {
        Json appNode = new Json;
        appNode.set(Atelier_Project_Name_Node, appName);
        appNode.set(Atelier_Project_Source_Node, srcPath);
        appNode.set(Atelier_Project_Export_Node, "export");

        {
            Json resNode = new Json;
            resNode.set("path", "res");
            resNode.set("archived", true);
            resNode.set("salt", "");

            Json resourcesNode = new Json;
            resourcesNode.set("res", resNode);
            appNode.set(Atelier_Project_Resources_Node, resourcesNode);
        }

        {
            Json windowNode = new Json;
            windowNode.set("enabled", true);
            windowNode.set("width", Atelier_Window_Width_Default);
            windowNode.set("height", Atelier_Window_Height_Default);
            appNode.set("window", windowNode);
        }

        json.set(Atelier_Project_Configurations_Node, [appNode]);
    }

    json.save(buildNormalizedPath(dir, Atelier_Project_File));

    foreach (subDir; ["res", "src", "export"]) {
        string resDir = buildNormalizedPath(dir, subDir);
        if (!exists(resDir))
            mkdir(resDir);
    }

    std.file.write(buildNormalizedPath(dir, ".gitignore"), Default_GitIgnoreContent);
    std.file.write(buildNormalizedPath(dir, srcPath), Default_SourceFileContent);

    log("Projet `", dirName, "` créé");
}
