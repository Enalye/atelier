/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module dahu.core.loader;

import std.file;
import std.path;
import std.stdio;

import dahu.common, dahu.render;

package void loadResources() {
    initFont();

    auto files = dirEntries(buildNormalizedPath("test", "assets"), SpanMode.depth);

    foreach (file; files) {
        switch (extension(file)) {
        case ".bmp":
        case ".gif":
        case ".jpg":
        case ".jpeg":
        case ".png":
        case ".tga":
            storePrototype!Texture(file, new Texture(file));
            writeln("loaded: ", file);
            break;
        default:
            break;
        }
    }
}
