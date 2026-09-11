class_name RollbackNeutralMotionGuard
extends Node

# CORE AWAKENED 91.00.00-H
#
# LIVE:
#   nodo pasivo -> `if not activo: return`
#
# ROLLBACK:
#   ya NO reconstruimos X con una estimación nativa del mismo physics tick.
#   Usamos directamente la X histórica del snapshot del tick siguiente.
#
# Protección:
#   sólo corregimos X cuando el estado lógico actual coincide con el histórico
#   final. Si velocity/dash/aire/etc. divergen, NO corregimos.

const DISTANCIA_SEGURA := 150.0
const MARGEN_BORDE := 28.0
const ARENA_IZQ := 110.0
const ARENA_DER := 1170.0

const TOL_VEL := 0.02
const TOL_Y := 0.02

var j1: CharacterBody2D = null
var j2: CharacterBody2D = null
var objetivos_j1: Array[Dictionary] = []
var objetivos_j2: Array[Dictionary] = []
var indice := 0
var activo := false

func configurar(_main_node: Node, fighter1: CharacterBody2D, fighter2: CharacterBody2D) -> void:
	j1 = fighter1
	j2 = fighter2
	process_physics_priority = 1000
	# Registrado desde el inicio para actuar en el MISMO tick de F11.
	# En LIVE sólo hace un bool + return.
	set_physics_process(true)

func _estado_seguro_inicio(estado: Dictionary, otro: Dictionary) -> bool:
	var p: Vector2 = estado.get("position", Vector2.ZERO)
	var po: Vector2 = otro.get("position", Vector2.ZERO)

	if absf(po.x - p.x) < DISTANCIA_SEGURA:
		return false
	if p.x <= ARENA_IZQ + MARGEN_BORDE or p.x >= ARENA_DER - MARGEN_BORDE:
		return false

	if bool(estado.get("esta_derrotado", false)):
		return false
	if bool(estado.get("derribo_especial_activo", false)):
		return false
	if bool(estado.get("en_secuencia_especial", false)):
		return false
	if bool(estado.get("bloqueo_cinematico", false)):
		return false
	if bool(estado.get("congelado_por_rival", false)):
		return false
	if bool(estado.get("bloqueando", false)):
		return false
	if int(estado.get("fase_ataque", 0)) != 0:
		return false
	if float(estado.get("hitstun_timer", 0.0)) > 0.0:
		return false
	if float(estado.get("empuje_timer", 0.0)) > 0.0:
		return false
	if float(estado.get("empuje_pendiente_timer", 0.0)) > 0.0:
		return false
	if float(estado.get("contacto_post_golpe_timer", 0.0)) > 0.0:
		return false

	return true

func _objetivo_desde(inicio: Dictionary, fin: Dictionary, otro_inicio: Dictionary) -> Dictionary:
	return {
		"seguro": _estado_seguro_inicio(inicio, otro_inicio),
		"x": float((fin.get("position", Vector2.ZERO) as Vector2).x),
		"y": float((fin.get("position", Vector2.ZERO) as Vector2).y),
		"velocity": fin.get("velocity", Vector2.ZERO),
		"carrera_activa": bool(fin.get("carrera_activa", false)),
		"carrera_direccion": float(fin.get("carrera_direccion", 0.0)),
		"dash_aereo_activo": bool(fin.get("dash_aereo_activo", false)),
		"dash_aereo_direccion": float(fin.get("dash_aereo_direccion", 0.0)),
		"en_el_aire": bool(fin.get("en_el_aire", false)),
		"saltos_usados": int(fin.get("saltos_usados", 0)),
		"fase_ataque": int(fin.get("fase_ataque", 0)),
		"hitstun_timer": float(fin.get("hitstun_timer", 0.0)),
		"bloqueando": bool(fin.get("bloqueando", false)),
	}

