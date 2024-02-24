# render.roundedrectangle

Rectangle avec bords arrondis
## Description
```grimoire
var rect = @RoundedRectangle.fill(200f, 50f, 5f);
rect.anchor = @Vec2f.zero;
rect.position = @Vec2f.zero;
rect.color = @Color.red;
entity.addImage(rect);
```

## Natifs
### RoundedRectangle
Hérite de **Image**
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|Description|
|-|-|-|-|-|-|
|filled|**RoundedRectangle**|**bool**|oui|oui|Si `true`, le rectangle est plein, sinon le rectangle est une bordure|
|radius|**RoundedRectangle**|**float**|oui|oui|Rayon des coins du rectangle|
|size|**RoundedRectangle**|**Vec2\<float>**|oui|oui|Taille du rectangle|
|thickness|**RoundedRectangle**|**float**|oui|oui|(Seulement si `filled` == false) Épaisseur de la bordure|
## Fonctions Statiques
|Fonction|Entrée|Sortie|
|-|-|-|
|[@**RoundedRectangle**.fill](#static_0)|*x*: **float**, *y*: **float**, *radius*: **float**|**RoundedRectangle**|
|[@**RoundedRectangle**.outline](#static_1)|*x*: **float**, *y*: **float**, *radius*: **float**, *thickness*: **float**|**RoundedRectangle**|


***
## Description des fonctions statiques

<a id="static_0"></a>
> @**RoundedRectangle**.fill(*x*: **float**, *y*: **float**, *radius*: **float**) (**RoundedRectangle**)

Construit un rectangle arrondi plein

<a id="static_1"></a>
> @**RoundedRectangle**.outline(*x*: **float**, *y*: **float**, *radius*: **float**, *thickness*: **float**) (**RoundedRectangle**)

Construit le contour d’un rectangle arrondi

