extends Node

# CORE AWAKENED 91.02.62 — PASS 14C
# Transporte ENet certificado + sincronización de selección/escenario/seed.
# NO intercambia todavía Input Frames de combate y NO toca rollback/gameplay.

signal estado_cambiado(texto: String)
signal rival_conectado(peer_id: int)
signal rival_desconectado(peer_id: int)
signal conexion_fallida(mensaje: String)
signal selecciones_actualizadas(host_personaje: String, cliente_personaje: String)
signal escenario_preview_cambiado(indice: int)
signal presentacion_sincronizada(seed: int, firma: String)
# 91.02.64 — PASS 14D1: barrera de Main + transporte real de Input Frames.
signal combate_go(seed: int)
signal input_remoto_recibido(tick: int)

# 91.02.71 — PASS 14D3A: PAUSA ONLINE SINCRONIZADA.
# El Host arbitra el tick exacto de pausa. Reanudación usa barrera + GO fiable.
signal pausa_online_programada(epoch: int, tick_objetivo: int)
signal pausa_online_reanudar(epoch: int, demora_ms: int)
signal pausa_online_cancelada()

# 91.02.74 — PASS 14D4A / REVANCHA ONLINE SINCRONIZADA.
signal revancha_estado_actualizado(host_listo: bool, client_listo: bool, epoch: int)
signal revancha_iniciada(epoch: int, seed: int)

# 91.02.75 — PASS 14D4B / SALIDA SINCRONIZADA DESDE RESULTADO.
# tipo: "selector" conserva la conexión; "menu" cierra la sesión en ambos peers.
signal salida_resultado_online(tipo: String, epoch: int)

const PUERTO_PREDETERMINADO := 7777
const MAX_CLIENTES := 1

var peer_enet: ENetMultiplayerPeer
var rol: String = "offline" # offline / host / client
var rival_peer_id: int = 0
var estado: String = "DESCONECTADO"
var ultimo_error: String = ""

# 91.02.65 — PASS 14D1B / ownership de dispositivo LOCAL por instancia.
# Cada proceso decide qué hardware lee; esto evita que dos instancias en la
# misma PC consuman el mismo Xbox y también evita que un mando conectado
# anule automáticamente al teclado.
var control_local: String = "teclado" # teclado / mando

# Estado canónico de pre-partida. La autoridad siempre es el Host (peer 1).
var personaje_host: String = ""
var personaje_cliente: String = ""
var escenario_preview_indice: int = 0
var escenario_confirmado: String = ""
var seed_online: int = 0
var flujo_seleccion_iniciado := false
var presentacion_ready_peers: Dictionary = {}
var presentacion_confirmada := false

# PASS 14D1 — estado de arranque de combate e inputs remotos.
var combate_ready_peers: Dictionary = {}
var combate_go_confirmado := false
var input_remoto_por_tick: Dictionary = {}
var ultimo_tick_remoto_recibido: int = -1
var paquetes_input_recibidos: int = 0

# 91.02.66 — PASS 14D1C: modo QA exclusivo para 2 instancias en la MISMA PC.
# En localhost, el HOST captura ambos dispositivos físicos (J1 teclado + J2 mando)
# y transmite el par de frames al cliente. En una conexión real entre 2 PCs
# este modo queda completamente apagado y sigue vigente el flujo bidireccional.
var loopback_misma_pc: bool = false
var input_loopback_por_tick: Dictionary = {}

# 91.02.71 — estado de pausa online.
# 12 ticks = ~200 ms a 60 Hz: da margen para que ambos peers reciban
# el mismo tick objetivo antes de congelar la simulación.
const PAUSA_ONLINE_MARGEN_TICKS := 12
const PAUSA_ONLINE_REANUDAR_DEMORA_MS := 300

var pausa_online_epoch: int = 0
var pausa_online_tick_objetivo: int = -1
var pausa_online_ack_peers: Dictionary = {}
var pausa_online_reanudar_ack_peers: Dictionary = {}
var pausa_online_reanudar_solicitado: bool = false
var pausa_online_en_barrera: bool = false

# 91.02.74 — estado de revancha.
var revancha_epoch: int = 0
var revancha_ready_peers: Dictionary = {}
var revancha_en_transicion: bool = false

# 91.02.75 — autoridad de salida de Resultado.
var salida_resultado_epoch: int = 0
var salida_resultado_en_transicion: bool = false


func _ready() -> void:
	# Debe seguir atendiendo la capa de control incluso con SceneTree.paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_conectar_senales_multiplayer()


func _conectar_senales_multiplayer() -> void:
	if not multiplayer.peer_connected.is_connected(_al_peer_conectado):
		multiplayer.peer_connected.connect(_al_peer_conectado)
	if not multiplayer.peer_disconnected.is_connected(_al_peer_desconectado):
		multiplayer.peer_disconnected.connect(_al_peer_desconectado)
	if not multiplayer.connected_to_server.is_connected(_al_conectado_al_servidor):
		multiplayer.connected_to_server.connect(_al_conectado_al_servidor)
	if not multiplayer.connection_failed.is_connected(_al_fallo_conexion):
		multiplayer.connection_failed.connect(_al_fallo_conexion)
	if not multiplayer.server_disconnected.is_connected(_al_servidor_desconectado):
		multiplayer.server_disconnected.connect(_al_servidor_desconectado)


