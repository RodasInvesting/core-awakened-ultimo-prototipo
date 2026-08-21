class_name Kali
extends Fighter

func _init() -> void:
	nombre_luchador = "Kali"
	color_base = Color(0.35, 0.65, 0.15)
	color_fase = Color(0.55, 0.9, 0.25)
	velocidad = 280.0
	fuerza_salto = -438.0
	gravedad = 1100.0
	dano_punetazo = 7.0
	cooldown_punetazo = 0.20
	poder_por_golpe = 12.0
	ia_prob_patada = 0.40
	ia_prob_bloqueo = 0.15
	ia_prob_retroceso = 0.28
	# Rápida y liviana: arranca/frena al toque, y sus golpes empujan y
	# aturden menos que los de los demás -- a cambio, pega seguido.
	aceleracion = 3520.0
	friccion_suelo = 3888.0
	friccion_aire = 1944.0
	peso_golpe = 0.75

	escala_sprite = 0.6378
	# FASE REDISEÑO KALI (lote 2 de 2): arte nuevo para caminata, bloqueo,
	# derribado, combo Furia completo (reemplazado, antes 6+3 ahora 3+3),
	# y la nueva mecánica de carrera (doble flecha), igual que en Cibor-X,
	# Helena y Kai. Sigue en arte viejo: salto, doble salto, especial,
	# absoluto, golpe recibido en Furia y derribado en Furia.
	textura_parado = load("res://assets/kali/parado.png")
	textura_punetazo = load("res://assets/kali/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/kali/punetazo_2.png"),
		load("res://assets/kali/punetazo_3.png"),
		load("res://assets/kali/punetazo_4.png"),
	]
	textura_patada = load("res://assets/kali/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/kali/patada_2.png"),
		load("res://assets/kali/patada_3.png"),
		load("res://assets/kali/patada_4.png"),
	]
	textura_golpe_recibido = load("res://assets/kali/golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/kali/golpe_recibido_2.png"),
		load("res://assets/kali/golpe_recibido_3.png"),
		load("res://assets/kali/golpe_recibido_4.png"),
	]
	textura_derribado = load("res://assets/kali/derribado.png")
	textura_especial = load("res://assets/kali/especial.png")
	textura_rematador = load("res://assets/kali/rematador.png")
	textura_absoluto = load("res://assets/kali/absoluto.png")
	textura_recarga = load("res://assets/kali/recarga.png")
	textura_furia_parado = load("res://assets/kali/furia_parado.png")
	textura_furia_punetazo = load("res://assets/kali/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/kali/furia_punetazo_2.png"),
		load("res://assets/kali/furia_punetazo_3.png"),
	]
	textura_furia_patada = load("res://assets/kali/furia_patada_1.png")
	texturas_furia_patada_extra = [
		load("res://assets/kali/furia_patada_2.png"),
		load("res://assets/kali/furia_patada_3.png"),
	]
	textura_furia_golpe_recibido = load("res://assets/kali/furia_golpe_recibido.png")
	textura_furia_derribado = load("res://assets/kali/furia_derribado.png")

	texturas_caminata = [
		load("res://assets/kali/caminata_1.png"),
		load("res://assets/kali/caminata_2.png"),
		load("res://assets/kali/caminata_3.png"),
		load("res://assets/kali/caminata_4.png"),
	]
	textura_salto = load("res://assets/kali/salto.png")
	textura_doble_salto = load("res://assets/kali/doble_salto.png")
	textura_descenso = load("res://assets/kali/descenso.png")
	textura_bloqueo = load("res://assets/kali/bloqueo.png")
	textura_carrera = load("res://assets/kali/carrera.png")
	textura_furia_carrera = load("res://assets/kali/furia_carrera.png")

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return
	_comportamiento_ia_basico(_delta, vel_actual, 85.0, 300.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(0.55, 0.95, 0.2, 0.85), 150.0, 26.0)
