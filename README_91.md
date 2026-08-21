# CORE AWAKENED — Prototipo 91

Base: Prototipo 90.5 (parpadeo recalibrado en Kai/Helena/Jester).

## Rediseño de Magnus — Parte 1 de 2

Aplicado el primer lote de arte nueva de Magnus (18 imágenes: salto,
doble salto, pose de inicio, 5 puñetazos, 5 patadas, 4 golpes recibidos y
derribado). Falta la parte 2 (caminata, bloqueo, y lo que corresponda del
combo de poder -- especial/rematador/absoluto/recarga siguen con el arte
vieja hasta que llegue esa parte).

### Mapeo aplicado
| Archivo subido | Reemplaza a |
|---|---|
| SALTO.png | `salto.png` |
| DOLE_SALTO.png | `doble_salto.png` |
| POSE_INICIO_DE_PELEA.png | `parado.png` |
| PUÑO.png … PUÑO (5).png | `punetazo_1.png` … `punetazo_5.png` |
| PATADA.png … PATADA (5).png | `patada_1.png` … `patada_5.png` |
| GOLPE_RECIBIDO.png … (4).png | `golpe_recibido.png`, `_2`, `_3`, `_4` |
| DERROTADO.png | `derribado.png` |

### Limpieza (para no mezclar arte vieja con nueva en la misma categoría)
El set viejo de puñetazo tenía 10 variantes (`punetazo.png` +
`punetazo_1`…`_10`) y el de patada 2 (`patada.png` + `_1`, `_2`). El lote
nuevo trae 5 de cada uno. Borré los archivos viejos que ya no se usan
(`punetazo.png`, `punetazo_6` a `_10`, `patada.png`) y actualicé
`magnus.gd` para que `texturas_punetazo_extra` / `texturas_patada_extra`
apunten solo a los 5 frames nuevos de cada golpe. `golpe_recibido_4` se
agregó como entrada nueva (antes solo había 3 golpes recibidos, ahora 4).

### Escalas: mismo bug que el parpadeo, mismo arreglo
Magnus tenía una entrada precalculada en `ESCALAS_POSE_PRECALCULADAS`
para cada PNG (calibradas contra el arte vieja, que era mucho más chica
--260x304 el parado viejo, contra 1254x1254 el nuevo). Si dejaba esas
entradas, el juego iba a aplicarle a la ilustración nueva una escala
pensada para la vieja, y se iba a ver mal (probablemente enorme o
minúsculo, según la pose). Saqué las entradas de los 15 archivos que
reemplacé (parado, salto, doble_salto, los 5 puñetazo, los 5 patada, los
4 golpe_recibido, derribado) -- para esos, ahora corre el cálculo
automático en tiempo real (el mismo que usan Jester y Varkhos mientras no
tienen calibración fina todavía). Dejé sin tocar las entradas de todo lo
que sigue con arte vieja: bloqueo, caminata_der/izq, especial, rematador,
absoluto, recarga y todo el set furia_ -- esas siguen siendo válidas
porque el archivo que describen no cambió.

## Archivos tocados
- `assets/magnus/*.png` (18 reemplazados, 6 borrados)
- `scripts/magnus.gd` — arrays de texturas de puñetazo/patada/golpe_recibido
- `scripts/fighter.gd` — `ESCALAS_POSE_PRECALCULADAS` (15 entradas
  removidas, solo las de Magnus que correspondían a arte reemplazada)

## Pendiente (parte 2)
Caminata, bloqueo, y el combo de poder (especial/rematador/absoluto/
recarga) si también se van a rediseñar. Cuando lleguen, mismo proceso:
reemplazar en la misma ruta, sacar la entrada vieja de
`ESCALAS_POSE_PRECALCULADAS` si el archivo cambia de tamaño/proporción, y
no dejar mezcla de arte vieja con nueva en una misma categoría de golpe.