func _reset_prepartida() -> void:
	personaje_host = ""
	personaje_cliente = ""
	escenario_preview_indice = 0
	escenario_confirmado = ""
	seed_online = 0
	presentacion_ready_peers.clear()
	presentacion_confirmada = false
	combate_ready_peers.clear()
	combate_go_confirmado = false
	input_remoto_por_tick.clear()
	ultimo_tick_remoto_recibido = -1
	paquetes_input_recibidos = 0
	input_loopback_por_tick.clear()
	_reset_pausa_online()
	_reset_revancha_online()


func _reset_revancha_online() -> void:
	revancha_ready_peers.clear()
	revancha_en_transicion = false
	salida_resultado_en_transicion = false


func _reset_pausa_online() -> void:
	pausa_online_tick_objetivo = -1
	pausa_online_ack_peers.clear()
	pausa_online_reanudar_ack_peers.clear()
	pausa_online_reanudar_solicitado = false
	pausa_online_en_barrera = false


func establecer_control_local(tipo: String) -> void:
	var normalizado := tipo.strip_edges().to_lower()
	if normalizado not in ["teclado", "mando"]:
		normalizado = "teclado"
	control_local = normalizado
	print("[91.02.65-P14D1B] CONTROL LOCAL peer=%d -> %s" % [mi_peer_id(), control_local.to_upper()])


func obtener_control_local() -> String:
	return control_local


func crear_host(puerto: int = PUERTO_PREDETERMINADO) -> Error:
	cerrar_conexion(false)
	peer_enet = ENetMultiplayerPeer.new()
	var err := peer_enet.create_server(puerto, MAX_CLIENTES)
	if err != OK:
		peer_enet = null
		_set_estado("ERROR AL CREAR HOST")
		ultimo_error = error_string(err)
		conexion_fallida.emit(ultimo_error)
		return err

	multiplayer.multiplayer_peer = peer_enet
	rol = "host"
	loopback_misma_pc = false
	rival_peer_id = 0
	ultimo_error = ""
	flujo_seleccion_iniciado = false
	_reset_prepartida()
	_set_estado("HOST ACTIVO — ESPERANDO RIVAL")
	return OK


func conectar_a_host(ip: String, puerto: int = PUERTO_PREDETERMINADO) -> Error:
	cerrar_conexion(false)
	var destino := ip.strip_edges()
	if destino.is_empty():
		destino = "127.0.0.1"

	peer_enet = ENetMultiplayerPeer.new()
	var err := peer_enet.create_client(destino, puerto)
	if err != OK:
		peer_enet = null
		_set_estado("ERROR AL INICIAR CLIENTE")
		ultimo_error = error_string(err)
		conexion_fallida.emit(ultimo_error)
		return err

	multiplayer.multiplayer_peer = peer_enet
	rol = "client"
	loopback_misma_pc = destino.to_lower() in ["127.0.0.1", "localhost", "::1"]
	rival_peer_id = 0
	ultimo_error = ""
	flujo_seleccion_iniciado = false
	_reset_prepartida()
	_set_estado("CONECTANDO A %s:%d..." % [destino, puerto])
	return OK


func cerrar_conexion(notificar: bool = true) -> void:
	if peer_enet != null:
		peer_enet.close()
	peer_enet = null
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	rol = "offline"
	loopback_misma_pc = false
	rival_peer_id = 0
	ultimo_error = ""
	flujo_seleccion_iniciado = false
	_reset_prepartida()
	if notificar:
		_set_estado("DESCONECTADO")
	else:
		estado = "DESCONECTADO"


func hay_rival_conectado() -> bool:
	if rol == "offline":
		return false
	if rol == "host":
		return rival_peer_id > 0
	if rol == "client":
		return multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED
	return false


func es_host() -> bool:
	return rol == "host"


func es_cliente() -> bool:
	return rol == "client"


func mi_peer_id() -> int:
	if rol == "offline":
		return 0
	return multiplayer.get_unique_id()


func ips_locales_ipv4() -> Array[String]:
	var resultado: Array[String] = []
	for direccion in IP.get_local_addresses():
		if ":" in direccion:
			continue
		if direccion.begins_with("127."):
			continue
		if direccion not in resultado:
			resultado.append(direccion)
	return resultado


func _al_peer_conectado(id: int) -> void:
	if id == multiplayer.get_unique_id():
		return
	rival_peer_id = id
	if rol == "host":
		_set_estado("RIVAL CONECTADO — PEER %d" % id)
		_programar_inicio_selector()
	rival_conectado.emit(id)


func _al_peer_desconectado(id: int) -> void:
	if id == rival_peer_id:
		rival_peer_id = 0
		flujo_seleccion_iniciado = false
		_reset_prepartida()
		if rol == "host":
			_set_estado("RIVAL DESCONECTADO — ESPERANDO NUEVO RIVAL")
		else:
			_set_estado("RIVAL DESCONECTADO")
	rival_desconectado.emit(id)


