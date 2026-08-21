# CORE AWAKENED — Prototipo 92.3

Base: Prototipo 92.2 (combo de poder CORE completo de Jester).

## Jester: golpe_recibido + derribado -- ya no falta nada del set base

Mapeo (deduje esto por el contenido, ya que llegaron sin nombre salvo la
primera -- si alguna asignación no es la que esperabas, avisá y la
reordeno):

| Archivo subido | Campo |
|---|---|
| GOLPE_RECIBIDO.png | `golpe_recibido.png` (retrocede, cara apretada) |
| 748dc858…png | `golpe_recibido_2.png` (se agarra el estómago, gotita de dolor) |
| ace88a3b…png | `golpe_recibido_3.png` (cae de rodillas, una mano al piso) |
| 2a5e8a17…png | `derribado.png` (tirada en el piso, ojos cerrados) |

Con esto, Jester ya tiene las 4 categorías completas: combate normal,
movimiento, reacciones a golpe, y combo de poder CORE. No hizo falta
calibrar escala a mano para estas -- a diferencia de las poses del combo
de poder, estas no tienen un aura grande alrededor que infle el
rectángulo visible, así que el cálculo automático les queda bien (mismo
criterio que ya funciona para el resto del roster en estas categorías).

## Lo único que sigue pendiente
- Fondo de escenario propio (`assets/fondos/jester.jpg`) y música de
  arena -- sigue usando el último fondo que haya quedado cargado.
- Póster VS dedicado -- sigue usando su pose de batalla como resguardo.
- Tarjeta del selector de personajes -- sigue siendo el placeholder que
  armé yo, no arte final tipo el resto del roster.

Todo lo demás (moveset completo + combo de poder) ya está aplicado.

## Archivos tocados
- `assets/jester/*.png` (4 nuevos)
- `scripts/jester.gd` — golpe_recibido, derribado
