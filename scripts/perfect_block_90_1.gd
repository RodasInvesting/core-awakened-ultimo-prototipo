extends Node

# CORE AWAKENED 90.11.07 — RÁFAGA IA SIN RESPIRO ENTRE IMPACTOS.
# Al abrir la ventana de Combo Cancel contra CPU, la propia IA queda en silencio
# desde el PRIMER impacto limpio. Así no puede recuperar neutral/bloqueo/retroceso
# durante las centésimas previas al segundo input. Versus Local no entra aquí.
# CORE AWAKENED 90.11.06 — COMBO CANCEL IA: CONTACTO DETERMINISTA.
# Versus Local NO se modifica. Al confirmar x2/x3 contra CPU se elimina únicamente
# el espacio extra que pudo crear la movilidad IA antes del impacto y se arma el
# siguiente ataque DESPUÉS de recomponer esa distancia, conservando su lunge/timing normal.
# CORE AWAKENED 90.11.05 — COMBO CANCEL IA: COMPARACIÓN AISLADA VS VERSUS LOCAL.
# No altera startup, activo, recovery ni hitstun base. Al confirmar COMBO x2/x3
# contra CPU sólo bloquea temporalmente decisiones exclusivas de IA que no existen
# en Versus Local: guardia automática, retroceso, mantener distancia y carrera.
# Mantiene el anclaje de knockback de 90.11.04 y deja intacta la física común.
# CORE AWAKENED 90.11.04 — COMBO x2 ROBUSTO VS IA.
# Mantiene el aislamiento de input 90.10.95 y suma consumo del buffer de Fighter
# al confirmar impacto contra CPU, más anclaje horizontal sólo durante cancels.
# CORE AWAKENED 90.10.95 — INPUT TÁCTICO POR LUCHADOR.
# Este módulo ya NO lee flechas/X/C/arriba/abajo globales para los jugadores.
# Consume el input_frame_enrutado_actual de cada Fighter, evitando que una tecla
# de J1 active Back Dash/Counter/Combo Cancel en J2 y habilitando las mismas
# mecánicas tácticas para mando y teclado.

# 90.7: Fighter.gd sigue controlando la escala general.
# Este módulo solo muestra los NUEVOS sprites de evasión durante Back Dash,
# usando _actualizar_textura() para conservar la normalización del Fighter.

# CORE AWAKENED 90.7 — SPRITES DE EVASION INTEGRADOS + IA TÁCTICA
#
# Implementación aislada:
# - NO modifica Fighter.
# - NO modifica escala/tamaño.
# - NO modifica sprites.
# - NO modifica CORE, especiales ni remates.
# - NO modifica scripts de personajes.
#
# Flujo:
# 1) ABAJO justo antes de un puño/patada = PERFECT!
# 2) Soltar ABAJO.
# 3) Dentro de la ventana: X = Counter Puño / C = Counter Patada.
# 4) El counter sale más rápido y con más impacto.
#
# Si no se presiona X/C a tiempo, la oportunidad desaparece sin penalización.

const VENTANA_PERFECT_BLOCK := 0.13
const STUN_ATACANTE := 0.24
const VENTANA_COUNTER := 0.34
const MULT_STARTUP_COUNTER := 0.58
const MULT_DANO_COUNTER := 1.16
const MULT_EMPUJE_COUNTER := 1.22
const MULT_HITSTUN_COUNTER := 1.12
const MULT_RECOVERY_COUNTER := 0.82
const INTERVALO_BUSQUEDA := 0.20

# 90.2 — Back Dash: doble toque ALEJÁNDOSE del rival.
const VENTANA_DOBLE_TOQUE_BACKDASH := 0.28
const DURACION_BACKDASH := 0.16
const VENTANA_INVULNERABLE_BACKDASH := 0.11
const COOLDOWN_BACKDASH := 0.42
const MULT_VELOCIDAD_BACKDASH := 2.15

# 90.3 — Combo Cancel
# Si un golpe normal CONECTA, permite cancelar parte del recovery
# y encadenar otro X/C. Máximo 3 golpes normales por cadena.
const VENTANA_COMBO_CANCEL := 0.24
const MAX_GOLPES_CANCEL := 3
const COOLDOWN_FIN_CADENA := 0.30

# 90.4 — Launcher + persecución aérea + Air Combo
# ↑ + X desde suelo arma un golpe lanzador.
const VENTANA_LAUNCHER_ARMADO := 0.24
const COOLDOWN_LAUNCHER := 0.62
const FUERZA_LAUNCH_VERTICAL := -500.0
const FUERZA_PERSECUCION_VERTICAL := -410.0
const VELOCIDAD_PERSECUCION_HORIZONTAL := 145.0
const VENTANA_AIR_COMBO := 1.20
const MAX_GOLPES_AEREOS := 3
const MULT_HITSTUN_AEREO := 1.10
const EMPUJE_VERTICAL_AIR_HIT := -72.0

# 90.5 — Quick Recovery / Tech
const RECOVERY_DELAY := 0.34
const RECOVERY_WINDOW := 0.30
const RECOVERY_COOLDOWN := 0.72
const RECOVERY_MIN_HITSTUN := 0.06

# 90.6 — IA táctica.
# Es una CAPA encima de la IA actual: no reemplaza Fighter ni su navegación.
const IA_DISTANCIA_DEFENSA := 190.0
const IA_DISTANCIA_CASTIGO := 205.0
const IA_DURACION_BLOQUEO := 0.28
const IA_REACCION_MIN := 0.10
const IA_REACCION_MAX := 0.18
const IA_PROB_BLOQUEO_BASE := 0.46
const IA_PROB_BACKDASH_PRESION := 0.24
const IA_PROB_CASTIGO := 0.72
const IA_PRESION_MAX := 4.0
const IA_PRESION_DECAY_POR_SEG := 0.34
const IA_RECOVERY_DELAY := 0.38
const IA_RECOVERY_WINDOW := 0.34
const IA_RECOVERY_PROB := 0.58
const IA_RECOVERY_COOLDOWN := 0.90

# 90.6.1 — La CPU no debe interrumpir una cadena que el jugador ya confirmó.
# Cada cancel conectado refresca esta protección.
const IA_PROTECCION_COMBO := 0.48

# 90.7 — sprites oficiales de EVASION / Back Dash.
# Todos miran al rival mientras el cuerpo retrocede.
# Magnus y Xenoid ya vienen PRE-INVERTIDOS dentro del ZIP.
const RUTAS_EVASION := {
	"Helena": "res://assets/evasion_final/helena.png",
	"Jester": "res://assets/evasion_final/jester.png",
	"Kai": "res://assets/evasion_final/kai.png",
	"Kali": "res://assets/evasion_final/kali.png",
	"Magnus": "res://assets/evasion_final/magnus.png",
	"Varkhos": "res://assets/evasion_final/varkhos.png",
	"Xenoid": "res://assets/evasion_final/xenoid.png",
	"Aethel": "res://assets/evasion_final/aethel.png",
	"Cibor-X": "res://assets/evasion_final/cibor-x.png",
	"Fang": "res://assets/evasion_final/fang.png",
}

var _luchadores: Dictionary = {}
var _ventana_hasta: Dictionary = {}
var _counter_hasta: Dictionary = {}
var _counter_disponible: Dictionary = {}
var _vida_antes: Dictionary = {}

var _abajo_previo := false
var _x_previo := false
var _c_previo := false
var _izquierda_previa := false
var _derecha_previa := false
var _ultimo_toque_izq := -10.0
var _ultimo_toque_der := -10.0

# 90.10.95 — estado de input separado por instancia de Fighter. Los campos
# globales anteriores se conservan por compatibilidad, pero ya no gobiernan
# acciones de jugador.
var _input_previo_por_id: Dictionary = {}
var _ultimo_toque_izq_por_id: Dictionary = {}
var _ultimo_toque_der_por_id: Dictionary = {}
var _backdash_timer: Dictionary = {}
var _backdash_direccion: Dictionary = {}
var _backdash_invuln_hasta: Dictionary = {}
var _backdash_cooldown_hasta: Dictionary = {}

# 90.7 — cache de sprites de evasión.
var _texturas_evasion: Dictionary = {}

# Estado de Combo Cancel por atacante.
var _combo_cancel_hasta: Dictionary = {}
var _combo_cancel_disponible: Dictionary = {}
var _combo_cancel_cadena: Dictionary = {}
var _combo_cancel_bloqueado_hasta: Dictionary = {}

# 90.4 — estado aéreo por atacante.
var _launcher_armado_hasta: Dictionary = {}
var _launcher_cooldown_hasta: Dictionary = {}
var _air_combo_activo: Dictionary = {}
var _air_combo_hasta: Dictionary = {}
var _air_combo_golpes: Dictionary = {}

# 90.5 — ventanas de recuperación por luchador.
var _recovery_desde: Dictionary = {}
var _recovery_hasta: Dictionary = {}
var _recovery_cooldown_hasta: Dictionary = {}
var _arriba_previo := false

# 90.6 — estado táctico de CPU por luchador.
var _ia_siguiente_decision: Dictionary = {}
var _ia_estado: Dictionary = {}
var _ia_presion: Dictionary = {}
var _ia_castigo_hasta: Dictionary = {}
var _ia_recovery_desde: Dictionary = {}
var _ia_recovery_hasta: Dictionary = {}
var _ia_recovery_cooldown_hasta: Dictionary = {}

# Ventana durante la cual la IA rival NO puede cortar el combo del atacante.
var _combo_proteccion_hasta: Dictionary = {}

# 90.11.04 — input ofensivo pre-bufferizado contra CPU. Fighter ya guarda un
# segundo X/C pulsado durante el golpe vigente; este módulo lo consume al
# confirmar el impacto para que la distancia/movimiento de la IA no haga perder x2.
var _combo_buffer_ia_diferido: Dictionary = {}

# 90.6.4 — cache visual exclusivo para poses problemáticas de Aethel.
# La tabla precalculada de Fighter puede quedar vieja si se reemplaza un PNG;
# este cache recalcula usando EL PNG REAL instalado.
var _aethel_patada_tex_id: Dictionary = {}
var _aethel_patada_escala: Dictionary = {}

var _scan_timer := 0.0

