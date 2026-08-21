# CORE AWAKENED — Prototipo 94.2

Base: Prototipo 94.1 (fondo negro en transiciones + ritmo de las láminas
ajustado).

## Pantalla de carga real (con texto y barra de progreso)

### Por qué el fondo negro no alcanzaba
Godot bloquea el mismo hilo que dibuja mientras hace una carga de escena
normal -- por eso, aunque el color de fondo ya no fuera gris, no había
forma de mostrar texto ni nada animado durante esa espera: literalmente
no se puede dibujar nada mientras esa carga está en curso.

### La solución de verdad: cargar en otro hilo
Ahora, en vez de cargar la escena pesada directo, se pasa primero por
`PantallaCarga.tscn` -- una escena chica y liviana que:
1. Arranca la carga de la escena de destino en un hilo aparte
   (`ResourceLoader.load_threaded_request`), que no bloquea el dibujado.
2. Mientras tanto, se queda mostrando "CARGANDO" con puntitos animados y
   una barra que avanza con el progreso real de la carga (no es
   decorativa -- son los mismos números que reporta Godot).
3. Apenas termina, cambia a la escena ya cargada.

Fondo azul oscuro (a tono con el resto del juego), letra clara, barra
celeste. Se puede ajustar el color en `pantalla_carga.gd`
(`COLOR_FONDO`) si lo querés de otro tono.

### Dónde se enchufó
Los tres lugares que mencionaste (más uno que tiene exactamente el mismo
problema):
- Después del logo del estudio, antes de la secuencia del origen (8
  imágenes grandes).
- Al elegir Arcade o Batalla Rápida, antes de la secuencia de Varkhos (9
  imágenes grandes).
- **Antes de la pelea** (`PresentacionVS` → `Main`) -- este es el más
  pesado de todos, porque carga el set completo de texturas de los DOS
  personajes de la pelea. Acá es donde más se va a notar el cambio.

### Cómo se usa si en algún momento hace falta en otro lado
Cualquier escena que necesite ir a una escena pesada, en vez de:
```gdscript
get_tree().change_scene_to_file(RUTA_PESADA)
```
hace:
```gdscript
var estado = get_node("/root/GameState")
estado.escena_destino_carga = RUTA_PESADA
get_tree().change_scene_to_file("res://scenes/PantallaCarga.tscn")
```
Quedó armado como sistema reusable, no como un parche pegado en un solo
lugar -- si en algún momento se siente una espera fea en otra transición
(por ejemplo Selector → PresentacionVS, que carga los pósters), se
resuelve con esas mismas dos líneas.

## Archivos nuevos/tocados
- `scenes/PantallaCarga.tscn` (nuevo)
- `scripts/pantalla_carga.gd` (nuevo)
- `scripts/game_state.gd` — `escena_destino_carga`
- `scripts/intro_estudio.gd` — pasa por la pantalla de carga
- `scripts/menu_principal.gd` — pasa por la pantalla de carga
- `scripts/presentacion_vs.gd` — pasa por la pantalla de carga
