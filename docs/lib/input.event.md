# input.event

Événements d’entrée
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
|Propriété|Natif|Type|Accesseur|Modifieur|Description|
|-|-|-|-|-|-|
|axis|**InputEventControllerAxis**|**ControllerButton**|oui|non|Affiche le contenu de l’événement.|
|button|**InputEventKeyButton**|**KeyButton**|oui|non|Affiche le contenu de l’événement.|
|button|**InputEventMouseButton**|**KeyButton**|oui|non|Affiche le contenu de l’événement.|
|button|**InputEventControllerButton**|**ControllerButton**|oui|non|Affiche le contenu de l’événement.|
|clicks|**InputEventMouseButton**|**int**|oui|non|Affiche le contenu de l’événement.|
|controllerAxis|**InputEvent**|**InputEventControllerAxis?**|oui|non|Si l’événement est de type InputEventControllerAxis, retourne le type.|
|controllerButton|**InputEvent**|**InputEventControllerButton?**|oui|non|Si l’événement est de type InputEventControllerButton, retourne le type.|
|deltaPosition|**InputEventMouseButton**|**Vec2\<float>**|oui|non|Affiche le contenu de l’événement.|
|deltaPosition|**InputEventMouseMotion**|**Vec2\<float>**|oui|non|Affiche le contenu de l’événement.|
|dropFile|**InputEvent**|**InputEventDropFile?**|oui|non|Si l’événement est de type InputEventDropFile, retourne le type.|
|echo|**InputEventKeyButton**|**bool**|oui|non|Affiche le contenu de l’événement.|
|keyButton|**InputEvent**|**InputEventKeyButton?**|oui|non|Si l’événement est de type InputEventKeyButton, retourne le type.|
|mouseButton|**InputEvent**|**InputEventMouseButton?**|oui|non|Si l’événement est de type InputEventMouseButton, retourne le type.|
|mouseMotion|**InputEvent**|**InputEventMouseMotion?**|oui|non|Si l’événement est de type InputEventMouseMotion, retourne le type.|
|mouseWheel|**InputEvent**|**InputEventMouseWheel?**|oui|non|Si l’événement est de type InputEventMouseWheel, retourne le type.|
|path|**InputEventDropFile**|**string**|oui|non|Affiche le contenu de l’événement.|
|position|**InputEventMouseButton**|**Vec2\<float>**|oui|non|Affiche le contenu de l’événement.|
|position|**InputEventMouseMotion**|**Vec2\<float>**|oui|non|Affiche le contenu de l’événement.|
|state|**InputEventKeyButton**|**KeyState**|oui|non|Affiche le contenu de l’événement.|
|state|**InputEventMouseButton**|**KeyState**|oui|non|Affiche le contenu de l’événement.|
|state|**InputEventControllerButton**|**KeyState**|oui|non|Affiche le contenu de l’événement.|
|text|**InputEventTextInput**|**string**|oui|non|Affiche le contenu de l’événement.|
|textInput|**InputEvent**|**InputEventTextInput?**|oui|non|Si l’événement est de type InputEventTextInput, retourne le type.|
|type|**InputEvent**|**InputEventType**|oui|non|Type d’événement|
|value|**InputEventControllerAxis**|**float**|oui|non|Affiche le contenu de l’événement.|
|x|**InputEventMouseWheel**|**int**|oui|non|Affiche le contenu de l’événement.|
|y|**InputEventMouseWheel**|**int**|oui|non|Affiche le contenu de l’événement.|
## Fonctions Statiques
|Fonction|Entrée|Sortie|
|-|-|-|
|[@**InputEvent**.keyButton](#static_0)|*event*: **KeyButton**, *action*: **KeyState**|**InputEvent**|
|[@**InputEvent**.keyButton](#static_1)|*event*: **KeyButton**, *action*: **KeyState**, *param2*: **bool**|**InputEvent**|
|[@**InputEvent**.mouseButton](#static_2)|*event*: **MouseButton**, *action*: **KeyState**, *param2*: **int**, *param3*: **Vec2\<float>**, *param4*: **Vec2\<float>**|**InputEvent**|
|[@**InputEvent**.mouseMotion](#static_3)|*event*: **Vec2\<float>**, *action*: **Vec2\<float>**|**InputEvent**|
|[@**InputEvent**.mouseWheel](#static_4)|*event*: **int**, *action*: **int**|**InputEvent**|
|[@**InputEvent**.controllerButton](#static_5)|*event*: **ControllerButton**, *action*: **KeyState**|**InputEvent**|
|[@**InputEvent**.controllerAxis](#static_6)|*event*: **ControllerAxis**, *action*: **float**|**InputEvent**|
|[@**InputEvent**.textInput](#static_7)|*event*: **string**|**InputEvent**|
|[@**InputEvent**.dropFile](#static_8)|*event*: **string**|**InputEvent**|
## Fonctions
|Fonction|Entrée|Sortie|
|-|-|-|
|[accept](#func_0)|*event*: **InputEvent**||
|[echo](#func_1)|*event*: **InputEvent**|**bool**|
|[isAction](#func_2)|*event*: **InputEvent**, *action*: **string**|**bool**|
|[isPressed](#func_3)|*event*: **InputEvent**|**bool**|
|[print](#func_4)|*event*: **InputEvent**||


***
## Description des fonctions statiques

<a id="static_0"></a>
> @**InputEvent**.keyButton(*event*: **KeyButton**, *action*: **KeyState**) (**InputEvent**)

Crée un événement clavier.

<a id="static_1"></a>
> @**InputEvent**.keyButton(*event*: **KeyButton**, *action*: **KeyState**, *param2*: **bool**) (**InputEvent**)

Crée un événement clavier.

<a id="static_2"></a>
> @**InputEvent**.mouseButton(*event*: **MouseButton**, *action*: **KeyState**, *param2*: **int**, *param3*: **Vec2\<float>**, *param4*: **Vec2\<float>**) (**InputEvent**)

Crée un événement bouton de souris.

<a id="static_3"></a>
> @**InputEvent**.mouseMotion(*event*: **Vec2\<float>**, *action*: **Vec2\<float>**) (**InputEvent**)

Crée un événement déplacement de souris.

<a id="static_4"></a>
> @**InputEvent**.mouseWheel(*event*: **int**, *action*: **int**) (**InputEvent**)

Crée un événement molette de souris.

<a id="static_5"></a>
> @**InputEvent**.controllerButton(*event*: **ControllerButton**, *action*: **KeyState**) (**InputEvent**)

Crée un événement bouton de manette.

<a id="static_6"></a>
> @**InputEvent**.controllerAxis(*event*: **ControllerAxis**, *action*: **float**) (**InputEvent**)

Crée un événement axe de manette.

<a id="static_7"></a>
> @**InputEvent**.textInput(*event*: **string**) (**InputEvent**)

Crée un événement entrée textuelle.

<a id="static_8"></a>
> @**InputEvent**.dropFile(*event*: **string**) (**InputEvent**)

Crée un événement fichier déposé.

## Description des fonctions

<a id="func_0"></a>
> accept(*event*: **InputEvent**)

Consomme l’événement.

<a id="func_1"></a>
> echo(*event*: **InputEvent**) (**bool**)

L’événement est-il déclenché par répétition ?

<a id="func_2"></a>
> isAction(*event*: **InputEvent**, *action*: **string**) (**bool**)

L’événement correspond-il à l’action ?

<a id="func_3"></a>
> isPressed(*event*: **InputEvent**) (**bool**)

La touche est-elle active ?

<a id="func_4"></a>
> print(*event*: **InputEvent**)

Affiche le contenu de l’événement.

