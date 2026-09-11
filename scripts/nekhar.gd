class_name Nekhar
extends Fighter

# CORE AWAKENED 91.02.02 — NEKHAR PARADO IMPORT FIX
# El Guardián del Sepulcro.
# Integración aditiva sobre Fighter: sin timers ni estado rollback nuevo.

const TEXTURA_PARADO_NEKHAR: Texture2D = preload("res://assets/nekhar/parado_v2.png")

var textura_remate_cuerpo: Texture2D = null

func _init() -> void:
	nombre_luchador = "Nekhar"
	color_base = Color(0.78, 0.56, 0.20)
	color_fase = Color(1.0, 0.30, 0.06)

	# Perfil pesado/técnico según ficha oficial.
	velocidad = 258.0
	fuerza_salto = -408.0
	gravedad = 1160.0
	rango_punetazo = 100.0
	rango_patada = 112.0
	dano_punetazo = 9.4
	dano_patada = 14.2
	cooldown_punetazo = 0.24
	cooldown_patada = 0.58
	poder_por_golpe = 13.0
	combo_core_remix_prioriza_patadas = false
	combo_core_remix_patadas_objetivo = 2
	ia_prob_patada = 0.36
	ia_prob_bloqueo = 0.36
	ia_prob_retroceso = 0.14
	vida_maxima = 236.0
	vida = 236.0
	aceleracion = 3240.0
	friccion_suelo = 3900.0
	friccion_aire = 1880.0
	peso_golpe = 1.10
	escala_sprite = 0.62

	textura_parado = TEXTURA_PARADO_NEKHAR

	textura_punetazo = load("res://assets/nekhar/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/nekhar/punetazo_2.png"),
		load("res://assets/nekhar/punetazo_3.png"),
		load("res://assets/nekhar/punetazo_4.png"),
		load("res://assets/nekhar/punetazo_5.png"),
	]

	textura_patada = load("res://assets/nekhar/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/nekhar/patada_2.png"),
		load("res://assets/nekhar/patada_3.png"),
		load("res://assets/nekhar/patada_4.png"),
		load("res://assets/nekhar/patada_5.png"),
	]

	texturas_caminata = [
		load("res://assets/nekhar/caminata_1.png"),
		load("res://assets/nekhar/caminata_2.png"),
	]
	textura_bloqueo = load("res://assets/nekhar/bloqueo.png")
	textura_carrera = load("res://assets/nekhar/carrera.png")
	textura_evasion = load("res://assets/nekhar/evasion.png")
	textura_salto = load("res://assets/nekhar/salto.png")
	textura_doble_salto = load("res://assets/nekhar/doble_salto.png")
	textura_descenso = load("res://assets/nekhar/descenso.png")

	textura_golpe_recibido = load("res://assets/nekhar/golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/nekhar/golpe_recibido_2.png"),
		load("res://assets/nekhar/golpe_recibido_3.png"),
		load("res://assets/nekhar/golpe_recibido_4.png"),
	]
	textura_derribado = load("res://assets/nekhar/derribado.png")
	textura_recarga = load("res://assets/nekhar/recarga.png")
	textura_victoria = load("res://assets/nekhar/victoria.png")

	# Gigantografías oficiales CORE I/II/III.
	textura_especial = load("res://assets/nekhar/especial.png")
	textura_rematador = load("res://assets/nekhar/rematador.png")
	textura_absoluto = load("res://assets/nekhar/absoluto.png")
	textura_remate_cuerpo = load("res://assets/nekhar/remate_cuerpo.png")

	# Seis beats de Combo Furia entregados.
	textura_furia_parado = textura_recarga
	textura_furia_caminata_der = texturas_caminata[0]
	textura_furia_caminata_izq = texturas_caminata[1]
	textura_furia_carrera = textura_carrera
	textura_furia_evasion = textura_evasion
	textura_furia_salto = textura_salto
	textura_furia_doble_salto = textura_doble_salto
	textura_furia_descenso = textura_descenso
	textura_furia_bloqueo = textura_bloqueo
	textura_furia_punetazo = load("res://assets/nekhar/furia_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/nekhar/furia_2.png"),
		load("res://assets/nekhar/furia_3.png"),
		load("res://assets/nekhar/furia_4.png"),
	]
	textura_furia_patada = load("res://assets/nekhar/furia_5.png")
	texturas_furia_patada_extra = [
		load("res://assets/nekhar/furia_6.png"),
	]
	textura_furia_golpe_recibido = textura_golpe_recibido
	textura_furia_derribado = textura_derribado

	# 91.02.55 — PASS 12L / PROYECTIL TANDA FINAL — NEKHAR.
	proyectil_especial_habilitado = true
	textura_proyectil_pose = load("res://assets/nekhar/poder_proyectil.png")
	textura_proyectil_nucleo = load("res://assets/nekhar/proyectil_oficial.png")
	# El vórtice dorado ocupa bastante ancho; compensación preventiva.
	proyectil_pose_escala_mult = 1.20
	color_proyectil_primario = Color(1.0, 0.62, 0.08, 1.0)
	color_proyectil_secundario = Color(1.0, 0.92, 0.56, 1.0)
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
	_comportamiento_ia_basico(_delta, vel_actual, 98.0, 286.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	# Energía funeraria: ámbar incandescente con lectura rojiza en CORE.
	_efecto_estallido(Color(1.0, 0.34, 0.05, 0.92), 188.0, 32.0)

func _pose_final_especial(duracion: float) -> void:
	if veces_fase_absoluta >= 2 and textura_remate_cuerpo:
		_actualizar_textura(textura_remate_cuerpo)
		pose_timer = duracion
		return
	super._pose_final_especial(duracion)

# CORE AWAKENED 91.02.04 — NEKHAR RECARGA / REMATE SCALE MATCH.
# Sus PNG de recarga y remate incluyen un halo rojo/naranja muy amplio. El
# fallback geométrico de Fighter mide también ese VFX y termina achicando el
# cuerpo de la momia. Esta corrección es presentación pura: no toca hitbox,
# daño, física, timers ni rollback.
func _escala_normalizada_por_pose(tex: Texture2D, rect: Rect2) -> float:
	# Recarga también es la pose de reposo de Furia, por eso una sola
	# calibración corrige ambos momentos.
	if tex == textura_recarga or tex == textura_furia_parado:
		return 0.2300

	# Último golpe corporal después de la gigantografía CORE.
	if tex == textura_remate_cuerpo:
		return 0.2350

	return super._escala_normalizada_por_pose(tex, rect)
