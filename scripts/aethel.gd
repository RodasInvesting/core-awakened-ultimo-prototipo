class_name Aethel
extends Fighter

# AETHEL REDISEÑO FINAL
# Las imágenes nuevas viven en una carpeta distinta a assets/aethel/.
# Esto evita que Fighter reutilice las escalas precalculadas antiguas
# asociadas a los PNG viejos de Aethel.

var textura_aceleracion_combo: Texture2D = null

func _init() -> void:
	nombre_luchador = "Aethel"
	color_base = Color(0.75, 0.82, 0.9)
	color_fase = Color(0.45, 0.88, 1.0)

	# Perfil original conservado.
	velocidad = 280.0
	fuerza_salto = -452.0
	gravedad = 1040.0
	dano_punetazo = 6.0
	cooldown_punetazo = 0.22
	poder_por_golpe = 10.0
	ia_prob_patada = 0.42
	ia_prob_bloqueo = 0.20
	ia_prob_retroceso = 0.32
	aceleracion = 3400.0
	friccion_suelo = 3800.0
	friccion_aire = 2200.0
	escala_sprite = 0.7261

	const AETHEL_NEW := "res://assets/aethel_redesign_final/"

	# ============================================================
	# NORMAL
	# ============================================================
	textura_parado = load(AETHEL_NEW + "parado.png")

	# 90.10.66 — 5 puños normales en total.
	# Se suma un nuevo puño frontal para dar más variedad al repertorio base
	# sin tocar las poses de Furia ya cerradas.
	textura_punetazo = load(AETHEL_NEW + "punetazo_1.png")
	texturas_punetazo_extra = [
		load(AETHEL_NEW + "punetazo_2.png"),
		load(AETHEL_NEW + "punetazo_5_90_10_66.png"),
		load(AETHEL_NEW + "punetazo_3.png"),
		load(AETHEL_NEW + "punetazo_4.png"),
	]

	# 90.10.66 — 6 patadas normales en total.
	# Se agregan un rodillazo aéreo y una patada lateral larga; se intercalan
	# entre las poses anteriores para que el juego no repita movimientos muy parecidos seguidos.
	textura_patada = load(AETHEL_NEW + "patada_1.png")
	texturas_patada_extra = [
		load(AETHEL_NEW + "patada_2.png"),
		load(AETHEL_NEW + "patada_5_rodillazo_90_10_66.png"),
		load(AETHEL_NEW + "patada_3.png"),
		load(AETHEL_NEW + "patada_6_90_10_66.png"),
		load(AETHEL_NEW + "patada_4.png"),
	]

	# Reacciones.
	textura_golpe_recibido = load(AETHEL_NEW + "golpe_recibido_1.png")
	texturas_golpe_recibido_extra = [
		load(AETHEL_NEW + "golpe_recibido_2.png"),
		load(AETHEL_NEW + "golpe_recibido_3.png"),
	]
	textura_derribado = load(AETHEL_NEW + "derribado.png")

	# ============================================================
	# MOVIMIENTO
	# ============================================================
	# Aethel levita en vez de caminar. Se usa la misma pose para ambos
	# pasos para conservar su identidad aérea.
	texturas_caminata = [
		load(AETHEL_NEW + "levitacion.png"),
		load(AETHEL_NEW + "levitacion.png"),
	]
	textura_caminata_der = load(AETHEL_NEW + "levitacion.png")
	textura_caminata_izq = load(AETHEL_NEW + "levitacion.png")

	textura_carrera = load(AETHEL_NEW + "carrera.png")
	# 90.10.44 — backdash dedicado del rediseño final.
	textura_evasion = load(AETHEL_NEW + "evasion.png")
	textura_furia_evasion = textura_evasion
	textura_salto = load(AETHEL_NEW + "salto.png")
	textura_doble_salto = load(AETHEL_NEW + "doble_salto.png")
	textura_descenso = load(AETHEL_NEW + "descenso.png")
	textura_bloqueo = load(AETHEL_NEW + "bloqueo.png")

	# ============================================================
	# RECARGA / VICTORIA
	# ============================================================
	textura_recarga = load(AETHEL_NEW + "recarga.png")
	textura_victoria = load(AETHEL_NEW + "victoria.png")

	# ============================================================
	# CORE
	# ============================================================
	# El primer CORE y la gigantografía del Absoluto se conservan por ahora,
	# porque todavía no recibimos sustitutos específicos para esas imágenes.
	textura_especial = load("res://assets/aethel/especial.png")
	textura_absoluto = load("res://assets/aethel/absoluto.png")

	# El remate corporal sí usa el nuevo diseño.
	textura_rematador = load(AETHEL_NEW + "rematador.png")

	# ============================================================
	# COMBO / FURIA — 6 GOLPES NUEVOS
	# El motor alterna las listas de puños y patadas.
	# Se distribuyen 1-3-5 como puños y 2-4-6 como patadas para conservar
	# el orden visual de la secuencia completa.
	# ============================================================
	textura_furia_parado = load(AETHEL_NEW + "parado.png")

	textura_furia_punetazo = load(AETHEL_NEW + "combo_1.png")
	texturas_furia_punetazo_extra = [
		load(AETHEL_NEW + "combo_3.png"),
		load(AETHEL_NEW + "combo_5.png"),
	]

	textura_furia_patada = load(AETHEL_NEW + "combo_2.png")
	texturas_furia_patada_extra = [
		load(AETHEL_NEW + "combo_4.png"),
		load(AETHEL_NEW + "combo_6.png"),
	]

	# En Furia se mantiene el arte nuevo también al recibir daño.
	textura_furia_golpe_recibido = load(AETHEL_NEW + "golpe_recibido_1.png")
	textura_furia_derribado = load(AETHEL_NEW + "derribado.png")

	texturas_furia_caminata = [
		load(AETHEL_NEW + "levitacion.png"),
		load(AETHEL_NEW + "levitacion.png"),
	]

	textura_furia_salto = load(AETHEL_NEW + "salto.png")
	textura_furia_doble_salto = load(AETHEL_NEW + "doble_salto.png")
	textura_furia_descenso = load(AETHEL_NEW + "descenso.png")
	textura_furia_bloqueo = load(AETHEL_NEW + "bloqueo.png")

	# Aceleración normal y previa al combo.
	textura_furia_carrera = load(AETHEL_NEW + "aceleracion_combo.png")
	textura_aceleracion_combo = load(AETHEL_NEW + "aceleracion_combo.png")

	# 91.02.51 — PASS 12H / PROYECTIL TANDA 2 — AETHEL.
	proyectil_especial_habilitado = true
	textura_proyectil_pose = load(AETHEL_NEW + "poder_proyectil.png")
	textura_proyectil_nucleo = load(AETHEL_NEW + "proyectil_oficial.png")
	# 91.02.52 — su PNG de lanzamiento incluye alas + energía y la
	# normalización geométrica achicaba demasiado el cuerpo en pantalla.
	proyectil_pose_escala_mult = 1.34
	color_proyectil_primario = Color(0.10, 0.58, 1.0, 1.0)
	color_proyectil_secundario = Color(0.88, 0.97, 1.0, 1.0)
	proyectil_velocidad = 805.0
	proyectil_dano_mult = 0.86
	proyectil_empuje = 148.0
	proyectil_hitstun = 0.22
	proyectil_startup = 0.16
	proyectil_recovery = 0.30
	proyectil_cooldown = 0.62
	sonido_proyectil_impacto = load("res://assets/helena/proyectil_impacto.wav")


