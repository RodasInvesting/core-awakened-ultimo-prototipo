class_name Virgilio
extends Fighter

# CORE AWAKENED 91.04.00 — VIRGILIO
# Homenaje al soldado paraguayo de la Guerra del Chaco.
# Integracion aditiva: reutiliza la fisica, FSM, CORE, IA y rollback genericos de Fighter.
# PASS 1: alta completa del luchador usando exclusivamente recursos entregados.

var textura_remate_core2_cuerpo: Texture2D = null
var textura_remate_core3_cuerpo: Texture2D = null

func _init() -> void:
	nombre_luchador = "Virgilio"
	color_base = Color(0.32, 0.42, 0.20)
	color_fase = Color(0.88, 0.92, 0.72)

	# Perfil equilibrado/robusto para primera prueba. Balance fino queda para QA.
	velocidad = 294.0
	fuerza_salto = -442.0
	gravedad = 1120.0
	dano_punetazo = 8.7
	dano_patada = 13.0
	cooldown_punetazo = 0.21
	cooldown_patada = 0.52
	poder_por_golpe = 13.5
	combo_core_remix_prioriza_patadas = true
	combo_core_remix_patadas_objetivo = 2
	ia_prob_patada = 0.39
	ia_prob_bloqueo = 0.29
	ia_prob_retroceso = 0.18
	vida_maxima = 220.0
	vida = 220.0
	aceleracion = 3560.0
	friccion_suelo = 3700.0
	friccion_aire = 1800.0
	peso_golpe = 1.04
	escala_sprite = 0.63

	textura_parado = load("res://assets/virgilio/parado.png")

	# Seis golpes normales de brazo.
	textura_punetazo = load("res://assets/virgilio/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/virgilio/punetazo_2.png"),
		load("res://assets/virgilio/punetazo_3.png"),
		load("res://assets/virgilio/punetazo_4.png"),
		load("res://assets/virgilio/punetazo_5.png"),
		load("res://assets/virgilio/punetazo_6.png"),
	]

	# Dos patadas + rodillazo entregados.
	textura_patada = load("res://assets/virgilio/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/virgilio/patada_2.png"),
		load("res://assets/virgilio/patada_3.png"),
	]

	texturas_caminata = [
		load("res://assets/virgilio/caminata_1.png"),
		load("res://assets/virgilio/caminata_2.png"),
	]
	textura_bloqueo = load("res://assets/virgilio/bloqueo.png")
	textura_carrera = load("res://assets/virgilio/carrera.png")
	# El back dash entregado se usa como pose oficial de evasion.
	textura_evasion = load("res://assets/virgilio/back_dash.png")
	textura_salto = load("res://assets/virgilio/salto.png")
	textura_doble_salto = load("res://assets/virgilio/doble_salto.png")
	textura_descenso = load("res://assets/virgilio/descenso.png")

	textura_golpe_recibido = load("res://assets/virgilio/golpe_recibido_1.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/virgilio/golpe_recibido_2.png"),
		load("res://assets/virgilio/golpe_recibido_3.png"),
	]
	textura_derribado = load("res://assets/virgilio/derribado.png")
	textura_recarga = load("res://assets/virgilio/recarga.png")
	textura_victoria = load("res://assets/virgilio/victoria.png")

	# Gigantografias CORE oficiales entregadas.
	textura_especial = load("res://assets/virgilio/core_1.png")
	textura_rematador = load("res://assets/virgilio/core_2.png")
	textura_absoluto = load("res://assets/virgilio/core_3.png")
	textura_remate_core2_cuerpo = load("res://assets/virgilio/combo_2.png")
	textura_remate_core3_cuerpo = load("res://assets/virgilio/combo_6.png")

	# Los seis cuadros COMBO se reutilizan como repertorio de Furia/CORE.
	textura_furia_parado = textura_recarga
	textura_furia_caminata_der = texturas_caminata[0]
	textura_furia_caminata_izq = texturas_caminata[1]
	textura_furia_carrera = textura_carrera
	textura_furia_evasion = textura_evasion
	textura_furia_salto = textura_salto
	textura_furia_doble_salto = textura_doble_salto
	textura_furia_descenso = textura_descenso
	textura_furia_bloqueo = textura_bloqueo
	textura_furia_punetazo = load("res://assets/virgilio/combo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/virgilio/combo_2.png"),
		load("res://assets/virgilio/combo_3.png"),
		load("res://assets/virgilio/combo_4.png"),
	]
	textura_furia_patada = load("res://assets/virgilio/combo_5.png")
	texturas_furia_patada_extra = [load("res://assets/virgilio/combo_6.png")]
	textura_furia_golpe_recibido = textura_golpe_recibido
	textura_furia_derribado = textura_derribado

	# Proyectil: usa exactamente la capa generica certificada del roster.
	proyectil_especial_habilitado = true
	textura_proyectil_pose = load("res://assets/virgilio/proyectil_pose.png")
	textura_proyectil_nucleo = load("res://assets/proyectiles/virgilio_proyectil.png")
	proyectil_pose_escala_mult = 1.00
	color_proyectil_primario = Color(0.92, 0.10, 0.12, 1.0)
	color_proyectil_secundario = Color(0.12, 0.34, 1.0, 1.0)
	proyectil_velocidad = 805.0
	proyectil_dano_mult = 0.86
	proyectil_empuje = 148.0
	proyectil_hitstun = 0.22
	proyectil_startup = 0.16
	proyectil_recovery = 0.30
	proyectil_cooldown = 0.62
	sonido_proyectil_impacto = load("res://assets/helena/proyectil_impacto.wav")

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return
	_comportamiento_ia_basico(_delta, vel_actual, 92.0, 300.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(0.78, 0.86, 0.42, 0.90), 178.0, 30.0)

func _pose_final_especial(duracion: float) -> void:
	if veces_fase_absoluta == 2 and textura_remate_core2_cuerpo:
		_actualizar_textura(textura_remate_core2_cuerpo)
		pose_timer = duracion
		return
	if veces_fase_absoluta >= 3 and textura_remate_core3_cuerpo:
		_actualizar_textura(textura_remate_core3_cuerpo)
		pose_timer = duracion
		return
	super._pose_final_especial(duracion)

# 91.04.00 PASS 1D — AJUSTE FINO VISUAL EXCLUSIVO DE VIRGILIO.
# No cambia fisica, hitbox, daño, timers, rollback ni Fighter.
func _escala_normalizada_por_pose(tex: Texture2D, rect: Rect2) -> float:
	var base: float = super._escala_normalizada_por_pose(tex, rect)
	if tex == textura_victoria:
		return base * 1.20
	if tex == textura_especial:
		# Microajuste final: CORE I un poco mas atras para que respire mejor el leon.
		return base * 1.18
	# Recarga / entrada a CORE II: un poco mas grande.
	if tex == textura_recarga:
		return base * 1.10
	# Proyectil: subir apenas mas respecto PASS 1D.
	if tex == textura_proyectil_pose:
		return base * 1.13
	# Salto / doble salto / descenso / back dash: subir apenas.
	if tex == textura_salto:
		return base * 1.06
	if tex == textura_doble_salto:
		return base * 1.06
	if tex == textura_descenso:
		return base * 1.06
	if tex == textura_evasion:
		return base * 1.06
	return base
