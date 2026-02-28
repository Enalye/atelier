module atelier.etabli.media.res.entity.editor;

import std.algorithm.sorting : sort;
import std.file;
import std.path;
import std.math : abs;

import farfadet;

import atelier.common;
import atelier.core;
import atelier.physics;
import atelier.input;
import atelier.ui;
import atelier.world.entity : BaseEntityData;
import atelier.etabli.ui;
import atelier.etabli.media.res.base;
import atelier.etabli.media.res.editor;
import atelier.etabli.media.res.entity.parameter;
import atelier.etabli.media.res.entity.toolbox;
import atelier.etabli.media.res.entity.data;

final class EntityResourceEditor : ResourceBaseEditor {
    private {
        Farfadet _ffd;
        string _name;
        ParameterWindow _parameterWindow;
        Toolbox _toolbox;

        EntityRenderData[] _graphics, _auxGraphics, _auxGraphicsStack;
        ColliderData _collider;
        RepulsorData _repulsor;
        HitboxData _hitbox;
        BaseEntityData _baseEntityData;

        Vec2f _originPosition = Vec2f.zero;
        float _zoom = 1f;
    }

    this(ResourceEditor editor, string path_, Farfadet ffd, Vec2f size) {
        super(editor, path_, ffd, size);
        _ffd = ffd;

        _name = ffd.get!string(0);

        _baseEntityData.load(ffd);
        _collider.load(ffd);
        _hitbox.load(ffd);
        _repulsor.load(ffd);

        foreach (size_t i, Farfadet renderNode; ffd.getNodes("graphic")) {
            EntityRenderData render = new EntityRenderData(renderNode);
            render.isVisible = (i == 0);
            _graphics ~= render;
        }

        foreach (size_t i, Farfadet renderNode; ffd.getNodes("auxGraphic")) {
            EntityRenderData render = new EntityRenderData(renderNode);
            _auxGraphics ~= render;
        }

        _parameterWindow = new ParameterWindow(_graphics, _auxGraphics, _collider, _repulsor, _hitbox, _baseEntityData);

        _toolbox = new Toolbox();
        _toolbox.setRenders(_graphics);

        _parameterWindow.addEventListener("property_collider", {
            _collider = _parameterWindow.getCollider();
            setDirty();
        });

        _parameterWindow.addEventListener("property_repulsor", {
            _repulsor = _parameterWindow.getRepulsor();
            setDirty();
        });

        _parameterWindow.addEventListener("property_hitbox", {
            _hitbox = _parameterWindow.getHitbox();
            setDirty();
        });

        _parameterWindow.addEventListener("property_base", {
            _baseEntityData = _parameterWindow.getBaseEntityData();
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
        Farfadet node = ffd.addNode("entity").add(_name);

        _baseEntityData.save(node);
        _collider.save(node);
        _hitbox.save(node);
        _repulsor.save(node);

        foreach (EntityRenderData render; _graphics) {
            render.save(node);
        }
        foreach (EntityRenderData render; _auxGraphics) {
            render.save(node);
        }
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
        if (_collider.type != ColliderData.Type.none) {
            Vec3f colliderSize = (cast(Vec3f) _collider.size) * _zoom;
            Vec2f offset = (cast(Vec2f)(_collider.size.xy - (_collider.size.xy >> 1))) * _zoom;

            Atelier.renderer.drawRect(_originPosition + getCenter() - offset,
                colliderSize.xy, Atelier.theme.onNeutral, 0.2f, false);

            _render();

            Atelier.renderer.drawRect(_originPosition + getCenter() - (offset + Vec2f(0f,
                    colliderSize.z)), colliderSize.xy, Color.yellow, 0.2f, true);

            Atelier.renderer.drawRect(_originPosition + getCenter() + Vec2f(0f,
                    colliderSize.y) - (offset + Vec2f(0f, colliderSize.z)),
                colliderSize.xz, Color.orange, 0.2f, true);

            Atelier.renderer.drawRect(_originPosition + getCenter() - (offset + Vec2f(0f,
                    colliderSize.z)), colliderSize.xy, Atelier.theme.onNeutral, 1f, false);

            Atelier.renderer.drawRect(_originPosition + getCenter() - (offset + Vec2f(0f,
                    colliderSize.z)), colliderSize.xy + Vec2f(0f, colliderSize.z),
                Atelier.theme.onNeutral, 1f, false);
        }
        else {
            _render();
        }

        if (_hitbox.hasHitbox) {
            Vec2f hitOrigin = _originPosition + getCenter() + Vec2f.angled(
                degToRad(cast(float) _hitbox.offsetAngle)) * _hitbox.offsetDist * _zoom;

            bool hasAngles = (_hitbox.angleDelta > 0 && _hitbox.angleDelta < 180);
            int startAngle, endAngle;
            if (hasAngles) {
                startAngle = _hitbox.angle - _hitbox.angleDelta;
                endAngle = _hitbox.angle + _hitbox.angleDelta;
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
                    hitOrigin + (a + Vec2f(0f, -height)) * _zoom,
                    hitOrigin + (b + Vec2f(0f, -height)) * _zoom,
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

                    drawCurve(currentAngle, currentEnd, _hitbox.minRadius, 0);
                    drawCurve(currentAngle, currentEnd, _hitbox.maxRadius, 0);
                    drawCurve(currentAngle, currentEnd, _hitbox.minRadius, _hitbox.height);
                    drawCurve(currentAngle, currentEnd, _hitbox.maxRadius, _hitbox.height);

                    currentAngle = currentEnd;
                }

                if ((endAngle - currentAngle) > 0) {
                    drawCurve(currentAngle, endAngle, _hitbox.minRadius, 0);
                    drawCurve(currentAngle, endAngle, _hitbox.maxRadius, 0);
                    drawCurve(currentAngle, endAngle, _hitbox.minRadius, _hitbox.height);
                    drawCurve(currentAngle, endAngle, _hitbox.maxRadius, _hitbox.height);
                }

                if (!hasAngles || (0 > startAngle && 0 < endAngle) || (360 > startAngle && 360 < endAngle)) {
                    drawAngleHeightLine(0f, _hitbox.minRadius, _hitbox.height);
                    drawAngleHeightLine(0f, _hitbox.maxRadius, _hitbox.height);
                }

                if (!hasAngles || (180 > startAngle && 180 < endAngle)) {
                    drawAngleHeightLine(180f, _hitbox.minRadius, _hitbox.height);
                    drawAngleHeightLine(180f, _hitbox.maxRadius, _hitbox.height);
                }

                if (hasAngles) {
                    drawAngleLine(startAngle, _hitbox.minRadius, _hitbox.maxRadius, 0);
                    drawAngleLine(endAngle, _hitbox.minRadius, _hitbox.maxRadius, 0);
                    drawAngleLine(startAngle, _hitbox.minRadius, _hitbox.maxRadius, _hitbox
                            .height);
                    drawAngleLine(endAngle, _hitbox.minRadius, _hitbox.maxRadius, _hitbox.height);

                    drawAngleHeightLine(startAngle, _hitbox.minRadius, _hitbox.height);
                    drawAngleHeightLine(startAngle, _hitbox.maxRadius, _hitbox.height);
                    drawAngleHeightLine(endAngle, _hitbox.minRadius, _hitbox.height);
                    drawAngleHeightLine(endAngle, _hitbox.maxRadius, _hitbox.height);
                }
            }
        }
    }
}
