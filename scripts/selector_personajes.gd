extends Control

const ROSTER: Array[String] = ["Kai", "Cibor-X", "Fang", "Kali", "Aethel", "Magnus", "Helena", "Jester"]
const COLORES := [
	Color(0.66,0.22,1.0), Color(0.05,0.75,1.0), Color(1.0,0.34,0.04),
	Color(0.42,1.0,0.06), Color(0.58,0.88,1.0), Color(1.0,0.56,0.10), Color(1.0,0.18,0.62),
	Color(0.85,0.25,0.85)
]

const IMG_W := 1024.0
const IMG_H := 546.0
# FASE 90: se sumó Jester como 8vo casillero. La lámina ilustrada
# "selector_rostros.jpg" sigue teniendo arte terminado solo para los 7
# personajes originales, así que en vez de estirarla a 8 columnas parejas
# (lo que la deformaría), se la escala UN POCO menos que antes -- lo justo
# para liberar una 8va columna del mismo ancho a la derecha -- y esa
# columna usa una tarjeta propia (jester_card.jpg, todavía placeholder,
# armada con su pose de batalla hasta que haya arte final tipo el resto).
const CASILLAS := 8
const DISPLAY_W := 1280.0
const CELDA_W := DISPLAY_W / CASILLAS
const ESCALA_LAMINA := (CELDA_W * 7.0) / IMG_W
const DISPLAY_H := IMG_H * ESCALA_LAMINA
const OFFSET := Vector2(0.0, (720.0 - DISPLAY_H) / 2.0)
const SCALE_X := ESCALA_LAMINA
const SCALE_Y := ESCALA_LAMINA
const TARJETAS_FUENTE := [
	Rect2(0, 0, 146, 546),
	Rect2(146, 0, 146, 546),
	Rect2(292, 0, 146, 546),
	Rect2(438, 0, 146, 546),
	Rect2(584, 0, 146, 546),
	Rect2(730, 0, 146, 546),
	Rect2(876, 0, 148, 546)
]
# Jester no vive en la lámina compartida: es una tarjeta aparte, del mismo
# ancho/alto final que las otras 7 ya escaladas, pegada justo a la derecha.
const RECT_JESTER := Rect2(0.0, 0.0, CELDA_W, DISPLAY_H)

var indice := 0
var marco: Panel
var badge_j1: Label
var musica: AudioStreamPlayer
var confirmando := false

func _ready() -> void:
	crear_fondo()
	crear_marco()
	crear_interaccion()
	crear_audio()
	actualizar_seleccion()

func _rect_pantalla(idx: int) -> Rect2:
	if idx >= TARJETAS_FUENTE.size():
		# Jester (8vo casillero): no está en la lámina, va pegada a la
		# derecha del último casillero de la lámina.
		return Rect2(OFFSET + Vector2(CELDA_W * 7.0, 0.0), RECT_JESTER.size)
	var r: Rect2 = TARJETAS_FUENTE[idx]
	return Rect2(
		OFFSET + Vector2(r.position.x * SCALE_X, r.position.y * SCALE_Y),
		Vector2(r.size.x * SCALE_X, r.size.y * SCALE_Y)
	)

func crear_fondo() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.004, 0.006, 0.015)
	bg.position = Vector2.ZERO
	bg.size = Vector2(1280, 720)
	add_child(bg)

	var imagen := TextureRect.new()
	imagen.texture = load("res://assets/ui/selector_rostros.jpg")
	imagen.position = OFFSET
	imagen.size = Vector2(DISPLAY_W, DISPLAY_H)
	imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen.stretch_mode = TextureRect.STRETCH_SCALE
	imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(imagen)

	# Tarjeta propia de Jester, pegada a la derecha de la lámina (ver nota
	# de FASE 90 arriba).
	var r_jester := _rect_pantalla(ROSTER.size() - 1)
	var jester_img := TextureRect.new()
	jester_img.texture = load("res://assets/ui/jester_card.jpg")
	jester_img.position = r_jester.position
	jester_img.size = r_jester.size
	jester_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	jester_img.stretch_mode = TextureRect.STRETCH_SCALE
	jester_img.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(jester_img)

	var barra_sup := ColorRect.new()
	barra_sup.position = Vector2(0, 0)
	barra_sup.size = Vector2(1280, 18)
	barra_sup.color = Color(0,0,0,0.35)
	barra_sup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(barra_sup)

	var barra_inf := ColorRect.new()
	barra_inf.position = Vector2(0, 701)
	barra_inf.size = Vector2(1280, 19)
	barra_inf.color = Color(0,0,0,0.35)
	barra_inf.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(barra_inf)

	var estado = get_node("/root/GameState")
	var modo := Label.new()
	modo.text = "MODO ARCADE" if estado.modo == "arcade" else "BATALLA RÁPIDA"
	modo.position = Vector2(20, 22)
	modo.size = Vector2(220, 24)
	modo.add_theme_font_size_override("font_size", 20)
	modo.add_theme_color_override("font_color", Color(0.95, 0.82, 1.0))
	add_child(modo)

	var subt := Label.new()
	subt.text = "SELECCIONA TU GUERRERO"
	subt.position = Vector2(430, 22)
	subt.size = Vector2(420, 24)
	subt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subt.add_theme_font_size_override("font_size", 22)
	subt.add_theme_color_override("font_color", Color(1.0, 0.90, 0.68))
	add_child(subt)

	var ayuda := Label.new()
	ayuda.text = "← → ELEGIR   |   ENTER CONFIRMAR   |   ESC ATRÁS"
	ayuda.position = Vector2(700, 682)
	ayuda.size = Vector2(560, 18)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ayuda.add_theme_font_size_override("font_size", 12)
	ayuda.add_theme_color_override("font_color", Color(1.0, 0.86, 0.56))
	add_child(ayuda)

