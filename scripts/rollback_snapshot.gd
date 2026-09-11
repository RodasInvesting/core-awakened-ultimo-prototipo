class_name RollbackSnapshot
extends RefCounted

# 91.02.58 — PASS 13A / snapshot lógico del proyectil.
# El nodo no se serializa como referencia; se reconstruye desde estado puro.
const SCRIPT_PROYECTIL_ENERGIA = preload("res://scripts/proyectil_energia.gd")

# CORE AWAKENED 91.00.00-H10.2 — SNAPSHOT + RESTORE EN MEMORIA
# No guarda arte, audio ni nodos. Conserva exclusivamente estado lógico mutable
# necesario para poder volver a un punto de simulación. Esta primera fase usa
# una lista amplia y tolerante: si una propiedad no existe en un personaje,
# simplemente se ignora.

# 91.00.00-H10.2 — PerfectBlock90_1 es una segunda máquina de estado de combate.
# Lee input_frame_enrutado_actual y gobierna Combo Cancel/Counter/Back Dash.
# Si Fighter vuelve al pasado pero esta capa queda en el presente, un X/C
# histórico puede convertirse falsamente en un nuevo flanco.
const PROPIEDADES_TACTICAS: Array[StringName] = [
	&"_ventana_hasta", &"_counter_hasta", &"_counter_disponible", &"_vida_antes",
	&"_abajo_previo", &"_x_previo", &"_c_previo",
	&"_izquierda_previa", &"_derecha_previa",
	&"_ultimo_toque_izq", &"_ultimo_toque_der",
	&"_input_previo_por_id",
	&"_ultimo_toque_izq_por_id", &"_ultimo_toque_der_por_id",
	&"_backdash_timer", &"_backdash_direccion",
	&"_backdash_invuln_hasta", &"_backdash_cooldown_hasta",
	&"_combo_cancel_hasta", &"_combo_cancel_disponible",
	&"_combo_cancel_cadena", &"_combo_cancel_bloqueado_hasta",
	&"_launcher_armado_hasta", &"_launcher_cooldown_hasta",
	&"_air_combo_activo", &"_air_combo_hasta", &"_air_combo_golpes",
	&"_recovery_desde", &"_recovery_hasta", &"_recovery_cooldown_hasta",
	&"_arriba_previo",
	&"_ia_siguiente_decision", &"_ia_estado", &"_ia_presion",
	&"_ia_castigo_hasta", &"_ia_recovery_desde",
	&"_ia_recovery_hasta", &"_ia_recovery_cooldown_hasta",
	&"_combo_proteccion_hasta", &"_combo_buffer_ia_diferido",
	&"_rollback_counter_event_serial", &"_rollback_counter_event_fighter_id",
	&"_rollback_counter_event_tipo",
	&"_rollback_backdash_event_serial", &"_rollback_backdash_event_fighter_id",
	&"_rollback_backdash_event_direccion",
	&"_rollback_launcher_event_serial", &"_rollback_launcher_event_attacker_id",
	&"_rollback_launcher_event_defender_id",
	&"_rollback_airhit_event_serial", &"_rollback_airhit_event_attacker_id",
	&"_rollback_airhit_event_defender_id", &"_rollback_airhit_event_count",
	&"_rollback_tactical_clock_ticks", &"_rollback_tactical_clock_seconds",
	&"_scan_timer",
]

const TACTICAS_DEADLINE_DICT: Array[StringName] = [
	&"_ventana_hasta", &"_counter_hasta",
	&"_ultimo_toque_izq_por_id", &"_ultimo_toque_der_por_id",
	&"_backdash_invuln_hasta", &"_backdash_cooldown_hasta",
	&"_combo_cancel_hasta", &"_combo_cancel_bloqueado_hasta",
	&"_launcher_armado_hasta", &"_launcher_cooldown_hasta",
	&"_air_combo_hasta",
	&"_recovery_desde", &"_recovery_hasta", &"_recovery_cooldown_hasta",
	&"_ia_siguiente_decision", &"_ia_castigo_hasta",
	&"_ia_recovery_desde", &"_ia_recovery_hasta", &"_ia_recovery_cooldown_hasta",
	&"_combo_proteccion_hasta",
]

const TACTICAS_DEADLINE_SCALAR: Array[StringName] = [
	&"_ultimo_toque_izq", &"_ultimo_toque_der",
]