func _al_conectado_al_servidor() -> void:
	rival_peer_id = MultiplayerPeer.TARGET_PEER_SERVER
	_set_estado("CONECTADO AL HOST")
	if loopback_misma_pc:
		rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, "_rpc_declarar_loopback_misma_pc")
		print("[91.02.66-P14D1C] LOOPBACK MISMA PC — CLIENTE declarado")
	rival_conectado.emit(rival_peer_id)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_declarar_loopback_misma_pc() -> void:
	if not es_host():
		return
	var sender: int = multiplayer.get_remote_sender_id()
	if sender != rival_peer_id:
		return
	loopback_misma_pc = true
	input_loopback_por_tick.clear()
	print("[91.02.66-P14D1C] LOOPBACK MISMA PC — HOST confirmado para peer %d" % sender)


func es_loopback_misma_pc() -> bool:
	return loopback_misma_pc


func _al_fallo_conexion() -> void:
	ultimo_error = "No se pudo conectar al host."
	_set_estado("CONEXIÓN FALLIDA")
	conexion_fallida.emit(ultimo_error)


func _al_servidor_desconectado() -> void:
	rival_peer_id = 0
	flujo_seleccion_iniciado = false
	_reset_prepartida()
	_set_estado("HOST DESCONECTADO")
	rival_desconectado.emit(MultiplayerPeer.TARGET_PEER_SERVER)


func _programar_inicio_selector() -> void:
	if not es_host() or flujo_seleccion_iniciado:
		return
	flujo_seleccion_iniciado = true
	# Da tiempo a que el cliente complete connected_to_server y tenga el autoload listo.
	await get_tree().create_timer(0.65).timeout
	if not es_host() or not hay_rival_conectado():
		flujo_seleccion_iniciado = false
		return
	_reset_prepartida()
	rpc("_rpc_abrir_selector_personajes")


@rpc("authority", "call_local", "reliable")
func _rpc_abrir_selector_personajes() -> void:
	var gs := get_node_or_null("/root/GameState")
	if gs != null:
		gs.modo = "online"
	get_tree().change_scene_to_file("res://scenes/SelectorPersonajes.tscn")


# -------------------- PERSONAJES --------------------
func confirmar_personaje_local(nombre: String) -> void:
	if rol == "offline" or not hay_rival_conectado():
		return
	if es_host():
		_registrar_personaje_host(nombre)
	else:
		rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, "_rpc_confirmar_personaje_cliente", nombre)


func _registrar_personaje_host(nombre: String) -> void:
	if not es_host():
		return
	personaje_host = nombre
	rpc("_rpc_reflejar_selecciones", personaje_host, personaje_cliente)
	_intentar_cerrar_seleccion_personajes()


@rpc("any_peer", "call_remote", "reliable")
func _rpc_confirmar_personaje_cliente(nombre: String) -> void:
	if not es_host():
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender != rival_peer_id:
		return
	personaje_cliente = nombre
	rpc("_rpc_reflejar_selecciones", personaje_host, personaje_cliente)
	_intentar_cerrar_seleccion_personajes()


@rpc("authority", "call_local", "reliable")
func _rpc_reflejar_selecciones(host_nombre: String, cliente_nombre: String) -> void:
	personaje_host = host_nombre
	personaje_cliente = cliente_nombre
	selecciones_actualizadas.emit(personaje_host, personaje_cliente)


func _intentar_cerrar_seleccion_personajes() -> void:
	if not es_host():
		return
	if personaje_host.is_empty() or personaje_cliente.is_empty():
		return
	# Canonicalizamos J1=HOST y J2=CLIENTE antes de entrar al selector de arena.
	await get_tree().create_timer(0.35).timeout
	if personaje_host.is_empty() or personaje_cliente.is_empty() or not hay_rival_conectado():
		return
	rpc("_rpc_abrir_selector_escenarios", personaje_host, personaje_cliente)


@rpc("authority", "call_local", "reliable")
func _rpc_abrir_selector_escenarios(j1: String, j2: String) -> void:
	personaje_host = j1
	personaje_cliente = j2
	var gs := get_node_or_null("/root/GameState")
	if gs != null and gs.has_method("preparar_online_personajes"):
		gs.preparar_online_personajes(j1, j2)
	get_tree().change_scene_to_file("res://scenes/SelectorEscenarios.tscn")


# -------------------- ESCENARIO --------------------
func actualizar_preview_escenario(indice: int) -> void:
	if not es_host() or not hay_rival_conectado():
		return
	escenario_preview_indice = max(0, indice)
	rpc("_rpc_preview_escenario", escenario_preview_indice)


@rpc("authority", "call_local", "reliable")
func _rpc_preview_escenario(indice: int) -> void:
	escenario_preview_indice = max(0, indice)
	escenario_preview_cambiado.emit(escenario_preview_indice)


func confirmar_escenario_online(escenario: String) -> void:
	if not es_host() or not hay_rival_conectado():
		return
	if personaje_host.is_empty() or personaje_cliente.is_empty():
		return
	escenario_confirmado = escenario
	seed_online = int(Time.get_ticks_usec() & 0x7fffffff)
	if seed_online == 0:
		seed_online = 9102062
	var firma := "%s|%s|%s|%d" % [personaje_host, personaje_cliente, escenario_confirmado, seed_online]
	print("[91.02.62-P14C] CONFIG HOST — %s" % firma)
	rpc("_rpc_configurar_presentacion", personaje_host, personaje_cliente, escenario_confirmado, seed_online)


