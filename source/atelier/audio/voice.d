/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.audio.voice;

import std.stdio;
import audioformats;
import bindbc.sdl;

import atelier.common;
import atelier.core;
import atelier.audio.effect;
import atelier.audio.config;
import atelier.audio.music;
import atelier.audio.sound;

interface Voice {
    @property {
        bool isAlive() const;
    }

    size_t process(out float[Atelier_Audio_BufferSize]);

    void addEffect(AudioEffect);
}
