class_name Jester
extends Fighter

# PERSONAJE NUEVO (fase 92.3, WIP): Jester, la alquimista bufón. Set
# completo de combate normal (parado, puños, patadas, caminata, salto,
# doble salto, descenso, bloqueo, carrera, golpe_recibido x3, derribado) +
# combo de poder CORE completo (especial, recarga, rematador, absoluto,
# furia_parado, victoria, furia_punetazo x5, furia_patada x1).
# Ya no falta ninguna categoría del set base. Pendiente solo si se quiere
# ampliar el combo (más frames de furia_patada) o pulir arte puntual.
# Sigue sin fondo propio en FONDOS (main.gd) ni póster VS definitivo: por
# ahora usa un póster armado a partir de la pose de batalla.
func _init() -> void:
	nombre_luchador = "Jester"
	color_base = Color(0.62, 0.16, 0.78)
	color_fase = Color(0.95, 0.30, 0.85)
	velocidad = 296.0
	fuerza_salto = -445.0
	gravedad = 1080.0
	dano_punetazo = 7.5
	cooldown_punetazo = 0.19
	poder_por_golpe = 13.0
	ia_prob_patada = 0.38
	ia_prob_bloqueo = 0.22
	ia_prob_retroceso = 0.30
	vida_maxima = 200.0
	vida = 200.0
	# Alquimista tramposa: liviana y esquiva, pega rápido y carga CORE algo
	# más rápido que el promedio (sus pociones son inestables), pero
	# aguanta menos golpes y empuja poco -- riesgo alto, recompensa alta.
	aceleracion = 3600.0
	friccion_suelo = 3700.0
	friccion_aire = 1850.0
	peso_golpe = 0.80

	escala_sprite = 0.65
	textura_parado = load("res://assets/jester/parado.png")
	textura_punetazo = load("res://assets/jester/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/jester/punetazo_2.png"),
		load("res://assets/jester/punetazo_3.png"),
	]
	textura_patada = load("res://assets/jester/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/jester/patada_2.png"),
		load("res://assets/jester/patada_3.png"),
		load("res://assets/jester/patada_4.png"),
	]

	texturas_caminata = [
		load("res://assets/jester/caminata_1.png"),
		load("res://assets/jester/caminata_2.png"),
		load("res://assets/jester/caminata_3.png"),
	]
	textura_salto = load("res://assets/jester/salto.png")
	textura_doble_salto = load("res://assets/jester/doble_salto.png")
	textura_descenso = load("res://assets/jester/descenso.png")
	textura_bloqueo = load("res://assets/jester/bloqueo.png")
	textura_carrera = load("res://assets/jester/carrera.png")
	textura_golpe_recibido = load("res://assets/jester/golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/jester/golpe_recibido_2.png"),
		load("res://assets/jester/golpe_recibido_3.png"),
	]
	textura_derribado = load("res://assets/jester/derribado.png")

	textura_especial = load("res://assets/jester/especial.png")
	textura_recarga = load("res://assets/jester/recarga.png")
	textura_rematador = load("res://assets/jester/rematador.png")
	textura_absoluto = load("res://assets/jester/absoluto.png")
	textura_furia_parado = load("res://assets/jester/furia_parado.png")
	textura_furia_punetazo = load("res://assets/jester/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/jester/furia_punetazo_2.png"),
		load("res://assets/jester/furia_punetazo_3.png"),
		load("res://assets/jester/furia_punetazo_4.png"),
		load("res://assets/jester/furia_punetazo_5.png"),
	]
	# Por ahora un solo frame de patada furia (la única patada que llegó en
	# este lote) -- el combo automático SÍ puede usarla, a diferencia de
	# Magnus, porque acá no hay arte vieja con la que se pueda mezclar.
	textura_furia_patada = load("res://assets/jester/furia_patada_1.png")
	# textura_victoria NO se carga a mano: fighter.gd la detecta sola apenas
	# existe assets/jester/victoria.png (ver _ready(), FASE 85).

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return
	_comportamiento_ia_basico(_delta, vel_actual, 88.0, 310.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(0.95, 0.30, 0.85, 0.85), 150.0, 24.0)