@rpc("authority", "call_local", "reliable")
func _rpc_configurar_presentacion(j1: String, j2: String, escenario: String, seed_recibida: int) -> void:
	personaje_host = j1
	personaje_cliente = j2
	escenario_confirmado = escenario
	seed_online = seed_recibida
	presentacion_ready_peers.clear()
	presentacion_confirmada = false
	var gs := get_node_or_null("/root/GameState")
	if gs != null and gs.has_method("iniciar_online_sincronizado"):
		gs.iniciar_online_sincronizado(j1, j2, escenario, seed_recibida)
	print("[91.02.62-P14C] CONFIG RECIBIDA peer=%d — %s|%s|%s|%d" % [mi_peer_id(), j1, j2, escenario, seed_recibida])
	get_tree().change_scene_to_file("res://scenes/PresentacionVS.tscn")


# -------------------- BARRERA PRESENTACION VS --------------------
func marcar_presentacion_lista() -> void:
	if rol == "offline":
		return
	if es_host():
		_registrar_presentacion_lista(multiplayer.get_unique_id())
	else:
		rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, "_rpc_presentacion_lista_cliente")


@rpc("any_peer", "call_remote", "reliable")
func _rpc_presentacion_lista_cliente() -> void:
	if not es_host():
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender != rival_peer_id:
		return
	_registrar_presentacion_lista(sender)


func _registrar_presentacion_lista(peer_id: int) -> void:
	if not es_host() or presentacion_confirmada:
		return
	presentacion_ready_peers[peer_id] = true
	var host_id := multiplayer.get_unique_id()
	if presentacion_ready_peers.has(host_id) and rival_peer_id > 0 and presentacion_ready_peers.has(rival_peer_id):
		presentacion_confirmada = true
		var firma := "%s|%s|%s|%d" % [personaje_host, personaje_cliente, escenario_confirmado, seed_online]
		print("[91.02.62-P14C] BARRERA VS OK — %s" % firma)
		rpc("_rpc_presentacion_confirmada", seed_online, firma)


@rpc("authority", "call_local", "reliable")
func _rpc_presentacion_confirmada(seed_recibida: int, firma: String) -> void:
	seed_online = seed_recibida
	presentacion_sincronizada.emit(seed_online, firma)
	print("[91.02.62-P14C] PRESENTACION SINCRONIZADA peer=%d — %s" % [mi_peer_id(), firma])



# -------------------- BARRERA MAIN / COMBATE --------------------
func marcar_main_lista() -> void:
	if rol == "offline":
		return
	if es_host():
		_registrar_main_lista(multiplayer.get_unique_id())
	else:
		rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, "_rpc_main_lista_cliente")


@rpc("any_peer", "call_remote", "reliable")
func _rpc_main_lista_cliente() -> void:
	if not es_host():
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender != rival_peer_id:
		return
	_registrar_main_lista(sender)


func _registrar_main_lista(peer_id: int) -> void:
	if not es_host() or combate_go_confirmado:
		return
	combate_ready_peers[peer_id] = true
	var host_id := multiplayer.get_unique_id()
	if combate_ready_peers.has(host_id) and rival_peer_id > 0 and combate_ready_peers.has(rival_peer_id):
		combate_go_confirmado = true
		print("[91.02.64-P14D1] BARRERA MAIN OK — seed=%d" % seed_online)
		rpc("_rpc_combate_go", seed_online)


@rpc("authority", "call_local", "reliable")
func _rpc_combate_go(seed_recibida: int) -> void:
	seed_online = seed_recibida
	input_remoto_por_tick.clear()
	ultimo_tick_remoto_recibido = -1
	paquetes_input_recibidos = 0
	combate_go.emit(seed_online)
	print("[91.02.64-P14D1] COMBATE GO peer=%d rol=%s seed=%d" % [mi_peer_id(), rol, seed_online])


# -------------------- SALIDA RESULTADO ONLINE 91.02.75 --------------------
func solicitar_salida_resultado_online(tipo: String) -> void:
	var destino: String = tipo.strip_edges().to_lower()
	if destino not in ["selector", "menu"]:
		return
	if rol == "offline" or not hay_rival_conectado():
		return
	if not _en_resultado_online():
		return
	if salida_resultado_en_transicion or revancha_en_transicion:
		return

	if es_host():
		_host_salida_resultado_online(destino, multiplayer.get_unique_id())
	else:
		rpc_id(
			MultiplayerPeer.TARGET_PEER_SERVER,
			"_rpc_solicitar_salida_resultado_cliente",
			destino
		)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_solicitar_salida_resultado_cliente(tipo: String) -> void:
	if not es_host() or salida_resultado_en_transicion or revancha_en_transicion:
		return
	if not _en_resultado_online():
		return
	var sender: int = multiplayer.get_remote_sender_id()
	if sender != rival_peer_id:
		return
	var destino: String = tipo.strip_edges().to_lower()
	if destino not in ["selector", "menu"]:
		return
	_host_salida_resultado_online(destino, sender)


func _host_salida_resultado_online(tipo: String, solicitante: int) -> void:
	if not es_host() or not hay_rival_conectado():
		return
	if salida_resultado_en_transicion or revancha_en_transicion:
		return
	if not _en_resultado_online():
		return

	salida_resultado_en_transicion = true
	revancha_ready_peers.clear()
	salida_resultado_epoch += 1

	print("[91.02.75-P14D4B] RESULTADO SALIDA GO — tipo=%s solicitante=%d epoch=%d" % [
		tipo, solicitante, salida_resultado_epoch
	])
	rpc("_rpc_salida_resultado_online", tipo, salida_resultado_epoch)


