extends Node

# CORE AWAKENED 91.02.74 — PASS 14D4A / ONLINE RESULT FLOW
#
# Este bridge existe para NO reemplazar scripts/resultado.gd.
# En modo ONLINE detecta Resultado.tscn, intercepta REVANCHA/REINTENTAR/
# REPETIR PELEA y convierte ese botón en una aceptación sincronizada.
# Selección/Menú quedan bloqueados temporalmente hasta PASS 14D4B.

const RESULTADO_SCENE := "res://scenes/Resultado.tscn"

var escena_resultado_actual: Node = null
var boton_revancha: Button = null
var boton_selector: Button = null
var boton_menu: Button = null
var etiqueta_estado: Label = null
var hook_realizado: bool = false
var salida_en_curso: bool = false

# 91.02.76 — PASS 14D5B / DESCONEXIÓN SEGURA.
# Si un rival desaparece durante una sesión ya iniciada, la pelea no debe
# continuar con inputs neutrales ni quedar "congelada". Se termina la sesión
# local de forma controlada y se vuelve al menú.
const DESCONEXION_VOLVER_MENU_SEGUNDOS := 2.0
var desconexion_en_curso: bool = false
var desconexion_overlay: CanvasLayer = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_conectar_desconexion_global()


func _conectar_desconexion_global() -> void:
	var red := _network()
	if red == null:
		return
	if red.has_signal("rival_desconectado"):
		var cb := Callable(self, "_al_rival_desconectado_global")
		if not red.is_connected("rival_desconectado", cb):
			red.connect("rival_desconectado", cb)


func _escena_online_activa_para_desconexion() -> bool:
	if not _es_online():
		return false
	var escena := get_tree().current_scene
	if escena == null:
		return false
	var ruta: String = escena.scene_file_path
	return ruta in [
		"res://scenes/SelectorPersonajes.tscn",
		"res://scenes/PresentacionVS.tscn",
		"res://scenes/Main.tscn",
		"res://scenes/Resultado.tscn",
	]


func _al_rival_desconectado_global(peer_id: int) -> void:
	if desconexion_en_curso:
		return
	if not _escena_online_activa_para_desconexion():
		return

	desconexion_en_curso = true
	salida_en_curso = true

	# Es crítico liberar una pausa local antes de cambiar de escena. Esto cubre
	# también el caso donde el rival se desconecta mientras ambos están pausados.
	if get_tree().paused:
		get_tree().paused = false

	print("[91.02.76-P14D5B] ABANDONO DETECTADO — peer=%d escena=%s" % [
		peer_id,
		get_tree().current_scene.scene_file_path if get_tree().current_scene != null else "sin_escena"
	])

	_mostrar_overlay_desconexion()

	# Timer con process_always=true para que funcione incluso si la señal llegó
	# durante la transición de una pausa.
	var timer := get_tree().create_timer(
		DESCONEXION_VOLVER_MENU_SEGUNDOS,
		true,
		false,
		true
	)
	timer.timeout.connect(_cerrar_sesion_por_desconexion)


func _mostrar_overlay_desconexion() -> void:
	if is_instance_valid(desconexion_overlay):
		return

	desconexion_overlay = CanvasLayer.new()
	desconexion_overlay.name = "OnlineDisconnectOverlay"
	desconexion_overlay.layer = 500
	desconexion_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(desconexion_overlay)

	var raiz := Control.new()
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_STOP
	desconexion_overlay.add_child(raiz)

	var fondo := ColorRect.new()
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.color = Color(0.02, 0.02, 0.03, 0.88)
	fondo.mouse_filter = Control.MOUSE_FILTER_STOP
	raiz.add_child(fondo)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-270, -90)
	panel.size = Vector2(540, 180)
	raiz.add_child(panel)

	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 14)
	panel.add_child(caja)

	var titulo := Label.new()
	titulo.text = "RIVAL DESCONECTADO"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 28)
	caja.add_child(titulo)

	var detalle := Label.new()
	detalle.text = "La pelea terminó.\nVolviendo al menú principal..."
	detalle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detalle.add_theme_font_size_override("font_size", 17)
	caja.add_child(detalle)


func _cerrar_sesion_por_desconexion() -> void:
	if not desconexion_en_curso:
		return

	# Nunca dejamos el árbol pausado ni una escucha ENet huérfana.
	get_tree().paused = false

	var red := _network()
	if red != null and red.has_method("cerrar_conexion"):
		red.call("cerrar_conexion", false)

	var gs := get_node_or_null("/root/GameState")
	if gs != null and gs.has_method("volver_al_menu"):
		gs.call("volver_al_menu")

	print("[91.02.76-P14D5B] ABANDONO CIERRE OK — sesión cerrada; menú principal")

	if is_instance_valid(desconexion_overlay):
		desconexion_overlay.queue_free()
	desconexion_overlay = null

	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")

	# Se limpia después de pedir el cambio; si una segunda señal ENet residual
	# llega en este frame queda absorbida por el flag.
	call_deferred("_finalizar_desconexion_local")


