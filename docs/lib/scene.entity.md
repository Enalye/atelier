# scene.entity

Élément d’une scène
## Description
```grimoire
var player = @Entity;
player.addImage(@Sprite("player"));
scene.addEntity(player);
```

## Natifs
### Entity
## Constructeurs
|Fonction|Entrée|
|-|-|
|[@**Entity**](#ctor_0)||
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|
|-|-|-|-|-|
|audio|**Entity**|**AudioComponent**|oui|non|
|position|**Entity**|**Vec2\<float>**|oui|oui|
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[addChild](#func_0)|*parent*: **Entity**, *child*: **Entity**||
|[addImage](#func_1)|*entity*: **Entity**, *image*: **Image**||


***
## Description des fonctions

<a id="func_0"></a>
> addChild(*parent*: **Entity**, *child*: **Entity**)

Ajoute une entité en tant qu’enfant de cette entité

<a id="func_1"></a>
> addImage(*entity*: **Entity**, *image*: **Image**)

Ajoute une image à l’entité

