/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.cli.cli_run;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import grimoire;
import atelier.common;
import atelier.core;
import atelier.script;

void cliRun(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string atelierPath = buildNormalizedPath(dirName(thisExePath()), Atelier_Exe);
    enforce(atelierPath, "impossible de trouver `" ~ atelierPath ~ "`");

    string dir = getcwd();
    string dirName = baseName(dir);

    if (cli.optionalParamCount() >= 1) {
        enforce(isValidPath(cli.getOptionalParam(0)), "chemin non valide");
        dirName = baseName(cli.getOptionalParam(0));
        dir = buildNormalizedPath(dir, cli.getOptionalParam(0));
    }
    enforce(!extension(dirName).length, "le nom du projet ne peut pas être un fichier");

    string projectFile = buildNormalizedPath(dir, Atelier_Project_File);
    enforce(exists(projectFile),
        "aucun fichier de project `" ~ Atelier_Project_File ~
        "` de trouvé à l’emplacement `" ~ dir ~ "`");

    Json json = new Json(projectFile);

    string sourceFile;
    string configName = json.getString(Atelier_Project_DefaultConfiguration_Node, "");

    if (cli.hasOption("config")) {
        configName = cli.getOption("config").getRequiredParam(0);
    }

    Json[] configsNode = json.getObjects(Atelier_Project_Configurations_Node, []);
    foreach (Json configNode; configsNode) {
        if (configNode.getString(Atelier_Project_Name_Node, "") == configName) {
            sourceFile = buildNormalizedPath(dir, configNode.getString(Atelier_Project_Source_Node));

            enforce(exists(sourceFile),
                "le fichier source `" ~ sourceFile ~ "` référencé dans `" ~
                Atelier_Project_File ~ "` n’existe pas");

            Json[string] resourcesNode = configNode.getObject(Atelier_Project_Resources_Node)
                .getChildren();
            string[] archives;

            foreach (string resName, Json resNode; resourcesNode) {
                string resFolder = buildNormalizedPath(dir, resNode.getString("path", resName));
                enforce(exists(resFolder), "le dossier de ressources `" ~ resFolder ~
                        "` référencé dans `" ~ Atelier_Project_File ~ "` n’existe pas");

                archives ~= resFolder;
            }
            writeln(sourceFile, ", ", archives);

            Json windowNode = configNode.getObject(Atelier_Project_Window_Node);
            string windowTitle = windowNode.getString(Atelier_Project_Window_Title_Node, configName);
            int windowWidth = windowNode.getInt(Atelier_Project_Window_Width_Node,
                Atelier_Window_Width_Default);
            int windowHeight = windowNode.getInt(Atelier_Project_Window_Height_Node,
                Atelier_Window_Height_Default);
            string windowIcon = windowNode.getString(Atelier_Project_Window_Icon_Node, "");
            bool windowEnabled = windowNode.getBool(Atelier_Project_Window_Enabled_Node,
                Atelier_Window_Enabled_Default);

            string envPath = buildNormalizedPath(dir, setExtension(configName,
                    Atelier_Environment_Extension));

            GrLibrary[] libraries = [grLoadStdLibrary(), loadLibrary()];

            GrCompiler compiler = new GrCompiler(Atelier_Version_ID);
            foreach (library; libraries) {
                compiler.addLibrary(library);
            }

            compiler.addFile(sourceFile);

            GrBytecode bytecode = compiler.compile(
                GrOption.safe | GrOption.profile | GrOption.symbols, GrLocale.fr_FR);

            enforce(bytecode, compiler.getError().prettify(GrLocale.fr_FR));

            Atelier atelier = new Atelier(bytecode, libraries, windowWidth, windowHeight, windowTitle);

            foreach (string archive; archives) {
                atelier.loadResources(archive);
            }

            if (windowIcon)
                atelier.window.setIcon(windowIcon);

            atelier.run();

            /*if (windowIcon.length) {
                std.file.copy(buildNormalizedPath(dir, windowIcon),
                    buildNormalizedPath(dir, windowIcon));
            }*/

            /*{
                OutStream envStream = new OutStream;
                envStream.write!string(Atelier_Environment_MagicWord);
                envStream.write!size_t(Atelier_Version_ID);
                envStream.write!bool(windowEnabled);

                if (windowEnabled) {
                    envStream.write!string(windowTitle);
                    envStream.write!uint(windowWidth);
                    envStream.write!uint(windowHeight);
                    envStream.write!string(windowIcon);
                }

                envStream.write!size_t(archives.length);
                foreach (string archive; archives) {
                    envStream.write!string(archive);
                }
                std.file.write(envPath, envStream.data);
            }*/

            //string ret = execute([atelierPath, "run", envPath, sourceFile]).output;

            return;
        }
    }

    enforce(false, "aucune configuration `" ~ configName ~ "` défini dans `" ~
            Atelier_Project_File ~ "`");
}
