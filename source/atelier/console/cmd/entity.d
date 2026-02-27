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

    // entity add <S:rid>
    ConsoleCommand entity_add = entity.addCommand("add");
    entity_add.addParameter("rid", ConsoleType.string_);
    entity_add.setHint("Ajoute une entité");
    entity_add.setCallback(&_entity_add);

    // entity remove
    ConsoleCommand entity_remove = entity.addCommand("remove");
    entity_remove.setHint("Retire une entité");
    entity_remove.setCallback(&_entity_remove);

    // entity find <S:name>
    ConsoleCommand entity_find = entity.addCommand("find");
    entity_find.setHint("Recherche une entité par son nom");
    entity_find.setCallback(&_entity_find);

    // entity setpos <I:x> <I:y> <I:z>
    ConsoleCommand entity_setpos = entity.addCommand("setpos");
    entity_setpos.addParameter("x", ConsoleType.int_);
    entity_setpos.addParameter("y", ConsoleType.int_);
    entity_setpos.addParameter("z", ConsoleType.int_);
    entity_setpos.setHint("Positionne une entité");
    entity_setpos.setCallback(&_entity_setpos);

    // entity setposground <I:x> <I:y> [I:z]
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

    // entity move <I:x> <I:y> <I:z>
    ConsoleCommand entity_move = entity.addCommand("move");
    entity_move.addParameter("x", ConsoleType.int_);
    entity_move.addParameter("y", ConsoleType.int_);
    entity_move.addParameter("z", ConsoleType.int_);
    entity_move.setHint("Déplace une entité");
    entity_move.setCallback(&_entity_move);

    // entity moveground <I:x> <I:y> [I:z]
    ConsoleCommand entity_moveGround = entity.addCommand("moveground");
    entity_moveGround.addParameter("x", ConsoleType.int_);
    entity_moveGround.addParameter("y", ConsoleType.int_);
    entity_moveGround.addOption("z", ConsoleType.int_, ConsoleValue(0));
    entity_moveGround.setHint("Déplace une entité par rapport au terrain");
    entity_moveGround.setCallback(&_entity_moveGround);

}

private void _entity_add(ConsoleCall call) {
    string rid = call.getArgument!string("rid");

    Vec3i position = Vec3i(cast(Vec2i) Atelier.world.camera.getPosition(), 0);
    position.z = Atelier.world.scene.getBaseZ(position.xy);

    if (Atelier.res.has!Entity(rid)) {
        _entity = Atelier.res.get!Entity(rid);
        Atelier.world.addEntity(_entity);
        call.console.log("Entité crée");
    }
    else {
        call.console.log("Aucune entité `", rid, "` trouvé");
        return;
    }
}

private void _entity_remove(ConsoleCall call) {
    if (_entity) {
        call.console.log("Entité supprimée");
        _entity.unregister();
        _entity = null;
    }
    else {
        call.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_find(ConsoleCall call) {
    _entity = Atelier.world.find(call.getArgument!string("name"));
    if (_entity) {
        call.console.log("Entité sélectionnée");
    }
    else {
        call.console.log("Entité introuvable");
    }
}

private void _entity_getGraphic(ConsoleCall call) {
    if (_entity) {
        call.console.log("Graphique réglé sur `", _entity.getGraphicID(), "`");
    }
    else {
        call.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_setGraphic(ConsoleCall call) {
    if (_entity) {
        _entity.setGraphic(call.getArgument!string("id"));
        call.console.log("Graphique réglé sur `", _entity.getGraphicID(), "`");
    }
    else {
        call.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_getpos(ConsoleCall call) {
    if (_entity) {
        Vec3i pos = _entity.getPosition();
        call.console.log("Entité positionnée à ", pos.x, ", ", pos.y, ", ", pos.z);
    }
    else {
        call.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_setpos(ConsoleCall call) {
    if (_entity) {
        Vec3i pos = Vec3i(
            call.getArgument!int("x"),
            call.getArgument!int("y"),
            call.getArgument!int("z"));
        _entity.setPosition(pos);
        call.console.log("Entité déplacée à ", pos.x, ", ", pos.y, ", ", pos.z);
    }
    else {
        call.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_setposGround(ConsoleCall call) {
    if (_entity) {
        Vec2i xy = Vec2i(
            call.getArgument!int("x"),
            call.getArgument!int("y"));

        int z = Atelier.world.scene.getBaseZ(xy);

        Vec3i pos = Vec3i(xy, z + call.getArgument!int("z"));

        _entity.setPosition(pos);
        call.console.log("Entité déplacée à ", pos.x, ", ", pos.y, ", ", pos.z);
    }
    else {
        call.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_move(ConsoleCall call) {
    if (_entity) {
        Vec3f moveDir = Vec3f(
            call.getArgument!int("x"),
            call.getArgument!int("y"),
            call.getArgument!int("z"));
        _entity.moveRaw(moveDir);
        call.console.log("Entité déplacée de ", moveDir.x, ", ", moveDir.y, ", ", moveDir.z);
    }
    else {
        call.console.log("Aucune entité de sélectionné");
    }
}

private void _entity_moveGround(ConsoleCall call) {
    if (_entity) {
        Vec2i xy = Vec2i(
            call.getArgument!int("x"),
            call.getArgument!int("y"));

        int z = Atelier.world.scene.getBaseZ(xy + _entity.getPosition().xy);

        Vec3i pos = Vec3i(xy, z + call.getArgument!int("z"));

        _entity.moveRaw(cast(Vec3f) pos);
        call.console.log("Entité déplacée à ", pos.x, ", ", pos.y, ", ", pos.z);
    }
    else {
        call.console.log("Aucune entité de sélectionné");
    }
}
