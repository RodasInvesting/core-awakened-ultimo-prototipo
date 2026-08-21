class_name CiborX
extends Fighter

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
	# FASE REDISEÑO (lote 1 de 2): puñetazo pasa de 8 (arte viejo) a 5
	# nuevos, patada de 2 a 4 (crece), golpe_recibido de 3 a 4. Se recorta
	# en vez de mezclar arte viejo con nuevo en la misma categoría -- igual
	# criterio que con Helena y Fang.
	textura_punetazo = load("res://assets/cibor-x/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/cibor-x/punetazo_2.png"),
		load("res://assets/cibor-x/punetazo_3.png"),
		load("res://assets/cibor-x/punetazo_4.png"),
		load("res://assets/cibor-x/punetazo_5.png"),
	]
	textura_patada = load("res://assets/cibor-x/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/cibor-x/patada_2.png"),
		load("res://assets/cibor-x/patada_3.png"),
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
	# FASE REDISEÑO (lote 2 de 2): combo Furia recortado a lo nuevo (4
	# puñetazos + 2 patadas, antes 7+2 con arte viejo).
	textura_furia_punetazo = load("res://assets/cibor-x/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/cibor-x/furia_punetazo_2.png"),
		load("res://assets/cibor-x/furia_punetazo_3.png"),
		load("res://assets/cibor-x/furia_punetazo_4.png"),
	]
	textura_furia_patada = load("res://assets/cibor-x/furia_patada_1.png")
	texturas_furia_patada_extra = [
		load("res://assets/cibor-x/furia_patada_2.png"),
	]
	textura_furia_golpe_recibido = load("res://assets/cibor-x/furia_golpe_recibido.png")
	textura_furia_derribado = load("res://assets/cibor-x/furia_derribado.png")

	# FASE REDISEÑO: caminata con cuadros reales (antes der/izq), y
	# descenso nuevo (Cibor-X no tenía esta pose antes).
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

	# FASE REDISEÑO (lote 3): pose dedicada para la carrera (doble toque de
	# flecha), antes usaba el ciclo de caminata normal acelerado. En Fase
	# Absoluta usa una variante más agresiva con estela/escombros.
	textura_carrera = load("res://assets/cibor-x/carrera.png")
	textura_furia_carrera = load("res://assets/cibor-x/furia_carrera.png")

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return
	_comportamiento_ia_basico(_delta, vel_actual, 95.0, 280.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(0.4, 0.8, 1.0, 0.85), 150.0, 27.0)
