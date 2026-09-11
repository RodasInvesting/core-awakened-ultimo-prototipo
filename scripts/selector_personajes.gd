extends Control

# CORE AWAKENED 91.02.38 — PASS 10.3 QA / VARKHOS DESBLOQUEADO TEMPORALMENTE.
# Basado en el selector definitivo de 13 personajes.
# Único cambio funcional de este PASS: permitir seleccionar Varkhos para QA final.
# No altera roster, zonas, VS local, Arcade, escenarios ni gameplay.
const ROSTER: Array[String] = [
	"Kai", "Cibor-X", "Fang", "Kali", "Aethel",
	"Magnus", "Helena", "Jester", "Xenoid", "Dax", "Krovan", "Nekhar", "Varkhos"
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
	Color(0.42, 1.0, 0.08),
	Color(0.96, 0.18, 0.08),
	Color(1.0, 0.62, 0.12),
	Color(1.0, 0.78, 0.15),
	Color(0.95, 0.10, 0.16),
]

# Bordes medidos sobre el roster definitivo 1672x941 y convertidos a 1280x720.
# 14 límites = 13 paneles: Kai ... Krovan, Nekhar, Varkhos.
const X_BORDES := [9.95, 120.96, 229.67, 322.30, 410.34, 499.90, 589.47, 680.57, 769.38, 855.89, 946.22, 1037.32, 1154.45, 1268.52]
const TARJETA_Y := 64.0
const TARJETA_H := 574.0

var indice := 0
var marco: Panel
var badge_j1: Label
var badge_j2: Label
var musica: AudioStreamPlayer
var confirmando := false
var fase_versus: int = 1
var indice_j1: int = -1
var estado_versus_label: Label

func _ready() -> void:
	crear_fondo()
	crear_marco()
	crear_interaccion()
	crear_audio()
	_crear_estado_versus()
	if _es_online():
		var red := _network()
		if red != null and not red.selecciones_actualizadas.is_connected(_al_selecciones_online):
			red.selecciones_actualizadas.connect(_al_selecciones_online)
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

	badge_j1 = _crear_badge("J1", Color(0.48, 0.08, 0.92, 0.96))
	add_child(badge_j1)
	badge_j2 = _crear_badge("J2", Color(0.10, 0.54, 1.0, 0.96))
	badge_j2.visible = false
	add_child(badge_j2)

func _crear_badge(texto: String, color: Color) -> Label:
	var badge := Label.new()
	badge.text = texto
	badge.size = Vector2(38, 28)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 17)
	badge.add_theme_color_override("font_color", Color.WHITE)
	var st := StyleBoxFlat.new()
	st.bg_color = color
	st.corner_radius_top_left = 5
	st.corner_radius_top_right = 5
	st.corner_radius_bottom_left = 5
	st.corner_radius_bottom_right = 5
	badge.add_theme_stylebox_override("normal", st)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return badge

func _es_versus_local() -> bool:
	var estado := get_node_or_null("/root/GameState")
	return estado != null and str(estado.modo) == "versus_local"

func _es_online() -> bool:
	var estado := get_node_or_null("/root/GameState")
	return estado != null and str(estado.modo) == "online"

func _network() -> Node:
	return get_node_or_null("/root/NetworkManager")

func _crear_estado_versus() -> void:
	if not _es_versus_local() and not _es_online():
		return
	estado_versus_label = Label.new()
	estado_versus_label.position = Vector2(330, 16)
	estado_versus_label.size = Vector2(620, 54)
	estado_versus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	estado_versus_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	estado_versus_label.add_theme_font_size_override("font_size", 24)
	estado_versus_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.68))
	estado_versus_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	estado_versus_label.add_theme_constant_override("outline_size", 6)
	add_child(estado_versus_label)
	_actualizar_estado_versus()

func _actualizar_estado_versus() -> void:
	if estado_versus_label == null:
		return
	if _es_online():
		var red := _network()
		if red == null:
			estado_versus_label.text = "ONLINE — RED NO DISPONIBLE"
			return
		var rol_txt := "HOST / JUGADOR 1" if red.es_host() else "CLIENTE / JUGADOR 2"
		if confirmando:
			# 91.02.63 — Godot 4.7.1 no puede inferir String desde propiedades
			# dinámicas de un Node en una expresión ternaria.
			var propio: String = str(red.personaje_host) if red.es_host() else str(red.personaje_cliente)
			var otro: String = str(red.personaje_cliente) if red.es_host() else str(red.personaje_host)
			if otro.is_empty():
				estado_versus_label.text = "%s: %s  •  ESPERANDO AL RIVAL..." % [rol_txt, propio.to_upper()]
			else:
				estado_versus_label.text = "HOST: %s  •  CLIENTE: %s  •  SINCRONIZANDO..." % [red.personaje_host.to_upper(), red.personaje_cliente.to_upper()]
		else:
			estado_versus_label.text = "ONLINE  •  %s: ELIGE TU GUERRERO" % rol_txt
		return
	if fase_versus == 1:
		estado_versus_label.text = "VERSUS LOCAL  •  JUGADOR 1: ELIGE TU GUERRERO"
	else:
		var nombre_j1 := ROSTER[indice_j1] if indice_j1 >= 0 else "J1"
		estado_versus_label.text = "J1: %s  •  JUGADOR 2: ELIGE TU GUERRERO" % nombre_j1.to_upper()

