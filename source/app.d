/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */

import std.stdio;
import std.exception;
import std.string;

//import dahu.cli;

void main(string[] args) {
    writeln("yo");
    version (Windows) {
        import core.sys.windows.windows : SetConsoleOutputCP;

        SetConsoleOutputCP(65_001);
    }
    
    //parseCommand(args);
import std.conv;
import bindbc.sdl;
auto ver = sdlMixerSupport;
writeln("ver: ", ver.major, ".", ver.minor, ".", ver.patch);
    SDL_Window* _sdlWindow;
    SDL_Renderer* _sdlRenderer;

    writeln("Loading");
    //enforce(loadSDL() >= SDLSupport.sdl2010, "SDL support <= 2.0.10");

    enforce(SDL_Init(SDL_INIT_EVERYTHING) == 0,
        "SDL initialisation failure: " ~ fromStringz(SDL_GetError()));

    enforce(SDL_CreateWindowAndRenderer(800, 600,
            SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC | SDL_WINDOW_RESIZABLE,
            &_sdlWindow, &_sdlRenderer) != -1, "window initialisation failure");

}
