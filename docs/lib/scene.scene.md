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
|isAlive|**Scene**|**bool**|oui|non||
|isVisible|**Scene**|**bool**|oui|oui||
|name|**Scene**|**string**|oui|oui||
|position|**Scene**|**Vec2\<float>**|oui|oui||
|zOrder|**Entity**|**int**|oui|oui||
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[addActor](#func_0)|*scene*: **Scene**, *actor*: **Actor**||
|[addEntity](#func_1)|*scene*: **Scene**, *entity*: **Entity**||
|[addParticleSource](#func_2)|*scene*: **Scene**, *source*: **ParticleSource**||
|[addSolid](#func_3)|*scene*: **Scene**, *solid*: **Solid**||
|[addTag](#func_4)|*scene*: **Scene**, *tag*: **string**||
|[addUI](#func_5)|*scene*: **Scene**, *ui*: **UIElement**||
|[clearUI](#func_6)|*scene*: **Scene**||
|[fetchEntitiesByTag](#func_7)|*tags*: **Scene**, *param1*: **[string]**|**[Entity]**|
|[fetchEntityByName](#func_8)|*name*: **Scene**, *param1*: **string**|**Entity?**|
|[fetchParticleSourceByName](#func_9)|*name*: **Scene**, *param1*: **string**|**ParticleSource?**|
|[fetchParticleSourcesByTag](#func_10)|*tags*: **Scene**, *param1*: **[string]**|**[ParticleSource]**|
|[getTags](#func_11)|*scene*: **Scene**|**[string]**|
|[hasTag](#func_12)|*scene*: **Scene**, *tag*: **string**|**bool**|
|[remove](#func_13)|*scene*: **Scene**||


***
## Description des fonctions

<a id="func_0"></a>
> addActor(*scene*: **Scene**, *actor*: **Actor**)

Ajoute un acteur à la scène

<a id="func_1"></a>
> addEntity(*scene*: **Scene**, *entity*: **Entity**)

Ajoute une entité à la scène

<a id="func_2"></a>
> addParticleSource(*scene*: **Scene**, *source*: **ParticleSource**)

Ajoute une source de particules à la scène

<a id="func_3"></a>
> addSolid(*scene*: **Scene**, *solid*: **Solid**)

Ajoute un solide à la scène

<a id="func_4"></a>
> addTag(*scene*: **Scene**, *tag*: **string**)

Ajoute un tag à la scène

<a id="func_5"></a>
> addUI(*scene*: **Scene**, *ui*: **UIElement**)

Ajoute un élément d’interface à la scène

<a id="func_6"></a>
> clearUI(*scene*: **Scene**)

Supprime les élements d’interface de la scène

<a id="func_7"></a>
> fetchEntitiesByTag(*tags*: **Scene**, *param1*: **[string]**) (**[Entity]**)

Récupère les entités possédants le tag indiqué dans la scène

<a id="func_8"></a>
> fetchEntityByName(*name*: **Scene**, *param1*: **string**) (**Entity?**)

Récupère l’entité correspondant au nom donné dans la scène

<a id="func_9"></a>
> fetchParticleSourceByName(*name*: **Scene**, *param1*: **string**) (**ParticleSource?**)

Récupère l’entité correspondant au nom donné dans la scène

<a id="func_10"></a>
> fetchParticleSourcesByTag(*tags*: **Scene**, *param1*: **[string]**) (**[ParticleSource]**)

Récupère les entités possédants le tag indiqué dans la scène

<a id="func_11"></a>
> getTags(*scene*: **Scene**) (**[string]**)

Récupère les tags de la scène

<a id="func_12"></a>
> hasTag(*scene*: **Scene**, *tag*: **string**) (**bool**)

Vérifie si la scène possède le tag

<a id="func_13"></a>
> remove(*scene*: **Scene**)

Supprime la scène

