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
|Fonction|Entrée|Description|
|-|-|-|
|[@**UIElement**](#ctor_0)||Crée un élément d’interface|
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|Description|
|-|-|-|-|-|-|
|alignX|**UIElement**|**UIAlignX**|oui|oui|Alignement horizontal|
|alignY|**UIElement**|**UIAlignY**|oui|oui|Alignement vertical|
|alpha|**UIElement**|**float**|oui|oui|Opacité de l’interface|
|angle|**UIElement**|**double**|oui|oui|Rotation de l’interface|
|color|**UIElement**|**Color**|oui|oui|Couleur de l’interface|
|hasFocus|**UIElement**|**bool**|oui|non|Focus ?|
|isActive|**UIElement**|**bool**|oui|oui|Actif ?|
|isEnabled|**UIElement**|**bool**|oui|oui|Active/désactive l’interface|
|isGrabbed|**UIElement**|**bool**|oui|non|L’interface est saisie ?|
|isHovered|**UIElement**|**bool**|oui|non|Survolé ?|
|isPressed|**UIElement**|**bool**|oui|non|Pressé ?|
|isSelected|**UIElement**|**bool**|oui|oui|Sélectionné ?|
|mousePosition|**UIElement**|**Vec2\<float>**|oui|non|Position de la souris dans l’interface|
|pivot|**UIElement**|**Vec2\<float>**|oui|oui|Point de rotation de l’interface|
|position|**UIElement**|**Vec2\<float>**|oui|oui|Position relatif au parent|
|scale|**UIElement**|**Vec2\<float>**|oui|oui|Facteur d’échelle de l’interface|
|size|**UIElement**|**Vec2\<float>**|oui|oui|Taille de l’interface|
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[addEventListener](#func_0)|*ui*: **UIElement**, *id*: **string**, *callback*: **event()**||
|[addImage](#func_1)|*ui*: **UIElement**, *image*: **Image**||
|[addState](#func_2)|*ui*: **UIElement**, *state*: **UIState**||
|[addUI](#func_3)|*parent*: **UIElement**, *child*: **UIElement**||
|[clearUI](#func_4)|*parent*: **UIElement**||
|[remove](#func_5)|*ui*: **UIElement**||
|[removeEventListener](#func_6)|*ui*: **UIElement**, *id*: **string**, *callback*: **event()**||
|[runState](#func_7)|*ui*: **UIElement**, *stateId*: **string**||
|[setAlign](#func_8)|*ui*: **UIElement**, *alignX*: **UIAlignX**, *alignY*: **UIAlignY**||
|[setState](#func_9)|*ui*: **UIElement**, *stateId*: **string**||


***
## Description des fonctions

<a id="func_0"></a>
> addEventListener(*ui*: **UIElement**, *id*: **string**, *callback*: **event()**)

Ajoute une fonction de rappel à un événement.

<a id="func_1"></a>
> addImage(*ui*: **UIElement**, *image*: **Image**)

Ajoute une image à l’interface.

<a id="func_2"></a>
> addState(*ui*: **UIElement**, *state*: **UIState**)

Ajoute un état à l’interface.

<a id="func_3"></a>
> addUI(*parent*: **UIElement**, *child*: **UIElement**)

Ajoute une interface en tant qu’enfant de cette interface.

<a id="func_4"></a>
> clearUI(*parent*: **UIElement**)

Supprime les éléments d’interface enfants du parent.

<a id="func_5"></a>
> remove(*ui*: **UIElement**)

Retire l’interface de l’arborescence.

<a id="func_6"></a>
> removeEventListener(*ui*: **UIElement**, *id*: **string**, *callback*: **event()**)

Supprime une fonction de rappel lié à un événement.

<a id="func_7"></a>
> runState(*ui*: **UIElement**, *stateId*: **string**)

Démarre la transition de l’interface de son état actuel vers son prochain état.

<a id="func_8"></a>
> setAlign(*ui*: **UIElement**, *alignX*: **UIAlignX**, *alignY*: **UIAlignY**)

Fixe l’alignement de l’interface.

Détermine à partir d’où la position de l’interface sera calculé par rapport au parent.

<a id="func_9"></a>
> setState(*ui*: **UIElement**, *stateId*: **string**)

Fixe l’état actuel de l’interface sans transition.