const TACTICAS_LOGICAS_CHECKSUM: Array[StringName] = [
	&"_rollback_tactical_clock_ticks", &"_rollback_tactical_clock_seconds",
	&"_ventana_hasta", &"_counter_hasta", &"_counter_disponible", &"_vida_antes",
	&"_abajo_previo", &"_x_previo", &"_c_previo",
	&"_izquierda_previa", &"_derecha_previa",
	&"_ultimo_toque_izq", &"_ultimo_toque_der",
	&"_input_previo_por_id",
	&"_ultimo_toque_izq_por_id", &"_ultimo_toque_der_por_id",
	&"_backdash_timer", &"_backdash_direccion",
	&"_backdash_invuln_hasta", &"_backdash_cooldown_hasta",
	&"_combo_cancel_hasta", &"_combo_cancel_disponible",
	&"_combo_cancel_cadena", &"_combo_cancel_bloqueado_hasta",
	&"_launcher_armado_hasta", &"_launcher_cooldown_hasta",
	&"_air_combo_activo", &"_air_combo_hasta", &"_air_combo_golpes",
	&"_recovery_desde", &"_recovery_hasta", &"_recovery_cooldown_hasta",
	&"_arriba_previo",
	&"_ia_siguiente_decision", &"_ia_estado", &"_ia_presion",
	&"_ia_castigo_hasta", &"_ia_recovery_desde",
	&"_ia_recovery_hasta", &"_ia_recovery_cooldown_hasta",
	&"_combo_proteccion_hasta", &"_combo_buffer_ia_diferido",
	&"_rollback_counter_event_serial", &"_rollback_counter_event_fighter_id",
	&"_rollback_counter_event_tipo",
	&"_rollback_backdash_event_serial", &"_rollback_backdash_event_fighter_id",
	&"_rollback_backdash_event_direccion",
	&"_rollback_launcher_event_serial", &"_rollback_launcher_event_attacker_id",
	&"_rollback_launcher_event_defender_id",
	&"_rollback_airhit_event_serial", &"_rollback_airhit_event_attacker_id",
	&"_rollback_airhit_event_defender_id", &"_rollback_airhit_event_count",
]

const PROPIEDADES_FIGHTER: Array[StringName] = [
	&"position", &"velocity",
	&"vida", &"poder", &"veces_fase_absoluta", &"mirando",
	&"fase_ataque", &"timer_fase_ataque", &"_atk_ya_conecto", &"_atk_tipo",
	&"hitstun_timer", &"hitstop_timer",
	&"empuje_timer", &"empuje_x",
	&"empuje_pendiente_timer", &"empuje_pendiente_direccion",
	&"empuje_pendiente_fuerza", &"absorcion_impacto_timer",
	&"contacto_post_golpe_timer", &"contacto_post_golpe_distancia",
	&"recuperacion_post_levantada_timer",
	&"bloqueando", &"bloqueo_timer",
	&"combo_count", &"combo_timer",
	&"en_secuencia_especial", &"bloqueo_cinematico",
	&"congelado_por_rival", &"reloj_seguridad_secuencia",
	&"core1_target_lock_activo", &"core1_target_lock_origen",
	&"core1_target_lock_destino", &"core1_target_lock_duracion",
	&"core1_target_lock_tiempo",
	&"core1_secuencia_etapa", &"core1_poster_timer", &"core1_poster_duracion",
	&"core2_secuencia_etapa", &"core2_recarga_timer", &"core2_recarga_duracion",
	&"core2_acercamiento_origen", &"core2_acercamiento_destino",
	&"core2_acercamiento_duracion", &"core2_acercamiento_tiempo",
	&"core2_combo_paso_idx", &"core2_combo_total_pasos", &"core2_combo_subfase",
	&"core2_combo_acercamiento_origen", &"core2_combo_acercamiento_destino",
	&"core2_combo_acercamiento_duracion", &"core2_combo_acercamiento_tiempo",
	&"core2_rematador_subfase", &"core2_rematador_timer", &"core2_rematador_duracion",
	&"core2_rematador_puede_conectar", &"core2_rematador_bloqueado",
	&"core2_rematador_direccion",
	&"core3_secuencia_etapa", &"core3_recarga_timer", &"core3_recarga_duracion",
	&"core3_recarga_primer_tick",
	&"core3_acercamiento_origen", &"core3_acercamiento_destino",
	&"core3_acercamiento_duracion", &"core3_acercamiento_tiempo",
	&"core3_primer_beat_subfase",
	&"core3_primer_beat_acercamiento_origen", &"core3_primer_beat_acercamiento_destino",
	&"core3_primer_beat_acercamiento_duracion", &"core3_primer_beat_acercamiento_tiempo",
	&"en_pose_victoria", &"en_fase_absoluta",
	&"derribo_especial_activo",
	&"carrera_activa", &"carrera_direccion",
	&"carrera_inicio_timer", &"carrera_frenado_timer",
	&"carrera_humo_timer",
	&"dash_aereo_activo", &"dash_aereo_direccion",
	&"dash_aereo_timer", &"dash_aereo_usado",
	&"doble_pulso_izq_timer", &"doble_pulso_der_timer",
	&"tecla_izq_previa", &"tecla_der_previa",
	&"z_estaba_presionado", &"salto_estaba_presionado",
	&"gamepad_salto_previo",
	&"en_el_aire", &"saltos_usados", &"cruce_aereo_activo",
	&"asentamiento_aterrizaje",
	&"indice_punetazo", &"indice_patada", &"indice_golpe_recibido",
	&"_reaccion_impacto_timer", &"_reaccion_impacto_direccion",
	&"_reaccion_impacto_fuerza",
	&"impacto_visual_y", &"seguimiento_ataque_x",
	&"nivel_impacto_actual", &"anticipacion_ataque_x",
	&"fuente_control", &"controlado_por_jugador",
	&"jugador_local_indice", &"gamepad_asignado_id",
	&"teclado_local_habilitado",
	&"input_frame_externo", &"input_externo_disponible",
	&"input_frame_enrutado_actual",
	&"dash_iniciado_este_frame", &"ultima_intencion_horizontal",
	&"puno_estaba_presionado", &"patada_estaba_presionada",
	&"ataque_buffer_tipo", &"ataque_buffer_timer",
	# 91.02.58 — estado mutable del comando/lanzamiento del proyectil.
	&"comando_proyectil_etapa", &"comando_proyectil_timer",
	&"en_lanzamiento_proyectil", &"proyectil_lanzamiento_timer",
	&"proyectil_spawn_timer", &"proyectil_disparo_pendiente",
	&"proyectil_cooldown_timer",
	&"fase_timer", &"pose_timer", &"en_pose_recarga", &"en_combo_auto_visual",
	&"esta_derrotado", &"guardia_escape_esquina_cooldown",
	&"derribo_especial_esperando_aterrizar", &"derribo_especial_se_levanta",
	&"derribo_especial_timer", &"derribo_especial_rebote_muro_usado",
	&"derribo_especial_deslizando", &"derribo_especial_tiempo_deslizamiento",
	&"_atk_rango", &"_atk_dano", &"_atk_empuje_base", &"_atk_hitstun",
	&"_atk_dur_activo", &"_atk_dur_recovery",
	&"_estaba_en_aire", &"ultima_direccion_movimiento",
	&"indice_caminata", &"ciclo_caminata", &"ciclo_reposo",
	&"paso_timer", &"paso_fase", &"ultima_velocidad_x",
	&"escala_actual", &"sprite_base_y", &"flash_timer",
]

