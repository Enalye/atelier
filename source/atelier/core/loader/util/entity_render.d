module atelier.core.loader.util.entity_render;

import farfadet;
import atelier.common;
import atelier.render;
import atelier.world;
import atelier.core.runtime;

package(atelier.core.loader) struct EntityGraphicData {
    string name;
    string type;
    string rid;
    Vec2f anchor = Vec2f(.5f, 1f);
    Vec2f pivot = Vec2f(.5f, 1f);
    Vec2f offset = Vec2f.zero;
    bool isRotating;
    int angleOffset;
    Blend blend = Blend.alpha;
    int[] isBehind;
    bool isDefault;

    void serialize(OutStream stream) {
        stream.write!string(name);
        stream.write!string(type);
        stream.write!string(rid);
        stream.write!Vec2f(anchor);
        stream.write!Vec2f(pivot);
        stream.write!Vec2f(offset);
        stream.write!bool(isRotating);
        stream.write!int(angleOffset);
        stream.write!Blend(blend);
        stream.write!(int[])(isBehind);
        stream.write!bool(isDefault);
    }

    void deserialize(InStream stream) {
        name = stream.read!string();
        type = stream.read!string();
        rid = stream.read!string();
        anchor = stream.read!Vec2f();
        pivot = stream.read!Vec2f();
        offset = stream.read!Vec2f();
        isRotating = stream.read!bool();
        angleOffset = stream.read!int();
        blend = stream.read!Blend();
        isBehind = stream.read!(int[])();
        isDefault = stream.read!bool();
    }
}

package(atelier.core.loader) void serializeEntityGraphicData(const Farfadet ffd, OutStream stream) {
    stream.write!uint(cast(uint) ffd.getNodeCount("render"));
    foreach (renderNode; ffd.getNodes("render")) {
        EntityGraphicData renderData;

        renderData.name = renderNode.get!string(0);

        if (renderNode.hasNode("type")) {
            renderData.type = renderNode.getNode("type").get!string(0);
        }

        if (renderNode.hasNode("rid")) {
            renderData.rid = renderNode.getNode("rid").get!string(0);
        }

        if (renderNode.hasNode("anchor")) {
            renderData.anchor = renderNode.getNode("anchor").get!Vec2f(0);
        }

        if (renderNode.hasNode("pivot")) {
            renderData.pivot = renderNode.getNode("pivot").get!Vec2f(0);
        }

        if (renderNode.hasNode("offset")) {
            renderData.offset = renderNode.getNode("offset").get!Vec2f(0);
        }

        if (renderNode.hasNode("isRotating")) {
            renderData.isRotating = renderNode.getNode("isRotating").get!bool(0);
        }

        if (renderNode.hasNode("blend")) {
            renderData.blend = renderNode.getNode("blend").get!Blend(0);
        }

        if (renderNode.hasNode("angleOffset")) {
            renderData.angleOffset = renderNode.getNode("angleOffset").get!int(0);
        }

        if (renderNode.hasNode("isBehind")) {
            renderData.isBehind = renderNode.getNode("isBehind").get!(int[])(0);
        }

        if (renderNode.hasNode("isDefault")) {
            renderData.isDefault = renderNode.getNode("isDefault").get!bool(0);
        }

        renderData.serialize(stream);
    }
}

package(atelier.core.loader) EntityGraphicData[] unserializeEntityGraphicData(InStream stream) {
    EntityGraphicData[] graphicDataList;
    graphicDataList.length = stream.read!uint();
    for (uint i; i < graphicDataList.length; ++i) {
        graphicDataList[i].deserialize(stream);
    }
    return graphicDataList;
}

package(atelier.core.loader) EntityGraphic createEntityGraphicData(EntityGraphicData data) {
    EntityGraphic graphic;

    switch (data.type) {
    case "sprite":
        graphic = new EntitySpriteRenderer(Atelier.res.get!Sprite(data.rid));
        break;
    case "animation":
        graphic = new EntityAnimRenderer(Atelier.res.get!Animation(data.rid));
        break;
    case "multidiranimation":
        graphic = new EntityMultiDirAnimRenderer(
            Atelier.res.get!MultiDirAnimation(data.rid));
        break;
    default:
        return null;
    }

    graphic.setAnchor(data.anchor);
    graphic.setPivot(data.pivot);
    graphic.setOffset(data.offset);
    graphic.setRotating(data.isRotating);
    graphic.setAngleOffset(data.angleOffset);
    graphic.setBlend(data.blend);
    graphic.setIsBehind(data.isBehind);
    graphic.setDefault(data.isDefault);
    return graphic;
}