func crear_marco() -> void:
	marco = Panel.new()
	marco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(marco)

	badge_j1 = Label.new()
	badge_j1.text = "J1"
	badge_j1.size = Vector2(42, 30)
	badge_j1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_j1.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge_j1.add_theme_font_size_override("font_size", 18)
	badge_j1.add_theme_color_override("font_color", Color.WHITE)
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color(0.48, 0.08, 0.92, 0.96)
	badge_style.corner_radius_top_left = 5
	badge_style.corner_radius_top_right = 5
	badge_style.corner_radius_bottom_left = 5
	badge_style.corner_radius_bottom_right = 5
	badge_j1.add_theme_stylebox_override("normal", badge_style)
	badge_j1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(badge_j1)

func crear_interaccion() -> void:
	for i in range(ROSTER.size()):
		var r := _rect_pantalla(i)
		var zona := Button.new()
		zona.flat = true
		zona.text = ""
		zona.position = r.position
		zona.size = r.size
		zona.modulate.a = 0.01
		zona.mouse_entered.connect(_seleccionar_indice.bind(i))
		zona.pressed.connect(_click_indice.bind(i))
		add_child(zona)

func _seleccionar_indice(idx: int) -> void:
	if confirmando:
		return
	indice = idx
	actualizar_seleccion()

func _click_indice(idx: int) -> void:
	if confirmando:
		return
	if indice == idx:
		confirmar()
	else:
		indice = idx
		actualizar_seleccion()

func crear_audio() -> void:
	musica = AudioStreamPlayer.new()
	musica.stream = load("res://assets/sonidos/menu/selector_loop.mp3")
	musica.volume_db = -10.0
	add_child(musica)
	musica.finished.connect(func(): musica.play())
	musica.play()

func actualizar_seleccion() -> void:
	indice = wrapi(indice, 0, ROSTER.size())
	var r := _rect_pantalla(indice)
	marco.position = r.position
	marco.size = r.size

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(COLORES[indice].r, COLORES[indice].g, COLORES[indice].b, 0.03)
	estilo.border_color = COLORES[indice]
	estilo.set_border_width_all(4)
	estilo.shadow_color = Color(COLORES[indice].r, COLORES[indice].g, COLORES[indice].b, 0.72)
	estilo.shadow_size = 12
	marco.add_theme_stylebox_override("panel", estilo)

	badge_j1.position = r.position + Vector2(6, 6)
	var badge_style: StyleBoxFlat = badge_j1.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	badge_style.bg_color = Color(COLORES[indice].r, COLORES[indice].g, COLORES[indice].b, 0.96)
	badge_j1.add_theme_stylebox_override("normal", badge_style)

func _unhandled_input(event: InputEvent) -> void:
	if confirmando:
		return
	if event.is_action_pressed("ui_left"):
		indice -= 1
		actualizar_seleccion()
	elif event.is_action_pressed("ui_right"):
		indice += 1
		actualizar_seleccion()
	elif event.is_action_pressed("ui_accept"):
		confirmar()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")

func confirmar() -> void:
	if confirmando:
		return
	confirmando = true
	var estado = get_node("/root/GameState")
	if estado.modo == "arcade":
		estado.iniciar_arcade(ROSTER[indice])
	else:
		estado.iniciar_batalla_rapida(ROSTER[indice])
	await get_tree().create_timer(0.18).timeout
	get_tree().change_scene_to_file("res://scenes/PresentacionVS.tscn")
