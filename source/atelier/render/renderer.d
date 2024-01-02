/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.render.renderer;

import std.exception : enforce;

import bindbc.sdl;

import atelier.common, atelier.core;

import atelier.render.canvas;

private {
    SDL_Renderer* _sdlRenderer;
}

@property pragma(inline) {
    SDL_Renderer* sdlRenderer() {
        return _sdlRenderer;
    }
}

final class Renderer {
    private {
        final class CanvasContext {
            Canvas canvas;
            Vec4i clip;
        }

        CanvasContext[] _canvases;
        int _idxContext = -1;
    }

    Color color = Color.white;

    this(Window window) {
        _sdlRenderer = SDL_CreateRenderer(window.sdlWindow, -1,
            SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
        enforce(_sdlRenderer, "renderer creation failure");
    }

    void close() {
        SDL_DestroyRenderer(_sdlRenderer);
    }

    void render() {
        SDL_Color sdlColor = color.toSDL();

        SDL_RenderPresent(_sdlRenderer);
        SDL_SetRenderDrawColor(_sdlRenderer, sdlColor.r, sdlColor.g, sdlColor.b, 0);
        SDL_RenderClear(_sdlRenderer);
    }

    void pushCanvas(uint width, uint height) {
        CanvasContext context;
        _idxContext++;

        enforce(_idxContext < 128, "canvas stack limit");

        if (_idxContext == _canvases.length) {
            context = new CanvasContext;
            context.canvas = new Canvas(width, height);
            context.clip = Vec4i(0, 0, width, height);
            _canvases ~= context;
        }
        else {
            context = _canvases[_idxContext];
            context.clip = Vec4i(0, 0, width, height);

            if (context.canvas.width < width || context.canvas.height < height) {
                context.canvas.setSize(max(context.canvas.width, width),
                    max(context.canvas.height, height));
            }
        }

        SDL_Color sdlColor = context.canvas.color.toSDL();

        SDL_SetRenderTarget(_sdlRenderer, context.canvas.target);
        SDL_SetRenderDrawColor(_sdlRenderer, sdlColor.r, sdlColor.g, sdlColor.b, 0);
        SDL_RenderClear(_sdlRenderer);
    }

    void popCanvas(Vec2f position, Vec2f size, double angle, Vec2f pivot, Color color, float alpha) {
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
        SDL_SetRenderDrawColor(_sdlRenderer, sdlColor.r, sdlColor.g,
            sdlColor.b, cast(ubyte)(clamp(alpha, 0f, 1f) * 255f));

        const SDL_FRect rect = {position.x, position.y, size.x, size.y};

        if (filled)
            SDL_RenderFillRectF(_sdlRenderer, &rect);
        else
            SDL_RenderDrawRectF(_sdlRenderer, &rect);
    }
}