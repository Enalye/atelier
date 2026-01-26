module atelier.console.cmd.entity;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.physics;
import atelier.console.system;

package void _entityCmd(Cli cli) {
    cli.addCommand(&_addentity, "addentity", "Ajoute une entité", [
            "S:rid"
        ]);
    cli.addCommandOption("addentity", "p", "pos",
        "Positionne l’entité créée", ["I:x", "I:y", "I:z"]);
    cli.addCommandOption("addentity", "n", "name", "Nomme l’entité", [
            "S:name"
        ]);
    cli.addCommandOption("addentity", "g", "graphic",
        "Change le rendu de l’entité", ["S:name"]);
    cli.addCommandOption("addentity", "a", "angle", "Nomme l’entité", [
            "F:degrees"
        ]);

    cli.addCommand(&_removeentity, "removeentity", "Supprime une entité", [
            "S:name"
        ]);

    cli.addCommand(&_setvel, "setvel", "Change la vitesse d’une entité", [
            "S:name", "F:x", "F:y", "F:z"
        ]);

    cli.addCommand(&_move, "move", "Déplace une entité", [
            "S:name", "F:x", "F:y", "F:z"
        ]);
    /*
    cli.addCommand(&_getpos, "getpos", "Position de l’entité", [
            "S:type", "S:rid"
        ]);*/
    //cli.addCommand(&_echo, "echo", "Répète le message", ["S:msg"]);

}

private void _addentity(Cli.Result cli) {
    string rid = cli.getRequiredParamAs!string(0);
    Entity entity;

    Vec3i position = Vec3i(cast(Vec2i) Atelier.world.camera.getPosition(), 0);
    position.z = Atelier.world.scene.getBaseZ(position.xy);

    try {
        entity = Atelier.res.get!Entity(rid);
    }
    catch (Exception e) {
        Atelier.console.log("Aucune entité `", rid, "` trouvé");
        return;
    }

    if (cli.hasOption("pos")) {
        Cli.Result.Option option = cli.getOption("pos");
        position.x = option.getRequiredParamAs!int(0);
        position.y = option.getRequiredParamAs!int(1);
        position.z = option.getRequiredParamAs!int(2);
    }

    entity.setPosition(position);

    if (cli.hasOption("name")) {
        Cli.Result.Option option = cli.getOption("pos");
        entity.setName(option.getRequiredParamAs!string(0));
    }

    if (cli.hasOption("graphic")) {
        Cli.Result.Option option = cli.getOption("graphic");
        entity.setGraphic(option.getRequiredParamAs!string(0));
    }

    if (cli.hasOption("angle")) {
        Cli.Result.Option option = cli.getOption("angle");
        entity.angle = option.getRequiredParamAs!float(0);
    }

    Atelier.world.addEntity(entity);
    Atelier.console.log("Entité crée");
}

private void _removeentity(Cli.Result cli) {
    Entity entity = Atelier.world.find(cli.getRequiredParam(0));
    if (entity) {
        Atelier.console.log("`", entity.getName(), "` supprimé");
        entity.unregister();
    }
    else {
        Atelier.console.log("`", entity.getName(), "` introuvable");
    }
}

private void _setvel(Cli.Result cli) {
    Entity entity = Atelier.world.find(cli.getRequiredParam(0));
    if (entity) {
        Vec3f vel = Vec3f(cli.getRequiredParamAs!float(1), cli.getRequiredParamAs!float(2), cli
                .getRequiredParamAs!float(3));
        entity.setVelocity(vel);
        Atelier.console.log("Vitesse de `", entity.getName(), "` fixée à ", vel);
    }
    else {
        Atelier.console.log("`", entity.getName(), "` introuvable");
    }
}

private void _move(Cli.Result cli) {
    Entity entity = Atelier.world.find(cli.getRequiredParam(0));
    if (entity) {
        Vec3f moveDir = Vec3f(cli.getRequiredParamAs!float(1), cli.getRequiredParamAs!float(2), cli
                .getRequiredParamAs!float(3));
        entity.move(moveDir);
        Atelier.console.log("`", entity.getName(), "` déplacé de ", moveDir);
    }
    else {
        Atelier.console.log("`", entity.getName(), "` introuvable");
    }
}
