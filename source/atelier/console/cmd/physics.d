module atelier.console.cmd.physics;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.physics;
import atelier.console.command;
import atelier.console.value;
import atelier.console.system;

package void _physicsCmd(Console console) {
    // coll
    ConsoleCommand coll = console.addCommand("coll");

    // coll debug
    ConsoleCommand coll_debug = coll.addCommand("debug");

    // coll debug showall [B:show]
    ConsoleCommand coll_debug_showall = coll_debug.addCommand("showall");
    coll_debug_showall.addOption("show", ConsoleType.bool_, ConsoleValue(true));
    coll_debug_showall.setHint("Affiche toutes les boîtes de collision");
    coll_debug_showall.setCallback(&_coll_debug_showall);

    // coll debug showactors [B:show]
    ConsoleCommand coll_debug_showactors = coll_debug.addCommand("showactors");
    coll_debug_showactors.addOption("show", ConsoleType.bool_, ConsoleValue(true));
    coll_debug_showactors.setHint("Affiche les boîtes de collision des acteurs");
    coll_debug_showactors.setCallback(&_coll_debug_showactors);

    // coll debug showsolids [B:show]
    ConsoleCommand coll_debug_showsolids = coll_debug.addCommand("showsolids");
    coll_debug_showsolids.addOption("show", ConsoleType.bool_, ConsoleValue(true));
    coll_debug_showsolids.setHint("Affiche les boîtes de collision des solides");
    coll_debug_showsolids.setCallback(&_coll_debug_showsolids);

    // coll debug showtriggers [B:show]
    ConsoleCommand coll_debug_showtriggers = coll_debug.addCommand("showtriggers");
    coll_debug_showtriggers.addOption("show", ConsoleType.bool_, ConsoleValue(true));
    coll_debug_showtriggers.setHint("Affiche les boîtes de collision des déclencheurs");
    coll_debug_showtriggers.setCallback(&_coll_debug_showtriggers);

    // coll debug showhitboxes [B:show]
    ConsoleCommand coll_debug_showhitboxes = coll_debug.addCommand("showhitboxes");
    coll_debug_showhitboxes.addOption("show", ConsoleType.bool_, ConsoleValue(true));
    coll_debug_showhitboxes.setHint("Affiche les boîtes de collision des hitbox");
    coll_debug_showhitboxes.setCallback(&_coll_debug_showhitboxes);
}

private void _coll_debug_showall(ConsoleCall call) {
    bool show = call.getArgument!bool("show");
    Atelier.physics.showActors(show);
    Atelier.physics.showSolids(show);
    Atelier.physics.showTriggers(show);
    Atelier.physics.showHitboxes(show);
}

private void _coll_debug_showactors(ConsoleCall call) {
    bool show = call.getArgument!bool("show");
    Atelier.physics.showActors(show);

    if (Atelier.nav.isDebug)
        call.console.log("Collision des acteurs affichée");
    else
        call.console.log("Collision des acteurs masquée");
}

private void _coll_debug_showsolids(ConsoleCall call) {
    bool show = call.getArgument!bool("show");
    Atelier.physics.showSolids(show);

    if (Atelier.nav.isDebug)
        call.console.log("Collision des solides affichée");
    else
        call.console.log("Collision des solides masquée");
}

private void _coll_debug_showtriggers(ConsoleCall call) {
    bool show = call.getArgument!bool("show");
    Atelier.physics.showTriggers(show);

    if (Atelier.nav.isDebug)
        call.console.log("Collision des déclencheurs affichée");
    else
        call.console.log("Collision des déclencheurs masquée");
}

private void _coll_debug_showhitboxes(ConsoleCall call) {
    bool show = call.getArgument!bool("show");
    Atelier.physics.showHitboxes(show);

    if (Atelier.nav.isDebug)
        call.console.log("Collision des hitbox affichée");
    else
        call.console.log("Collision des hitbox masquée");
}
