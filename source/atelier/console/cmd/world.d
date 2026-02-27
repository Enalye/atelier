module atelier.console.cmd.world;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.console.command;
import atelier.console.value;
import atelier.console.system;

package void _worldCmd(Console console) {
    // scene
    ConsoleCommand scene = console.addCommand("scene");
    scene.setHint("Affiche la scène actuelle");
    scene.setCallback(&_scene);

    // scene reload
    ConsoleCommand scene_reload = scene.addCommand("reload");
    scene_reload.setHint("Recharge la scène actuelle");
    scene_reload.setCallback(&_scene_reload);

    // scene reset
    ConsoleCommand scene_reset = scene.addCommand("reset");
    scene_reset.setHint("Recharge instantanément la scène actuelle");
    scene_reset.setCallback(&_scene_reset);

    // scene change <S:rid> [S:teleporter] [U:direction]
    ConsoleCommand scene_change = scene.addCommand("change");
    scene_change.addParameter("rid", ConsoleType.string_);
    scene_change.addOption("teleporter", ConsoleType.string_, ConsoleValue(""));
    scene_change.addOption("direction", ConsoleType.uint_, ConsoleValue(0));
    scene_change.setHint("Change le niveau");
    scene_change.setCallback(&_scene_change);

    // scene set <S:rid>
    ConsoleCommand scene_set = scene.addCommand("set");
    scene_set.addParameter("rid", ConsoleType.string_);
    scene_set.setHint("Change le niveau instantanément");
    scene_set.setCallback(&_scene_set);
}

private void _scene(ConsoleCall call) {
    call.console.log("Scène actuelle: `", Atelier.state.getScene(), "`");
}

private void _scene_reload(ConsoleCall call) {
    call.console.log("Rechargement de la scène `", Atelier.state.getScene(), "`");
    Atelier.world.runScene(
        Atelier.state.getScene(),
        Atelier.state.getTeleporter(),
        Atelier.state.getTeleporterDirection());
}

private void _scene_reset(ConsoleCall call) {
    call.console.log("Rechargement de la scène `", Atelier.state.getScene(), "`");
    Atelier.world.load(Atelier.state.getScene());
}

private void _scene_change(ConsoleCall call) {
    string rid = call.getArgument!string("rid");
    string teleporter = call.getArgument!string("teleporter");
    uint direction = call.getArgument!uint("direction");

    if (Atelier.res.has!Scene(rid)) {
        call.console.log("Chargement de la scène `", rid, "`");
        Atelier.world.runScene(rid, teleporter, direction);
    }
    else {
        call.console.log("La scène `", rid, "` n’existe pas");
    }
}

private void _scene_set(ConsoleCall call) {
    string rid = call.getArgument!string("rid");
    if (Atelier.res.has!Scene(rid)) {
        call.console.log("Chargement de la scène `", rid, "`");
        Atelier.world.load(rid);
    }
    else {
        call.console.log("La scène `", rid, "` n’existe pas");
    }
}
