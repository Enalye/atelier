# scene.level

Niveau actuel
## Natifs
### Level
## Fonctions Statiques
|Fonction|Entrée|Sortie|
|-|-|-|
|[@**Level**.load](#static_0)|*rid*: **string**||
|[@**Level**.addScene](#static_1)|*scene*: **Scene**||
|[@**Level**.findSceneByName](#static_2)|*name*: **string**|**Scene?**|
|[@**Level**.findScenesByTag](#static_3)|*tags*: **[string]**|**[Scene]**|
|[@**Level**.findEntityByName](#static_4)|*name*: **string**|**Entity?**|
|[@**Level**.findEntitiesByTag](#static_5)|*tags*: **[string]**|**[Entity]**|
|[@**Level**.findParticleSourceByName](#static_6)|*name*: **string**|**ParticleSource?**|
|[@**Level**.findParticleSourcesByTag](#static_7)|*tags*: **[string]**|**[ParticleSource]**|
|[@**Level**.findActorByName](#static_8)|*name*: **string**|**Actor?**|
|[@**Level**.findActorsByTag](#static_9)|*tags*: **[string]**|**[Actor]**|
|[@**Level**.findSolidByName](#static_10)|*name*: **string**|**Solid?**|
|[@**Level**.findSolidsByTag](#static_11)|*tags*: **[string]**|**[Solid]**|


***
## Description des fonctions statiques

<a id="static_0"></a>
> @**Level**.load(*rid*: **string**)

Charge un niveau

<a id="static_1"></a>
> @**Level**.addScene(*scene*: **Scene**)

Ajoute une scène au niveau

<a id="static_2"></a>
> @**Level**.findSceneByName(*name*: **string**) (**Scene?**)

Récupère la scène correspondant au nom donné

<a id="static_3"></a>
> @**Level**.findScenesByTag(*tags*: **[string]**) (**[Scene]**)

Récupère les scènes possédants le tag indiqué

<a id="static_4"></a>
> @**Level**.findEntityByName(*name*: **string**) (**Entity?**)

Récupère l’entité correspondant au nom donné parmi toutes les scènes

<a id="static_5"></a>
> @**Level**.findEntitiesByTag(*tags*: **[string]**) (**[Entity]**)

Récupère les entités possédants le tag indiqué

<a id="static_6"></a>
> @**Level**.findParticleSourceByName(*name*: **string**) (**ParticleSource?**)

Récupère la source correspondant au nom donné parmi toutes les scènes

<a id="static_7"></a>
> @**Level**.findParticleSourcesByTag(*tags*: **[string]**) (**[ParticleSource]**)

Récupère les sources possédants le tag indiqué

<a id="static_8"></a>
> @**Level**.findActorByName(*name*: **string**) (**Actor?**)

Récupère l’acteur correspondant au nom donné parmi toutes les scènes

<a id="static_9"></a>
> @**Level**.findActorsByTag(*tags*: **[string]**) (**[Actor]**)

Récupère les acteurs possédants le tag indiqué

<a id="static_10"></a>
> @**Level**.findSolidByName(*name*: **string**) (**Solid?**)

Récupère le solide correspondant au nom donné parmi toutes les scènes

<a id="static_11"></a>
> @**Level**.findSolidsByTag(*tags*: **[string]**) (**[Solid]**)

Récupère les solides possédants le tag indiqué

