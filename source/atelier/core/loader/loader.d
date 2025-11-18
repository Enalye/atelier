module atelier.core.loader.loader;

import atelier.common;
import atelier.render;
import atelier.core.data;

import atelier.core.loader.actor;
import atelier.core.loader.animation;
import atelier.core.loader.bitmapfont;
import atelier.core.loader.light;
import atelier.core.loader.locale;
import atelier.core.loader.multidiranimation;
import atelier.core.loader.music;
import atelier.core.loader.ninepatch;
import atelier.core.loader.particle;
import atelier.core.loader.pixelfont;
import atelier.core.loader.pixelfontset;
import atelier.core.loader.prop;
import atelier.core.loader.proxy;
import atelier.core.loader.shadow;
import atelier.core.loader.scene;
import atelier.core.loader.shadedtexture;
import atelier.core.loader.shot;
import atelier.core.loader.sound;
import atelier.core.loader.sprite;
import atelier.core.loader.terrain;
import atelier.core.loader.texture;
import atelier.core.loader.tilemap;
import atelier.core.loader.tileset;
import atelier.core.loader.truetype;

/// Initialise les ressources
void setupDefaultResourceLoaders(ResourceManager res) {
    loadInternalData(res);
    res.setLoader("texture", &compileTexture, &loadTexture);
    res.setLoader("shadedtexture", &compileShadedTexture, &loadShadedTexture);
    res.setLoader("sprite", &compileSprite, &loadSprite);
    res.setLoader("animation", &compileAnimation, &loadAnimation);
    res.setLoader("multidiranimation", &compileMultiDirAnimation, &loadMultiDirAnimation);
    res.setLoader("ninepatch", &compileNinepatch, &loadNinepatch);
    res.setLoader("tileset", &compileTileset, &loadTileset);
    res.setLoader("tilemap", &compileTilemap, &loadTilemap);
    res.setLoader("sound", &compileSound, &loadSound);
    res.setLoader("music", &compileMusic, &loadMusic);
    res.setLoader("truetype", &compileTrueType, &loadTrueType);
    res.setLoader("bitmapfont", &compileBitmapFont, &loadBitmapFont);
    res.setLoader("particle", &compileParticle, &loadParticle);
    res.setLoader("pixelfontbordered", &compilePixelFont, &loadPixelFont!PixelFontBordered);
    res.setLoader("pixelfontshadowed", &compilePixelFont, &loadPixelFont!PixelFontShadowed);
    res.setLoader("pixelfontstandard", &compilePixelFont, &loadPixelFont!PixelFontStandard);
    res.setLoader("pixelfontset", &compilePixelFontSet, &loadPixelFontSet);
    res.setLoader("shadow", &compileShadow, &loadShadow);
    res.setLoader("light", &compileLight, &loadLight);
    res.setLoader("scene", &compileScene, &loadScene);
    res.setLoader("terrain", &compileTerrain, &loadTerrain);
    res.setLoader("prop", &compileProp, &loadProp);
    res.setLoader("actor", &compileActor, &loadActor);
    res.setLoader("shot", &compileShot, &loadShot);
    res.setLoader("proxy", &compileProxy, &loadProxy);
    res.setLoader("locale", &compileLocale, &loadLocale);
    res.setLoaderIgnored("instrument");
}
