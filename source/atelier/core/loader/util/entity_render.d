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
    bool isAuxGraphic;

    // Principal
    bool isDefault;
    Vec2i effectMargin;

    struct AuxGraphicData {
        string id;
        uint[] dirs;
        // Offset du rendu auxiliaire en fonction de la frame de l’animation du rendu principal
        int[] xOffsets;
        int[] yOffsets;
        float[] angleOffsets;

        bool hasDir(uint dir) const {
            if (!dirs.length)
                return true;

            foreach (dir_; dirs) {
                if (dir_ == dir)
                    return true;
            }
            return false;
        }
    }

    AuxGraphicData[] auxGraphics;

    // Auxiliaire
    int[] isBehind;
    int order;
    uint slot;

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
        stream.write!bool(isAuxGraphic);

        // Principal
        stream.write!bool(isDefault);
        stream.write!Vec2i(effectMargin);
        stream.write!(AuxGraphicData[])(auxGraphics);

        // Auxiliaire
        stream.write!(int[])(isBehind);
        stream.write!int(order);
        stream.write!uint(slot);
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
        isAuxGraphic = stream.read!bool();

        // Principal
        isDefault = stream.read!bool();
        effectMargin = stream.read!Vec2i();
        auxGraphics = stream.read!(AuxGraphicData[])();

        // Auxiliaire
        isBehind = stream.read!(int[])();
        order = stream.read!int();
        slot = stream.read!uint();
    }
}

package(atelier.core.loader) void serializeEntityGraphicData(const Farfadet ffd, OutStream stream) {
    uint count = cast(uint)(ffd.getNodeCount("graphic") + ffd.getNodeCount("auxGraphic"));
    stream.write!uint(count);

    foreach (string key; ["graphic", "auxGraphic"]) {
        foreach (graphicNode; ffd.getNodes(key)) {
            EntityGraphicData graphicData;

            graphicData.name = graphicNode.get!string(0);
            graphicData.isAuxGraphic = key == "auxGraphic";

            if (graphicNode.hasNode("type")) {
                graphicData.type = graphicNode.getNode("type").get!string(0);
            }

            if (graphicNode.hasNode("rid")) {
                graphicData.rid = graphicNode.getNode("rid").get!string(0);
            }

            if (graphicNode.hasNode("anchor")) {
                graphicData.anchor = graphicNode.getNode("anchor").get!Vec2f(0);
            }

            if (graphicNode.hasNode("pivot")) {
                graphicData.pivot = graphicNode.getNode("pivot").get!Vec2f(0);
            }

            if (graphicNode.hasNode("offset")) {
                graphicData.offset = graphicNode.getNode("offset").get!Vec2f(0);
            }

            if (graphicNode.hasNode("isRotating")) {
                graphicData.isRotating = graphicNode.getNode("isRotating").get!bool(0);
            }

            if (graphicNode.hasNode("blend")) {
                graphicData.blend = graphicNode.getNode("blend").get!Blend(0);
            }

            if (graphicNode.hasNode("angleOffset")) {
                graphicData.angleOffset = graphicNode.getNode("angleOffset").get!int(0);
            }

            if (graphicData.isAuxGraphic) {
                if (graphicNode.hasNode("isBehind")) {
                    graphicData.isBehind = graphicNode.getNode("isBehind").get!(int[])(0);
                }

                if (graphicNode.hasNode("order")) {
                    graphicData.order = graphicNode.getNode("order").get!(int)(0);
                }

                if (graphicNode.hasNode("slot")) {
                    graphicData.slot = graphicNode.getNode("slot").get!(uint)(0);
                }
            }
            else {
                if (graphicNode.hasNode("isDefault")) {
                    graphicData.isDefault = graphicNode.getNode("isDefault").get!bool(0);
                }

                if (graphicNode.hasNode("effectMargin")) {
                    graphicData.effectMargin = graphicNode.getNode("effectMargin").get!Vec2i(0);
                }

                graphicData.auxGraphics.length = 0;
                foreach (auxNode; graphicNode.getNodes("auxGraphic")) {
                    EntityGraphicData.AuxGraphicData graphic;

                    if (auxNode.hasNode("id")) {
                        graphic.id = auxNode.getNode("id").get!string(0);
                    }

                    if (auxNode.hasNode("dirs")) {
                        graphic.dirs = auxNode.getNode("dirs").get!(uint[])(0);
                    }

                    if (auxNode.hasNode("xOffsets")) {
                        graphic.xOffsets = auxNode.getNode("xOffsets").get!(int[])(0);
                    }

                    if (auxNode.hasNode("yOffsets")) {
                        graphic.yOffsets = auxNode.getNode("yOffsets").get!(int[])(0);
                    }

                    if (auxNode.hasNode("angleOffsets")) {
                        graphic.angleOffsets = auxNode.getNode("angleOffsets").get!(float[])(0);
                    }

                    graphicData.auxGraphics ~= graphic;
                }
            }

            graphicData.serialize(stream);
        }
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

    if (data.isAuxGraphic) {
        graphic.setIsBehind(data.isBehind);
        graphic.setOrder(data.order);
        graphic.setSlot(data.slot);
    }
    else {
        graphic.setDefault(data.isDefault);
        graphic.setEffectMargin(data.effectMargin);

        foreach (auxGraphic; data.auxGraphics) {
            graphic.addAuxGraphics(auxGraphic.id, auxGraphic.dirs, auxGraphic.xOffsets, auxGraphic.yOffsets, auxGraphic
                    .angleOffsets);
        }
    }

    return graphic;
}

package(atelier.core.loader) void buildEntityGraphics(Entity entity, EntityGraphicData[] graphicDataList) {
    for (uint i; i < graphicDataList.length; ++i) {
        EntityGraphic graphic = createEntityGraphicData(graphicDataList[i]);
        if (!graphic)
            continue;

        if (graphicDataList[i].isAuxGraphic)
            entity.addAuxGraphic(graphicDataList[i].name, graphic);
        else
            entity.addGraphic(graphicDataList[i].name, graphic);
    }
}
