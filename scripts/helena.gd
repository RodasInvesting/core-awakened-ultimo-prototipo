class_name Helena
extends Fighter

func _init() -> void:
	nombre_luchador = "Helena"
	color_base = Color(0.9, 0.35, 0.65)
	color_fase = Color(1.0, 0.55, 0.85)
	velocidad = 302.0
	fuerza_salto = -425.0
	gravedad = 1160.0
	aceleracion = 3300.0
	friccion_suelo = 3402.0
	friccion_aire = 1566.0
	peso_golpe = 0.96
	vida_maxima = 240.0
	vida = 240.0
	dano_punetazo = 11.0
	cooldown_punetazo = 0.21
	poder_por_golpe = 15.0
	ia_prob_patada = 0.35
	ia_prob_bloqueo = 0.20
	ia_prob_retroceso = 0.15

	escala_sprite = 0.6486
	textura_parado = load("res://assets/helena/parado.png")
	textura_punetazo = load("res://assets/helena/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/helena/punetazo_2.png"),
		load("res://assets/helena/punetazo_3.png"),
		load("res://assets/helena/punetazo_4.png"),
		load("res://assets/helena/punetazo_5.png"),
		load("res://assets/helena/punetazo_6.png"),
		load("res://assets/helena/punetazo_7.png"),
		load("res://assets/helena/punetazo_8.png"),
	]
	textura_patada = load("res://assets/helena/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/helena/patada_2.png"),
		load("res://assets/helena/patada_3.png"),
	]
	textura_golpe_recibido = load("res://assets/helena/golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/helena/golpe_recibido_2.png"),
		load("res://assets/helena/golpe_recibido_3.png"),
		load("res://assets/helena/golpe_recibido_4.png"),
	]
	textura_derribado = load("res://assets/helena/derribado.png")
	textura_especial = load("res://assets/helena/especial.png")
	textura_rematador = load("res://assets/helena/rematador.png")
	textura_absoluto = load("res://assets/helena/absoluto.png")
	textura_recarga = load("res://assets/helena/recarga.png")
	textura_furia_parado = load("res://assets/helena/furia_parado.png")
	# FASE REDISEÑO: en Furia el combo automático usa un set reducido y
	# mezclado (3 puñetazos + 2 patadas) en vez de los 8+3 anteriores --
	# menos variedad de cuadros, pero todos nuevos y en alta resolución.
	textura_furia_punetazo = load("res://assets/helena/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/helena/furia_punetazo_2.png"),
		load("res://assets/helena/furia_punetazo_3.png"),
	]
	textura_furia_patada = load("res://assets/helena/furia_patada_1.png")
	texturas_furia_patada_extra = [
		load("res://assets/helena/furia_patada_2.png"),
	]
	textura_furia_golpe_recibido = load("res://assets/helena/furia_golpe_recibido.png")
	textura_furia_derribado = load("res://assets/helena/furia_derribado.png")

	# FASE REDISEÑO 2: caminata rediseñada, vuelve a un ciclo de 2 cuadros
	# (antes había pasado por 4). Se deja textura_caminata_der/izq vacío a
	# propósito: así el motor usa automáticamente el ciclo de N cuadros
	# (texturas_caminata) con ping-pong -- no hace falta tocar fighter.gd.
	textura_salto = load("res://assets/helena/salto.png")
	textura_doble_salto = load("res://assets/helena/doble_salto.png")
	textura_bloqueo = load("res://assets/helena/bloqueo.png")
	texturas_caminata = [
		load("res://assets/helena/caminata_1.png"),
		load("res://assets/helena/caminata_2.png"),
	]

	# FASE REDISEÑO 2: pose dedicada para la carrera (doble toque de flecha),
	# mismo mecanismo que ya usa Cibor-X.
	textura_carrera = load("res://assets/helena/carrera.png")

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return
	_comportamiento_ia_basico(_delta, vel_actual, 90.0, 300.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(1.0, 0.6, 0.9, 0.9), 175.0, 32.0)
