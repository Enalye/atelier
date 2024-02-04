# scene.component

Composant d’une entité
## Natifs
### AudioComponent
Hérite de **EntityComponent**
### EntityComponent
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[addEffect](#func_0)|*audio*: **AudioComponent**, *effect*: **AudioEffect**||
|[connectTo](#func_1)|*audio*: **AudioComponent**, *bus*: **AudioBus**||
|[connectToMaster](#func_2)|*audio*: **AudioComponent**||
|[disconnect](#func_3)|*audio*: **AudioComponent**||
|[play](#func_4)|*audio*: **AudioComponent**, *sound*: **Sound**||
|[play](#func_5)|*audio*: **AudioComponent**, *music*: **Music**||
|[play](#func_6)|*audio*: **AudioComponent**, *player*: **AudioPlayer**||


***
## Description des fonctions

<a id="func_0"></a>
> addEffect(*audio*: **AudioComponent**, *effect*: **AudioEffect**)

Ajoute un effet audio au bus audio de l’entité

<a id="func_1"></a>
> connectTo(*audio*: **AudioComponent**, *bus*: **AudioBus**)

Connecte le bus audio de l’entité à un autre bus

<a id="func_2"></a>
> connectToMaster(*audio*: **AudioComponent**)

Connecte le bus audio de l’entité au bus maître

<a id="func_3"></a>
> disconnect(*audio*: **AudioComponent**)

Déconnecte le bus audio de l’entité

<a id="func_4"></a>
> play(*audio*: **AudioComponent**, *sound*: **Sound**)

Joue un son spacialisé au niveau de l’entité

<a id="func_5"></a>
> play(*audio*: **AudioComponent**, *music*: **Music**)

Joue une musique spacialisée au niveau de l’entité

<a id="func_6"></a>
> play(*audio*: **AudioComponent**, *player*: **AudioPlayer**)

Lance un lecteur audio spacialisé au niveau de l’entité