@rpc("authority", "call_local", "reliable")
func _rpc_salida_resultado_online(tipo: String, epoch: int) -> void:
	if rol == "offline":
		return
	var destino: String = tipo.strip_edges().to_lower()
	if destino not in ["selector", "menu"]:
		return

	salida_resultado_epoch = epoch
	salida_resultado_en_transicion = true

	if destino == "selector":
		# Conservar ENet y roles, pero limpiar TODO lo que pertenecía a la pelea
		# anterior y a la configuración anterior. El selector online existente
		# volverá a poblar personaje_host/personaje_cliente/escenario/seed.
		personaje_host = ""
		personaje_cliente = ""
		escenario_preview_indice = 0
		escenario_confirmado = ""
		seed_online = 0
		presentacion_ready_peers.clear()
		presentacion_confirmada = false
		combate_ready_peers.clear()
		combate_go_confirmado = false
		input_remoto_por_tick.clear()
		ultimo_tick_remoto_recibido = -1
		paquetes_input_recibidos = 0
		input_loopback_por_tick.clear()
		_reset_pausa_online()
		_reset_revancha_online()
		# _reset_revancha_online limpia el flag; lo mantenemos activo hasta que
		# Resultado sea liberado para bloquear dobles solicitudes en este frame.
		salida_resultado_en_transicion = true
		var gs := get_node_or_null("/root/GameState")
		if gs != null:
			gs.set("modo", "online")
			gs.set("ultimo_resultado", "")
			gs.set("ultimo_rival", "")

	print("[91.02.75-P14D4B] RESULTADO SALIDA RECIBIDA — peer=%d rol=%s tipo=%s epoch=%d" % [
		mi_peer_id(), rol, destino, epoch
	])
	salida_resultado_online.emit(destino, epoch)


func finalizar_salida_resultado_online() -> void:
	salida_resultado_en_transicion = false


# -------------------- REVANCHA ONLINE SINCRONIZADA 91.02.74 --------------------
func _en_resultado_online() -> bool:
	var escena := get_tree().current_scene
	if escena == null or escena.scene_file_path != "res://scenes/Resultado.tscn":
		return false
	var gs := get_node_or_null("/root/GameState")
	if gs == null:
		return false
	if gs.has_method("es_online"):
		return bool(gs.call("es_online"))
	return str(gs.get("modo")) == "online"


func solicitar_revancha_online() -> void:
	if rol == "offline" or not hay_rival_conectado():
		return
	if not _en_resultado_online():
		return
	if revancha_en_transicion or salida_resultado_en_transicion:
		return

	if es_host():
		_registrar_revancha(multiplayer.get_unique_id())
	else:
		rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, "_rpc_solicitar_revancha_cliente")


@rpc("any_peer", "call_remote", "reliable")
func _rpc_solicitar_revancha_cliente() -> void:
	if not es_host() or revancha_en_transicion or salida_resultado_en_transicion or not _en_resultado_online():
		return
	var sender: int = multiplayer.get_remote_sender_id()
	if sender != rival_peer_id:
		return
	_registrar_revancha(sender)


func _registrar_revancha(peer_id: int) -> void:
	if not es_host() or revancha_en_transicion:
		return
	if not _en_resultado_online():
		return

	# Primer voto abre un nuevo ciclo; el segundo voto conserva el mismo epoch.
	if revancha_ready_peers.is_empty():
		revancha_epoch += 1

	revancha_ready_peers[peer_id] = true

	var host_id: int = multiplayer.get_unique_id()
	var host_listo: bool = revancha_ready_peers.has(host_id)
	var client_listo: bool = rival_peer_id > 0 and revancha_ready_peers.has(rival_peer_id)

	print("[91.02.74-P14D4A] REVANCHA VOTO — peer=%d host=%s client=%s epoch=%d" % [
		peer_id, str(host_listo), str(client_listo), revancha_epoch
	])
	rpc("_rpc_reflejar_revancha", revancha_epoch, host_listo, client_listo)

	if host_listo and client_listo:
		_host_iniciar_revancha()


@rpc("authority", "call_local", "reliable")
func _rpc_reflejar_revancha(epoch: int, host_listo: bool, client_listo: bool) -> void:
	revancha_epoch = epoch
	revancha_estado_actualizado.emit(host_listo, client_listo, epoch)


func _host_iniciar_revancha() -> void:
	if not es_host() or revancha_en_transicion or not hay_rival_conectado():
		return
	var host_id: int = multiplayer.get_unique_id()
	if not revancha_ready_peers.has(host_id):
		return
	if rival_peer_id <= 0 or not revancha_ready_peers.has(rival_peer_id):
		return

	revancha_en_transicion = true
	var nueva_seed: int = int(Time.get_ticks_usec() & 0x7fffffff)
	if nueva_seed == 0 or nueva_seed == seed_online:
		nueva_seed = int((seed_online + 9102074) & 0x7fffffff)
		if nueva_seed == 0:
			nueva_seed = 9102074

	print("[91.02.74-P14D4A] REVANCHA GO — epoch=%d seed=%d config=%s|%s|%s" % [
		revancha_epoch, nueva_seed, personaje_host, personaje_cliente, escenario_confirmado
	])
	rpc("_rpc_iniciar_revancha_online", revancha_epoch, nueva_seed)


