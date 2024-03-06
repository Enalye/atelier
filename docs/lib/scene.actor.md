# scene.actor

Acteur physique d’une scène
## Natifs
### Actor
Hérite de **Collider**
## Constructeurs
|Fonction|Entrée|Description|
|-|-|-|
|[@**Actor**](#ctor_0)|||
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[dismount](#func_0)|*actor*: **Actor**||
|[mount](#func_1)|*actor*: **Actor**, *solid*: **Solid**||
|[moveX](#func_2)|*actor*: **Actor**, *x*: **float**|**CollisionData?**|
|[moveY](#func_3)|*actor*: **Actor**, *y*: **float**|**CollisionData?**|


***
## Description des fonctions

<a id="func_0"></a>
> dismount(*actor*: **Actor**)

Détache l’acteur du solide

<a id="func_1"></a>
> mount(*actor*: **Actor**, *solid*: **Solid**)

Attache l’acteur au solide

<a id="func_2"></a>
> moveX(*actor*: **Actor**, *x*: **float**) (**CollisionData?**)

Déplace horizontalement l’acteur et retourne des informations de collision si un solide est touché.

<a id="func_3"></a>
> moveY(*actor*: **Actor**, *y*: **float**) (**CollisionData?**)

Déplace verticalement l’acteur et retourne des informations de collision si un solide est touché.

