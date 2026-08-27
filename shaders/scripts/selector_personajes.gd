extends Control

# Selector nuevo: 9 personajes jugables + Varkhos visible y bloqueado.
# Varkhos NO forma parte de ROSTER, por lo que no tiene hitbox de selección
# ni puede confirmarse por teclado/mouse. Sigue reservado como jefe final.
const ROSTER: Array[String] = [
	"Kai", "Cibor-X", "Fang", "Kali", "Aethel",
	"Magnus", "Helena", "Jester", "Xenoid"
]

const COLORES := [
	Color(0.66, 0.22, 1.0),
	Color(0.05, 0.75, 1.0),
	Color(1.0, 0.34, 0.04),
	Color(0.42, 1.0, 0.06),
	Color(0.58, 0.88, 1.0),
	Color(0.10, 0.90, 0.88),
	Color(1.0, 0.18, 0.62),
	Color(0.85, 0.25, 0.85),
	Color(0.42, 1.0, 0.08)
]

# Bordes de las tarjetas sobre la ilustración final 1280x720.
# La décima tarjeta (1137..1265) es Varkhos y queda fuera de ROSTER.
const X_BORDES := [15.0, 144.0, 268.0, 382.0, 506.0, 625.0, 755.0, 877.0, 1015.0, 1137.0, 1265.0]
const TARJETA_Y := 108.0
const TARJETA_H := 577.0

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
	var i := clampi(idx, 0, ROSTER.size() - 1)
	var x0: float = X_BORDES[i]
	var x1: float = X_BORDES[i + 1]
	return Rect2(Vector2(x0, TARJETA_Y), Vector2(x1 - x0, TARJETA_H))

func crear_fondo() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.004, 0.006, 0.015)
	bg.position = Vector2.ZERO
	bg.size = Vector2(1280, 720)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var imagen := TextureRect.new()
	imagen.texture = load("res://assets/ui/selector_personajes_nuevo.png")
	imagen.position = Vector2.ZERO
	imagen.size = Vector2(1280, 720)
	imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen.stretch_mode = TextureRect.STRETCH_SCALE
	imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(imagen)

func crear_marco() -> void:
	marco = Panel.new()
	marco.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(marco)

	badge_j1 = Label.new()
	badge_j1.text = "J1"
	badge_j1.size = Vector2(38, 28)
	badge_j1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_j1.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge_j1.add_theme_font_size_override("font_size", 17)
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
	var c: Color = COLORES[indice]
	estilo.bg_color = Color(c.r, c.g, c.b, 0.035)
	estilo.border_color = c
	estilo.set_border_width_all(4)
	estilo.shadow_color = Color(c.r, c.g, c.b, 0.78)
	estilo.shadow_size = 12
	marco.add_theme_stylebox_override("panel", estilo)

	badge_j1.position = r.position + Vector2(6, 6)
	var badge_style: StyleBoxFlat = badge_j1.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	badge_style.bg_color = Color(c.r, c.g, c.b, 0.96)
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