func _finalizar_desconexion_local() -> void:
	desconexion_en_curso = false
	salida_en_curso = false


func _process(_delta: float) -> void:
	var escena := get_tree().current_scene
	if escena != escena_resultado_actual:
		escena_resultado_actual = escena
		hook_realizado = false
		boton_revancha = null
		boton_selector = null
		boton_menu = null
		etiqueta_estado = null
		if not desconexion_en_curso:
			salida_en_curso = false

	if desconexion_en_curso:
		return
	if hook_realizado:
		return
	if escena == null or escena.scene_file_path != RESULTADO_SCENE:
		return
	if not _es_online():
		return

	call_deferred("_armar_resultado_online")
	hook_realizado = true


func _es_online() -> bool:
	var gs := get_node_or_null("/root/GameState")
	if gs == null:
		return false
	if gs.has_method("es_online"):
		return bool(gs.call("es_online"))
	return str(gs.get("modo")) == "online"


func _network() -> Node:
	return get_node_or_null("/root/NetworkManager")


func _todos_los_botones(nodo: Node, salida: Array[Button]) -> void:
	for hijo in nodo.get_children():
		if hijo is Button:
			salida.append(hijo as Button)
		_todos_los_botones(hijo, salida)


func _desconectar_pressed(boton: Button) -> void:
	for conexion in boton.pressed.get_connections():
		var cb: Callable = conexion.get("callable", Callable())
		if cb.is_valid() and boton.pressed.is_connected(cb):
			boton.pressed.disconnect(cb)


func _armar_resultado_online() -> void:
	if not is_instance_valid(escena_resultado_actual):
		return
	if not _es_online():
		return

	var botones: Array[Button] = []
	_todos_los_botones(escena_resultado_actual, botones)

	for b in botones:
		var txt: String = b.text.strip_edges().to_upper()
		var es_revancha := (
			"REVANCHA" in txt
			or "REINTENTAR" in txt
			or "REPETIR" in txt
		)

		if es_revancha and boton_revancha == null:
			boton_revancha = b
			_desconectar_pressed(b)
			b.text = "REVANCHA"
			b.disabled = false
			b.pressed.connect(_solicitar_revancha)
			continue

		if ("SELECCIÓN" in txt or "SELECCION" in txt) and boton_selector == null:
			boton_selector = b
			_desconectar_pressed(b)
			b.disabled = false
			b.tooltip_text = ""
			b.pressed.connect(Callable(self, "_solicitar_salida").bind("selector"))
			continue

		if ("MENÚ" in txt or "MENU" in txt) and boton_menu == null:
			boton_menu = b
			_desconectar_pressed(b)
			b.disabled = false
			b.tooltip_text = ""
			b.pressed.connect(Callable(self, "_solicitar_salida").bind("menu"))

	etiqueta_estado = Label.new()
	etiqueta_estado.name = "OnlineRematchStatus"
	etiqueta_estado.position = Vector2(190, 625)
	etiqueta_estado.size = Vector2(900, 44)
	etiqueta_estado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta_estado.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiqueta_estado.add_theme_font_size_override("font_size", 17)
	etiqueta_estado.add_theme_color_override("font_color", Color(0.78, 0.82, 1.0))
	etiqueta_estado.text = "REVANCHA ONLINE • AMBOS JUGADORES DEBEN ACEPTAR"
	escena_resultado_actual.add_child(etiqueta_estado)

	var red := _network()
	if red != null:
		var cb_estado := Callable(self, "_al_revancha_estado")
		if red.has_signal("revancha_estado_actualizado") and not red.is_connected("revancha_estado_actualizado", cb_estado):
			red.connect("revancha_estado_actualizado", cb_estado)
		var cb_salida := Callable(self, "_al_salida_resultado_online")
		if red.has_signal("salida_resultado_online") and not red.is_connected("salida_resultado_online", cb_salida):
			red.connect("salida_resultado_online", cb_salida)

	if boton_revancha != null:
		boton_revancha.grab_focus()
		print("[91.02.74-P14D4A] RESULTADO ONLINE ARMADO — botón REVANCHA sincronizado")
	else:
		etiqueta_estado.text = "REVANCHA ONLINE NO DISPONIBLE — botón no localizado"
		print("[91.02.74-P14D4A] RESULTADO ONLINE WARN — no se encontró botón de revancha")


