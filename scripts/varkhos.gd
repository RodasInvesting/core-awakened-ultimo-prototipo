class_name Varkhos
extends Fighter

# JEFE FINAL DE ARCADE (fase 90, WIP): Varkhos, "El Ojo del Núcleo". NO es
# un personaje del ROSTER -- no aparece en el selector ni en Batalla Rápida.
# game_state.gd lo agrega como último rival, siempre, al final de la lista
# de oponentes de Arcade (ver iniciar_arcade), así queda "bloqueado hasta
# el final de la batalla" como pidió el diseño. Para probarlo sin jugar
# todo el torneo, está en el atajo de debug de main.gd (tecla 8, rival).
#
# ARTE: por ahora solo llegaron sus dos ilustraciones de estado (normal /
# furia), no un set de combate como el resto del roster. Eso alcanza para
# parado y furia_parado (se activa solo cuando SU propio CORE se carga,
# igual que a cualquier otro personaje). PERO: intentar_punetazo() e
# intentar_patada() en fighter.gd se cancelan solos si la lista de
# texturas de ese golpe está vacía -- sin una imagen puesta ahí, Varkhos
# no podría atacar nunca. Por eso punetazo_1 y patada_1 reusan
# temporalmente la misma ilustración normal: pega de verdad (el daño y el
# empuje son reales), pero todavía no hay una animación de golpe propia.
# Falta, para un set completo: golpe_recibido, derribado, especial/
# rematador/absoluto, recarga y victoria -- todos con resguardo seguro
# mientras tanto (fighter.gd no rompe con ellos en null).
func _init() -> void:
	nombre_luchador = "Varkhos"
	color_base = Color(0.30, 0.03, 0.07)
	color_fase = Color(0.85, 0.08, 0.16)
	# Grande, lento y pesado: no esquiva, no retrocede casi nunca, y cuando
	# conecta se siente -- el objetivo es que dé miedo acercarse, no que
	# sea rápido.
	velocidad = 150.0
	fuerza_salto = -360.0
	gravedad = 1300.0
	dano_punetazo = 20.0
	dano_patada = 18.0
	cooldown_punetazo = 0.50
	cooldown_patada = 0.58
	poder_por_golpe = 14.0
	ia_prob_patada = 0.30
	ia_prob_bloqueo = 0.08
	ia_prob_retroceso = 0.05
	vida_maxima = 480.0
	vida = 480.0
	rango_punetazo = 112.0
	rango_patada = 122.0
	ancho_cuerpo = 56.0
	alto_cuerpo = 92.0
	peso_golpe = 2.2
	aceleracion = 2000.0
	friccion_suelo = 2600.0
	friccion_aire = 900.0
	# Tamaño físico (colisión/anclaje de póster). El tamaño VISIBLE del
	# sprite se controla aparte, en ALTURA_AJUSTES_VISUALES (fighter.gd).
	mult_tamano_extra = 1.45

	escala_sprite = 0.75
	textura_parado = load("res://assets/varkhos/parado.png")
	textura_furia_parado = load("res://assets/varkhos/furia_parado.png")
	textura_punetazo = load("res://assets/varkhos/punetazo_1.png")
	textura_patada = load("res://assets/varkhos/patada_1.png")

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return
	# Persigue de largo (no se cansa de acercarse) y ataca en cuanto puede.
	_comportamiento_ia_basico(_delta, vel_actual, 112.0, 420.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(0.85, 0.08, 0.16, 0.9), 220.0, 40.0)
