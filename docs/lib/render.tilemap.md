# render.tilemap

Grille de tuiles alignées
## Description

```grimoire
var tileset = @Tileset("terrain");
var tilemap = @Tilemap(tileset, 20, 20);

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
|Fonction|Entrée|
|-|-|
|[@**Tilemap**](#ctor_0)| *param0*: **Tileset**,  *param1*: **int**,  *param2*: **int**|
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|
|-|-|-|-|-|
|size|**Tilemap**|**Vec2\<float>**|oui|oui|
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[setTile](#func_0)|*x*: **Tilemap**, *y*: **int**, *tile*: **int**, *param3*: **int**||


***
## Description des fonctions

<a id="func_0"></a>
> setTile(*x*: **Tilemap**, *y*: **int**, *tile*: **int**, *param3*: **int**)

Change la tuile à la position donnée

