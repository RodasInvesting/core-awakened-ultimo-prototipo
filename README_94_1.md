# CORE AWAKENED — Prototipo 94.1

Base: Prototipo 94 (secuencia de Varkhos antes de Arcade/Batalla Rápida).

## 1) La pantalla gris en las transiciones

### Causa
Godot pinta un color de "fondo por defecto" en el instante entre que
libera la escena vieja y la nueva termina de cargar sus recursos -- por
defecto ese color es un gris medio. Con escenas livianas no se nota, pero
en transiciones pesadas (muchas imágenes grandes, como las dos secuencias
nuevas, o toda la carga de texturas de los dos personajes antes de la
pelea) ese instante se estira y el gris se hace evidente. Pasaba en TODO
el juego, no solo en lo que agregamos ahora -- lo que cambió es que ahora
hay más transiciones pesadas para notarlo.

### Arreglo
Un solo ajuste global en `project.godot`
(`rendering/environment/defaults/default_clear_color`), puesto en negro.
No hace falta tocar cada escena una por una -- aplica a los cambios de
escena de todo el juego. Como el resto del juego ya usa fundidos a negro
para las transiciones, ese instante ahora es invisible en vez de un
salto de color que no combina con nada.

### Si en la pelea sigue sintiéndose largo
El negro en sí no acorta el TIEMPO de carga (cargar todas las texturas de
dos personajes sigue tardando lo que tarda) -- lo que arregla es que ese
tiempo se vea como una transición prolija en vez de un glitch. Si
después de probarlo la espera antes de la pelea te sigue pareciendo
larga, hay margen para optimizarla de verdad (cargar en segundo plano en
vez de todo de una vez), pero es un cambio más grande -- lo charlamos si
hace falta.

## 2) Las secuencias narrativas pasaban muy rápido

Bajé el `pitch_scale` del audio a **0.92** en las dos secuencias (baja
tono y velocidad juntos, ~1.5 semitonos -- para un tema instrumental/
cinemático sin voz, difícil de notar sin tener el original al lado para
comparar) y estiré cada lámina un ~8.7% para que sigan acompañando a la
música ya más lenta sin desincronizarse.

| | Antes | Ahora |
|---|---|---|
| IntroHistoria (8 láminas) | 33.7s | ~36.6s |
| IntroBatalla (9 láminas) | 34.5s | ~37.5s |

Si con esto sigue sintiéndose rápido, o si el tono sí se nota, es un solo
número para tocar (`pitch_scale`, arriba del todo en cada script) -- bajarlo
más da más tiempo pero más cambio de tono; subirlo hacia 1.0 es menos
tiempo pero menos cambio de tono.

## Archivos tocados
- `project.godot` — nueva sección `[rendering]`
- `scripts/intro_historia.gd` — `pitch_scale`, `DURACIONES` reescaladas
- `scripts/intro_batalla.gd` — `pitch_scale`, `DURACIONES` reescaladas
