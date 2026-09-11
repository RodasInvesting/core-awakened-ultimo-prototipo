class_name Jester
extends Fighter

# CORE AWAKENED 90.10.61 — JESTER NORMAL EXPANSION + FURIA TOTAL REPLACEMENT
# - Se agregan golpes normales nuevos sin eliminar los normales anteriores.
# - Se reemplaza por completo el set de combo/Furia/Core 3 por el nuevo modelo
#   enviado por el usuario para evitar el problema de escala del set anterior.

func _cargar_tex(ruta: String) -> Texture2D:
	if ResourceLoader.exists(ruta, "Texture2D"):
		return load(ruta)
	return null

func _cargar_lista(rutas: Array[String]) -> Array[Texture2D]:
	var salida: Array[Texture2D] = []
	for ruta in rutas:
		var tex := _cargar_tex(ruta)
		if tex:
			salida.append(tex)
	return salida

func _init() -> void:
	nombre_luchador = "Jester"
	color_base = Color(0.83, 0.25, 0.88)
	color_fase = Color(1.0, 0.35, 0.95)

	# Perfil: ágil, técnico y tramposo.
	velocidad = 250.0
	fuerza_salto = -435.0
	gravedad = 1195.0
	aceleracion = 2550.0
	friccion_suelo = 2900.0
	friccion_aire = 1320.0
	peso_golpe = 0.95
	dano_punetazo = 8.7
	rango_punetazo = 92.0
	rango_patada = 104.0
	cooldown_punetazo = 0.21
	cooldown_patada = 0.40
	poder_por_golpe = 11.5
	ia_prob_patada = 0.42
	ia_prob_bloqueo = 0.16
	ia_prob_retroceso = 0.20
	vida_maxima = 200.0
	vida = 200.0
	escala_sprite = 0.66

	# Base / movimiento general.
	textura_parado = _cargar_tex("res://assets/jester/parado.png")
	texturas_caminata = _cargar_lista([
		"res://assets/jester/caminata_1.png",
		"res://assets/jester/caminata_2.png",
	])
	textura_caminata_der = _cargar_tex("res://assets/jester/caminata_1.png")
	textura_caminata_izq = _cargar_tex("res://assets/jester/caminata_2.png")
	textura_carrera = _cargar_tex("res://assets/jester/carrera.png")
	textura_evasion = _cargar_tex("res://assets/jester/evasion.png")
	textura_salto = _cargar_tex("res://assets/jester/salto.png")
	textura_doble_salto = _cargar_tex("res://assets/jester/doble_salto.png")
	textura_descenso = _cargar_tex("res://assets/jester/descenso.png")
	textura_bloqueo = _cargar_tex("res://assets/jester/bloqueo.png") # 90.11.26: sprite de bloqueo recuperado

	# Reacciones.
	textura_golpe_recibido = _cargar_tex("res://assets/jester/golpe_recibido.png")
	texturas_golpe_recibido_extra = _cargar_lista([
		"res://assets/jester/golpe_recibido_2.png",
		"res://assets/jester/golpe_recibido_3.png",
		"res://assets/jester/golpe_recibido_4.png",
	])
	textura_derribado = _cargar_tex("res://assets/jester/derribado.png")
	textura_recarga = _cargar_tex("res://assets/jester/recarga.png")
	textura_victoria = _cargar_tex("res://assets/jester/victoria.png")

	# Normales: se conservan los viejos y se suman los nuevos intercalados
	# para que el combate se vea variado y no repita poses muy parecidas.
	textura_punetazo = _cargar_tex("res://assets/jester/punetazo_1.png")
	texturas_punetazo_extra = _cargar_lista([
		"res://assets/jester/punetazo_2.png",
		"res://assets/jester/punetazo_5_90_10_61.png",
		"res://assets/jester/punetazo_3.png",
		"res://assets/jester/punetazo_6_90_10_61.png",
		"res://assets/jester/punetazo_4.png",
	])
	textura_patada = _cargar_tex("res://assets/jester/patada_1.png")
	texturas_patada_extra = _cargar_lista([
		"res://assets/jester/patada_2.png",
		"res://assets/jester/patada_4_90_10_61.png",
		"res://assets/jester/patada_3.png",
		"res://assets/jester/patada_5_90_10_61.png",
		"res://assets/jester/patada_6_90_10_61.png",
	])

	# Especial / remate / gigantografía: se apuntan al nuevo modelo Furia.
	textura_especial = _cargar_tex("res://assets/jester/furia_especial_90_10_61.png")
	textura_rematador = _cargar_tex("res://assets/jester/furia_punetazo_2_90_10_61.png")
	textura_absoluto = _cargar_tex("res://assets/jester/gigantografia_core3_final_90_10_62.png")

	# Reemplazo TOTAL del set Furia / Core 3.
	textura_furia_parado = _cargar_tex("res://assets/jester/furia_especial_90_10_61.png")
	textura_furia_punetazo = _cargar_tex("res://assets/jester/furia_punetazo_1_90_10_61.png")
	texturas_furia_punetazo_extra = _cargar_lista([
		"res://assets/jester/furia_punetazo_2_90_10_61.png",
		"res://assets/jester/furia_punetazo_3_90_10_61.png",
	])
	textura_furia_patada = _cargar_tex("res://assets/jester/furia_patada_1_90_10_61.png")
	texturas_furia_patada_extra = _cargar_lista([
		"res://assets/jester/furia_patada_2_90_10_61.png",
		"res://assets/jester/furia_patada_3_90_10_61.png",
	])
	# Fallbacks del set Furia si existen artes específicos en el proyecto.
	textura_furia_carrera = _cargar_tex("res://assets/jester/furia_carrera.png")
	textura_furia_golpe_recibido = _cargar_tex("res://assets/jester/furia_golpe_recibido.png")
	textura_furia_derribado = _cargar_tex("res://assets/jester/furia_derribado.png")
	textura_furia_bloqueo = _cargar_tex("res://assets/jester/furia_bloqueo.png")
	textura_furia_salto = _cargar_tex("res://assets/jester/furia_salto.png")
	textura_furia_doble_salto = _cargar_tex("res://assets/jester/furia_doble_salto.png")
	textura_furia_descenso = _cargar_tex("res://assets/jester/furia_descenso.png")
	texturas_furia_caminata = _cargar_lista([
		"res://assets/jester/furia_caminata_1.png",
		"res://assets/jester/furia_caminata_2.png",
	])
	textura_furia_caminata_der = _cargar_tex("res://assets/jester/furia_caminata_1.png")
	textura_furia_caminata_izq = _cargar_tex("res://assets/jester/furia_caminata_2.png")

	# 91.02.53 — PASS 12J / PROYECTIL TANDA 3 — JESTER.
	proyectil_especial_habilitado = true
	textura_proyectil_pose = _cargar_tex("res://assets/jester/poder_proyectil.png")
	textura_proyectil_nucleo = _cargar_tex("res://assets/jester/proyectil_oficial.png")
	proyectil_pose_escala_mult = 1.10
	color_proyectil_primario = Color(0.82, 0.06, 0.92, 1.0)
	color_proyectil_secundario = Color(1.0, 0.30, 0.72, 1.0)
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
	_comportamiento_ia_basico(_delta, vel_actual, 92.0, 290.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(1.0, 0.25, 0.90, 0.88), 160.0, 28.0)
