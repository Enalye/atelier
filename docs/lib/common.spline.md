# common.spline

Courbes d’accélération.
Des exemples de ces fonctions sont visibles sur [ce site](https://easings.net/fr).
## Énumérations
|Énumération|Valeurs|Description|
|-|-|-|
|Spline|{linear, sineIn, sineOut, sineInOut, quadIn, quadOut, quadInOut, cubicIn, cubicOut, cubicInOut, quartIn, quartOut, quartInOut, quintIn, quintOut, quintInOut, expIn, expOut, expInOut, circIn, circOut, circInOut, backIn, backOut, backInOut, elasticIn, elasticOut, elasticInOut, bounceIn, bounceOut, bounceInOut}|Décrit une fonction d’accélération|
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[ease](#func_0)|*value*: **float**, *spline*: **Spline**|**float**|


***
## Description des fonctions

<a id="func_0"></a>
> ease(*value*: **float**, *spline*: **Spline**) (**float**)

Applique une courbe d’acccélération.

`value` doit être compris entre 0 et 1.

La fonction retourne une valeur entre 0 et 1.

