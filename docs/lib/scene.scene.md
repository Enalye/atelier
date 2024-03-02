# scene.scene

Défini un calque où évolue des entités
## Description
```grimoire
var scene = @Scene;
addScene(scene);
```

## Natifs
### Scene
## Constructeurs
|Fonction|Entrée|Description|
|-|-|-|
|[@**Scene**](#ctor_0)|||
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|Description|
|-|-|-|-|-|-|
|canvas|**Scene**|**Canvas**|oui|non||
|isVisible|**Scene**|**bool**|oui|oui||
|name|**Scene**|**string**|oui|oui||
|position|**Scene**|**Vec2\<float>**|oui|oui||
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[addEntity](#func_0)|*scene*: **Scene**, *entity*: **Entity**||
|[addParticleSource](#func_1)|*scene*: **Scene**, *source*: **ParticleSource**||
|[addScene](#func_2)|*scene*: **Scene**||
|[addTag](#func_3)|*scene*: **Scene**, *tag*: **string**||
|[addUI](#func_4)|*scene*: **Scene**, *ui*: **UIElement**||
|[clearUI](#func_5)|*scene*: **Scene**||
|[fetchEntitiesByTag](#func_6)|*tags*: **[string]**|**[Entity]**|
|[fetchEntitiesByTag](#func_7)|*tags*: **Scene**, *param1*: **[string]**|**[Entity]**|
|[fetchEntityByName](#func_8)|*name*: **string**|**Entity?**|
|[fetchEntityByName](#func_9)|*name*: **Scene**, *param1*: **string**|**Entity?**|
|[fetchParticleSourceByName](#func_10)|*name*: **string**|**ParticleSource?**|
|[fetchParticleSourceByName](#func_11)|*name*: **Scene**, *param1*: **string**|**ParticleSource?**|
|[fetchParticleSourcesByTag](#func_12)|*tags*: **[string]**|**[ParticleSource]**|
|[fetchParticleSourcesByTag](#func_13)|*tags*: **Scene**, *param1*: **[string]**|**[ParticleSource]**|
|[fetchSceneByName](#func_14)|*name*: **string**|**Scene?**|
|[fetchScenesByTag](#func_15)|*tags*: **[string]**|**[Scene]**|
|[getTags](#func_16)|*scene*: **Scene**|**[string]**|
|[hasTag](#func_17)|*scene*: **Scene**, *tag*: **string**|**bool**|
|[loadLevel](#func_18)|*name*: **string**||


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
> addTag(*scene*: **Scene**, *tag*: **string**)

Ajoute un tag à la scène

<a id="func_4"></a>
> addUI(*scene*: **Scene**, *ui*: **UIElement**)

Ajoute un élément d’interface à la scène

<a id="func_5"></a>
> clearUI(*scene*: **Scene**)

Supprime les élements d’interface de la scène

<a id="func_6"></a>
> fetchEntitiesByTag(*tags*: **[string]**) (**[Entity]**)

Récupère les entités possédants le tag indiqué

<a id="func_7"></a>
> fetchEntitiesByTag(*tags*: **Scene**, *param1*: **[string]**) (**[Entity]**)

Récupère les entités possédants le tag indiqué dans la scène

<a id="func_8"></a>
> fetchEntityByName(*name*: **string**) (**Entity?**)

Récupère l’entité correspondant au nom donné parmi toutes les scènes

<a id="func_9"></a>
> fetchEntityByName(*name*: **Scene**, *param1*: **string**) (**Entity?**)

Récupère l’entité correspondant au nom donné dans la scène

<a id="func_10"></a>
> fetchParticleSourceByName(*name*: **string**) (**ParticleSource?**)

Récupère l’entité correspondant au nom donné parmi toutes les scènes

<a id="func_11"></a>
> fetchParticleSourceByName(*name*: **Scene**, *param1*: **string**) (**ParticleSource?**)

Récupère l’entité correspondant au nom donné dans la scène

<a id="func_12"></a>
> fetchParticleSourcesByTag(*tags*: **[string]**) (**[ParticleSource]**)

Récupère les entités possédants le tag indiqué

<a id="func_13"></a>
> fetchParticleSourcesByTag(*tags*: **Scene**, *param1*: **[string]**) (**[ParticleSource]**)

Récupère les entités possédants le tag indiqué dans la scène

<a id="func_14"></a>
> fetchSceneByName(*name*: **string**) (**Scene?**)

Récupère la scène correspondant au nom donné

<a id="func_15"></a>
> fetchScenesByTag(*tags*: **[string]**) (**[Scene]**)

Récupère les scènes possédants le tag indiqué

<a id="func_16"></a>
> getTags(*scene*: **Scene**) (**[string]**)

Récupère les tags de la scène

<a id="func_17"></a>
> hasTag(*scene*: **Scene**, *tag*: **string**) (**bool**)

Vérifie si la scène possède le tag

<a id="func_18"></a>
> loadLevel(*name*: **string**)

Charge un niveau

