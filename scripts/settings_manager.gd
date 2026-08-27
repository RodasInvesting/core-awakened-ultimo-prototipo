extends Node

# CORE AWAKENED 90.10.33 — SETTINGS MANAGER
# Guarda las preferencias en user:// para que sobrevivan al cierre del juego.
# También crea y mantiene buses separados de Música / Efectos / Voces sin
# obligarnos a reescribir cada reproductor de audio existente.

const CONFIG_PATH := "user://core_awakened_settings.cfg"
const BUS_MUSICA := "Musica"
const BUS_EFECTOS := "Efectos"
const BUS_VOCES := "Voces"

# 90.10.37 — resoluciones 16:9 soportadas para modo ventana. En pantalla
# completa se usa SIEMPRE la resolución nativa real del monitor.
const RESOLUCIONES_BASE: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]

var volumen_master: float = 100.0
var volumen_musica: float = 100.0
var volumen_efectos: float = 100.0
var volumen_voces: float = 100.0
var pantalla_completa: bool = false
var resolucion_ventana: Vector2i = Vector2i(1280, 720)
var vsync: bool = true
var shake_camara: bool = true

var _scan_timer := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_asegurar_buses()
	_cargar()
	_aplicar_todo(false)
	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)
	set_process(true)


func _on_node_added(nodo: Node) -> void:
	if nodo is AudioStreamPlayer or nodo is AudioStreamPlayer2D or nodo is AudioStreamPlayer3D:
		# Diferido cubre también players que se agregan antes de asignar stream.
		call_deferred("_clasificar_player", nodo)

func _process(delta: float) -> void:
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = 0.45
		_clasificar_audio_del_arbol()

func _asegurar_buses() -> void:
	_asegurar_bus(BUS_MUSICA)
	_asegurar_bus(BUS_EFECTOS)
	_asegurar_bus(BUS_VOCES)

func _asegurar_bus(nombre: String) -> int:
	var idx := AudioServer.get_bus_index(nombre)
	if idx < 0:
		AudioServer.add_bus()
		idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, nombre)
		AudioServer.set_bus_send(idx, "Master")
	return idx

func _cargar() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(CONFIG_PATH)
	if err != OK:
		var modo := DisplayServer.window_get_mode()
		pantalla_completa = modo == DisplayServer.WINDOW_MODE_FULLSCREEN or modo == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		resolucion_ventana = Vector2i(1280, 720)
		vsync = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
		_guardar()
		return
	volumen_master = clampf(float(cfg.get_value("audio", "master", 100.0)), 0.0, 100.0)
	volumen_musica = clampf(float(cfg.get_value("audio", "musica", 100.0)), 0.0, 100.0)
	volumen_efectos = clampf(float(cfg.get_value("audio", "efectos", 100.0)), 0.0, 100.0)
	volumen_voces = clampf(float(cfg.get_value("audio", "voces", 100.0)), 0.0, 100.0)
	pantalla_completa = bool(cfg.get_value("video", "fullscreen", false))
	var ancho_guardado := int(cfg.get_value("video", "window_width", 1280))
	var alto_guardado := int(cfg.get_value("video", "window_height", 720))
	resolucion_ventana = _normalizar_resolucion(Vector2i(ancho_guardado, alto_guardado))
	vsync = bool(cfg.get_value("video", "vsync", true))
	shake_camara = bool(cfg.get_value("accesibilidad", "shake_camara", true))

func _guardar() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", volumen_master)
	cfg.set_value("audio", "musica", volumen_musica)
	cfg.set_value("audio", "efectos", volumen_efectos)
	cfg.set_value("audio", "voces", volumen_voces)
	cfg.set_value("video", "fullscreen", pantalla_completa)
	cfg.set_value("video", "window_width", resolucion_ventana.x)
	cfg.set_value("video", "window_height", resolucion_ventana.y)
	cfg.set_value("video", "vsync", vsync)
	cfg.set_value("accesibilidad", "shake_camara", shake_camara)
	cfg.save(CONFIG_PATH)

func _db_desde_porcentaje(valor: float) -> float:
	if valor <= 0.0:
		return -80.0
	return linear_to_db(clampf(valor, 0.0, 100.0) / 100.0)

func _aplicar_todo(guardar: bool = true) -> void:
	_asegurar_buses()
	_aplicar_volumen_bus("Master", volumen_master)
	_aplicar_volumen_bus(BUS_MUSICA, volumen_musica)
	_aplicar_volumen_bus(BUS_EFECTOS, volumen_efectos)
	_aplicar_volumen_bus(BUS_VOCES, volumen_voces)
	_aplicar_video()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)
	if guardar:
		_guardar()

func _aplicar_volumen_bus(nombre: String, valor: float) -> void:
	var idx := AudioServer.get_bus_index(nombre)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, _db_desde_porcentaje(valor))

func set_master(valor: float) -> void:
	volumen_master = clampf(valor, 0.0, 100.0)
	_aplicar_volumen_bus("Master", volumen_master)
	_guardar()

func set_musica(valor: float) -> void:
	volumen_musica = clampf(valor, 0.0, 100.0)
	_aplicar_volumen_bus(BUS_MUSICA, volumen_musica)
	_guardar()

func set_efectos(valor: float) -> void:
	volumen_efectos = clampf(valor, 0.0, 100.0)
	_aplicar_volumen_bus(BUS_EFECTOS, volumen_efectos)
	_guardar()

func set_voces(valor: float) -> void:
	volumen_voces = clampf(valor, 0.0, 100.0)
	_aplicar_volumen_bus(BUS_VOCES, volumen_voces)
	_guardar()

