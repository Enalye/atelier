module atelier.common.constants;

version (Windows) {
    enum Atelier_Exe = "redist.exe";
    enum Atelier_Library = "atelier.dll";
}
version (posix) {
    enum Atelier_Exe = "redist";
    enum Atelier_Library = "atelier.so";
}

enum Atelier_Version_Major = 0;
enum Atelier_Version_Minor = 1;
enum Atelier_Version_Display = "0.1";

/// Identifiant utilisé dans les fichiers devant être validés
enum Atelier_Version_ID = Atelier_Version_Major * 1000 + Atelier_Version_Minor;

enum Atelier_Project_File = "atelier.ffd";

// Initialisation fenêtre
enum Atelier_Window_Width = 640;

enum Atelier_Window_Height = 360;

enum Atelier_Window_Title = "Atelier";

enum Atelier_Window_Icon = "icon.png";

enum Atelier_Window_Enabled_Default = true;

enum Atelier_Media_Dir = "media";

/// Fichier de configuration
enum Atelier_Configuration_Extension = ".acf";

/// Fichier de configuration
enum Atelier_Configuration = "atelier.ffd";

/// Fichier d’application
enum Atelier_Application_Extension = ".atl";

/// Fichier de données
enum Atelier_Archive_Extension = ".pqt";

/// Fichier de ressource farfadet
enum Atelier_Resource_Extension = ".ffd";

/// Fichier de ressource compilé
enum Atelier_Resource_Compiled_Extension = ".ffdt";

/// Fichier de script grimoire
enum Atelier_Script_Extension = ".gr";

/// Fichier de bytecode grimoire
enum Atelier_Bytecode_Extension = ".grb";

enum Atelier_Environment_MagicWord = "atelier";

enum Atelier_Resource_Compiled_MagicWord = "farfadet";

static immutable Atelier_Dependencies = [
    "SDL2.dll", "SDL2_image.dll", "SDL2_ttf.dll"
];
