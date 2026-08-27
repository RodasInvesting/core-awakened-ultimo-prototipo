extends Node

# CORE AWAKENED 90.10.32 — PAUSE SYSTEM
# Autoload global. Sólo puede abrirse dentro de Main.tscn (la pelea).
# Funciona aun con SceneTree.paused gracias a PROCESS_MODE_ALWAYS.

const ESCENA_COMBATE := "res://scenes/Main.tscn"
const ESCENA_MENU := "res://scenes/MenuPrincipal.tscn"
const TAMANO := Vector2(1280.0, 720.0)

var pausa_activa := false
var mostrando_opciones := false
var transicionando := false

var capa: CanvasLayer
var fondo: ColorRect
var panel_principal: Panel
var panel_opciones: Panel
var botones_principales: Array[Button] = []
var slider_master: HSlider
var slider_musica: HSlider
var slider_efectos: HSlider
var slider_voces: HSlider
var label_master_valor: Label
var label_musica_valor: Label
var label_efectos_valor: Label
var label_voces_valor: Label
var selector_resolucion: OptionButton
var label_monitor_nativo: Label
var resoluciones_mostradas: Array[Vector2i] = []
var toggle_fullscreen: CheckButton
var toggle_vsync: CheckButton
var toggle_shake: CheckButton
var controles_opciones: Array[Control] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir_interfaz()

func _input(event: InputEvent) -> void:
	if transicionando:
		return

	if _es_evento_pausa(event):
		if pausa_activa or _es_escena_combate():
			get_viewport().set_input_as_handled()
			if pausa_activa:
				_continuar()
			else:
				_pausar()
		return

	# B / Circle dentro del menú de pausa = volver. En la pelea normal B
	# conserva su función de bloqueo porque este bloque sólo corre pausado.
	if pausa_activa and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if mostrando_opciones:
			_mostrar_menu_principal()
		else:
			_continuar()

func _es_evento_pausa(event: InputEvent) -> bool:
	if event is InputEventKey:
		var tecla := event as InputEventKey
		return tecla.pressed and not tecla.echo and tecla.keycode == KEY_ESCAPE
	if event is InputEventJoypadButton:
		var boton := event as InputEventJoypadButton
		return boton.pressed and boton.button_index == JOY_BUTTON_START
	return false

func _es_escena_combate() -> bool:
	var actual := get_tree().current_scene
	return actual != null and actual.scene_file_path == ESCENA_COMBATE

func _pausar() -> void:
	if pausa_activa or not _es_escena_combate():
		return
	pausa_activa = true
	mostrando_opciones = false
	panel_principal.visible = true
	panel_opciones.visible = false
	fondo.visible = true
	capa.visible = true
	get_tree().paused = true
	await get_tree().process_frame
	if not botones_principales.is_empty():
		botones_principales[0].grab_focus()

func _continuar() -> void:
	if not pausa_activa:
		return
	pausa_activa = false
	mostrando_opciones = false
	capa.visible = false
	get_tree().paused = false

func _reiniciar_pelea() -> void:
	if transicionando:
		return
	transicionando = true
	var estado := get_node_or_null("/root/GameState")
	if estado and estado.has_method("reiniciar_combate_actual"):
		estado.reiniciar_combate_actual()
	pausa_activa = false
	capa.visible = false
	get_tree().paused = false
	await get_tree().process_frame
	get_tree().reload_current_scene()
	transicionando = false

func _volver_menu() -> void:
	if transicionando:
		return
	transicionando = true
	var estado := get_node_or_null("/root/GameState")
	if estado and estado.has_method("volver_al_menu"):
		estado.volver_al_menu()
	pausa_activa = false
	capa.visible = false
	get_tree().paused = false
	await get_tree().process_frame
	get_tree().change_scene_to_file(ESCENA_MENU)
	transicionando = false

func _mostrar_opciones() -> void:
	mostrando_opciones = true
	panel_principal.visible = false
	panel_opciones.visible = true
	_actualizar_estado_opciones()
	await get_tree().process_frame
	if slider_master:
		slider_master.grab_focus()

func _mostrar_menu_principal() -> void:
	mostrando_opciones = false
	panel_opciones.visible = false
	panel_principal.visible = true
	await get_tree().process_frame
	if not botones_principales.is_empty():
		botones_principales[0].grab_focus()

