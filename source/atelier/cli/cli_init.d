/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.cli.cli_init;

import std.stdio, std.file, std.path;
import std.exception;

import farfadet;
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
*.atl
*.exe
*.dll
*.so
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

    if (cli.hasOption("source")) {
        Cli.Result.Option option = cli.getOption("source");
        srcPath = buildNormalizedPath(option.getRequiredParam(0));
    }

    Farfadet ffd = new Farfadet;

    { // Programme par défaut
        Farfadet default_ = ffd.addNode("default");
        default_.add(appName);
    }

    {
        Farfadet configNode = ffd.addNode("config").add(appName);
        configNode.addNode("source").add(srcPath);
        configNode.addNode("export").add("export");

        Farfadet resNode = configNode.addNode("resource").add("res");
        resNode.addNode("path").add("res");
        resNode.addNode("archived").add(true);

        Farfadet windowNode = configNode.addNode("window");
        windowNode.addNode("size").add(Atelier_Window_Width_Default)
            .add(Atelier_Window_Height_Default);
    }

    ffd.save(buildNormalizedPath(dir, Atelier_Project_File));

    foreach (subDir; ["res", "src", "export"]) {
        string resDir = buildNormalizedPath(dir, subDir);
        if (!exists(resDir))
            mkdir(resDir);
    }

    std.file.write(buildNormalizedPath(dir, ".gitignore"), Default_GitIgnoreContent);
    std.file.write(buildNormalizedPath(dir, srcPath), Default_SourceFileContent);

    log("Projet `", dirName, "` créé");
}
