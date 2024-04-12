/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.render.renderer;

import std.exception : enforce;

import bindbc.sdl;

import atelier.common, atelier.core;

import atelier.render.canvas;
import atelier.render.sprite;
import atelier.render.util;

final class Renderer {
    private {
        SDL_Renderer* _sdlRenderer;

        final class CanvasContext {
            Canvas canvas;
            Vec4u clip;
        }

        CanvasContext[] _canvases;
        int _idxContext = -1;

        Vec2i _windowSize;

        Vec2i _kernelSize;
        Canvas _kernelCanvas;
        Sprite _kernelSprite;
        int _pixelSharpness = 1;
        Canvas _scaledCanvas;
        Sprite _scaledSprite;

        Scaling _scaling = Scaling.stretch;
        Vec2f _scaledSizeStart = Vec2f.zero, _scaledSizeEnd = Vec2f.zero;
        Timer _scaleTimer;
    }

    enum Scaling {
        none,
        integer,
        fit,
        contain,
        stretch,
        desktop
    }

    @property {
        Vec2i center() {
            return _kernelSize / 2;
        }

        Vec2i size() {
            return _kernelSize;
        }

        package pragma(inline) SDL_Renderer* sdlRenderer() {
            return _sdlRenderer;
        }
    }

    uint scalingTime = 15;

