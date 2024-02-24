# render.rectangle

Rectangle
## Description
```grimoire
var rect = @Rectangle.fill(200f, 50f);
rect.anchor = @Vec2f.zero;
rect.position = @Vec2f.zero;
rect.color = @Color.red;
entity.addImage(rect);
```

## Natifs
### Rectangle
Hérite de **Image**
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|
|-|-|-|-|-|
|filled|**Rectangle**|**bool**|oui|oui|
|size|**Rectangle**|**Vec2\<float>**|oui|oui|
|thickness|**Rectangle**|**float**|oui|oui|
## Fonctions Statiques
|Fonction|Entrée|Sortie|
|-|-|-|
|[@**Rectangle**.fill](#static_0)|*x*: **float**, *y*: **float**|**Rectangle**|
|[@**Rectangle**.outline](#static_1)|*x*: **float**, *y*: **float**, *thickness*: **float**|**Rectangle**|


***
## Description des fonctions statiques

<a id="static_0"></a>
> @**Rectangle**.fill(*x*: **float**, *y*: **float**) (**Rectangle**)

Construit un rectangle plein

<a id="static_1"></a>
> @**Rectangle**.outline(*x*: **float**, *y*: **float**, *thickness*: **float**) (**Rectangle**)

Construit le contour d’un rectangle

