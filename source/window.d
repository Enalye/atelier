/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.window;

import std.exception : enforce;
import std.string : toStringz, fromStringz;

import bindbc.sdl;

final class Window {
    enum Display {
        fullscreen,
        desktop,
        windowed
    }

    private {
        SDL_Window* _sdlWindow;
        SDL_Renderer* _sdlRenderer;
        SDL_Surface* _icon;
        string _title;
        uint _width, _height;
    }

    @property {
        /// Titre de la fenêtre
        string title() const {
            return _title;
        }
        /// Ditto
        string title(string title_) {
            _title = title_;
            SDL_SetWindowTitle(_sdlWindow, toStringz(_title));
            return _title;
        }
    }

    this(uint width_, uint height_) {
        _width = width_;
        _height = height_;

        enforce(SDL_Init(SDL_INIT_EVERYTHING) == 0,
            "SDL initialisation failure: " ~ fromStringz(SDL_GetError()));

        enforce(TTF_Init() != -1, "SDL ttf initialisation failure");
        enforce(Mix_OpenAudio(44_100, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS,
                1024) != -1, "no audio device connected");
        enforce(Mix_AllocateChannels(16) != -1, "audio channels allocation failure");

        IMG_Load(toStringz("yo"));


        SDL_SetHint(SDL_HINT_RENDER_BATCHING, "1");

        enforce(SDL_CreateWindowAndRenderer(_width, _height,
                SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC | SDL_WINDOW_RESIZABLE,
                &_sdlWindow, &_sdlRenderer) != -1, "window initialisation failure");

    }
}
