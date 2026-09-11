class_name Krovan
extends Fighter

# CORE AWAKENED 91.01.00 — KROVAN
# El Guardián de la Última Cosecha.
# Integración aditiva: reutiliza toda la física/rollback genérica de Fighter.
# No introduce timers, Tweens ni estado lógico nuevo de combate.

var textura_remate_core2_cuerpo: Texture2D = null
var textura_remate_core3_cuerpo: Texture2D = null

func _init() -> void:
	nombre_luchador = "Krovan"
	color_base = Color(0.78, 0.46, 0.16)
	color_fase = Color(1.0, 0.72, 0.12)

	# Perfil inicial equilibrado: luchador medio-pesado, observador y de presión.
	# Estos valores son de gameplay y quedan deliberadamente cerca del roster base
	# para poder balancearlos después de la primera prueba real.
	velocidad = 292.0
	fuerza_salto = -442.0
	gravedad = 1120.0
	dano_punetazo = 8.6
	dano_patada = 13.2
	cooldown_punetazo = 0.21
	cooldown_patada = 0.52
	poder_por_golpe = 13.5
	combo_core_remix_prioriza_patadas = true
	combo_core_remix_patadas_objetivo = 2
	ia_prob_patada = 0.40
	ia_prob_bloqueo = 0.28
	ia_prob_retroceso = 0.18
	vida_maxima = 220.0
	vida = 220.0
	aceleracion = 3560.0
	friccion_suelo = 3700.0
	friccion_aire = 1800.0
	peso_golpe = 1.04
	escala_sprite = 0.63

	# Pose oficial de inicio.
	textura_parado = load("res://assets/krovan/parado.png")

	# Repertorio normal: 6 golpes de brazo.
	textura_punetazo = load("res://assets/krovan/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/krovan/punetazo_2.png"),
		load("res://assets/krovan/punetazo_3.png"),
		load("res://assets/krovan/punetazo_4.png"),
		load("res://assets/krovan/punetazo_5.png"),
		load("res://assets/krovan/punetazo_6.png"),
	]

	# 5 golpes de pierna, incluido rodillazo.
	textura_patada = load("res://assets/krovan/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/krovan/patada_2.png"),
		load("res://assets/krovan/patada_3.png"),
		load("res://assets/krovan/patada_4.png"),
		load("res://assets/krovan/patada_5.png"),
	]

	# Movimiento / defensa.
	texturas_caminata = [
		load("res://assets/krovan/caminata_1.png"),
		load("res://assets/krovan/caminata_2.png"),
	]
	textura_bloqueo = load("res://assets/krovan/bloqueo.png")
	textura_carrera = load("res://assets/krovan/carrera.png")
	textura_evasion = load("res://assets/krovan/evasion.png")
	textura_salto = load("res://assets/krovan/salto.png")
	textura_doble_salto = load("res://assets/krovan/doble_salto.png")
	textura_descenso = load("res://assets/krovan/descenso.png")

	# Reacciones. Los PNG se integran tal como fueron entregados; queda pendiente
	# únicamente una limpieza visual menor de bordes en algunos recibidos.
	textura_golpe_recibido = load("res://assets/krovan/golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/krovan/golpe_recibido_2.png"),
		load("res://assets/krovan/golpe_recibido_3.png"),
	]
	textura_derribado = load("res://assets/krovan/derribado.png")
	textura_recarga = load("res://assets/krovan/recarga.png")
	textura_victoria = load("res://assets/krovan/victoria.png")

	# Gigantografías oficiales por nivel CORE.
	textura_especial = load("res://assets/krovan/especial.png")
	textura_rematador = load("res://assets/krovan/rematador.png")
	textura_absoluto = load("res://assets/krovan/absoluto.png")
	textura_remate_core2_cuerpo = load("res://assets/krovan/remate_core2_cuerpo.png")
	textura_remate_core3_cuerpo = load("res://assets/krovan/remate_core3_cuerpo.png")

	# CORE III / Furia: seis cuadros entregados, cuatro de brazo y dos de pierna.
	# La recarga dorada funciona como pose de Furia entre beats.
	textura_furia_parado = textura_recarga
	textura_furia_caminata_der = texturas_caminata[0]
	textura_furia_caminata_izq = texturas_caminata[1]
	textura_furia_carrera = textura_carrera
	textura_furia_evasion = textura_evasion
	textura_furia_salto = textura_salto
	textura_furia_doble_salto = textura_doble_salto
	textura_furia_descenso = textura_descenso
	textura_furia_bloqueo = textura_bloqueo
	textura_furia_punetazo = load("res://assets/krovan/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/krovan/furia_punetazo_2.png"),
		load("res://assets/krovan/furia_punetazo_3.png"),
		load("res://assets/krovan/furia_punetazo_4.png"),
	]
	textura_furia_patada = load("res://assets/krovan/furia_patada_1.png")
	texturas_furia_patada_extra = [
		load("res://assets/krovan/furia_patada_2.png"),
	]
	textura_furia_golpe_recibido = textura_golpe_recibido
	textura_furia_derribado = textura_derribado

	# 91.02.55 — PASS 12L / PROYECTIL TANDA FINAL — KROVAN.
	proyectil_especial_habilitado = true
	textura_proyectil_pose = load("res://assets/krovan/poder_proyectil.png")
	textura_proyectil_nucleo = load("res://assets/krovan/proyectil_oficial.png")
	# El PNG incluye una masa grande de cuervos/fuego a la derecha.
	proyectil_pose_escala_mult = 1.18
	color_proyectil_primario = Color(1.0, 0.34, 0.02, 1.0)
	color_proyectil_secundario = Color(1.0, 0.78, 0.16, 1.0)
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
	# Estallido dorado del CORE. Los cuervos forman parte de las ilustraciones
	# entregadas y no requieren nodos lógicos adicionales.
	_efecto_estallido(Color(1.0, 0.68, 0.12, 0.90), 178.0, 30.0)

func _pose_final_especial(duracion: float) -> void:
	# CORE I conserva la pose genérica de lanzamiento. CORE II y III usan sus
	# remates corporales dedicados sin alterar la FSM certificada del Fighter.
	if veces_fase_absoluta == 2 and textura_remate_core2_cuerpo:
		_actualizar_textura(textura_remate_core2_cuerpo)
		pose_timer = duracion
		return
	if veces_fase_absoluta >= 3 and textura_remate_core3_cuerpo:
		_actualizar_textura(textura_remate_core3_cuerpo)
		pose_timer = duracion
		return
	super._pose_final_especial(duracion)

# CORE AWAKENED 91.02.03 — KROVAN REACTION SCALE FIX.
# Presentación pura: los frames encorvados/horizontales de Krovan no deben
# agrandarse por el fallback geométrico genérico de Fighter. No se altera
# física, hitbox, daño, timers, movimiento ni estado de rollback.
func _escala_normalizada_por_pose(tex: Texture2D, rect: Rect2) -> float:
	# Los tres recibidos deben conservar exactamente el volumen corporal de parado.
	if tex == textura_golpe_recibido or tex == textura_furia_golpe_recibido or texturas_golpe_recibido_extra.has(tex):
		return 0.2053

	# 91.02.04 — el video real confirmó que 0.2200 quedó demasiado pequeño.
	# Derribado es horizontal: 0.2700 recupera una longitud corporal comparable
	# al volumen de Krovan de pie sin volver al gigantismo original.
	if tex == textura_derribado or tex == textura_furia_derribado:
		return 0.2700

	return super._escala_normalizada_por_pose(tex, rect)

