module atelier.etabli.media.res.particle.particle_old;
/+
import std.conv : to;
import std.math : round;
import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier;

import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;
import atelier.etabli.ui;

final class ParticleResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        string _spriteRID;
        string _blend;
        bool _isRelativePosition, _isRelativeSpriteAngle;
        Vec2u _lifetime, _count;
        string _mode;
        Vec2f _area = Vec2f.zero, _distance = Vec2f.zero, _angle = Vec2f.zero;
        float _spreadAngle = 0f;
        EffectData[] _effects;
        ParticleSource _particleSource;
        Vec2f _position = Vec2f.zero;
        float _zoom = 1f;
        ParameterWindow _parameterWindow;
        MediaPlayer _player;
        bool _isPlaying;
    }

    @property {
        bool isPlaying() const {
            return _isPlaying;
        }
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);
        _particleSource = new ParticleSource;

        if (ffd.hasNode("sprite")) {
            _spriteRID = ffd.getNode("sprite").get!string(0);
            setSpriteRID(_spriteRID);
        }

        _blend = to!string(Blend.alpha);
        if (ffd.hasNode("blend")) {
            _blend = ffd.getNode("blend").get!string(0);
            _particleSource.setBlend(to!Blend(_blend));
        }

        if (ffd.hasNode("isRelativePosition")) {
            _isRelativePosition = ffd.getNode("isRelativePosition").get!bool(0);
            _particleSource.setRelativePosition(_isRelativePosition);
        }

        if (ffd.hasNode("isRelativeSpriteAngle")) {
            _isRelativeSpriteAngle = ffd.getNode("isRelativeSpriteAngle").get!bool(0);
            _particleSource.setRelativeSpriteAngle(_isRelativeSpriteAngle);
        }

        if (ffd.hasNode("lifetime")) {
            _lifetime = ffd.getNode("lifetime").get!Vec2u(0);
            _particleSource.setLifetime(_lifetime.x, _lifetime.y);
        }

        if (ffd.hasNode("count")) {
            _count = ffd.getNode("count").get!Vec2u(0);
            _particleSource.setCount(_count.x, _count.y);
        }

        if (ffd.hasNode("mode")) {
            _mode = ffd.getNode("mode").get!string(0);
            _particleSource.setMode(to!ParticleMode(_mode));
        }

        if (ffd.hasNode("area")) {
            _area = ffd.getNode("area").get!Vec2f(0);
            _particleSource.setArea(_area.x, _area.y);
        }

        if (ffd.hasNode("distance")) {
            _distance = ffd.getNode("distance").get!Vec2f(0);
            _particleSource.setDistance(_distance.x, _distance.y);
        }

        if (ffd.hasNode("spread")) {
            Farfadet node = ffd.getNode("spread");
            _angle = node.get!Vec2f(0);
            _spreadAngle = node.get!float(2);
            _particleSource.setSpread(_angle.x, _angle.y, _spreadAngle);
        }

        foreach (node; ffd.getNodes()) {
            switch (node.name) {
            case "speed":
            case "angle":
            case "spin":
            case "pivotAngle":
            case "pivotSpin":
            case "pivotDistance":
            case "spriteAngle":
            case "spriteSpin":
            case "scale":
            case "color":
            case "alpha":
                _effects ~= new EffectData(node);
                break;
            default:
                break;
            }
        }

        _player = new MediaPlayer(this);
        addUI(_player);

        _parameterWindow = new ParameterWindow(_spriteRID, _blend, _isRelativePosition, _isRelativeSpriteAngle,
            _lifetime, _count, _mode, _area, _distance, _angle, _spreadAngle, _effects);

        _parameterWindow.addEventListener("property_spriteRID", {
            _spriteRID = _parameterWindow.getSpriteRID();
            setSpriteRID(_spriteRID);
            setDirty();
        });

        _parameterWindow.addEventListener("property_blend", {
            _blend = _parameterWindow.getBlend();
            _particleSource.setBlend(to!Blend(_blend));
            setDirty();
        });

        _parameterWindow.addEventListener("property_relativePosition", {
            _isRelativePosition = _parameterWindow.isRelativePosition();
            _particleSource.setRelativePosition(_isRelativePosition);
            setDirty();
        });

        _parameterWindow.addEventListener("property_relativeSpriteAngle", {
            _isRelativeSpriteAngle = _parameterWindow.isRelativeSpriteAngle();
            _particleSource.setRelativeSpriteAngle(_isRelativeSpriteAngle);
            setDirty();
        });

        _parameterWindow.addEventListener("property_lifetime", {
            _lifetime = _parameterWindow.getLifetime();
            _particleSource.setLifetime(_lifetime.x, _lifetime.y);
            setDirty();
        });

        _parameterWindow.addEventListener("property_count", {
            _count = _parameterWindow.getCount();
            _particleSource.setCount(_count.x, _count.y);
            setDirty();
        });

        _parameterWindow.addEventListener("property_mode", {
            _mode = _parameterWindow.getMode();
            _particleSource.setMode(to!ParticleMode(_mode));
            setDirty();
        });

        _parameterWindow.addEventListener("property_area", {
            _area = _parameterWindow.getArea();
            _particleSource.setArea(_area.x, _area.y);
            setDirty();
        });

        _parameterWindow.addEventListener("property_distance", {
            _distance = _parameterWindow.getDistance();
            _particleSource.setDistance(_distance.x, _distance.y);
            setDirty();
        });

        _parameterWindow.addEventListener("property_spread", {
            _angle = _parameterWindow.getAngle();
            _spreadAngle = _parameterWindow.getSpreadAngle();
            _particleSource.setSpread(_angle.x, _angle.y, _spreadAngle);
            setDirty();
        });

        _parameterWindow.addEventListener("property_effect", {
            _effects.length = 0;
            foreach (EffectData effectData; _parameterWindow.getEffects()) {
                _effects ~= new EffectData(effectData);
            }
            _updateEffects();
            setDirty();
        });

        addEventListener("size", &_onSize);
        addEventListener("update", &_onUpdate);
        addEventListener("draw", &_onDraw);
        addEventListener("mousedown", &_onMouseDown);
        addEventListener("mouseup", &_onMouseUp);
        addEventListener("mouseleave", &_onMouseLeave);
        addEventListener("clickoutside", &_onMouseLeave);

        _updateEffects();
    }

    private void _updateEffects() {
        _particleSource.clearEffects();
        foreach (effect; _effects) {
            effect.apply(_particleSource);
        }
    }

    private void _onSize() {
        _player.setWidth(getWidth());
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("particle");
        node.add(_name);
        node.addNode("sprite").add(_spriteRID);
        node.addNode("blend").add(_blend);
        node.addNode("isRelativePosition").add(_isRelativePosition);
        node.addNode("isRelativeSpriteAngle").add(_isRelativeSpriteAngle);
        node.addNode("lifetime").add(_lifetime);
        node.addNode("count").add(_count);
        node.addNode("mode").add(_mode);
        node.addNode("area").add(_area);
        node.addNode("distance").add(_distance);
        node.addNode("spread").add(_angle).add(_spreadAngle);

        foreach (effect; _effects) {
            effect.save(node);
        }
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    void play(int value) {
        if (_isPlaying) {
            _isPlaying = false;
            _particleSource.stop();
        }
        else {
            _isPlaying = true;
            _particleSource.start(value);
        }
    }

    void emit() {
        _particleSource.emit();
    }

    void clear() {
        _particleSource.clear();
    }

    void setSpriteRID(string rid) {
        _zoom = 1f;
        Vec4u spriteClip;

        try {
            auto spriteRes = Atelier.etabli.getResource("sprite", rid);
            auto textureRes = Atelier.etabli.getResource("texture",
                spriteRes.farfadet.getNode("texture").get!string(0));
            string filePath = textureRes.farfadet.getNode("file").get!string(0);
            Texture texture = Texture.fromFile(textureRes.getPath(filePath));

            if (spriteRes.farfadet.hasNode("clip")) {
                spriteClip = spriteRes.farfadet.getNode("clip").get!Vec4u(0);
            }

            _particleSource.setSprite(new Sprite(texture, spriteClip));
        }
        catch (Exception e) {
            return;
        }
    }

    private void _onUpdate() {
        Vec2f offset = getCenter() + _position + Vec2f(0f, _player.getHeight() / -2f);
        _particleSource.update(offset);
        _particleSource.position = offset;
    }

    private void _onMouseLeave() {
        removeEventListener("mousemove", &_onDrag);
    }

    private void _onMouseDown() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            addEventListener("mousemove", &_onDrag);
            break;
        default:
            break;
        }
    }

    private void _onMouseUp() {
        InputEvent.MouseButton ev = getManager().input.asMouseButton();
        switch (ev.button) with (InputEvent.MouseButton.Button) {
        case right:
            removeEventListener("mousemove", &_onDrag);
            break;
        default:
            break;
        }
    }

    private void _onDrag() {
        UIManager manager = getManager();
        InputEvent.MouseMotion ev = manager.input.asMouseMotion();
        _position += ev.deltaPosition;
    }

    private void _onDraw() {
        Vec2f center = getCenter() + _position + Vec2f(0f, _player.getHeight() / -2f);
        Atelier.renderer.drawLine(Vec2f(0f, center.y), Vec2f(getWidth(), center.y), Color.red, 1f);

        Atelier.renderer.drawLine(Vec2f(center.x, 0f), Vec2f(center.x,
                getHeight()), Color.red, 1f);

        _particleSource.draw(Vec2f.zero);
    }
}