# 91.00.00-H10.2 — MARCADOR EXPLÍCITO DE COUNTER PARA ROLLBACK.
# Diagnóstico únicamente: NO gobierna gameplay, daño, timing ni input.
# Se incrementa sólo cuando _intentar_counter() realmente consume la ventana
# y lanza el contraataque.
var _rollback_counter_event_serial: int = 0
var _rollback_counter_event_fighter_id: int = -1
var _rollback_counter_event_tipo: String = ""

# 91.00.00-H10.2 — marcador explícito Back Dash para diagnóstico rollback.
# No participa de gameplay: sólo identifica una ejecución REAL aceptada.
var _rollback_backdash_event_serial: int = 0
var _rollback_backdash_event_fighter_id: int = -1
var _rollback_backdash_event_direccion: float = 0.0

# 91.00.00-H10.2 — marcadores explícitos Launcher/Air Combo para diagnóstico.
# Son observadores inertes: NO gobiernan gameplay, timings, daño ni movimiento.
var _rollback_launcher_event_serial: int = 0
var _rollback_launcher_event_attacker_id: int = -1
var _rollback_launcher_event_defender_id: int = -1

var _rollback_airhit_event_serial: int = 0
var _rollback_airhit_event_attacker_id: int = -1
var _rollback_airhit_event_defender_id: int = -1
var _rollback_airhit_event_count: int = 0

# 91.00.00-H10.2 — RELOJ TÁCTICO DETERMINISTA.
# Todas las ventanas de Perfect/Counter/Combo Cancel/Back Dash/Launcher/
# Quick Recovery/IA dejan de depender del reloj real del SO.
# Este reloj avanza una vez por physics tick y forma parte del snapshot.
var _rollback_tactical_clock_ticks: int = 0
var _rollback_tactical_clock_seconds: float = 0.0
# H10.7 — delta efímero para resimulación CORE III. No participa del gameplay
# normal; Main lo fija sólo durante catch-up y se consume en un callback.
var rollback_delta_override: float = -1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Ejecutar nuestra corrección visual DESPUÉS de los fighters.
	process_priority = 100
	_buscar_luchadores()


func _physics_process(delta: float) -> void:
	if rollback_delta_override >= 0.0:
		delta = rollback_delta_override
		rollback_delta_override = -1.0
	# 91.00.00-H10.2 — avanzar ANTES de evaluar cualquier deadline táctico.
	_avanzar_reloj_tactico(delta)

	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = INTERVALO_BUSQUEDA
		_buscar_luchadores()

	_limpiar_referencias_invalidas()

	# Estado previo a posibles impactos de este frame.
	for id in _luchadores.keys():
		var luchador = _luchadores[id]
		if is_instance_valid(luchador):
			_vida_antes[id] = float(luchador.get("vida"))

	# 90.6 — capa táctica de la CPU.
	_procesar_ia_tactica(delta)

	# 90.10.95 — toda la capa táctica humana se resuelve POR LUCHADOR usando
	# el mismo Input Frame que ya consumió Fighter. Esto elimina el segundo
	# controlador global que provocaba el "dash espejo" y hacía que Combo Cancel
	# sólo respondiera a X/C del teclado.
	_procesar_input_jugadores()

	# Expirar oportunidades viejas.
	var ahora_exp := _ahora()
	for id in _counter_hasta.keys():
		if ahora_exp > float(_counter_hasta.get(id, 0.0)):
			_counter_disponible[id] = false

	for id in _combo_cancel_hasta.keys():
		if ahora_exp > float(_combo_cancel_hasta.get(id, 0.0)):
			_combo_cancel_disponible[id] = false

	for id in _air_combo_hasta.keys():
		if ahora_exp > float(_air_combo_hasta.get(id, 0.0)):
			_air_combo_activo[id] = false
			_air_combo_golpes[id] = 0

	# 91.00.00-H10.2 — BACK DASH 100% PHYSICS.
	# Antes se actualizaba en _process(delta), por lo que posición y timer
	# dependían del framerate/render y no podían reproducirse de forma exacta.
	#
	# Se ejecuta DESPUÉS de _procesar_input_jugadores(): si el segundo toque
	# inicia un Back Dash en este physics tick, su primer paso ocurre en este
	# mismo tick tanto en LIVE como durante rollback.
	_actualizar_backdash(delta)


func _process(_delta: float) -> void:
	# 91.00.00-H10.2 — _process queda exclusivamente para correcciones visuales.
	# Ningún estado lógico ni movimiento de Back Dash puede depender del render.

	# 90.6.3 — única excepción visual: las patadas de Aethel tienen entradas
	# precalculadas viejas. Se recalculan contra el PNG real en tiempo de juego.
	_corregir_poses_aethel()


func _corregir_poses_aethel() -> void:
	for id in _luchadores.keys():
		var luchador = _luchadores[id]
		if not is_instance_valid(luchador):
			continue
		if String(luchador.get("nombre_luchador")) != "Aethel":
			continue

		var sprite_obj = luchador.get("sprite")
		if not (sprite_obj is Sprite2D):
			continue

		var spr: Sprite2D = sprite_obj as Sprite2D
		var tex: Texture2D = spr.texture
		if not tex:
			continue

		var ruta: String = tex.resource_path
		if not _es_pose_problem_aethel(ruta):
			continue

		if not luchador.has_method("_obtener_rect_visual"):
			continue
		if not luchador.has_method("_altura_visible_objetivo"):
			continue

		var tex_id: int = int(tex.get_instance_id())
		var escala_correcta: float = 0.0

		# La escala solo se calcula una vez por textura.
		if int(_aethel_patada_tex_id.get(id, -1)) == tex_id:
			escala_correcta = float(_aethel_patada_escala.get(id, 0.0))
		else:
			escala_correcta = _calcular_escala_real_aethel(luchador, tex)
			if escala_correcta <= 0.0:
				continue
			_aethel_patada_tex_id[id] = tex_id
			_aethel_patada_escala[id] = escala_correcta

		if escala_correcta <= 0.0:
			continue

		# Aplicar el tamaño correcto. Se hace cada frame de ESA pose para que
		# una escala precalculada vieja no pueda volver a pisarlo.
		spr.scale = Vector2(escala_correcta, escala_correcta)
		_set_si_existe(luchador, "escala_actual", escala_correcta)

		# Recalcular el anclaje inferior exactamente con el mismo criterio
		# de Fighter: el borde visible inferior permanece pegado al piso.
		var rect_var = luchador.call("_obtener_rect_visual", tex)
		if not (rect_var is Rect2):
			continue
		var rect: Rect2 = rect_var

		var base_y: float = (
			float(tex.get_height()) * 0.5 * escala_correcta
			- (rect.position.y + rect.size.y) * escala_correcta
		)
		_set_si_existe(luchador, "sprite_base_y", base_y)
		spr.position.y = base_y

		if luchador.has_method("_sprite_ancla_x"):
			spr.position.x = float(luchador.call("_sprite_ancla_x"))


func _es_pose_problem_aethel(ruta: String) -> bool:
	if not ruta.begins_with("res://assets/aethel/"):
		return false

	var archivo: String = ruta.get_file().to_lower()

	# Patadas normales y de Furia.
	if archivo.begins_with("patada") or archivo.begins_with("furia_patada"):
		return true

	# Poses aéreas: cubre salto, doble_salto y variantes equivalentes.
	if "salto" in archivo:
		return true

	# Descenso / decenso (incluimos ambas grafías por compatibilidad con assets).
	if "descenso" in archivo or "decenso" in archivo:
		return true

	return false


func _calcular_escala_real_aethel(luchador: Node, tex: Texture2D) -> float:
	var rect_var = luchador.call("_obtener_rect_visual", tex)
	if not (rect_var is Rect2):
		return 0.0

	var rect: Rect2 = rect_var
	if rect.size.x <= 1.0 or rect.size.y <= 1.0:
		return 0.0

	var ref_tex_obj = luchador.get("textura_parado")
	if not (ref_tex_obj is Texture2D):
		# Fallback simple por altura visible.
		var alto_objetivo: float = float(luchador.call("_altura_visible_objetivo"))
		return clampf(alto_objetivo / rect.size.y, 0.08, 2.0)

	var ref_tex: Texture2D = ref_tex_obj as Texture2D
	var ref_rect_var = luchador.call("_obtener_rect_visual", ref_tex)
	if not (ref_rect_var is Rect2):
		return 0.0

	var ref_rect: Rect2 = ref_rect_var
	if ref_rect.size.x <= 1.0 or ref_rect.size.y <= 1.0:
		return 0.0

	# MISMA fórmula geométrica que usa Fighter cuando una pose no tiene
	# entrada precalculada. La diferencia es que aquí IGNORAMOS únicamente
	# las entradas viejas de estas poses de Aethel.
	var alto_objetivo: float = float(luchador.call("_altura_visible_objetivo"))
	var escala_parado: float = alto_objetivo / ref_rect.size.y
	var metrica_ref: float = sqrt(maxf(ref_rect.size.x * ref_rect.size.y, 1.0))
	var metrica_pose: float = sqrt(maxf(rect.size.x * rect.size.y, 1.0))
	var escala_pose: float = escala_parado * (metrica_ref / metrica_pose)

	return clampf(escala_pose, 0.08, 2.0)


func _frame_tactico_neutro() -> Dictionary:
	return {
		"izquierda": false,
		"derecha": false,
		"salto": false,
		"bloqueo": false,
		"puno": false,
		"patada": false,
		"especial": false,
	}


func _input_frame_de_luchador(luchador: Node) -> Dictionary:
	if not is_instance_valid(luchador):
		return _frame_tactico_neutro()
	# Fighter 90.10.93+ conserva aquí el último frame real, tanto LOCAL como
	# EXTERNO. PerfectBlock corre con prioridad 100, después del Fighter.
	if _tiene_propiedad(luchador, "input_frame_enrutado_actual"):
		var valor = luchador.get("input_frame_enrutado_actual")
		if valor is Dictionary:
			return (valor as Dictionary).duplicate(false)
	return _frame_tactico_neutro()