func _al_selecciones_online(host_nombre: String, cliente_nombre: String) -> void:
	if not _es_online():
		return
	_actualizar_estado_versus()

func _volver_a_j1_versus() -> void:
	fase_versus = 1
	confirmando = false
	if indice_j1 >= 0:
		indice = indice_j1
	indice_j1 = -1
	if badge_j2:
		badge_j2.visible = false
	_actualizar_estado_versus()
	actualizar_seleccion()

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

func _sonido_navegacion() -> void:
	var estado := get_node_or_null("/root/GameState")
	if estado and estado.has_method("reproducir_navegacion_ui"):
		estado.reproducir_navegacion_ui()

func _seleccionar_indice(idx: int) -> void:
	if confirmando:
		return
	if idx != indice:
		indice = idx
		_sonido_navegacion()
		actualizar_seleccion()

func _click_indice(idx: int) -> void:
	if confirmando:
		return
	if indice == idx:
		confirmar()
	else:
		indice = idx
		_sonido_navegacion()
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

	if _es_online():
		var red := _network()
		badge_j1.text = "J1" if red != null and red.es_host() else "J2"
		badge_j1.position = r.position + Vector2(6, 6)
		_aplicar_color_badge(badge_j1, c)
		if badge_j2:
			badge_j2.visible = false
	elif _es_versus_local() and fase_versus == 2:
		var r_j1 := _rect_pantalla(indice_j1)
		badge_j1.position = r_j1.position + Vector2(6, 6)
		_aplicar_color_badge(badge_j1, COLORES[indice_j1])
		badge_j2.visible = true
		badge_j2.position = r.position + Vector2(6, 40)
		_aplicar_color_badge(badge_j2, c)
	else:
		badge_j1.position = r.position + Vector2(6, 6)
		_aplicar_color_badge(badge_j1, c)
		if badge_j2:
			badge_j2.visible = false

	_actualizar_estado_versus()

func _aplicar_color_badge(badge: Label, c: Color) -> void:
	var actual := badge.get_theme_stylebox("normal")
	if actual == null:
		return
	var st: StyleBoxFlat = actual.duplicate() as StyleBoxFlat
	st.bg_color = Color(c.r, c.g, c.b, 0.96)
	badge.add_theme_stylebox_override("normal", st)

func _unhandled_input(event: InputEvent) -> void:
	if confirmando:
		return

	if _es_versus_local() and fase_versus == 2 and event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_A:
				indice -= 1
				_sonido_navegacion()
				actualizar_seleccion()
				return
			KEY_D:
				indice += 1
				_sonido_navegacion()
				actualizar_seleccion()
				return
			KEY_F:
				confirmar()
				return
			KEY_ESCAPE:
				_volver_a_j1_versus()
				return

	if event.is_action_pressed("ui_left"):
		indice -= 1
		_sonido_navegacion()
		actualizar_seleccion()
	elif event.is_action_pressed("ui_right"):
		indice += 1
		_sonido_navegacion()
		actualizar_seleccion()
	elif event.is_action_pressed("ui_accept"):
		confirmar()
	elif event.is_action_pressed("ui_cancel"):
		if _es_online():
			var red := _network()
			if red != null:
				red.cerrar_conexion()
			get_node("/root/GameState").volver_al_menu()
			get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
		elif _es_versus_local() and fase_versus == 2:
			_volver_a_j1_versus()
		else:
			get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")

func confirmar() -> void:
	if confirmando:
		return
	var estado = get_node("/root/GameState")
	var elegido: String = ROSTER[indice]
	# 91.02.38 — QA FINAL: Varkhos queda seleccionable temporalmente.
	# En Arcade sigue entrando por la ruta segura de Batalla Rápida definida abajo.

	if _es_online():
		var red := _network()
		if red == null or not red.hay_rival_conectado():
			return
		confirmando = true
		estado.modo = "online"
		red.confirmar_personaje_local(elegido)
		_actualizar_estado_versus()
		return

	if _es_versus_local():
		if fase_versus == 1:
			indice_j1 = indice
			fase_versus = 2
			indice = wrapi(indice + 1, 0, ROSTER.size())
			_actualizar_estado_versus()
			actualizar_seleccion()
			return

		confirmando = true
		var elegido_j1: String = ROSTER[indice_j1]
		estado.iniciar_versus_local(elegido_j1, elegido)
		await get_tree().create_timer(0.18).timeout
		get_tree().change_scene_to_file("res://scenes/SelectorEscenarios.tscn")
		return

	confirmando = true
	if estado.modo == "arcade" and elegido != "Varkhos":
		estado.iniciar_arcade(elegido)
		await get_tree().create_timer(0.18).timeout
		get_tree().change_scene_to_file("res://scenes/PresentacionVS.tscn")
	else:
		estado.iniciar_batalla_rapida(elegido)
		await get_tree().create_timer(0.18).timeout
		get_tree().change_scene_to_file("res://scenes/SelectorEscenarios.tscn")
