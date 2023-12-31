module dahu.common.constants;

version (Windows) {
    enum Dahu_Exe = "dahu.exe";
}
version (posix) {
    enum Dahu_Exe = "dahu";
}

enum Dahu_Version_Major = 0;
enum Dahu_Version_Minor = 1;
enum Dahu_Version_Display = "0.1";

/// Identifiant utilisé dans les fichiers devant être validés
enum Dahu_Version_ID = Dahu_Version_Major * 1000 + Dahu_Version_Minor;

enum Dahu_Project_File = "dahu.json";

// dahu.json
enum Dahu_Project_DefaultConfiguration_Node = "defaultConfig";

enum Dahu_Project_Configurations_Node = "configs";

enum Dahu_Project_DefaultConfigurationName = "app";

enum Dahu_Project_Name_Node = "name";

enum Dahu_Project_Source_Node = "source";

enum Dahu_Project_Resources_Node = "resources";

enum Dahu_Project_Export_Node = "export";

enum Dahu_Project_Window_Node = "window";

enum Dahu_Project_Window_Enabled_Node = "enabled";

enum Dahu_Project_Window_Title_Node = "title";

enum Dahu_Project_Window_Width_Node = "width";

enum Dahu_Project_Window_Height_Node = "height";

enum Dahu_Project_Window_Icon_Node = "icon";

// Initialisation fenêtre
enum Dahu_Window_Width_Default = 800;

enum Dahu_Window_Height_Default = 600;

enum Dahu_Window_Enabled_Default = true;

enum Dahu_Window_Icon_Default = Dahu_StandardLibrary_File ~ "/lapis.png";

/// GRB: **GR**imoire **B**ytecode
enum Dahu_Bytecode_Extension = ".grb";

/// ACFG: **A**lchimie **C**on**F**iguration
enum Dahu_Configuration_Extension = ".acf";

/// AME: **A**lchimie **M**achine **E**nvironement
enum Dahu_Environment_Extension = ".dh";

/// ARC: **P**a**Q**ue**T**
enum Dahu_Archive_Extension = ".pqt";

/// ARS: **A**lchimie **R**e**S**source
enum Dahu_Resource_Extension = ".ars";

/// ARSC: **A**lchimie **R**e**S**source **C**ompiled
enum Dahu_Resource_Compiled_Extension = ".arsc";

enum Dahu_StandardLibrary_File = "codex";

enum Dahu_StandardLibrary_Path = Dahu_StandardLibrary_File ~ Dahu_Archive_Extension;

enum Dahu_Environment_MagicWord = "dahu";

enum Dahu_Resource_Compiled_MagicWord = "rscdh";
