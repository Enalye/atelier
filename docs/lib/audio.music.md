# audio.music

Représente un fichier audio
## Natifs
### Music
## Constructeurs
|Fonction|Entrée|
|-|-|
|[@**Music**](#ctor_0)| *param0*: **string**|
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[pauseTrack](#func_0)|*fadeOut*: **float**||
|[play](#func_1)|*music*: **Music**||
|[playTrack](#func_2)|*music*: **Music**, *fadeOut*: **float**||
|[popTrack](#func_3)|*fadeOut*: **float**, *delay*: **float**, *fadeIn*: **float**||
|[pushTrack](#func_4)|*music*: **Music**, *fadeOut*: **float**||
|[resumeTrack](#func_5)|*fadeIn*: **float**||
|[stopTrack](#func_6)|*fadeOut*: **float**||


***
## Description des fonctions

<a id="func_0"></a>
> pauseTrack(*fadeOut*: **float**)

Met en pause la piste musicale en cours avec un fondu de `fadeOut` secondes.

<a id="func_1"></a>
> play(*music*: **Music**)

Lance directement la lecture d’une musique.

<a id="func_2"></a>
> playTrack(*music*: **Music**, *fadeOut*: **float**)

Joue une nouvelle piste musical.

À la différence de `play` les fonctions comme `playTrack` et `pushTrack` sont limitées à une seule musique en même temps.

Jouer une nouvelle musique remplacera celle en cours et s’occupera de faire la transition entre les deux musiques automatiquement durant `fadeOut` secondes (grace à `AudioFader`).

Si aucune piste n’est en cours, la musique se lancera directement.

<a id="func_3"></a>
> popTrack(*fadeOut*: **float**, *delay*: **float**, *fadeIn*: **float**)

Termine la piste musicale en cours et reprend la dernière piste musicale interrompu via `pushTrack`.

<a id="func_4"></a>
> pushTrack(*music*: **Music**, *fadeOut*: **float**)

Remplace temporairement la piste musicale en cours par une nouvelle musique avec un fondu de `fadeOut` secondes.

Pour redémarrer l’ancienne piste à l’endroit où elle a été interrompu, il suffit d’appeler la fonction `popTrack`.

<a id="func_5"></a>
> resumeTrack(*fadeIn*: **float**)

Redémarre la piste en cours là où elle s’était arrêtée avec un fondu de `fadeIn` secondes.

<a id="func_6"></a>
> stopTrack(*fadeOut*: **float**)

Interromp la piste musicale en cours avec un fondu de `fadeOut` secondes.

