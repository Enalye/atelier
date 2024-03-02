# scene.particle

Système de particules
## Description
```grimoire
var src = @ParticleSource;
src.setSprite("particle");
src.setMode(ParticleMode.spread);
src.setSpread(0f, 360f, 45f);
src.setDistance(100f, 100f);
src.setCount(50, 70);
src.setLifetime(100, 100);
src.setSpeed(0, 60, 0.3f, 0.5f, Spline.sineInOut);
src.setSpeed(60, 100, 0.5f, 0f, Spline.sineInOut);
src.setAlpha(0, 10, 0f, 1f, Spline.sineInOut);
src.setAlpha(90, 100, 1f, 0f, Spline.sineInOut);
src.setPivotSpin(0, 0.02f, 0.02f);
src.setPivotDistance(0, 60, 50f, 150f, Spline.sineInOut);
src.setPivotDistance(60, 100, 150f, 100f, Spline.sineInOut);
src.start(5);

scene.addParticleSource(src);
```

## Énumérations
|Énumération|Valeurs|Description|
|-|-|-|
|ParticleMode|{spread, rectangle, ellipsis}|Mode d’émission des particules|
## Natifs
### ParticleSource
## Constructeurs
|Fonction|Entrée|Description|
|-|-|-|
|[@**ParticleSource**](#ctor_0)||Mode d’émission des particules|
|[@**ParticleSource**](#ctor_1)| *param0*: **string**|Mode d’émission des particules|
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|Description|
|-|-|-|-|-|-|
|position|**ParticleSource**|**Vec2\<float>**|oui|oui|Mode d’émission des particules|
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[attachTo](#func_0)|*source*: **ParticleSource**, *entity*: **Entity**||
|[attachToCamera](#func_1)|*source*: **ParticleSource**||
|[clear](#func_2)|*source*: **ParticleSource**||
|[detach](#func_3)|*source*: **ParticleSource**||
|[emit](#func_4)|*source*: **ParticleSource**||
|[remove](#func_5)|*source*: **ParticleSource**||
|[setAlpha](#func_6)|*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startAlpha*: **float**, *endAlpha*: **float**, *spline*: **Spline**||
|[setAlpha](#func_7)|*source*: **ParticleSource**, *frame*: **uint**, *minAlpha*: **float**, *maxAlpha*: **float**||
|[setAngle](#func_8)|*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startAngle*: **float**, *endAngle*: **float**, *spline*: **Spline**||
|[setAngle](#func_9)|*source*: **ParticleSource**, *frame*: **uint**, *minAngle*: **float**, *maxAngle*: **float**||
|[setArea](#func_10)|*source*: **ParticleSource**, *width*: **float**, *height*: **float**||
|[setBlend](#func_11)|*source*: **ParticleSource**, *blend*: **Blend**||
|[setColor](#func_12)|*source*: **ParticleSource**, *frame*: **uint**, *minColor*: **Color**, *maxColor*: **Color**||
|[setColor](#func_13)|*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startColor*: **Color**, *endColor*: **Color**, *spline*: **Spline**||
|[setCount](#func_14)|*source*: **ParticleSource**, *minCount*: **uint**, *maxCount*: **uint**||
|[setDistance](#func_15)|*source*: **ParticleSource**, *minDistance*: **float**, *maxDistance*: **float**||
|[setLifetime](#func_16)|*source*: **ParticleSource**, *minLifetime*: **uint**, *maxLifetime*: **uint**||
|[setMode](#func_17)|*source*: **ParticleSource**, *mode*: **ParticleMode**||
|[setPivotAngle](#func_18)|*source*: **ParticleSource**, *frame*: **uint**, *minAngle*: **float**, *maxAngle*: **float**||
|[setPivotAngle](#func_19)|*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startAngle*: **float**, *endAngle*: **float**, *spline*: **Spline**||
|[setPivotDistance](#func_20)|*source*: **ParticleSource**, *frame*: **uint**, *minDistance*: **float**, *maxDistance*: **float**||
|[setPivotDistance](#func_21)|*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startDistance*: **float**, *endDistance*: **float**, *spline*: **Spline**||
|[setPivotSpin](#func_22)|*source*: **ParticleSource**, *frame*: **uint**, *minSpin*: **float**, *maxSpin*: **float**||
|[setPivotSpin](#func_23)|*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startSpin*: **float**, *endSpin*: **float**, *spline*: **Spline**||
|[setRelativePosition](#func_24)|*source*: **ParticleSource**, *isRelative*: **bool**||
|[setRelativeSpriteAngle](#func_25)|*source*: **ParticleSource**, *isRelative*: **bool**||
|[setScale](#func_26)|*source*: **ParticleSource**, *frame*: **uint**, *minScale*: **Vec2\<float>**, *maxScale*: **Vec2\<float>**||
|[setScale](#func_27)|*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startScale*: **Vec2\<float>**, *endScale*: **Vec2\<float>**, *spline*: **Spline**||
|[setSpeed](#func_28)|*source*: **ParticleSource**, *frame*: **uint**, *minSpeed*: **float**, *maxSpeed*: **float**||
|[setSpeed](#func_29)|*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startSpeed*: **float**, *endSpeed*: **float**, *spline*: **Spline**||
|[setSpin](#func_30)|*source*: **ParticleSource**, *frame*: **uint**, *minSpin*: **float**, *maxSpin*: **float**||
|[setSpin](#func_31)|*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startSpin*: **float**, *endSpin*: **float**, *spline*: **Spline**||
|[setSpread](#func_32)|*source*: **ParticleSource**, *minAngle*: **float**, *maxAngle*: **float**, *spreadAngle*: **float**||
|[setSprite](#func_33)|*source*: **ParticleSource**, *spriteId*: **string**||
|[setSpriteAngle](#func_34)|*source*: **ParticleSource**, *frame*: **uint**, *minAngle*: **float**, *maxAngle*: **float**||
|[setSpriteAngle](#func_35)|*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startAngle*: **float**, *endAngle*: **float**, *spline*: **Spline**||
|[setSpriteSpin](#func_36)|*source*: **ParticleSource**, *frame*: **uint**, *minSpin*: **float**, *maxSpin*: **float**||
|[setSpriteSpin](#func_37)|*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startSpin*: **float**, *endSpin*: **float**, *spline*: **Spline**||
|[start](#func_38)|*source*: **ParticleSource**, *interval*: **uint**||
|[stop](#func_39)|*source*: **ParticleSource**||


***
## Description des fonctions

<a id="func_0"></a>
> attachTo(*source*: **ParticleSource**, *entity*: **Entity**)

La source suit l’entité.

<a id="func_1"></a>
> attachToCamera(*source*: **ParticleSource**)

La source suit la caméra.

<a id="func_2"></a>
> clear(*source*: **ParticleSource**)

Efface toutes les particules.

<a id="func_3"></a>
> detach(*source*: **ParticleSource**)

Détache la source de l’entité/scène auquel elle était attaché.

<a id="func_4"></a>
> emit(*source*: **ParticleSource**)

Génère une seule fois des particules.

<a id="func_5"></a>
> remove(*source*: **ParticleSource**)

Retire la source de la scène.

<a id="func_6"></a>
> setAlpha(*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startAlpha*: **float**, *endAlpha*: **float**, *spline*: **Spline**)

Change l’opacité des particules.

<a id="func_7"></a>
> setAlpha(*source*: **ParticleSource**, *frame*: **uint**, *minAlpha*: **float**, *maxAlpha*: **float**)

Change l’opacité des particules.

<a id="func_8"></a>
> setAngle(*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startAngle*: **float**, *endAngle*: **float**, *spline*: **Spline**)

Change l’angle des particules.

<a id="func_9"></a>
> setAngle(*source*: **ParticleSource**, *frame*: **uint**, *minAngle*: **float**, *maxAngle*: **float**)

Change l’angle des particules.

<a id="func_10"></a>
> setArea(*source*: **ParticleSource**, *width*: **float**, *height*: **float**)

Change la taille de la zone à émettre.

<a id="func_11"></a>
> setBlend(*source*: **ParticleSource**, *blend*: **Blend**)

Type de blending

<a id="func_12"></a>
> setColor(*source*: **ParticleSource**, *frame*: **uint**, *minColor*: **Color**, *maxColor*: **Color**)

Change la couleur des particules.

<a id="func_13"></a>
> setColor(*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startColor*: **Color**, *endColor*: **Color**, *spline*: **Spline**)

Change la couleur des particules.

<a id="func_14"></a>
> setCount(*source*: **ParticleSource**, *minCount*: **uint**, *maxCount*: **uint**)

Le nombre de particule à émettre en même temps.

<a id="func_15"></a>
> setDistance(*source*: **ParticleSource**, *minDistance*: **float**, *maxDistance*: **float**)

En mode `spread`, change la distance avec laquelle les particules sont émises.

<a id="func_16"></a>
> setLifetime(*source*: **ParticleSource**, *minLifetime*: **uint**, *maxLifetime*: **uint**)

Paramètre la durée de vie des particules (en frames).

<a id="func_17"></a>
> setMode(*source*: **ParticleSource**, *mode*: **ParticleMode**)

Le mode d’émission:

 * ParticleMode.spread: réglé par `setDistance` et `setSpread`, projette les particules selon un arc de cercle.

 * ParticleMode.rectangle: réglé par `setArea`, défini un rectangle autour de la position.

 * ParticleMode.ellipsis: réglé par `setArea`, défini une ellipse autour de la position.

<a id="func_18"></a>
> setPivotAngle(*source*: **ParticleSource**, *frame*: **uint**, *minAngle*: **float**, *maxAngle*: **float**)

Change l’angle des particules autour de leur pivot.

<a id="func_19"></a>
> setPivotAngle(*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startAngle*: **float**, *endAngle*: **float**, *spline*: **Spline**)

Change l’angle des particules autour de leur pivot.

<a id="func_20"></a>
> setPivotDistance(*source*: **ParticleSource**, *frame*: **uint**, *minDistance*: **float**, *maxDistance*: **float**)

Change la distance des particules avec leur pivot.

<a id="func_21"></a>
> setPivotDistance(*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startDistance*: **float**, *endDistance*: **float**, *spline*: **Spline**)

Change la distance des particules avec leur pivot.

<a id="func_22"></a>
> setPivotSpin(*source*: **ParticleSource**, *frame*: **uint**, *minSpin*: **float**, *maxSpin*: **float**)

Change la vitesse de rotation des particules autour de leur pivot.

<a id="func_23"></a>
> setPivotSpin(*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startSpin*: **float**, *endSpin*: **float**, *spline*: **Spline**)

Change la vitesse de rotation des particules autour de leur pivot.

<a id="func_24"></a>
> setRelativePosition(*source*: **ParticleSource**, *isRelative*: **bool**)

Si `true` les particules suivent la source, sinon elles sont laissées à la traine.

<a id="func_25"></a>
> setRelativeSpriteAngle(*source*: **ParticleSource**, *isRelative*: **bool**)

Est-ce que l’orientation du sprite dépend de l’angle de la particule ?

<a id="func_26"></a>
> setScale(*source*: **ParticleSource**, *frame*: **uint**, *minScale*: **Vec2\<float>**, *maxScale*: **Vec2\<float>**)

Change la taille des particules.

<a id="func_27"></a>
> setScale(*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startScale*: **Vec2\<float>**, *endScale*: **Vec2\<float>**, *spline*: **Spline**)

Change la taille des particules.

<a id="func_28"></a>
> setSpeed(*source*: **ParticleSource**, *frame*: **uint**, *minSpeed*: **float**, *maxSpeed*: **float**)

Change la vitesse des particules.

<a id="func_29"></a>
> setSpeed(*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startSpeed*: **float**, *endSpeed*: **float**, *spline*: **Spline**)

Change la vitesse des particules.

<a id="func_30"></a>
> setSpin(*source*: **ParticleSource**, *frame*: **uint**, *minSpin*: **float**, *maxSpin*: **float**)

Change la vitesse de rotation des particules.

<a id="func_31"></a>
> setSpin(*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startSpin*: **float**, *endSpin*: **float**, *spline*: **Spline**)

Change la vitesse de rotation des particules.

<a id="func_32"></a>
> setSpread(*source*: **ParticleSource**, *minAngle*: **float**, *maxAngle*: **float**, *spreadAngle*: **float**)

En mode `spread`, change l’angle (en radians) où sont émises les particules.

À chaque émission, un angle entre `minAngle` et `maxAngle` est choisi, les particules sont émises dans cet angle avec un écart de `spreadAngle`.

<a id="func_33"></a>
> setSprite(*source*: **ParticleSource**, *spriteId*: **string**)

Change le sprite des particules.

<a id="func_34"></a>
> setSpriteAngle(*source*: **ParticleSource**, *frame*: **uint**, *minAngle*: **float**, *maxAngle*: **float**)

Change la rotation de l’image des particules.

<a id="func_35"></a>
> setSpriteAngle(*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startAngle*: **float**, *endAngle*: **float**, *spline*: **Spline**)

Change la rotation de l’image des particules.

<a id="func_36"></a>
> setSpriteSpin(*source*: **ParticleSource**, *frame*: **uint**, *minSpin*: **float**, *maxSpin*: **float**)

Change la vitesse de rotation de l’image des particules.

<a id="func_37"></a>
> setSpriteSpin(*source*: **ParticleSource**, *startFrame*: **uint**, *endFrame*: **uint**, *startSpin*: **float**, *endSpin*: **float**, *spline*: **Spline**)

Change la vitesse de rotation de l’image des particules.

<a id="func_38"></a>
> start(*source*: **ParticleSource**, *interval*: **uint**)

Démarre l’émission de particules toutes les `interval` frames.

<a id="func_39"></a>
> stop(*source*: **ParticleSource**)

Interrompt l’émission de particules.