static func _duplicar_valor(valor: Variant) -> Variant:
	if typeof(valor) == TYPE_DICTIONARY:
		return (valor as Dictionary).duplicate(true)
	if typeof(valor) == TYPE_ARRAY:
		return (valor as Array).duplicate(true)
	return valor

static func _mapa_propiedades(objeto: Object) -> Dictionary:
	var salida: Dictionary = {}
	if objeto == null:
		return salida
	for info in objeto.get_property_list():
		var nombre := StringName(str(info.get("name", "")))
		if nombre != StringName():
			salida[nombre] = true
	return salida

static func capturar_fighter(personaje: Object) -> Dictionary:
	var estado: Dictionary = {}
	if personaje == null:
		return estado
	var disponibles := _mapa_propiedades(personaje)
	for nombre in PROPIEDADES_FIGHTER:
		if disponibles.has(nombre):
			estado[str(nombre)] = _duplicar_valor(personaje.get(nombre))
	# 91.00.00-H10.2 — CharacterBody2D mantiene contactos (floor/wall/ceiling)
	# dentro del motor después de move_and_slide(). No aparecen en get_property_list(),
	# por eso los guardamos como estado derivado de diagnóstico.
	if personaje is CharacterBody2D:
		var body := personaje as CharacterBody2D
		estado["__on_floor"] = body.is_on_floor()
		estado["__on_wall"] = body.is_on_wall()
		estado["__on_ceiling"] = body.is_on_ceiling()
		estado["__last_motion"] = body.get_last_motion()
		estado["__real_velocity"] = body.get_real_velocity()
		estado["__floor_normal"] = body.get_floor_normal()

	# 91.00.00-H10.2 — el pushbox contextual usa sprite.texture + sprite.scale
	# para estimar radio corporal. No es "arte decorativo" solamente: por eso
	# el rollback debe devolver también esta parte de la presentación histórica.
	var sprite_obj = personaje.get("sprite") if disponibles.has(&"sprite") else null
	if sprite_obj is Sprite2D:
		var spr := sprite_obj as Sprite2D
		estado["__sprite_texture_path"] = spr.texture.resource_path if spr.texture else ""
		estado["__sprite_scale"] = spr.scale
		estado["__sprite_position"] = spr.position
		estado["__sprite_rotation"] = spr.rotation
		estado["__sprite_flip_h"] = spr.flip_h
		estado["__sprite_visible"] = spr.visible
		estado["__sprite_modulate"] = spr.modulate
	return estado

