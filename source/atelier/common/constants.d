module atelier.common.constants;

version (Windows) {
    enum Atelier_Exe = "redist.exe";
}
version (posix) {
    enum Atelier_Exe = "redist";
}

enum Atelier_Version_Major = 0;
enum Atelier_Version_Minor = 1;
enum Atelier_Version_Display = "0.1";

/// Identifiant utilisé dans les fichiers devant être validés
enum Atelier_Version_ID = Atelier_Version_Major * 1000 + Atelier_Version_Minor;

enum Atelier_Project_File = "atelier.json";

// atelier.json
enum Atelier_Project_DefaultConfiguration_Node = "defaultConfig";

enum Atelier_Project_Configurations_Node = "configs";

enum Atelier_Project_DefaultConfigurationName = "app";

enum Atelier_Project_Name_Node = "name";

enum Atelier_Project_Source_Node = "source";

enum Atelier_Project_Resources_Node = "resources";

enum Atelier_Project_Export_Node = "export";

enum Atelier_Project_Window_Node = "window";

enum Atelier_Project_Window_Enabled_Node = "enabled";

enum Atelier_Project_Window_Title_Node = "title";

enum Atelier_Project_Window_Width_Node = "width";

enum Atelier_Project_Window_Height_Node = "height";

enum Atelier_Project_Window_Icon_Node = "icon";

// Initialisation fenêtre
enum Atelier_Window_Width_Default = 800;

enum Atelier_Window_Height_Default = 600;

enum Atelier_Window_Enabled_Default = true;

/// GRB: **GR**imoire **B**ytecode
enum Atelier_Bytecode_Extension = ".grb";

/// Fichier de configuration
enum Atelier_Configuration_Extension = ".conf";

/// Fichier de démarrage
enum Atelier_Environment_Extension = ".at";

/// ARC: **P**a**Q**ue**T**
enum Atelier_Archive_Extension = ".pqt";

/// Fichier de ressource farfadet
enum Atelier_Resource_Extension = ".res";

/// Fichier de ressource compilé
enum Atelier_Resource_Compiled_Extension = ".resc";

enum Atelier_Environment_MagicWord = "atelier";

enum Atelier_Resource_Compiled_MagicWord = "resc";

static immutable Atelier_Dependencies = [
    "SDL2.dll", "SDL2_image.dll", "SDL2_ttf.dll"
];
