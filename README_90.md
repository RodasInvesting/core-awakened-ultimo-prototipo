# CORE AWAKENED — Prototipo 90

Base: Prototipo 89.11 (los 7 sonidos nuevos, brillo/contraste bajado en los
5 rediseños y la velocidad de vuelo del CORE ya ajustada).

## Jester — 8vo personaje, integrado en modo WIP para probar ya

Se sumó a Jester (la alquimista bufón) como personaje jugable número 8,
seleccionable y enfrentable en Batalla Rápida y Arcade, con el primer lote
de 16 poses que llegaron para ella.

### Arte ya conectado (`assets/jester/`)
- `parado` (usa la pose de inicio de batalla)
- `punetazo_1/2/3`
- `patada_1/2/3/4`
- `caminata_1/2/3`
- `salto`, `doble_salto`, `descenso`, `bloqueo`
- `carrera` (la pose de "doble flecha", misma mecánica que Cibor-X/Helena/
  Kai/Kali)

### Arte que TODAVÍA falta (Fighter cae solo a los resguardos existentes,
no rompe nada mientras tanto)
- `golpe_recibido` (y variantes)
- `derribado`
- `especial` / `rematador` / `absoluto` (las 3 fases del poder CORE)
- `recarga`
- `victoria`
- Todo el set Furia (`furia_*`)

### Escala visual
No se precalculó `ESCALAS_POSE_PRECALCULADAS` para Jester todavía (eso es
un paso de calibración fina, igual que se hizo para el resto en fases
anteriores). Mientras no esté, cada pose usa el resguardo automático de
`_escala_normalizada_por_pose()` en `fighter.gd`, que mide el área alfa
visible de cada PNG contra `parado.png` y ajusta la escala sola (clamp
0.08–2.0). Se puede jugar y ver el tamaño correcto ya mismo; el paso de
precalcular es solo una optimización para cuando el arte esté cerrado.

### Selector de personajes
La lámina `selector_rostros.jpg` sigue teniendo arte terminado solo para
los 7 personajes originales. En vez de deformarla a 8 columnas parejas, se
la escaló un poco menos (de 1.25x a 1.09375x) para liberar una 8va columna
del mismo ancho a la derecha, donde va una tarjeta propia
(`assets/ui/jester_card.jpg`). Esa tarjeta es un placeholder armado con su
pose de batalla sobre un fondo degradado a tono — no es arte final tipo el
resto, hay que reemplazarla cuando haya una ilustración dedicada como la
de los demás.

### Póster VS
Tampoco hay todavía un póster VS cinematográfico dedicado (los de los
otros 7 son ilustraciones grandes aparte, no la pose de pelea). Por ahora
`assets/vs/jester_vs.png` es una copia directa de su pose de batalla;
funciona pero se nota más "plana" que el resto en esa pantalla.

### Gameplay
Arquetipo: alquimista tramposa, rápida y esquiva, pega seguido y carga
CORE un poco más rápido que el promedio, pero aguanta menos golpes y
empuja poco (200 de vida vs. 220 del resto). Efecto de poder especial:
estallido magenta/violeta (`_efecto_estallido`), reutilizando el sistema
genérico -- sin partículas ni sonido propios todavía (usa el sonido de
especial genérico `SND_ESPECIAL` como resguardo).

### Archivos tocados
- `scripts/jester.gd` (nuevo)
- `scripts/game_state.gd` — ROSTER
- `scripts/selector_personajes.gd` — layout de 8 casillas + tarjeta propia
- `scripts/main.gd` — instanciación (`_crear_luchador`), color de ambiente
  y tipo de escenario (ambos sin efecto real hasta que exista
  `assets/fondos/jester.jpg`)
- `scripts/presentacion_vs.gd` — póster VS

## Pendiente para el próximo lote de Jester
Cuando lleguen más poses: golpe_recibido, derribado, especial/rematador/
absoluto, recarga, victoria y furia. Ese mismo lote es buen momento para
precalcular su escala definitiva y, si se quiere, un fondo de escenario y
un póster VS dedicados.

## Varkhos — jefe final de Arcade (recibido, todavía sin implementar)
Se recibió el diseño de Varkhos, "El Ojo del Núcleo", con sus dos estados
de arte (`MODO_NORMAL` / `MODO_FURIA`) y el concepto: bloqueado hasta
terminar el torneo Arcade, más grande, con más golpes y más difícil de
vencer que el resto del roster. Todavía no está integrado a este
prototipo -- ni el arte ni el desbloqueo -- queda como próximo bloque de
trabajo aparte (es una pieza grande: escala mayor, vida/daño propios,
gate de desbloqueo en `game_state.gd` tras completar `arcade_oponentes`, y
probablemente una IA algo distinta a `_comportamiento_ia_basico`).
