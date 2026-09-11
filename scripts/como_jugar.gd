extends Control

# CORE AWAKENED 90.10.34 — CÓMO JUGAR
# Guía ligera y no intrusiva: enseña el lenguaje del juego sin meter una
# escena de entrenamiento obligatoria en el flujo de Arcade/Batalla Rápida.

const TAMANO := Vector2(1280.0, 720.0)
const MENU := "res://scenes/MenuPrincipal.tscn"

const PAGINAS := [
	{
		"titulo": "MOVIMIENTO Y DEFENSA",
		"subtitulo": "DOMINÁ EL ESPACIO ANTES DE ATACAR",
		"items": [
			["MOVERSE", "STICK / D-PAD  ←  →", "J1  ← →   /   J2  A D", "Acercate, medí distancia y reposicionate frente al rival."],
			["DASH / BACK DASH", "DOBLE  ←  /  →", "DOBLE  ←  /  →", "Doble toque hacia el rival = entrada rápida. Alejándote = evasión."],
			["AIR DASH", "DOBLE  ←  /  → EN AIRE", "DOBLE  ←  /  → EN AIRE", "Durante salto o doble salto podés hacer un dash horizontal por permanencia en el aire."],
			["BLOQUEO", "B / LT / D-PAD ↓", "J1 ↓   /   J2 S", "Defendé el contacto. En la esquina, mantener bloqueo durante presión puede abrir la Guardia de Escape."],
		]
	},
	{
		"titulo": "COMBATE",
		"subtitulo": "CADA GOLPE CAMBIA DE POSE, ALCANCE Y RITMO",
		"items": [
			["PUÑO", "X", "J1 X   /   J2 F", "Ataque rápido. Las variantes del personaje rotan automáticamente."],
			["PATADA", "Y", "J1 C   /   J2 G", "Más alcance y presencia. Ideal para cortar el avance del rival."],
			["SALTO / DOBLE SALTO", "A / D-PAD ↑", "J1 ↑   /   J2 W", "Pulsá otra vez en el aire para ganar altura y cruzar sobre el rival."],
			["ENTRADA OFENSIVA", "DASH + X / Y", "DOBLE → + X / C", "Cancelá el dash con ataque para entrar rápido sin deslizarte de más."],
		]
	},
	{
		"titulo": "DEFENSA AVANZADA",
		"subtitulo": "LEÉ EL IMPACTO Y RECUPERÁ TU TURNO",
		"items": [
			["PERFECT BLOCK", "B / ↓ JUSTO ANTES", "↓ JUSTO ANTES", "Empezá a bloquear instantes antes del impacto para activar PERFECT."],
			["COUNTER", "X / Y TRAS PERFECT", "X / C TRAS PERFECT", "Después de un Perfect Block soltá la guardia y respondé rápido para contraatacar."],
			["QUICK RECOVERY", "A / ↑ TRAS RECIBIR", "↑ TRAS RECIBIR", "Durante la ventana de recuperación, pulsá salto para cortar antes un hitstun recuperable."],
			["GUARDIA DE ESCAPE", "MANTENER BLOQUEO EN ESQUINA", "MANTENER ↓ / S", "En Versus Local, si te acorralan durante hitstun, la siguiente presión normal puede entrar bloqueada y separar la pelea."],
		]
	},
	{
		"titulo": "COMBOS AVANZADOS",
		"subtitulo": "ENCADENÁ SIN REGALAR EL TURNO",
		"items": [
			["COMBO CANCEL", "X / Y TRAS IMPACTO", "X / C TRAS IMPACTO", "Un golpe normal limpio abre una ventana corta para encadenar. Máximo 3 golpes por cadena."],
			["LAUNCHER", "↑ + X", "↑ + X", "Desde suelo, arriba + puño arma un golpe lanzador y habilita persecución aérea."],
			["AIR COMBO", "X / Y EN PERSECUCIÓN", "X / C EN PERSECUCIÓN", "Después del Launcher podés continuar la secuencia en el aire hasta 3 impactos."],
			["PRESIÓN DE ESQUINA", "VARIÁ PUÑO / PATADA", "VARIÁ X / C", "La pared potencia cadenas rápidas, pero el defensor conserva una salida si anticipa la guardia."],
		]
	},
	{
		"titulo": "EL SISTEMA CORE",
		"subtitulo": "LA PELEA ESCALA HASTA EL GOLPE ABSOLUTO",
		"items": [
			["CARGAR CORE", "CONECTÁ GOLPES", "CONECTÁ GOLPES", "La barra CORE aumenta al golpear. Un golpe bloqueado carga mucho menos."],
			["CORE I", "RB / RT", "J1 Z   /   J2 H", "Primera carga completa: ejecuta el poder especial del personaje."],
			["CORE II", "RB / RT", "J1 Z   /   J2 H", "Segunda carga: especial + combo automático trifásico + remate."],
			["CORE III — ABSOLUTO", "RB / RT", "J1 Z   /   J2 H", "Tercera carga: Furia + combo final + Golpe Absoluto. Si conecta, termina la partida."],
		]
	}
]

