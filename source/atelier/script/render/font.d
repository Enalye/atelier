/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.script.render.font;

import grimoire;

import atelier.common;
import atelier.core;
import atelier.render;
import atelier.script.util;

package void loadLibRender_font(GrLibDefinition library) {
    library.setModule("render.font");
    library.setModuleInfo(GrLocale.fr_FR, "Police de caractères");

    library.addNative("Font", [], "ImageData");
    GrType ttfType = library.addNative("TrueTypeFont", [], "Font");
    GrType bmpfType = library.addNative("BitmapFont", [], "Font");
    GrType pxfType = library.addNative("PixelFont", [], "Font");

    library.setDescription(GrLocale.fr_FR, "Style de police");
    GrType pxfStyleType = library.addEnum("PixelFontStyle", [
            "standard", "shadowed", "bordered"
        ]);

    library.setParameters(["name"]);
    library.addConstructor(&_ttfCtor, ttfType, [grString]);

    library.setParameters(["name"]);
    library.addConstructor(&_bmpfCtor, bmpfType, [grString]);

    library.setParameters([
        "ascent", "descent", "lineSkip", "weight", "spacing", "style"
    ]);
    library.addConstructor(&_pxfCtor, pxfType, [
            grInt, grInt, grInt, grInt, grInt, pxfStyleType
        ]);

    library.setDescription(GrLocale.fr_FR, "Ajoute un caractère à la police.");
    library.setParameters([
        "font", "ch", "advance", "offsetX", "offsetY", "width", "height",
        "posX", "posY", "kerningChar", "kerningOffset"
    ]);
    library.addFunction(&_addCharacter_bmpf, "addCharacter", [
            bmpfType, grChar, grInt, grInt, grInt, grInt, grInt, grInt, grInt,
            grList(grChar), grList(grInt)
        ]);

    library.setParameters([
        "font", "ch", "glyphData", "width", "height", "descent"
    ]);
    library.addFunction(&_addCharacter_pxf, "addCharacter", [
            pxfType, grChar, grList(grInt), grInt, grInt, grInt
        ]);
}

private void _ttfCtor(GrCall call) {
    call.setNative(Atelier.res.get!TrueTypeFont(call.getString(0)));
}

private void _bmpfCtor(GrCall call) {
    call.setNative(Atelier.res.get!BitmapFont(call.getString(0)));
}

private void _pxfCtor(GrCall call) {
    int ascent = call.getInt(0);
    int descent = call.getInt(1);
    int lineSkip = call.getInt(2);
    int weight = call.getInt(3);
    int spacing = call.getInt(4);

    PixelFont font;
    switch (call.getInt(5)) {
    case 0:
        font = new PixelFontStandard(ascent, descent, lineSkip, weight, spacing);
        break;
    case 1:
        font = new PixelFontShadowed(ascent, descent, lineSkip, weight, spacing);
        break;
    case 2:
        font = new PixelFontBordered(ascent, descent, lineSkip, weight, spacing);
        break;
    default:
        call.raise("InvalidEnum");
        return;
    }

    call.setNative(font);
}

private void _addCharacter_bmpf(GrCall call) {
    BitmapFont font = call.getNative!BitmapFont(0);
    dchar ch = call.getChar(1);
    int advance = call.getInt(2);
    int offsetX = call.getInt(3);
    int offsetY = call.getInt(4);
    int width = call.getInt(5);
    int height = call.getInt(6);
    int posX = call.getInt(7);
    int posY = call.getInt(8);
    dchar[] kerningChar = call.getList(9).getChars();
    int[] kerningOffset = call.getList(10).getInts();

    font.addCharacter(ch, advance, offsetX, offsetY, width, height, posX, posY,
        kerningChar, kerningOffset);
}

private void _addCharacter_pxf(GrCall call) {
    PixelFont font = call.getNative!PixelFont(0);
    dchar ch = call.getChar(1);
    int[] glyphData = call.getList(2).getInts();
    int width = call.getInt(3);
    int height = call.getInt(4);
    int descent = call.getInt(5);

    font.addCharacter(ch, glyphData, width, height, descent);
}