func _procesar_input_jugadores() -> void:
	var ahora := _ahora()
	for id in _luchadores.keys():
		var luchador = _luchadores[id]
		if not is_instance_valid(luchador):
			continue
		if not bool(luchador.get("controlado_por_jugador")):
			continue

		var frame: Dictionary = _input_frame_de_luchador(luchador)
		var previo_var = _input_previo_por_id.get(id, _frame_tactico_neutro())
		var previo: Dictionary = previo_var if previo_var is Dictionary else _frame_tactico_neutro()

		var izquierda := bool(frame.get("izquierda", false))
		var derecha := bool(frame.get("derecha", false))
		var arriba := bool(frame.get("salto", false))
		var abajo := bool(frame.get("bloqueo", false))
		var puno := bool(frame.get("puno", false))
		var patada := bool(frame.get("patada", false))

		var izquierda_justa := izquierda and not bool(previo.get("izquierda", false))
		var derecha_justa := derecha and not bool(previo.get("derecha", false))
		var arriba_justa := arriba and not bool(previo.get("salto", false))
		var abajo_justa := abajo and not bool(previo.get("bloqueo", false))
		var puno_justo := puno and not bool(previo.get("puno", false))
		var patada_justa := patada and not bool(previo.get("patada", false))

		# Back Dash: el doble toque sólo puede afectar a ESTE luchador.
		if izquierda_justa:
			_procesar_toque_backdash(luchador, -1.0, ahora)
		if derecha_justa:
			_procesar_toque_backdash(luchador, 1.0, ahora)

		# Quick Recovery: salto/arriba del mismo dispositivo del Fighter.
		if arriba_justa:
			_intentar_quick_recovery(luchador)

		# Perfect Block: abrir ventana únicamente para quien comenzó su guardia.
		if abajo_justa:
			_ventana_hasta[id] = ahora + VENTANA_PERFECT_BLOCK

		# Launcher: arriba + puño del mismo Fighter.
		if arriba and puno_justo:
			_intentar_armar_launcher(luchador)

		# Counter tiene prioridad sobre Combo Cancel, pero ahora por Fighter.
		if not abajo:
			if puno_justo:
				if not _intentar_counter("punetazo", luchador):
					_intentar_combo_cancel("punetazo", luchador)
			elif patada_justa:
				if not _intentar_counter("patada", luchador):
					_intentar_combo_cancel("patada", luchador)

		_input_previo_por_id[id] = frame.duplicate(false)


func _procesar_toque_backdash(luchador: Node, direccion_tecla: float, ahora: float) -> void:
	if not is_instance_valid(luchador):
		return
	var id := luchador.get_instance_id()
	var tabla: Dictionary = _ultimo_toque_izq_por_id if direccion_tecla < 0.0 else _ultimo_toque_der_por_id
	var ultimo := float(tabla.get(id, -10.0))
	if ahora - ultimo <= VENTANA_DOBLE_TOQUE_BACKDASH:
		_intentar_backdash(direccion_tecla, luchador)
		tabla[id] = -10.0
	else:
		tabla[id] = ahora


func _intentar_backdash(direccion_tecla: float, objetivo_input: Node = null) -> void:
	var ahora := _ahora()

	for id in _luchadores.keys():
		var luchador = _luchadores[id]
		if not is_instance_valid(luchador):
			continue
		if objetivo_input != null and luchador != objetivo_input:
			continue
		if not bool(luchador.get("controlado_por_jugador")):
			continue
		if not _puede_backdash(luchador):
			continue
		if ahora < float(_backdash_cooldown_hasta.get(id, 0.0)):
			continue

		var direccion_alejar := _direccion_alejamiento(luchador)
		if direccion_alejar == 0.0 or direccion_tecla != direccion_alejar:
			# Doble toque HACIA el rival sigue siendo la carrera normal del juego.
			continue

		_iniciar_backdash(luchador, direccion_alejar)
		return


func _puede_backdash(luchador: Node) -> bool:
	if bool(luchador.get("esta_derrotado")):
		return false
	if bool(luchador.get("en_secuencia_especial")):
		return false
	if bool(luchador.get("bloqueo_cinematico")):
		return false
	if float(luchador.get("hitstun_timer")) > 0.0:
		return false
	if bool(luchador.get("bloqueando")):
		return false
	if int(luchador.get("fase_ataque")) != 0:
		return false
	if not luchador.is_on_floor():
		return false
	return true


func _direccion_alejamiento(luchador: Node) -> float:
	var rival = luchador.get("objetivo")
	if not is_instance_valid(rival):
		return 0.0
	var dx: float = rival.global_position.x - luchador.global_position.x
	if absf(dx) < 1.0:
		return 0.0
	return -signf(dx)


func _iniciar_backdash(luchador: Node, direccion: float) -> void:
	var id := luchador.get_instance_id()
	var ahora := _ahora()

	# Fighter también reconoce el doble toque como carrera.
	# La detenemos solo en este caso porque esta dirección es "hacia atrás".
	if luchador.has_method("_detener_carrera"):
		luchador.call("_detener_carrera")

	_backdash_timer[id] = DURACION_BACKDASH
	_backdash_direccion[id] = direccion
	_backdash_invuln_hasta[id] = ahora + VENTANA_INVULNERABLE_BACKDASH
	_backdash_cooldown_hasta[id] = ahora + COOLDOWN_BACKDASH

	# 91.00.00-H10.2 — sello sólo después de que el Back Dash fue aceptado.
	_rollback_backdash_event_serial += 1
	_rollback_backdash_event_fighter_id = int(id)
	_rollback_backdash_event_direccion = direccion
	print("[91.00.00-H10.2] BACKDASH EVENT MARCADO — serial=%d fighter_id=%d dir=%.1f" % [
		_rollback_backdash_event_serial,
		_rollback_backdash_event_fighter_id,
		_rollback_backdash_event_direccion
	])

	# Mantiene la mirada hacia el rival mientras retrocede.
	var rival = luchador.get("objetivo")
	if is_instance_valid(rival):
		var dx: float = rival.global_position.x - luchador.global_position.x
		if absf(dx) > 1.0:
			luchador.set("mirando", signf(dx))

	# Evita que el inicio de carrera del doble toque agregue velocidad residual.
	var vel: Vector2 = luchador.get("velocity")
	vel.x = 0.0
	luchador.set("velocity", vel)

	# 90.7 — mostrar inmediatamente la pose oficial de evasión.
	_aplicar_pose_evasion(luchador)


func _actualizar_backdash(delta: float) -> void:
	# H5.1: esta función SOLO se invoca desde _physics_process.
	# `delta` es por tanto el paso de simulación, no el delta de render.
	for id in _backdash_timer.keys():
		var restante: float = float(_backdash_timer.get(id, 0.0))
		if restante <= 0.0:
			continue

		var luchador = _luchadores.get(id, null)
		if not is_instance_valid(luchador):
			_backdash_timer[id] = 0.0
			continue
		if bool(luchador.get("esta_derrotado")) or bool(luchador.get("en_secuencia_especial")):
			_backdash_timer[id] = 0.0
			continue

		var direccion: float = float(_backdash_direccion.get(id, 0.0))
		var velocidad_base: float = float(luchador.get("velocidad"))
		var velocidad_dash: float = clampf(velocidad_base * MULT_VELOCIDAD_BACKDASH, 520.0, 760.0)

		# Movimiento deliberadamente horizontal y corto. Al ser SIEMPRE alejándose
		# del rival no atraviesa al oponente.
		luchador.global_position.x += direccion * velocidad_dash * delta

		# Reutiliza los límites de arena del Fighter sin modificar su implementación.
		if luchador.has_method("_aplicar_limites_arena"):
			luchador.call("_aplicar_limites_arena")

		# Mantiene la orientación hacia el rival durante la evasión.
		var rival = luchador.get("objetivo")
		if is_instance_valid(rival):
			var dx: float = rival.global_position.x - luchador.global_position.x
			if absf(dx) > 1.0:
				luchador.set("mirando", signf(dx))

		# No permitir que la carrera normal quede enganchada durante el dash atrás.
		if bool(luchador.get("carrera_activa")) and luchador.has_method("_detener_carrera"):
			luchador.call("_detener_carrera")

		# 90.7 — mantener el sprite de evasión durante toda la ventana.
		_aplicar_pose_evasion(luchador)

		_backdash_timer[id] = maxf(0.0, restante - delta)


func _obtener_textura_evasion(luchador: Node) -> Texture2D:
	if not is_instance_valid(luchador):
		return null

	var nombre: String = String(luchador.get("nombre_luchador"))
	if not RUTAS_EVASION.has(nombre):
		return null

	if _texturas_evasion.has(nombre):
		var cache = _texturas_evasion[nombre]
		if cache is Texture2D:
			return cache as Texture2D

	var ruta: String = String(RUTAS_EVASION[nombre])
	if not ResourceLoader.exists(ruta):
		return null

	var recurso = load(ruta)
	if recurso is Texture2D:
		_texturas_evasion[nombre] = recurso
		return recurso as Texture2D

	return null


func _aplicar_pose_evasion(luchador: Node) -> void:
	if not is_instance_valid(luchador):
		return
	if bool(luchador.get("esta_derrotado")):
		return
	if bool(luchador.get("en_secuencia_especial")):
		return

	var tex: Texture2D = _obtener_textura_evasion(luchador)
	if not tex:
		return

	var sprite_obj = luchador.get("sprite")
	if not (sprite_obj is Sprite2D):
		return

	var spr: Sprite2D = sprite_obj as Sprite2D

	# Solo recalcular cuando Fighter haya intentado colocar otra textura.
	# _actualizar_textura normaliza automáticamente los PNG de distinto tamaño.
	if spr.texture != tex and luchador.has_method("_actualizar_textura"):
		luchador.call("_actualizar_textura", tex)

	# La mirada sigue siendo propiedad del Fighter.
	# Magnus y Xenoid ya están invertidos físicamente en sus PNG de este paquete.


func _buscar_luchadores() -> void:
	var escena := get_tree().current_scene
	if not escena:
		return

	var nodos: Array[Node] = [escena]
	while not nodos.is_empty():
		var nodo: Node = nodos.pop_back()
		_registrar_si_es_luchador(nodo)
		for hijo in nodo.get_children():
			nodos.append(hijo)


