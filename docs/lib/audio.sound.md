# audio.sound

Représente un fichier audio.
Le son est entièrement décodé en mémoire.
Il est recommandé de reserver cette classe pour des fichiers peu volumineux.
## Description
Sound est une ressource définie dans un fichier `.ffd` (voir la page [ressources](/resources#Sound)).

## Natifs
### Sound
## Constructeurs
|Fonction|Entrée|Description|
|-|-|-|
|[@**Sound**](#ctor_0)| *param0*: **string**||
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[play](#func_0)|*sound*: **Sound**||


***
## Description des fonctions

<a id="func_0"></a>
> play(*sound*: **Sound**)

Lance la lecture sur le bus `master`.

