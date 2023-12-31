/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.cli.cli_export;

import std.conv : to;
import std.datetime;
import std.exception;
import std.file;
import std.path;
import std.stdio;

import grimoire;
import dahu.common;
import dahu.core;
import dahu.script;

void cliExport(Cli.Result cli) {
    if (cli.hasOption("help")) {
        writeln(cli.getHelp(cli.name));
        return;
    }

    string dahuPath = buildNormalizedPath(dirName(thisExePath()), Dahu_Exe);
    enforce(dahuPath, "impossible de trouver `" ~ dahuPath ~ "`");

    string dir = getcwd();
    string dirBaseName = baseName(dir);

    if (cli.optionalParamCount() >= 1) {
        enforce(isValidPath(cli.getOptionalParam(0)), "chemin non valide");
        dirBaseName = baseName(cli.getOptionalParam(0));
        dir = buildNormalizedPath(dir, cli.getOptionalParam(0));
    }
    enforce(!extension(dirBaseName).length, "le nom du projet ne peut pas être un fichier");

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

            string exportDir = buildNormalizedPath(dir,
                configNode.getString(Dahu_Project_Export_Node));

            if (!exists(exportDir))
                mkdir(exportDir);

            string newDahuPath = buildNormalizedPath(exportDir, setExtension(configName, "exe"));
            std.file.copy(dahuPath, newDahuPath);

            string envPath = buildNormalizedPath(exportDir,
                setExtension(configName, Dahu_Environment_Extension));

            Json[string] resourcesNode = configNode.getObject(Dahu_Project_Resources_Node)
                .getChildren();
            string[] archives;

            ResourceManager res = new ResourceManager;
            setupDefaultResourceLoaders(res);

            foreach (string resName, Json resNode; resourcesNode) {
                string resFolder = buildNormalizedPath(dir, resNode.getString("path", resName));
                enforce(exists(resFolder), "le dossier de ressources `" ~ resFolder ~
                        "` référencé dans `" ~ Dahu_Project_File ~ "` n’existe pas");

                Archive archive = new Archive;
                archive.pack(resFolder);
                if (resNode.getBool("archived", true)) {
                    string resDir = buildNormalizedPath(exportDir,
                        setExtension(resName, Dahu_Archive_Extension));
                    writeln("Archivage de `" ~ resFolder ~ "` vers `", resDir, "`");

                    foreach (file; archive) {
                        if (extension(file.name) == Dahu_Resource_Extension) {
                            OutStream stream = new OutStream;
                            stream.write!string(Dahu_Resource_Compiled_MagicWord);

                            Json resJson = new Json(file.data);
                            Json[] resNodes = resJson.getObjects("resources", []);

                            stream.write!uint(cast(uint) resNodes.length);
                            foreach (resNode; resNodes) {
                                string resType = resNode.getString("type");
                                stream.write!string(resType);

                                ResourceManager.Loader loader = res.getLoader(resType);
                                loader.compile(dirName(file.path), resNode, stream);
                            }

                            file.name = setExtension(file.name, Dahu_Resource_Compiled_Extension);
                            file.data = cast(ubyte[]) stream.data;
                        }
                    }

                    archive.save(resDir);
                    archives ~= setExtension(resName, Dahu_Archive_Extension);
                }
                else {
                    string resDir = buildNormalizedPath(exportDir, resName);
                    writeln("Copie de `" ~ resFolder ~ "` vers `", resDir, "`");
                    archive.unpack(resDir);
                    archives ~= resName;
                }
            }

            Json windowNode = configNode.getObject(Dahu_Project_Window_Node);
            string windowTitle = windowNode.getString(Dahu_Project_Window_Title_Node, configName);
            int windowWidth = windowNode.getInt(Dahu_Project_Window_Width_Node,
                Dahu_Window_Width_Default);
            int windowHeight = windowNode.getInt(Dahu_Project_Window_Height_Node,
                Dahu_Window_Height_Default);
            string windowIcon = windowNode.getString(Dahu_Project_Window_Icon_Node, "");
            bool windowEnabled = windowNode.getBool(Dahu_Project_Window_Enabled_Node,
                Dahu_Window_Enabled_Default);

            if (windowIcon.length) {
                std.file.copy(buildNormalizedPath(dir, windowIcon),
                    buildNormalizedPath(exportDir, windowIcon));
            }

            foreach (fileName; [
                    Dahu_StandardLibrary_Path, "SDL2.dll", "SDL2_image.dll",
                    "SDL2_ttf.dll", "OpenAL32.dll"
                ]) {
                string filePath = buildNormalizedPath(dirName(thisExePath()), fileName);
                enforce(exists(filePath), "fichier manquant `" ~ filePath ~ "`");

                std.file.copy(filePath, buildNormalizedPath(exportDir, fileName));
            }

            string bytecodePath = buildNormalizedPath(exportDir,
                setExtension(configName, Dahu_Bytecode_Extension));

            {
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
            }

            GrLibrary[] libraries = [grLoadStdLibrary(), loadLibrary()];

            GrCompiler compiler = new GrCompiler;
            foreach (library; libraries) {
                compiler.addLibrary(library);
            }

            compiler.addFile(sourceFile);

            int options = GrOption.none;

            if (cli.hasOption("profile")) {
                options |= GrOption.profile;
            }
            if (cli.hasOption("safe")) {
                options |= GrOption.safe;
            }
            if (cli.hasOption("symbols")) {
                options |= GrOption.symbols;
            }
            writeln("compilation de `", sourceFile, "`");

            try {
                long startTime = Clock.currStdTime();
                GrBytecode bytecode = compiler.compile(options, GrLocale.fr_FR);
                enforce(bytecode, compiler.getError().prettify(GrLocale.fr_FR));
                double loadDuration = (cast(double)(Clock.currStdTime() - startTime) / 10_000_000.0);
                writeln("compilation effectuée en ", to!string(loadDuration), "sec");
                bytecode.save(bytecodePath);
                writeln("génération du bytecode `", sourceFile, "`");
            }
            catch (Exception e) {
                writeln(e.msg);
                writeln("compilation échouée");
            }

            return;
        }
    }

    enforce(false, "aucune configuration `" ~ configName ~ "` défini dans `" ~
            Dahu_Project_File ~ "`");
}
