class_name Dax
extends Fighter

# CORE AWAKENED 90.11.14 — DAX CENTRADO + BACK DASH TERRESTRE.
# Cada pose se carga desde el PNG nombrado por el usuario; se elimina la mezcla
# accidental entre repertorio normal, Furia y dash.

var textura_remate_furia_cuerpo: Texture2D = null

func _init() -> void:
	nombre_luchador = "Dax"
	color_base = Color(0.96, 0.18, 0.08)
	color_fase = Color(1.0, 0.30, 0.14)
	velocidad = 314.0
	fuerza_salto = -438.0
	gravedad = 1130.0
	dano_punetazo = 8.8
	cooldown_punetazo = 0.18
	poder_por_golpe = 13.0
	combo_core_remix_prioriza_patadas = true
	combo_core_remix_patadas_objetivo = 3
	ia_prob_patada = 0.42
	ia_prob_bloqueo = 0.22
	ia_prob_retroceso = 0.12
	vida_maxima = 215.0
	vida = 215.0
	aceleracion = 3720.0
	friccion_suelo = 3820.0
	friccion_aire = 1820.0
	peso_golpe = 1.02
	escala_sprite = 0.63

	# Pose oficial de inicio.
	textura_parado = load("res://assets/dax/parado.png")

	# 9 PUÑOS NORMALES exactos. Ningún sprite con aura entra en esta lista.
	textura_punetazo = load("res://assets/dax/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/dax/punetazo_2.png"),
		load("res://assets/dax/punetazo_3.png"),
		load("res://assets/dax/punetazo_4.png"),
		load("res://assets/dax/punetazo_5.png"),
		load("res://assets/dax/punetazo_6.png"),
		load("res://assets/dax/punetazo_7.png"),
		load("res://assets/dax/punetazo_8.png"),
		load("res://assets/dax/punetazo_9.png"),
	]

	# 5 PATADAS NORMALES exactas, incluido rodillazo.
	textura_patada = load("res://assets/dax/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/dax/patada_2.png"),
		load("res://assets/dax/patada_3.png"),
		load("res://assets/dax/patada_4.png"),
		load("res://assets/dax/patada_5.png"),
	]

	texturas_caminata = [load("res://assets/dax/caminata_1.png"), load("res://assets/dax/caminata_2.png")]
	textura_bloqueo = load("res://assets/dax/bloqueo.png")
	textura_carrera = load("res://assets/dax/carrera.png")
	textura_evasion = load("res://assets/dax/evasion.png")
	textura_salto = load("res://assets/dax/salto.png")
	textura_doble_salto = load("res://assets/dax/doble_salto.png")
	textura_descenso = load("res://assets/dax/descenso.png")

	textura_golpe_recibido = load("res://assets/dax/golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/dax/golpe_recibido_2.png"),
		load("res://assets/dax/golpe_recibido_3.png"),
		load("res://assets/dax/golpe_recibido_4.png"),
	]
	textura_derribado = load("res://assets/dax/derribado.png")
	textura_recarga = load("res://assets/dax/recarga.png")
	textura_victoria = load("res://assets/dax/victoria.png")

	# CORE I queda a la espera de la gigantografía dedicada que el usuario va a pasar.
	textura_especial = null
	textura_rematador = load("res://assets/dax/rematador.png")
	textura_absoluto = load("res://assets/dax/absoluto.png")
	textura_remate_furia_cuerpo = load("res://assets/dax/remate_furia.png")

	# Furia: 3 golpes de brazo + 5 golpes de pierna = los 8 PNG de combo entregados.
	textura_furia_parado = load("res://assets/dax/furia_parado.png")
	textura_furia_carrera = load("res://assets/dax/furia_carrera.png")
	textura_furia_evasion = load("res://assets/dax/furia_evasion.png")
	textura_furia_punetazo = load("res://assets/dax/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/dax/furia_punetazo_2.png"),
		load("res://assets/dax/furia_punetazo_3.png"),
	]
	textura_furia_patada = load("res://assets/dax/furia_patada_1.png")
	texturas_furia_patada_extra = [
		load("res://assets/dax/furia_patada_2.png"),
		load("res://assets/dax/furia_patada_3.png"),
		load("res://assets/dax/furia_patada_4.png"),
		load("res://assets/dax/furia_patada_5.png"),
	]
	textura_furia_golpe_recibido = load("res://assets/dax/furia_golpe_recibido.png")
	textura_furia_derribado = load("res://assets/dax/furia_derribado.png")

# 90.11.14 — El dash aéreo ya retenía su pose mediante pose_timer, pero el dash
# terrestre podía ser reemplazado por la caminata en el mismo ciclo visual.
# Esta corrección es EXCLUSIVA DE DAX: conserva la física base y fija sólo la
# textura correcta durante los 0.17 s del dash.
func _iniciar_carrera(direccion: float) -> void:
	super._iniciar_carrera(direccion)
	if not carrera_activa or not sprite:
		return

	var es_backdash: bool = carrera_direccion != 0.0 and mirando != 0.0 and carrera_direccion * mirando < 0.0
	var tex_dash: Texture2D = _tex_evasion() if es_backdash else textura_carrera
	if en_fase_absoluta:
		if es_backdash and textura_furia_evasion:
			tex_dash = textura_furia_evasion
		elif not es_backdash and textura_furia_carrera:
			tex_dash = textura_furia_carrera
	if tex_dash:
		_actualizar_textura(tex_dash)
		pose_timer = maxf(pose_timer, DASH_DURACION + 0.02)

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return
	_comportamiento_ia_basico(_delta, vel_actual, 88.0, 285.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(1.0, 0.26, 0.14, 0.90), 180.0, 30.0)

# La recarga original es un poco más chica que el resto del repertorio de Dax.
func _escala_normalizada_por_pose(tex: Texture2D, rect: Rect2) -> float:
	var escala := super._escala_normalizada_por_pose(tex, rect)
	if tex == textura_recarga:
		return escala * 1.10
	return escala

# En el cierre del CORE III usamos el PNG específico REMATE MODO FURIA.
func _pose_final_especial(duracion: float) -> void:
	if en_fase_absoluta and textura_remate_furia_cuerpo:
		_actualizar_textura(textura_remate_furia_cuerpo)
		pose_timer = duracion
		return
	super._pose_final_especial(duracion)
