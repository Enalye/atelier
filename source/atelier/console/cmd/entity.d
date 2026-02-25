module atelier.console.cmd.entity;

import atelier.common;
import atelier.core;
import atelier.world;
import atelier.physics;
import atelier.console.command;
import atelier.console.value;
import atelier.console.system;

private {
    Entity _entity;
}

package void _entityCmd(Console console) {
    // entity
    ConsoleCommand entity = console.addCommand("entity");

    // entity add
    ConsoleCommand entity_add = entity.addCommand("add");
    entity_add.addParameter("rid", ConsoleType.string_);
    entity_add.setHint("Ajoute une entité");
    entity_add.setCallback(&_entity_add);

    // entity remove
    ConsoleCommand entity_remove = entity.addCommand("remove");
    entity_remove.setHint("Retire une entité");
    entity_remove.setCallback(&_entity_remove);

    // entity find
    ConsoleCommand entity_find = entity.addCommand("find");
    entity_find.setHint("Recherche une entité par son nom");
    entity_find.setCallback(&_entity_find);

    // entity setpos
    ConsoleCommand entity_setpos = entity.addCommand("setpos");
    entity_setpos.addParameter("x", ConsoleType.int_);
    entity_setpos.addParameter("y", ConsoleType.int_);
    entity_setpos.addParameter("z", ConsoleType.int_);
    entity_setpos.setHint("Positionne une entité");
    entity_setpos.setCallback(&_entity_setpos);

    // entity setposground
    ConsoleCommand entity_setposGround = entity.addCommand("setposground");
    entity_setposGround.addParameter("x", ConsoleType.int_);
    entity_setposGround.addParameter("y", ConsoleType.int_);
    entity_setposGround.addOption("z", ConsoleType.int_, ConsoleValue(0));
    entity_setposGround.setHint("Positionne une entité par rapport au terrain");
    entity_setposGround.setCallback(&_entity_setpos);

    // entity getpos
    ConsoleCommand entity_getpos = entity.addCommand("getpos");
    entity_getpos.setHint("Affiche la position d’une entité");
    entity_getpos.setCallback(&_entity_getpos);

    // entity move
    ConsoleCommand entity_move = entity.addCommand("move");
    entity_move.addParameter("x", ConsoleType.int_);
    entity_move.addParameter("y", ConsoleType.int_);
    entity_move.addParameter("z", ConsoleType.int_);
    entity_move.setHint("Déplace une entité");
    entity_move.setCallback(&_entity_move);

    // entity moveground
    ConsoleCommand entity_moveGround = entity.addCommand("moveground");
    entity_moveGround.addParameter("x", ConsoleType.int_);
    entity_moveGround.addParameter("y", ConsoleType.int_);
    entity_moveGround.addOption("z", ConsoleType.int_, ConsoleValue(0));
    entity_moveGround.setHint("Déplace une entité par rapport au terrain");
    entity_moveGround.setCallback(&_entity_moveGround);

}

private void _entity_add(ConsoleResult result) {
    string rid = result.getArgument!string("rid");

    Vec3i position = Vec3i(cast(Vec2i) Atelier.world.camera.getPosition(), 0);
    position.z = Atelier.world.scene.getBaseZ(position.xy);

    if (Atelier.res.has!Entity(rid)) {
        _entity = Atelier.res.get!Entity(rid);
        Atelier.world.addEntity(_entity);
        result.console.log("Entité crée");
    }
    else {
        result.console.log("Aucune entité `", rid, "` trouvé");
        return;
    }
}

private void _entity_remove(ConsoleResult result) {
    if (_entity) {
        Atelier.console.log("Entité supprimée");
        _entity.unregister();
        _entity = null;
    }
    else {
        Atelier.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_find(ConsoleResult result) {
    _entity = Atelier.world.find(result.getArgument!string("name"));
    if (_entity) {
        Atelier.console.log("Entité sélectionnée");
    }
    else {
        Atelier.console.log("Entité introuvable");
    }
}

private void _entity_getGraphic(ConsoleResult result) {
    if (_entity) {
        Atelier.console.log("Graphique réglé sur `", _entity.getGraphicID(), "`");
    }
    else {
        Atelier.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_setGraphic(ConsoleResult result) {
    if (_entity) {
        _entity.setGraphic(result.getArgument!string("id"));
        Atelier.console.log("Graphique réglé sur `", _entity.getGraphicID(), "`");
    }
    else {
        Atelier.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_getpos(ConsoleResult result) {
    if (_entity) {
        Vec3i pos = _entity.getPosition();
        result.console.log("Entité positionnée à ", pos.x, ", ", pos.y, ", ", pos.z);
    }
    else {
        result.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_setpos(ConsoleResult result) {
    if (_entity) {
        Vec3i pos = Vec3i(
            result.getArgument!int("x"),
            result.getArgument!int("y"),
            result.getArgument!int("z"));
        _entity.setPosition(pos);
        result.console.log("Entité déplacée à ", pos.x, ", ", pos.y, ", ", pos.z);
    }
    else {
        result.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_setposGround(ConsoleResult result) {
    if (_entity) {
        Vec2i xy = Vec2i(
            result.getArgument!int("x"),
            result.getArgument!int("y"));

        int z = Atelier.world.scene.getBaseZ(xy);

        Vec3i pos = Vec3i(xy, z + result.getArgument!int("z"));

        _entity.setPosition(pos);
        result.console.log("Entité déplacée à ", pos.x, ", ", pos.y, ", ", pos.z);
    }
    else {
        result.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_move(ConsoleResult result) {
    if (_entity) {
        Vec3f moveDir = Vec3f(
            result.getArgument!int("x"),
            result.getArgument!int("y"),
            result.getArgument!int("z"));
        _entity.moveRaw(moveDir);
        result.console.log("Entité déplacée de ", moveDir.x, ", ", moveDir.y, ", ", moveDir.z);
    }
    else {
        result.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_moveGround(ConsoleResult result) {
    if (_entity) {
        Vec2i xy = Vec2i(
            result.getArgument!int("x"),
            result.getArgument!int("y"));

        int z = Atelier.world.scene.getBaseZ(xy + _entity.getPosition().xy);

        Vec3i pos = Vec3i(xy, z + result.getArgument!int("z"));

        _entity.moveRaw(cast(Vec3f) pos);
        result.console.log("Entité déplacée à ", pos.x, ", ", pos.y, ", ", pos.z);
    }
    else {
        result.console.log("Aucune entité de sélectionné");
    }
}
