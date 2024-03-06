# input.input

Entrées utilisateur
## Natifs
### Input
## Fonctions Statiques
|Fonction|Entrée|Sortie|
|-|-|-|
|[@**Input**.isDown](#static_0)|*input*: **KeyButton**|**bool**|
|[@**Input**.isDown](#static_1)|*input*: **MouseButton**|**bool**|
|[@**Input**.isDown](#static_2)|*input*: **ControllerButton**|**bool**|
|[@**Input**.isUp](#static_3)|*input*: **KeyButton**|**bool**|
|[@**Input**.isUp](#static_4)|*input*: **MouseButton**|**bool**|
|[@**Input**.isUp](#static_5)|*input*: **ControllerButton**|**bool**|
|[@**Input**.isHeld](#static_6)|*input*: **KeyButton**|**bool**|
|[@**Input**.isHeld](#static_7)|*input*: **MouseButton**|**bool**|
|[@**Input**.isHeld](#static_8)|*input*: **ControllerButton**|**bool**|
|[@**Input**.isPressed](#static_9)|*input*: **KeyButton**|**bool**|
|[@**Input**.isPressed](#static_10)|*input*: **MouseButton**|**bool**|
|[@**Input**.isPressed](#static_11)|*input*: **ControllerButton**|**bool**|
|[@**Input**.addAction](#static_12)|*action*: **string**||
|[@**Input**.removeAction](#static_13)|*action*: **string**||
|[@**Input**.hasAction](#static_14)|*action*: **string**|**bool**|
|[@**Input**.isAction](#static_15)|*action*: **string**, *event*: **InputEvent**|**bool**|
|[@**Input**.addActionEvent](#static_16)|*action*: **string**, *event*: **InputEvent**||
|[@**Input**.removeActionEvents](#static_17)|*action*: **string**||
|[@**Input**.isActionActivated](#static_18)|*action*: **string**|**bool**|
|[@**Input**.getActionStrength](#static_19)|*action*: **string**|**float**|
|[@**Input**.getActionAxis](#static_20)|*negative*: **string**, *positive*: **string**|**float**|
|[@**Input**.getActionVector](#static_21)|*left*: **string**, *right*: **string**, *up*: **string**, *down*: **string**|**Vec2\<float>**|


***
## Description des fonctions statiques

<a id="static_0"></a>
> @**Input**.isDown(*input*: **KeyButton**) (**bool**)

La touche est-elle appuyée sur cette frame ?

<a id="static_1"></a>
> @**Input**.isDown(*input*: **MouseButton**) (**bool**)

La touche est-elle appuyée sur cette frame ?

<a id="static_2"></a>
> @**Input**.isDown(*input*: **ControllerButton**) (**bool**)

La touche est-elle appuyée sur cette frame ?

<a id="static_3"></a>
> @**Input**.isUp(*input*: **KeyButton**) (**bool**)

La touche est-elle relâchée sur cette frame ?

<a id="static_4"></a>
> @**Input**.isUp(*input*: **MouseButton**) (**bool**)

La touche est-elle relâchée sur cette frame ?

<a id="static_5"></a>
> @**Input**.isUp(*input*: **ControllerButton**) (**bool**)

La touche est-elle relâchée sur cette frame ?

<a id="static_6"></a>
> @**Input**.isHeld(*input*: **KeyButton**) (**bool**)

La touche est-elle enfoncée ?

<a id="static_7"></a>
> @**Input**.isHeld(*input*: **MouseButton**) (**bool**)

La touche est-elle enfoncée ?

<a id="static_8"></a>
> @**Input**.isHeld(*input*: **ControllerButton**) (**bool**)

La touche est-elle enfoncée ?

<a id="static_9"></a>
> @**Input**.isPressed(*input*: **KeyButton**) (**bool**)

La touche est-elle pressée ?

<a id="static_10"></a>
> @**Input**.isPressed(*input*: **MouseButton**) (**bool**)

La touche est-elle pressée ?

<a id="static_11"></a>
> @**Input**.isPressed(*input*: **ControllerButton**) (**bool**)

La touche est-elle pressée ?

<a id="static_12"></a>
> @**Input**.addAction(*action*: **string**)

Défini une nouvelle action

<a id="static_13"></a>
> @**Input**.removeAction(*action*: **string**)

Supprime une action existante

<a id="static_14"></a>
> @**Input**.hasAction(*action*: **string**) (**bool**)

Vérifie si l’action existe

<a id="static_15"></a>
> @**Input**.isAction(*action*: **string**, *event*: **InputEvent**) (**bool**)

L’événement correspond-il a l’action ?

<a id="static_16"></a>
> @**Input**.addActionEvent(*action*: **string**, *event*: **InputEvent**)

Associe un événement à une action

<a id="static_17"></a>
> @**Input**.removeActionEvents(*action*: **string**)

Supprime les événements associés à une action

<a id="static_18"></a>
> @**Input**.isActionActivated(*action*: **string**) (**bool**)

L’action a-t’elle été déclenchée ?

<a id="static_19"></a>
> @**Input**.getActionStrength(*action*: **string**) (**float**)

Récupère l’intensité de l’action

<a id="static_20"></a>
> @**Input**.getActionAxis(*negative*: **string**, *positive*: **string**) (**float**)

Récupère l’intensité sous forme d’un axe défini par 2 actions (l’un positif, l’autre négatif)

<a id="static_21"></a>
> @**Input**.getActionVector(*left*: **string**, *right*: **string**, *up*: **string**, *down*: **string**) (**Vec2\<float>**)

Récupère l’intensité sous forme d’un vecteur défini par 4 actions