var pagina := 0
var panel_contenido: Control
var titulo: Label
var subtitulo: Label
var indicador: Label
var ayuda: Label
var btn_anterior: Button
var btn_siguiente: Button

func _ready() -> void:
	_construir_fondo()
	_construir_ui()
	_renderizar()

func _unhandled_input(event: InputEvent) -> void:
	# 90.10.35: consumir el input ANTES de cualquier cambio de escena.
	# En 90.10.34, al volver al menú primero se destruía ComoJugar.tscn y
	# después se intentaba llamar get_viewport().set_input_as_handled().
	# Como el nodo ya no estaba en el árbol, get_viewport() devolvía null y
	# Godot detenía la ejecución.
	if event.is_action_pressed("ui_right"):
		get_viewport().set_input_as_handled()
		_siguiente()
	elif event.is_action_pressed("ui_left"):
		get_viewport().set_input_as_handled()
		_anterior()
	elif event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if pagina >= PAGINAS.size() - 1:
			_volver_menu()
		else:
			_siguiente()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if pagina > 0:
			_anterior()
		else:
			_volver_menu()

func _construir_fondo() -> void:
	var fondo := Sprite2D.new()
	fondo.texture = load("res://assets/ui/portada_inicio_nueva.png")
	fondo.centered = true
	fondo.position = TAMANO * 0.5
	if fondo.texture:
		var s := fondo.texture.get_size()
		fondo.scale = Vector2(TAMANO.x / s.x, TAMANO.y / s.y)
	fondo.z_index = -10
	add_child(fondo)

	var velo := ColorRect.new()
	velo.position = Vector2.ZERO
	velo.size = TAMANO
	velo.color = Color(0.006, 0.004, 0.020, 0.88)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	velo.z_index = -5
	add_child(velo)

	# Halo central tenue para conservar la identidad violeta/CORE.
	var halo := Panel.new()
	halo.position = Vector2(92, 92)
	halo.size = Vector2(1096, 545)
	halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hs := StyleBoxFlat.new()
	hs.bg_color = Color(0.025, 0.018, 0.070, 0.92)
	hs.border_color = Color(0.63, 0.23, 1.0, 0.78)
	hs.set_border_width_all(2)
	hs.corner_radius_top_left = 24
	hs.corner_radius_top_right = 24
	hs.corner_radius_bottom_left = 24
	hs.corner_radius_bottom_right = 24
	hs.shadow_color = Color(0.55, 0.12, 1.0, 0.34)
	hs.shadow_size = 28
	halo.add_theme_stylebox_override("panel", hs)
	add_child(halo)

func _construir_ui() -> void:
	var etiqueta := Label.new()
	etiqueta.text = "CORE AWAKENED"
	etiqueta.position = Vector2(120, 107)
	etiqueta.size = Vector2(1040, 28)
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", 15)
	etiqueta.add_theme_color_override("font_color", Color(0.76, 0.56, 1.0))
	add_child(etiqueta)

	titulo = Label.new()
	titulo.position = Vector2(120, 134)
	titulo.size = Vector2(1040, 48)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 31)
	titulo.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48))
	add_child(titulo)

	subtitulo = Label.new()
	subtitulo.position = Vector2(120, 180)
	subtitulo.size = Vector2(1040, 28)
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.add_theme_font_size_override("font_size", 13)
	subtitulo.add_theme_color_override("font_color", Color(0.86, 0.81, 0.95))
	add_child(subtitulo)

	panel_contenido = Control.new()
	panel_contenido.position = Vector2(130, 225)
	panel_contenido.size = Vector2(1020, 330)
	add_child(panel_contenido)

	indicador = Label.new()
	indicador.position = Vector2(520, 568)
	indicador.size = Vector2(240, 26)
	indicador.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	indicador.add_theme_font_size_override("font_size", 13)
	indicador.add_theme_color_override("font_color", Color(0.85, 0.72, 1.0))
	add_child(indicador)

	btn_anterior = _crear_boton_inferior("◀  ANTERIOR", Vector2(142, 579))
	btn_anterior.pressed.connect(_anterior)
	add_child(btn_anterior)

	btn_siguiente = _crear_boton_inferior("SIGUIENTE  ▶", Vector2(918, 579))
	btn_siguiente.pressed.connect(_siguiente_o_salir)
	add_child(btn_siguiente)

	ayuda = Label.new()
	ayuda.position = Vector2(250, 615)
	ayuda.size = Vector2(780, 24)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.add_theme_font_size_override("font_size", 12)
	ayuda.add_theme_color_override("font_color", Color(0.92, 0.88, 0.98))
	add_child(ayuda)