static func _restaurar_estado_visual_pushbox(personaje: Object, estado: Dictionary) -> void:
	if personaje == null or estado.is_empty():
		return
	var disponibles := _mapa_propiedades(personaje)
	var sprite_obj = personaje.get("sprite") if disponibles.has(&"sprite") else null
	if not (sprite_obj is Sprite2D):
		return
	var spr := sprite_obj as Sprite2D
	var ruta: String = str(estado.get("__sprite_texture_path", ""))

	# H10.64 — RESTORE VISUAL SIN MUTAR SIMULACIÓN.
	# Fighter._actualizar_textura() también recalcula el pushbox y, desde
	# 90.10.72, puede llamar _separar_ganador_del_ko(). Eso es correcto LIVE,
	# pero durante rollback una restauración visual NO puede mover el cuerpo ni
	# cambiar su orientación. Preservamos explícitamente los tres valores que
	# esa ruta puede mutar y los reponemos después de reconstruir pose/pushbox.
	var body: CharacterBody2D = personaje as CharacterBody2D if personaje is CharacterBody2D else null
	var posicion_simulacion := body.position if body != null else Vector2.ZERO
	var velocidad_simulacion := body.velocity if body != null else Vector2.ZERO
	var mirando_simulacion = personaje.get("mirando") if disponibles.has(&"mirando") else null

	# 91.00.00-H: cambiar sólo Sprite2D.texture no reconstruía escala_actual,
	# sprite_base_y ni la caja que Fighter deriva de una pose. Usamos la propia
	# API de Fighter para que el estado visual que puede alimentar pushbox quede
	# internamente coherente con el snapshot.
	if not ruta.is_empty() and ResourceLoader.exists(ruta):
		var tex = load(ruta)
		if tex is Texture2D:
			if personaje.has_method("_actualizar_textura"):
				personaje.call("_actualizar_textura", tex)
			else:
				spr.texture = tex

	# H10.64 — cualquier side effect físico de _actualizar_textura queda fuera
	# del restore. La fotografía histórica manda de forma absoluta.
	if body != null:
		body.position = posicion_simulacion
		body.velocity = velocidad_simulacion
	if mirando_simulacion != null and disponibles.has(&"mirando"):
		personaje.set(&"mirando", mirando_simulacion)

	# Después de normalizar la pose, recuperar exactamente los offsets visuales
	# del instante histórico. Estos valores NO mueven CharacterBody2D.
	if estado.has("__sprite_scale"):
		spr.scale = estado["__sprite_scale"]
	if estado.has("__sprite_position"):
		spr.position = estado["__sprite_position"]
	if estado.has("__sprite_rotation"):
		spr.rotation = float(estado["__sprite_rotation"])
	if estado.has("__sprite_flip_h"):
		spr.flip_h = bool(estado["__sprite_flip_h"])
	if estado.has("__sprite_visible"):
		spr.visible = bool(estado["__sprite_visible"])
	if estado.has("__sprite_modulate"):
		spr.modulate = estado["__sprite_modulate"]

	# escala_actual/sprite_base_y son valores derivados que sí pueden alimentar
	# presentación y radio visual contextual. Reponerlos al final garantiza que
	# coincidan con la fotografía aunque haya assets con calibración especial.
	if estado.has("escala_actual") and disponibles.has(&"escala_actual"):
		personaje.set(&"escala_actual", estado["escala_actual"])
	if estado.has("sprite_base_y") and disponibles.has(&"sprite_base_y"):
		personaje.set(&"sprite_base_y", estado["sprite_base_y"])

static func _rehidratar_contacto_nativo(personaje: Object, estado: Dictionary) -> void:
	if not (personaje is CharacterBody2D):
		return
	var body := personaje as CharacterBody2D
	var pos_objetivo: Vector2 = body.position
	var vel_objetivo: Vector2 = body.velocity
	var mascara_objetivo: int = body.collision_mask
	var esperaba_piso: bool = bool(estado.get("__on_floor", false))

	# 91.00.00-H10.2 — la micro-sonda move_and_slide() de G3-G6 podía dejar un
	# recovery nativo lateral que get_last_motion() no informa. Eso explica los
	# desplazamientos externos de ±8.666 px observados en G6 aun con input=0.
	#
	# En piso usamos apply_floor_snap(), que reconstruye el contacto sin inyectar
	# una velocidad horizontal. En aire limpiamos el cache con una sonda SIN
	# colisiones (mask=0), de modo que nunca pueda resolver penetraciones X.
	if esperaba_piso:
		body.apply_floor_snap()
	else:
		body.collision_mask = 0
		body.velocity = Vector2(0.0, -0.01)
		body.move_and_slide()
		body.collision_mask = mascara_objetivo

	# La rehidratación sólo sirve para caches nativos; transform y velocidad
	# pertenecen exclusivamente al snapshot.
	body.position = pos_objetivo
	body.velocity = vel_objetivo
	body.collision_mask = mascara_objetivo

