extends Control

# CORE AWAKENED 91.02.00 — selector de escenarios con KROVAN + NEKHAR.
# Arcade conserva escenario automático según rival.
const ESCENARIOS: Array[String] = [
	"Kai", "Cibor-X", "Fang", "Kali", "Aethel", "Magnus",
	"Helena", "Jester", "Xenoid", "Dax", "Varkhos", "Krovan", "Nekhar", "Virgilio"
]

const NOMBRES := {
	"Kai": "SANTUARIO VIOLETA",
	"Cibor-X": "NÚCLEO CIBERNÉTICO",
	"Fang": "TEMPLO DEL TIGRE",
	"Kali": "COLMENA ESMERALDA",
	"Aethel": "ALTAR CELESTIAL",
	"Magnus": "FORJA TITÁNICA",
	"Helena": "SANTUARIO DEL DRAGÓN",
	"Jester": "LABORATORIO DEL VACÍO",
	"Xenoid": "NEXO XENOID",
	"Dax": "COLISEO ROJO",
	"Varkhos": "TRONO DEL NÚCLEO",
	"Krovan": "CAMPO DE LA ÚLTIMA COSECHA",
	"Nekhar": "SEPULCRO DE KHEMET",
	"Virgilio": "CHACO PARAGUAYO",
}

const RUTAS := {
	"Kai": "res://assets/fondos/kai.jpg",
	"Cibor-X": "res://assets/fondos/cibor-x.png",
	"Fang": "res://assets/fondos/fang.jpg",
	"Kali": "res://assets/fondos/kali.png",
	"Aethel": "res://assets/fondos/aethel.png",
	"Magnus": "res://assets/fondos/magnus.jpg",
	"Helena": "res://assets/fondos/helena.png",
	"Jester": "res://assets/fondos/jester.png",
	"Xenoid": "res://assets/fondos/xenoid.png",
	"Dax": "res://assets/fondos/dax.png",
	"Varkhos": "res://assets/fondos/varkhos.png",
	"Krovan": "res://assets/fondos/krovan.png",
	"Nekhar": "res://assets/fondos/nekhar.png",
	"Virgilio": "res://assets/fondos/virgilio_chaco_paraguayo.png",
}

const COLORES := {
	"Kai": Color(0.66, 0.22, 1.0),
	"Cibor-X": Color(0.05, 0.75, 1.0),
	"Fang": Color(1.0, 0.34, 0.04),
	"Kali": Color(0.42, 1.0, 0.06),
	"Aethel": Color(0.58, 0.88, 1.0),
	"Magnus": Color(1.0, 0.56, 0.10),
	"Helena": Color(1.0, 0.18, 0.62),
	"Jester": Color(0.85, 0.25, 0.85),
	"Xenoid": Color(0.42, 1.0, 0.08),
	"Dax": Color(0.96, 0.18, 0.08),
	"Varkhos": Color(0.62, 0.18, 1.0),
	"Krovan": Color(1.0, 0.62, 0.12),
	"Nekhar": Color(1.0, 0.38, 0.08),
	"Virgilio": Color(0.72, 0.76, 0.58),
}

const COLUMNAS := 6
const TARJETA_W := 190.0
const TARJETA_H := 112.0
const GAP_X := 14.0
const GAP_Y := 18.0
const INICIO_X := 35.0
const INICIO_Y := 150.0

var indice := 0
var tarjetas: Array[Panel] = []
var labels_nombres: Array[Label] = []
var confirmando := false
var musica: AudioStreamPlayer
var titulo_seleccion: Label

func _es_online() -> bool:
	var estado := get_node_or_null("/root/GameState")
	return estado != null and str(estado.modo) == "online"

func _network() -> Node:
	return get_node_or_null("/root/NetworkManager")

func _ready() -> void:
	var estado = get_node("/root/GameState")
	if estado.modo == "arcade":
		get_tree().change_scene_to_file("res://scenes/PresentacionVS.tscn")
		return
	_crear_fondo()
	_crear_titulo()
	_crear_tarjetas()
	_crear_ayuda()
	_crear_audio()
	if _es_online():
		var red := _network()
		if red != null:
			indice = clampi(int(red.escenario_preview_indice), 0, ESCENARIOS.size() - 1)
			if not red.escenario_preview_cambiado.is_connected(_al_preview_online):
				red.escenario_preview_cambiado.connect(_al_preview_online)
	_actualizar_seleccion()

