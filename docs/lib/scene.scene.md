# scene.scene

Défini une caméra où évolue des entités
## Description
```grimoire
var scene = @Scene(@App.width, @App.height);
addScene(scene);
```

## Natifs
### Scene
## Constructeurs
|Fonction|Entrée|Description|
|-|-|-|
|[@**Scene**](#ctor_0)| *width*: **int**,  *height*: **int**||
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|Description|
|-|-|-|-|-|-|
|canvas|**Entity**|**Canvas**|oui|non||
|isVisible|**Entity**|**bool**|oui|oui||
|position|**Scene**|**Vec2\<float>**|oui|oui||
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[addEntity](#func_0)|*scene*: **Scene**, *entity*: **Entity**||
|[addParticleSource](#func_1)|*scene*: **Scene**, *source*: **ParticleSource**||
|[addScene](#func_2)|*scene*: **Scene**||
|[addUI](#func_3)|*scene*: **Scene**, *ui*: **UIElement**||
|[clearUI](#func_4)|*scene*: **Scene**||


***
## Description des fonctions

<a id="func_0"></a>
> addEntity(*scene*: **Scene**, *entity*: **Entity**)

Ajoute une entité à la scène

<a id="func_1"></a>
> addParticleSource(*scene*: **Scene**, *source*: **ParticleSource**)

Ajoute une source de particules à la scène

<a id="func_2"></a>
> addScene(*scene*: **Scene**)

Ajoute une scène à l’application

<a id="func_3"></a>
> addUI(*scene*: **Scene**, *ui*: **UIElement**)

Ajoute un élément d’interface à la scène

<a id="func_4"></a>
> clearUI(*scene*: **Scene**)

Supprime les élements d’interface de la scène