func set_fullscreen(activo: bool) -> void:
	pantalla_completa = activo
	_aplicar_video()
	_guardar()

func set_resolucion_ventana(tamano: Vector2i) -> void:
	resolucion_ventana = _normalizar_resolucion(tamano)
	if not pantalla_completa:
		_aplicar_resolucion_ventana()
	_guardar()

func get_resoluciones_disponibles() -> Array[Vector2i]:
	var pantalla := _tamano_monitor_actual()
	var lista: Array[Vector2i] = []
	for resolucion in RESOLUCIONES_BASE:
		if resolucion.x <= pantalla.x and resolucion.y <= pantalla.y:
			lista.append(resolucion)
	if lista.is_empty():
		lista.append(Vector2i(1280, 720))
	return lista

func get_resolucion_monitor_texto() -> String:
	var pantalla := _tamano_monitor_actual()
	return "%d × %d" % [pantalla.x, pantalla.y]

func _tamano_monitor_actual() -> Vector2i:
	var pantalla_idx := DisplayServer.window_get_current_screen()
	var tamano := DisplayServer.screen_get_size(pantalla_idx)
	if tamano.x <= 0 or tamano.y <= 0:
		return Vector2i(1920, 1080)
	return tamano

func _normalizar_resolucion(tamano: Vector2i) -> Vector2i:
	var disponibles := get_resoluciones_disponibles()
	if disponibles.has(tamano):
		return tamano
	# Si el monitor cambió o el valor guardado ya no entra, tomar la resolución
	# disponible más cercana sin superar físicamente la pantalla.
	var mejor: Vector2i = disponibles[0]
	var diferencia_mejor: int = absi(mejor.x - tamano.x) + absi(mejor.y - tamano.y)
	for r in disponibles:
		var diferencia: int = absi(r.x - tamano.x) + absi(r.y - tamano.y)
		if diferencia < diferencia_mejor:
			mejor = r
			diferencia_mejor = diferencia
	return mejor

func _aplicar_video() -> void:
	if pantalla_completa:
		# Fullscreen normal de Godot = pantalla completa sin forzar una resolución
		# exclusiva. Windows usa la resolución nativa actual del monitor y Godot
		# escala nuestro lienzo lógico 1280×720.
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		call_deferred("_aplicar_resolucion_ventana")

func _aplicar_resolucion_ventana() -> void:
	if pantalla_completa:
		return
	var tamano := _normalizar_resolucion(resolucion_ventana)
	resolucion_ventana = tamano
	DisplayServer.window_set_size(tamano)
	var pantalla_idx := DisplayServer.window_get_current_screen()
	var pos_pantalla := DisplayServer.screen_get_position(pantalla_idx)
	var tamano_pantalla := DisplayServer.screen_get_size(pantalla_idx)
	var posicion := pos_pantalla + Vector2i(
		maxi(0, (tamano_pantalla.x - tamano.x) / 2),
		maxi(0, (tamano_pantalla.y - tamano.y) / 2)
	)
	DisplayServer.window_set_position(posicion)

func set_vsync(activo: bool) -> void:
	vsync = activo
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if activo else DisplayServer.VSYNC_DISABLED)
	_guardar()

func set_shake_camara(activo: bool) -> void:
	shake_camara = activo
	_guardar()

func restaurar_predeterminados() -> void:
	volumen_master = 100.0
	volumen_musica = 100.0
	volumen_efectos = 100.0
	volumen_voces = 100.0
	pantalla_completa = false
	resolucion_ventana = Vector2i(1280, 720)
	vsync = true
	shake_camara = true
	_aplicar_todo(true)

func _clasificar_audio_del_arbol() -> void:
	var escena := get_tree().current_scene
	if escena == null:
		return
	_clasificar_nodo_recursivo(escena)
	# Autoloads también pueden crear SFX globales (GameState, etc.).
	for hijo in get_tree().root.get_children():
		if hijo != escena and hijo != self:
			_clasificar_nodo_recursivo(hijo)

func _clasificar_nodo_recursivo(nodo: Node) -> void:
	if nodo is AudioStreamPlayer or nodo is AudioStreamPlayer2D or nodo is AudioStreamPlayer3D:
		_clasificar_player(nodo)
	for hijo in nodo.get_children():
		_clasificar_nodo_recursivo(hijo)

func _clasificar_player(player: Node) -> void:
	var bus_actual := String(player.get("bus"))
	if bus_actual != "Master":
		return
	var stream = player.get("stream")
	if stream == null:
		return
	var ruta := String(stream.resource_path).to_lower()
	if ruta.is_empty():
		return
	player.set("bus", _bus_para_ruta(ruta))

func _bus_para_ruta(ruta: String) -> String:
	# Primero música/ambientes para que el viejo kai_human_pain.ogg, usado como
	# ambiente de escenario, no termine clasificado como voz por su nombre.
	if "/escenarios/" in ruta or "/ambientes/" in ruta or "historia_intro" in ruta or "historia_batalla" in ruta or "intro_estudio" in ruta or "selector_loop" in ruta or "seleccion_modos" in ruta or "/musica/" in ruta:
		return BUS_MUSICA
	if "/voces" in ruta or "/helena_real/" in ruta or "grito" in ruta or "dolor" in ruta or "reaccion_golpe" in ruta or "muerte_candidata" in ruta or "ataque_1_candidata" in ruta:
		return BUS_VOCES
	return BUS_EFECTOS
