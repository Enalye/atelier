# scene.collider

Objet physique d’une scène
## Natifs
### Collider
### Collision
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|Description|
|-|-|-|-|-|-|
|direction|**Collision**|**Vec2\<int>**|oui|non||
|entity|**Collider**|**Entity?**|oui|oui|Entité lié à l’objet|
|hitbox|**Collider**|**Vec2\<int>**|oui|oui||
|isAlive|**Collider**|**bool**|oui|non||
|name|**Collider**|**string**|oui|oui||
|position|**Collider**|**Vec2\<int>**|oui|oui||
|solid|**Collision**|**Solid**|oui|non||
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[addTag](#func_0)|*collider*: **Collider**, *tag*: **string**||
|[getTags](#func_1)|*collider*: **Collider**||
|[hasTag](#func_2)|*collider*: **Collider**, *tag*: **string**|**bool**|
|[remove](#func_3)|*collider*: **Collider**||


***
## Description des fonctions

<a id="func_0"></a>
> addTag(*collider*: **Collider**, *tag*: **string**)

Ajoute un tag à l’objet

<a id="func_1"></a>
> getTags(*collider*: **Collider**)

Récupère les tags de l’objet

<a id="func_2"></a>
> hasTag(*collider*: **Collider**, *tag*: **string**) (**bool**)

Vérifie si l’objet possède le tag

<a id="func_3"></a>
> remove(*collider*: **Collider**)

Supprime l’objet

