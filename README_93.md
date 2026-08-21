# CORE AWAKENED — Prototipo 93

Base: Prototipo 92.3 (Jester completa).

## Secuencia narrativa "El origen del Core"

Nueva pantalla entre el logo del estudio y el menú principal: las 8
láminas que mandaste (arte + texto + marco, todo ya compuesto en el PNG)
se muestran una por vez con fundido cruzado, sobre el tema musical que
mandaste de fondo.

### Flujo de escenas (antes → ahora)
```
Antes:   IntroEstudio (logo) ────────────────► MenuPrincipal
Ahora:   IntroEstudio (logo) ── IntroHistoria ─► MenuPrincipal
```
Un solo archivo tocado para lograrlo: `intro_estudio.gd` ahora apunta a
`IntroHistoria.tscn` en vez de ir directo al menú. `IntroHistoria.tscn`
es la escena nueva; al terminar (o al saltarla), ella misma manda a
`MenuPrincipal.tscn` como hacía antes `IntroEstudio`.

### Timing
La música que mandaste dura 33.72 segundos exactos. Repartí ese tiempo
entre las 8 láminas a mano, no en partes iguales -- más tiempo a las que
tienen más texto o más peso dramático: la 5 ("Era una prisión.") es la
más corta a propósito, como un latido de pausa; la 7 (la de Varkhos
dormido, tres oraciones) y la 8 (el logo final) son las más largas. La
suma da 33.7s, prácticamente calzada con el tema.

### Se puede saltar
Cualquier tecla, click o toque salta directo al menú, con un fundido a
negro prolijo y la música bajando en vez de cortarse en seco. Hay un
cartelito chico y discreto abajo ("Toca o presioná cualquier tecla para
saltar") para que se note que existe la opción, sin ser invasivo. Con
0.3s de demora antes de activarse, para que no se salte por accidente
con un input que venía rebotando de la pantalla anterior.

### Ajuste de imagen
Las 8 láminas son 1672x941 -- casi el mismo aspecto que la pantalla del
juego (1280x720), así que se escalan a pantalla completa sin bandas
negras ni recortes notorios.

## Archivos nuevos/tocados
- `scenes/IntroHistoria.tscn` (nuevo)
- `scripts/intro_historia.gd` (nuevo)
- `scripts/intro_estudio.gd` — cambia a qué escena apunta al terminar
- `assets/historia/slide_1.png` … `slide_8.png` (nuevos)
- `assets/sonidos/historia_intro.mp3` (nuevo)

## Pendiente / a definir
- ¿La secuencia se muestra SIEMPRE que se abre el juego, o solo la
  primera vez? Hoy se ve siempre (no hay sistema de guardado en el
  proyecto todavía, así que "solo la primera vez" no se puede hacer sin
  agregar persistencia -- lo charlamos si te interesa).
- El volumen del tema (-4 dB) y de la música del logo (-7.5 dB) quedaron
  con valores distintos porque son pistas distintas -- avisá si al
  escucharlo seguido hay que nivelarlos.
