# render.circle

Cercle
## Description
```grimoire
var circle = @Circle.fill(20f);
circle.anchor = @Vec2f.half;
circle.position = @Vec2f(32f, -48f);
circle.color = @Color.blue;
entity.addImage(circle);
```

## Natifs
### Circle
Hérite de **Image**
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|
|-|-|-|-|-|
|filled|**Circle**|**bool**|oui|oui|
|radius|**Circle**|**float**|oui|oui|
|thickness|**Circle**|**float**|oui|oui|
## Fonctions Statiques
|Fonction|Entrée|Sortie|
|-|-|-|
|[@**Circle**.fill](#static_0)|*radius*: **float**|**Circle**|
|[@**Circle**.outline](#static_1)|*radius*: **float**, *thickness*: **float**|**Circle**|


***
## Description des fonctions statiques

<a id="static_0"></a>
> @**Circle**.fill(*radius*: **float**) (**Circle**)

Construit un cercle plein

<a id="static_1"></a>
> @**Circle**.outline(*radius*: **float**, *thickness*: **float**) (**Circle**)

Construit le contour d’un cercle

