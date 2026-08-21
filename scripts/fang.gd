class_name Fang
extends Fighter

func _init() -> void:
	nombre_luchador = "Fang"
	color_base = Color(0.85, 0.45, 0.1)
	color_fase = Color(1.0, 0.55, 0.15)
	velocidad = 213.0
	fuerza_salto = -405.0
	gravedad = 1260.0
	aceleracion = 2255.0
	friccion_suelo = 2538.0
	friccion_aire = 1026.0
	peso_golpe = 1.22
	dano_punetazo = 10.0
	poder_por_golpe = 10.0
	ia_prob_patada = 0.45
	ia_prob_bloqueo = 0.10
	ia_prob_retroceso = 0.08

	escala_sprite = 0.6693
	textura_parado = load("res://assets/fang/parado.png")
	# FASE REDISEÑO: por ahora solo llegaron 2 puñetazos nuevos (de los 9
	# viejos) y 1 patada nueva (de las 5 que mandaron, 4 en un estilo pixel
	# art que no coincide con el resto -- quedan afuera hasta nueva orden).
	# Se recorta el array en vez de mezclar arte viejo con nuevo; se
	# expande solo cuando lleguen más variantes en el próximo lote.
	textura_punetazo = load("res://assets/fang/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/fang/punetazo_2.png"),
		load("res://assets/fang/punetazo_3.png"),
		load("res://assets/fang/punetazo_4.png"),
	]
	textura_patada = load("res://assets/fang/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/fang/patada_2.png"),
	]
	textura_golpe_recibido = load("res://assets/fang/golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/fang/golpe_recibido_2.png"),
		load("res://assets/fang/golpe_recibido_3.png"),
		load("res://assets/fang/golpe_recibido_4.png"),
	]
	textura_derribado = load("res://assets/fang/derribado.png")
	textura_especial = load("res://assets/fang/especial.png")
	textura_rematador = load("res://assets/fang/rematador.png")
	textura_absoluto = load("res://assets/fang/absoluto.png")
	textura_recarga = load("res://assets/fang/recarga.png")
	textura_descenso = load("res://assets/fang/descenso.png")
	textura_furia_parado = load("res://assets/fang/furia_parado.png")
	# FASE REDISEÑO: combo Furia completo -- 3 puñetazos + 4 patadas (los 7
	# cuadros de la secuencia COMBO que mandaron en los dos lotes).
	textura_furia_punetazo = load("res://assets/fang/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/fang/furia_punetazo_2.png"),
		load("res://assets/fang/furia_punetazo_3.png"),
	]
	textura_furia_patada = load("res://assets/fang/furia_patada_1.png")
	texturas_furia_patada_extra = [
		load("res://assets/fang/furia_patada_2.png"),
		load("res://assets/fang/furia_patada_3.png"),
		load("res://assets/fang/furia_patada_4.png"),
	]
	textura_furia_golpe_recibido = load("res://assets/fang/furia_golpe_recibido.png")
	textura_furia_derribado = load("res://assets/fang/furia_derribado.png")

	# FASE REDISEÑO: caminata con cuadros reales (antes der/izq). Se deja
	# textura_caminata_der/izq vacío a propósito para que el motor use el
	# ciclo de N cuadros (texturas_caminata) con ping-pong automáticamente.
	textura_salto = load("res://assets/fang/salto.png")
	textura_doble_salto = load("res://assets/fang/doble_salto.png")
	textura_bloqueo = load("res://assets/fang/bloqueo.png")
	texturas_caminata = [
		load("res://assets/fang/caminata_1.png"),
		load("res://assets/fang/caminata_2.png"),
	]

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return
	_comportamiento_ia_basico(_delta, vel_actual, 95.0, 260.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(1.0, 0.5, 0.1, 0.85), 150.0, 28.0)