func _registrar_si_es_luchador(nodo: Node) -> void:
	if not nodo:
		return

	# Identificación por API estable de Fighter.
	if not nodo.has_signal("impacto_detallado"):
		return
	if not nodo.has_method("recibir_dano"):
		return
	if not nodo.has_method("intentar_punetazo"):
		return
	if not nodo.has_method("intentar_patada"):
		return

	var id := nodo.get_instance_id()
	if _luchadores.has(id):
		return

	_luchadores[id] = nodo
	_vida_antes[id] = float(nodo.get("vida"))
	_ventana_hasta[id] = 0.0
	_counter_hasta[id] = 0.0
	_counter_disponible[id] = false
	_backdash_timer[id] = 0.0
	_backdash_direccion[id] = 0.0
	_backdash_invuln_hasta[id] = 0.0
	_backdash_cooldown_hasta[id] = 0.0
	_input_previo_por_id[id] = _frame_tactico_neutro()
	_ultimo_toque_izq_por_id[id] = -10.0
	_ultimo_toque_der_por_id[id] = -10.0
	_combo_cancel_hasta[id] = 0.0
	_combo_cancel_disponible[id] = false
	_combo_cancel_cadena[id] = 0
	_combo_cancel_bloqueado_hasta[id] = 0.0
	_launcher_armado_hasta[id] = 0.0
	_launcher_cooldown_hasta[id] = 0.0
	_air_combo_activo[id] = false
	_air_combo_hasta[id] = 0.0
	_air_combo_golpes[id] = 0
	_recovery_desde[id] = 0.0
	_recovery_hasta[id] = 0.0
	_recovery_cooldown_hasta[id] = 0.0

	_ia_siguiente_decision[id] = 0.0
	_ia_estado[id] = "NEUTRAL"
	_ia_presion[id] = 0.0
	_ia_castigo_hasta[id] = 0.0
	_ia_recovery_desde[id] = 0.0
	_ia_recovery_hasta[id] = 0.0
	_ia_recovery_cooldown_hasta[id] = 0.0
	_combo_proteccion_hasta[id] = 0.0

	var callback := Callable(self, "_on_impacto_detallado").bind(nodo)
	if not nodo.is_connected("impacto_detallado", callback):
		nodo.connect("impacto_detallado", callback)


func _on_impacto_detallado(_fuerza: float, tipo: String, bloqueado: bool, defensor: Node) -> void:
	if not is_instance_valid(defensor):
		return

	# 90.6 — la IA aprende de la presión aunque el defensor sea CPU.
	_registrar_impacto_ia(defensor, tipo, bloqueado)

	var tipo_normal := tipo == "punetazo" or tipo == "patada" or tipo == "golpe"
	var id := defensor.get_instance_id()

	# Atacante real del impacto actual.
	var atacante_combo = defensor.get("objetivo") if tipo_normal else null

	# 90.11.03 — OFENSIVA HUMANA CONTRA IA.
	# Antes el `return` del defensor CPU ocurría antes de abrir Combo Cancel.
	# Resultado: COMBO x2, Launcher y Air Combo funcionaban contra J2 humano,
	# pero no contra la CPU. Procesamos primero las oportunidades del ATACANTE;
	# luego salimos si el defensor no necesita mecánicas defensivas humanas.
	if tipo_normal and not bloqueado and is_instance_valid(atacante_combo) \
		and bool(atacante_combo.get("controlado_por_jugador")):
		if _consumir_launcher_si_corresponde(atacante_combo, defensor, tipo):
			var aid_launcher: int = int(atacante_combo.get_instance_id())
			_combo_cancel_cadena[aid_launcher] = 1
			_combo_cancel_disponible[aid_launcher] = true
			_combo_cancel_hasta[aid_launcher] = _ahora() + VENTANA_COMBO_CANCEL
		else:
			_registrar_air_hit_si_corresponde(atacante_combo, defensor)
			_abrir_combo_cancel(atacante_combo)
			# 90.11.04 — si el jugador ya pulsó el próximo X/C ANTES de que
			# el golpe alcanzara a una CPU móvil, Fighter lo tiene en su buffer.
			# Lo convertimos en Combo Cancel diferido para evitar reentrar en la
			# resolución del impacto que todavía está en curso.
			_programar_buffer_combo_vs_ia(atacante_combo, defensor)

	# Desde aquí hacia abajo son respuestas/defensas del propio defensor humano.
	# Una CPU conserva su IA táctica y no recibe ventanas de control de jugador.
	if not bool(defensor.get("controlado_por_jugador")):
		return

	# 90.5 — Un impacto normal limpio puede habilitar Quick Recovery más tarde.
	if tipo_normal and not bloqueado:
		_armar_quick_recovery(defensor)

	# 90.2 — evasión del Back Dash. Solo golpes normales.
	if tipo_normal and _ahora() <= float(_backdash_invuln_hasta.get(id, 0.0)):
		if _vida_antes.has(id):
			defensor.set("vida", maxf(float(defensor.get("vida")), float(_vida_antes[id])))

		_set_si_existe(defensor, "hitstun_timer", 0.0)
		_set_si_existe(defensor, "_reaccion_impacto_timer", 0.0)
		_set_si_existe(defensor, "empuje_pendiente_timer", 0.0)
		_set_si_existe(defensor, "empuje_pendiente_fuerza", 0.0)
		_set_si_existe(defensor, "empuje_timer", 0.0)
		_set_si_existe(defensor, "empuje_x", 0.0)
		_set_si_existe(defensor, "absorcion_impacto_timer", 0.0)
		_set_si_existe(defensor, "impacto_visual_y", 0.0)

		_mostrar_texto(defensor, "EVADE!", Color(0.55, 0.90, 1.0, 1.0))
		return

	if not bloqueado:
		return
	if not tipo_normal:
		# Los CORE, especiales y remates mantienen sus reglas.
		return
	var limite: float = float(_ventana_hasta.get(id, 0.0))
	if _ahora() > limite:
		return

	_ventana_hasta[id] = 0.0

	# Quitar chip damage del bloqueo normal.
	if _vida_antes.has(id):
		defensor.set("vida", maxf(float(defensor.get("vida")), float(_vida_antes[id])))

	# El defensor recupera control inmediatamente.
	_set_si_existe(defensor, "hitstun_timer", 0.0)
	_set_si_existe(defensor, "_reaccion_impacto_timer", 0.0)
	_set_si_existe(defensor, "empuje_pendiente_timer", 0.0)
	_set_si_existe(defensor, "empuje_pendiente_fuerza", 0.0)
	_set_si_existe(defensor, "empuje_timer", 0.0)
	_set_si_existe(defensor, "empuje_x", 0.0)
	_set_si_existe(defensor, "absorcion_impacto_timer", 0.0)
	_set_si_existe(defensor, "impacto_visual_y", 0.0)
	_set_si_existe(defensor, "pose_timer", 0.0)

	# Frenar brevemente al atacante.
	var atacante = defensor.get("objetivo")
	if is_instance_valid(atacante) and not bool(atacante.get("esta_derrotado")):
		_set_si_existe(atacante, "hitstop_timer",
			maxf(_get_float(atacante, "hitstop_timer"), 0.050))
		_set_si_existe(atacante, "hitstun_timer",
			maxf(_get_float(atacante, "hitstun_timer"), STUN_ATACANTE))

	# Abrir la oportunidad real de Counter.
	_counter_disponible[id] = true
	_counter_hasta[id] = _ahora() + VENTANA_COUNTER

	_mostrar_texto(defensor, "PERFECT!", Color(1.0, 0.88, 0.28, 1.0))


func _intentar_counter(tipo: String, objetivo_input: Node = null) -> bool:
	var ahora := _ahora()

	for id in _luchadores.keys():
		var defensor = _luchadores[id]
		if not is_instance_valid(defensor):
			continue
		if objetivo_input != null and defensor != objetivo_input:
			continue
		if not bool(defensor.get("controlado_por_jugador")):
			continue
		if not bool(_counter_disponible.get(id, false)):
			continue
		if ahora > float(_counter_hasta.get(id, 0.0)):
			_counter_disponible[id] = false
			continue
		if bool(defensor.get("esta_derrotado")):
			_counter_disponible[id] = false
			continue

		# Consumir la ventana una sola vez.
		_counter_disponible[id] = false
		_counter_hasta[id] = 0.0

		# Soltar guardia sin forzar una pose/textura intermedia.
		_set_si_existe(defensor, "bloqueando", false)
		_set_si_existe(defensor, "bloqueo_timer", 0.0)

		_set_si_existe(defensor, "hitstun_timer", 0.0)
		_set_si_existe(defensor, "_reaccion_impacto_timer", 0.0)
		_set_si_existe(defensor, "pose_timer", 0.0)

		# Ejecutar el ataque normal del propio personaje.
		if tipo == "punetazo":
			defensor.call("intentar_punetazo")
		else:
			defensor.call("intentar_patada")

		# Potenciar SOLO el ataque que acaba de iniciarse.
		# Se alteran valores internos de ESA instancia de ataque y no las
		# estadísticas permanentes del personaje.
		if _tiene_propiedad(defensor, "timer_fase_ataque"):
			var startup_actual := _get_float(defensor, "timer_fase_ataque")
			defensor.set("timer_fase_ataque", startup_actual * MULT_STARTUP_COUNTER)

		if _tiene_propiedad(defensor, "_atk_dano"):
			defensor.set("_atk_dano", _get_float(defensor, "_atk_dano") * MULT_DANO_COUNTER)

		if _tiene_propiedad(defensor, "_atk_empuje_base"):
			defensor.set("_atk_empuje_base",
				_get_float(defensor, "_atk_empuje_base") * MULT_EMPUJE_COUNTER)

		if _tiene_propiedad(defensor, "_atk_hitstun"):
			defensor.set("_atk_hitstun",
				_get_float(defensor, "_atk_hitstun") * MULT_HITSTUN_COUNTER)

		if _tiene_propiedad(defensor, "_atk_dur_recovery"):
			defensor.set("_atk_dur_recovery",
				_get_float(defensor, "_atk_dur_recovery") * MULT_RECOVERY_COUNTER)

		# 91.00.00-H10.2 — sello de evento. Si esta línea se ejecuta, el Counter
		# fue REALMENTE aceptado por la lógica de producción.
		_rollback_counter_event_serial += 1
		_rollback_counter_event_fighter_id = int(id)
		_rollback_counter_event_tipo = tipo
		print("[91.00.00-H10.2] COUNTER EVENT MARCADO — serial=%d fighter_id=%d tipo=%s" % [
			_rollback_counter_event_serial,
			_rollback_counter_event_fighter_id,
			_rollback_counter_event_tipo
		])

		_mostrar_texto(defensor, "COUNTER!", Color(0.35, 0.95, 1.0, 1.0))
		return true

	return false


