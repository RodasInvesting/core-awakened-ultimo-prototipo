# CORE AWAKENED — Prototipo 90.1

Base: Prototipo 90 (Jester integrada como 8vo personaje).

## Varkhos, "El Ojo del Núcleo" — jefe final de Arcade

Se integró el sistema de jefe final: Varkhos ya se puede pelear, pero
sigue siendo WIP (arte de combate pendiente, ver abajo).

### Cómo queda bloqueado
Varkhos **no está en `ROSTER`** (`game_state.gd`) -- por diseño: eso lo
saca automáticamente del selector de personajes, del sorteo de Batalla
Rápida y del sorteo normal de rivales de Arcade. En cambio,
`iniciar_arcade()` lo agrega aparte, siempre como último elemento de
`arcade_oponentes`, después de barajar al resto. Como `es_final_arcade()`
ya comparaba contra el último índice de esa lista, la pelea de Varkhos
queda automáticamente marcada como "la final" sin tocar esa lógica.

Para probarlo sin jugar todo el torneo: atajo de debug en batalla, tecla
**8** (rival). Sigue sin ser seleccionable como jugador ni aparece en
Batalla Rápida.

### Arte: qué hay y qué falta
Solo llegaron sus dos ilustraciones de estado (no un set de combate como
el resto del roster):
- `assets/varkhos/parado.png` ← Modo Normal
- `assets/varkhos/furia_parado.png` ← Modo Furia (se activa solo cuando
  SU propio CORE se carga, igual que a cualquier personaje)

**Importante:** `intentar_punetazo()` / `intentar_patada()` en
`fighter.gd` se cancelan solas si la lista de texturas de ese golpe está
vacía. Sin nada puesto ahí, Varkhos no podría atacar nunca -- ni un solo
golpe, IA o no. Por eso, temporalmente, `punetazo_1.png` y `patada_1.png`
son copias de su Modo Normal: el daño, el empuje y el hit real SÍ
funcionan, pero todavía no hay una animación de golpe propia (no se lo va
a ver "pegar", el sprite no cambia durante el ataque). Apenas llegue arte
de combate dedicado, es cambiar esos dos `load()` en `varkhos.gd`.

Sigue sin arte (con resguardo seguro, no rompe nada): golpe_recibido,
derribado, especial/rematador/absoluto, recarga, victoria.

### Tamaño y stats
Es notoriamente más grande que el resto: `mult_tamano_extra = 1.45`
(colisión/ancla de póster) y una entrada nueva en
`ALTURA_AJUSTES_VISUALES` (`fighter.gd`) de `1.35` para que el sprite se
vea más alto también, no solo pese más en colisión. Vida 480 (vs. 310 de
Magnus, el más resistente del roster hasta ahora), daño de puño/patada
por encima del resto, golpes más pesados (`peso_golpe = 2.2`) y más
lento/torpe (`velocidad = 150`, salto débil). La IA reusa
`_comportamiento_ia_basico()` pero con parámetros agresivos: casi no
retrocede, casi no bloquea, y persigue de mucho más lejos que cualquier
otro personaje. Todavía usa la IA genérica -- un patrón propio queda
pendiente para cuando tenga animaciones que lo justifiquen.

### Presentación
- Póster VS: usa directamente `MODO_FURIA` como `varkhos_vs.png`
  (resguardo, no es un póster cinematográfico dedicado como los del resto).
- Pantalla de "siguiente rival": si el próximo rival es Varkhos, en vez
  del cartel normal "SIGUIENTE: X" ahora dice **"EL NÚCLEO DESPIERTA..."**
  en rojo -- el primer toque de puesta en escena para el jefe final.
- Todavía sin fondo de escenario propio (`assets/fondos/varkhos.jpg`) ni
  música de arena -- la pelea usa el último fondo/tema que haya quedado
  cargado. El color de ambiente y el tipo de escenario para cuando exista
  ese fondo ya están precargados en `main.gd` (`AMBIENTE_COLORES`,
  quedaría por asignarle un `_tipo_escenario` propio en vez del genérico
  "oscuro" actual).

### Archivos tocados
- `scripts/varkhos.gd` (nuevo)
- `scripts/fighter.gd` — `ALTURA_AJUSTES_VISUALES`
- `scripts/game_state.gd` — `JEFE_FINAL`, `iniciar_arcade()`
- `scripts/main.gd` — instanciación, atajo de debug (tecla 8), color de
  ambiente
- `scripts/presentacion_vs.gd` — póster VS
- `scripts/resultado.gd` — cartel especial antes de la pelea final

## Pendiente
1. Arte de combate real (golpe, patada, golpe_recibido, derribado como
   mínimo para que la pelea se sienta terminada).
2. Fondo/escenario propio + música de arena.
3. Opcional: patrón de IA propio (patrones de golpe más lentos/leídos,
   quizás una fase de enfurecimiento cuando le queda poca vida) una vez
   que haya animación para venderlo.
