# Ressources

Les ressources représentent tous les données externes au code qui ont besoin d’être chargé par l’application

Ces ressources sont décrites au sein de fichiers [farfadets](https://github.com/Enalye/farfadet) avec l’extension `.ffd`.

Chaque ressource est définie par un bloc avec la syntaxe suivante:
```
TYPE_RESSOURCE RID {
    [PARAMÈTRES…]
}
```
**RID** (Resource ID) est un identifiant unique par type de ressource permettant à la ressource d’être récupéré en script.

Les types de ressources reconnues sont:
- [Texture](#Texture)
- [Sprite](#Sprite)
- [Ninepatch](#Ninepatch)
- [Animation](#Animation)
- [Tileset](#Tileset)
- [Tilemap](#Tilemap)
- [Sound](#Sound)
- [Music](#Music)
- [Truetype](#Truetype)
- [BitmapFont](#BitmapFont)
- [Particle](#Particle)
- [Level](#Level)

## Texture
Les textures sont utilisés par d’autres ressources tels les sprites afin d’afficher du contenu à l’écran.

```
texture "maTexture" {
    file "maTexture.png"
} 
```
Paramètres:
 * `file` (obligatoire)
    - chemin relatif du fichier (string)

## Sprite
Les sprites définissent une région d’une texture à dessiner.

```
sprite "monSprite" {
    texture "maTexture"
    clip 0 0 32 32
} 
```
Paramètres:
 * `texture` (obligatoire)
    - RID de la texture (string)
 * `clip` (optionnel)
    - x (int)
    - y (int)
    - largeur (int)
    - hauteur (int)

## Ninepatch
Les ninepatchs permettent de diviser un sprite en 9 sections afin de se mettre à l’échelle sans s’étirer.

```
ninepatch "monNinepatch" {
    texture "maTexture"
    clip 0 0 32 32
    top 4
    bottom 4
    left 4
    right 4
} 
```
Paramètres:
 * `texture` (obligatoire)
    - RID de la texture (string)
 * `clip` (optionnel)
    - x (int)
    - y (int)
    - largeur (int)
    - hauteur (int)
 * `top` (optionnel)
    - taille (int)
 * `bottom` (optionnel)
    - taille (int)
 * `left` (optionnel)
    - taille (int)
 * `right` (optionnel)
    - taille (int) 

## Animation
Les animations sont des suites de sprites (frames) qui s’alternent.

```
animation "monAnimation" {
    texture "maTexture"
    clip 0 0 32 32
    frameTime 10
    frames [0 1 2 3]
    repeat true
    lines 4
    columns 1
    maxCount 4
    margin 1 1
} 
```
Paramètres:
 * `texture` (obligatoire)
    - RID de la texture (string)
 * `clip` (optionnel) Position du premier sprite
    - x (int)
    - y (int)
    - largeur (int)
    - hauteur (int)
 * `frameTime` (optionnel)
    - durée entre chaque frame (int)
 * `frames` (optionnel)
    - liste des frames à jouer (int[])
 * `repeat` (optionnel)
    - doit-on recommencer après avoir fini ? (bool)
 * `lines` (optionnel)
    - nombre de lignes de sprites (int)
 * `columns` (optionnel)
    - nombre de colonnes de sprites (int)
 * `maxCount` (optionnel)
    - nombre maximum de sprites (par défaut: lines×columns) (int)
 * `margin` (optionnel)
    - écart en x entre chaque sprites (int)
    - écart en y entre chaque sprites (int)

## Tileset
Les tilesets permettent de répéter certains sprites (tuiles) sous forme d’une grille par un Tilemap.

```
tileset "monTileset" {
    texture "maTexture"
    clip 0 0 32 32
    columns 8
    lines 8
    maxCount 4
    margin 1 1
    frameTime 30
    tileFrame 1 2
    tileFrame 2 3
    tileFrame 3 1
} 
```
Paramètres:
 * `texture` (obligatoire)
    - RID de la texture (string)
 * `clip` (optionnel) Position du premier sprite
    - x (int)
    - y (int)
    - largeur (int)
    - hauteur (int)
 * `tileSize` (optionnel) Taille de la surface de la tuile dans le clip
    - largeur (int)
    - hauteur (int)
 * `frameTime` (optionnel)
    - durée entre chaque frame (int)
 * `tileFrame` (optionnel) animation des tuiles
    - id actuel de la tuile (int)
    - prochaine id de la tuile (int)
 * `repeat` (optionnel)
    - doit-on recommencer après avoir fini ? (bool)
 * `lines` (optionnel)
    - nombre de lignes de sprites (int)
 * `columns` (optionnel)
    - nombre de colonnes de sprites (int)
 * `maxCount` (optionnel)
    - nombre maximum de sprites (par défaut: lines×columns) (int)
 * `margin` (optionnel)
    - écart en x entre chaque sprites (int)
    - écart en y entre chaque sprites (int)

## Tilemap
Les tilemap représentent une grille de tuiles formé par un Tileset.
```
tilemap "maTilemap" {
    tileset "monTileset"
    size 5 5
    tiles [
        [1 1 2 2 1]
        [2 1 0 2 1]
        [1 1 2 2 1]
        [0 1 1 0 0]
        [2 1 0 0 0]
    ]
}
```
Paramètres:
 * `tileset` (obligatoire)
    - RID du tileset (string)
 * `size` (obligatoire)
    - largeur de la grille en tuiles (uint)
    - hauteur de la grille en tuiles (uint)
 * `tiles` (optionnel)
    - grille des tuiles à la dimension de `size` (int[][])
 * `heightmap` (optionnel)
    - grille des élévations des tuiles à la dimension de `size` (int[][])

## Sound
Les sons permettent de jouer de l’audio et sont entièrement chargés en mémoire.

```
sound "monSon" {
    file "monSon.wav"
    volume 1.0
}
```
Paramètres:
 * `file` (obligatoire)
    - chemin relatif du fichier (string)
 * `volume` (optionnel)
    - volume (0~1) (float)

## Music
Les musiques permettent de jouer de l’audio et sont décodés au fur et à mesure.

```
music "maMusique" {
    file "maMusique.ogg"
    volume 1.0
    loopStart 5.0
    loopEnd 60.0
}
```
Paramètres:
 * `file` (obligatoire)
    - chemin relatif du fichier (string)
 * `volume` (optionnel)
    - volume (0~1) (float)
 * `loopStart` (optionnel)
    - temps (en secondes) où la musique redémarre après avoir atteint `loopEnd` (float)
 * `loopEnd` (optionnel)
    - temps (en secondes) où la musique boucle à `loopStart` (float)

## TrueType
Les polices truetype (TTF) permettent de générer du texte à l’écran.

```
truetype "maPolice" {
    file "maPolice.ttf"
    size 16
    outline 2
}
```
Paramètres:
 * `file` (obligatoire)
    - chemin relatif du fichier (string)
 * `size` (obligatoire)
    - taille de la police (int)
 * `outline` (optionnel)
    - taille de la bordure (int)

## BitmapFont
Les polices bitmap permettent de générer du texte à l’écran en se basant sur une texture.

```
bitmapfont "maPolice" {
    texture "maPolice.png"
    size 7
    ascent 5
    descent 2
    char 'a' {
        advance 2
        offset 2 2
        size 2 2
        pos 2 2
        kerning 'b' 2
        kerning 'c' 2
    }
    char 'b' {
        advance 2
        offset 2 2
        size 2 2
        pos 2 2
    }
    char 'c' {
        advance 2
        offset 2 2
        size 2 2
        pos 2 2
    }
}
```
Paramètres:
 * `texture` (obligatoire)
    - RID de la texture (string)
 * `size` (obligatoire)
    - taille de la police (int)
 * `ascent` (obligatoire)
    - hauteur au dessus de la ligne (int)
 * `descent` (obligatoire)
    - hauteur au dessous de la ligne (int)
 * `char` (optionnel)
    - lettre (char)

`char` définit ces paramètres:
 * `advance` (optionnel)
    - avancement du curseur (int)
 * `offset` (optionnel)
    - décalage en x par rapport au curseur (int)
    - décalage en y par rapport au curseur (int)
 * `size` (optionnel)
    - largeur du sprite (int)
    - hauteur du sprite (int)
 * `pos` (optionnel)
    - position du sprite en x (int)
    - position du sprite en y (int)
 * `kerning` (optionnel)
    - lettre précédente (char)
    - décalage horizontal (int)

## Particle
Particle définit des générateur de particules (ParticleSource).

```
particle "mesParticules" {
    sprite "monSprite"
    isRelativePosition true
    spread 0 360 45
    mode "spread"
    distance 100 100
    count 5 7
    lifetime 100 100

    speed {
        frames 0 60
        start 0.3
        end 0.5
        spline "sineInOut"
    }

    speed {
        frames 60 100
        start 0.5
        end 0
        spline "sineInOut"
    }

    alpha {
        frames 0 10
        start 0
        end 1
        spline "sineInOut"
    }

    alpha {
        frames 90 100
        start 1
        end 0
        spline "sineInOut"
    }

    pivotSpin {
        frame 0
        min 0.02
        max 0.02
    }

    pivotDistance {
        frames 0 60
        start 50
        end 150
        spline "sineInOut"
    }

    pivotDistance {
        frames 60 100
        start 150
        end 100
        spline "sineInOut"
    }
}
```

Paramètres:
 * `sprite` (optionnel)
    - RID du sprite (string)
 * `blend` (optionnel)
    - blending du sprite (string)
 * `isRelativePosition` (optionnel)
    - les particules se déplacent-elles avec la source ? (bool)
 * `isRelativeSpriteAngle` (optionnel)
    - les particules s’orientent-elles en fonction de leur angle ? (bool)
 * `lifetime` (optionnel)
    - durée de vie minimale d’une particule en frames (uint)
    - durée de vie maximale d’une particule en frames (uint)
 * `count` (optionnel)
    - quantité minimale de particules émises à la fois (uint)
    - quantité maximale de particules émises à la fois (uint)
 * `mode` (optionnel)
    - mode d’émission ("rectangle", "ellipsis" ou "spread") (string)
 * `area` (optionnel) (mode: "rectangle" ou "ellipsis")
    - largeur de la zone d’émission (float)
    - hauteur de la zone d’émission (float)
 * `distance` (optionnel) (mode: "spread")
    - distance minimale de l’émission depuis le centre (float)
    - distance maximale de l’émission depuis le centre (float)
 * `spread` (optionnel) (mode: "spread")
    - angle minimum (en degrés) de l’émission (float)
    - angle maximum (en degrés) de l’émission (float)
    - écart (en degrés) autour de l’angle d’émission (float)

Liste des effets:
 * `speed`
 * `angle`
 * `spin`
 * `pivotAngle`
 * `pivotSpin`
 * `pivotDistance`
 * `spriteAngle`
 * `spriteSpin`
 * `scale`
 * `color`
 * `alpha`

Chaque effet peut prendre 2 formes:
 * Forme unique:
    Applique l’effet sur une frame entre une valeur minimale et maximale
 * Forme intervalle:
    Applique l’effet interpolé entre deux frames entre une valeur initiale et finale

Forme unique:
 * `frame` (optionnel)
    - frame sur laquelle l’effet s’applique (uint)
 * `min` (optionnel)
    - valeur minimale de l’effet (2 float pour `scale`, 3 pour `color`, 1 pour les autres)
 * `max` (optionnel)
    - valeur maximale de l’effet (2 float pour `scale`, 3 pour `color`, 1 pour les autres)

Forme intervalle:
 * `frames` (optionnel)
    - frame initiale (uint)
    - frame finale (uint)
 * `spline` (optionnel)
    - courbe d’interpolation appliquée (string)
 * `start` (optionnel)
    - valeur initiale de l’effet (2 float pour `scale`, 3 pour `color`, 1 pour les autres)
 * `end` (optionnel)
    - valeur finale de l’effet (2 float pour `scale`, 3 pour `color`, 1 pour les autres)

## Level
Level définit un preset de niveau à charger avec `loadLevel`

```
level "monLevel" {
    scene {
        parallax 0.5 0.2
        zOrder 1

        entity {
            tilemap "terrain" {
                position -200 -200
            }
        }
    }

    scene {
        name "scene"

        particle "mesParticules" {
            name "particle"
        }

        entity {
            tilemap "terrain" {
                position -200 -200
            }
        }

        entity {
            name "player"
            position 100 10
            sprite "player"

            circle {
                position 10 10
                hsl 300 0.6 0.5
                radius 10
                outline 2
            }
        }
    }
}
```

Paramètres:
 * `scene` (optionnel)

`scene` définit ces commandes:
 * `name` (optionnel)
    - Nom de la scène (string)
 * `tags` (optionnel)
    - tags à ajouter à la scène (string[])
 * `tag` (optionnel)
    - tag à ajouter à la scène (string)
 * `position`
    - position en x (float)
    - position en y (float)
 * `parallax`
    - facteur de décalage en x (float)
    - facteur de décalage en y (float)
 * `zOrder` (optionnel)
    - ordonnancement de la scène (int)
 * `particle` (optionnel)
    - RID de la source de particules (string)
 * `entity` (optionnel)

`particle` définit ces commandes:
 * `name` (optionnel)
    - Nom de la scène (string)
 * `tags` (optionnel)
    - tags à ajouter à la scène (string[])
 * `tag` (optionnel)
    - tag à ajouter à la scène (string)
 * `position`
    - position en x (float)
    - position en y (float)

`entity` définit ces commandes:
 * `name` (optionnel)
    - Nom de la scène (string)
 * `tags` (optionnel)
    - tags à ajouter à la scène (string[])
 * `tag` (optionnel)
    - tag à ajouter à la scène (string)
 * `position`
    - position en x (float)
    - position en y (float)
 * `zOrder` (optionnel)
    - ordonnancement de la scène (int)
 * `entity` (optionnel)
 * `animation` (optionnel)
    - RID de l’animation (string)
 * `ninepatch` (optionnel)
    - RID du ninepatch (string)
 * `sprite` (optionnel)
    - RID du sprite (string)
 * `tilemap` (optionnel)
    - RID du tilemap (string)
 * `capsule` (optionnel)
 * `circle` (optionnel)
 * `rectangle` (optionnel)
 * `roundedrectangle` (optionnel)

`capsule` définit ces commandes:
 * `size` (optionnel)
    - largeur de la capsule (float)
    - hauteur de la capsule (float)
 * `outline` (optionnel)
    - épaisseur de la bordure (float)

`circle` définit ces commandes:
 * `outline` (optionnel)
    - épaisseur de la bordure (float)
 * `radius` (optionnel)
    - rayon du cercle (float)

`rectangle` définit ces commandes:
 * `size` (optionnel)
    - largeur du rectangle (float)
    - hauteur du rectangle (float)
 * `outline` (optionnel)
    - épaisseur de la bordure (float)

`roundedrectangle` définit ces commandes:
 * `size` (optionnel)
    - largeur du rectangle (float)
    - hauteur du rectangle (float)
 * `outline` (optionnel)
    - épaisseur de la bordure (float)
 * `radius` (optionnel)
    - rayon des coins arrondis (float)

`animation`, `ninepatch`, `sprite`, `tilemap`, `capsule`, `circle`, `rectangle` et `roundedrectangle` définissent tous ces commandes:
 * `position` (optionnel)
    - position en x (float)
    - position en y (float)
 * `angle` (optionnel)
    - angle en degrés (float)
 * `flip` (optionnel)
    - retournement horizontal ? (bool)
    - retournement vertical ? (bool)
 * `anchor` (optionnel)
    - point d’ancrage en x (0: gauche, 0.5: centre, 1: droite) (float)
    - point d’ancrage en y (0: haut, 0.5: centre, 1: bas) (float)
 * `pivot` (optionnel)
    - point de rotation en x (0: gauche, 0.5: centre, 1: droite) (float)
    - point de rotation en y (0: haut, 0.5: centre, 1: bas) (float)
 * `blend` (optionnel)
    - blending de l’image (string)
 * `rgb` (optionnel)
    - rouge (0~1) (float)
    - vert (0~1) (float)
    - bleu (0~1) (float)
 * `hsl` (optionnel)
    - teinte (0~360) (float)
    - saturation (0~1) (float)
    - luminance (0~1) (float)
 * `alpha` (optionnel)
    - opacité (0~1) (float)

