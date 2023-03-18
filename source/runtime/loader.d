/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module runtime.loader;

import std.file;
import std.path;
import std.stdio;

import common, render;

package void loadResources() {
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
            break;
        default:
            break;
        }
    }
}