func _solicitar_revancha() -> void:
	if boton_revancha != null:
		boton_revancha.disabled = true
		boton_revancha.text = "ESPERANDO RIVAL..."
	if etiqueta_estado != null:
		etiqueta_estado.text = "REVANCHA SOLICITADA • ESPERANDO AL OTRO JUGADOR"

	var red := _network()
	if red != null and red.has_method("solicitar_revancha_online"):
		print("[91.02.74-P14D4A] REVANCHA LOCAL REQUEST — peer=%d" % int(red.call("mi_peer_id")))
		red.call("solicitar_revancha_online")


func _bloquear_acciones_resultado() -> void:
	for b in [boton_revancha, boton_selector, boton_menu]:
		if is_instance_valid(b):
			b.disabled = true


func _solicitar_salida(tipo: String) -> void:
	if salida_en_curso:
		return
	salida_en_curso = true
	_bloquear_acciones_resultado()

	var destino := tipo.strip_edges().to_lower()
	if etiqueta_estado != null:
		if destino == "selector":
			etiqueta_estado.text = "CAMBIANDO PERSONAJES • SINCRONIZANDO AMBAS PCs..."
		else:
			etiqueta_estado.text = "CERRANDO SESIÓN ONLINE..."

	var red := _network()
	if red != null and red.has_method("solicitar_salida_resultado_online"):
		print("[91.02.75-P14D4B] RESULTADO SALIDA LOCAL REQUEST — peer=%d tipo=%s" % [
			int(red.call("mi_peer_id")), destino
		])
		red.call("solicitar_salida_resultado_online", destino)


func _al_salida_resultado_online(tipo: String, epoch: int) -> void:
	if not is_instance_valid(escena_resultado_actual):
		return
	if escena_resultado_actual.scene_file_path != RESULTADO_SCENE:
		return

	salida_en_curso = true
	_bloquear_acciones_resultado()
	var destino := tipo.strip_edges().to_lower()
	print("[91.02.75-P14D4B] RESULTADO SALIDA APLICAR — tipo=%s epoch=%d" % [destino, epoch])

	if destino == "selector":
		if etiqueta_estado != null:
			etiqueta_estado.text = "ABRIENDO SELECCIÓN DE PERSONAJES..."
		call_deferred("_ir_selector_online")
	elif destino == "menu":
		if etiqueta_estado != null:
			etiqueta_estado.text = "RIVAL/SALA CERRANDO • VOLVIENDO AL MENÚ..."
		call_deferred("_ir_menu_online")


func _ir_selector_online() -> void:
	get_tree().change_scene_to_file("res://scenes/SelectorPersonajes.tscn")
	await get_tree().process_frame
	var red := _network()
	if red != null and red.has_method("finalizar_salida_resultado_online"):
		red.call("finalizar_salida_resultado_online")


func _ir_menu_online() -> void:
	# Da una fracción breve para que el RPC fiable de salida llegue a ambos
	# peers antes de que cada uno cierre su ENet local.
	await get_tree().create_timer(0.25, true, false, true).timeout

	var red := _network()
	if red != null and red.has_method("cerrar_conexion"):
		red.call("cerrar_conexion", false)

	var gs := get_node_or_null("/root/GameState")
	if gs != null and gs.has_method("volver_al_menu"):
		gs.call("volver_al_menu")

	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")


func _al_revancha_estado(host_listo: bool, client_listo: bool, epoch: int) -> void:
	if not is_instance_valid(escena_resultado_actual):
		return
	if escena_resultado_actual.scene_file_path != RESULTADO_SCENE:
		return

	var red := _network()
	var local_listo := false
	var rival_listo := false
	if red != null and bool(red.call("es_host")):
		local_listo = host_listo
		rival_listo = client_listo
	else:
		local_listo = client_listo
		rival_listo = host_listo

	if etiqueta_estado != null:
		if local_listo and rival_listo:
			etiqueta_estado.text = "REVANCHA CONFIRMADA • PREPARANDO COMBATE..."
		elif local_listo:
			etiqueta_estado.text = "VOS: LISTO • RIVAL: ESPERANDO"
		elif rival_listo:
			etiqueta_estado.text = "RIVAL QUIERE REVANCHA • PRESIONÁ REVANCHA"
		else:
			etiqueta_estado.text = "REVANCHA ONLINE • AMBOS JUGADORES DEBEN ACEPTAR"

	if boton_revancha != null and not local_listo:
		boton_revancha.disabled = false
		boton_revancha.text = "REVANCHA"

	print("[91.02.74-P14D4A] REVANCHA ESTADO — local=%s rival=%s epoch=%d" % [
		str(local_listo), str(rival_listo), epoch
	])
