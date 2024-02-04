# core.runtime

Informations système
## Énumérations
|Énumération|Valeurs|Description|
|-|-|-|
|Scaling|{none, integer, fit, contain, stretch}|Algorithme de mise à l’échelle (voir: setScaling)|
## Natifs
### App
## Fonctions Statiques
|Fonction|Entrée|Sortie|
|-|-|-|
|[@**App**.width](#static_0)||**int**|
|[@**App**.height](#static_1)||**int**|
|[@**App**.size](#static_2)||**Vec2\<int>**|
|[@**App**.center](#static_3)||**Vec2\<int>**|
|[@**App**.setPixelSharpness](#static_4)|*sharpness*: **uint**||
|[@**App**.setScaling](#static_5)|*scaling*: **Scaling**||


***
## Description des fonctions statiques

<a id="static_0"></a>
> @**App**.width() (**int**)

La largeur en pixel de l’écran.

<a id="static_1"></a>
> @**App**.height() (**int**)

La hauteur en pixel de l’écran.

<a id="static_2"></a>
> @**App**.size() (**Vec2\<int>**)

La taille en pixel de l’écran.

<a id="static_3"></a>
> @**App**.center() (**Vec2\<int>**)

Les coordonnées du centre de l’écran.

Égal à `@App.size() / 2`.

<a id="static_4"></a>
> @**App**.setPixelSharpness(*sharpness*: **uint**)

Facteur de netteté des pixels.

Plus cette valeur est grande, plus la qualité est grande mais plus le jeu sera gourmand en ressources graphiques.

Le canvas du jeu de base est d’abord multiplié par ce facteur, avant de passer à l’algorithme de mise à l’échelle.

Exemple:

    Un jeu qui a un canvas de 640×360 et un facteur de netteté de 2 sera rendu avec une résolution de 1280×720

    avant d’être mise à l’échelle de la fenêtre grace à la méthode de `setScaling`.

<a id="static_5"></a>
> @**App**.setScaling(*scaling*: **Scaling**)

Applique un algorithme de mise à l’échelle.

- **Scaling.none**: aucun redimensionnement

- **Scaling.integer**: seul le facteur de `setPixelSharpness` est appliqué

- **Scaling.fit**: comme `integer`, puis mise à l’échelle de la fenêtre en respectant le ratio largeur/hauteur de l’écran. Peut induire des bandes noires sur les côtés.

- **Scaling.contain**: comme `fit`, mais en dépassant de la fenêtre afin d’éviter les bandes noires.

- **Scaling.stretch**: comme `integer`, puis redimensionnement à la taille de la fenêtre sans respecter le ratio

