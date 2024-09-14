/** 
 * Droits d’auteur: Enalye
 * Licence: Zlib
 * Auteur: Enalye
 */
module atelier.core.loader.loader;

import atelier.common;
import atelier.core.data;

import atelier.core.loader.animation;
import atelier.core.loader.bitmapfont;
import atelier.core.loader.scene;
import atelier.core.loader.music;
import atelier.core.loader.ninepatch;
import atelier.core.loader.particle;
import atelier.core.loader.sound;
import atelier.core.loader.sprite;
import atelier.core.loader.texture;
import atelier.core.loader.tilemap;
import atelier.core.loader.tileset;
import atelier.core.loader.truetype;

/// Initialise les ressources
void setupDefaultResourceLoaders(ResourceManager res) {
    loadInternalData(res);
    res.setLoader("texture", &compileTexture, &loadTexture);
    res.setLoader("sprite", &compileSprite, &loadSprite);
    res.setLoader("animation", &compileAnimation, &loadAnimation);
    res.setLoader("ninepatch", &compileNinepatch, &loadNinepatch);
    res.setLoader("tileset", &compileTileset, &loadTileset);
    res.setLoader("tilemap", &compileTilemap, &loadTilemap);
    res.setLoader("sound", &compileSound, &loadSound);
    res.setLoader("music", &compileMusic, &loadMusic);
    res.setLoader("truetype", &compileTrueType, &loadTrueType);
    res.setLoader("bitmapfont", &compileBitmapFont, &loadBitmapFont);
    res.setLoader("particle", &compileParticle, &loadParticle);
    res.setLoader("scene", &compileScene, &loadScene);
}