func _construir_interfaz() -> void:
	capa = CanvasLayer.new()
	capa.name = "PauseLayer"
	capa.layer = 500
	capa.process_mode = Node.PROCESS_MODE_ALWAYS
	capa.visible = false
	add_child(capa)

	fondo = ColorRect.new()
	fondo.position = Vector2.ZERO
	fondo.size = TAMANO
	fondo.color = Color(0.008, 0.006, 0.025, 0.76)
	fondo.mouse_filter = Control.MOUSE_FILTER_STOP
	fondo.process_mode = Node.PROCESS_MODE_ALWAYS
	capa.add_child(fondo)

	panel_principal = _crear_panel(Vector2(355, 105), Vector2(570, 510))
	capa.add_child(panel_principal)
	_construir_menu_principal()

	panel_opciones = _crear_panel(Vector2(300, 38), Vector2(680, 644))
	panel_opciones.visible = false
	capa.add_child(panel_opciones)
	_construir_menu_opciones()

func _crear_panel(pos: Vector2, tam: Vector2) -> Panel:
	var panel := Panel.new()
	panel.position = pos
	panel.size = tam
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = Color(0.018, 0.014, 0.052, 0.97)
	estilo.border_color = Color(0.73, 0.29, 1.0, 0.95)
	estilo.set_border_width_all(3)
	estilo.corner_radius_top_left = 20
	estilo.corner_radius_top_right = 20
	estilo.corner_radius_bottom_left = 20
	estilo.corner_radius_bottom_right = 20
	estilo.shadow_color = Color(0.0, 0.0, 0.0, 0.72)
	estilo.shadow_size = 24
	panel.add_theme_stylebox_override("panel", estilo)
	return panel

func _titulo(panel: Control, texto: String, y: float) -> void:
	var l := Label.new()
	l.text = texto
	l.position = Vector2(30, y)
	l.size = Vector2(510, 48)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 31)
	l.add_theme_color_override("font_color", Color(1.0, 0.86, 0.46))
	panel.add_child(l)

func _subtitulo(panel: Control, texto: String, y: float) -> void:
	var l := Label.new()
	l.text = texto
	l.position = Vector2(40, y)
	l.size = Vector2(490, 26)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 13)
	l.add_theme_color_override("font_color", Color(0.80, 0.72, 0.93))
	panel.add_child(l)

func _construir_menu_principal() -> void:
	_titulo(panel_principal, "PAUSA", 22)
	_subtitulo(panel_principal, "CORE AWAKENED", 69)

	var continuar := _crear_boton("CONTINUAR", Vector2(85, 125))
	continuar.pressed.connect(_continuar)
	panel_principal.add_child(continuar)
	botones_principales.append(continuar)

	var opciones := _crear_boton("OPCIONES", Vector2(85, 193))
	opciones.pressed.connect(_mostrar_opciones)
	panel_principal.add_child(opciones)
	botones_principales.append(opciones)

	var reiniciar := _crear_boton("REINICIAR PELEA", Vector2(85, 261))
	reiniciar.pressed.connect(_reiniciar_pelea)
	panel_principal.add_child(reiniciar)
	botones_principales.append(reiniciar)

	var menu := _crear_boton("VOLVER AL MENÚ", Vector2(85, 329))
	menu.pressed.connect(_volver_menu)
	panel_principal.add_child(menu)
	botones_principales.append(menu)

	var ayuda := Label.new()
	ayuda.text = "A  CONFIRMAR     •     B  VOLVER     •     MENU / ESC  CONTINUAR"
	ayuda.position = Vector2(30, 445)
	ayuda.size = Vector2(510, 28)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.add_theme_font_size_override("font_size", 12)
	ayuda.add_theme_color_override("font_color", Color(0.90, 0.86, 0.98))
	panel_principal.add_child(ayuda)

