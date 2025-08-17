module atelier.etabli.media.res.shot.editor;

import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.input;
import atelier.physics;
import atelier.ui;
import atelier.render;

import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;
import atelier.etabli.media.res.entity_render;
import atelier.etabli.media.res.shot.parameter;
import atelier.etabli.media.res.shot.toolbox;

final class ShotResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        ParameterWindow _parameterWindow;
        Toolbox _toolbox;

        EntityRenderData[] _renders;
        HitboxData _hitbox;
        HurtboxData _hurtbox;
        int _material;
        uint _bounces, _ttl;
        bool _hasBounces, _hasTtl;

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

        if (ffd.hasNode("material")) {
            _material = ffd.getNode("material").get!int(0);
        }

        if (ffd.hasNode("bounces")) {
            _bounces = ffd.getNode("bounces").get!uint(0);
            _hasBounces = true;
        }

        if (ffd.hasNode("ttl")) {
            _ttl = ffd.getNode("ttl").get!uint(0);
            _hasTtl = true;
        }

        foreach (size_t i, Farfadet renderNode; ffd.getNodes("render")) {
            EntityRenderData render = new EntityRenderData(renderNode);
            render.isVisible = (i == 0);
            _renders ~= render;
        }

        _parameterWindow = new ParameterWindow(_renders, _hitbox, _hurtbox, _bounces, _hasBounces, _ttl, _hasTtl, _material);

        _toolbox = new Toolbox();
        _toolbox.setRenders(_renders);

        _parameterWindow.addEventListener("property_hitbox", {
            _hitbox = _parameterWindow.getHitbox();
            setDirty();
        });

        _parameterWindow.addEventListener("property_hurtbox", {
            _hurtbox = _parameterWindow.getHurtbox();
            setDirty();
        });

        _parameterWindow.addEventListener("property_bounces", {
            _bounces = _parameterWindow.getBounces();
            _hasBounces = _parameterWindow.hasBounces();
            setDirty();
        });

        _parameterWindow.addEventListener("property_ttl", {
            _ttl = _parameterWindow.getTtl();
            _hasTtl = _parameterWindow.hasTtl();
            setDirty();
        });

        _parameterWindow.addEventListener("property_render", {
            _renders.length = 0;
            foreach (size_t i, EntityRenderData renderData; _parameterWindow.getRenders()) {
                EntityRenderData render = new EntityRenderData(renderData);
                render.isVisible = (i == _toolbox.getRender());
                _renders ~= render;
            }
            _toolbox.setRenders(_renders);
            setDirty();
        });

        _parameterWindow.addEventListener("property_material", {
            _material = _parameterWindow.getMaterial();
            setDirty();
        });

        _toolbox.addEventListener("toolbox", {
            foreach (size_t i, EntityRenderData render; _renders) {
                render.isVisible = (i == _toolbox.getRender());
            }
        });

        _toolbox.addEventListener("toolbox_play", {
            foreach (EntityRenderData render; _renders) {
                render.play();
            }
        });

        _toolbox.addEventListener("toolbox_pause", {
            foreach (EntityRenderData render; _renders) {
                render.pause();
            }
        });

        _toolbox.addEventListener("toolbox_stop", {
            foreach (EntityRenderData render; _renders) {
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
    }

    override Farfadet save(Farfadet ffd) {
        Farfadet node = ffd.addNode("shot").add(_name);
        foreach (EntityRenderData render; _renders) {
            render.save(node);
        }
        if (_hitbox.hasHitbox) {
            _hitbox.save(node);
        }
        _hurtbox.save(node);

        if (_hasBounces)
            node.addNode("bounces").add(_bounces);

        if (_hasTtl)
            node.addNode("ttl").add(_ttl);

        node.addNode("material").add(_material);
        return node;
    }

    override UIElement getPanel() {
        return _parameterWindow;
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
        foreach (EntityRenderData render; _renders) {
            render.update(_zoom);
        }
    }

    private void _onDraw() {
        if (_hitbox.hasHitbox) {
            Vec3f hitboxSize = (cast(Vec3f) _hitbox.size) * _zoom;
            Vec2f offset = (cast(Vec2f)(_hitbox.size.xy - (_hitbox.size.xy >> 1))) * _zoom;

            Atelier.renderer.drawRect(_originPosition + getCenter() - offset,
                hitboxSize.xy, Atelier.theme.onNeutral, 0.2f, false);

            foreach (EntityRenderData render; _renders) {
                render.draw(_originPosition + getCenter(), _toolbox.getDir());
            }

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
            foreach (EntityRenderData render; _renders) {
                render.draw(_originPosition + getCenter(), _toolbox.getDir());
            }
        }

        if (_hurtbox.type != "none") {
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
