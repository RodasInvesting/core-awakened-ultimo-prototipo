class_name Magnus
extends Fighter

func _init() -> void:
	nombre_luchador = "Magnus"
	color_base = Color(0.45, 0.38, 0.28)
	color_fase = Color(0.85, 0.5, 0.15)
	velocidad = 168.0
	fuerza_salto = -382.0
	gravedad = 1340.0
	vida_maxima = 310.0
	vida = 310.0
	ancho_cuerpo = 50.0
	alto_cuerpo = 85.0
	mult_tamano_extra = 1.12
	dano_punetazo = 16.0
	cooldown_punetazo = 0.43
	poder_por_golpe = 16.0
	ia_prob_patada = 0.20
	ia_prob_bloqueo = 0.28
	ia_prob_retroceso = 0.05
	# Pesado: tarda en arrancar y no frena en seco (más inercia que el resto).
	aceleracion = 1540.0
	friccion_suelo = 1620.0
	friccion_aire = 756.0
	# Sus golpes también pegan pesado: más empuje y más aturdimiento en
	# el rival que le toca recibirlos.
	peso_golpe = 1.6

	escala_sprite = 0.7595
	textura_parado = load("res://assets/magnus/parado.png")
	textura_punetazo = load("res://assets/magnus/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/magnus/punetazo_2.png"),
		load("res://assets/magnus/punetazo_3.png"),
		load("res://assets/magnus/punetazo_4.png"),
		load("res://assets/magnus/punetazo_5.png"),
	]
	textura_patada = load("res://assets/magnus/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/magnus/patada_2.png"),
		load("res://assets/magnus/patada_3.png"),
		load("res://assets/magnus/patada_4.png"),
		load("res://assets/magnus/patada_5.png"),
	]
	textura_golpe_recibido = load("res://assets/magnus/golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/magnus/golpe_recibido_2.png"),
		load("res://assets/magnus/golpe_recibido_3.png"),
		load("res://assets/magnus/golpe_recibido_4.png"),
	]
	textura_derribado = load("res://assets/magnus/derribado.png")
	textura_especial = load("res://assets/magnus/especial.png")
	textura_rematador = load("res://assets/magnus/rematador.png")
	textura_absoluto = load("res://assets/magnus/absoluto.png")
	textura_recarga = load("res://assets/magnus/recarga.png")
	textura_furia_parado = load("res://assets/magnus/furia_parado.png")
	textura_furia_punetazo = load("res://assets/magnus/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/magnus/furia_punetazo_2.png"),
		load("res://assets/magnus/furia_punetazo_3.png"),
		load("res://assets/magnus/furia_punetazo_4.png"),
		load("res://assets/magnus/furia_punetazo_5.png"),
		load("res://assets/magnus/furia_punetazo_6.png"),
	]
	textura_furia_patada = load("res://assets/magnus/furia_patada_1.png")
	texturas_furia_patada_extra = [
		load("res://assets/magnus/furia_patada_2.png"),
	]
	textura_furia_golpe_recibido = load("res://assets/magnus/furia_golpe_recibido.png")
	textura_furia_derribado = load("res://assets/magnus/furia_derribado.png")
	# FASE 92.1: furia_patada sigue con arte de la camada vieja (nadie mandó
	# patadas nuevas para el combo). Mientras tanto, el combo automático de
	# Magnus pega solo con puños -- así no se mezcla una patada chica y
	# vieja en medio de los golpes grandes y nuevos.
	combo_auto_incluye_patada = false

	textura_caminata_der = load("res://assets/magnus/caminata_der.png")
	textura_caminata_izq = load("res://assets/magnus/caminata_izq.png")
	textura_salto = load("res://assets/magnus/salto.png")
	textura_doble_salto = load("res://assets/magnus/doble_salto.png")
	textura_bloqueo = load("res://assets/magnus/bloqueo.png")
	textura_descenso = load("res://assets/magnus/descenso.png")
	textura_carrera = load("res://assets/magnus/carrera.png")
	# textura_victoria NO se carga a mano: fighter.gd la detecta sola apenas
	# existe assets/magnus/victoria.png (ver _ready(), FASE 85).

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return
	_comportamiento_ia_basico(_delta, vel_actual, 100.0, 260.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(1.0, 0.6, 0.15, 0.85), 170.0, 34.0)
