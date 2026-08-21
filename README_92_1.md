# CORE AWAKENED — Prototipo 92.1

Base: Prototipo 92 (Magnus rediseño completo, partes 1 y 2).

## Los 3 problemas que reportaste, uno por uno

### 1) "Aparecen de la antigua camada todavía algunos" -- ya sé por qué
El combo automático (`_racha_combo_auto()` en `fighter.gd`) **alterna
golpe y patada en cada golpe** (puño, patada, puño, patada...). Como
nadie mandó todavía patadas nuevas para el combo, la mitad de los golpes
del combo seguían mostrando `furia_patada_1.png` / `furia_patada_2.png`
-- que son de la camada vieja (chiquitos, ~300-500px) -- mezclados con
los puños nuevos y grandes. No era algo esporádico: al alternar siempre,
tocaba en la mitad de los golpes.

**Arreglo**: agregué un interruptor por personaje
(`combo_auto_incluye_patada`, default `true` para no tocar a nadie más) y
lo apagué para Magnus. Mientras no haya patadas nuevas para el combo, el
combo de Magnus pega solo con puños -- se pierde la variedad patada/puño
por ahora, pero no se ve más la mezcla vieja/nueva. Apenas mandes esas
patadas, aviso y lo prendo de nuevo.

### 2) "El remate sale muy chico"
Cuando limpié `ESCALAS_POSE_PRECALCULADAS` en la fase anterior, dejé que
`rematador.png` (y el resto del combo de poder: especial, recarga, los 6
furia_punetazo) se autocalcularan en tiempo real -- el mismo sistema que
usa Jester/Varkhos. El problema es que ese cálculo automático mide el
"rectángulo visible" completo, aura de energía incluida, y en estas
ilustraciones la garra/aura ocupa mucho más espacio que en una pose
parada común -- así que el golem terminaba más chico de lo que se ve en
la ilustración original.

**Arreglo**: les puse un valor de escala calculado a mano para las 8
imágenes del combo de poder (especial, recarga, rematador, los 6
furia_punetazo), con un empuje extra de +18% para que se vean con la
presencia que tienen que tener en el momento más importante de la pelea.

### 3) "El golem tiene que ser un poco más grande"
Agregué a Magnus a `ALTURA_AJUSTES_VISUALES` (mismo sistema que ya usa
Varkhos para el jefe final) con un valor de **1.15** -- 15% más alto en
TODAS sus poses normales (parado, caminata, puños, patadas, golpes
recibidos, salto, bloqueo, etc.), consistente con que ya es, por diseño,
el más pesado y grande del roster original.

Como ese ajuste no le llega a las imágenes que tienen un valor calibrado
a mano (`absoluto.png` y las 3 que todavía son de la camada vieja:
furia_derribado, furia_golpe_recibido, furia_patada), les subí esos
números un 15% también, a mano, para que Magnus se vea igual de grande
en cualquier pose, sin un salto de tamaño incómodo entre una pose y otra.

## Archivo tocado
- `scripts/fighter.gd` — `combo_auto_incluye_patada` (nuevo),
  `_racha_combo_auto()`, `ALTURA_AJUSTES_VISUALES`, `ESCALAS_POSE_PRECALCULADAS`
- `scripts/magnus.gd` — `combo_auto_incluye_patada = false`

## Pendiente
Patadas nuevas para el combo (furia_patada) cuando las tengas -- ahí
reactivo `combo_auto_incluye_patada` en Magnus y calibro su escala igual
que el resto.