func preparar_rollback(ventana: Array[Dictionary], presente: Dictionary) -> void:
	objetivos_j1.clear()
	objetivos_j2.clear()
	indice = 0
	activo = false

	if ventana.is_empty() or not is_instance_valid(j1) or not is_instance_valid(j2):
		return

	for i in range(ventana.size()):
		var inicio_total: Dictionary = ventana[i].get("snapshot", {})
		var fin_total: Dictionary = presente if i == ventana.size() - 1 else ventana[i + 1].get("snapshot", {})

		var a1: Dictionary = inicio_total.get("j1", {})
		var a2: Dictionary = inicio_total.get("j2", {})
		var b1: Dictionary = fin_total.get("j1", {})
		var b2: Dictionary = fin_total.get("j2", {})

		objetivos_j1.append(_objetivo_desde(a1, b1, a2))
		objetivos_j2.append(_objetivo_desde(a2, b2, a1))

	activo = true

func cancelar() -> void:
	activo = false
	indice = 0

func _prop(obj: Object, nombre: String, fallback = null):
	if obj == null:
		return fallback
	for info in obj.get_property_list():
		if str(info.get("name", "")) == nombre:
			return obj.get(nombre)
	return fallback

func _estado_logico_final_coincide(f: CharacterBody2D, objetivo: Dictionary) -> bool:
	if not bool(objetivo.get("seguro", false)):
		return false

	var vel_esp: Vector2 = objetivo.get("velocity", Vector2.ZERO)
	if absf(f.velocity.x - vel_esp.x) > TOL_VEL or absf(f.velocity.y - vel_esp.y) > TOL_VEL:
		return false
	if absf(f.position.y - float(objetivo.get("y", f.position.y))) > TOL_Y:
		return false

	if bool(_prop(f, "carrera_activa", false)) != bool(objetivo.get("carrera_activa", false)):
		return false
	if absf(float(_prop(f, "carrera_direccion", 0.0)) - float(objetivo.get("carrera_direccion", 0.0))) > 0.001:
		return false
	if bool(_prop(f, "dash_aereo_activo", false)) != bool(objetivo.get("dash_aereo_activo", false)):
		return false
	if absf(float(_prop(f, "dash_aereo_direccion", 0.0)) - float(objetivo.get("dash_aereo_direccion", 0.0))) > 0.001:
		return false
	if bool(_prop(f, "en_el_aire", false)) != bool(objetivo.get("en_el_aire", false)):
		return false
	if int(_prop(f, "saltos_usados", 0)) != int(objetivo.get("saltos_usados", 0)):
		return false
	if int(_prop(f, "fase_ataque", 0)) != int(objetivo.get("fase_ataque", 0)):
		return false
	if absf(float(_prop(f, "hitstun_timer", 0.0)) - float(objetivo.get("hitstun_timer", 0.0))) > 0.001:
		return false
	if bool(_prop(f, "bloqueando", false)) != bool(objetivo.get("bloqueando", false)):
		return false

	return true

func _aplicar_x_historica(f: CharacterBody2D, objetivo: Dictionary, etiqueta: String) -> void:
	if not is_instance_valid(f):
		return
	if not _estado_logico_final_coincide(f, objetivo):
		return

	var x_obj := float(objetivo.get("x", f.position.x))
	var correccion := x_obj - f.position.x
	if absf(correccion) <= 0.0005:
		return

	f.position.x = x_obj
	f.reset_physics_interpolation()

	print("[91.00.00-H10.2] X NATIVA HISTÓRICA RESTAURADA %s — corrección %.4f px" % [
		etiqueta, correccion
	])

func _physics_process(_delta: float) -> void:
	# Gameplay LIVE: costo mínimo.
	if not activo:
		return

	if indice >= objetivos_j1.size():
		cancelar()
		return

	_aplicar_x_historica(j1, objetivos_j1[indice], "J1")
	_aplicar_x_historica(j2, objetivos_j2[indice], "J2")

	indice += 1
	if indice >= objetivos_j1.size():
		cancelar()