func _ia_cpu_fuera_de_combate(cpu: Node) -> bool:
	if not is_instance_valid(cpu):
		return true
	if bool(cpu.get("esta_derrotado")):
		return true
	# El Fighter actual expone vida internamente; <= 0 evita que la capa IA
	# lance una acción en el intervalo entre el golpe final y la caída.
	if _tiene_propiedad(cpu, "vida") and float(cpu.get("vida")) <= 0.0:
		return true
	return false


func _ia_rival_en_combo_protegido(rival: Node) -> bool:
	if not is_instance_valid(rival):
		return false

	# Combos CORE / remates / secuencias cinemáticas del Fighter.
	if bool(rival.get("en_secuencia_especial")):
		return true
	if bool(rival.get("bloqueo_cinematico")):
		return true

	var rid: int = int(rival.get_instance_id())
	var ahora := _ahora()

	# Combo Cancel / Launcher / Air Combo añadidos por este módulo.
	if ahora <= float(_combo_proteccion_hasta.get(rid, 0.0)):
		return true
	if bool(_air_combo_activo.get(rid, false)):
		return true

	return false


func _cancelar_estado_tactico(cpu: Node, id, motivo: String) -> void:
	# Cancela exclusivamente decisiones creadas por esta capa IA.
	# No altera hit-stun, derrota, física ni sprites del Fighter.
	_ia_estado[id] = motivo
	_ia_castigo_hasta[id] = 0.0
	_ia_siguiente_decision[id] = _ahora() + 0.12
	_ia_recovery_desde[id] = 0.0
	_ia_recovery_hasta[id] = 0.0

	# Soltar SOLO el estado. Fighter conserva control exclusivo de la pose
	# y de la normalización visual.
	if is_instance_valid(cpu) and bool(cpu.get("bloqueando")):
		_set_si_existe(cpu, "bloqueando", false)
		_set_si_existe(cpu, "bloqueo_timer", 0.0)

func _ia_nivel(cpu: Node) -> int:
	if not is_instance_valid(cpu):
		return 0
	if _tiene_propiedad(cpu, "dificultad_ia"):
		return clampi(int(cpu.get("dificultad_ia")), 0, 2)
	return 0

func _ia_prob_bloqueo_por_nivel(cpu: Node) -> float:
	match _ia_nivel(cpu):
		2: return 0.24
		1: return 0.44
		_: return 0.30

func _ia_prob_backdash_por_nivel(cpu: Node) -> float:
	match _ia_nivel(cpu):
		2: return 0.12
		1: return 0.22
		_: return 0.12

func _ia_prob_castigo_por_nivel(cpu: Node) -> float:
	match _ia_nivel(cpu):
		2: return 0.96
		1: return 0.70
		_: return 0.48

func _ia_tiempo_reaccion_cpu(cpu: Node) -> float:
	match _ia_nivel(cpu):
		2: return randf_range(0.025, 0.055)
		1: return randf_range(0.095, 0.165)
		_: return randf_range(0.16, 0.25)

func _ia_prob_recovery_por_nivel(cpu: Node) -> float:
	match _ia_nivel(cpu):
		2: return 0.36
		1: return 0.46
		_: return 0.25

func _ia_duracion_bloqueo_por_nivel(cpu: Node) -> float:
	match _ia_nivel(cpu):
		2: return 0.12
		1: return IA_DURACION_BLOQUEO
		_: return 0.30


func _procesar_ia_tactica(delta: float) -> void:
	var ahora := _ahora()

	for id in _luchadores.keys():
		var cpu = _luchadores[id]
		if not is_instance_valid(cpu):
			continue
		if bool(cpu.get("controlado_por_jugador")):
			continue

		# 90.6.1 — KO absoluto para la capa táctica.
		# `vida <= 0` cubre también los frames previos a que Fighter termine
		# de marcar `esta_derrotado` y reproducir la caída.
		if _ia_cpu_fuera_de_combate(cpu):
			_cancelar_estado_tactico(cpu, id, "KO")
			continue

		if bool(cpu.get("en_secuencia_especial")) or bool(cpu.get("bloqueo_cinematico")):
			_cancelar_estado_tactico(cpu, id, "LOCK")
			continue

		# La presión baja poco a poco si el jugador deja respirar a la CPU.
		var presion: float = float(_ia_presion.get(id, 0.0))
		presion = maxf(0.0, presion - IA_PRESION_DECAY_POR_SEG * delta)
		_ia_presion[id] = presion

		# Tech de CPU: solo para reacciones largas y con probabilidad.
		_intentar_recovery_ia(cpu, ahora)

		if ahora < float(_ia_siguiente_decision.get(id, 0.0)):
			continue

		var rival = cpu.get("objetivo")
		if not is_instance_valid(rival):
			continue
		if bool(rival.get("esta_derrotado")):
			continue

		# Si el rival está ejecutando una secuencia CORE/cinemática O una
		# cadena normal ya confirmada, la CPU debe recibirla sin insertar
		# bloqueo, evasión ni respuesta táctica entre golpes.
		if _ia_rival_en_combo_protegido(rival):
			_cancelar_estado_tactico(cpu, id, "COMBO_LOCK")
			_ia_siguiente_decision[id] = ahora + 0.10
			continue

		var distancia: float = absf(rival.global_position.x - cpu.global_position.x)
		var cpu_neutral: bool = (
			int(cpu.get("fase_ataque")) == 0
			and float(cpu.get("hitstun_timer")) <= 0.0
			and not bool(cpu.get("bloqueando"))
		)
		var rival_atacando: bool = (
			int(rival.get("fase_ataque")) != 0
			or float(rival.get("pose_timer")) > 0.0
		)

		# REACCIÓN DEFENSIVA:
		# cuanto más presiona el jugador, más probable que la CPU se defienda.
		if cpu_neutral and rival_atacando and distancia <= IA_DISTANCIA_DEFENSA:
			var bloqueo_base_nivel: float = _ia_prob_bloqueo_por_nivel(cpu)
			var prob_bloqueo: float = clampf(
				bloqueo_base_nivel + presion * 0.075,
				bloqueo_base_nivel,
				0.82
			)

			# Bajo mucha presión puede crear espacio con Back Dash.
			if presion >= 2.0 and randf() < _ia_prob_backdash_por_nivel(cpu) and _puede_backdash(cpu):
				var dir_escape: float = _direccion_alejamiento(cpu)
				if dir_escape != 0.0:
					_iniciar_backdash(cpu, dir_escape)
					_ia_estado[id] = "EVADE"
					_ia_siguiente_decision[id] = ahora + 0.42
					continue

			if randf() < prob_bloqueo and cpu.has_method("_iniciar_bloqueo"):
				var dur_bloqueo_cpu: float = _ia_duracion_bloqueo_por_nivel(cpu)
				cpu.call("_iniciar_bloqueo", dur_bloqueo_cpu)
				_ia_estado[id] = "DEFENSA"
				# Difícil bloquea menos tiempo y transforma la defensa en castigo rápido.
				var espera_castigo: float = 0.025 if _ia_nivel(cpu) == 2 else 0.22
				_ia_castigo_hasta[id] = ahora + dur_bloqueo_cpu + espera_castigo
				_ia_siguiente_decision[id] = ahora + dur_bloqueo_cpu
				continue

		# CASTIGO:
		# después de una defensa táctica, si el rival sigue cerca y la CPU ya
		# está libre, puede responder con puño o patada.
		if String(_ia_estado.get(id, "NEUTRAL")) == "DEFENSA":
			if ahora >= float(_ia_castigo_hasta.get(id, 0.0)):
				if distancia <= IA_DISTANCIA_CASTIGO and float(cpu.get("hitstun_timer")) <= 0.0:
					_set_si_existe(cpu, "bloqueando", false)
					_set_si_existe(cpu, "bloqueo_timer", 0.0)

					if randf() < _ia_prob_castigo_por_nivel(cpu):
						if randf() < 0.55:
							if cpu.has_method("intentar_punetazo"):
								cpu.call("intentar_punetazo")
						else:
							if cpu.has_method("intentar_patada"):
								cpu.call("intentar_patada")
						_ia_estado[id] = "PUNISH"
						_ia_siguiente_decision[id] = ahora + 0.36
						continue

				_ia_estado[id] = "NEUTRAL"

		# Esta capa no fuerza aproximación ni recarga: eso sigue siendo trabajo
		# de la IA original del Fighter, evitando conflictos entre sistemas.
		_ia_siguiente_decision[id] = ahora + _ia_tiempo_reaccion_cpu(cpu)


func _registrar_impacto_ia(defensor: Node, tipo: String, bloqueado: bool) -> void:
	if not is_instance_valid(defensor):
		return

	var tipo_normal: bool = tipo == "punetazo" or tipo == "patada" or tipo == "golpe"
	if not tipo_normal:
		return

	var atacante = defensor.get("objetivo")

	# CPU recibió presión del jugador.
	if not bool(defensor.get("controlado_por_jugador")):
		var did: int = int(defensor.get_instance_id())

		if _ia_cpu_fuera_de_combate(defensor):
			_cancelar_estado_tactico(defensor, did, "KO")
			return

		if is_instance_valid(atacante) and _ia_rival_en_combo_protegido(atacante):
			# Registramos presión, pero NO armamos recovery/counter defensivo
			# que pueda cortar la secuencia.
			_ia_presion[did] = minf(
				IA_PRESION_MAX,
				float(_ia_presion.get(did, 0.0)) + (0.35 if bloqueado else 1.0)
			)
			return

		if bloqueado:
			_ia_presion[did] = minf(IA_PRESION_MAX, float(_ia_presion.get(did, 0.0)) + 0.35)
		else:
			_ia_presion[did] = minf(IA_PRESION_MAX, float(_ia_presion.get(did, 0.0)) + 1.0)

			# Los impactos limpios largos pueden habilitar Tech automático.
			var ahora := _ahora()
			if ahora >= float(_ia_recovery_cooldown_hasta.get(did, 0.0)):
				_ia_recovery_desde[did] = ahora + IA_RECOVERY_DELAY
				_ia_recovery_hasta[did] = ahora + IA_RECOVERY_DELAY + IA_RECOVERY_WINDOW

		return

	# Si la CPU consiguió golpear al jugador, baja su sensación de presión:
	# logró recuperar iniciativa.
	if is_instance_valid(atacante) and not bool(atacante.get("controlado_por_jugador")) and not bloqueado:
		var aid: int = int(atacante.get_instance_id())
		_ia_presion[aid] = maxf(0.0, float(_ia_presion.get(aid, 0.0)) - 1.25)
		_ia_estado[aid] = "NEUTRAL"