func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return

	_comportamiento_ia_basico(_delta, vel_actual, 90.0, 320.0)
	if poder >= poder_maximo:
		intentar_poder_especial()


func _ejecutar_especial() -> void:
	_efecto_estallido(Color(0.55, 0.90, 1.0, 0.88), 165.0, 25.0)


# Aethel usa una pose de aceleración propia antes de los golpes del combo CORE.
# La lógica de movimiento es la misma que ya usa el Fighter moderno.
func _acercar_para_combo_auto() -> void:
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return

	# 90.11.00 — AETHEL AIR CORE TARGET LOCK 2D.
	# Aethel conservaba el override antiguo que sólo tween-eaba global_position.x.
	# Si CORE II/III arrancaba desde salto/doble salto, avanzaba horizontalmente
	# manteniendo su altura y podía ejecutar toda la ráfaga por encima del rival.
	# Ahora usa la misma lógica 2D/adaptativa del Fighter moderno, manteniendo
	# su pose exclusiva de aceleración antes de cada golpe.
	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_combo_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)
	if distancia_x <= distancia_combo_objetivo \
		and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_combo_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	if textura_aceleracion_combo and sprite:
		_actualizar_textura(textura_aceleracion_combo)
		pose_timer = duracion + 0.04

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", destino, duracion)
	await tween.finished
	velocity = Vector2.ZERO
