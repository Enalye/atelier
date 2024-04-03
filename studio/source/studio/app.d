/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
import atelier;

import studio.ui;

void main() {
    try {
        openLogger(false);
        Atelier atelier = new Atelier(1280, 720, "Studio Atelier");
        atelier.renderer.scalingTime = 0;
        atelier.window.setIcon("atelier:logo128");
        atelier.renderer.setScaling(Renderer.Scaling.desktop);

        atelier.loadArchive("res");
        atelier.loadResources();

        initApp();
        atelier.run();
    }
    catch (Exception e) {
        log("Erreur: ", e.msg);
        foreach (trace; e.info) {
            log("at: ", trace);
        }
    }
    finally {
        closeLogger();
    }
}