static func _aplicar_estado_fighter_sin_sonda(personaje: Object, estado: Dictionary) -> void:
	if personaje == null or estado.is_empty():
		return
	var disponibles := _mapa_propiedades(personaje)
	if estado.has("position") and disponibles.has(&"position"):
		personaje.set(&"position", _duplicar_valor(estado["position"]))
	for clave in estado.keys():
		if clave == "position" or str(clave).begins_with("__"):
			continue
		var nombre := StringName(str(clave))
		if disponibles.has(nombre):
			personaje.set(nombre, _duplicar_valor(estado[clave]))

static func restaurar_fighter(personaje: Object, estado: Dictionary) -> void:
	# Compatibilidad para usos aislados (F9/F10). La restauración de partida
	# usa una ruta de DOS FASES para evitar que un Fighter haga su sonda física
	# mientras el rival todavía permanece en la posición del presente.
	_aplicar_estado_fighter_sin_sonda(personaje, estado)
	_rehidratar_contacto_nativo(personaje, estado)
	# La sonda puede modificar position/velocity: reponemos el estado exacto.
	_aplicar_estado_fighter_sin_sonda(personaje, estado)
	_restaurar_estado_visual_pushbox(personaje, estado)
	if personaje != null and personaje.has_method("reset_physics_interpolation"):
		personaje.call("reset_physics_interpolation")

static func _nodo_tactico(main: Object) -> Object:
	if main == null or not (main is Node):
		return null
	return (main as Node).get_node_or_null("/root/PerfectBlock90_1")

static func capturar_tactico(main: Object) -> Dictionary:
	var nodo := _nodo_tactico(main)
	if nodo == null:
		return {}
	var disponibles := _mapa_propiedades(nodo)
	var estado: Dictionary = {}
	for nombre in PROPIEDADES_TACTICAS:
		if disponibles.has(nombre):
			estado[str(nombre)] = _duplicar_valor(nodo.get(nombre))
	return estado


static func restaurar_tactico(main: Object, estado: Dictionary) -> void:
	if estado.is_empty():
		return
	var nodo := _nodo_tactico(main)
	if nodo == null:
		return

	# H4: reloj y deadlines pertenecen a la simulación. Se restauran EXACTOS.
	# Ya no hay compensación contra Time.get_ticks_msec().
	var disponibles := _mapa_propiedades(nodo)
	for nombre in PROPIEDADES_TACTICAS:
		var clave := str(nombre)
		if estado.has(clave) and disponibles.has(nombre):
			nodo.set(nombre, _duplicar_valor(estado[clave]))


static func _tactico_logico(estado: Dictionary) -> Dictionary:
	var salida: Dictionary = {}
	for nombre in TACTICAS_LOGICAS_CHECKSUM:
		var clave := str(nombre)
		if estado.has(clave):
			salida[clave] = _duplicar_valor(estado[clave])
	return salida

# 91.02.58 — El proyectil es una entidad de simulación separada del Fighter.
# Como sólo puede existir uno por atacante, basta una fotografía por lado.
static func capturar_proyectil(personaje: Object) -> Dictionary:
	var inactivo := {"activo": false}
	if personaje == null:
		return inactivo

	var props_fighter := _mapa_propiedades(personaje)
	if not props_fighter.has(&"proyectil_activo"):
		return inactivo

	var nodo = personaje.get(&"proyectil_activo")
	if not is_instance_valid(nodo) or not (nodo is Node2D):
		return inactivo

	var props := _mapa_propiedades(nodo)
	if props.has(&"terminado") and bool(nodo.get(&"terminado")):
		return inactivo

	return {
		"activo": true,
		"global_position": (nodo as Node2D).global_position,
		"direccion": float(nodo.get(&"direccion")) if props.has(&"direccion") else 1.0,
		"velocidad": float(nodo.get(&"velocidad")) if props.has(&"velocidad") else 720.0,
		"dano": float(nodo.get(&"dano")) if props.has(&"dano") else 3.0,
		"empuje": float(nodo.get(&"empuje")) if props.has(&"empuje") else 148.0,
		"hitstun": float(nodo.get(&"hitstun")) if props.has(&"hitstun") else 0.22,
		"vida_restante": float(nodo.get(&"vida_restante")) if props.has(&"vida_restante") else 0.0,
	}