private final class MediaPlayer : UIElement {
    private {
        ParticleResourceEditor _editor;
        Container _container;
        IconButton _playBtn, _emitBtn, _clearBtn;
        IntegerField _delayField;
    }

    this(ParticleResourceEditor editor) {
        _editor = editor;
        setSize(Vec2f(editor.getWidth(), 200f));
        setAlign(UIAlignX.center, UIAlignY.bottom);

        _container = new Container;
        _container.setSize(getSize());
        addUI(_container);

        HBox hbox = new HBox;
        hbox.setAlign(UIAlignX.center, UIAlignY.center);
        hbox.setSpacing(32f);
        addUI(hbox);

        {
            VBox vbox = new VBox;
            vbox.setChildAlign(UIAlignX.left);
            hbox.addUI(vbox);

            vbox.addUI(new Label("Délai:", Atelier.theme.font));

            _delayField = new IntegerField;
            _delayField.setMinValue(1);
            vbox.addUI(_delayField);
        }

        _playBtn = new IconButton("editor:play");
        _playBtn.addEventListener("click", &_onPlay);
        hbox.addUI(_playBtn);

        _emitBtn = new IconButton("editor:play-once");
        _emitBtn.addEventListener("click", &_onEmit);
        hbox.addUI(_emitBtn);

        _clearBtn = new IconButton("editor:clear");
        _clearBtn.addEventListener("click", &_onClear);
        hbox.addUI(_clearBtn);

        addEventListener("size", &_onSize);
        addEventListener("update", &_onUpdate);
    }

