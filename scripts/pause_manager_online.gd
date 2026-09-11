extends "res://scripts/pause_manager.gd"

# CORE AWAKENED 91.02.71 — PASS 14D3A / PAUSA ONLINE SINCRONIZADA
#
# LOCAL: conserva exactamente el PauseManager 90.10.32 original.
# ONLINE: ESC/START solicita al Host un tick futuro común; ambos peers pausan
# exactamente en ese mismo online_tick_simulacion. CONTINUAR usa una barrera
# fiable y una demora real breve antes de soltar ambos SceneTree.

var pausa_online_pendiente: bool = false
var pausa_online_tick_objetivo: int = -1
var pausa_online_epoch_local: int = 0
var reanudacion_online_programada: bool = false
var reanudacion_online_deadline_usec: int = 0
var reanudacion_online_esperando: bool = false

# 91.02.73 — PASS 14D3C / timeout de pausa online.
# En online nadie puede mantener una pelea detenida indefinidamente.
const PAUSA_ONLINE_MAX_SEGUNDOS := 60
var pausa_online_deadline_usec: int = 0
var pausa_online_timeout_disparado: bool = false
var pausa_online_label_tiempo: Label = null


func _ready() -> void:
	super()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_conectar_pausa_online()
	_reconectar_botones_virtuales()
	_crear_contador_pausa_online()


func _crear_contador_pausa_online() -> void:
	if panel_principal == null:
		return
	pausa_online_label_tiempo = Label.new()
	pausa_online_label_tiempo.name = "PauseOnlineCountdown"
	pausa_online_label_tiempo.position = Vector2(30, 94)
	pausa_online_label_tiempo.size = Vector2(510, 28)
	pausa_online_label_tiempo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pausa_online_label_tiempo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pausa_online_label_tiempo.add_theme_font_size_override("font_size", 14)
	pausa_online_label_tiempo.add_theme_color_override("font_color", Color(1.0, 0.72, 0.24))
	pausa_online_label_tiempo.visible = false
	pausa_online_label_tiempo.process_mode = Node.PROCESS_MODE_ALWAYS
	panel_principal.add_child(pausa_online_label_tiempo)


func _actualizar_contador_pausa_online() -> void:
	if pausa_online_label_tiempo == null:
		return
	if not pausa_activa or pausa_online_deadline_usec <= 0:
		pausa_online_label_tiempo.visible = false
		return

	pausa_online_label_tiempo.visible = true
	if reanudacion_online_programada or reanudacion_online_esperando:
		pausa_online_label_tiempo.text = "REANUDANDO PELEA..."
		return

	var restante_usec: int = maxi(0, pausa_online_deadline_usec - Time.get_ticks_usec())
	var restante_seg: int = int(ceili(float(restante_usec) / 1000000.0))
	var minutos: int = restante_seg / 60
	var segundos: int = restante_seg % 60
	pausa_online_label_tiempo.text = "PAUSA ONLINE  •  REANUDA AUTOMÁTICAMENTE EN %02d:%02d" % [
		minutos, segundos
	]


func _network_online() -> Node:
	return get_node_or_null("/root/NetworkManager")


func _es_online_activo() -> bool:
	if not _es_escena_combate():
		return false
	var red := _network_online()
	if red == null:
		return false
	var rol_actual: String = str(red.get("rol"))
	if rol_actual not in ["host", "client"]:
		return false
	if not red.has_method("hay_rival_conectado"):
		return false
	return bool(red.call("hay_rival_conectado"))


func _tick_online_actual() -> int:
	var escena := get_tree().current_scene
	if escena == null or escena.scene_file_path != ESCENA_COMBATE:
		return 0
	var valor = escena.get("online_tick_simulacion")
	if valor == null:
		return 0
	return int(valor)


func _conectar_pausa_online() -> void:
	var red := _network_online()
	if red == null:
		return
	if red.has_signal("pausa_online_programada"):
		var cb_programada := Callable(self, "_al_pausa_online_programada")
		if not red.is_connected("pausa_online_programada", cb_programada):
			red.connect("pausa_online_programada", cb_programada)
	if red.has_signal("pausa_online_reanudar"):
		var cb_reanudar := Callable(self, "_al_pausa_online_reanudar")
		if not red.is_connected("pausa_online_reanudar", cb_reanudar):
			red.connect("pausa_online_reanudar", cb_reanudar)
	if red.has_signal("pausa_online_cancelada"):
		var cb_cancelar := Callable(self, "_al_pausa_online_cancelada")
		if not red.is_connected("pausa_online_cancelada", cb_cancelar):
			red.connect("pausa_online_cancelada", cb_cancelar)
	if red.has_signal("rival_desconectado"):
		var cb_desconexion := Callable(self, "_al_rival_desconectado_online")
		if not red.is_connected("rival_desconectado", cb_desconexion):
			red.connect("rival_desconectado", cb_desconexion)