func _crear_boton(texto: String, pos: Vector2) -> Button:
	var b := Button.new()
	b.text = texto
	b.position = pos
	b.size = Vector2(400, 52)
	b.process_mode = Node.PROCESS_MODE_ALWAYS
	b.focus_mode = Control.FOCUS_ALL
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", Color(0.96, 0.91, 1.0))
	b.add_theme_color_override("font_focus_color", Color.WHITE)

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.035, 0.025, 0.085, 0.96)
	normal.border_color = Color(0.50, 0.22, 0.78, 0.84)
	normal.set_border_width_all(2)
	normal.corner_radius_top_left = 11
	normal.corner_radius_top_right = 11
	normal.corner_radius_bottom_left = 11
	normal.corner_radius_bottom_right = 11
	b.add_theme_stylebox_override("normal", normal)

	var focus: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	focus.bg_color = Color(0.15, 0.045, 0.20, 0.99)
	focus.border_color = Color(1.0, 0.58, 0.10, 1.0)
	focus.set_border_width_all(4)
	focus.shadow_color = Color(0.70, 0.18, 1.0, 0.52)
	focus.shadow_size = 9
	b.add_theme_stylebox_override("focus", focus)
	b.add_theme_stylebox_override("hover", focus)
	b.add_theme_stylebox_override("pressed", focus)
	b.focus_entered.connect(_sonido_navegacion)
	b.mouse_entered.connect(_sonido_navegacion)
	return b

func _sonido_navegacion() -> void:
	var estado := get_node_or_null("/root/GameState")
	if estado and estado.has_method("reproducir_navegacion_ui"):
		estado.reproducir_navegacion_ui()

func _settings() -> Node:
	return get_node_or_null("/root/SettingsManager")

func _crear_slider_opcion(panel: Control, texto: String, y: float) -> Array:
	var titulo := Label.new()
	titulo.text = texto
	titulo.position = Vector2(55, y)
	titulo.size = Vector2(205, 28)
	titulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 15)
	titulo.add_theme_color_override("font_color", Color(0.96, 0.89, 1.0))
	panel.add_child(titulo)

	var slider := HSlider.new()
	slider.position = Vector2(265, y - 1)
	slider.size = Vector2(285, 32)
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 5.0
	slider.process_mode = Node.PROCESS_MODE_ALWAYS
	slider.focus_mode = Control.FOCUS_ALL
	slider.focus_entered.connect(_sonido_navegacion)
	slider.mouse_entered.connect(_sonido_navegacion)
	panel.add_child(slider)
	controles_opciones.append(slider)

	var valor := Label.new()
	valor.position = Vector2(565, y)
	valor.size = Vector2(65, 28)
	valor.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	valor.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	valor.add_theme_font_size_override("font_size", 15)
	valor.add_theme_color_override("font_color", Color(1.0, 0.78, 0.35))
	panel.add_child(valor)
	return [slider, valor]

func _crear_toggle_opcion(panel: Control, texto: String, y: float) -> CheckButton:
	var t := CheckButton.new()
	t.text = texto
	t.position = Vector2(55, y)
	t.size = Vector2(575, 36)
	t.process_mode = Node.PROCESS_MODE_ALWAYS
	t.focus_mode = Control.FOCUS_ALL
	t.focus_entered.connect(_sonido_navegacion)
	t.mouse_entered.connect(_sonido_navegacion)
	t.add_theme_font_size_override("font_size", 16)
	t.add_theme_color_override("font_color", Color(0.96, 0.89, 1.0))
	panel.add_child(t)
	controles_opciones.append(t)
	return t

