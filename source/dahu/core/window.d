/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.core.window;

import std.exception : enforce;
import std.string : toStringz, fromStringz;

import bindbc.sdl;

import dahu.render;

private {
    Window _window;
}

@property {
    pragma(inline) Window getWindow() {
        return _window;
    }
}

final class Window {
    enum Display {
        fullscreen,
        desktop,
        windowed
    }

    private {
        SDL_Window* _sdlWindow;
        SDL_Surface* _icon;
        string _title;
        uint _width, _height;
    }

    @property {
        SDL_Window* sdlWindow() {
            return _sdlWindow;
        }

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

        uint width() const {
            return _width;
        }

        uint height() const {
            return _height;
        }
    }

    this(uint width_, uint height_) {
        _width = width_;
        _height = height_;

        enforce(SDL_Init(SDL_INIT_EVERYTHING) == 0,
            "SDL initialisation failure: " ~ fromStringz(SDL_GetError()));

        enforce(TTF_Init() != -1, "SDL ttf initialisation failure");

        _sdlWindow = SDL_CreateWindow(toStringz("dahu"), SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED, _width, _height, SDL_WINDOW_RESIZABLE);
        enforce(_sdlWindow, "window initialisation failure");

        _window = this;
    }

    void close() {
        if (_sdlWindow)
            SDL_DestroyWindow(_sdlWindow);
    }

    void setIcon(string path) {
        if (_icon) {
            SDL_FreeSurface(_icon);
            _icon = null;
        }
        _icon = IMG_Load(toStringz(path));

        SDL_SetWindowIcon(_sdlWindow, _icon);
    }
}
