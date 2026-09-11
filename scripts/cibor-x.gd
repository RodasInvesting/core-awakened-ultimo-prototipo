class_name CiborX
extends Fighter

# CORE AWAKENED 90.10.64 — CIBOR-X COMBAT VARIETY PASS
# Se suman 4 golpes normales y 2 golpes Furia sin reemplazar el repertorio actual.

func _init() -> void:
	nombre_luchador = "Cibor-X"
	color_base = Color(0.15, 0.55, 0.85)
	color_fase = Color(0.5, 0.85, 1.0)
	velocidad = 235.0
	fuerza_salto = -408.0
	gravedad = 1280.0
	aceleracion = 2200.0
	friccion_suelo = 2430.0
	friccion_aire = 972.0
	peso_golpe = 1.28
	dano_punetazo = 9.0
	cooldown_punetazo = 0.24
	poder_por_golpe = 12.0
	ia_prob_patada = 0.30
	ia_prob_bloqueo = 0.32
	ia_prob_retroceso = 0.20
	mult_tamano_extra = 1.10

	escala_sprite = 0.5248
	textura_parado = load("res://assets/cibor-x/parado.png")

	# 90.10.64 — 7 puños normales en total. Los dos nuevos quedan
	# intercalados entre los anteriores para evitar poses demasiado parecidas seguidas.
	textura_punetazo = load("res://assets/cibor-x/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/cibor-x/punetazo_2.png"),
		load("res://assets/cibor-x/punetazo_6_90_10_64.png"),
		load("res://assets/cibor-x/punetazo_3.png"),
		load("res://assets/cibor-x/punetazo_4.png"),
		load("res://assets/cibor-x/punetazo_7_90_10_64.png"),
		load("res://assets/cibor-x/punetazo_5.png"),
	]

	# 90.10.64 — 6 patadas normales en total. Rodillazo y patada baja
	# se intercalan para romper el ritmo de las patadas anteriores.
	textura_patada = load("res://assets/cibor-x/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/cibor-x/patada_5_rodillazo_90_10_64.png"),
		load("res://assets/cibor-x/patada_2.png"),
		load("res://assets/cibor-x/patada_3.png"),
		load("res://assets/cibor-x/patada_6_baja_90_10_64.png"),
		load("res://assets/cibor-x/patada_4.png"),
	]

	textura_golpe_recibido = load("res://assets/cibor-x/golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/cibor-x/golpe_recibido_2.png"),
		load("res://assets/cibor-x/golpe_recibido_3.png"),
		load("res://assets/cibor-x/golpe_recibido_4.png"),
	]
	textura_derribado = load("res://assets/cibor-x/derribado.png")
	textura_especial = load("res://assets/cibor-x/especial.png")
	textura_rematador = load("res://assets/cibor-x/rematador.png")
	textura_absoluto = load("res://assets/cibor-x/absoluto.png")
	textura_recarga = load("res://assets/cibor-x/recarga.png")
	textura_furia_parado = load("res://assets/cibor-x/furia_parado.png")

	# 90.10.64 — Combo Furia ampliado de 6 a 8 golpes visuales.
	# Los dos nuevos quedan al final de sus repertorios para aparecer
	# hacia el tramo final del CORE III antes del remate.
	textura_furia_punetazo = load("res://assets/cibor-x/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/cibor-x/furia_punetazo_2.png"),
		load("res://assets/cibor-x/furia_punetazo_3.png"),
		load("res://assets/cibor-x/furia_punetazo_4.png"),
		load("res://assets/cibor-x/furia_punetazo_5_90_10_64.png"),
	]
	textura_furia_patada = load("res://assets/cibor-x/furia_patada_1.png")
	texturas_furia_patada_extra = [
		load("res://assets/cibor-x/furia_patada_2.png"),
		load("res://assets/cibor-x/furia_patada_3_90_10_64.png"),
	]
	textura_furia_golpe_recibido = load("res://assets/cibor-x/furia_golpe_recibido.png")
	textura_furia_derribado = load("res://assets/cibor-x/furia_derribado.png")

	textura_descenso = load("res://assets/cibor-x/descenso.png")
	textura_salto = load("res://assets/cibor-x/salto.png")
	textura_doble_salto = load("res://assets/cibor-x/doble_salto.png")
	textura_bloqueo = load("res://assets/cibor-x/bloqueo.png")
	texturas_caminata = [
		load("res://assets/cibor-x/caminata_1.png"),
		load("res://assets/cibor-x/caminata_2.png"),
		load("res://assets/cibor-x/caminata_3.png"),
		load("res://assets/cibor-x/caminata_4.png"),
	]
	textura_carrera = load("res://assets/cibor-x/carrera.png")
	textura_furia_carrera = load("res://assets/cibor-x/furia_carrera.png")

	# 91.02.50 — PASS 12G / PROYECTIL TANDA 1 — CIBOR-X.
	proyectil_especial_habilitado = true
	textura_proyectil_pose = load("res://assets/cibor-x/poder_proyectil.png")
	textura_proyectil_nucleo = load("res://assets/cibor-x/proyectil_oficial.png")
	proyectil_pose_escala_mult = 1.05
	color_proyectil_primario = Color(0.02, 0.56, 1.0, 1.0)
	color_proyectil_secundario = Color(0.72, 0.96, 1.0, 1.0)
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
	_comportamiento_ia_basico(_delta, vel_actual, 95.0, 280.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(0.4, 0.8, 1.0, 0.85), 150.0, 27.0)