func _crear_boton_inferior(texto: String, pos: Vector2) -> Button:
	var b := Button.new()
	b.text = texto
	b.position = pos
	b.size = Vector2(220, 40)
	b.focus_mode = Control.FOCUS_NONE
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.04, 0.025, 0.10, 0.96)
	st.border_color = Color(0.73, 0.32, 1.0, 0.90)
	st.set_border_width_all(2)
	st.corner_radius_top_left = 10
	st.corner_radius_top_right = 10
	st.corner_radius_bottom_left = 10
	st.corner_radius_bottom_right = 10
	b.add_theme_stylebox_override("normal", st)
	var hov := st.duplicate() as StyleBoxFlat
	hov.bg_color = Color(0.13, 0.035, 0.18, 1.0)
	hov.border_color = Color(1.0, 0.65, 0.20, 1.0)
	b.add_theme_stylebox_override("hover", hov)
	b.add_theme_stylebox_override("pressed", hov)
	b.add_theme_font_size_override("font_size", 14)
	return b

func _renderizar() -> void:
	pagina = clampi(pagina, 0, PAGINAS.size() - 1)
	var data: Dictionary = PAGINAS[pagina]
	titulo.text = String(data["titulo"])
	subtitulo.text = String(data["subtitulo"])
	indicador.text = "PÁGINA %d / %d" % [pagina + 1, PAGINAS.size()]
	btn_anterior.visible = pagina > 0
	btn_siguiente.text = "VOLVER AL MENÚ  ▶" if pagina == PAGINAS.size() - 1 else "SIGUIENTE  ▶"
	ayuda.text = "← →  CAMBIAR PÁGINA     •     A / ENTER  %s     •     B / ESC  VOLVER" % ("MENÚ" if pagina == PAGINAS.size() - 1 else "SIGUIENTE")

	for child in panel_contenido.get_children():
		panel_contenido.remove_child(child)
		child.queue_free()

	var items: Array = data["items"]
	for i in range(items.size()):
		var col := i % 2
		var row := i / 2
		_crear_tarjeta(items[i], Vector2(float(col) * 510.0, float(row) * 164.0))

func _crear_tarjeta(item: Array, pos: Vector2) -> void:
	var panel := Panel.new()
	panel.position = pos
	panel.size = Vector2(492, 148)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.020, 0.016, 0.060, 0.97)
	st.border_color = Color(0.38, 0.20, 0.62, 0.92)
	st.set_border_width_all(2)
	st.corner_radius_top_left = 14
	st.corner_radius_top_right = 14
	st.corner_radius_bottom_left = 14
	st.corner_radius_bottom_right = 14
	panel.add_theme_stylebox_override("panel", st)
	panel_contenido.add_child(panel)

	var nombre := Label.new()
	nombre.text = String(item[0])
	nombre.position = Vector2(18, 12)
	nombre.size = Vector2(456, 27)
	nombre.add_theme_font_size_override("font_size", 18)
	nombre.add_theme_color_override("font_color", Color(1.0, 0.72, 0.24))
	panel.add_child(nombre)

	var xbox := Label.new()
	xbox.text = "XBOX     " + String(item[1])
	xbox.position = Vector2(18, 43)
	xbox.size = Vector2(456, 24)
	xbox.add_theme_font_size_override("font_size", 14)
	xbox.add_theme_color_override("font_color", Color(0.70, 0.92, 1.0))
	panel.add_child(xbox)

	var teclado := Label.new()
	teclado.text = "TECLADO  " + String(item[2])
	teclado.position = Vector2(18, 66)
	teclado.size = Vector2(456, 24)
	teclado.add_theme_font_size_override("font_size", 13)
	teclado.add_theme_color_override("font_color", Color(0.83, 0.73, 1.0))
	panel.add_child(teclado)

	var desc := Label.new()
	desc.text = String(item[3])
	desc.position = Vector2(18, 94)
	desc.size = Vector2(456, 43)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 12)
	desc.add_theme_color_override("font_color", Color(0.90, 0.88, 0.94))
	panel.add_child(desc)

func _siguiente() -> void:
	if pagina < PAGINAS.size() - 1:
		pagina += 1
		_renderizar()

func _anterior() -> void:
	if pagina > 0:
		pagina -= 1
		_renderizar()

func _siguiente_o_salir() -> void:
	if pagina >= PAGINAS.size() - 1:
		_volver_menu()
	else:
		_siguiente()

var volviendo_al_menu := false

func _volver_menu() -> void:
	if volviendo_al_menu:
		return
	volviendo_al_menu = true
	set_process_unhandled_input(false)
	get_tree().change_scene_to_file(MENU)