static func _retirar_proyectil_actual(personaje: Object) -> void:
	if personaje == null:
		return
	var props := _mapa_propiedades(personaje)
	if not props.has(&"proyectil_activo"):
		return

	var actual = personaje.get(&"proyectil_activo")
	if is_instance_valid(actual):
		# No usamos _terminar(): durante restore no debe existir impacto,
		# notificación ni presentación. Sólo retiramos la entidad futura.
		if actual.has_method("set_physics_process"):
			actual.call("set_physics_process", false)
		var props_actual := _mapa_propiedades(actual)
		if props_actual.has(&"terminado"):
			actual.set(&"terminado", true)
		if actual is Node:
			(actual as Node).queue_free()

	personaje.set(&"proyectil_activo", null)


static func restaurar_proyectil(main: Object, atacante: Object, objetivo: Object, estado: Dictionary) -> void:
	_retirar_proyectil_actual(atacante)

	if estado.is_empty() or not bool(estado.get("activo", false)):
		return
	if atacante == null or objetivo == null:
		return
	if not (main is Node):
		return

	var arbol := (main as Node).get_tree()
	if arbol == null or arbol.current_scene == null:
		return

	var props_atacante := _mapa_propiedades(atacante)
	var nodo = SCRIPT_PROYECTIL_ENERGIA.new()

	var color_primario: Color = atacante.get(&"color_proyectil_primario") if props_atacante.has(&"color_proyectil_primario") else Color(1.0, 0.1, 0.7, 1.0)
	var color_secundario: Color = atacante.get(&"color_proyectil_secundario") if props_atacante.has(&"color_proyectil_secundario") else Color(1.0, 0.85, 0.98, 1.0)
	var textura = atacante.get(&"textura_proyectil_nucleo") if props_atacante.has(&"textura_proyectil_nucleo") else null

	# Audio = null deliberadamente: restaurar una fotografía histórica no puede
	# volver a reproducir el sonido de salida.
	nodo.configurar(
		atacante,
		objetivo,
		float(estado.get("direccion", 1.0)),
		float(estado.get("velocidad", 720.0)),
		float(estado.get("dano", 3.0)),
		float(estado.get("empuje", 148.0)),
		float(estado.get("hitstun", 0.22)),
		color_primario,
		color_secundario,
		textura,
		null
	)

	arbol.current_scene.add_child(nodo)
	nodo.global_position = estado.get("global_position", Vector2.ZERO)
	nodo.vida_restante = float(estado.get("vida_restante", 0.0))
	nodo.terminado = false
	atacante.set(&"proyectil_activo", nodo)

	if nodo.has_method("reset_physics_interpolation"):
		nodo.call("reset_physics_interpolation")

	# 91.02.60 — PASS 13C / SCHEDULER ALIGN DEL PROYECTIL.
	# Evidencia runtime 91.02.59: al reconstruir el nodo dentro del _physics_process
	# de Main, Godot no lo incluye en el scheduler de ESE MISMO physics frame.
	# Resultado: queda exactamente 1 tick atrasado (805/60 = 13.4167 px y
	# vida_restante +1/60), y el impacto/CORE/bloqueo ocurre un tick tarde.
	#
	# Sólo durante el arnés F11 de PROYECTIL reponemos ese primer tick perdido
	# con call_deferred: se ejecuta DESPUÉS de los Fighter del subtick histórico
	# y ANTES del siguiente physics tick, reproduciendo el orden LIVE:
	# Main -> Fighters -> Proyectil. F9/F10 y todo rollback certificado previo
	# quedan fuera de esta compensación.
	var props_main := _mapa_propiedades(main)
	var clase_rb := str(main.get(&"rollback_h_clasificacion")) if props_main.has(&"rollback_h_clasificacion") else ""
	if clase_rb.begins_with("PROYECTIL"):
		var hz := maxf(float(Engine.physics_ticks_per_second), 1.0)
		var delta_historico := (1.0 / hz) * float(Engine.time_scale)
		nodo.call_deferred("_physics_process", delta_historico)


