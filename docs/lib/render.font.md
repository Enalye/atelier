# render.font

Polices de caractères
## Description
TrueTypeFont est une ressource définie dans un fichier `.ffd` (voir la page [ressources](/resources#TrueType)).

BitmapFont est une ressource définie dans un fichier `.ffd` (voir la page [ressources](/resources#BitmapFont)).

PixelFont permet de définir des polices directement en code.

## Énumérations
|Énumération|Valeurs|Description|
|-|-|-|
|PixelFontStyle|{standard, shadowed, bordered}|Style de police|
## Natifs
### BitmapFont
Hérite de **Font**
### Font
Hérite de **ImageData**
### PixelFont
Hérite de **Font**
### TrueTypeFont
Hérite de **Font**
## Constructeurs
|Fonction|Entrée|Description|
|-|-|-|
|[@**TrueTypeFont**](#ctor_0)| *name*: **string**|Style de police|
|[@**BitmapFont**](#ctor_1)| *name*: **string**|Style de police|
|[@**PixelFont**](#ctor_2)| *ascent*: **int**,  *descent*: **int**,  *lineSkip*: **int**,  *weight*: **int**,  *spacing*: **int**,  *style*: **PixelFontStyle**|Style de police|
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[addCharacter](#func_0)|*font*: **BitmapFont**, *ch*: **char**, *advance*: **int**, *offsetX*: **int**, *offsetY*: **int**, *width*: **int**, *height*: **int**, *posX*: **int**, *posY*: **int**, *kerningChar*: **[char]**, *kerningOffset*: **[int]**||
|[addCharacter](#func_1)|*font*: **PixelFont**, *ch*: **char**, *glyphData*: **[int]**, *width*: **int**, *height*: **int**, *descent*: **int**||


***
## Description des fonctions

<a id="func_0"></a>
> addCharacter(*font*: **BitmapFont**, *ch*: **char**, *advance*: **int**, *offsetX*: **int**, *offsetY*: **int**, *width*: **int**, *height*: **int**, *posX*: **int**, *posY*: **int**, *kerningChar*: **[char]**, *kerningOffset*: **[int]**)

Ajoute un caractère à la police.

<a id="func_1"></a>
> addCharacter(*font*: **PixelFont**, *ch*: **char**, *glyphData*: **[int]**, *width*: **int**, *height*: **int**, *descent*: **int**)

Ajoute un caractère à la police.