    this(Window window) {
        _kernelSize = Vec2i(window.width, window.height);
        _sdlRenderer = SDL_CreateRenderer(window.sdlWindow, -1,
            SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
        enforce(_sdlRenderer, "renderer creation failure");
    }

    void setupKernel() {
        _updateKernel();
        _updateScaling();
        _updateSharpness();
    }

    void close() {
        SDL_DestroyRenderer(_sdlRenderer);
    }

    Vec2f getLogicalPosition(Vec2f position) const {
        Vec2f windowSize = Vec2f(Atelier.window.width, Atelier.window.height);
        Vec2f ratio = (cast(Vec2f) _kernelSize) / windowSize;
        return position * ratio;
    }

    private void _updateKernel() {
        _kernelCanvas = new Canvas(_kernelSize.x, _kernelSize.y);
        _kernelSprite = new Sprite(_kernelCanvas);
        _kernelSprite.anchor = Vec2f.half;

        _scaledCanvas = new Canvas(_kernelSize.x * _pixelSharpness,
            _kernelSize.y * _pixelSharpness, true);
        _scaledSprite = new Sprite(_scaledCanvas);
        _scaledSprite.anchor = Vec2f.half;
    }

    private void _updateScaling() {
        Vec2f windowSize = Vec2f(Atelier.window.width, Atelier.window.height);
        Vec2f scaledKernelSize = cast(Vec2f)(_kernelSize * _pixelSharpness);

        float time = easeInOutQuad(_scaleTimer.value01);
        _scaledSizeStart = _scaledSizeStart.lerp(_scaledSizeEnd, time);

        final switch (_scaling) with (Scaling) {
        case none:
            _scaledSizeEnd = cast(Vec2f) _kernelSize;
            break;
        case integer:
            _scaledSizeEnd = scaledKernelSize;
            break;
        case fit:
            _scaledSizeEnd = scaledKernelSize.fit(windowSize);
            break;
        case contain:
            _scaledSizeEnd = scaledKernelSize.contain(windowSize);
            break;
        case stretch:
            _scaledSizeEnd = windowSize;
            break;
        case desktop:
            _kernelSize = Vec2i(Atelier.window.width, Atelier.window.height);
            _updateKernel();
            _scaledSizeEnd = cast(Vec2f) _kernelSize;
            Atelier.ui.dispatchEvent("windowSize");
            Atelier.ui.dispatchEvent("parentSize", false);
            break;
        }

        if (scalingTime > 0) {
            _scaleTimer.start(scalingTime);
        }
        else {
            _scaleTimer.start(1);
            _scaleTimer.update();
        }
    }

    private void _updateSharpness() {
        _scaledCanvas.setSize(_kernelSize.x * _pixelSharpness, _kernelSize.y * _pixelSharpness);
        _scaledSprite.clip = Vec4u(0, 0, _scaledCanvas.width, _scaledCanvas.height);
        _kernelSprite.size = cast(Vec2f)(_kernelSize * _pixelSharpness);
    }

    void setScaling(Scaling scaling) {
        if (_scaling == scaling)
            return;

        _scaling = scaling;
        _updateScaling();
    }

    void setPixelSharpness(int sharpness) {
        if (sharpness < 1)
            sharpness = 1;

        if (_pixelSharpness == sharpness)
            return;

        _pixelSharpness = sharpness;
        _updateSharpness();
        _updateScaling();
    }

    void setWindowSize(Vec2i windowSize) {
        if (_windowSize == windowSize)
            return;

        _windowSize = windowSize;
        _updateScaling();
    }

    void startRenderPass() {
        pushCanvas(_kernelCanvas);
    }

    void endRenderPass() {
        popCanvas();

        pushCanvas(_scaledCanvas);
        _kernelSprite.draw(_kernelSprite.size / 2f);
        popCanvas();

        _scaleTimer.update();

        Vec2f scaledSize = Vec2f.zero;
        float time = easeInOutQuad(_scaleTimer.value01);
        scaledSize = _scaledSizeStart.lerp(_scaledSizeEnd, time);

        _scaledSprite.size = scaledSize;
        _scaledSprite.draw(Vec2f(Atelier.window.width, Atelier.window.height) / 2f);

        SDL_Color sdlColor = Atelier.theme.background.toSDL();

        SDL_RenderPresent(_sdlRenderer);
        SDL_SetRenderDrawColor(_sdlRenderer, sdlColor.r, sdlColor.g, sdlColor.b, 0);
        SDL_RenderClear(_sdlRenderer);
    }

    void pushCanvas(Canvas canvas) {
        CanvasContext context;
        _idxContext++;

        enforce(_idxContext < 128, "canvas stack limit");

        if (_idxContext == _canvases.length) {
            context = new CanvasContext;
            _canvases ~= context;
        }
        else {
            context = _canvases[_idxContext];
        }

        context.canvas = canvas;
        context.clip = Vec4u(0, 0, canvas.width, canvas.height);

        SDL_Color sdlColor = context.canvas.color.toSDL();

        SDL_SetRenderTarget(_sdlRenderer, context.canvas.target);
        SDL_SetRenderDrawColor(_sdlRenderer, sdlColor.r, sdlColor.g, sdlColor.b, 0);
        SDL_RenderClear(_sdlRenderer);
    }

    void pushCanvas(uint width, uint height, Blend blend = Blend.canvas) {
        CanvasContext context;
        _idxContext++;

        enforce(_idxContext < 128, "canvas stack limit");

        if (_idxContext == _canvases.length) {
            context = new CanvasContext;
            context.canvas = new Canvas(width, height);
            context.clip = Vec4u(0, 0, width, height);
            _canvases ~= context;
        }
        else {
            context = _canvases[_idxContext];
            context.clip = Vec4u(0, 0, width, height);

            if (context.canvas.width < width || context.canvas.height < height) {
                context.canvas.setSize(max(context.canvas.width, width),
                    max(context.canvas.height, height));
            }
        }
        context.canvas.blend = blend;

        SDL_SetRenderTarget(_sdlRenderer, context.canvas.target);
        SDL_SetRenderDrawBlendMode(_sdlRenderer, getSDLBlend(Blend.none));
        SDL_SetRenderDrawColor(_sdlRenderer, 0, 0, 0, 0);
        SDL_RenderClear(_sdlRenderer);
    }

    void popCanvas() {
        if (_idxContext < 0)
            return;

        _idxContext--;
        if (_idxContext >= 0)
            SDL_SetRenderTarget(_sdlRenderer, _canvases[_idxContext].canvas.target);
        else
            SDL_SetRenderTarget(_sdlRenderer, null);
    }

    void popCanvasAndDraw(Vec2f position, Vec2f size, double angle, Vec2f pivot,
        Color color, float alpha) {
        if (_idxContext < 0)
            return;

        CanvasContext context = _canvases[_idxContext];

        _idxContext--;
        if (_idxContext >= 0)
            SDL_SetRenderTarget(_sdlRenderer, _canvases[_idxContext].canvas.target);
        else
            SDL_SetRenderTarget(_sdlRenderer, null);

        context.canvas.color = color;
        context.canvas.alpha = alpha;
        context.canvas.draw(position, size, context.clip, angle, pivot);
    }

    void drawRect(Vec2f position, Vec2f size, Color color, float alpha, bool filled) {
        const auto sdlColor = color.toSDL();
        SDL_SetRenderDrawBlendMode(_sdlRenderer, getSDLBlend(Blend.alpha));
        SDL_SetRenderDrawColor(_sdlRenderer, sdlColor.r, sdlColor.g,
            sdlColor.b, cast(ubyte)(clamp(alpha, 0f, 1f) * 255f));

        const SDL_FRect rect = {position.x, position.y, size.x, size.y};

        if (filled)
            SDL_RenderFillRectF(_sdlRenderer, &rect);
        else
            SDL_RenderDrawRectF(_sdlRenderer, &rect);
    }
}