func _intentar_recovery_ia(cpu: Node, ahora: float) -> void:
	if not is_instance_valid(cpu):
		return
	if bool(cpu.get("controlado_por_jugador")):
		return
	if _ia_cpu_fuera_de_combate(cpu):
		return
	if bool(cpu.get("en_secuencia_especial")) or bool(cpu.get("bloqueo_cinematico")):
		return

	var rival = cpu.get("objetivo")
	if is_instance_valid(rival) and _ia_rival_en_combo_protegido(rival):
		return

	var id: int = int(cpu.get_instance_id())
	if ahora < float(_ia_recovery_desde.get(id, 0.0)):
		return
	if ahora > float(_ia_recovery_hasta.get(id, 0.0)):
		return
	if ahora < float(_ia_recovery_cooldown_hasta.get(id, 0.0)):
		return
	if not cpu.is_on_floor():
		return
	if float(cpu.get("hitstun_timer")) < RECOVERY_MIN_HITSTUN:
		return

	# Resolver una sola vez por ventana.
	_ia_recovery_desde[id] = 0.0
	_ia_recovery_hasta[id] = 0.0
	_ia_recovery_cooldown_hasta[id] = ahora + IA_RECOVERY_COOLDOWN

	if randf() > _ia_prob_recovery_por_nivel(cpu):
		return

	_set_si_existe(cpu, "hitstun_timer", 0.0)
	_set_si_existe(cpu, "_reaccion_impacto_timer", 0.0)
	_set_si_existe(cpu, "empuje_pendiente_timer", 0.0)
	_set_si_existe(cpu, "empuje_pendiente_fuerza", 0.0)
	_set_si_existe(cpu, "empuje_timer", 0.0)
	_set_si_existe(cpu, "empuje_x", 0.0)
	_set_si_existe(cpu, "absorcion_impacto_timer", 0.0)
	_set_si_existe(cpu, "impacto_visual_y", 0.0)
	_set_si_existe(cpu, "pose_timer", 0.0)

	var vel: Vector2 = cpu.get("velocity")
	vel.x = 0.0
	vel.y = 0.0
	cpu.set("velocity", vel)

	_ia_estado[id] = "RECOVER"


func _ia_tiempo_reaccion() -> float:
	return lerpf(IA_REACCION_MIN, IA_REACCION_MAX, randf())


func _armar_quick_recovery(luchador: Node) -> void:
	if not is_instance_valid(luchador):
		return
	if not bool(luchador.get("controlado_por_jugador")):
		return
	if bool(luchador.get("esta_derrotado")):
		return

	var id: int = int(luchador.get_instance_id())
	var ahora := _ahora()
	if ahora < float(_recovery_cooldown_hasta.get(id, 0.0)):
		return

	_recovery_desde[id] = ahora + RECOVERY_DELAY
	_recovery_hasta[id] = ahora + RECOVERY_DELAY + RECOVERY_WINDOW


func _intentar_quick_recovery(objetivo_input: Node = null) -> bool:
	var ahora := _ahora()

	for id in _luchadores.keys():
		var luchador = _luchadores[id]
		if not is_instance_valid(luchador):
			continue
		if objetivo_input != null and luchador != objetivo_input:
			continue
		if not bool(luchador.get("controlado_por_jugador")):
			continue
		if bool(luchador.get("esta_derrotado")):
			continue
		if bool(luchador.get("en_secuencia_especial")):
			continue
		if bool(luchador.get("bloqueo_cinematico")):
			continue
		if ahora < float(_recovery_desde.get(id, 0.0)):
			continue
		if ahora > float(_recovery_hasta.get(id, 0.0)):
			continue
		if ahora < float(_recovery_cooldown_hasta.get(id, 0.0)):
			continue
		if not luchador.is_on_floor():
			continue

		var stun_restante := _get_float(luchador, "hitstun_timer")
		if stun_restante < RECOVERY_MIN_HITSTUN:
			continue

		_recovery_desde[id] = 0.0
		_recovery_hasta[id] = 0.0
		_recovery_cooldown_hasta[id] = ahora + RECOVERY_COOLDOWN

		_set_si_existe(luchador, "hitstun_timer", 0.0)
		_set_si_existe(luchador, "_reaccion_impacto_timer", 0.0)
		_set_si_existe(luchador, "empuje_pendiente_timer", 0.0)
		_set_si_existe(luchador, "empuje_pendiente_fuerza", 0.0)
		_set_si_existe(luchador, "empuje_timer", 0.0)
		_set_si_existe(luchador, "empuje_x", 0.0)
		_set_si_existe(luchador, "absorcion_impacto_timer", 0.0)
		_set_si_existe(luchador, "impacto_visual_y", 0.0)
		_set_si_existe(luchador, "pose_timer", 0.0)

		var vel: Vector2 = luchador.get("velocity")
		vel.x = 0.0
		vel.y = 0.0
		luchador.set("velocity", vel)

		_mostrar_texto(luchador, "RECOVER!", Color(0.48, 1.0, 0.62, 1.0))
		return true

	return false


func _intentar_armar_launcher(objetivo_input: Node = null) -> bool:
	var ahora := _ahora()

	for id in _luchadores.keys():
		var luchador = _luchadores[id]
		if not is_instance_valid(luchador):
			continue
		if objetivo_input != null and luchador != objetivo_input:
			continue
		if not bool(luchador.get("controlado_por_jugador")):
			continue
		if bool(luchador.get("esta_derrotado")):
			continue
		if bool(luchador.get("bloqueando")):
			continue
		if bool(luchador.get("en_secuencia_especial")) or bool(luchador.get("bloqueo_cinematico")):
			continue
		if ahora < float(_launcher_cooldown_hasta.get(id, 0.0)):
			continue

		# Se acepta en suelo o en el primer instante del salto, para no depender
		# del orden exacto entre el Autoload y _physics_process de Fighter.
		var vel: Vector2 = luchador.get("velocity")
		var acaba_de_saltar: bool = int(luchador.get("saltos_usados")) == 1 and vel.y < 0.0
		if not luchador.is_on_floor() and not acaba_de_saltar:
			continue

		_launcher_armado_hasta[id] = ahora + VENTANA_LAUNCHER_ARMADO
		_launcher_cooldown_hasta[id] = ahora + COOLDOWN_LAUNCHER

		# Si todavía está físicamente en el piso, arrancamos la persecución con
		# el salto normal del propio personaje. Fighter evita duplicarlo.
		if luchador.is_on_floor() and luchador.has_method("saltar"):
			luchador.call("saltar")

		# Usamos el puñetazo normal del personaje: conserva su sprite, hitbox,
		# daño, CORE y timings existentes.
		if luchador.has_method("intentar_punetazo"):
			luchador.call("intentar_punetazo")

		return true

	return false


func _consumir_launcher_si_corresponde(atacante: Node, defensor: Node, tipo: String) -> bool:
	if tipo != "punetazo":
		return false
	if not is_instance_valid(atacante) or not is_instance_valid(defensor):
		return false
	if not bool(atacante.get("controlado_por_jugador")):
		return false

	var aid := atacante.get_instance_id()
	if _ahora() > float(_launcher_armado_hasta.get(aid, 0.0)):
		return false

	_launcher_armado_hasta[aid] = 0.0

	# Lanzamiento vertical del rival. Se conserva una pequeña velocidad
	# horizontal, sin activar estados de derribo especial ni tocar escalas.
	var vel_def: Vector2 = defensor.get("velocity")
	vel_def.y = FUERZA_LAUNCH_VERTICAL
	vel_def.x *= 0.30
	defensor.set("velocity", vel_def)

	# El hit-stun debe durar lo suficiente para que el rival permanezca
	# vulnerable mientras asciende, pero sin convertirlo en una cinemática.
	_set_si_existe(defensor, "hitstun_timer",
		maxf(_get_float(defensor, "hitstun_timer"), 0.54))
	_set_si_existe(defensor, "empuje_pendiente_timer", 0.0)
	_set_si_existe(defensor, "empuje_pendiente_fuerza", 0.0)
	_set_si_existe(defensor, "empuje_timer", 0.0)
	_set_si_existe(defensor, "empuje_x", 0.0)

	# Persecución: el atacante recibe una subida controlada y un pequeño
	# impulso horizontal hacia el rival.
	var vel_atk: Vector2 = atacante.get("velocity")
	vel_atk.y = minf(vel_atk.y, FUERZA_PERSECUCION_VERTICAL)
	var dx: float = defensor.global_position.x - atacante.global_position.x
	if absf(dx) > 2.0:
		vel_atk.x = signf(dx) * VELOCIDAD_PERSECUCION_HORIZONTAL
		atacante.set("mirando", signf(dx))
	atacante.set("velocity", vel_atk)

	# Abrir sistema de Air Combo.
	_air_combo_activo[aid] = true
	_air_combo_hasta[aid] = _ahora() + VENTANA_AIR_COMBO
	_air_combo_golpes[aid] = 0
	_combo_proteccion_hasta[aid] = _ahora() + 0.72

	# H6 — sello sólo cuando el golpe ARMADO realmente conectó y lanzó.
	_rollback_launcher_event_serial += 1
	_rollback_launcher_event_attacker_id = int(aid)
	_rollback_launcher_event_defender_id = int(defensor.get_instance_id())
	print("[91.00.00-H10.2] LAUNCHER EVENT MARCADO — serial=%d atacante=%d defensor=%d" % [
		_rollback_launcher_event_serial,
		_rollback_launcher_event_attacker_id,
		_rollback_launcher_event_defender_id
	])

	_mostrar_texto(atacante, "LAUNCH!", Color(1.0, 0.45, 0.16, 1.0))
	return true


