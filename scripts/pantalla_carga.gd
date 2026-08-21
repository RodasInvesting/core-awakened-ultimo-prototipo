extends Node2D

# FASE 94.2: pantalla de carga real. Godot no puede dibujar NADA mientras
# hace una carga normal (change_scene_to_file de una escena pesada bloquea
# el mismo hilo que dibuja) -- por eso el fix anterior (fondo negro) solo
# ocultaba el instante feo, pero no achicaba la espera ni mostraba nada
# mientras tanto. Esto sí: carga la escena pesada en un hilo aparte
# (ResourceLoader.load_threaded_*) mientras esta pantalla, que es liviana,
# se queda dibujando el texto y la barra con el progreso real.
#
# Cómo se usa desde cualquier otra escena, en vez de
# get_tree().change_scene_to_file(RUTA_PESADA):
#   var estado = get_node("/root/GameState")
#   estado.escena_destino_carga = RUTA_PESADA
#   get_tree().change_scene_to_file("res://scenes/PantallaCarga.tscn")

const TAMANO_PANTALLA := Vector2(1280.0, 720.0)
const COLOR_FONDO := Color(0.06, 0.11, 0.22)
const COLOR_BARRA_FONDO := Color(1.0, 1.0, 1.0, 0.15)
const COLOR_BARRA_RELLENO := Color(0.55, 0.75, 1.0)
const ANCHO_BARRA := 420.0
const ALTO_BARRA := 8.0
const INTERVALO_PUNTOS := 0.4

var ruta_destino: String = ""
var cargando := false
var label_estado: Label
var barra_relleno: ColorRect
var tiempo_puntos := 0.0

func _ready() -> void:
	var estado = get_node("/root/GameState")
	ruta_destino = estado.escena_destino_carga

	var fondo := ColorRect.new()
	fondo.color = COLOR_FONDO
	fondo.position = Vector2.ZERO
	fondo.size = TAMANO_PANTALLA
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)

	label_estado = Label.new()
	label_estado.text = "CARGANDO"
	label_estado.position = Vector2(0.0, 330.0)
	label_estado.size = Vector2(TAMANO_PANTALLA.x, 50.0)
	label_estado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_estado.add_theme_font_size_override("font_size", 30)
	label_estado.add_theme_color_override("font_color", Color(0.86, 0.91, 1.0))
	add_child(label_estado)

	var barra_x: float = (TAMANO_PANTALLA.x - ANCHO_BARRA) * 0.5
	var barra_fondo := ColorRect.new()
	barra_fondo.color = COLOR_BARRA_FONDO
	barra_fondo.position = Vector2(barra_x, 392.0)
	barra_fondo.size = Vector2(ANCHO_BARRA, ALTO_BARRA)
	add_child(barra_fondo)

	barra_relleno = ColorRect.new()
	barra_relleno.color = COLOR_BARRA_RELLENO
	barra_relleno.position = Vector2(barra_x, 392.0)
	barra_relleno.size = Vector2(0.0, ALTO_BARRA)
	add_child(barra_relleno)

	if ruta_destino == "":
		# Resguardo: si por lo que sea no se seteó destino, no deja a
		# nadie mirando una barra de carga que nunca va a ningún lado.
		push_warning("PantallaCarga sin escena_destino_carga -- volviendo al menú.")
		get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
		return

	var err := ResourceLoader.load_threaded_request(ruta_destino)
	if err != OK:
		push_warning("No se pudo iniciar la carga en segundo plano de %s (error %d) -- cargando directo." % [ruta_destino, err])
		get_tree().change_scene_to_file(ruta_destino)
		return
	cargando = true

func _process(delta: float) -> void:
	if not cargando:
		return

	tiempo_puntos += delta
	var puntos: int = int(tiempo_puntos / INTERVALO_PUNTOS) % 4
	label_estado.text = "CARGANDO" + ".".repeat(puntos)

	var progreso: Array = []
	var estado_carga := ResourceLoader.load_threaded_get_status(ruta_destino, progreso)
	if progreso.size() > 0:
		barra_relleno.size.x = ANCHO_BARRA * clampf(float(progreso[0]), 0.0, 1.0)

	match estado_carga:
		ResourceLoader.THREAD_LOAD_LOADED:
			cargando = false
			var escena := ResourceLoader.load_threaded_get(ruta_destino) as PackedScene
			get_tree().change_scene_to_packed(escena)
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			cargando = false
			push_warning("Falló la carga en segundo plano de %s -- cargando directo." % ruta_destino)
			get_tree().change_scene_to_file(ruta_destino)