static func capturar_partida(main: Object, j1: Object, j2: Object) -> Dictionary:
	var snapshot := {
		"build": "91.00.00-H",
		"time_scale": Engine.time_scale,
		"rondas_j1": int(main.get("rondas_kai")),
		"rondas_j2": int(main.get("rondas_rival")),
		"ronda_activa": bool(main.get("ronda_activa")),
		"congelando_ko": bool(main.get("congelando_ko")),
		# H10.60 — único timer Main probado por runtime como no rebobinable.
		"core3_absolute_reveal_fsm_activo": bool(main.get("core3_absolute_reveal_fsm_activo")),
		"core3_absolute_reveal_timer": float(main.get("core3_absolute_reveal_timer")),
		"core3_absolute_reveal_lado": int(main.get("core3_absolute_reveal_lado")),
		# H10.62 — espera 0.70 s hasta _derrotado(), probada no rebobinable en H10.61.
		"core3_absolute_ko_fsm_activo": bool(main.get("core3_absolute_ko_fsm_activo")),
		"core3_absolute_ko_timer": float(main.get("core3_absolute_ko_timer")),
		"core3_absolute_ko_lado": int(main.get("core3_absolute_ko_lado")),
		# H10.65 — espera física 0.65 s hasta ABSOLUTE VICTORY ENTRY.
		"core3_absolute_victory_fsm_activo": bool(main.get("core3_absolute_victory_fsm_activo")),
		"core3_absolute_victory_timer": float(main.get("core3_absolute_victory_timer")),
		"core3_absolute_victory_lado": int(main.get("core3_absolute_victory_lado")),
		"j1": capturar_fighter(j1),
		"j2": capturar_fighter(j2),
		# Entidades de vuelo separadas del Fighter.
		"proyectil_j1": capturar_proyectil(j1),
		"proyectil_j2": capturar_proyectil(j2),
		"tactico": capturar_tactico(main),
	}
	var replay = main.get("input_replay")
	if replay != null:
		snapshot["replay_tick"] = int(replay.get("tick_actual"))
	return snapshot

