class_name Xenoid
extends Fighter

# XENOID — integración jugable inicial.
# Usa únicamente arte entregado por el creador. Las categorías que todavía
# no tienen imagen propia (caminar, bloquear, correr y victoria) quedan sin
# asset inventado para que Fighter use sus fallbacks seguros.
func _init() -> void:
	nombre_luchador = "Xenoid"
	color_base = Color(0.42, 1.0, 0.08)
	color_fase = Color(0.10, 0.82, 1.0)

	# Perfil: veloz, liviano y técnico.
	velocidad = 310.0
	fuerza_salto = -455.0
	gravedad = 1080.0
	dano_punetazo = 7.5
	cooldown_punetazo = 0.19
	poder_por_golpe = 12.5
	ia_prob_patada = 0.40
	ia_prob_bloqueo = 0.20
	ia_prob_retroceso = 0.28
	vida_maxima = 205.0
	vida = 205.0
	aceleracion = 3700.0
	friccion_suelo = 3800.0
	friccion_aire = 1900.0
	peso_golpe = 0.88
	escala_sprite = 0.62

	textura_parado = load("res://assets/xenoid/parado.png")

	textura_punetazo = load("res://assets/xenoid/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/xenoid/punetazo_2.png"),
		load("res://assets/xenoid/punetazo_3.png"),
		load("res://assets/xenoid/punetazo_4.png"),
	]

	textura_patada = load("res://assets/xenoid/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/xenoid/patada_2.png"),
		load("res://assets/xenoid/patada_3.png"),
		load("res://assets/xenoid/patada_4.png"),
		load("res://assets/xenoid/patada_5.png"),
	]

	# Todavía no llegó una pose de salto inicial separada. Mientras tanto se
	# usa el doble salto también como pose aérea base; no afecta la física.
	textura_salto = load("res://assets/xenoid/salto.png")
	textura_doble_salto = load("res://assets/xenoid/doble_salto.png")
	textura_descenso = load("res://assets/xenoid/descenso.png")

	textura_golpe_recibido = load("res://assets/xenoid/golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/xenoid/golpe_recibido_2.png"),
		load("res://assets/xenoid/golpe_recibido_3.png"),
		load("res://assets/xenoid/golpe_recibido_4.png"),
	]
	textura_derribado = load("res://assets/xenoid/derribado.png")

	# CORE / Furia: dos imágenes de combo disponibles por ahora. Se reparten
	# entre especial, rematador y absoluto hasta completar los frames restantes.
	textura_recarga = load("res://assets/xenoid/recarga.png")
	textura_especial = load("res://assets/xenoid/especial.png")
	textura_rematador = load("res://assets/xenoid/rematador.png")
	textura_absoluto = load("res://assets/xenoid/absoluto.png")
	textura_furia_parado = load("res://assets/xenoid/furia_parado.png")
	textura_furia_punetazo = load("res://assets/xenoid/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [load("res://assets/xenoid/furia_patada_1.png")]
	textura_furia_patada = load("res://assets/xenoid/furia_patada_1.png")

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return

	_comportamiento_ia_basico(_delta, vel_actual, 90.0, 320.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(0.10, 0.82, 1.0, 0.88), 165.0, 28.0)
