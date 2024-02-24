# render.capsule

Capsule
## Description
```grimoire
var capsule = @Capsule.outline(200f, 50f, 5f);
capsule.anchor = @Vec2f.half;
capsule.position = @Vec2f.zero;
capsule.color = @Color.red;
entity.addImage(capsule);
```

## Natifs
### Capsule
Hérite de **Image**
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|
|-|-|-|-|-|
|filled|**Capsule**|**bool**|oui|oui|
|size|**Capsule**|**Vec2\<float>**|oui|oui|
|thickness|**Capsule**|**float**|oui|oui|
## Fonctions Statiques
|Fonction|Entrée|Sortie|
|-|-|-|
|[@**Capsule**.fill](#static_0)|*x*: **float**, *y*: **float**|**Capsule**|
|[@**Capsule**.outline](#static_1)|*x*: **float**, *y*: **float**, *thickness*: **float**|**Capsule**|


***
## Description des fonctions statiques

<a id="static_0"></a>
> @**Capsule**.fill(*x*: **float**, *y*: **float**) (**Capsule**)

Construit une capsule pleine

<a id="static_1"></a>
> @**Capsule**.outline(*x*: **float**, *y*: **float**, *thickness*: **float**) (**Capsule**)

Construit le contour d’une capsule