func _preparar_nuevo_ciclo_combate_online() -> void:
	# Mantiene conexión, personajes y escenario; reinicia sólo las barreras y
	# buffers pertenecientes a una pelea concreta.
	presentacion_ready_peers.clear()
	presentacion_confirmada = false
	combate_ready_peers.clear()
	combate_go_confirmado = false
	input_remoto_por_tick.clear()
	ultimo_tick_remoto_recibido = -1
	paquetes_input_recibidos = 0
	input_loopback_por_tick.clear()
	_reset_pausa_online()


@rpc("authority", "call_local", "reliable")
func _rpc_iniciar_revancha_online(epoch: int, nueva_seed: int) -> void:
	if rol == "offline" or not hay_rival_conectado():
		return
	if epoch != revancha_epoch:
		revancha_epoch = epoch

	revancha_en_transicion = true
	seed_online = nueva_seed
	_preparar_nuevo_ciclo_combate_online()

	var gs := get_node_or_null("/root/GameState")
	if gs != null:
		if gs.has_method("reiniciar_combate_actual"):
			gs.call("reiniciar_combate_actual")
		if gs.has_method("iniciar_online_sincronizado"):
			gs.call(
				"iniciar_online_sincronizado",
				personaje_host,
				personaje_cliente,
				escenario_confirmado,
				seed_online
			)

	print("[91.02.74-P14D4A] REVANCHA TRANSICION — peer=%d rol=%s epoch=%d seed=%d" % [
		mi_peer_id(), rol, revancha_epoch, seed_online
	])
	revancha_iniciada.emit(revancha_epoch, seed_online)

	# El cambio diferido evita liberar Resultado.tscn dentro del propio RPC.
	get_tree().call_deferred("change_scene_to_file", "res://scenes/PresentacionVS.tscn")

	# El siguiente ciclo ya está armado. Los votos viejos no se reutilizan.
	revancha_ready_peers.clear()
	revancha_en_transicion = false


# -------------------- PAUSA ONLINE SINCRONIZADA 91.02.71 --------------------
func _tick_online_actual() -> int:
	var escena := get_tree().current_scene
	if escena == null or escena.scene_file_path != "res://scenes/Main.tscn":
		return 0
	var valor = escena.get("online_tick_simulacion")
	if valor == null:
		return 0
	return int(valor)


func pausa_online_en_curso() -> bool:
	return pausa_online_tick_objetivo >= 0 or pausa_online_en_barrera


func solicitar_pausa_online(tick_solicitante: int) -> void:
	if rol == "offline" or not hay_rival_conectado():
		return
	if pausa_online_en_curso():
		return
	if es_host():
		_host_programar_pausa_online(tick_solicitante)
	else:
		rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, "_rpc_solicitar_pausa_online_cliente", tick_solicitante)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_solicitar_pausa_online_cliente(tick_solicitante: int) -> void:
	if not es_host():
		return
	var sender: int = multiplayer.get_remote_sender_id()
	if sender != rival_peer_id:
		return
	if pausa_online_en_curso():
		return
	_host_programar_pausa_online(tick_solicitante)


func _host_programar_pausa_online(tick_solicitante: int) -> void:
	if not es_host() or not hay_rival_conectado():
		return
	pausa_online_epoch += 1
	var tick_host: int = _tick_online_actual()
	var base_tick: int = maxi(tick_host, tick_solicitante)
	var objetivo: int = base_tick + PAUSA_ONLINE_MARGEN_TICKS
	pausa_online_tick_objetivo = objetivo
	pausa_online_ack_peers.clear()
	pausa_online_reanudar_ack_peers.clear()
	pausa_online_reanudar_solicitado = false
	pausa_online_en_barrera = false
	print("[91.02.71-P14D3A] PAUSA REQUEST — host_tick=%d solicitante=%d objetivo=%d epoch=%d" % [
		tick_host, tick_solicitante, objetivo, pausa_online_epoch
	])
	rpc("_rpc_programar_pausa_online", pausa_online_epoch, objetivo)


@rpc("authority", "call_local", "reliable")
func _rpc_programar_pausa_online(epoch: int, tick_objetivo: int) -> void:
	pausa_online_epoch = epoch
	pausa_online_tick_objetivo = tick_objetivo
	pausa_online_ack_peers.clear()
	pausa_online_reanudar_ack_peers.clear()
	pausa_online_reanudar_solicitado = false
	pausa_online_en_barrera = false
	pausa_online_programada.emit(epoch, tick_objetivo)
	print("[91.02.71-P14D3A] PAUSA PROGRAMADA — peer=%d rol=%s objetivo=%d epoch=%d" % [
		mi_peer_id(), rol, tick_objetivo, epoch
	])