func _construir_menu_opciones() -> void:
	_titulo(panel_opciones, "OPCIONES", 14)
	_subtitulo(panel_opciones, "Los cambios se guardan automáticamente", 57)

	var fila_master := _crear_slider_opcion(panel_opciones, "VOLUMEN GENERAL", 100)
	slider_master = fila_master[0] as HSlider
	label_master_valor = fila_master[1] as Label
	slider_master.value_changed.connect(_cambiar_master)

	var fila_musica := _crear_slider_opcion(panel_opciones, "MÚSICA", 146)
	slider_musica = fila_musica[0] as HSlider
	label_musica_valor = fila_musica[1] as Label
	slider_musica.value_changed.connect(_cambiar_musica)

	var fila_efectos := _crear_slider_opcion(panel_opciones, "EFECTOS", 192)
	slider_efectos = fila_efectos[0] as HSlider
	label_efectos_valor = fila_efectos[1] as Label
	slider_efectos.value_changed.connect(_cambiar_efectos)

	var fila_voces := _crear_slider_opcion(panel_opciones, "VOCES", 238)
	slider_voces = fila_voces[0] as HSlider
	label_voces_valor = fila_voces[1] as Label
	slider_voces.value_changed.connect(_cambiar_voces)

	# 90.10.37 — resolución de ventana. Pantalla completa NO fuerza estas
	# medidas: usa la resolución nativa del monitor y escala el lienzo 1280×720.
	var lbl_res := Label.new()
	lbl_res.text = "RESOLUCIÓN EN VENTANA"
	lbl_res.position = Vector2(55, 282)
	lbl_res.size = Vector2(205, 32)
	lbl_res.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_res.add_theme_font_size_override("font_size", 15)
	lbl_res.add_theme_color_override("font_color", Color(0.96, 0.89, 1.0))
	panel_opciones.add_child(lbl_res)

	selector_resolucion = OptionButton.new()
	selector_resolucion.position = Vector2(265, 282)
	selector_resolucion.size = Vector2(365, 34)
	selector_resolucion.process_mode = Node.PROCESS_MODE_ALWAYS
	selector_resolucion.focus_mode = Control.FOCUS_ALL
	selector_resolucion.focus_entered.connect(_sonido_navegacion)
	selector_resolucion.mouse_entered.connect(_sonido_navegacion)
	selector_resolucion.add_theme_font_size_override("font_size", 15)
	selector_resolucion.item_selected.connect(_cambiar_resolucion)
	panel_opciones.add_child(selector_resolucion)
	controles_opciones.append(selector_resolucion)

	toggle_fullscreen = _crear_toggle_opcion(panel_opciones, "PANTALLA COMPLETA (NATIVA)", 326)
	toggle_fullscreen.toggled.connect(_cambiar_fullscreen)

	toggle_vsync = _crear_toggle_opcion(panel_opciones, "VSYNC", 368)
	toggle_vsync.toggled.connect(_cambiar_vsync)

	toggle_shake = _crear_toggle_opcion(panel_opciones, "SACUDIDA DE CÁMARA", 410)
	toggle_shake.toggled.connect(_cambiar_shake)

	var restaurar := _crear_boton("RESTAURAR PREDETERMINADOS", Vector2(140, 458))
	restaurar.size = Vector2(400, 44)
	restaurar.pressed.connect(_restaurar_opciones)
	panel_opciones.add_child(restaurar)
	controles_opciones.append(restaurar)

	var volver := _crear_boton("VOLVER", Vector2(140, 510))
	volver.size = Vector2(400, 44)
	volver.pressed.connect(_mostrar_menu_principal)
	panel_opciones.add_child(volver)
	controles_opciones.append(volver)

	label_monitor_nativo = Label.new()
	label_monitor_nativo.position = Vector2(30, 558)
	label_monitor_nativo.size = Vector2(620, 22)
	label_monitor_nativo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_monitor_nativo.add_theme_font_size_override("font_size", 11)
	label_monitor_nativo.add_theme_color_override("font_color", Color(1.0, 0.76, 0.34))
	panel_opciones.add_child(label_monitor_nativo)

	var ayuda := Label.new()
	ayuda.text = "↑ ↓ ELEGIR   •   ← → AJUSTAR   •   A CAMBIAR   •   B VOLVER"
	ayuda.position = Vector2(30, 588)
	ayuda.size = Vector2(620, 28)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.add_theme_font_size_override("font_size", 11)
	ayuda.add_theme_color_override("font_color", Color(0.90, 0.86, 0.98))
	panel_opciones.add_child(ayuda)

