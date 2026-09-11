extends Control

const TAMANO := Vector2(1280.0, 720.0)

var estado_label: Label
var ip_input: LineEdit
var puerto_input: LineEdit
var host_button: Button
var join_button: Button
var volver_button: Button
var ips_label: Label
var control_button: Button


func _ready() -> void:
	_crear_ui()
	var red := get_node("/root/NetworkManager")
	if not red.estado_cambiado.is_connected(_al_estado_red):
		red.estado_cambiado.connect(_al_estado_red)
	if not red.conexion_fallida.is_connected(_al_error_red):
		red.conexion_fallida.connect(_al_error_red)
	_al_estado_red(red.estado)


func _exit_tree() -> void:
	var red := get_node_or_null("/root/NetworkManager")
	if red == null:
		return
	if red.estado_cambiado.is_connected(_al_estado_red):
		red.estado_cambiado.disconnect(_al_estado_red)
	if red.conexion_fallida.is_connected(_al_error_red):
		red.conexion_fallida.disconnect(_al_error_red)


func _crear_ui() -> void:
	var fondo := ColorRect.new()
	fondo.color = Color(0.012, 0.010, 0.032, 1.0)
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fondo)

	var titulo := Label.new()
	titulo.text = "ONLINE — CONEXIÓN DIRECTA"
	titulo.position = Vector2(300, 92)
	titulo.size = Vector2(680, 46)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 30)
	titulo.add_theme_color_override("font_color", Color(0.96, 0.76, 1.0))
	add_child(titulo)

	var subtitulo := Label.new()
	subtitulo.text = "PASS 14B — prueba de transporte ENet / 2 jugadores"
	subtitulo.position = Vector2(300, 138)
	subtitulo.size = Vector2(680, 28)
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.add_theme_font_size_override("font_size", 16)
	add_child(subtitulo)

	var panel := Panel.new()
	panel.position = Vector2(300, 190)
	panel.size = Vector2(680, 390)
	add_child(panel)

	var host_titulo := Label.new()
	host_titulo.text = "CREAR PARTIDA"
	host_titulo.position = Vector2(340, 225)
	host_titulo.size = Vector2(260, 28)
	host_titulo.add_theme_font_size_override("font_size", 20)
	add_child(host_titulo)

	host_button = Button.new()
	host_button.text = "HOST"
	host_button.position = Vector2(340, 265)
	host_button.size = Vector2(260, 48)
	host_button.pressed.connect(_crear_host)
	add_child(host_button)

	ips_label = Label.new()
	ips_label.position = Vector2(340, 320)
	ips_label.size = Vector2(600, 50)
	ips_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ips_label.add_theme_font_size_override("font_size", 13)
	var ips: Array[String] = get_node("/root/NetworkManager").ips_locales_ipv4()
	ips_label.text = "IP LAN del host: %s" % (", ".join(ips) if not ips.is_empty() else "no detectada")
	add_child(ips_label)

	var join_titulo := Label.new()
	join_titulo.text = "UNIRSE A PARTIDA"
	join_titulo.position = Vector2(650, 225)
	join_titulo.size = Vector2(260, 28)
	join_titulo.add_theme_font_size_override("font_size", 20)
	add_child(join_titulo)

	ip_input = LineEdit.new()
	ip_input.placeholder_text = "IP del host"
	ip_input.text = "127.0.0.1"
	ip_input.position = Vector2(650, 265)
	ip_input.size = Vector2(260, 42)
	add_child(ip_input)

	var puerto_label := Label.new()
	puerto_label.text = "Puerto:"
	puerto_label.position = Vector2(650, 318)
	puerto_label.size = Vector2(70, 30)
	add_child(puerto_label)

	puerto_input = LineEdit.new()
	puerto_input.text = str(get_node("/root/NetworkManager").PUERTO_PREDETERMINADO)
	puerto_input.position = Vector2(720, 313)
	puerto_input.size = Vector2(190, 40)
	puerto_input.max_length = 5
	add_child(puerto_input)

	join_button = Button.new()
	join_button.text = "CONECTAR"
	join_button.position = Vector2(650, 365)
	join_button.size = Vector2(260, 48)
	join_button.pressed.connect(_unirse)
	add_child(join_button)

	control_button = Button.new()
	control_button.position = Vector2(340, 414)
	control_button.size = Vector2(570, 34)
	control_button.pressed.connect(_alternar_control_local)
	add_child(control_button)
	_actualizar_control_button()

	estado_label = Label.new()
	estado_label.position = Vector2(340, 455)
	estado_label.size = Vector2(570, 65)
	estado_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	estado_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	estado_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	estado_label.add_theme_font_size_override("font_size", 17)
	add_child(estado_label)

	var ayuda := Label.new()
	ayuda.text = "127.0.0.1 / misma PC: jugá en la ventana HOST — TECLADO=J1 y XBOX=J2. El CLIENTE sólo replica."
	ayuda.position = Vector2(330, 528)
	ayuda.size = Vector2(620, 40)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ayuda.add_theme_font_size_override("font_size", 13)
	add_child(ayuda)

	volver_button = Button.new()
	volver_button.text = "VOLVER"
	volver_button.position = Vector2(500, 610)
	volver_button.size = Vector2(280, 46)
	volver_button.pressed.connect(_volver)
	add_child(volver_button)

	host_button.grab_focus()


func _actualizar_control_button() -> void:
	if control_button == null:
		return
	var red := get_node("/root/NetworkManager")
	var origen := str(red.obtener_control_local()).to_lower() if red.has_method("obtener_control_local") else "teclado"
	var pads := Input.get_connected_joypads()
	if origen == "mando":
		control_button.text = "CONTROL LOCAL: MANDO" if not pads.is_empty() else "CONTROL LOCAL: MANDO (NO DETECTADO)"
	else:
		control_button.text = "CONTROL LOCAL: TECLADO"


func _alternar_control_local() -> void:
	var red := get_node("/root/NetworkManager")
	var actual := str(red.obtener_control_local()).to_lower() if red.has_method("obtener_control_local") else "teclado"
	red.establecer_control_local("mando" if actual == "teclado" else "teclado")
	_actualizar_control_button()


func _puerto() -> int:
	var p := int(puerto_input.text)
	return clampi(p, 1024, 65535)


func _crear_host() -> void:
	var gs := get_node("/root/GameState")
	gs.modo = "online"
	var red := get_node("/root/NetworkManager")
	var err: Error = red.crear_host(_puerto())
	if err == OK:
		host_button.disabled = true
		join_button.disabled = true
		control_button.disabled = true


func _unirse() -> void:
	var gs := get_node("/root/GameState")
	gs.modo = "online"
	var red := get_node("/root/NetworkManager")
	var err: Error = red.conectar_a_host(ip_input.text, _puerto())
	if err == OK:
		host_button.disabled = true
		join_button.disabled = true
		control_button.disabled = true


func _al_estado_red(texto: String) -> void:
	if estado_label == null:
		return
	estado_label.text = texto
	var red := get_node("/root/NetworkManager")
	if red.hay_rival_conectado():
		estado_label.text += "\nTRANSPORTE OK — 2 PEERS CONECTADOS"


func _al_error_red(mensaje: String) -> void:
	if estado_label:
		estado_label.text = "ERROR: %s" % mensaje
	host_button.disabled = false
	join_button.disabled = false
	control_button.disabled = false


func _volver() -> void:
	get_node("/root/NetworkManager").cerrar_conexion()
	get_node("/root/GameState").volver_al_menu()
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
