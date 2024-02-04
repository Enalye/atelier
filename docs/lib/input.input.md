# input.input

Entrées utilisateur
## Énumérations
|Énumération|Valeurs|Description|
|-|-|-|
|ControllerAxis|{unknown, leftX, leftY, rightX, rightY, leftTrigger, rightTrigger}|Axe de la manette|
|ControllerButton|{unknown, a, b, x, y, back, guide, start, leftStick, rightStick, leftShoulder, rightShoulder, up, down, left, right}|Bouton de la manette|
|InputEventType|{none, keyButton, mouseButton, mouseMotion, mouseWheel, controllerButton, controllerAxis, textInput, dropFile}|Type d’événement|
|KeyButton|{unknown, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z, alpha1, alpha2, alpha3, alpha4, alpha5, alpha6, alpha7, alpha8, alpha9, alpha0, enter, escape, backspace, tab, space, minus, equals, leftBracket, rightBracket, backslash, nonushash, semicolon, apostrophe, grave, comma, period, slash, capslock, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, printScreen, scrollLock, pause, insert, home, pageup, remove, end, pagedown, right, left, down, up, numLockclear, numDivide, numMultiply, numMinus, numPlus, numEnter, num1, num2, num3, num4, num5, num6, num7, num8, num9, num0, numPeriod, nonusBackslash, application, power, numEquals, f13, f14, f15, f16, f17, f18, f19, f20, f21, f22, f23, f24, execute, help, menu, select, stop, again, undo, cut, copy, paste, find, mute, volumeUp, volumeDown, numComma, numEqualsAs400, international1, international2, international3, international4, international5, international6, international7, international8, international9, lang1, lang2, lang3, lang4, lang5, lang6, lang7, lang8, lang9, alterase, sysreq, cancel, clear, prior, enter2, separator, out_, oper, clearAgain, crsel, exsel, num00, num000, thousandSeparator, decimalSeparator, currencyUnit, currencySubunit, numLeftParenthesis, numRightParenthesis, numLeftBrace, numRightBrace, numTab, numBackspace, numA, numB, numC, numD, numE, numF, numXor, numPower, numPercent, numLess, numGreater, numAmpersand, numDblAmpersand, numVerticalBar, numDblVerticalBar, numColon, numHash, numSpace, numAt, numExclam, numMemStore, numMemRecall, numMemClear, numMemAdd, numMemSubtract, numMemMultiply, numMemDivide, numPlusMinus, numClear, numClearEntry, numBinary, numOctal, numDecimal, numHexadecimal, leftControl, leftShift, leftAlt, leftGUI, rightControl, rightShift, rightAlt, rightGUI, mode, audioNext, audioPrev, audioStop, audioPlay, audioMute, mediaSelect, www, mail, calculator, computer, acSearch, acHome, acBack, acForward, acStop, acRefresh, acBookmarks, brightnessDown, brightnessUp, displaysWitch, kbdIllumToggle, kbdIllumDown, kbdIllumUp, eject, sleep, app1, app2}|Touche du clavier|
|KeyState|{none, down, held, up, pressed}|État d’une entrée|
|MouseButton|{left, middle, right, x1, x2}|Bouton de la souris|
## Natifs
### InputEvent
Type d’événement
### InputEventControllerAxis
Type d’événement
### InputEventControllerButton
Type d’événement
### InputEventDropFile
Type d’événement
### InputEventKeyButton
Type d’événement
### InputEventMouseButton
Type d’événement
### InputEventMouseMotion
Type d’événement
### InputEventMouseWheel
Type d’événement
### InputEventTextInput
Type d’événement
## Conversions
|Source|Destination|
|-|-|
|**InputEvent**|**string**|
## Propriétés
|Propriété|Natif|Type|Accesseur|Modifieur|
|-|-|-|-|-|
|axis|**InputEventControllerAxis**|**ControllerButton**|oui|non|
|button|**InputEventKeyButton**|**KeyButton**|oui|non|
|button|**InputEventMouseButton**|**KeyButton**|oui|non|
|button|**InputEventControllerButton**|**ControllerButton**|oui|non|
|clicks|**InputEventMouseButton**|**int**|oui|non|
|controllerAxis|**InputEvent**|**InputEventControllerAxis?**|oui|non|
|controllerButton|**InputEvent**|**InputEventControllerButton?**|oui|non|
|deltaPosition|**InputEventMouseButton**|**Vec2\<float>**|oui|non|
|deltaPosition|**InputEventMouseMotion**|**Vec2\<float>**|oui|non|
|dropFile|**InputEvent**|**InputEventDropFile?**|oui|non|
|echo|**InputEventKeyButton**|**bool**|oui|non|
|keyButton|**InputEvent**|**InputEventKeyButton?**|oui|non|
|mouseButton|**InputEvent**|**InputEventMouseButton?**|oui|non|
|mouseMotion|**InputEvent**|**InputEventMouseMotion?**|oui|non|
|mouseWheel|**InputEvent**|**InputEventMouseWheel?**|oui|non|
|path|**InputEventDropFile**|**string**|oui|non|
|position|**InputEventMouseButton**|**Vec2\<float>**|oui|non|
|position|**InputEventMouseMotion**|**Vec2\<float>**|oui|non|
|state|**InputEventKeyButton**|**KeyState**|oui|non|
|state|**InputEventMouseButton**|**KeyState**|oui|non|
|state|**InputEventControllerButton**|**KeyState**|oui|non|
|text|**InputEventTextInput**|**string**|oui|non|
|textInput|**InputEvent**|**InputEventTextInput?**|oui|non|
|type|**InputEvent**|**InputEventType**|oui|non|
|value|**InputEventControllerAxis**|**float**|oui|non|
|x|**InputEventMouseWheel**|**int**|oui|non|
|y|**InputEventMouseWheel**|**int**|oui|non|
## Fonctions Statiques
|Fonction|Entrée|Sortie|
|-|-|-|
|[@**InputEvent**.keyButton](#static_0)|*param0*: **KeyButton**, *param1*: **KeyState**|**InputEvent**|
|[@**InputEvent**.keyButton](#static_1)|*param0*: **KeyButton**, *param1*: **KeyState**, *param2*: **bool**|**InputEvent**|
|[@**InputEvent**.mouseButton](#static_2)|*param0*: **MouseButton**, *param1*: **KeyState**, *param2*: **int**, *param3*: **Vec2\<float>**, *param4*: **Vec2\<float>**|**InputEvent**|
|[@**InputEvent**.mouseMotion](#static_3)|*param0*: **Vec2\<float>**, *param1*: **Vec2\<float>**|**InputEvent**|
|[@**InputEvent**.mouseWheel](#static_4)|*param0*: **int**, *param1*: **int**|**InputEvent**|
|[@**InputEvent**.controllerButton](#static_5)|*param0*: **ControllerButton**, *param1*: **KeyState**|**InputEvent**|
|[@**InputEvent**.controllerAxis](#static_6)|*param0*: **ControllerAxis**, *param1*: **float**|**InputEvent**|
|[@**InputEvent**.textInput](#static_7)|*param0*: **string**|**InputEvent**|
|[@**InputEvent**.dropFile](#static_8)|*param0*: **string**|**InputEvent**|
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[accept](#func_0)|*param0*: **InputEvent**||
|[addAction](#func_1)|*param0*: **string**||
|[addActionEvent](#func_2)|*param0*: **string**, *param1*: **InputEvent**||
|[echo](#func_3)|*param0*: **InputEvent**|**bool**|
|[getActionAxis](#func_4)|*param0*: **string**, *param1*: **string**|**float**|
|[getActionStrength](#func_5)|*param0*: **string**|**float**|
|[hasAction](#func_6)|*param0*: **string**|**bool**|
|[isAction](#func_7)|*param0*: **InputEvent**, *param1*: **string**|**bool**|
|[isActionActivated](#func_8)|*param0*: **string**|**bool**|
|[isPressed](#func_9)|*param0*: **InputEvent**|**bool**|
|[isPressed](#func_10)|*param0*: **KeyButton**|**bool**|
|[isPressed](#func_11)|*param0*: **MouseButton**|**bool**|
|[isPressed](#func_12)|*param0*: **ControllerButton**|**bool**|
|[print](#func_13)|*param0*: **InputEvent**||
|[removeAction](#func_14)|*param0*: **string**||
|[removeActionEvents](#func_15)|*param0*: **string**||


***
## Description des fonctions statiques

<a id="static_0"></a>
> @**InputEvent**.keyButton(*param0*: **KeyButton**, *param1*: **KeyState**) (**InputEvent**)

Crée un événement clavier.

<a id="static_1"></a>
> @**InputEvent**.keyButton(*param0*: **KeyButton**, *param1*: **KeyState**, *param2*: **bool**) (**InputEvent**)

Crée un événement clavier.

<a id="static_2"></a>
> @**InputEvent**.mouseButton(*param0*: **MouseButton**, *param1*: **KeyState**, *param2*: **int**, *param3*: **Vec2\<float>**, *param4*: **Vec2\<float>**) (**InputEvent**)

Crée un événement bouton de souris.

<a id="static_3"></a>
> @**InputEvent**.mouseMotion(*param0*: **Vec2\<float>**, *param1*: **Vec2\<float>**) (**InputEvent**)

Crée un événement déplacement de souris.

<a id="static_4"></a>
> @**InputEvent**.mouseWheel(*param0*: **int**, *param1*: **int**) (**InputEvent**)

Crée un événement molette de souris.

<a id="static_5"></a>
> @**InputEvent**.controllerButton(*param0*: **ControllerButton**, *param1*: **KeyState**) (**InputEvent**)

Crée un événement bouton de manette.

<a id="static_6"></a>
> @**InputEvent**.controllerAxis(*param0*: **ControllerAxis**, *param1*: **float**) (**InputEvent**)

Crée un événement axe de manette.

<a id="static_7"></a>
> @**InputEvent**.textInput(*param0*: **string**) (**InputEvent**)

Crée un événement entrée textuelle.

<a id="static_8"></a>
> @**InputEvent**.dropFile(*param0*: **string**) (**InputEvent**)

Crée un événement fichier déposé.

## Description des fonctions

<a id="func_0"></a>
> accept(*param0*: **InputEvent**)

Consomme l’événement.

<a id="func_1"></a>
> addAction(*param0*: **string**)

Défini une nouvelle action

<a id="func_2"></a>
> addActionEvent(*param0*: **string**, *param1*: **InputEvent**)

Associe un événement à une action

<a id="func_3"></a>
> echo(*param0*: **InputEvent**) (**bool**)

L’événement est-il déclenché par répétition ?

<a id="func_4"></a>
> getActionAxis(*param0*: **string**, *param1*: **string**) (**float**)

Récupère l’intensité sous forme d’un axe défini par 2 actions (l’un positif, l’autre négatif)

<a id="func_5"></a>
> getActionStrength(*param0*: **string**) (**float**)

Récupère l’intensité de l’action

<a id="func_6"></a>
> hasAction(*param0*: **string**) (**bool**)

Vérifie si l’action existe

<a id="func_7"></a>
> isAction(*param0*: **InputEvent**, *param1*: **string**) (**bool**)

L’événement correspond-il a l’action ?

<a id="func_8"></a>
> isActionActivated(*param0*: **string**) (**bool**)

L’action a-t’elle été déclenchée ?

<a id="func_9"></a>
> isPressed(*param0*: **InputEvent**) (**bool**)

La touche est-elle active ?

<a id="func_10"></a>
> isPressed(*param0*: **KeyButton**) (**bool**)

L’événement est-il pressé ?

<a id="func_11"></a>
> isPressed(*param0*: **MouseButton**) (**bool**)

L’événement est-il pressé ?

<a id="func_12"></a>
> isPressed(*param0*: **ControllerButton**) (**bool**)

L’événement est-il pressé ?

<a id="func_13"></a>
> print(*param0*: **InputEvent**)

Affiche le contenu de l’événement.

<a id="func_14"></a>
> removeAction(*param0*: **string**)

Supprime une action existante

<a id="func_15"></a>
> removeActionEvents(*param0*: **string**)

Supprime les événements associés à une action

