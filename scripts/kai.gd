class_name Kai
extends Fighter

func _init() -> void:
	nombre_luchador = "Kai"
	color_base = Color(0.55, 0.25, 0.85)
	color_fase = Color(0.85, 0.45, 1.0)
	velocidad = 336.0
	fuerza_salto = -432.0
	gravedad = 1190.0
	aceleracion = 3245.0
	friccion_suelo = 3402.0
	friccion_aire = 1350.0
	peso_golpe = 1.05

	escala_sprite = 0.6125
	textura_parado = load("res://assets/kai/parado.png")
	textura_punetazo = load("res://assets/kai/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/kai/punetazo_2.png"),
		load("res://assets/kai/punetazo_3.png"),
		load("res://assets/kai/punetazo_4.png"),
		load("res://assets/kai/punetazo_5.png"),
		load("res://assets/kai/punetazo_6.png"),
		load("res://assets/kai/punetazo_7.png"),
		load("res://assets/kai/punetazo_8.png"),
		load("res://assets/kai/punetazo_9.png"),
	]
	textura_patada = load("res://assets/kai/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/kai/patada_2.png"),
	]
	textura_golpe_recibido = load("res://assets/kai/golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/kai/golpe_recibido_2.png"),
		load("res://assets/kai/golpe_recibido_3.png"),
	]
	textura_derribado = load("res://assets/kai/derribado.png")
	textura_especial = load("res://assets/kai/especial.png")
	textura_rematador = load("res://assets/kai/rematador.png")
	textura_absoluto = load("res://assets/kai/absoluto.png")
	textura_recarga = load("res://assets/kai/recarga.png")
	textura_furia_parado = load("res://assets/kai/furia_parado.png")
	# FASE REDISEÑO 2: combo Furia reemplazado por completo con el set nuevo
	# que mandaste (2 puñetazos + 3 patadas + remate), en vez de las 17+4
	# variantes anteriores. Menos cuadros, pero todos en el arte nuevo.
	textura_furia_punetazo = load("res://assets/kai/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/kai/furia_punetazo_2.png"),
	]
	textura_furia_patada = load("res://assets/kai/furia_patada_1.png")
	texturas_furia_patada_extra = [
		load("res://assets/kai/furia_patada_2.png"),
		load("res://assets/kai/furia_patada_3.png"),
	]
	textura_furia_golpe_recibido = load("res://assets/kai/furia_golpe_recibido.png")
	textura_furia_derribado = load("res://assets/kai/furia_derribado.png")

	# FASE REDISEÑO: caminata con 4 cuadros reales por modo (antes 2,
	# der/izq). Se deja textura_caminata_der/izq vacío a propósito: así el
	# motor usa automáticamente el ciclo de 4 cuadros (texturas_caminata),
	# que ya soporta N cuadros con ping-pong -- no hace falta tocar nada
	# de fighter.gd para esto, ya estaba preparado.
	textura_salto = load("res://assets/kai/salto.png")
	textura_doble_salto = load("res://assets/kai/doble_salto.png")
	textura_descenso = load("res://assets/kai/descenso.png")
	textura_bloqueo = load("res://assets/kai/bloqueo.png")
	# Mecánica de carrera (doble toque de flecha) que ya tenían Cibor-X,
	# Helena y Kali -- a Kai le faltaba.
	textura_carrera = load("res://assets/kai/carrera.png")
	textura_furia_carrera = load("res://assets/kai/furia_carrera.png")
	texturas_caminata = [
		load("res://assets/kai/caminata_1.png"),
		load("res://assets/kai/caminata_2.png"),
		load("res://assets/kai/caminata_3.png"),
		load("res://assets/kai/caminata_4.png"),
	]

	textura_furia_salto = load("res://assets/kai/furia_salto.png")
	textura_furia_doble_salto = load("res://assets/kai/furia_doble_salto.png")
	textura_furia_descenso = load("res://assets/kai/furia_descenso.png")
	textura_furia_bloqueo = load("res://assets/kai/furia_bloqueo.png")
	texturas_furia_caminata = [
		load("res://assets/kai/furia_caminata_1.png"),
		load("res://assets/kai/furia_caminata_2.png"),
		load("res://assets/kai/furia_caminata_3.png"),
		load("res://assets/kai/furia_caminata_4.png"),
	]

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return
	_comportamiento_ia_basico(_delta, vel_actual, 90.0, 300.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(0.85, 0.45, 1.0, 0.85), 160.0, 30.0)