static func restaurar_partida(main: Object, j1: Object, j2: Object, snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return
	Engine.time_scale = float(snapshot.get("time_scale", 1.0))
	main.set("rondas_kai", int(snapshot.get("rondas_j1", main.get("rondas_kai"))))
	main.set("rondas_rival", int(snapshot.get("rondas_j2", main.get("rondas_rival"))))
	main.set("ronda_activa", bool(snapshot.get("ronda_activa", main.get("ronda_activa"))))
	main.set("congelando_ko", bool(snapshot.get("congelando_ko", main.get("congelando_ko"))))
	# H10.60 — restauración exacta del reveal físico Main.
	main.set("core3_absolute_reveal_fsm_activo", bool(snapshot.get("core3_absolute_reveal_fsm_activo", main.get("core3_absolute_reveal_fsm_activo"))))
	main.set("core3_absolute_reveal_timer", float(snapshot.get("core3_absolute_reveal_timer", main.get("core3_absolute_reveal_timer"))))
	main.set("core3_absolute_reveal_lado", int(snapshot.get("core3_absolute_reveal_lado", main.get("core3_absolute_reveal_lado"))))
	# H10.62 — restauración exacta de la espera física hasta el K.O. absoluto.
	main.set("core3_absolute_ko_fsm_activo", bool(snapshot.get("core3_absolute_ko_fsm_activo", main.get("core3_absolute_ko_fsm_activo"))))
	main.set("core3_absolute_ko_timer", float(snapshot.get("core3_absolute_ko_timer", main.get("core3_absolute_ko_timer"))))
	main.set("core3_absolute_ko_lado", int(snapshot.get("core3_absolute_ko_lado", main.get("core3_absolute_ko_lado"))))
	# H10.65 — restauración exacta de la espera física hasta entrada de victoria.
	main.set("core3_absolute_victory_fsm_activo", bool(snapshot.get("core3_absolute_victory_fsm_activo", main.get("core3_absolute_victory_fsm_activo"))))
	main.set("core3_absolute_victory_timer", float(snapshot.get("core3_absolute_victory_timer", main.get("core3_absolute_victory_timer"))))
	main.set("core3_absolute_victory_lado", int(snapshot.get("core3_absolute_victory_lado", main.get("core3_absolute_victory_lado"))))

	# PerfectBlock90_1 es autoload y procesa antes que Main. El snapshot se tomó
	# DESPUÉS de su tick y ANTES de los Fighter. Restaurarlo acá recrea exactamente
	# esa misma frontera temporal.
	restaurar_tactico(main, snapshot.get("tactico", {}))

	var e1: Dictionary = snapshot.get("j1", {})
	var e2: Dictionary = snapshot.get("j2", {})

	# 91.00.00-H10.2 — RESTORE EN DOS FASES.
	# Fase A: colocar AMBOS Fighter exactamente en el mismo instante histórico.
	_aplicar_estado_fighter_sin_sonda(j1, e1)
	_aplicar_estado_fighter_sin_sonda(j2, e2)
	_restaurar_estado_visual_pushbox(j1, e1)
	_restaurar_estado_visual_pushbox(j2, e2)

	# Fase B: recién ahora reconstruir los caches nativos de CharacterBody2D.
	# Ninguna sonda ve al rival en la posición futura previa al rollback.
	_rehidratar_contacto_nativo(j1, e1)
	_rehidratar_contacto_nativo(j2, e2)

	# Fase C: las sondas sólo sirven para el cache nativo. El estado lógico y
	# transform exactos se vuelven a imponer después de AMBAS sondas.
	_aplicar_estado_fighter_sin_sonda(j1, e1)
	_aplicar_estado_fighter_sin_sonda(j2, e2)
	_restaurar_estado_visual_pushbox(j1, e1)
	_restaurar_estado_visual_pushbox(j2, e2)

	if j1 != null and j1.has_method("reset_physics_interpolation"):
		j1.call("reset_physics_interpolation")
	if j2 != null and j2.has_method("reset_physics_interpolation"):
		j2.call("reset_physics_interpolation")

	# 91.02.58 — recién con AMBOS Fighter ya restaurados reconciliamos las
	# entidades de proyectil. Así hurtbox/objetivo y punteros pertenecen al
	# mismo instante histórico.
	restaurar_proyectil(main, j1, j2, snapshot.get("proyectil_j1", {}))
	restaurar_proyectil(main, j2, j1, snapshot.get("proyectil_j2", {}))

	var replay = main.get("input_replay")
	if replay != null and snapshot.has("replay_tick"):
		replay.set("tick_actual", int(snapshot["replay_tick"]))
	if main.has_method("_actualizar_marcador"):
		main.call("_actualizar_marcador")

static func _snapshot_logico(snapshot: Dictionary) -> Dictionary:
	# Separación estricta SIMULACIÓN / PRESENTACIÓN.
	# __* = telemetría nativa/visual.
	# estado_visual_* usa Time.get_ticks_msec() dentro de Fighter y por diseño
	# NO puede formar parte de un checksum determinista de rollback.
	var limpio: Dictionary = snapshot.duplicate(true)
	var solo_presentacion := {
		"estado_visual_tension": true,
		"estado_visual_balance": true,
		"escala_actual": true,
		"sprite_base_y": true,
	}
	for lado in ["j1", "j2"]:
		if limpio.has(lado) and typeof(limpio[lado]) == TYPE_DICTIONARY:
			var estado: Dictionary = limpio[lado]
			for clave in estado.keys():
				if str(clave).begins_with("__") or solo_presentacion.has(str(clave)):
					estado.erase(clave)

	if limpio.has("tactico") and typeof(limpio["tactico"]) == TYPE_DICTIONARY:
		limpio["tactico"] = _tactico_logico(limpio["tactico"])
	return limpio

static func _comparar_valores(esperado: Variant, actual: Variant, ruta: String, diferencias: Array[String]) -> void:
	var te := typeof(esperado)
	var ta := typeof(actual)
	if te != ta:
		diferencias.append("%s tipo esperado=%s actual=%s" % [ruta, te, ta])
		return
	if te == TYPE_FLOAT:
		if absf(float(esperado) - float(actual)) > 0.0009:
			diferencias.append("%s esperado=%s actual=%s" % [ruta, esperado, actual])
	elif te == TYPE_VECTOR2:
		var ve: Vector2 = esperado
		var va: Vector2 = actual
		if ve.distance_to(va) > 0.0009:
			diferencias.append("%s esperado=%s actual=%s" % [ruta, esperado, actual])
	elif te == TYPE_DICTIONARY:
		var de: Dictionary = esperado
		var da: Dictionary = actual
		for clave in de.keys():
			if not da.has(clave):
				diferencias.append("%s.%s ausente" % [ruta, clave])
			else:
				_comparar_valores(de[clave], da[clave], "%s.%s" % [ruta, clave], diferencias)
	elif te == TYPE_ARRAY:
		var ae: Array = esperado
		var aa: Array = actual
		if ae.size() != aa.size():
			diferencias.append("%s tamaño esperado=%d actual=%d" % [ruta, ae.size(), aa.size()])
			return
		for i in range(ae.size()):
			_comparar_valores(ae[i], aa[i], "%s[%d]" % [ruta, i], diferencias)
	elif esperado != actual:
		diferencias.append("%s esperado=%s actual=%s" % [ruta, esperado, actual])

static func comparar_snapshots(esperado: Dictionary, actual: Dictionary) -> Array[String]:
	var diferencias: Array[String] = []
	var esperado_logico := _snapshot_logico(esperado)
	var actual_logico := _snapshot_logico(actual)
	_comparar_valores(esperado_logico, actual_logico, "snapshot", diferencias)
	return diferencias
