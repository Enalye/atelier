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
|Propriété|Natif|Type|Accesseur|Modifieur|Description|
|-|-|-|-|-|-|
|filled|**Circle**|**bool**|oui|oui|Si `true`, le cercle est plein, sinon le cercle est une bordure|
|radius|**Circle**|**float**|oui|oui|Rayon du cercle|
|thickness|**Circle**|**float**|oui|oui|(Seulement si `filled` == false) Épaisseur de la bordure|
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

