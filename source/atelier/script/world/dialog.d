module atelier.script.world.dialog;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.world;
import atelier.ui;
import atelier.script.util;

package void loadLibWorld_dialog(GrModule mod) {
    GrType entityType = grGetNativeType("Entity");

    mod.setDescription(GrLocale.fr_FR, "Ouvre une bulle de dialogue");
    mod.setParameters(["entity", "text"]);
    mod.addFunction(&_say, "say", [entityType, grString]);

    mod.setDescription(GrLocale.fr_FR, "Ouvre une bulle de dialogue");
    mod.setParameters(["entity", "text"]);
    mod.addFunction(&_think, "think", [entityType, grString]);

    mod.setDescription(GrLocale.fr_FR, "Ferme une bulle de dialogue");
    mod.setParameters(["entity"]);
    mod.addFunction(&_hush, "hush", [entityType]);

    mod.setDescription(GrLocale.fr_FR, "Ouvre une sélection de choix");
    mod.setParameters(["entity", "choices", "hasDefault"]);
    mod.addFunction(&_choice, "choice", [entityType, grList(grString), grBool], [
            grChannel(grInt)
        ]);
}

private void _say(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    string text = call.getString(1);

    DialogBlocker blocker = new DialogBlocker;
    call.block(blocker);

    Atelier.world.dialog.say(entity, text, blocker);
}

private void _think(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    string text = call.getString(1);

    DialogBlocker blocker = new DialogBlocker;
    call.block(blocker);

    Atelier.world.dialog.think(entity, text, blocker);
}

private void _hush(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    Atelier.world.dialog.close(entity);
}

private void _choice(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    string[] choices = call.getList(1).getStrings!string();
    bool hasDefault = call.getBool(2);

    GrChannel channel = new GrChannel;
    Atelier.world.dialog.choice(entity, choices, hasDefault, channel);
    call.setChannel(channel);
}
