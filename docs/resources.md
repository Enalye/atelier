# Ressources

Les ressources représentent tous les données externes au code qui ont besoin d’être chargé par l’application

Ces ressources sont décrites au sein de fichiers [farfadets](https://github.com/Enalye/farfadet) avec l’extension `.res`.

Chaque ressource est définie par un bloc avec la syntaxe suivante:
```
TYPE_RESSOURCE NOM_RESSOURCE {
    [PARAMÈTRES…]
}
```

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
    - nom de la texture (string)
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
    - nom de la texture (string)
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
    - nom de la texture (string)
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
Les tilesets permettent de répéter certains sprites (tuiles) sous forme d’une grille.

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
    - nom de la texture (string)
 * `clip` (optionnel) Position du premier sprite
    - x (int)
    - y (int)
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
    - nom de la texture (string)
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