func _crear_fondo() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.006, 0.004, 0.015)
	bg.position = Vector2.ZERO
	bg.size = Vector2(1280, 720)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var halo := ColorRect.new()
	halo.color = Color(0.12, 0.02, 0.22, 0.42)
	halo.position = Vector2.ZERO
	halo.size = Vector2(1280, 720)
	halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(halo)

func _crear_titulo() -> void:
	var titulo := Label.new()
	titulo.text = "SELECCIONA EL ESCENARIO"
	titulo.position = Vector2(250, 22)
	titulo.size = Vector2(780, 38)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 30)
	titulo.add_theme_color_override("font_color", Color(1.0, 0.90, 0.68))
	add_child(titulo)

	titulo_seleccion = Label.new()
	titulo_seleccion.position = Vector2(250, 60)
	titulo_seleccion.size = Vector2(780, 28)
	titulo_seleccion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo_seleccion.add_theme_font_size_override("font_size", 18)
	titulo_seleccion.add_theme_color_override("font_color", Color(0.82, 0.72, 1.0))
	add_child(titulo_seleccion)

func _crear_tarjetas() -> void:
	for i in range(ESCENARIOS.size()):
		var escenario: String = ESCENARIOS[i]
		var fila: int = int(i / COLUMNAS)
		var columna: int = i % COLUMNAS
		var pos := Vector2(
			INICIO_X + float(columna) * (TARJETA_W + GAP_X),
			INICIO_Y + float(fila) * (TARJETA_H + GAP_Y)
		)

		var panel := Panel.new()
		panel.position = pos
		panel.size = Vector2(TARJETA_W, TARJETA_H)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.clip_contents = true
		add_child(panel)
		tarjetas.append(panel)

		var imagen := TextureRect.new()
		imagen.texture = load(RUTAS[escenario])
		imagen.position = Vector2(4, 4)
		imagen.size = Vector2(TARJETA_W - 8.0, TARJETA_H - 8.0)
		imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
		imagen.clip_contents = true
		panel.add_child(imagen)

		var franja := ColorRect.new()
		franja.position = Vector2(4, TARJETA_H - 30.0)
		franja.size = Vector2(TARJETA_W - 8.0, 26.0)
		franja.color = Color(0.0, 0.0, 0.0, 0.76)
		franja.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(franja)

		var nombre := Label.new()
		nombre.text = NOMBRES[escenario]
		nombre.position = Vector2(8, TARJETA_H - 28.0)
		nombre.size = Vector2(TARJETA_W - 16.0, 22.0)
		nombre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nombre.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		nombre.add_theme_font_size_override("font_size", 11 if escenario in ["Krovan", "Nekhar", "Virgilio"] else 12)
		nombre.add_theme_color_override("font_color", Color.WHITE)
		nombre.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(nombre)
		labels_nombres.append(nombre)

		var zona := Button.new()
		zona.flat = true
		zona.text = ""
		zona.position = pos
		zona.size = Vector2(TARJETA_W, TARJETA_H)
		zona.modulate.a = 0.01
		zona.mouse_entered.connect(_seleccionar_indice.bind(i))
		zona.pressed.connect(_click_indice.bind(i))
		add_child(zona)

func _crear_ayuda() -> void:
	var ayuda := Label.new()
	ayuda.text = "← → ↑ ↓ ELEGIR     ENTER CONFIRMAR     ESC VOLVER"
	ayuda.position = Vector2(350, 676)
	ayuda.size = Vector2(900, 24)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ayuda.add_theme_font_size_override("font_size", 14)
	ayuda.add_theme_color_override("font_color", Color(1.0, 0.84, 0.56))
	add_child(ayuda)

	var modo := Label.new()
	var estado = get_node("/root/GameState")
	modo.text = "ONLINE — HOST ELIGE" if estado.modo == "online" else ("VERSUS LOCAL" if estado.modo == "versus_local" else "MODO VERSUS")
	modo.position = Vector2(28, 676)
	modo.size = Vector2(200, 24)
	modo.add_theme_font_size_override("font_size", 16)
	modo.add_theme_color_override("font_color", Color(0.86, 0.74, 1.0))
	add_child(modo)

func _crear_audio() -> void:
	musica = AudioStreamPlayer.new()
	musica.stream = load("res://assets/sonidos/menu/selector_loop.mp3")
	musica.volume_db = -12.0
	add_child(musica)
	musica.finished.connect(func(): musica.play())
	musica.play()

