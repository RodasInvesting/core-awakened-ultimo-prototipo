# CORE AWAKENED — Prototipo 92.2

Base: Prototipo 92.1 (fix de la clave duplicada + combo/escala de Magnus).

## Jester: se completa el combo de poder CORE

Con este lote, Jester pasa de tener solo el set de combate normal a tener
también todo el combo de poder: especial, recarga, rematador, absoluto,
furia_parado, victoria, y su primer set de furia_punetazo/furia_patada.

### Mapeo aplicado
| Archivo subido | Campo |
|---|---|
| RECARGA_DE_ENERGIA.png | `recarga.png` |
| ACELARACION_ANTES_DEL_COMBO.png | `especial.png` |
| REMATE.png | `rematador.png` |
| GIGANTOGRAFIA_DEL_ULTIMO_GOLPE_FINAL.png | `absoluto.png` |
| PARADO_MODO_FURIA.png | `furia_parado.png` |
| VICTORIA.png | `victoria.png` (detección automática) |
| COMBO.png, COMBO (2)-(4).png, COMBOO.png | `furia_punetazo_1.png`…`_5.png` |
| COMBO (5).png | `furia_patada_1.png` |

### Por qué una de las 6 "combo" fue a patada y no a puñetazo
A diferencia del lote de Magnus (donde las 6 eran puñetazos), acá
`COMBO (5).png` es claramente una patada (pierna extendida, estela en
forma de corazón) -- así que fue a `furia_patada_1` en vez de sumarse al
array de puños.

### Aprendizaje del combo de Magnus, aplicado antes de que preguntes
Con Magnus vimos dos cosas:
1. El combo automático alterna puño/patada -- si falta arte de patada
   furia, se mezcla con la vieja. Acá **no hace falta ningún interruptor**:
   como Jester es un personaje nuevo, no tiene arte vieja de furia_patada
   con la que mezclarse -- el único frame que tiene (`furia_patada_1`) ya
   es parte de este mismo lote. El combo automático de Jester queda
   activado con puño y patada normalmente.
2. Las poses del combo de poder (mucha aura/energía alrededor) hacían que
   el cálculo automático de escala las mostrara más chicas de lo que se
   ven en la ilustración. Esta vez calibré esas 8 imágenes a mano DESDE EL
   ARRANQUE (mismo criterio: +18% sobre el cálculo automático), en vez de
   esperar a que se viera mal en el juego.

## Todavía sin arte propio
`golpe_recibido` y `derribado`. El resto del set (parado, puños, patadas,
caminata, salto, bloqueo, etc.) ya estaba de la entrega anterior.

## Archivos tocados
- `assets/jester/*.png` (12 nuevos)
- `scripts/jester.gd` — nuevos campos de textura
- `scripts/fighter.gd` — `ESCALAS_POSE_PRECALCULADAS` (11 entradas nuevas
  para Jester)
