/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.cli.cli_run;

import std.stdio, std.file, std.path;
import std.exception;
import std.process;

import grimoire;
import dahu.common;
import dahu.core;
import dahu.script;

void cliRun(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dahuPath = buildNormalizedPath(dirName(thisExePath()), Dahu_Exe);
    enforce(dahuPath, "impossible de trouver `" ~ dahuPath ~ "`");

    string dir = getcwd();
    string dirName = baseName(dir);

    if (cli.optionalParamCount() >= 1) {
        enforce(isValidPath(cli.getOptionalParam(0)), "chemin non valide");
        dirName = baseName(cli.getOptionalParam(0));
        dir = buildNormalizedPath(dir, cli.getOptionalParam(0));
    }
    enforce(!extension(dirName).length, "le nom du projet ne peut pas être un fichier");

    string projectFile = buildNormalizedPath(dir, Dahu_Project_File);
    enforce(exists(projectFile),
        "aucun fichier de project `" ~ Dahu_Project_File ~
        "` de trouvé à l’emplacement `" ~ dir ~ "`");

    Json json = new Json(projectFile);

    string sourceFile;
    string configName = json.getString(Dahu_Project_DefaultConfiguration_Node, "");

    if (cli.hasOption("config")) {
        configName = cli.getOption("config").getRequiredParam(0);
    }

    Json[] configsNode = json.getObjects(Dahu_Project_Configurations_Node, []);
    foreach (Json configNode; configsNode) {
        if (configNode.getString(Dahu_Project_Name_Node, "") == configName) {
            sourceFile = buildNormalizedPath(dir, configNode.getString(Dahu_Project_Source_Node));

            enforce(exists(sourceFile),
                "le fichier source `" ~ sourceFile ~ "` référencé dans `" ~
                Dahu_Project_File ~ "` n’existe pas");

            Json[string] resourcesNode = configNode.getObject(Dahu_Project_Resources_Node)
                .getChildren();
            string[] archives;

            foreach (string resName, Json resNode; resourcesNode) {
                string resFolder = buildNormalizedPath(dir, resNode.getString("path", resName));
                enforce(exists(resFolder), "le dossier de ressources `" ~ resFolder ~
                        "` référencé dans `" ~ Dahu_Project_File ~ "` n’existe pas");

                archives ~= resFolder;
            }
            writeln(sourceFile, ", ", archives);

            Json windowNode = configNode.getObject(Dahu_Project_Window_Node);
            string windowTitle = windowNode.getString(Dahu_Project_Window_Title_Node, configName);
            int windowWidth = windowNode.getInt(Dahu_Project_Window_Width_Node,
                Dahu_Window_Width_Default);
            int windowHeight = windowNode.getInt(Dahu_Project_Window_Height_Node,
                Dahu_Window_Height_Default);
            string windowIcon = windowNode.getString(Dahu_Project_Window_Icon_Node, "");
            bool windowEnabled = windowNode.getBool(Dahu_Project_Window_Enabled_Node,
                Dahu_Window_Enabled_Default);

            string envPath = buildNormalizedPath(dir, setExtension(configName,
                    Dahu_Environment_Extension));

            GrLibrary[] libraries = [grLoadStdLibrary(), loadLibrary()];

            GrCompiler compiler = new GrCompiler;
            foreach (library; libraries) {
                compiler.addLibrary(library);
            }

            compiler.addFile(sourceFile);

            GrBytecode bytecode = compiler.compile(
                GrOption.safe | GrOption.profile | GrOption.symbols, GrLocale.fr_FR);

            enforce(bytecode, compiler.getError().prettify(GrLocale.fr_FR));

            Dahu dahu = new Dahu(bytecode, libraries, windowWidth, windowHeight, windowTitle);

            foreach (string archive; archives) {
                dahu.loadResources(archive);
            }

            if (windowIcon)
                dahu.window.setIcon(windowIcon);

            dahu.run();

            /*if (windowIcon.length) {
                std.file.copy(buildNormalizedPath(dir, windowIcon),
                    buildNormalizedPath(dir, windowIcon));
            }*/

            /*{
                OutStream envStream = new OutStream;
                envStream.write!string(Dahu_Environment_MagicWord);
                envStream.write!size_t(Dahu_Version_ID);
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

            //string ret = execute([dahuPath, "run", envPath, sourceFile]).output;

            return;
        }
    }

    enforce(false, "aucune configuration `" ~ configName ~ "` défini dans `" ~
            Dahu_Project_File ~ "`");
}
