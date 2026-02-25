module atelier.console.cmd.nav;

import atelier.common;
import atelier.core;
import atelier.nav;
import atelier.console.command;
import atelier.console.value;
import atelier.console.system;

package void _navCmd(Console console) {
    // nav
    ConsoleCommand nav = console.addCommand("nav");

    // nav debug
    ConsoleCommand nav_debug = nav.addCommand("debug");
    nav_debug.addOption("show", ConsoleType.bool_, ConsoleValue(true));
    nav_debug.setHint("Affiche le navmesh");
    nav_debug.setCallback(&_nav_debug);

    // nav debug setlevel [U:level]
    ConsoleCommand nav_debug_setlevel = nav_debug.addCommand("setlevel");
    nav_debug_setlevel.addParameter("level", ConsoleType.uint_);
    nav_debug_setlevel.setHint("Restreint l’affichage à un niveau de terrain");
    nav_debug_setlevel.setCallback(&_nav_debug_setlevel);

    // nav debug unsetlevel
    ConsoleCommand nav_debug_unsetlevel = nav_debug.addCommand("unsetlevel");
    nav_debug_unsetlevel.setHint("Retire la restriction de niveau de terrain");
    nav_debug_unsetlevel.setCallback(&_nav_debug_unsetlevel);

    // nav generate
    ConsoleCommand nav_generate = nav.addCommand("generate");
    nav_generate.setHint("Régénère le navmesh");
    nav_generate.setCallback(&_nav_generate);
}

private void _nav_debug(ConsoleResult result) {
    Atelier.nav.isDebug = result.getArgument!bool("show");

    if (Atelier.nav.isDebug)
        Atelier.log("Navigation affichée");
    else
        Atelier.log("Navigation masquée");
}

private void _nav_debug_setlevel(ConsoleResult result) {
    Atelier.nav.levelToDraw = result.getArgument!int("level");
    Atelier.log("Niveau de navigation affiché reglé sur ", Atelier.nav.levelToDraw);
}

private void _nav_debug_unsetlevel(ConsoleResult result) {
    Atelier.nav.levelToDraw = -1;
    Atelier.log("Niveau de navigation affiché reglé sur tous");
}

private void _nav_generate(ConsoleResult result) {
    Atelier.log("Génération du navmesh");
    Atelier.nav.generate();
}
