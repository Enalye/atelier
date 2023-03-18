/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module render.renderer;

import bindbc.sdl;

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
    }

    this(SDL_Renderer* sdlRenderer) {
        _sdlRenderer = sdlRenderer;
    }

    void close() {
        SDL_DestroyRenderer(_sdlRenderer);
    }
}