func _registrar_air_hit_si_corresponde(atacante: Node, defensor: Node) -> void:
	if not is_instance_valid(atacante) or not is_instance_valid(defensor):
		return

	var aid := atacante.get_instance_id()
	if not bool(_air_combo_activo.get(aid, false)):
		return
	if _ahora() > float(_air_combo_hasta.get(aid, 0.0)):
		_air_combo_activo[aid] = false
		return
	if atacante.is_on_floor():
		return

	var golpes := int(_air_combo_golpes.get(aid, 0)) + 1
	_air_combo_golpes[aid] = golpes

	# Cada golpe aéreo sostiene un poco al rival para que la secuencia sea
	# legible y no caiga fuera de alcance instantáneamente.
	var vel_def: Vector2 = defensor.get("velocity")
	vel_def.y = minf(vel_def.y, EMPUJE_VERTICAL_AIR_HIT)
	defensor.set("velocity", vel_def)
	_set_si_existe(defensor, "hitstun_timer",
		maxf(_get_float(defensor, "hitstun_timer"), 0.30 * MULT_HITSTUN_AEREO))

	# Corrección horizontal suave del atacante para seguir al rival.
	var dx: float = defensor.global_position.x - atacante.global_position.x
	var vel_atk: Vector2 = atacante.get("velocity")
	if absf(dx) > 18.0:
		vel_atk.x = signf(dx) * 105.0
		atacante.set("mirando", signf(dx))
	atacante.set("velocity", vel_atk)

	# H6 — sello de impacto aéreo REAL, después de aplicar su estado lógico.
	_rollback_airhit_event_serial += 1
	_rollback_airhit_event_attacker_id = int(aid)
	_rollback_airhit_event_defender_id = int(defensor.get_instance_id())
	_rollback_airhit_event_count = golpes
	print("[91.00.00-H10.2] AIR HIT EVENT MARCADO — serial=%d atacante=%d defensor=%d air_x=%d" % [
		_rollback_airhit_event_serial,
		_rollback_airhit_event_attacker_id,
		_rollback_airhit_event_defender_id,
		_rollback_airhit_event_count
	])

	_mostrar_texto(atacante, "AIR x%d" % golpes, Color(0.58, 0.90, 1.0, 1.0))

	if golpes >= MAX_GOLPES_AEREOS:
		_air_combo_activo[aid] = false
		_combo_cancel_disponible[aid] = false
		_combo_proteccion_hasta[aid] = _ahora() + 0.18
	else:
		_air_combo_hasta[aid] = _ahora() + 0.55
		_combo_proteccion_hasta[aid] = _ahora() + 0.62


# 90.11.04 — contra CPU, un segundo botón puede llegar unas centésimas ANTES
# del impacto porque el rival se mueve. Fighter 90.10.94 ya conserva ese tap en
# `ataque_buffer_tipo`; aquí lo promovemos al cancel rápido que sí ocurre cuando
# el rival está quieto/contra la pared. Se difiere para no cambiar de ataque
# dentro del callback síncrono del impacto actual.
func _programar_buffer_combo_vs_ia(atacante: Node, defensor: Node) -> void:
	if not is_instance_valid(atacante) or not is_instance_valid(defensor):
		return
	if bool(defensor.get("controlado_por_jugador")):
		return
	if not bool(atacante.get("controlado_por_jugador")):
		return
	if not _tiene_propiedad(atacante, "ataque_buffer_tipo") \
		or not _tiene_propiedad(atacante, "ataque_buffer_timer"):
		return

	var tipo: String = String(atacante.get("ataque_buffer_tipo"))
	var restante: float = float(atacante.get("ataque_buffer_timer"))
	if restante <= 0.0 or (tipo != "punetazo" and tipo != "patada"):
		return

	var aid: int = int(atacante.get_instance_id())
	if not bool(_combo_cancel_disponible.get(aid, false)):
		return

	# Lo consume este módulo; Fighter no debe volver a dispararlo al terminar
	# el recovery normal, porque justamente queremos CANCELAR ese recovery.
	atacante.set("ataque_buffer_tipo", "")
	atacante.set("ataque_buffer_timer", 0.0)
	_combo_buffer_ia_diferido[aid] = tipo
	call_deferred("_ejecutar_buffer_combo_vs_ia", aid)


func _ejecutar_buffer_combo_vs_ia(aid: int) -> void:
	var tipo: String = String(_combo_buffer_ia_diferido.get(aid, ""))
	_combo_buffer_ia_diferido.erase(aid)
	if tipo != "punetazo" and tipo != "patada":
		return
	if not _luchadores.has(aid):
		return
	var atacante = _luchadores[aid]
	if not is_instance_valid(atacante):
		return
	_intentar_combo_cancel(tipo, atacante)


# Una vez CONFIRMADO un Combo Cancel contra CPU, anulamos solamente el empuje
# horizontal pendiente del impacto anterior. El hitstun y la reacción visual se
# conservan. Así x2/x3 tiene la misma continuidad que contra una pared, pero el
# último golpe de la cadena vuelve a usar su knockback normal.
func _preparar_cpu_para_combo_cancel(atacante: Node) -> void:
	if not is_instance_valid(atacante):
		return
	var cpu = atacante.get("objetivo")
	if not is_instance_valid(cpu) or bool(cpu.get("controlado_por_jugador")):
		return

	# 90.11.06 — IMPORTANTE: esto corre ANTES de iniciar el segundo golpe.
	# Así _iniciar_ataque() calcula su lunge desde la distancia correcta y conserva
	# exactamente el timing/impulso normal que ya se siente bien en Versus Local.
	_set_si_existe(cpu, "empuje_pendiente_timer", 0.0)
	_set_si_existe(cpu, "empuje_pendiente_fuerza", 0.0)
	_set_si_existe(cpu, "empuje_timer", 0.0)
	_set_si_existe(cpu, "empuje_x", 0.0)

	# La separación post-impacto común ya cumplió su función visual en el primer hit.
	# Contra una CPU móvil puede quedar sosteniendo un hueco extra justo cuando el
	# jugador confirma x2. Se limpia SOLO en ese caso confirmado.
	_set_si_existe(cpu, "contacto_post_golpe_timer", 0.0)
	_set_si_existe(cpu, "contacto_post_golpe_distancia", 0.0)
	_set_si_existe(atacante, "contacto_post_golpe_timer", 0.0)
	_set_si_existe(atacante, "contacto_post_golpe_distancia", 0.0)

	# No aumentamos hitstun. El golpe recibido conserva el mismo hitstun del Fighter
	# que tendría un J2 humano. Sólo apagamos estados exclusivos de IA.
	_set_si_existe(cpu, "bloqueando", false)
	_set_si_existe(cpu, "bloqueo_timer", 0.0)
	_set_si_existe(cpu, "ia_retrocediendo", false)
	_set_si_existe(cpu, "ia_mantener_distancia", false)
	if cpu.has_method("_detener_carrera"):
		cpu.call("_detener_carrera")

	if _tiene_propiedad(cpu, "velocity"):
		var vel_cpu: Vector2 = cpu.get("velocity")
		vel_cpu.x = 0.0
		cpu.set("velocity", vel_cpu)

	# Cerrar ÚNICAMENTE el hueco extra. Nunca alejamos a los luchadores si ya están
	# compactos. El defensor no se teletransporta: se corrige al atacante, que es
	# quien está encadenando el golpe.
	var lado: float = signf(float(cpu.global_position.x) - float(atacante.global_position.x))
	if lado == 0.0:
		lado = signf(_get_float(atacante, "mirando"))
	if lado == 0.0:
		lado = 1.0

	var distancia_lock: float = 82.0
	if atacante.has_method("_distancia_precontacto_adaptativa"):
		distancia_lock = float(atacante.call("_distancia_precontacto_adaptativa", cpu, atacante))
	distancia_lock = clampf(distancia_lock, 78.0, 88.0)

	var distancia_actual: float = absf(float(cpu.global_position.x) - float(atacante.global_position.x))
	if distancia_actual > distancia_lock:
		atacante.global_position.x = cpu.global_position.x - lado * distancia_lock
		if atacante.has_method("_aplicar_limites_arena"):
			atacante.call("_aplicar_limites_arena")

	# Fighter aplica el lock en SU propia rutina de IA, no sólo en la capa táctica.
	# Dura apenas lo necesario para que el segundo startup entre; se refresca en x3.
	if cpu.has_method("activar_lock_recepcion_combo_cancel_cpu"):
		cpu.call("activar_lock_recepcion_combo_cancel_cpu", 0.26)

	# La capa táctica externa también queda en silencio durante la misma ráfaga.
	var cid: int = int(cpu.get_instance_id())
	_ia_estado[cid] = "COMBO_LOCK"
	_ia_siguiente_decision[cid] = _ahora() + 0.26
	_ia_castigo_hasta[cid] = 0.0
	_ia_recovery_desde[cid] = 0.0
	_ia_recovery_hasta[cid] = 0.0


