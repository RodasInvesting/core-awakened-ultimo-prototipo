# CORE AWAKENED — Prototipo 92

Base: Prototipo 91 (Magnus rediseño parte 1: pose base + golpes + golpes
recibidos + derribado).

## Rediseño de Magnus — Parte 2 de 2 (completo)

### Mapeo aplicado
| Archivo subido | Reemplaza a / campo |
|---|---|
| BLOQUEO.png | `bloqueo.png` |
| CAMINATA.png / CAMINATA (2).png | `caminata_der.png` / `caminata_izq.png` |
| ACELERACION_2_VECES_LA_FLECHITA.png | `carrera.png` **(campo nuevo)** |
| DECENSO.png | `descenso.png` **(campo nuevo)** |
| RECARGA_DE_ENERGIA.png | `recarga.png` |
| ACELLERACION_ANTES_DEL_COMBO.png | `especial.png` |
| COMBO.png … COMBO (6).png | `furia_punetazo_1.png` … `_6.png` |
| REMATE_DEL_COMBO.png | `rematador.png` |
| POSE_PARADO_MODO_FURIA.png | `furia_parado.png` |
| VICTORIA.png | `victoria.png` **(detección automática)** |

### Cómo decidí el mapeo de las piezas del combo de poder
Magnus no tiene un campo "combo" -- reconstruí qué pieza es cada imagen
siguiendo el orden real de la cinemática en `fighter.gd`
(`_secuencia_rematador()`): especial (flash previo) → `_entrar_furia()`
→ recarga → combo automático (usa las texturas furia_punetazo, porque ya
está en fase furia) → remate. Con eso: RECARGA_DE_ENERGIA es la pose de
carga con energía en ambos puños; ACELLERACION_ANTES_DEL_COMBO es el
flash previo (`textura_especial`) porque se muestra ANTES de entrar en
furia; las 6 COMBO son justo las que se ven durante el combo automático
una vez que ya está transformado, así que van al array de
`furia_punetazo`; y REMATE_DEL_COMBO -- con el impacto y las siluetas
fantasma de fondo -- es el golpe de cierre (`textura_rematador`).

### Dos campos que Magnus no tenía y ahora sí
- `textura_carrera`: no existía. Se agregó junto con `ACELERACION_2_VECES_LA_FLECHITA.png`
  -- misma mecánica de doble toque de flecha que ya usan Kai/Helena/
  Cibor-X/Kali/Jester.
- `textura_descenso`: tampoco existía. Ahora tiene su propia pose de
  caída en vez de compartir la de salto.

`victoria.png` no necesitó ningún cambio de código: `fighter.gd` ya
detecta sola cualquier `assets/<personaje>/victoria.png` que exista
(FASE 85), así que con solo poner el archivo alcanzó.

### Limpieza
El set viejo de furia_punetazo tenía 7 variantes numeradas + una base sin
usar (`furia_punetazo.png`, jamás referenciada). El lote nuevo trae 6.
Igual que en la parte 1, no se mezcla: se actualizó
`texturas_furia_punetazo_extra` a las 5 nuevas y se borraron
`furia_punetazo.png` y `furia_punetazo_7.png` (ya sin uso).

### Escalas
Mismo criterio que la parte 1: se sacaron de `ESCALAS_POSE_PRECALCULADAS`
las entradas de todos los archivos reemplazados (bloqueo, caminata_der/
izq, especial, furia_parado, furia_punetazo 1 a 7, recarga, rematador) --
corren con el cálculo automático hasta que se calibren de nuevo. Ojo: en
un primer paso había sacado por error también las de furia_derribado,
furia_golpe_recibido y furia_patada (esos tres NO cambiaron en esta
parte) -- las restauré antes de cerrar esta fase.

## Estado de Magnus, resumen
Con esto, Magnus queda con arte nueva en TODO su set normal y furia
excepto: `absoluto.png` (remate del 3er CORE) y `furia_patada` /
`furia_derribado` / `furia_golpe_recibido`. Si en algún momento llega
arte nueva para esas, mismo proceso: reemplazar en la misma ruta y sacar
la entrada vieja de `ESCALAS_POSE_PRECALCULADAS`.

## Archivos tocados
- `assets/magnus/*.png` (10 reemplazados/agregados, 2 borrados)
- `scripts/magnus.gd` — furia_punetazo, `textura_descenso`,
  `textura_carrera`
- `scripts/fighter.gd` — `ESCALAS_POSE_PRECALCULADAS`
