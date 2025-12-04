module atelier.etabli.media.res.prop.editor;

import std.algorithm.sorting : sort;
import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.physics;
import atelier.ui;
import atelier.world.entity : BaseEntityData;
import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;
import atelier.etabli.media.res.entity_base;
import atelier.etabli.media.res.prop.parameter;
import atelier.etabli.media.res.prop.toolbox;

final class PropResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        ParameterWindow _parameterWindow;
        Toolbox _toolbox;

        EntityRenderData[] _graphics, _auxGraphics, _auxGraphicsStack;
        HitboxData _hitbox;
        HurtboxData _hurtbox;
        BaseEntityData _baseEntityData;
        int _material;

        Vec2f _originPosition = Vec2f.zero;
        float _zoom = 1f;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        if (ffd.hasNode("hitbox")) {
            _hitbox.load(ffd.getNode("hitbox"));
        }

        if (ffd.hasNode("hurtbox")) {
            _hurtbox.load(ffd.getNode("hurtbox"));
        }

        _baseEntityData.load(ffd);

        if (ffd.hasNode("material")) {
            _material = ffd.getNode("material").get!int(0);
        }

        foreach (size_t i, Farfadet renderNode; ffd.getNodes("graphic")) {
            EntityRenderData render = new EntityRenderData(renderNode);
            render.isVisible = (i == 0);
            _graphics ~= render;
        }

        foreach (size_t i, Farfadet renderNode; ffd.getNodes("auxGraphic")) {
            EntityRenderData render = new EntityRenderData(renderNode);
            _auxGraphics ~= render;
        }

        _parameterWindow = new ParameterWindow(_graphics, _auxGraphics, _hitbox, _hurtbox, _baseEntityData, _material);

        _toolbox = new Toolbox();
        _toolbox.setRenders(_graphics);

        _parameterWindow.addEventListener("property_hitbox", {
            _hitbox = _parameterWindow.getHitbox();
            setDirty();
        });

        _parameterWindow.addEventListener("property_hurtbox", {
            _hurtbox = _parameterWindow.getHurtbox();
            setDirty();
        });

        _parameterWindow.addEventListener("property_render", {
            _graphics.length = 0;
            foreach (size_t i, EntityRenderData renderData; _parameterWindow.getRenders()) {
                _graphics ~= new EntityRenderData(renderData);
            }
            _toolbox.setRenders(_graphics);
            _onToolbox();
            setDirty();
        });

        _parameterWindow.addEventListener("property_auxGraphic", {
            _auxGraphics.length = 0;
            foreach (size_t i, EntityRenderData renderData; _parameterWindow.getAuxRenders()) {
                _auxGraphics ~= new EntityRenderData(renderData);
            }
            _onToolbox();
            setDirty();
        });

        _parameterWindow.addEventListener("property_base", {
            _baseEntityData = _parameterWindow.getBaseEntityData();
            setDirty();
        });

        _parameterWindow.addEventListener("property_material", {
            _material = _parameterWindow.getMaterial();
            setDirty();
        });

        _toolbox.addEventListener("toolbox", &_onToolbox);

        _toolbox.addEventListener("toolbox_play", {
            foreach (EntityRenderData render; _graphics) {
                render.play();
            }
            foreach (EntityRenderData render; _auxGraphics) {
                render.play();
            }
        });

        _toolbox.addEventListener("toolbox_pause", {
            foreach (EntityRenderData render; _graphics) {
                render.pause();
            }
            foreach (EntityRenderData render; _auxGraphics) {
                render.pause();
            }
        });

        _toolbox.addEventListener("toolbox_stop", {
            foreach (EntityRenderData render; _graphics) {
                render.stop();
            }
            foreach (EntityRenderData render; _auxGraphics) {
                render.stop();
            }
        });

        addEventListener("update", &_onUpdate);
        addEventListener("draw", &_onDraw);
        addEventListener("wheel", &_onWheel);
        addEventListener("mousedown", &_onMouseDown);
        addEventListener("mouseup", &_onMouseUp);
        addEventListener("mouseleave", {
            removeEventListener("mousemove", &_onDrag);
        });
        addEventListener("register", { Atelier.ui.addUI(_toolbox); });
        addEventListener("unregister", { _toolbox.removeUI(); });

        _onToolbox();
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("prop").add(_name);
        foreach (EntityRenderData render; _graphics) {
            render.save(node);
        }
        foreach (EntityRenderData render; _auxGraphics) {
            render.save(node);
        }
        if (_hitbox.hasHitbox) {
            _hitbox.save(node);
        }
        _hurtbox.save(node);
        _baseEntityData.save(node);
        node.addNode("material").add(_material);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
    }

    private void _onToolbox() {
        EntityRenderData mainRenderData;
        foreach (size_t i, EntityRenderData render; _graphics) {
            render.isVisible = (i == _toolbox.getRender());
            if (render.isVisible) {
                mainRenderData = render;
            }
        }

        _auxGraphicsStack.length = 0;
        foreach (size_t i, EntityRenderData render; _auxGraphics) {
            if (mainRenderData) {
                render.isVisible = mainRenderData && mainRenderData.hasAuxGraphic(render.name);
                if (render.isVisible) {
                    _auxGraphicsStack ~= render;
                }
            }
            else {
                render.isVisible = false;
            }
        }
        _auxGraphicsStack.sort!((a, b) => a.order < b.order)();
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
        _originPosition += ev.deltaPosition;
    }

    private void _onWheel() {
        UIManager manager = getManager();
        InputEvent.MouseWheel ev = manager.input.asMouseWheel();
        float zoomDelta = 1f + (ev.wheel.sum() * 0.25f);

        Vec2f mouseOffset = getMousePosition() - getCenter();
        Vec2f delta = (mouseOffset - _originPosition) / _zoom;
        _zoom *= zoomDelta;
        Vec2f delta2 = (mouseOffset - _originPosition) / _zoom;

        _originPosition += (delta2 - delta) * _zoom;
    }

    private void _onUpdate() {
        foreach (EntityRenderData render; _graphics) {
            render.setZoom(_zoom);
            render.update();
        }
        foreach (EntityRenderData render; _auxGraphics) {
            render.setZoom(_zoom);
            render.update();
        }
    }

    private void _render() {
        Vec2f graphicOffset = _originPosition + getCenter();

        if (_auxGraphicsStack.length) {
            foreach (EntityRenderData render; _auxGraphicsStack) {
                if (render.getIsBehind()) {
                    render.draw(graphicOffset, _toolbox.getDir());
                }
            }

            foreach (EntityRenderData render; _graphics) {
                render.draw(graphicOffset, _toolbox.getDir());
            }

            foreach (EntityRenderData render; _auxGraphicsStack) {
                if (!render.getIsBehind()) {
                    render.draw(graphicOffset, _toolbox.getDir());
                }
            }
        }
        else {
            foreach (EntityRenderData render; _graphics) {
                render.draw(graphicOffset, _toolbox.getDir());
            }
        }
    }

    private void _onDraw() {
        if (_hitbox.hasHitbox) {
            Vec3f hitboxSize = (cast(Vec3f) _hitbox.size) * _zoom;
            Vec2f offset = (cast(Vec2f)(_hitbox.size.xy - (_hitbox.size.xy >> 1))) * _zoom;

            Atelier.renderer.drawRect(_originPosition + getCenter() - offset,
                hitboxSize.xy, Atelier.theme.onNeutral, 0.2f, false);

            _render();

            Atelier.renderer.drawRect(_originPosition + getCenter() - (offset + Vec2f(0f,
                    hitboxSize.z)), hitboxSize.xy, Color.yellow, 0.2f, true);

            Atelier.renderer.drawRect(_originPosition + getCenter() + Vec2f(0f,
                    hitboxSize.y) - (offset + Vec2f(0f, hitboxSize.z)),
                hitboxSize.xz, Color.orange, 0.2f, true);

            Atelier.renderer.drawRect(_originPosition + getCenter() - (offset + Vec2f(0f,
                    hitboxSize.z)), hitboxSize.xy, Atelier.theme.onNeutral, 1f, false);

            Atelier.renderer.drawRect(_originPosition + getCenter() - (offset + Vec2f(0f,
                    hitboxSize.z)), hitboxSize.xy + Vec2f(0f, hitboxSize.z),
                Atelier.theme.onNeutral, 1f, false);
        }
        else {
            _render();
        }

        if (_hurtbox.hasHurtbox) {
            Vec2f hurtOrigin = _originPosition + getCenter() + Vec2f.angled(
                degToRad(cast(float) _hurtbox.offsetAngle)) * _hurtbox.offsetDist * _zoom;

            bool hasAngles = (_hurtbox.angleDelta > 0 && _hurtbox.angleDelta < 180);
            int startAngle, endAngle;
            if (hasAngles) {
                startAngle = _hurtbox.angle - _hurtbox.angleDelta;
                endAngle = _hurtbox.angle + _hurtbox.angleDelta;
            }
            else {
                startAngle = 0;
                endAngle = 360;
            }

            int deltaAngle = abs(endAngle - startAngle);
            if (deltaAngle > 360) {
                startAngle = 0;
                endAngle = 360;
                deltaAngle = 360;
                hasAngles = false;
            }

            void drawLine(Vec2f a, Vec2f b, float height) {
                Atelier.renderer.drawLine(
                    hurtOrigin + (a + Vec2f(0f, -height)) * _zoom,
                    hurtOrigin + (b + Vec2f(0f, -height)) * _zoom,
                    Color.red, 1f);
            }

            void drawCurve(float startAngle, float endAngle, float dist, float height) {
                Vec2f a = Vec2f.angled(degToRad(cast(float) startAngle)) * dist;
                Vec2f b = Vec2f.angled(degToRad(cast(float) endAngle)) * dist;
                drawLine(a, b, height);
            }

            void drawAngleLine(float angle, float startDist, float endDist, float height) {
                Vec2f a = Vec2f.angled(degToRad(cast(float) angle)) * startDist;
                Vec2f b = Vec2f.angled(degToRad(cast(float) angle)) * endDist;
                drawLine(a, b, height);
            }

            void drawAngleHeightLine(float angle, float dist, float height) {
                Vec2f a = Vec2f.angled(degToRad(cast(float) angle)) * dist;
                Vec2f b = a + Vec2f(0f, -height);
                drawLine(a, b, 0);
            }

            {
                int segments = deltaAngle / 5;
                int currentAngle = startAngle;
                for (int i; i < segments; ++i) {
                    int currentEnd = currentAngle + 5;

                    drawCurve(currentAngle, currentEnd, _hurtbox.minRadius, 0);
                    drawCurve(currentAngle, currentEnd, _hurtbox.maxRadius, 0);
                    drawCurve(currentAngle, currentEnd, _hurtbox.minRadius, _hurtbox.height);
                    drawCurve(currentAngle, currentEnd, _hurtbox.maxRadius, _hurtbox.height);

                    currentAngle = currentEnd;
                }

                if ((endAngle - currentAngle) > 0) {
                    drawCurve(currentAngle, endAngle, _hurtbox.minRadius, 0);
                    drawCurve(currentAngle, endAngle, _hurtbox.maxRadius, 0);
                    drawCurve(currentAngle, endAngle, _hurtbox.minRadius, _hurtbox.height);
                    drawCurve(currentAngle, endAngle, _hurtbox.maxRadius, _hurtbox.height);
                }

                if (!hasAngles || (0 > startAngle && 0 < endAngle) || (360 > startAngle && 360 < endAngle)) {
                    drawAngleHeightLine(0f, _hurtbox.minRadius, _hurtbox.height);
                    drawAngleHeightLine(0f, _hurtbox.maxRadius, _hurtbox.height);
                }

                if (!hasAngles || (180 > startAngle && 180 < endAngle)) {
                    drawAngleHeightLine(180f, _hurtbox.minRadius, _hurtbox.height);
                    drawAngleHeightLine(180f, _hurtbox.maxRadius, _hurtbox.height);
                }

                if (hasAngles) {
                    drawAngleLine(startAngle, _hurtbox.minRadius, _hurtbox.maxRadius, 0);
                    drawAngleLine(endAngle, _hurtbox.minRadius, _hurtbox.maxRadius, 0);
                    drawAngleLine(startAngle, _hurtbox.minRadius, _hurtbox.maxRadius, _hurtbox
                            .height);
                    drawAngleLine(endAngle, _hurtbox.minRadius, _hurtbox.maxRadius, _hurtbox.height);

                    drawAngleHeightLine(startAngle, _hurtbox.minRadius, _hurtbox.height);
                    drawAngleHeightLine(startAngle, _hurtbox.maxRadius, _hurtbox.height);
                    drawAngleHeightLine(endAngle, _hurtbox.minRadius, _hurtbox.height);
                    drawAngleHeightLine(endAngle, _hurtbox.maxRadius, _hurtbox.height);
                }
            }
        }
    }
}