func _reconectar_boton(boton: Button, callback: Callable) -> void:
	for conexion in boton.pressed.get_connections():
		var existente: Callable = conexion.get("callable", Callable())
		if existente.is_valid() and boton.pressed.is_connected(existente):
			boton.pressed.disconnect(existente)
	boton.pressed.connect(callback)


func _reconectar_botones_virtuales() -> void:
	# Garantiza que los botones creados por la clase base llamen a las versiones
	# online de CONTINUAR/REINICIAR/MENÚ, sin depender de dispatch implícito.
	if botones_principales.size() >= 1:
		_reconectar_boton(botones_principales[0], Callable(self, "_continuar"))
	if botones_principales.size() >= 3:
		_reconectar_boton(botones_principales[2], Callable(self, "_reiniciar_pelea"))
	if botones_principales.size() >= 4:
		_reconectar_boton(botones_principales[3], Callable(self, "_volver_menu"))


func _input(event: InputEvent) -> void:
	if transicionando:
		return

	if not _es_online_activo():
		super(event)
		return

	if _es_evento_pausa(event):
		if pausa_activa or _es_escena_combate():
			get_viewport().set_input_as_handled()
			if pausa_activa:
				_continuar()
			elif not pausa_online_pendiente:
				_pausar()
		return

	# B / Circle conserva la semántica del menú original, pero CONTINUAR online
	# pasa siempre por la barrera de red.
	if pausa_activa and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if mostrando_opciones:
			_mostrar_menu_principal()
		else:
			_continuar()


func _process(_delta: float) -> void:
	if pausa_online_pendiente and not pausa_activa:
		var tick_actual: int = _tick_online_actual()
		if tick_actual >= pausa_online_tick_objetivo:
			_aplicar_pausa_online(tick_actual)

	if pausa_activa:
		_actualizar_contador_pausa_online()
		if (
			pausa_online_deadline_usec > 0
			and not pausa_online_timeout_disparado
			and not reanudacion_online_esperando
			and not reanudacion_online_programada
			and Time.get_ticks_usec() >= pausa_online_deadline_usec
		):
			pausa_online_timeout_disparado = true
			print("[91.02.73-P14D3C] PAUSA TIMEOUT 60S — peer=%d tick=%d epoch=%d" % [
				int(_network_online().call("mi_peer_id")) if _network_online() != null else -1,
				_tick_online_actual(),
				pausa_online_epoch_local
			])
			_continuar()

	if reanudacion_online_programada and pausa_activa:
		if Time.get_ticks_usec() >= reanudacion_online_deadline_usec:
			_aplicar_reanudacion_online()


func _pausar() -> void:
	if not _es_online_activo():
		super()
		return
	if pausa_activa or pausa_online_pendiente or not _es_escena_combate():
		return
	var red := _network_online()
	if red == null or not red.has_method("solicitar_pausa_online"):
		return
	var tick_actual: int = _tick_online_actual()
	print("[91.02.71-P14D3A] PAUSA LOCAL REQUEST — peer=%d tick=%d" % [
		int(red.call("mi_peer_id")), tick_actual
	])
	red.call("solicitar_pausa_online", tick_actual)


func _al_pausa_online_programada(epoch: int, tick_objetivo: int) -> void:
	if not _es_escena_combate():
		return
	pausa_online_epoch_local = epoch
	pausa_online_tick_objetivo = tick_objetivo
	pausa_online_pendiente = true
	reanudacion_online_programada = false
	reanudacion_online_esperando = false
	print("[91.02.71-P14D3A] PAUSA ARMADA UI — objetivo=%d epoch=%d tick_local=%d" % [
		tick_objetivo, epoch, _tick_online_actual()
	])


func _aplicar_pausa_online(tick_actual: int) -> void:
	if pausa_activa or not pausa_online_pendiente:
		return

	# El criterio de certificación es que ambos reporten EXACTAMENTE el objetivo.
	if tick_actual != pausa_online_tick_objetivo:
		print("[91.02.71-P14D3A] PAUSA TICK WARN — actual=%d objetivo=%d" % [
			tick_actual, pausa_online_tick_objetivo
		])

	pausa_online_pendiente = false
	pausa_activa = true
	mostrando_opciones = false
	pausa_online_timeout_disparado = false
	pausa_online_deadline_usec = Time.get_ticks_usec() + PAUSA_ONLINE_MAX_SEGUNDOS * 1000000
	panel_principal.visible = true
	panel_opciones.visible = false
	fondo.visible = true
	capa.visible = true

	_configurar_botones_online(true)

	var red := _network_online()
	if red != null and red.has_method("confirmar_pausa_online_aplicada"):
		# Se envía el ACK antes de congelar SceneTree.
		red.call(
			"confirmar_pausa_online_aplicada",
			pausa_online_epoch_local,
			tick_actual
		)

	get_tree().paused = true
	if not botones_principales.is_empty():
		botones_principales[0].grab_focus()

	print("[91.02.71-P14D3A] PAUSA APLICADA — tick=%d epoch=%d" % [
		tick_actual, pausa_online_epoch_local
	])
	print("[91.02.73-P14D3C] PAUSA LIMITE — peer=%d max=%ds epoch=%d" % [
		int(red.call("mi_peer_id")) if red != null else -1,
		PAUSA_ONLINE_MAX_SEGUNDOS,
		pausa_online_epoch_local
	])


