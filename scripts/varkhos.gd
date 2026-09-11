class_name Varkhos
extends Fighter

# VARKHOS — PASS 10.3V / 91.02.39 — SPRITES FINALES DE QA.
# Integra el set visual definitivo suministrado por el usuario para reposo,
# recarga, victoria, derrota, bloqueo, reacciones, puños y patada adicional.
# No modifica timings, daño, física, CORE, pushbox, rollback ni netcode.
# VARKHOS — HOTFIX 90.9.4.1.
# Compatible con el Fighter actual: elimina la referencia a un miembro inexistente
# que impedía compilar/instanciar la clase con Varkhos.new().
# Jefe final pesado, demoníaco y más grande que el resto del roster.
# No salta: pelea siempre pegado al piso como una bestia colosal.

var textura_aceleracion_combo: Texture2D = null
const RUTA_VARKHOS := "res://assets/varkhos_final/"

func _init() -> void:
	nombre_luchador = "Varkhos"
	color_base = Color(0.90, 0.12, 0.18)
	color_fase = Color(0.72, 0.12, 1.00)

	# Perfil pesado / jefe final.
	velocidad = 255.0
	fuerza_salto = 0.0
	gravedad = 1280.0
	dano_punetazo = 9.5
	cooldown_punetazo = 0.24
	poder_por_golpe = 14.0
	ia_prob_patada = 0.38
	ia_prob_bloqueo = 0.22
	ia_prob_retroceso = 0.22
	vida_maxima = 290.0
	vida = 290.0
	aceleracion = 3200.0
	friccion_suelo = 3900.0
	friccion_aire = 2200.0
	peso_golpe = 1.35
	escala_sprite = 0.80


	textura_parado = load(RUTA_VARKHOS + "parado.png")
	textura_victoria = load(RUTA_VARKHOS + "victoria.png")
	textura_bloqueo = load(RUTA_VARKHOS + "bloqueo.png")

	textura_punetazo = load(RUTA_VARKHOS + "punetazo_1.png")
	texturas_punetazo_extra = [
		load(RUTA_VARKHOS + "punetazo_2.png"),
		load(RUTA_VARKHOS + "punetazo_3.png"),
		load(RUTA_VARKHOS + "punetazo_4.png"),
		# 91.02.39 — quinto arte de puño agregado sin alterar su lógica.
		load(RUTA_VARKHOS + "punetazo_5.png"),
	]

	textura_patada = load(RUTA_VARKHOS + "patada_1.png")
	texturas_patada_extra = [
		load(RUTA_VARKHOS + "patada_2.png"),
		load(RUTA_VARKHOS + "patada_3.png"),
		load(RUTA_VARKHOS + "patada_4.png"),
	]

	texturas_caminata = [
		load(RUTA_VARKHOS + "caminata_1.png"),
		load(RUTA_VARKHOS + "caminata_2.png"),
	]
	textura_caminata_der = load(RUTA_VARKHOS + "caminata_1.png")
	textura_caminata_izq = load(RUTA_VARKHOS + "caminata_2.png")
	textura_carrera = load(RUTA_VARKHOS + "carrera.png")

	# Aunque el jefe no salta, se cargan poses seguras para evitar huecos si
	# alguna lógica externa intenta consultarlas.
	textura_salto = load(RUTA_VARKHOS + "salto.png")
	textura_doble_salto = load(RUTA_VARKHOS + "doble_salto.png")
	textura_descenso = load(RUTA_VARKHOS + "descenso.png")

	textura_golpe_recibido = load(RUTA_VARKHOS + "golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load(RUTA_VARKHOS + "golpe_recibido_2.png"),
		load(RUTA_VARKHOS + "golpe_recibido_3.png"),
	]
	textura_derribado = load(RUTA_VARKHOS + "derribado.png")

	textura_recarga = load(RUTA_VARKHOS + "recarga.png")
	textura_especial = load(RUTA_VARKHOS + "especial.png")
	textura_rematador = load(RUTA_VARKHOS + "rematador.png")
	textura_absoluto = load(RUTA_VARKHOS + "absoluto.png")
	textura_aceleracion_combo = load(RUTA_VARKHOS + "aceleracion_combo.png")

	textura_furia_parado = load(RUTA_VARKHOS + "parado.png")
	textura_furia_bloqueo = load(RUTA_VARKHOS + "bloqueo.png")
	texturas_furia_caminata = [
		load(RUTA_VARKHOS + "caminata_1.png"),
		load(RUTA_VARKHOS + "caminata_2.png"),
	]
	textura_furia_carrera = load(RUTA_VARKHOS + "aceleracion_combo.png")
	textura_furia_salto = load(RUTA_VARKHOS + "salto.png")
	textura_furia_doble_salto = load(RUTA_VARKHOS + "doble_salto.png")
	textura_furia_descenso = load(RUTA_VARKHOS + "descenso.png")
	textura_furia_golpe_recibido = load(RUTA_VARKHOS + "golpe_recibido.png")
	textura_furia_derribado = load(RUTA_VARKHOS + "derribado.png")

	# Combo de 6 golpes en orden visual 1..6.
	textura_furia_punetazo = load(RUTA_VARKHOS + "combo_1.png")
	texturas_furia_punetazo_extra = [
		load(RUTA_VARKHOS + "combo_3.png"),
		load(RUTA_VARKHOS + "combo_5.png"),
	]
	textura_furia_patada = load(RUTA_VARKHOS + "combo_2.png")
	texturas_furia_patada_extra = [
		load(RUTA_VARKHOS + "combo_4.png"),
		load(RUTA_VARKHOS + "combo_6.png"),
	]

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador_varkhos(vel_actual)
		return
	_comportamiento_ia_basico(_delta, vel_actual, 90.0, 320.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

# Varkhos no salta. Conserva carrera, bloqueo, golpes y poder.
func _entrada_jugador_varkhos(vel_actual: float) -> void:
	var izquierda: bool = Input.is_physical_key_pressed(KEY_LEFT)
	var derecha: bool = Input.is_physical_key_pressed(KEY_RIGHT)
	var izquierda_justa: bool = izquierda and not tecla_izq_previa
	var derecha_justa: bool = derecha and not tecla_der_previa

	doble_pulso_izq_timer = maxf(0.0, doble_pulso_izq_timer - _delta_actual)
	doble_pulso_der_timer = maxf(0.0, doble_pulso_der_timer - _delta_actual)

	if izquierda_justa:
		if doble_pulso_izq_timer > 0.0:
			_iniciar_carrera(-1.0)
			doble_pulso_izq_timer = 0.0
		else:
			doble_pulso_izq_timer = VENTANA_DOBLE_PULSO_CARRERA
		if carrera_activa and carrera_direccion > 0.0:
			_detener_carrera()

	if derecha_justa:
		if doble_pulso_der_timer > 0.0:
			_iniciar_carrera(1.0)
			doble_pulso_der_timer = 0.0
		else:
			doble_pulso_der_timer = VENTANA_DOBLE_PULSO_CARRERA
		if carrera_activa and carrera_direccion < 0.0:
			_detener_carrera()

	if carrera_activa:
		if (carrera_direccion < 0.0 and not izquierda) or (carrera_direccion > 0.0 and not derecha):
			_detener_carrera()

	tecla_izq_previa = izquierda
	tecla_der_previa = derecha

	var direccion: float = 0.0
	if izquierda:
		direccion -= 1.0
	if derecha:
		direccion += 1.0
	var velocidad_input: float = vel_actual * (MULT_CARRERA if carrera_activa else 1.0)
	mover(direccion, velocidad_input)

	if Input.is_physical_key_pressed(KEY_DOWN):
		if not bloqueando:
			_iniciar_bloqueo(999.0)
	elif bloqueando:
		_detener_bloqueo()

	if Input.is_physical_key_pressed(KEY_X):
		intentar_punetazo()
	if Input.is_physical_key_pressed(KEY_C):
		intentar_patada()

	var z_presionado: bool = Input.is_physical_key_pressed(KEY_Z)
	if z_presionado and not z_estaba_presionado:
		intentar_poder_especial()
	z_estaba_presionado = z_presionado

func saltar() -> void:
	return

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(0.95, 0.12, 0.20, 0.92), 195.0, 34.0)

func _acercar_para_combo_auto() -> void:
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return
	var dx: float = objetivo.global_position.x - global_position.x
	var distancia: float = absf(dx)
	if distancia <= DISTANCIA_COMBO_AUTO_OBJETIVO:
		return
	var lado: float = signf(dx)
	mirando = lado
	var distancia_objetivo: float = DISTANCIA_COMBO_AUTO_OBJETIVO
	if distancia > DISTANCIA_COMBO_AUTO_MAX:
		distancia_objetivo = 110.0
	var destino_x: float = objetivo.global_position.x - lado * distancia_objetivo
	var duracion: float = clampf(distancia / 880.0, 0.09, 0.22)
	if textura_aceleracion_combo and sprite:
		_actualizar_textura(textura_aceleracion_combo)
		pose_timer = duracion + 0.04
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:x", destino_x, duracion)
	await tween.finished
	velocity.x = 0.0
