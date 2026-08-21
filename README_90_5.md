# CORE AWAKENED — Prototipo 90.5

Base: Prototipo 90.4 (respiración atada al cansancio + guardia con
balanceo propio).

## El parpadeo: no era solo un número mal puesto, eran dos bugs reales

### Bug 1 — la calibración vieja ya no correspondía al arte actual
`DATOS_CARA` tenía coordenadas por personaje calibradas contra una
versión anterior de cada `parado.png`. Como varios personajes pasaron por
rediseños de arte desde entonces (canvas de otro tamaño, pose distinta),
esos números quedaron completamente desactualizados. Medí de nuevo a
mano, sobre el arte ACTUAL, con una grilla de píxeles superpuesta para
ubicar los ojos con precisión -- después lo verifiqué dibujando un
círculo en la posición calculada sobre cada PNG para confirmar que caía
exacto sobre el ojo (así quedó, en los tres casos que recalibré).

### Bug 2 — el personaje sin calibrar usaba un resguardo sin sentido
Cualquier personaje que no estuviera en `DATOS_CARA` (como Jester, que es
nueva) caía en un valor por defecto `Vector4(0, -195, ...)` -- un offset
mucho más grande que cualquier valor real calibrado, así que terminaba
flotando arriba de la cabeza. Ahora, si el personaje no está en
`DATOS_CARA`, la capa de parpadeo directamente no se crea -- apagado
limpio, no una posición inventada.

### Bug 3 (bonus, encontrado de paso) — la animación nunca se aplicaba
El sistema de fases del parpadeo (cerrar rápido, abrir un poco más lento)
ya estaba calculado (`parpadeo_progreso`, `apertura`) pero el párpado se
forzaba a `visible = false` en TODAS las fases, así que aunque la
posición hubiera estado bien, no se iba a ver nunca. Ahora sí se conecta:
el párpado crece de 0 a cobertura total en ~55ms (cierre) y vuelve a 0 en
~70ms (apertura) -- un parpadeo natural, bien rápido.

## A qué personajes se les activó
Solo a los que tienen dos ojos simétricos y de frente en su arte actual:
**Kai, Helena y Jester**. Medido y verificado visualmente en los tres.

## A quiénes NO, y por qué (a propósito, no por olvido)
Revisé el `parado.png` actual de todo el roster antes de decidir esto:
- **Fang** y **Aethel**: la pose muestra un solo ojo (cabeza de perfil/
  girada) -- no hay un segundo ojo simétrico donde poner el otro párpado.
- **Cibor-X**: es un lente robótico único, no un par de ojos.
- **Kali**: tiene un ojo compuesto grande y otro chico muy asimétricos
  entre sí -- no son un par simétrico.
- **Magnus**: un solo cristal brillante en la cabeza, sin ojos pareados.
- **Varkhos**: ojos-vacío sin párpado natural (más un tercer ojo aparte
  en la frente).

Para estos, forzar una posición "aproximada" iba a repetir el mismo
problema que reportaste -- mejor dejarlo apagado hasta que, si en algún
momento cambian a una pose más de frente con ambos ojos visibles, se
pueda calibrar igual que los otros tres.

## Si agregan un personaje nuevo más adelante
El parpadeo queda apagado automáticamente hasta que se agregue su entrada
en `DATOS_CARA` (`fighter.gd`) -- ya no hay riesgo de que vuelva a
aparecer flotando en cualquier lado. Para calibrar uno nuevo, el proceso
que usé es repetible: recortar la cara con una grilla de píxeles, leer
las coordenadas de los ojos a simple vista, y confirmar con un círculo de
prueba antes de darlo por bueno.

## Archivo tocado
- `scripts/fighter.gd` — `DATOS_CARA`, `_crear_capa_facial()`,
  `_actualizar_expresion_facial()`