    private void _onSize() {
        _container.setSize(getSize());
    }

    private void _onUpdate() {
        if (Atelier.input.isDown(InputEvent.KeyButton.Button.space)) {
            _onPlay();
        }
    }

    private void _onPlay() {
        _editor.play(_delayField.value);
        if (_editor.isPlaying) {
            _playBtn.setIcon("editor:pause");
        }
        else {
            _playBtn.setIcon("editor:play");
        }
    }

    private void _onEmit() {
        _editor.emit();
    }

    private void _onClear() {
        _editor.clear();
    }
}

private final class ParameterWindow : UIElement {
    private {
        RessourceButton _spriteSelect;
        SelectButton _blendSelect;
        Checkbox _isRelativePositionCB;
        Checkbox _isRelativeSpriteAngleCB;
        IntegerField _minLifetimeField;
        IntegerField _maxLifetimeField;
        IntegerField _minCountField;
        IntegerField _maxCountField;
        SelectButton _modeSelect;
        NumberField _widthField;
        NumberField _heightField;
        NumberField _minDistanceField;
        NumberField _maxDistanceField;
        NumberField _minAngleField;
        NumberField _maxAngleField;
        NumberField _spreadAngleField;
        VList _effectsList;
    }

    this(string spriteRID, string blend, bool isRelativePosition, bool isRelativeSpriteAngle,
        Vec2u lifetime, Vec2u count, string mode, Vec2f area, Vec2f distance,
        Vec2f angle, float spreadAngle, EffectData[] effects) {
        VList vlist = new VList;
        vlist.setPosition(Vec2f(8f, 8f));
        vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        vlist.setAlign(UIAlignX.left, UIAlignY.top);
        vlist.setColor(Atelier.theme.surface);
        vlist.setSpacing(8f);
        vlist.setChildAlign(UIAlignX.left);
        addUI(vlist);

        {
            LabelSeparator sep = new LabelSeparator("Propriétés", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Texture:", Atelier.theme.font));

            _spriteSelect = new RessourceButton(spriteRID, "sprite", ["sprite"]);
            _spriteSelect.addEventListener("value", {
                dispatchEvent("property_spriteRID", false);
            });
            hlayout.addUI(_spriteSelect);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Composition:", Atelier.theme.font));

            _blendSelect = new SelectButton([__traits(allMembers, Blend)], blend);
            _blendSelect.setWidth(200f);
            _blendSelect.addEventListener("value", {
                dispatchEvent("property_blend", false);
            });
            hlayout.addUI(_blendSelect);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Position relative ?", Atelier.theme.font));

            _isRelativePositionCB = new Checkbox(isRelativePosition);
            _isRelativePositionCB.addEventListener("value", {
                dispatchEvent("property_relativePosition", false);
            });
            hlayout.addUI(_isRelativePositionCB);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Angle du sprite relatif ?", Atelier.theme.font));

            _isRelativeSpriteAngleCB = new Checkbox(isRelativeSpriteAngle);
            _isRelativeSpriteAngleCB.addEventListener("value", {
                dispatchEvent("property_relativeSpriteAngle", false);
            });
            hlayout.addUI(_isRelativeSpriteAngleCB);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Durée de vie (min):", Atelier.theme.font));

            _minLifetimeField = new IntegerField();
            _minLifetimeField.value = lifetime.x;
            _minLifetimeField.addEventListener("value", {
                dispatchEvent("property_lifetime", false);
            });
            hlayout.addUI(_minLifetimeField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Durée de vie (max):", Atelier.theme.font));

            _maxLifetimeField = new IntegerField();
            _maxLifetimeField.value = lifetime.y;
            _maxLifetimeField.addEventListener("value", {
                dispatchEvent("property_lifetime", false);
            });
            hlayout.addUI(_maxLifetimeField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Quantité par itér. (min):", Atelier.theme.font));

            _minCountField = new IntegerField();
            _minCountField.value = count.x;
            _minCountField.addEventListener("value", {
                dispatchEvent("property_count", false);
            });
            hlayout.addUI(_minCountField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Quantité par itér. (max):", Atelier.theme.font));

            _maxCountField = new IntegerField();
            _maxCountField.value = count.y;
            _maxCountField.addEventListener("value", {
                dispatchEvent("property_count", false);
            });
            hlayout.addUI(_maxCountField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Mode:", Atelier.theme.font));

            _modeSelect = new SelectButton([__traits(allMembers, ParticleMode)], mode);
            _modeSelect.setWidth(200f);
            _modeSelect.addEventListener("value", {
                _updateMode();
                dispatchEvent("property_mode", false);
            });
            hlayout.addUI(_modeSelect);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Largeur:", Atelier.theme.font));

            _widthField = new NumberField();
            _widthField.value = area.x;
            _widthField.addEventListener("value", {
                dispatchEvent("property_area", false);
            });
            hlayout.addUI(_widthField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Hauteur:", Atelier.theme.font));

            _heightField = new NumberField();
            _heightField.value = area.y;
            _heightField.addEventListener("value", {
                dispatchEvent("property_area", false);
            });
            hlayout.addUI(_heightField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Distance (min):", Atelier.theme.font));

            _minDistanceField = new NumberField();
            _minDistanceField.value = distance.x;
            _minDistanceField.addEventListener("value", {
                dispatchEvent("property_distance", false);
            });
            hlayout.addUI(_minDistanceField);
        }
        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Distance (max):", Atelier.theme.font));

            _maxDistanceField = new NumberField();
            _maxDistanceField.value = distance.y;
            _maxDistanceField.addEventListener("value", {
                dispatchEvent("property_distance", false);
            });
            hlayout.addUI(_maxDistanceField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Angle (min):", Atelier.theme.font));

            _minAngleField = new NumberField();
            _minAngleField.value = angle.x;
            _minAngleField.addEventListener("value", {
                dispatchEvent("property_spread", false);
            });
            hlayout.addUI(_minAngleField);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Angle (max):", Atelier.theme.font));

            _maxAngleField = new NumberField();
            _maxAngleField.value = angle.y;
            _maxAngleField.addEventListener("value", {
                dispatchEvent("property_spread", false);
            });
            hlayout.addUI(_maxAngleField);
        }
        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Écart:", Atelier.theme.font));

            _spreadAngleField = new NumberField();
            _spreadAngleField.value = spreadAngle;
            _spreadAngleField.addEventListener("value", {
                dispatchEvent("property_spread", false);
            });
            hlayout.addUI(_spreadAngleField);
        }

        {
            LabelSeparator sep = new LabelSeparator("Effets", Atelier.theme.font);
            sep.setColor(Atelier.theme.neutral);
            sep.setPadding(Vec2f(284f, 0f));
            sep.setSpacing(8f);
            sep.setLineWidth(1f);
            vlist.addList(sep);
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(284f, 0f));
            vlist.addList(hlayout);

            hlayout.addUI(new Label("Effets:", Atelier.theme.font));

            _effectsList = new VList;
            _effectsList.setSize(Vec2f(300f, 500f));

            AccentButton addBtn = new AccentButton("Ajouter");
            addBtn.addEventListener("click", {
                EditEffect modal = new EditEffect();
                modal.addEventListener("effect.new", {
                    auto elt = new EffectElement(this, modal.getData());
                    _effectsList.addList(elt);
                    elt.addEventListener("effect", {
                        dispatchEvent("property_effect", false);
                    });
                    dispatchEvent("property_effect", false);
                    Atelier.ui.popModalUI();
                });
                Atelier.ui.pushModalUI(modal);
            });
            hlayout.addUI(addBtn);

            vlist.addList(_effectsList);

            foreach (effect; effects) {
                auto elt = new EffectElement(this, effect);
                elt.addEventListener("effect", {
                    dispatchEvent("property_effect", false);
                });
                _effectsList.addList(elt);
            }
        }

        _updateMode();

        addEventListener("size", {
            vlist.setSize(Vec2f.zero.max(getSize() - Vec2f(8f, 8f)));
        });

        addEventListener("draw", {
            Atelier.renderer.drawRect(Vec2f.zero, getSize(), Atelier.theme.surface, 1f, true);
        });
    }

    private void _updateMode() {
        switch (_modeSelect.value) {
        case "spread":
            _widthField.isEnabled = false;
            _heightField.isEnabled = false;
            _minDistanceField.isEnabled = true;
            _maxDistanceField.isEnabled = true;
            _minAngleField.isEnabled = true;
            _maxAngleField.isEnabled = true;
            _spreadAngleField.isEnabled = true;
            break;
        case "rectangle":
            _widthField.isEnabled = true;
            _heightField.isEnabled = true;
            _minDistanceField.isEnabled = false;
            _maxDistanceField.isEnabled = false;
            _minAngleField.isEnabled = false;
            _maxAngleField.isEnabled = false;
            _spreadAngleField.isEnabled = false;
            break;
        case "ellipsis":
            _widthField.isEnabled = true;
            _heightField.isEnabled = true;
            _minDistanceField.isEnabled = false;
            _maxDistanceField.isEnabled = false;
            _minAngleField.isEnabled = false;
            _maxAngleField.isEnabled = false;
            _spreadAngleField.isEnabled = false;
            break;
        default:
            _widthField.isEnabled = false;
            _heightField.isEnabled = false;
            _minDistanceField.isEnabled = false;
            _maxDistanceField.isEnabled = false;
            _minAngleField.isEnabled = false;
            _maxAngleField.isEnabled = false;
            _spreadAngleField.isEnabled = false;
            break;
        }
    }

    string getSpriteRID() const {
        return _spriteSelect.getName();
    }

    string getBlend() const {
        return _blendSelect.value();
    }

    bool isRelativePosition() const {
        return _isRelativePositionCB.value();
    }

    bool isRelativeSpriteAngle() const {
        return _isRelativeSpriteAngleCB.value();
    }

    Vec2u getLifetime() const {
        return Vec2u(_minLifetimeField.value(), _maxLifetimeField.value());
    }

    Vec2u getCount() const {
        return Vec2u(_minCountField.value(), _maxCountField.value());
    }

    string getMode() const {
        return _modeSelect.value();
    }

    Vec2f getArea() const {
        return Vec2f(_widthField.value(), _heightField.value());
    }

    Vec2f getDistance() const {
        return Vec2f(_minDistanceField.value(), _maxDistanceField.value());
    }

    Vec2f getAngle() const {
        return Vec2f(_minAngleField.value(), _maxAngleField.value());
    }

    float getSpreadAngle() const {
        return _spreadAngleField.value();
    }

    EffectData[] getEffects() {
        EffectElement[] elements = cast(EffectElement[]) _effectsList.getList();
        EffectData[] effects;
        foreach (EffectElement elt; elements) {
            effects ~= elt.getData();
        }
        return effects;
    }

    private void moveUp(EffectElement item_) {
        EffectElement[] elements = cast(EffectElement[]) _effectsList.getList();
        _effectsList.clearList();

        for (size_t i = 1; i < elements.length; ++i) {
            if (elements[i] == item_) {
                elements[i] = elements[i - 1];
                elements[i - 1] = item_;
                break;
            }
        }

        foreach (EffectElement element; elements) {
            _effectsList.addList(element);
        }
    }

    private void moveDown(EffectElement item_) {
        EffectElement[] elements = cast(EffectElement[]) _effectsList.getList();
        _effectsList.clearList();

        for (size_t i = 0; (i + 1) < elements.length; ++i) {
            if (elements[i] == item_) {
                elements[i] = elements[i + 1];
                elements[i + 1] = item_;
                break;
            }
        }

        foreach (EffectElement element; elements) {
            _effectsList.addList(element);
        }
    }
}

private final class EffectData {
    string type;
    uint startFrame, endFrame;
    Color colorA, colorB;
    Vec2f vecA, vecB;
    float valA, valB;
    string spline;
    bool isInterval;

    this() {

    }

    this(Farfadet ffd) {
        type = ffd.name;

        foreach (node; ffd.getNodes()) {
            switch (node.name) {
            case "frame":
                startFrame = node.get!uint(0);
                endFrame = startFrame;
                isInterval = false;
                break;
            case "frames":
                startFrame = node.get!uint(0);
                endFrame = node.get!uint(1);
                isInterval = true;
                break;
            case "spline":
                spline = node.get!string(0);
                break;
            case "start":
            case "min":
                switch (type) {
                case "scale":
                    vecA = Vec2f(node.get!float(0), node.get!float(1));
                    break;
                case "color":
                    colorA = Color(node.get!float(0), node.get!float(1), node.get!float(2));
                    break;
                default:
                    valA = node.get!float(0);
                    break;
                }
                break;
            case "end":
            case "max":
                switch (type) {
                case "scale":
                    vecB = Vec2f(node.get!float(0), node.get!float(1));
                    break;
                case "color":
                    colorB = Color(node.get!float(0), node.get!float(1), node.get!float(2));
                    break;
                default:
                    valB = node.get!float(0);
                    break;
                }
                break;
            default:
                break;
            }
        }
    }

    this(EffectData data) {
        type = data.type;
        startFrame = data.startFrame;
        endFrame = data.endFrame;
        colorA = data.colorA;
        colorB = data.colorB;
        vecA = data.vecA;
        vecB = data.vecB;
        valA = data.valA;
        valB = data.valB;
        spline = data.spline;
        isInterval = data.isInterval;
    }

    private void apply(ParticleSource source) {
        ParticleEffect effect;
        if (isInterval) {
            SplineFunc splineFunc = getSplineFunc(to!Spline(spline));

            switch (type) {
            case "speed":
                effect = new SpeedIntervalParticleEffect(valA, valB, splineFunc);
                break;
            case "angle":
                effect = new AngleIntervalParticleEffect(valA, valB, splineFunc);
                break;
            case "spin":
                effect = new SpinIntervalParticleEffect(valA, valB, splineFunc);
                break;
            case "pivotAngle":
                effect = new PivotAngleIntervalParticleEffect(valA, valB, splineFunc);
                break;
            case "pivotSpin":
                effect = new PivotSpinIntervalParticleEffect(valA, valB, splineFunc);
                break;
            case "pivotDistance":
                effect = new PivotDistanceIntervalParticleEffect(valA, valB, splineFunc);
                break;
            case "spriteAngle":
                effect = new SpriteAngleIntervalParticleEffect(valA, valB, splineFunc);
                break;
            case "spriteSpin":
                effect = new SpriteSpinIntervalParticleEffect(valA, valB, splineFunc);
                break;
            case "scale":
                effect = new ScaleIntervalParticleEffect(vecA, vecB, splineFunc);
                break;
            case "color":
                effect = new ColorIntervalParticleEffect(colorA, colorB, splineFunc);
                break;
            case "alpha":
                effect = new AlphaIntervalParticleEffect(valA, valB, splineFunc);
                break;
            default:
                break;
            }
        }
        else {
            switch (type) {
            case "speed":
                effect = new SpeedParticleEffect(valA, valB);
                break;
            case "angle":
                effect = new AngleParticleEffect(valA, valB);
                break;
            case "spin":
                effect = new SpinParticleEffect(valA, valB);
                break;
            case "pivotAngle":
                effect = new PivotAngleParticleEffect(valA, valB);
                break;
            case "pivotSpin":
                effect = new PivotSpinParticleEffect(valA, valB);
                break;
            case "pivotDistance":
                effect = new PivotDistanceParticleEffect(valA, valB);
                break;
            case "spriteAngle":
                effect = new SpriteAngleParticleEffect(valA, valB);
                break;
            case "spriteSpin":
                effect = new SpriteSpinParticleEffect(valA, valB);
                break;
            case "scale":
                effect = new ScaleParticleEffect(vecA, vecB);
                break;
            case "color":
                effect = new ColorParticleEffect(colorA, colorB);
                break;
            case "alpha":
                effect = new AlphaParticleEffect(valA, valB);
                break;
            default:
                break;
            }
        }

        if (effect) {
            effect.setFrames(startFrame, endFrame);
            source.addEffect(effect);
        }
    }

    Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode(type);

        if (isInterval) {
            node.addNode("frames").add(startFrame).add(endFrame);
            node.addNode("spline").add(spline);
            switch (type) {
            case "scale":
                node.addNode("start").add(vecA);
                node.addNode("end").add(vecB);
                break;
            case "color":
                node.addNode("start").add(colorA);
                node.addNode("end").add(colorB);
                break;
            default:
                node.addNode("start").add(valA);
                node.addNode("end").add(valB);
                break;
            }
        }
        else {
            node.addNode("frame").add(startFrame);
            switch (type) {
            case "scale":
                node.addNode("min").add(vecA);
                node.addNode("max").add(vecB);
                break;
            case "color":
                node.addNode("min").add(colorA);
                node.addNode("max").add(colorB);
                break;
            default:
                node.addNode("min").add(valA);
                node.addNode("max").add(valB);
                break;
            }
        }

        return node;
    }
}

private final class EffectElement : UIElement {
    private {
        ParameterWindow _param;
        EffectData _data;
        Label _frameLabel, _typeLabel;
        Rectangle _rect;
        HBox _hbox;
        IconButton _upBtn, _downBtn;
    }

    this(ParameterWindow param, EffectData data) {
        _param = param;
        _data = new EffectData(data);
        setSize(Vec2f(300f, 48f));

        _rect = Rectangle.fill(getSize());
        _rect.anchor = Vec2f.zero;
        _rect.color = Atelier.theme.foreground;
        _rect.isVisible = false;
        addImage(_rect);

        HBox hbox = new HBox;
        hbox.setAlign(UIAlignX.left, UIAlignY.center);
        hbox.setSpacing(8f);
        addUI(hbox);

        _frameLabel = new Label("", Atelier.theme.font);
        _frameLabel.textColor = Atelier.theme.onNeutral;
        hbox.addUI(_frameLabel);

        _typeLabel = new Label("", Atelier.theme.font);
        _typeLabel.textColor = Atelier.theme.accent;
        hbox.addUI(_typeLabel);

        {
            _hbox = new HBox;
            _hbox.setAlign(UIAlignX.right, UIAlignY.center);
            _hbox.setPosition(Vec2f(12f, 0f));
            _hbox.setSpacing(2f);
            addUI(_hbox);

            _upBtn = new IconButton("editor:arrow-small-up");
            _upBtn.addEventListener("click", { _param.moveUp(this); });
            _hbox.addUI(_upBtn);

            _downBtn = new IconButton("editor:arrow-small-down");
            _downBtn.addEventListener("click", { _param.moveDown(this); });
            _hbox.addUI(_downBtn);

            _hbox.isVisible = false;
            _hbox.isEnabled = false;
        }

        _updateDisplay();

        addEventListener("mouseenter", &_onMouseEnter);
        addEventListener("mouseleave", &_onMouseLeave);
        addEventListener("click", &_onClick);
    }

    private void _onMouseEnter() {
        _rect.isVisible = true;
        _hbox.isVisible = true;
        _hbox.isEnabled = true;
    }

    private void _onMouseLeave() {
        _rect.isVisible = false;
        _hbox.isVisible = false;
        _hbox.isEnabled = false;
    }

    private void _updateDisplay() {
        if (_data.isInterval) {
            _frameLabel.text = to!string(_data.startFrame) ~ ":" ~ to!string(_data.endFrame);
        }
        else {
            _frameLabel.text = to!string(_data.startFrame);
        }
        _typeLabel.text = _data.type;
    }

    private void _onClick() {
        EditEffect modal = new EditEffect(_data);
        modal.addEventListener("effect.apply", {
            _data = modal.getData();
            if (modal.isDirty()) {
                dispatchEvent("effect", false);
            }
            _updateDisplay();
            Atelier.ui.popModalUI();
        });
        modal.addEventListener("effect.remove", {
            dispatchEvent("effect", false);
            Atelier.ui.popModalUI();
            removeUI();
        });
        Atelier.ui.pushModalUI(modal);
    }

    EffectData getData() {
        return _data;
    }
}

final class EditEffect : Modal {
    private {
        EffectData _data;
        SelectButton _typeSelector;
        TextField _pathField, _nameField;
        TabGroup _modeTab;
        VBox _vbox, _typebox;
        SplineGraph _splineGraph;
        bool _isDirty = false, _isModeInit = true, _isTypeInit = true;
    }

    this(EffectData data = null) {
        setAlign(UIAlignX.center, UIAlignY.center);
        setSize(Vec2f(500f, 400f));

        bool isNew = false;
        if (data) {
            _data = data;
        }
        else {
            _data = new EffectData;
            isNew = true;
        }

        if (isNew) {
            _isDirty = true;
        }

        {
            Label title = new Label(isNew ? "Nouvel effet" : "Éditer l’effet",
                Atelier.theme.font);
            title.setAlign(UIAlignX.center, UIAlignY.top);
            title.setPosition(Vec2f(0f, 4f));
            addUI(title);
        }

        {
            IconButton exitBtn = new IconButton("editor:exit");
            exitBtn.setAlign(UIAlignX.right, UIAlignY.top);
            exitBtn.setPosition(Vec2f(4f, 4f));
            exitBtn.addEventListener("click", &removeUI);
            addUI(exitBtn);
        }

        {
            _modeTab = new TabGroup;
            _modeTab.setAlign(UIAlignX.left, UIAlignY.top);
            _modeTab.setWidth(getWidth());
            _modeTab.setPosition(Vec2f(0f, 32f));
            addUI(_modeTab);

            _modeTab.addTab("Instantané", "instant", "");
            _modeTab.addTab("Intervalle", "interval", "");
            _modeTab.selectTab(_data.isInterval ? "interval" : "instant");

            _modeTab.addEventListener("value", &_onModeTab);
        }
        {
            HBox validationBox = new HBox;
            validationBox.setAlign(UIAlignX.right, UIAlignY.bottom);
            validationBox.setPosition(Vec2f(10f, 10f));
            validationBox.setSpacing(8f);
            addUI(validationBox);

            if (isNew) {
                NeutralButton cancelBtn = new NeutralButton("Annuler");
                cancelBtn.addEventListener("click", &removeUI);
                validationBox.addUI(cancelBtn);

                AccentButton createBtn = new AccentButton("Créer");
                createBtn.addEventListener("click", {
                    dispatchEvent("effect.new", false);
                });
                validationBox.addUI(createBtn);
            }
            else {
                DangerButton removeBtn = new DangerButton("Supprimer");
                removeBtn.addEventListener("click", {
                    dispatchEvent("effect.remove", false);
                });
                validationBox.addUI(removeBtn);

                NeutralButton cancelBtn = new NeutralButton("Annuler");
                cancelBtn.addEventListener("click", &removeUI);
                validationBox.addUI(cancelBtn);

                AccentButton applyBtn = new AccentButton("Appliquer");
                applyBtn.addEventListener("click", {
                    dispatchEvent("effect.apply", false);
                });
                validationBox.addUI(applyBtn);
            }
        }

        {
            _vbox = new VBox;
            _vbox.setAlign(UIAlignX.left, UIAlignY.top);
            _vbox.setChildAlign(UIAlignX.left);
            _vbox.setSpacing(8f);
            _vbox.setPosition(Vec2f(16f, 96f));
            addUI(_vbox);
        }

        {
            _typebox = new VBox;
            _typebox.setChildAlign(UIAlignX.left);
            _typebox.setSpacing(8f);
        }

        _onModeTab();
    }

    private void _onModeTab() {
        _data.isInterval = (_modeTab.value == "interval");
        _vbox.clearUI();

        if (_isModeInit) {
            _isModeInit = false;
        }
        else {
            _isDirty = true;
        }

        {
            HLayout hlayout = new HLayout;
            hlayout.setPadding(Vec2f(400f, 0f));
            _vbox.addUI(hlayout);

            hlayout.addUI(new Label("Type:", Atelier.theme.font));

            _typeSelector = new SelectButton([
                "speed", "angle", "spin", "pivotAngle", "pivotSpin",
                "pivotDistance", "spriteAngle", "spriteSpin", "scale", "color",
                "alpha"
            ], _data.type, true);
            _typeSelector.value = _data.type;
            _typeSelector.addEventListener("value", &_onTypeChange);
            hlayout.addUI(_typeSelector);
        }

        switch (_modeTab.value) {
        case "instant": {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(400f, 0f));
                _vbox.addUI(hlayout);

                hlayout.addUI(new Label("Trame:", Atelier.theme.font));

                IntegerField frameField = new IntegerField;
                frameField.value = _data.startFrame;
                frameField.addEventListener("value", {
                    _data.startFrame = frameField.value;
                    _isDirty = true;
                });
                hlayout.addUI(frameField);
            }
            break;
        case "interval": {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(400f, 0f));
                _vbox.addUI(hlayout);

                hlayout.addUI(new Label("Trame - début:", Atelier.theme.font));

                IntegerField startFrameField = new IntegerField;
                startFrameField.value = _data.startFrame;
                startFrameField.addEventListener("value", {
                    _data.startFrame = startFrameField.value;
                    _isDirty = true;
                });
                hlayout.addUI(startFrameField);

                hlayout.addUI(new Label("fin:", Atelier.theme.font));

                IntegerField endFrameField = new IntegerField;
                endFrameField.value = _data.endFrame;
                endFrameField.addEventListener("value", {
                    _data.endFrame = endFrameField.value;
                    _isDirty = true;
                });
                hlayout.addUI(endFrameField);
            }
            {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(400f, 0f));
                _vbox.addUI(hlayout);

                hlayout.addUI(new Label("Interpolation:", Atelier.theme.font));

                auto _splineSelector = new CarouselButton([
                    __traits(allMembers, Spline)
                ], _data.spline, false);
                _splineSelector.addEventListener("value", {
                    _isDirty = true;
                    _data.spline = _splineSelector.value;
                    _splineGraph.setSpline(_data.spline);
                });
                hlayout.addUI(_splineSelector);

                _splineGraph = new SplineGraph();
                _splineGraph.setSpline(_data.spline);
                hlayout.addUI(_splineGraph);
            }
            break;
        default:
            break;
        }

        _vbox.addUI(_typebox);
        _onTypeChange();
    }

    private void _onTypeChange() {
        _data.type = _typeSelector.value;
        _typebox.clearUI();

        if (_isTypeInit) {
            _isTypeInit = false;
        }
        else {
            _isDirty = true;
        }

        switch (_data.type) {
        case "speed":
        case "angle":
        case "spin":
        case "pivotAngle":
        case "pivotSpin":
        case "pivotDistance":
        case "spriteAngle":
        case "spriteSpin":
        case "alpha": {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(400f, 0f));
                _typebox.addUI(hlayout);

                hlayout.addUI(new Label(_data.isInterval ? "Début:" : "Minimum:",
                        Atelier.theme.font));

                NumberField valueAField = new NumberField;
                valueAField.value = _data.valA;
                valueAField.addEventListener("value", {
                    _isDirty = true;
                    _data.valA = valueAField.value;
                });
                hlayout.addUI(valueAField);

                hlayout.addUI(new Label(_data.isInterval ? "Fin:" : "Maximum:", Atelier.theme.font));

                NumberField valueBField = new NumberField;
                valueBField.value = _data.valB;
                valueBField.addEventListener("value", {
                    _isDirty = true;
                    _data.valB = valueBField.value;
                });
                hlayout.addUI(valueBField);
            }
            break;
        case "scale": {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(400f, 0f));
                _typebox.addUI(hlayout);

                hlayout.addUI(new Label(_data.isInterval ?
                        "Début - X:" : "Minimum - X:", Atelier.theme.font));

                NumberField valueAXField = new NumberField;
                valueAXField.value = _data.vecA.x;
                valueAXField.addEventListener("value", {
                    _isDirty = true;
                    _data.vecA.x = valueAXField.value;
                });
                hlayout.addUI(valueAXField);

                hlayout.addUI(new Label("Y:", Atelier.theme.font));

                NumberField valueAYField = new NumberField;
                valueAYField.value = _data.vecA.y;
                valueAYField.addEventListener("value", {
                    _isDirty = true;
                    _data.vecA.y = valueAYField.value;
                });
                hlayout.addUI(valueAYField);

                hlayout = new HLayout;
                hlayout.setPadding(Vec2f(400f, 0f));
                _typebox.addUI(hlayout);

                hlayout.addUI(new Label(_data.isInterval ?
                        "Fin      - X:" : "Maximum - X:", Atelier.theme.font));

                NumberField valueBXField = new NumberField;
                valueBXField.value = _data.vecB.x;
                valueBXField.addEventListener("value", {
                    _isDirty = true;
                    _data.vecB.x = valueBXField.value;
                });
                hlayout.addUI(valueBXField);

                hlayout.addUI(new Label("Y:", Atelier.theme.font));

                NumberField valueBYField = new NumberField;
                valueBYField.value = _data.vecB.y;
                valueBYField.addEventListener("value", {
                    _isDirty = true;
                    _data.vecB.y = valueBYField.value;
                });
                hlayout.addUI(valueBYField);
            }
            break;
        case "color": {
                HLayout hlayout = new HLayout;
                hlayout.setPadding(Vec2f(400f, 0f));
                _typebox.addUI(hlayout);

                hlayout.addUI(new Label(_data.isInterval ? "Début:" : "Minimum:",
                        Atelier.theme.font));

                ColorButton colorABtn = new ColorButton;
                colorABtn.value = _data.colorA;
                colorABtn.addEventListener("value", {
                    _isDirty = true;
                    _data.colorA = colorABtn.value;
                });
                hlayout.addUI(colorABtn);

                hlayout.addUI(new Label(_data.isInterval ? "Fin:" : "Maximum:", Atelier.theme.font));

                ColorButton colorBBtn = new ColorButton;
                colorBBtn.value = _data.colorB;
                colorBBtn.addEventListener("value", {
                    _isDirty = true;
                    _data.colorB = colorBBtn.value;
                });
                hlayout.addUI(colorBBtn);
            }
            break;
        default:
            break;
        }
    }

    EffectData getData() {
        return _data;
    }

    bool isDirty() {
        return _isDirty;
    }
}
+/
