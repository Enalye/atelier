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
|Fonction|Entrée|Description|
|-|-|-|
|[@**Entity**](#ctor_0)|||
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|Description|
|-|-|-|-|-|-|
|audio|**Entity**|**AudioComponent**|oui|non||
|name|**Entity**|**string**|oui|oui||
|position|**Entity**|**Vec2\<float>**|oui|oui||
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[addChild](#func_0)|*parent*: **Entity**, *child*: **Entity**||
|[addImage](#func_1)|*entity*: **Entity**, *image*: **Image**||
|[addTag](#func_2)|*scene*: **Entity**, *tag*: **string**||
|[getCanvas](#func_3)|*entity*: **Entity**, *param1*: **Canvas?**||
|[getTags](#func_4)|*scene*: **Entity**||
|[hasTag](#func_5)|*scene*: **Entity**, *tag*: **string**|**bool**|
|[removeCanvas](#func_6)|*entity*: **Entity**||
|[setCanvas](#func_7)|*entity*: **Entity**, *width*: **uint**, *height*: **uint**||


***
## Description des fonctions

<a id="func_0"></a>
> addChild(*parent*: **Entity**, *child*: **Entity**)

Ajoute une entité en tant qu’enfant de cette entité

<a id="func_1"></a>
> addImage(*entity*: **Entity**, *image*: **Image**)

Ajoute une image à l’entité

<a id="func_2"></a>
> addTag(*scene*: **Entity**, *tag*: **string**)

Ajoute un tag à l’entité

<a id="func_3"></a>
> getCanvas(*entity*: **Entity**, *param1*: **Canvas?**)

Retourne le canvas de rendu de l’entité

<a id="func_4"></a>
> getTags(*scene*: **Entity**)

Récupère les tags de l’entité

<a id="func_5"></a>
> hasTag(*scene*: **Entity**, *tag*: **string**) (**bool**)

Vérifie si l’entité possède le tag

<a id="func_6"></a>
> removeCanvas(*entity*: **Entity**)

Supprime le canvas de l’entité

<a id="func_7"></a>
> setCanvas(*entity*: **Entity**, *width*: **uint**, *height*: **uint**)

Crée un canvas de rendu de l’entité