func confirmar_pausa_online_aplicada(epoch: int, tick_aplicado: int) -> void:
	if rol == "offline" or epoch != pausa_online_epoch:
		return
	if es_host():
		_registrar_pausa_online_aplicada(multiplayer.get_unique_id(), epoch, tick_aplicado)
	else:
		rpc_id(
			MultiplayerPeer.TARGET_PEER_SERVER,
			"_rpc_confirmar_pausa_online_cliente",
			epoch,
			tick_aplicado
		)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_confirmar_pausa_online_cliente(epoch: int, tick_aplicado: int) -> void:
	if not es_host() or epoch != pausa_online_epoch:
		return
	var sender: int = multiplayer.get_remote_sender_id()
	if sender != rival_peer_id:
		return
	_registrar_pausa_online_aplicada(sender, epoch, tick_aplicado)


func _registrar_pausa_online_aplicada(peer_id: int, epoch: int, tick_aplicado: int) -> void:
	if not es_host() or epoch != pausa_online_epoch:
		return
	pausa_online_ack_peers[peer_id] = tick_aplicado
	var host_id: int = multiplayer.get_unique_id()
	print("[91.02.71-P14D3A] PAUSA ACK — peer=%d tick=%d epoch=%d" % [
		peer_id, tick_aplicado, epoch
	])
	if pausa_online_ack_peers.has(host_id) and rival_peer_id > 0 and pausa_online_ack_peers.has(rival_peer_id):
		pausa_online_en_barrera = true
		var tick_host_ack: int = int(pausa_online_ack_peers[host_id])
		var tick_client_ack: int = int(pausa_online_ack_peers[rival_peer_id])
		print("[91.02.71-P14D3A] PAUSA BARRERA OK — host=%d client=%d objetivo=%d exacta=%s epoch=%d" % [
			tick_host_ack,
			tick_client_ack,
			pausa_online_tick_objetivo,
			str(tick_host_ack == pausa_online_tick_objetivo and tick_client_ack == pausa_online_tick_objetivo),
			epoch
		])
		_intentar_reanudar_online()


func solicitar_reanudar_online(epoch: int) -> void:
	if rol == "offline" or not hay_rival_conectado():
		return
	if epoch != pausa_online_epoch:
		return
	if es_host():
		pausa_online_reanudar_solicitado = true
		_intentar_reanudar_online()
	else:
		rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, "_rpc_solicitar_reanudar_online_cliente", epoch)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_solicitar_reanudar_online_cliente(epoch: int) -> void:
	if not es_host() or epoch != pausa_online_epoch:
		return
	var sender: int = multiplayer.get_remote_sender_id()
	if sender != rival_peer_id:
		return
	pausa_online_reanudar_solicitado = true
	_intentar_reanudar_online()


func _intentar_reanudar_online() -> void:
	if not es_host() or not pausa_online_reanudar_solicitado:
		return
	if not pausa_online_en_barrera:
		return
	var host_id: int = multiplayer.get_unique_id()
	if not pausa_online_ack_peers.has(host_id):
		return
	if rival_peer_id <= 0 or not pausa_online_ack_peers.has(rival_peer_id):
		return
	pausa_online_reanudar_solicitado = false
	pausa_online_reanudar_ack_peers.clear()
	print("[91.02.71-P14D3A] REANUDAR GO — epoch=%d demora=%dms tick=%d" % [
		pausa_online_epoch, PAUSA_ONLINE_REANUDAR_DEMORA_MS, pausa_online_tick_objetivo
	])
	rpc(
		"_rpc_reanudar_online",
		pausa_online_epoch,
		PAUSA_ONLINE_REANUDAR_DEMORA_MS
	)


@rpc("authority", "call_local", "reliable")
func _rpc_reanudar_online(epoch: int, demora_ms: int) -> void:
	if epoch != pausa_online_epoch:
		return
	pausa_online_reanudar.emit(epoch, maxi(demora_ms, 100))
	print("[91.02.71-P14D3A] REANUDAR PROGRAMADO — peer=%d epoch=%d demora=%dms" % [
		mi_peer_id(), epoch, demora_ms
	])


func confirmar_reanudacion_online(epoch: int, tick_reanudado: int) -> void:
	if rol == "offline" or epoch != pausa_online_epoch:
		return
	if es_host():
		_registrar_reanudacion_online(multiplayer.get_unique_id(), epoch, tick_reanudado)
	else:
		rpc_id(
			MultiplayerPeer.TARGET_PEER_SERVER,
			"_rpc_confirmar_reanudacion_online_cliente",
			epoch,
			tick_reanudado
		)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_confirmar_reanudacion_online_cliente(epoch: int, tick_reanudado: int) -> void:
	if not es_host() or epoch != pausa_online_epoch:
		return
	var sender: int = multiplayer.get_remote_sender_id()
	if sender != rival_peer_id:
		return
	_registrar_reanudacion_online(sender, epoch, tick_reanudado)


