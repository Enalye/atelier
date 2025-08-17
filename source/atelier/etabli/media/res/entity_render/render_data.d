module atelier.etabli.media.res.entity_render.render_data;

import atelier;
import farfadet;
import atelier.etabli.ui;

final class EntityRenderData {
    private {
        string _name;
        string _type;
        string _rid;
        string _layer;
        bool _isRenderDirty = true;
        Sprite _sprite;
        Animation _anim;
        MultiDirAnimation _mdiranim;
        Image _image;
    }

    bool isDefault;
    bool isRotating;
    Blend blend = Blend.alpha;
    Vec2f anchor = Vec2f(.5f, .5f);
    Vec2f pivot = Vec2f(.5f, .5f);
    Vec2i offset = Vec2i.zero;
    int angleOffset = 0;
    int[] isBehind;
    bool isVisible = true;

    @property {
        string name() const {
            return _name;
        }

        string name(string name_) {
            _name = name_;
            return _name;
        }

        string type() const {
            return _type;
        }

        string type(string type_) {
            _type = type_;
            _isRenderDirty = true;
            return _type;
        }

        string rid() const {
            return _rid;
        }

        string rid(string rid_) {
            _rid = rid_;
            _isRenderDirty = true;
            return _rid;
        }
    }

    this() {

    }

    this(Farfadet ffd) {
        name = ffd.get!string(0);

        if (ffd.hasNode("type")) {
            type = ffd.getNode("type").get!string(0);
        }

        if (ffd.hasNode("rid")) {
            rid = ffd.getNode("rid").get!string(0);
        }

        if (ffd.hasNode("anchor")) {
            anchor = ffd.getNode("anchor").get!Vec2f(0);
        }

        if (ffd.hasNode("pivot")) {
            pivot = ffd.getNode("pivot").get!Vec2f(0);
        }

        if (ffd.hasNode("offset")) {
            offset = ffd.getNode("offset").get!Vec2i(0);
        }

        if (ffd.hasNode("isRotating")) {
            isRotating = ffd.getNode("isRotating").get!bool(0);
        }

        if (ffd.hasNode("angleOffset")) {
            angleOffset = ffd.getNode("angleOffset").get!int(0);
        }

        if (ffd.hasNode("blend")) {
            blend = ffd.getNode("blend").get!Blend(0);
        }

        if (ffd.hasNode("isDefault")) {
            isDefault = ffd.getNode("isDefault").get!bool(0);
        }

        if (ffd.hasNode("isBehind")) {
            isBehind = ffd.getNode("isBehind").get!(int[])(0);
        }
    }

    this(EntityRenderData other) {
        name = other.name;
        type = other.type;
        rid = other.rid;
        anchor = other.anchor;
        pivot = other.pivot;
        offset = other.offset;
        isRotating = other.isRotating;
        angleOffset = other.angleOffset;
        blend = other.blend;
        isDefault = other.isDefault;
        isBehind = other.isBehind;
        isVisible = other.isVisible;
    }

    Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("render").add(name);
        node.addNode("type").add(type);
        node.addNode("rid").add(rid);
        node.addNode("anchor").add(anchor);
        node.addNode("pivot").add(pivot);
        node.addNode("offset").add(offset);
        node.addNode("isRotating").add(isRotating);
        node.addNode("angleOffset").add(angleOffset);
        node.addNode("blend").add(blend);
        node.addNode("isDefault").add(isDefault);
        node.addNode("isBehind").add(isBehind);
        return node;
    }

    void play() {
        if (_anim) {
            _anim.start();
        }

        if (_mdiranim) {
            _mdiranim.start();
        }
    }

    void pause() {
        if (_anim) {
            if (_anim.isPlaying())
                _anim.pause();
            else
                _anim.resume();
        }

        if (_mdiranim) {
            if (_mdiranim.isPlaying())
                _mdiranim.pause();
            else
                _mdiranim.resume();
        }
    }

    void stop() {
        if (_anim) {
            _anim.stop();
        }

        if (_mdiranim) {
            _mdiranim.stop();
        }
    }

    void update(float zoom) {
        if (_sprite) {
            _sprite.size = (cast(Vec2f) _sprite.clip.zw) * zoom;
        }
        if (_anim) {
            _anim.size = (cast(Vec2f) _anim.clip.zw) * zoom;
        }
        if (_mdiranim) {
            _mdiranim.size = (cast(Vec2f) _mdiranim.clip.zw) * zoom;
        }

        if (_image) {
            _image.position = (cast(Vec2f) offset) * zoom;
            _image.anchor = anchor;
            _image.pivot = pivot;
            _image.update();
        }
    }

    void draw(Vec2f offset_, float dirAngle) {
        if (!isVisible)
            return;

        if (_isRenderDirty) {
            _isRenderDirty = false;

            _sprite = null;
            _anim = null;
            _mdiranim = null;
            _image = null;
            switch (_type) {
            case "sprite":
                _sprite = Atelier.etabli.getSprite(_rid);
                _image = _sprite;
                break;
            case "animation":
                _anim = Atelier.etabli.getAnimation(_rid);
                _image = _anim;
                break;
            case "multidiranimation":
                _mdiranim = Atelier.etabli.getMultiDirAnimation(_rid);
                _image = _mdiranim;
                break;
            default:
                break;
            }
        }

        float angle = angleOffset;
        if (isRotating) {
            angle += dirAngle;
        }

        if (_sprite) {
            _sprite.angle = angle;
            _sprite.blend = blend;
        }
        if (_anim) {
            _anim.angle = angle;
            _anim.blend = blend;
        }
        if (_mdiranim) {
            _mdiranim.angle = angle;
            _mdiranim.blend = blend;
            _mdiranim.dirAngle = dirAngle;
        }

        if (_image) {
            _image.draw(offset_);
        }
    }

    EntityGraphic createEntityGraphicData() {
        EntityGraphic graphic;

        switch (_type) {
        case "sprite":
            graphic = new EntitySpriteRenderer(Atelier.etabli.getSprite(_rid));
            break;
        case "animation":
            graphic = new EntityAnimRenderer(Atelier.etabli.getAnimation(_rid));
            break;
        case "multidiranimation":
            graphic = new EntityMultiDirAnimRenderer(
                Atelier.etabli.getMultiDirAnimation(_rid));
            break;
        default:
            return null;
        }

        graphic.setAnchor(anchor);
        graphic.setPivot(pivot);
        graphic.setOffset(cast(Vec2f) offset);
        graphic.setRotating(isRotating);
        graphic.setAngleOffset(angleOffset);
        graphic.setBlend(blend);
        graphic.setDefault(isDefault);
        graphic.setIsBehind(isBehind);
        return graphic;
    }
}
