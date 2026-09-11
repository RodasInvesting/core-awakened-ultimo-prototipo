class_name Kali
extends Fighter

# CORE AWAKENED 90.10.68 — KALI NORMAL KICKS + FURY COMBO EXTENSION
# Se agregan 2 patadas normales nuevas y 3 sprites Furia nuevos.
# No se reemplaza el repertorio existente; sólo se amplía e intercala.

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
	aceleracion = 3520.0
	friccion_suelo = 3888.0
	friccion_aire = 1944.0
	peso_golpe = 0.75

	escala_sprite = 0.6378
	textura_parado = load("res://assets/kali/parado.png")
	textura_punetazo = load("res://assets/kali/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/kali/punetazo_2.png"),
		load("res://assets/kali/punetazo_3.png"),
		load("res://assets/kali/punetazo_4.png"),
	]

	# 90.10.68 — 6 patadas normales en total. Las dos nuevas se intercalan
	# con el repertorio actual para evitar secuencias demasiado parecidas.
	textura_patada = load("res://assets/kali/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/kali/patada_2.png"),
		load("res://assets/kali/patada_5_90_10_68.png"),
		load("res://assets/kali/patada_3.png"),
		load("res://assets/kali/patada_6_90_10_68.png"),
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
	textura_absoluto = load("res://assets/kali/gigantografia_core3_nueva.png")
	textura_recarga = load("res://assets/kali/recarga.png")
	textura_furia_parado = load("res://assets/kali/furia_parado.png")

	# 90.10.68 — combo Furia ampliado de 6 a 9 golpes visuales.
	# Se suman 2 ataques Furia de mano y 1 ataque Furia de pierna
	# hacia el tramo final del CORE III antes del remate.
	textura_furia_punetazo = load("res://assets/kali/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/kali/furia_punetazo_2.png"),
		load("res://assets/kali/furia_punetazo_3.png"),
		load("res://assets/kali/furia_punetazo_4_90_10_68.png"),
		load("res://assets/kali/furia_punetazo_5_90_10_68.png"),
	]
	textura_furia_patada = load("res://assets/kali/furia_patada_1.png")
	texturas_furia_patada_extra = [
		load("res://assets/kali/furia_patada_2.png"),
		load("res://assets/kali/furia_patada_3.png"),
		load("res://assets/kali/furia_patada_4_90_10_68.png"),
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

	# 91.02.51 — PASS 12H / PROYECTIL TANDA 2 — KALI.
	proyectil_especial_habilitado = true
	textura_proyectil_pose = load("res://assets/kali/poder_proyectil.png")
	textura_proyectil_nucleo = load("res://assets/kali/proyectil_oficial.png")
	# 91.02.52 — compensación leve por el VFX incluido en el PNG.
	proyectil_pose_escala_mult = 1.12
	color_proyectil_primario = Color(0.42, 0.95, 0.08, 1.0)
	color_proyectil_secundario = Color(0.93, 1.0, 0.48, 1.0)
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
	_comportamiento_ia_basico(_delta, vel_actual, 85.0, 300.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(0.55, 0.95, 0.2, 0.85), 150.0, 26.0)