func _registrar_reanudacion_online(peer_id: int, epoch: int, tick_reanudado: int) -> void:
	if not es_host() or epoch != pausa_online_epoch:
		return
	pausa_online_reanudar_ack_peers[peer_id] = tick_reanudado
	var host_id: int = multiplayer.get_unique_id()
	if pausa_online_reanudar_ack_peers.has(host_id) and rival_peer_id > 0 and pausa_online_reanudar_ack_peers.has(rival_peer_id):
		var tick_host: int = int(pausa_online_reanudar_ack_peers[host_id])
		var tick_client: int = int(pausa_online_reanudar_ack_peers[rival_peer_id])
		print("[91.02.71-P14D3A] REANUDACION BARRERA OK — host=%d client=%d delta=%d epoch=%d" % [
			tick_host, tick_client, absi(tick_host - tick_client), epoch
		])

		# 91.02.72 — PASS 14D3B
		# 91.02.71 cerraba el ciclo sólo en el Host. El Client conservaba
		# pausa_online_tick_objetivo >= 0 y por eso una segunda solicitud
		# de PAUSA desde PC2 era descartada por pausa_online_en_curso().
		# El Host confirma ahora de forma fiable que la barrera de reanudación
		# terminó y ordena al Client limpiar SU estado de control.
		rpc_id(rival_peer_id, "_rpc_cerrar_ciclo_pausa_online", epoch)
		print("[91.02.72-P14D3B] PAUSA CICLO CERRADO — peer=%d rol=host epoch=%d" % [
			mi_peer_id(), epoch
		])
		_reset_pausa_online()


@rpc("authority", "call_remote", "reliable")
func _rpc_cerrar_ciclo_pausa_online(epoch: int) -> void:
	if not es_cliente():
		return
	if epoch != pausa_online_epoch:
		return
	print("[91.02.72-P14D3B] PAUSA CICLO CERRADO — peer=%d rol=client epoch=%d" % [
		mi_peer_id(), epoch
	])
	_reset_pausa_online()


func cancelar_pausa_online() -> void:
	_reset_pausa_online()
	pausa_online_cancelada.emit()


# -------------------- LOOPBACK QA / DOS DISPOSITIVOS EN UNA MISMA PC --------------------
func enviar_input_frames_loopback(tick: int, mascara_j1: int, mascara_j2: int) -> void:
	if not loopback_misma_pc or not es_host() or rival_peer_id <= 0:
		return
	rpc_id(rival_peer_id, "_rpc_recibir_input_frames_loopback", tick, mascara_j1, mascara_j2)


@rpc("authority", "call_remote", "reliable")
func _rpc_recibir_input_frames_loopback(tick: int, mascara_j1: int, mascara_j2: int) -> void:
	if not loopback_misma_pc or not es_cliente():
		return
	input_loopback_por_tick[str(tick)] = {
		"j1": mascara_j1,
		"j2": mascara_j2,
	}


func obtener_input_frames_loopback(tick: int) -> Dictionary:
	var clave: String = str(tick)
	if not input_loopback_por_tick.has(clave):
		return {"disponible": false, "j1": 0, "j2": 0}
	var paquete: Dictionary = input_loopback_por_tick[clave]
	return {
		"disponible": true,
		"j1": int(paquete.get("j1", 0)),
		"j2": int(paquete.get("j2", 0)),
	}


func descartar_inputs_loopback_anteriores_a(tick_minimo: int) -> void:
	var borrar: Array[String] = []
	for clave in input_loopback_por_tick.keys():
		if int(clave) < tick_minimo:
			borrar.append(str(clave))
	for clave in borrar:
		input_loopback_por_tick.erase(clave)


# -------------------- INPUT FRAMES DE COMBATE --------------------
# PASS 14D1 transporta exclusivamente intención compacta (máscara de 7 bits).
# No replica posiciones, vida, CORE ni sprites.
func enviar_input_frame(tick: int, mascara: int) -> void:
	if rol == "offline" or not hay_rival_conectado():
		return
	if es_host():
		if rival_peer_id > 0:
			rpc_id(rival_peer_id, "_rpc_recibir_input_frame", tick, mascara)
	else:
		rpc_id(MultiplayerPeer.TARGET_PEER_SERVER, "_rpc_recibir_input_frame", tick, mascara)


@rpc("any_peer", "call_remote", "reliable")
func _rpc_recibir_input_frame(tick: int, mascara: int) -> void:
	if rol == "offline":
		return
	var sender := multiplayer.get_remote_sender_id()
	if es_host():
		if sender != rival_peer_id:
			return
	else:
		if sender != MultiplayerPeer.TARGET_PEER_SERVER:
			return

	# 91.02.75: durante Main -> Resultado puede llegar algún datagrama ya en
	# vuelo. No debe llamar al callback de un Main que está saliendo del árbol.
	var escena_actual := get_tree().current_scene
	if escena_actual == null or escena_actual.scene_file_path != "res://scenes/Main.tscn":
		return

	var clave := str(tick)
	input_remoto_por_tick[clave] = mascara
	ultimo_tick_remoto_recibido = maxi(ultimo_tick_remoto_recibido, tick)
	paquetes_input_recibidos += 1
	input_remoto_recibido.emit(tick)


func obtener_input_remoto(tick: int) -> Dictionary:
	var clave := str(tick)
	if not input_remoto_por_tick.has(clave):
		return {
			"disponible": false,
			"mascara": 0,
		}
	return {
		"disponible": true,
		"mascara": int(input_remoto_por_tick[clave]),
	}


func descartar_inputs_remotos_anteriores_a(tick_minimo: int) -> void:
	var borrar: Array[String] = []
	for clave in input_remoto_por_tick.keys():
		if int(clave) < tick_minimo:
			borrar.append(str(clave))
	for clave in borrar:
		input_remoto_por_tick.erase(clave)


func _set_estado(nuevo: String) -> void:
	estado = nuevo
	estado_cambiado.emit(estado)
	print("[91.02.62-P14C] ONLINE — %s" % estado)