func _actualizar_estado_opciones() -> void:
	var ajustes := _settings()
	if ajustes:
		slider_master.set_value_no_signal(float(ajustes.get("volumen_master")))
		slider_musica.set_value_no_signal(float(ajustes.get("volumen_musica")))
		slider_efectos.set_value_no_signal(float(ajustes.get("volumen_efectos")))
		slider_voces.set_value_no_signal(float(ajustes.get("volumen_voces")))
		_recargar_resoluciones(ajustes)
		toggle_fullscreen.set_pressed_no_signal(bool(ajustes.get("pantalla_completa")))
		toggle_vsync.set_pressed_no_signal(bool(ajustes.get("vsync")))
		toggle_shake.set_pressed_no_signal(bool(ajustes.get("shake_camara")))
		if label_monitor_nativo:
			var nativa := String(ajustes.call("get_resolucion_monitor_texto")) if ajustes.has_method("get_resolucion_monitor_texto") else "AUTO"
			label_monitor_nativo.text = "PANTALLA COMPLETA = RESOLUCIÓN NATIVA DEL MONITOR: " + nativa
	else:
		var bus := AudioServer.get_bus_index("Master")
		if bus >= 0:
			slider_master.set_value_no_signal(clampf(db_to_linear(AudioServer.get_bus_volume_db(bus)) * 100.0, 0.0, 100.0))
	_actualizar_labels_audio()

func _actualizar_labels_audio() -> void:
	label_master_valor.text = "%d%%" % int(round(slider_master.value))
	label_musica_valor.text = "%d%%" % int(round(slider_musica.value))
	label_efectos_valor.text = "%d%%" % int(round(slider_efectos.value))
	label_voces_valor.text = "%d%%" % int(round(slider_voces.value))

func _cambiar_master(valor: float) -> void:
	label_master_valor.text = "%d%%" % int(round(valor))
	var ajustes := _settings()
	if ajustes and ajustes.has_method("set_master"):
		ajustes.set_master(valor)

func _cambiar_musica(valor: float) -> void:
	label_musica_valor.text = "%d%%" % int(round(valor))
	var ajustes := _settings()
	if ajustes and ajustes.has_method("set_musica"):
		ajustes.set_musica(valor)

func _cambiar_efectos(valor: float) -> void:
	label_efectos_valor.text = "%d%%" % int(round(valor))
	var ajustes := _settings()
	if ajustes and ajustes.has_method("set_efectos"):
		ajustes.set_efectos(valor)

func _cambiar_voces(valor: float) -> void:
	label_voces_valor.text = "%d%%" % int(round(valor))
	var ajustes := _settings()
	if ajustes and ajustes.has_method("set_voces"):
		ajustes.set_voces(valor)


func _recargar_resoluciones(ajustes: Node) -> void:
	if selector_resolucion == null:
		return
	selector_resolucion.clear()
	resoluciones_mostradas.clear()
	var disponibles: Array = []
	if ajustes.has_method("get_resoluciones_disponibles"):
		disponibles = ajustes.call("get_resoluciones_disponibles")
	if disponibles.is_empty():
		disponibles = [Vector2i(1280, 720)]
	for valor in disponibles:
		var r: Vector2i = valor
		resoluciones_mostradas.append(r)
		selector_resolucion.add_item("%d × %d" % [r.x, r.y])
	var actual: Vector2i = ajustes.get("resolucion_ventana")
	var indice := resoluciones_mostradas.find(actual)
	selector_resolucion.select(maxi(indice, 0))

func _cambiar_resolucion(indice: int) -> void:
	if indice < 0 or indice >= resoluciones_mostradas.size():
		return
	var ajustes := _settings()
	if ajustes and ajustes.has_method("set_resolucion_ventana"):
		ajustes.set_resolucion_ventana(resoluciones_mostradas[indice])

func _cambiar_fullscreen(activo: bool) -> void:
	var ajustes := _settings()
	if ajustes and ajustes.has_method("set_fullscreen"):
		ajustes.set_fullscreen(activo)

func _cambiar_vsync(activo: bool) -> void:
	var ajustes := _settings()
	if ajustes and ajustes.has_method("set_vsync"):
		ajustes.set_vsync(activo)

func _cambiar_shake(activo: bool) -> void:
	var ajustes := _settings()
	if ajustes and ajustes.has_method("set_shake_camara"):
		ajustes.set_shake_camara(activo)

func _restaurar_opciones() -> void:
	var ajustes := _settings()
	if ajustes and ajustes.has_method("restaurar_predeterminados"):
		ajustes.restaurar_predeterminados()
	_actualizar_estado_opciones()
	await get_tree().process_frame
	if slider_master:
		slider_master.grab_focus()
