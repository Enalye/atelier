# scene.camera

Point de vue du joueur
## Description
```grimoire
@Camera.follow(player, @Vec2f(1f, 0.2f), @Vec2f(0f, 100f));
@Camera.zoom(1f, 120, Spline.sineInOut);
```

## Natifs
### Camera
## Fonctions Statiques
|Fonction|Entrée|Sortie|
|-|-|-|
|[@**Camera**.getPosition](#static_0)||**Vec2\<float>**|
|[@**Camera**.setPosition](#static_1)|*position*: **Vec2\<float>**||
|[@**Camera**.moveTo](#static_2)|*position*: **Vec2\<float>**, *frames*: **uint**, *spline*: **Spline**||
|[@**Camera**.follow](#static_3)|*target*: **Entity**, *damping*: **Vec2\<float>**, *deadzone*: **Vec2\<float>**||
|[@**Camera**.stop](#static_4)|||
|[@**Camera**.zoom](#static_5)|*zoomLevel*: **float**, *frames*: **uint**, *spline*: **Spline**||
|[@**Camera**.shake](#static_6)|*trauma*: **float**||
|[@**Camera**.rumble](#static_7)|*trauma*: **float**, *frames*: **uint**, *spline*: **Spline**||


***
## Description des fonctions statiques

<a id="static_0"></a>
> @**Camera**.getPosition() (**Vec2\<float>**)

Récupère la position de la caméra

<a id="static_1"></a>
> @**Camera**.setPosition(*position*: **Vec2\<float>**)

Déplace instantanément la caméra

<a id="static_2"></a>
> @**Camera**.moveTo(*position*: **Vec2\<float>**, *frames*: **uint**, *spline*: **Spline**)

Déplace la caméra vers la position

<a id="static_3"></a>
> @**Camera**.follow(*target*: **Entity**, *damping*: **Vec2\<float>**, *deadzone*: **Vec2\<float>**)

Déplace la caméra en suivant une cible

<a id="static_4"></a>
> @**Camera**.stop()

Arrête la caméra

<a id="static_5"></a>
> @**Camera**.zoom(*zoomLevel*: **float**, *frames*: **uint**, *spline*: **Spline**)

Change le zoom de la caméra

<a id="static_6"></a>
> @**Camera**.shake(*trauma*: **float**)

Secoue temporairement la caméra

<a id="static_7"></a>
> @**Camera**.rumble(*trauma*: **float**, *frames*: **uint**, *spline*: **Spline**)

Fait trembler la caméra

