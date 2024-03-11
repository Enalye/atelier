/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module studio.ui.menubar;

import ciel;

final class EditorMenu : MenuBar {
    private {
        //Rectangle _rect;
    }

    this() {
        add("Projet", "Nouveau Projet").addEventListener("click", {
            import std.stdio;writeln("nouvprojet");
        });
        addSeparator("Projet");
        add("Projet", "Lancer");
        add("Projet", "Exporter");
        addSeparator("Projet");
        add("Projet", "Quitter");

        add("Ressource", "Nouveau Fichier");
        addSeparator("Ressource");
        add("Ressource", "Enregistrer");
        add("Ressource", "Enregistrer Sous…");
        addSeparator("Ressource");
        add("Ressource", "Fermer");
    }
}
