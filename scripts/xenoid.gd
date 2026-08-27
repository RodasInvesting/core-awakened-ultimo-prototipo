class_name Xenoid
extends Fighter

# CORE AWAKENED 90.11.01 — XENOID CORE SPRINT CLEANUP + COMBAT VARIETY
# Se agregan 6 golpes normales y 3 golpes de combo/furia.
# El orden queda intercalado para que las poses similares no salgan seguidas.

var textura_aceleracion_combo: Texture2D = null
var textura_remate_final_cuerpo: Texture2D = null

func _init() -> void:
	nombre_luchador = "Xenoid"
	color_base = Color(0.42, 1.0, 0.08)
	color_fase = Color(0.28, 1.0, 0.08)

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

	# 90.10.59 — golpes normales ampliados.
	# Se alternan los nuevos con los viejos para evitar repeticiones visuales.
	textura_punetazo = load("res://assets/xenoid/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/xenoid/punetazo_5_90_10_59.png"),
		load("res://assets/xenoid/punetazo_2.png"),
		load("res://assets/xenoid/punetazo_doble_90_10_59.png"),
		load("res://assets/xenoid/punetazo_3.png"),
		load("res://assets/xenoid/punetazo_nuevo_90_10_45.png"),
		load("res://assets/xenoid/punetazo_4.png"),
		load("res://assets/xenoid/punetazo_6_90_10_59.png"),
	]
	textura_patada = load("res://assets/xenoid/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/xenoid/patada_2.png"),
		load("res://assets/xenoid/patada_6_rodillazo_90_10_59.png"),
		load("res://assets/xenoid/patada_3.png"),
		load("res://assets/xenoid/patada_8_lateral_90_10_59.png"),
		load("res://assets/xenoid/patada_4.png"),
		load("res://assets/xenoid/patada_7_baja_90_10_59.png"),
		load("res://assets/xenoid/patada_5.png"),
	]

	# Movimiento completo.
	texturas_caminata = [
		load("res://assets/xenoid/caminata_1.png"),
		load("res://assets/xenoid/caminata_2.png"),
	]
	textura_caminata_der = load("res://assets/xenoid/caminata_1.png")
	textura_caminata_izq = load("res://assets/xenoid/caminata_2.png")
	textura_bloqueo = load("res://assets/xenoid/bloqueo.png")
	textura_carrera = load("res://assets/xenoid/carrera.png")
	textura_salto = load("res://assets/xenoid/salto.png")
	textura_doble_salto = load("res://assets/xenoid/doble_salto.png")
	textura_descenso = load("res://assets/xenoid/descenso.png")

	# Reacciones.
	textura_golpe_recibido = load("res://assets/xenoid/golpe_recibido_espejo_1_90_10_45.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/xenoid/golpe_recibido_espejo_2_90_10_45.png"),
		load("res://assets/xenoid/golpe_recibido_espejo_3_90_10_45.png"),
		load("res://assets/xenoid/golpe_recibido_espejo_4_90_10_45.png"),
	]
	textura_derribado = load("res://assets/xenoid/derribado.png")

	# CORE / Furia.
	textura_recarga = load("res://assets/xenoid/recarga.png")
	textura_victoria = load("res://assets/xenoid/victoria_90_10_45.png")
	textura_especial = load("res://assets/xenoid/especial.png")
	textura_rematador = load("res://assets/xenoid/rematador.png")
	textura_absoluto = load("res://assets/xenoid/gigantografia_90_10_45.png")
	textura_remate_final_cuerpo = load("res://assets/xenoid/remate_final_cuerpo.png")
	textura_aceleracion_combo = load("res://assets/xenoid/aceleracion_combo.png")

	# 90.10.59 — tres golpes extra para el combo/furia, agregados al final.
	# Queda: 5 puños visuales + 4 patadas visuales dentro de la racha.
	textura_furia_punetazo = load("res://assets/xenoid/combo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/xenoid/combo_2.png"),
		load("res://assets/xenoid/combo_3.png"),
		load("res://assets/xenoid/combo_4.png"),
		load("res://assets/xenoid/furia_punetazo_5_90_10_59.png"),
	]
	textura_furia_patada = load("res://assets/xenoid/combo_5.png")
	texturas_furia_patada_extra = [
		load("res://assets/xenoid/combo_6.png"),
		load("res://assets/xenoid/furia_patada_3_90_10_59.png"),
		load("res://assets/xenoid/furia_patada_4_90_10_59.png"),
	]
	textura_furia_parado = load("res://assets/xenoid/furia_parado.png")
	textura_furia_carrera = load("res://assets/xenoid/aceleracion_combo.png")

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return

	_comportamiento_ia_basico(_delta, vel_actual, 90.0, 320.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(0.32, 1.0, 0.12, 0.90), 175.0, 30.0)

# Xenoid tiene una pose específica de aceleración justo antes de cada golpe
# del combo CORE. Conserva la misma lógica física segura del Fighter base.
func _acercar_para_combo_auto() -> void:
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return

	# 90.10.60 — XENOID AIR CORE TARGET LOCK 2D.
	# Xenoid conserva su pose propia de aceleración, pero CORE II/III ahora
	# persigue la posición completa del rival (X + Y). Esto evita que al
	# activarlo desde salto/doble salto pase por encima y pegue en el aire.
	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	if distancia_x <= DISTANCIA_COMBO_AUTO_OBJETIVO \
		and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * DISTANCIA_COMBO_AUTO_OBJETIVO,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	# 90.11.01 — la pose de sprint se muestra SOLO en el acercamiento inicial
	# previo a la ráfaga. Durante en_combo_auto_visual, las microcorrecciones de
	# posición se hacen silenciosamente para no tapar los sprites de ataque.
	if not en_combo_auto_visual and textura_aceleracion_combo and sprite:
		_actualizar_textura(textura_aceleracion_combo)
		pose_timer = duracion + 0.04

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", destino, duracion)
	await tween.finished
	velocity = Vector2.ZERO

# En el último golpe del tercer CORE el cuerpo usa el remate con los pequeños
# Xenoid, mientras la gigantografía verde aparece arriba/detrás mediante
# textura_absoluto. Antes de entrar en Furia conserva el comportamiento base.
func _pose_final_especial(duracion: float) -> void:
	if en_fase_absoluta and textura_remate_final_cuerpo:
		_actualizar_textura(textura_remate_final_cuerpo)
		pose_timer = duracion
		return
	var lista: Array[Texture2D] = _lista_punetazo()
	if not lista.is_empty():
		_actualizar_textura(lista[lista.size() - 1])
		pose_timer = duracion