func _sonido_navegacion() -> void:
	var estado := get_node_or_null("/root/GameState")
	if estado and estado.has_method("reproducir_navegacion_ui"):
		estado.reproducir_navegacion_ui()

func _seleccionar_indice(idx: int) -> void:
	if confirmando:
		return
	if _es_online():
		var red := _network()
		if red == null or not red.es_host():
			return
	if idx != indice:
		indice = idx
		_sonido_navegacion()
		_actualizar_seleccion()
		_publicar_preview_online()

func _click_indice(idx: int) -> void:
	if confirmando:
		return
	if _es_online():
		var red := _network()
		if red == null or not red.es_host():
			return
	if indice == idx:
		_confirmar()
	else:
		indice = idx
		_sonido_navegacion()
		_actualizar_seleccion()
		_publicar_preview_online()

func _actualizar_seleccion() -> void:
	indice = wrapi(indice, 0, ESCENARIOS.size())
	for i in range(tarjetas.size()):
		var escenario: String = ESCENARIOS[i]
		var c: Color = COLORES[escenario]
		var estilo := StyleBoxFlat.new()
		estilo.bg_color = Color(0.02, 0.01, 0.04, 0.92)
		if i == indice:
			estilo.border_color = c
			estilo.set_border_width_all(4)
			estilo.shadow_color = Color(c.r, c.g, c.b, 0.78)
			estilo.shadow_size = 12
			labels_nombres[i].add_theme_color_override("font_color", c.lerp(Color.WHITE, 0.58))
		else:
			estilo.border_color = Color(0.35, 0.30, 0.45, 0.72)
			estilo.set_border_width_all(1)
			estilo.shadow_size = 0
			labels_nombres[i].add_theme_color_override("font_color", Color.WHITE)
		estilo.corner_radius_top_left = 6
		estilo.corner_radius_top_right = 6
		estilo.corner_radius_bottom_left = 6
		estilo.corner_radius_bottom_right = 6
		tarjetas[i].add_theme_stylebox_override("panel", estilo)

	var actual: String = ESCENARIOS[indice]
	titulo_seleccion.text = NOMBRES[actual]
	titulo_seleccion.add_theme_color_override("font_color", COLORES[actual].lerp(Color.WHITE, 0.32))

func _al_preview_online(nuevo_indice: int) -> void:
	if not _es_online():
		return
	indice = clampi(nuevo_indice, 0, ESCENARIOS.size() - 1)
	_actualizar_seleccion()

func _publicar_preview_online() -> void:
	if not _es_online():
		return
	var red := _network()
	if red != null and red.es_host():
		red.actualizar_preview_escenario(indice)

func _unhandled_input(event: InputEvent) -> void:
	if confirmando:
		return
	if _es_online():
		var red := _network()
		if red == null:
			return
		if event.is_action_pressed("ui_cancel"):
			red.cerrar_conexion()
			get_node("/root/GameState").volver_al_menu()
			get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
			return
		# El Cliente observa; la autoridad de escenario es exclusivamente el Host.
		if not red.es_host():
			return

	if event.is_action_pressed("ui_left"):
		indice -= 1
		_sonido_navegacion()
		_actualizar_seleccion()
		_publicar_preview_online()
	elif event.is_action_pressed("ui_right"):
		indice += 1
		_sonido_navegacion()
		_actualizar_seleccion()
		_publicar_preview_online()
	elif event.is_action_pressed("ui_up"):
		indice -= COLUMNAS
		_sonido_navegacion()
		_actualizar_seleccion()
		_publicar_preview_online()
	elif event.is_action_pressed("ui_down"):
		indice += COLUMNAS
		_sonido_navegacion()
		_actualizar_seleccion()
		_publicar_preview_online()
	elif event.is_action_pressed("ui_accept"):
		_confirmar()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/SelectorPersonajes.tscn")

func _confirmar() -> void:
	if confirmando:
		return
	var estado = get_node("/root/GameState")
	if _es_online():
		var red := _network()
		if red == null or not red.es_host():
			return
		confirmando = true
		red.confirmar_escenario_online(ESCENARIOS[indice])
		return
	confirmando = true
	estado.seleccionar_escenario(ESCENARIOS[indice])
	await get_tree().create_timer(0.18).timeout
	get_tree().change_scene_to_file("res://scenes/PresentacionVS.tscn")
