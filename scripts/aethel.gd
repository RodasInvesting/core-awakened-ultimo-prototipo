class_name Aethel
extends Fighter

func _init() -> void:
	nombre_luchador = "Aethel"
	color_base = Color(0.75, 0.82, 0.9)
	color_fase = Color(0.6, 0.85, 1.0)
	velocidad = 314.0
	fuerza_salto = -452.0
	gravedad = 1040.0
	dano_punetazo = 6.0
	cooldown_punetazo = 0.19
	poder_por_golpe = 10.0
	ia_prob_patada = 0.42
	ia_prob_bloqueo = 0.20
	ia_prob_retroceso = 0.32
	# Ágil: arranca y frena rapidísimo, y controla bien en el aire (vuela).
	aceleracion = 3740.0
	friccion_suelo = 4104.0
	friccion_aire = 2376.0

	escala_sprite = 0.7261
	# FASE REDISEÑO AETHEL (lote 1 de 2): arte nuevo para parado, puñetazo
	# (reducido de 7 a 4 cuadros), recarga y la nueva mecánica de carrera.
	# Aethel no camina, levita -- por eso texturas_caminata tiene un único
	# cuadro fijo en vez de un ciclo de piernas. Todavía en arte viejo:
	# patada (solo llegó patada_4 nueva, se guardó pero no se conecta hasta
	# tener el set completo mañana), golpe recibido, derribado, especial,
	# absoluto, salto, doble salto, bloqueo y todo el combo Furia.
	textura_parado = load("res://assets/aethel/parado.png")
	textura_punetazo = load("res://assets/aethel/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/aethel/punetazo_2.png"),
		load("res://assets/aethel/punetazo_3.png"),
		load("res://assets/aethel/punetazo_4.png"),
	]
	textura_patada = load("res://assets/aethel/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/aethel/patada_2.png"),
		load("res://assets/aethel/patada_3.png"),
	]
	textura_golpe_recibido = load("res://assets/aethel/golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/aethel/golpe_recibido_2.png"),
		load("res://assets/aethel/golpe_recibido_3.png"),
	]
	textura_derribado = load("res://assets/aethel/derribado.png")
	textura_especial = load("res://assets/aethel/especial.png")
	textura_rematador = load("res://assets/aethel/rematador.png")
	textura_absoluto = load("res://assets/aethel/absoluto.png")
	textura_recarga = load("res://assets/aethel/recarga.png")
	textura_furia_parado = load("res://assets/aethel/furia_parado.png")
	textura_furia_punetazo = load("res://assets/aethel/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/aethel/furia_punetazo_2.png"),
		load("res://assets/aethel/furia_punetazo_3.png"),
		load("res://assets/aethel/furia_punetazo_4.png"),
		load("res://assets/aethel/furia_punetazo_5.png"),
		load("res://assets/aethel/furia_punetazo_6.png"),
	]
	textura_furia_patada = load("res://assets/aethel/furia_patada_1.png")
	texturas_furia_patada_extra = [
		load("res://assets/aethel/furia_patada_2.png"),
		load("res://assets/aethel/furia_patada_3.png"),
	]
	textura_furia_golpe_recibido = load("res://assets/aethel/furia_golpe_recibido.png")
	textura_furia_derribado = load("res://assets/aethel/furia_derribado.png")

	textura_caminata_der = null
	textura_caminata_izq = null
	texturas_caminata = [
		load("res://assets/aethel/levitacion.png"),
	]
	textura_salto = load("res://assets/aethel/salto.png")
	textura_doble_salto = load("res://assets/aethel/doble_salto.png")
	textura_bloqueo = load("res://assets/aethel/bloqueo.png")
	textura_carrera = load("res://assets/aethel/carrera.png")

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return
	_comportamiento_ia_basico(_delta, vel_actual, 90.0, 320.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(0.7, 0.9, 1.0, 0.85), 165.0, 25.0)
