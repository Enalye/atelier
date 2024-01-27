/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module atelier.audio.config;

enum Atelier_Audio_SampleRate = 48_000;
enum Atelier_Audio_FrameSize = 128;
enum Atelier_Audio_Channels = 2;
enum Atelier_Audio_BufferSize = Atelier_Audio_FrameSize * Atelier_Audio_Channels;