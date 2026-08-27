extends Control

const TAMANO := Vector2(1280.0, 720.0)
var musica: AudioStreamPlayer
var botones: Array[Button] = []
var _menu_listo := false

func _ready() -> void:
	crear_fondo_centrado()
	crear_menu_centrado()
	crear_audio()

func crear_fondo_centrado() -> void:
	var fondo := Sprite2D.new()
	fondo.texture = load("res://assets/ui/portada_inicio_nueva.png")
	fondo.centered = true
	fondo.position = TAMANO * 0.5
	if fondo.texture:
		var tex_size: Vector2 = fondo.texture.get_size()
		fondo.scale = Vector2(TAMANO.x / tex_size.x, TAMANO.y / tex_size.y)
	fondo.z_index = -10
	add_child(fondo)

	var velo := ColorRect.new()
	velo.position = Vector2.ZERO
	velo.size = TAMANO
	velo.color = Color(0.0, 0.0, 0.0, 0.10)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	velo.z_index = -5
	add_child(velo)

func estilo_boton(boton: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.022, 0.020, 0.050, 0.94)
	normal.border_color = Color(0.94, 0.55, 0.08, 0.95)
	normal.set_border_width_all(2)
	normal.corner_radius_top_left = 10
	normal.corner_radius_top_right = 10
	normal.corner_radius_bottom_left = 10
	normal.corner_radius_bottom_right = 10
	boton.add_theme_stylebox_override("normal", normal)

	var hover: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.12, 0.035, 0.16, 0.98)
	hover.border_color = Color(0.78, 0.27, 1.0, 1.0)
	hover.set_border_width_all(4)
	hover.shadow_color = Color(0.68, 0.18, 1.0, 0.50)
	hover.shadow_size = 9
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("focus", hover)
	boton.add_theme_stylebox_override("pressed", hover)
	boton.add_theme_font_size_override("font_size", 20)
	boton.add_theme_color_override("font_color", Color(1.0, 0.93, 0.76))
	boton.add_theme_color_override("font_hover_color", Color.WHITE)
	boton.add_theme_color_override("font_focus_color", Color.WHITE)

func crear_menu_centrado() -> void:
	# 90.10.78: se suma VERSUS LOCAL como modo oficial. El panel crece hacia
	# arriba para mantener cinco botones completos sin pisar la ayuda inferior.
	const PANEL_ANCHO := 560.0
	const PANEL_ALTO := 306.0
	const PANEL_X := (1280.0 - PANEL_ANCHO) * 0.5
	const PANEL_Y := 378.0

	var panel := Panel.new()
	panel.position = Vector2(PANEL_X, PANEL_Y)
	panel.size = Vector2(PANEL_ANCHO, PANEL_ALTO)
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.015, 0.012, 0.040, 0.82)
	ps.border_color = Color(0.72, 0.28, 1.0, 0.68)
	ps.set_border_width_all(2)
	ps.corner_radius_top_left = 16
	ps.corner_radius_top_right = 16
	ps.corner_radius_bottom_left = 16
	ps.corner_radius_bottom_right = 16
	ps.shadow_color = Color(0.0, 0.0, 0.0, 0.72)
	ps.shadow_size = 18
	panel.add_theme_stylebox_override("panel", ps)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	var titulo := Label.new()
	titulo.text = "MENÚ PRINCIPAL"
	titulo.position = Vector2(PANEL_X + 60.0, PANEL_Y + 11.0)
	titulo.size = Vector2(PANEL_ANCHO - 120.0, 24.0)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 18)
	titulo.add_theme_color_override("font_color", Color(0.91, 0.70, 1.0))
	add_child(titulo)

	var datos := [
		["MODO ARCADE", Callable(self, "_arcade")],
		["BATALLA RÁPIDA", Callable(self, "_rapida")],
		["VERSUS LOCAL", Callable(self, "_versus_local")],
		["CÓMO JUGAR", Callable(self, "_como_jugar")],
		["SALIR", Callable(self, "_salir")],
	]

	const BTN_X := 410.0
	const BTN_W := 460.0
	const BTN_H := 38.0
	const BTN_Y := 419.0
	const BTN_SEP := 47.0
	for i in range(datos.size()):
		var b := Button.new()
		b.text = datos[i][0]
		b.position = Vector2(BTN_X, BTN_Y + float(i) * BTN_SEP)
		b.size = Vector2(BTN_W, BTN_H)
		estilo_boton(b)
		b.pressed.connect(datos[i][1])
		b.mouse_entered.connect(_sonido_navegacion)
		b.focus_entered.connect(_sonido_navegacion)
		add_child(b)
		botones.append(b)
	botones[0].grab_focus()

	var ayuda := Label.new()
	ayuda.text = "↑ ↓  ELEGIR     •     A / ENTER  CONFIRMAR"
	ayuda.position = Vector2(PANEL_X + 45.0, 662.0)
	ayuda.size = Vector2(PANEL_ANCHO - 90.0, 17.0)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.add_theme_font_size_override("font_size", 11)
	ayuda.add_theme_color_override("font_color", Color(0.86, 0.83, 0.96))
	add_child(ayuda)

	await get_tree().process_frame
	_menu_listo = true

func crear_audio() -> void:
	musica = AudioStreamPlayer.new()
	musica.stream = load("res://assets/sonidos/menu/seleccion_modos.mp3")
	musica.volume_db = -9.0
	add_child(musica)
	musica.finished.connect(func(): musica.play())
	musica.play()


func _sonido_navegacion() -> void:
	if not _menu_listo:
		return
	var estado := get_node_or_null("/root/GameState")
	if estado and estado.has_method("reproducir_navegacion_ui"):
		estado.reproducir_navegacion_ui()

func _ir_selector(modo_nuevo: String) -> void:
	var estado = get_node("/root/GameState")
	estado.modo = modo_nuevo
	estado.reproducir_sfx_global("res://assets/sonidos/menu/start.mp3", -3.0)
	for b in botones:
		b.disabled = true
	await get_tree().create_timer(0.72).timeout
	estado.escena_destino_carga = "res://scenes/IntroBatalla.tscn"
	get_tree().change_scene_to_file("res://scenes/PantallaCarga.tscn")

func _arcade() -> void:
	await _ir_selector("arcade")

func _rapida() -> void:
	await _ir_selector("rapida")

func _versus_local() -> void:
	# El Versus local es un modo de repetición rápida: no reproduce la secuencia
	# narrativa de Varkhos cada vez que dos personas quieren jugar otra partida.
	var estado = get_node("/root/GameState")
	estado.modo = "versus_local"
	estado.reproducir_sfx_global("res://assets/sonidos/menu/start.mp3", -3.0)
	for b in botones:
		b.disabled = true
	await get_tree().create_timer(0.35).timeout
	get_tree().change_scene_to_file("res://scenes/SelectorPersonajes.tscn")

func _como_jugar() -> void:
	if not botones.is_empty():
		for b in botones:
			b.disabled = true
	var estado := get_node_or_null("/root/GameState")
	if estado and estado.has_method("reproducir_sfx_global"):
		estado.reproducir_sfx_global("res://assets/sonidos/menu/start.mp3", -5.0)
	await get_tree().create_timer(0.18).timeout
	get_tree().change_scene_to_file("res://scenes/ComoJugar.tscn")

func _salir() -> void:
	get_tree().quit()
