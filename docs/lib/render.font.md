# render.font

Police de caractères
## Natifs
### BitmapFont
Hérite de **Font**
### Font
Hérite de **ImageData**
### PixelFontBordered
Hérite de **Font**
### PixelFontShadowed
Hérite de **Font**
### PixelFontStandard
Hérite de **Font**
### TrueTypeFont
Hérite de **Font**
## Constructeurs
|Fonction|Entrée|
|-|-|
|[@**TrueTypeFont**](#ctor_0)| *name*: **string**|
|[@**BitmapFont**](#ctor_1)| *name*: **string**|
|[@**PixelFontStandard**](#ctor_2)| *ascent*: **int**,  *descent*: **int**,  *lineSkip*: **int**,  *weight*: **int**,  *spacing*: **int**|
|[@**PixelFontShadowed**](#ctor_3)| *ascent*: **int**,  *descent*: **int**,  *lineSkip*: **int**,  *weight*: **int**,  *spacing*: **int**|
|[@**PixelFontBordered**](#ctor_4)| *ascent*: **int**,  *descent*: **int**,  *lineSkip*: **int**,  *weight*: **int**,  *spacing*: **int**|
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[addCharacter](#func_0)|*font*: **BitmapFont**, *ch*: **char**, *advance*: **int**, *offsetX*: **int**, *offsetY*: **int**, *width*: **int**, *height*: **int**, *posX*: **int**, *posY*: **int**, *kerningChar*: **[char]**, *kerningOffset*: **[int]**||
|[addCharacter](#func_1)|*font*: **PixelFontStandard**, *ch*: **char**, *glyphData*: **[int]**, *width*: **int**, *height*: **int**, *descent*: **int**||
|[addCharacter](#func_2)|*font*: **PixelFontShadowed**, *ch*: **char**, *glyphData*: **[int]**, *width*: **int**, *height*: **int**, *descent*: **int**||
|[addCharacter](#func_3)|*font*: **PixelFontBordered**, *ch*: **char**, *glyphData*: **[int]**, *width*: **int**, *height*: **int**, *descent*: **int**||


***
## Description des fonctions

<a id="func_0"></a>
> addCharacter(*font*: **BitmapFont**, *ch*: **char**, *advance*: **int**, *offsetX*: **int**, *offsetY*: **int**, *width*: **int**, *height*: **int**, *posX*: **int**, *posY*: **int**, *kerningChar*: **[char]**, *kerningOffset*: **[int]**)

Ajoute un caractère à la police.

<a id="func_1"></a>
> addCharacter(*font*: **PixelFontStandard**, *ch*: **char**, *glyphData*: **[int]**, *width*: **int**, *height*: **int**, *descent*: **int**)

Ajoute un caractère à la police.

<a id="func_2"></a>
> addCharacter(*font*: **PixelFontShadowed**, *ch*: **char**, *glyphData*: **[int]**, *width*: **int**, *height*: **int**, *descent*: **int**)

Ajoute un caractère à la police.

<a id="func_3"></a>
> addCharacter(*font*: **PixelFontBordered**, *ch*: **char**, *glyphData*: **[int]**, *width*: **int**, *height*: **int**, *descent*: **int**)

Ajoute un caractère à la police.

