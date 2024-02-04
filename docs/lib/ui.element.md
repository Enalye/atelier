# ui.element

Élément d’interface
## Énumérations
|Énumération|Valeurs|Description|
|-|-|-|
|UIAlignX|{left, center, right}|Alignement horizontal|
|UIAlignY|{top, center, bottom}|Alignement vertical|
## Natifs
### UIElement
Alignement vertical
## Constructeurs
|Fonction|Entrée|
|-|-|
|[@**UIElement**](#ctor_0)||
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|
|-|-|-|-|-|
|alignX|**UIElement**|**UIAlignX**|oui|oui|
|alignY|**UIElement**|**UIAlignY**|oui|oui|
|alpha|**UIElement**|**float**|oui|oui|
|angle|**UIElement**|**double**|oui|oui|
|pivot|**UIElement**|**Vec2\<float>**|oui|oui|
|position|**UIElement**|**Vec2\<float>**|oui|oui|
|scale|**UIElement**|**Vec2\<float>**|oui|oui|
|size|**UIElement**|**Vec2\<float>**|oui|oui|
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[addElement](#func_0)|*ui*: **UIElement**, *image*: **UIElement**||
|[addEventListener](#func_1)|*ui*: **UIElement**, *id*: **string**, *callback*: **event()**||
|[addImage](#func_2)|*ui*: **UIElement**, *image*: **Image**||
|[addState](#func_3)|*ui*: **UIElement**, *state*: **UIState**||
|[remove](#func_4)|*ui*: **UIElement**||
|[removeEventListener](#func_5)|*ui*: **UIElement**, *id*: **string**, *callback*: **event()**||
|[runState](#func_6)|*ui*: **UIElement**, *stateId*: **string**||
|[setAlign](#func_7)|*ui*: **UIElement**, *alignX*: **UIAlignX**, *alignY*: **UIAlignY**||
|[setState](#func_8)|*ui*: **UIElement**, *stateId*: **string**||


***
## Description des fonctions

<a id="func_0"></a>
> addElement(*ui*: **UIElement**, *image*: **UIElement**)

Ajoute une interface en tant qu’enfant de cette interface

<a id="func_1"></a>
> addEventListener(*ui*: **UIElement**, *id*: **string**, *callback*: **event()**)

Ajoute une fonction de rappel à un événement

<a id="func_2"></a>
> addImage(*ui*: **UIElement**, *image*: **Image**)

Ajoute une image à l’interface

<a id="func_3"></a>
> addState(*ui*: **UIElement**, *state*: **UIState**)

Ajoute un état à l’interface

<a id="func_4"></a>
> remove(*ui*: **UIElement**)

Retire l’interface de l’arborescence

<a id="func_5"></a>
> removeEventListener(*ui*: **UIElement**, *id*: **string**, *callback*: **event()**)

Supprime une fonction de rappel lié à un événement

<a id="func_6"></a>
> runState(*ui*: **UIElement**, *stateId*: **string**)

Démarre la transition de l’interface de son état actuel vers son prochain état.

<a id="func_7"></a>
> setAlign(*ui*: **UIElement**, *alignX*: **UIAlignX**, *alignY*: **UIAlignY**)

Fixe l’alignement de l’interface.

Détermine à partir d’où la position de l’interface sera calculé par rapport au parent.

<a id="func_8"></a>
> setState(*ui*: **UIElement**, *stateId*: **string**)

Fixe l’état actuel de l’interface sans transition

