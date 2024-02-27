# render.tilemap

Grille de tuiles alignées
## Description

```grimoire
var tileset = @Tileset("terrain");
var tilemap = @Tilemap(tileset, 20, 20);

// Tilemap peut également être définie en ressource
var tilemap = @Tilemap("terrain");

// Change la tuile {0;2} à 1
tilemap.setTile(0, 2, 1);

var map = @Entity;
map.addImage(tilemap);
scene.addEntity(map);
```

## Natifs
### Tilemap
Hérite de **Image**
## Constructeurs
|Fonction|Entrée|Description|
|-|-|-|
|[@**Tilemap**](#ctor_0)| *tileset*: **Tileset**,  *width*: **int**,  *height*: **int**|Crée une tilemap depuis un tileset|
|[@**Tilemap**](#ctor_1)| *name*: **string**|Charge la ressource|
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|Description|
|-|-|-|-|-|-|
|size|**Tilemap**|**Vec2\<float>**|oui|oui|Taille d’une tuile|
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[getTile](#func_0)|*x*: **Tilemap**, *y*: **int**, *param2*: **int**|**int**|
|[setTile](#func_1)|*x*: **Tilemap**, *y*: **int**, *tile*: **int**, *param3*: **int**||


***
## Description des fonctions

<a id="func_0"></a>
> getTile(*x*: **Tilemap**, *y*: **int**, *param2*: **int**) (**int**)

Récupère la tuile à la position donnée

<a id="func_1"></a>
> setTile(*x*: **Tilemap**, *y*: **int**, *tile*: **int**, *param3*: **int**)

Change la tuile à la position donnée