func _abrir_combo_cancel(atacante: Node) -> void:
	if not is_instance_valid(atacante):
		return
	if bool(atacante.get("esta_derrotado")):
		return

	var id := atacante.get_instance_id()
	var ahora := _ahora()
	var en_air_combo: bool = bool(_air_combo_activo.get(id, false)) and not atacante.is_on_floor()

	# En persecución aérea, la cadena usa su propio contador de impactos.
	# No hereda el límite/cooldown del combo terrestre.
	if en_air_combo:
		if ahora > float(_air_combo_hasta.get(id, 0.0)):
			_air_combo_activo[id] = false
			_combo_cancel_disponible[id] = false
			return
		if int(_air_combo_golpes.get(id, 0)) >= MAX_GOLPES_AEREOS:
			_combo_cancel_disponible[id] = false
			return
		_combo_cancel_disponible[id] = true
		_combo_cancel_hasta[id] = ahora + VENTANA_COMBO_CANCEL
		return

	# Cadena terrestre normal.
	if ahora > float(_combo_cancel_hasta.get(id, 0.0)) + COOLDOWN_FIN_CADENA:
		_combo_cancel_cadena[id] = 1
	elif int(_combo_cancel_cadena.get(id, 0)) <= 0:
		_combo_cancel_cadena[id] = 1

	if int(_combo_cancel_cadena.get(id, 0)) >= MAX_GOLPES_CANCEL:
		_combo_cancel_disponible[id] = false
		_combo_cancel_bloqueado_hasta[id] = ahora + COOLDOWN_FIN_CADENA
		return

	if ahora < float(_combo_cancel_bloqueado_hasta.get(id, 0.0)):
		return

	_combo_cancel_disponible[id] = true
	_combo_cancel_hasta[id] = ahora + VENTANA_COMBO_CANCEL
	_combo_proteccion_hasta[id] = ahora + IA_PROTECCION_COMBO

	# 90.11.07 — ésta es la diferencia observada en video. La capa táctica ya
	# respetaba _combo_proteccion_hasta, pero el Fighter CPU podía volver a su
	# IA básica apenas terminaba el hitstun del primer golpe, justo antes de que
	# el jugador confirmara X/C. En Versus el defensor humano neutral no inserta
	# automáticamente bloqueo/retroceso en ese único frame. Silenciamos SOLAMENTE
	# la IA interna durante la misma ventana que el jugador tiene para cancelar.
	# Si no llega un segundo input, el lock vence enseguida y la CPU vuelve normal.
	var defensor_cpu = atacante.get("objetivo")
	if is_instance_valid(defensor_cpu) and not bool(defensor_cpu.get("controlado_por_jugador")):
		var did_cpu: int = int(defensor_cpu.get_instance_id())
		# 91.02.40 — cualquier Tech/recovery táctico armado por el primer impacto
		# se cancela mientras el jugador conserva la ventana x2/x3. No se modifica
		# el hitstun del Fighter ni la física común.
		_ia_recovery_desde[did_cpu] = 0.0
		_ia_recovery_hasta[did_cpu] = 0.0
		_ia_estado[did_cpu] = "COMBO_LOCK"
		_ia_siguiente_decision[did_cpu] = _ahora() + VENTANA_COMBO_CANCEL + 0.10
		if defensor_cpu.has_method("activar_lock_recepcion_combo_cancel_cpu"):
			# +0.10 cubre también el startup del siguiente golpe; 90.11.07 usaba
			# +0.04 y todavía podía liberar la IA unas centésimas antes del impacto.
			defensor_cpu.call("activar_lock_recepcion_combo_cancel_cpu", VENTANA_COMBO_CANCEL + 0.10)


func _intentar_combo_cancel(tipo: String, objetivo_input: Node = null) -> bool:
	var ahora := _ahora()

	for id in _luchadores.keys():
		var luchador = _luchadores[id]
		if not is_instance_valid(luchador):
			continue
		if objetivo_input != null and luchador != objetivo_input:
			continue
		if not bool(luchador.get("controlado_por_jugador")):
			continue
		if not bool(_combo_cancel_disponible.get(id, false)):
			continue
		if ahora > float(_combo_cancel_hasta.get(id, 0.0)):
			_combo_cancel_disponible[id] = false
			continue
		if bool(luchador.get("esta_derrotado")):
			_combo_cancel_disponible[id] = false
			continue
		if bool(luchador.get("en_secuencia_especial")):
			_combo_cancel_disponible[id] = false
			continue
		var es_aereo: bool = not luchador.is_on_floor()
		if not es_aereo and ahora < float(_combo_cancel_bloqueado_hasta.get(id, 0.0)):
			continue
		if es_aereo:
			if not bool(_air_combo_activo.get(id, false)):
				continue
			if _ahora() > float(_air_combo_hasta.get(id, 0.0)):
				_air_combo_activo[id] = false
				continue
			if int(_air_combo_golpes.get(id, 0)) >= MAX_GOLPES_AEREOS:
				continue

		var cadena_actual := int(_combo_cancel_cadena.get(id, 1))
		if not es_aereo and cadena_actual >= MAX_GOLPES_CANCEL:
			_combo_cancel_disponible[id] = false
			continue

		_combo_cancel_disponible[id] = false
		_combo_cancel_hasta[id] = 0.0
		_combo_proteccion_hasta[id] = ahora + IA_PROTECCION_COMBO

		# 90.11.06 — si el defensor es CPU, recomponemos el contacto ANTES de
		# iniciar el siguiente golpe. En Versus Local esta función no hace nada.
		if not es_aereo:
			_preparar_cpu_para_combo_cancel(luchador)

		# Cancelar SOLO la recuperación del golpe normal vigente.
		# No se toca ningún especial ni CORE.
		_set_si_existe(luchador, "timer_fase_ataque", 0.0)
		_set_si_existe(luchador, "pose_timer", 0.0)
		_set_si_existe(luchador, "hitstop_timer", 0.0)

		# phase/fase_ataque usa 0 como reposo en Fighter.
		_set_si_existe(luchador, "fase_ataque", 0)

		if tipo == "punetazo":
			luchador.call("intentar_punetazo")
		else:
			luchador.call("intentar_patada")

		if not es_aereo:
			# El segundo golpe ya arrancó desde el contacto recompuesto. No tocamos
			# su velocity ni su lunge después de iniciarlo.
			_combo_cancel_cadena[id] = cadena_actual + 1
			var numero := int(_combo_cancel_cadena[id])
			_mostrar_texto(luchador, "COMBO x%d" % numero, Color(1.0, 0.62, 0.22, 1.0))

		# El input fue consumido tanto en suelo como en aire.
		return true

	return false


func _mostrar_texto(luchador: Node, texto: String, color: Color) -> void:
	if not is_instance_valid(luchador):
		return

	# 91.05.03 PASS 2C — sólo presentación.
	# El evento táctico ya no se dibuja sobre el cuerpo del luchador: Main lo
	# presenta debajo del nombre correspondiente en el HUD. Gameplay intacto.
	var escena := get_tree().current_scene
	if escena != null and escena.has_method("_mostrar_evento_hud"):
		escena.call("_mostrar_evento_hud", luchador, texto, color)
		return

	# Fallback seguro si este módulo alguna vez se usa fuera de Main.
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.z_index = 100
	var altura := 255.0
	if luchador.has_method("_altura_visible_objetivo"):
		altura = float(luchador.call("_altura_visible_objetivo"))
	etiqueta.position = Vector2(-68.0, -altura - 42.0)
	etiqueta.add_theme_font_size_override("font_size", 28)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.90))
	etiqueta.add_theme_constant_override("shadow_offset_x", 2)
	etiqueta.add_theme_constant_override("shadow_offset_y", 2)
	luchador.add_child(etiqueta)
	var destino := etiqueta.position + Vector2(0.0, -20.0)
	var tween := etiqueta.create_tween()
	tween.set_parallel(true)
	tween.tween_property(etiqueta, "position", destino, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(etiqueta, "modulate:a", 0.0, 0.32).set_delay(0.10)
	tween.chain().tween_callback(etiqueta.queue_free)

func _tiene_propiedad(objeto: Object, nombre: String) -> bool:
	for item in objeto.get_property_list():
		if String(item.get("name", "")) == nombre:
			return true
	return false


func _get_float(objeto: Object, nombre: String) -> float:
	if not _tiene_propiedad(objeto, nombre):
		return 0.0
	return float(objeto.get(nombre))


func _set_si_existe(objeto: Object, nombre: String, valor) -> void:
	if _tiene_propiedad(objeto, nombre):
		objeto.set(nombre, valor)


func _limpiar_referencias_invalidas() -> void:
	for id in _luchadores.keys():
		if not is_instance_valid(_luchadores[id]):
			_luchadores.erase(id)
			_ventana_hasta.erase(id)
			_counter_hasta.erase(id)
			_counter_disponible.erase(id)
			_backdash_timer.erase(id)
			_backdash_direccion.erase(id)
			_backdash_invuln_hasta.erase(id)
			_backdash_cooldown_hasta.erase(id)
			_input_previo_por_id.erase(id)
			_ultimo_toque_izq_por_id.erase(id)
			_ultimo_toque_der_por_id.erase(id)
			_combo_cancel_hasta.erase(id)
			_combo_cancel_disponible.erase(id)
			_combo_cancel_cadena.erase(id)
			_combo_cancel_bloqueado_hasta.erase(id)
			_launcher_armado_hasta.erase(id)
			_launcher_cooldown_hasta.erase(id)
			_air_combo_activo.erase(id)
			_air_combo_hasta.erase(id)
			_air_combo_golpes.erase(id)
			_recovery_desde.erase(id)
			_recovery_hasta.erase(id)
			_recovery_cooldown_hasta.erase(id)

			_ia_siguiente_decision.erase(id)
			_ia_estado.erase(id)
			_ia_presion.erase(id)
			_ia_castigo_hasta.erase(id)
			_ia_recovery_desde.erase(id)
			_ia_recovery_hasta.erase(id)
			_ia_recovery_cooldown_hasta.erase(id)
			_combo_proteccion_hasta.erase(id)
			_combo_buffer_ia_diferido.erase(id)
			_aethel_patada_tex_id.erase(id)
			_aethel_patada_escala.erase(id)

			_vida_antes.erase(id)


func _avanzar_reloj_tactico(delta: float) -> void:
	# Godot escala delta con Engine.time_scale. Dividir por la escala conserva
	# aproximadamente la duración real que tenía el sistema anterior, pero ahora
	# el resultado depende exclusivamente de pasos de simulación reproducibles.
	var escala := absf(float(Engine.time_scale))
	var paso := delta
	if escala > 0.000001:
		paso = delta / escala
	elif Engine.physics_ticks_per_second > 0:
		paso = 1.0 / float(Engine.physics_ticks_per_second)

	_rollback_tactical_clock_ticks += 1
	_rollback_tactical_clock_seconds += paso


func _ahora() -> float:
	return _rollback_tactical_clock_seconds
