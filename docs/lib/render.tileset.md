# render.tileset

Jeu de tuiles
## Description
Tileset est une ressource définie dans un fichier `.res` (voir la page [ressources](/resources#Tileset))
```grimoire
var tileset = @Tileset("terrain");
var tilemap = @Tilemap(tileset, 20, 20);
scene.addEntity(map);
```

## Natifs
### Tileset
## Constructeurs
|Fonction|Entrée|Description|
|-|-|-|
|[@**Tileset**](#ctor_0)| *name*: **string**||
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|Description|
|-|-|-|-|-|-|
|frameTime|**Tileset**|**int**|oui|oui|Durée entre chaque frame|


***
