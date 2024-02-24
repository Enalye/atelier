# audio.bus

Route les sons et leur applique des effets
## Natifs
### AudioBus
## Constructeurs
|Fonction|Entrée|Description|
|-|-|-|
|[@**AudioBus**](#ctor_0)|||
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[addEffect](#func_0)|*bus*: **AudioBus**, *effect*: **AudioEffect**||
|[connectTo](#func_1)|*srcBus*: **AudioBus**, *destBus*: **AudioBus**||
|[connectToMaster](#func_2)|*bus*: **AudioBus**||
|[disconnect](#func_3)|*srcBus*: **AudioBus**||
|[play](#func_4)|*bus*: **AudioBus**, *player*: **AudioPlayer**||
|[play](#func_5)|*bus*: **AudioBus**, *player*: **Sound**||
|[play](#func_6)|*bus*: **AudioBus**, *player*: **Music**||


***
## Description des fonctions

<a id="func_0"></a>
> addEffect(*bus*: **AudioBus**, *effect*: **AudioEffect**)

Ajoute un effet.

<a id="func_1"></a>
> connectTo(*srcBus*: **AudioBus**, *destBus*: **AudioBus**)

Connecte le bus à un bus destinataire.

<a id="func_2"></a>
> connectToMaster(*bus*: **AudioBus**)

Connecte le bus au bus maître.

<a id="func_3"></a>
> disconnect(*srcBus*: **AudioBus**)

Déconnecte le bus de toute destination.

<a id="func_4"></a>
> play(*bus*: **AudioBus**, *player*: **AudioPlayer**)

Joue le son sur le bus.

<a id="func_5"></a>
> play(*bus*: **AudioBus**, *player*: **Sound**)

Joue le son sur le bus.

<a id="func_6"></a>
> play(*bus*: **AudioBus**, *player*: **Music**)

Joue le son sur le bus.