func _continuar() -> void:
	if not _es_online_activo():
		super()
		return
	if not pausa_activa or reanudacion_online_esperando or reanudacion_online_programada:
		return

	var red := _network_online()
	if red == null or not red.has_method("solicitar_reanudar_online"):
		return

	reanudacion_online_esperando = true
	if not botones_principales.is_empty():
		botones_principales[0].text = "SINCRONIZANDO..."
		botones_principales[0].disabled = true

	print("[91.02.71-P14D3A] CONTINUAR REQUEST — peer=%d tick=%d epoch=%d" % [
		int(red.call("mi_peer_id")), _tick_online_actual(), pausa_online_epoch_local
	])
	red.call("solicitar_reanudar_online", pausa_online_epoch_local)


func _al_pausa_online_reanudar(epoch: int, demora_ms: int) -> void:
	if not pausa_activa or epoch != pausa_online_epoch_local:
		return
	reanudacion_online_esperando = false
	reanudacion_online_programada = true
	reanudacion_online_deadline_usec = Time.get_ticks_usec() + int(maxi(demora_ms, 100)) * 1000
	print("[91.02.71-P14D3A] REANUDAR COUNTDOWN — epoch=%d demora=%dms tick=%d" % [
		epoch, demora_ms, _tick_online_actual()
	])


func _aplicar_reanudacion_online() -> void:
	if not pausa_activa or not reanudacion_online_programada:
		return
	reanudacion_online_programada = false
	pausa_online_deadline_usec = 0
	pausa_online_timeout_disparado = false
	if pausa_online_label_tiempo != null:
		pausa_online_label_tiempo.visible = false

	var tick_reanudado: int = _tick_online_actual()
	pausa_activa = false
	mostrando_opciones = false
	capa.visible = false
	_configurar_botones_online(false)

	# Primero soltamos la simulación. El ACK sólo es diagnóstico y no gobierna
	# gameplay; el Input Delay + rollback 8T absorben una eventual diferencia
	# de un frame de scheduler entre máquinas.
	get_tree().paused = false

	var red := _network_online()
	if red != null and red.has_method("confirmar_reanudacion_online"):
		red.call(
			"confirmar_reanudacion_online",
			pausa_online_epoch_local,
			tick_reanudado
		)

	print("[91.02.71-P14D3A] REANUDADO — tick=%d epoch=%d" % [
		tick_reanudado, pausa_online_epoch_local
	])

	pausa_online_tick_objetivo = -1
	reanudacion_online_esperando = false


func _configurar_botones_online(en_pausa_online: bool) -> void:
	if botones_principales.size() >= 1:
		botones_principales[0].text = "CONTINUAR"
		botones_principales[0].disabled = false

	# Reiniciar pelea y volver al menú aún no tienen barrera online. Se bloquean
	# en este PASS para que no puedan destruir la sincronía certificada.
	if botones_principales.size() >= 3:
		botones_principales[2].disabled = en_pausa_online
		botones_principales[2].tooltip_text = (
			"Se sincronizará en el siguiente PASS online."
			if en_pausa_online else ""
		)
	if botones_principales.size() >= 4:
		botones_principales[3].disabled = en_pausa_online
		botones_principales[3].tooltip_text = (
			"Se sincronizará en el siguiente PASS online."
			if en_pausa_online else ""
		)


func _reiniciar_pelea() -> void:
	if _es_online_activo():
		print("[91.02.71-P14D3A] REINICIAR ONLINE BLOQUEADO — pendiente de revancha sincronizada")
		return
	super()


func _volver_menu() -> void:
	if _es_online_activo():
		print("[91.02.71-P14D3A] VOLVER MENU ONLINE BLOQUEADO — pendiente de salida sincronizada")
		return
	super()


func _al_pausa_online_cancelada() -> void:
	_limpiar_pausa_online_local(true)


func _al_rival_desconectado_online(_peer_id: int) -> void:
	# Nunca dejar una PC congelada si el rival se cae durante la pausa.
	_limpiar_pausa_online_local(true)


func _limpiar_pausa_online_local(forzar_reanudar: bool) -> void:
	pausa_online_pendiente = false
	pausa_online_tick_objetivo = -1
	pausa_online_deadline_usec = 0
	pausa_online_timeout_disparado = false
	if pausa_online_label_tiempo != null:
		pausa_online_label_tiempo.visible = false
	reanudacion_online_programada = false
	reanudacion_online_esperando = false
	reanudacion_online_deadline_usec = 0
	if forzar_reanudar and get_tree().paused:
		get_tree().paused = false
	pausa_activa = false
	mostrando_opciones = false
	if capa != null:
		capa.visible = false
	_configurar_botones_online(false)
