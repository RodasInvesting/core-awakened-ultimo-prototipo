# CORE AWAKENED — Prototipo 90.3

Base: Prototipo 90.2 (empuje real durante el combo del CORE + empuje
global subido 1.35x).

## Segunda capa: el "golpe seco" instantáneo también estaba apagado en el combo

Revisando el mismo sistema encontré otro lugar donde el combo se salteaba
por completo una reacción física: `_aplicar_contacto_corporal_post_golpe()`.

Esta función hace dos cosas en el mismo frame del impacto (antes de que
el empuje físico de 90.2 termine de acelerar el cuerpo):
1. Corrige separación mínima para que el golpe no se vea "atravesado".
2. Suma un microdesplazamiento instantáneo al defensor (5.5–14px según la
   fuerza del golpe) -- esto es lo que hace que un golpe se sienta "seco"
   en el instante exacto del contacto, antes de que el empuje con
   velocidad (más gradual) siga empujando.

Antes, esta función entera se salteaba durante el combo automático
(`en_secuencia_especial`). Ahora, durante el combo, se deja pasar
**solo** el paso 2 (el golpe seco al defensor). El paso 1 (separación) y
el auto-recoil del atacante siguen sin tocarse durante el combo a
propósito: esa parte de la posición del atacante ya la controla el tween
de `_acercar_para_combo_auto()`, y sumarle un ajuste instantáneo aparte
podía generar un microtemblor peleando contra ese tween. El defensor no
tiene ningún tween controlándolo, así que a él no le genera ese riesgo.

## Resultado esperado
Cada golpe del combo ahora debería sentirse en dos tiempos: un golpe seco
instantáneo en el momento exacto del contacto + el empuje con velocidad
que ya veníamos arreglando, que sigue empujando un rato más y hace que el
atacante tenga que perseguir para conectar el siguiente golpe.

## Otros números disponibles para seguir afinando (todos en `fighter.gd`)
- `MULT_EMPUJE_GLOBAL` (90.2): empuje de TODOS los golpes del juego.
- Los `5.5`–`14.0` de `impulso_defensor` en
  `_aplicar_contacto_corporal_post_golpe()`: el golpe seco instantáneo
  específicamente.
- Si después de probar quieren que el combo empuje distinto que los
  golpes sueltos (por ejemplo, más fuerte en combo para que se note más
  el "vuelo" entre golpes), es separar `MULT_EMPUJE_GLOBAL` en dos
  constantes -- avisen y lo hacemos.

## Archivo tocado
- `scripts/fighter.gd` — `_aplicar_contacto_corporal_post_golpe()`
