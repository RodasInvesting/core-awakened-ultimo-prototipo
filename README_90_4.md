# CORE AWAKENED — Prototipo 90.4

Base: Prototipo 90.3 (golpe seco instantáneo también durante el combo).

## Más "vida" en el personaje sin arte nuevo

### 1) Respiración atada también al cansancio, no solo al CORE
Antes, el balanceo tipo "respirando" (100% procedural, mueve posición y
rotación del sprite unos píxeles) solo se aceleraba cuando el CORE estaba
por llenarse. Ahora también sube con la vida perdida -- el que viene
perdiendo se ve más agitado, no solo el que está por soltar su poder.
Usa lo que sea mayor entre las dos señales.

### 2) La guardia ya no es una foto congelada
Bloqueando, antes no había ningún movimiento -- ni respiración (se
apagaba a propósito) ni nada. Ahora tiene su propio balanceo: más chico
y más rápido que el de reposo (tensión sostenida, no respiración
relajada), con un leve sesgo del cuerpo hacia el rival, como si estuviera
empujando el bloqueo hacia adelante. También sube de intensidad con la
carga de CORE o el cansancio, igual que el de reposo.

Los dos puntos de arriba son 100% código -- no hace falta ningún PNG
nuevo, ya está andando en este build.

## Sobre boca y brazos independientes: la respuesta honesta

Este truco (respiración/guardia) funciona porque mueve el SPRITE ENTERO
unos píxeles -- no mueve una parte del cuerpo por separado. Cada pose es
una sola ilustración plana (parado, puñetazo, patada, etc.), no un
personaje armado en capas (torso, cabeza, boca, brazos como piezas
separadas). Eso pone un techo real a lo que puedo simular solo con
código:

- **Lo que SÍ se puede** con lo que hay: más balanceo, inclinación,
  retroceso, sacudidas de cámara, temblor por impacto, parpadeo (ver
  abajo) -- todo lo que mueve el cuerpo COMO UN TODO.
- **Lo que NO se puede** sin más trabajo: abrir/cerrar la boca o mover un
  brazo de forma independiente del resto del cuerpo. Eso requiere que esa
  parte exista como pieza separada.

Dos caminos reales para eso, sin inventar nada a medias que después haya
que rehacer:

1. **Más cuadros de pose (barato, mismo sistema que ya usan)**: el mismo
   mecanismo que ya tienen para puñetazo_1/2/3 o caminata_1/2/3 -- 2 o 3
   variantes del parado con la boca/postura levemente distinta (un
   "fidget" de reposo) que el juego alterna solo cada tanto tiempo
   quieto. Con eso ya se rompe la sensación de estampita sin cambiar
   ningún sistema, con arte nueva pero relativamente rápida de generar.
2. **Rigging real (más caro, otro nivel de pulido)**: separar cada
   personaje en piezas (torso, cabeza, brazos) tipo recorte/marioneta
   (el estilo que usan engines como Spine2D/DragonBones, o directamente
   Nodo2D por pieza en Godot) para animarlas de verdad e independiente.
   Es un cambio de pipeline de arte, no algo que se agregue en una tarde
   -- vale la pena si en algún momento quieren ese nivel de pulido en
   todo el roster, pero es una decisión aparte, no un parche.

## Bonus: había un sistema de parpadeo ya armado, pero apagado
Existe un sistema completo de parpadeo (temporizador, fases de cierre y
apertura, posición calibrada por personaje en `DATOS_CARA`) pero el
párpado en sí está forzado a invisible en el código, con una nota de una
fase anterior: un párpado genérico no calzaba bien con los ojos ya
pintados en cada personaje. Si quieren, en la próxima paso lo puedo
retomar y calibrar en serio (forma/color por personaje en vez de uno
genérico) -- ya está el 90% de la maquinaria hecha, faltaría afinarlo
visualmente por personaje.

## Archivo tocado
- `scripts/fighter.gd` — `_physics_process()`, bloque de animación de
  reposo/guardia
