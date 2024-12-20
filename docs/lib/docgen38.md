# docgen38

## Natifs
### Level
## Fonctions Statiques
|Fonction|Entrée|Sortie|
|-|-|-|
|[@**Level**.load](#static_0)|*rid*: **string**||
|[@**Level**.addScene](#static_1)|*scene*: **Scene**||
|[@**Level**.fetchSceneByName](#static_2)|*name*: **string**|**Scene?**|
|[@**Level**.fetchScenesByTag](#static_3)|*tags*: **[string]**|**[Scene]**|
|[@**Level**.fetchEntityByName](#static_4)|*name*: **string**|**Entity?**|
|[@**Level**.fetchEntitiesByTag](#static_5)|*tags*: **[string]**|**[Entity]**|
|[@**Level**.fetchParticleSourceByName](#static_6)|*name*: **string**|**ParticleSource?**|
|[@**Level**.fetchParticleSourcesByTag](#static_7)|*tags*: **[string]**|**[ParticleSource]**|


***
## Description des fonctions statiques

<a id="static_0"></a>
> @**Level**.load(*rid*: **string**)

Charge un niveau

<a id="static_1"></a>
> @**Level**.addScene(*scene*: **Scene**)

Ajoute une scène au niveau

<a id="static_2"></a>
> @**Level**.fetchSceneByName(*name*: **string**) (**Scene?**)

Récupère la scène correspondant au nom donné

<a id="static_3"></a>
> @**Level**.fetchScenesByTag(*tags*: **[string]**) (**[Scene]**)

Récupère les scènes possédants le tag indiqué

<a id="static_4"></a>
> @**Level**.fetchEntityByName(*name*: **string**) (**Entity?**)

Récupère l’entité correspondant au nom donné parmi toutes les scènes

<a id="static_5"></a>
> @**Level**.fetchEntitiesByTag(*tags*: **[string]**) (**[Entity]**)

Récupère les entités possédants le tag indiqué

<a id="static_6"></a>
> @**Level**.fetchParticleSourceByName(*name*: **string**) (**ParticleSource?**)

Récupère l’entité correspondant au nom donné parmi toutes les scènes

<a id="static_7"></a>
> @**Level**.fetchParticleSourcesByTag(*tags*: **[string]**) (**[ParticleSource]**)

Récupère les entités possédants le tag indiqué

