extends Control

const TAMANO := Vector2(1280.0, 720.0)
const SND_NAVEGACION := preload("res://assets/sonidos/menu/navegacion.wav")
var musica: AudioStreamPlayer
var audio_navegacion: AudioStreamPlayer
var botones: Array[Button] = []
var _menu_listo := false

func _ready() -> void:
	crear_fondo_centrado()
	crear_menu_centrado()
	crear_audio()

func crear_fondo_centrado() -> void:
	# Sprite2D centrado matemáticamente en el viewport. Esto evita cualquier
	# desplazamiento lateral que pueda introducir TextureRect/stretches.
	var fondo := Sprite2D.new()
	fondo.texture = load("res://assets/ui/portada_inicio_nueva.png")
	fondo.centered = true
	fondo.position = TAMANO * 0.5
	if fondo.texture:
		var tex_size: Vector2 = fondo.texture.get_size()
		fondo.scale = Vector2(TAMANO.x / tex_size.x, TAMANO.y / tex_size.y)
	fondo.z_index = -10
	add_child(fondo)

	# Velo muy suave para que las opciones sean legibles sin apagar el arte.
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
	boton.add_theme_font_size_override("font_size", 22)
	boton.add_theme_color_override("font_color", Color(1.0, 0.93, 0.76))
	boton.add_theme_color_override("font_hover_color", Color.WHITE)
	boton.add_theme_color_override("font_focus_color", Color.WHITE)

func crear_menu_centrado() -> void:
	# Bloque completo centrado a X=640.
	const PANEL_ANCHO := 560.0
	const PANEL_ALTO := 205.0
	const PANEL_X := (1280.0 - PANEL_ANCHO) * 0.5
	const PANEL_Y := 492.0

	var panel := Panel.new()
	panel.position = Vector2(PANEL_X, PANEL_Y)
	panel.size = Vector2(PANEL_ANCHO, PANEL_ALTO)
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color(0.015, 0.012, 0.040, 0.80)
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
	titulo.text = "SELECCIONA MODO"
	titulo.position = Vector2(PANEL_X + 60.0, PANEL_Y + 12.0)
	titulo.size = Vector2(PANEL_ANCHO - 120.0, 24.0)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 18)
	titulo.add_theme_color_override("font_color", Color(0.91, 0.70, 1.0))
	add_child(titulo)

	var datos := [
		["MODO ARCADE", Callable(self, "_arcade")],
		["BATALLA RÁPIDA", Callable(self, "_rapida")],
		["SALIR", Callable(self, "_salir")],
	]

	const BTN_X := 410.0
	const BTN_W := 460.0
	const BTN_H := 38.0
	for i in range(datos.size()):
		var b := Button.new()
		b.text = datos[i][0]
		b.position = Vector2(BTN_X, 532.0 + float(i) * 46.0)
		b.size = Vector2(BTN_W, BTN_H)
		estilo_boton(b)
		b.pressed.connect(datos[i][1])
		b.mouse_entered.connect(_sonido_navegacion)
		b.focus_entered.connect(_sonido_navegacion)
		add_child(b)
		botones.append(b)
	botones[0].grab_focus()

	var ayuda := Label.new()
	ayuda.text = "↑ ↓  ELEGIR     •     ENTER / MANDO  CONFIRMAR"
	ayuda.position = Vector2(PANEL_X + 45.0, 674.0)
	ayuda.size = Vector2(PANEL_ANCHO - 90.0, 17.0)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.add_theme_font_size_override("font_size", 11)
	ayuda.add_theme_color_override("font_color", Color(0.86, 0.83, 0.96))
	add_child(ayuda)

	# El grab_focus() de arriba no debe sonar como si el jugador ya hubiera
	# navegado -- recién a partir del próximo frame cuenta como movimiento.
	await get_tree().process_frame
	_menu_listo = true

func crear_audio() -> void:
	musica = AudioStreamPlayer.new()
	musica.stream = load("res://assets/sonidos/menu/seleccion_modos.mp3")
	musica.volume_db = -9.0
	add_child(musica)
	musica.finished.connect(func(): musica.play())
	musica.play()

	audio_navegacion = AudioStreamPlayer.new()
	audio_navegacion.stream = SND_NAVEGACION
	audio_navegacion.volume_db = -4.0
	add_child(audio_navegacion)

# Un solo tick al moverse entre MODO ARCADE / BATALLA RÁPIDA / SALIR, ya
# sea con mouse (hover) o teclado/mando (cambio de foco).
func _sonido_navegacion() -> void:
	if audio_navegacion and _menu_listo:
		audio_navegacion.play()

func _ir_selector(modo_nuevo: String) -> void:
	var estado = get_node("/root/GameState")
	estado.modo = modo_nuevo
	estado.reproducir_sfx_global("res://assets/sonidos/menu/start.mp3", -3.0)
	for b in botones:
		b.disabled = true
	await get_tree().create_timer(0.72).timeout
	# FASE 94.2: IntroBatalla también carga varias imágenes grandes.
	estado.escena_destino_carga = "res://scenes/IntroBatalla.tscn"
	get_tree().change_scene_to_file("res://scenes/PantallaCarga.tscn")

func _arcade() -> void:
	await _ir_selector("arcade")

func _rapida() -> void:
	await _ir_selector("rapida")

func _salir() -> void:
	get_tree().quit()
