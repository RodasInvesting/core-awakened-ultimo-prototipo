class_name Helena
extends Fighter

func _init() -> void:
	nombre_luchador = "Helena"
	color_base = Color(0.9, 0.35, 0.65)
	color_fase = Color(1.0, 0.55, 0.85)
	velocidad = 302.0
	fuerza_salto = -425.0
	gravedad = 1160.0
	aceleracion = 3300.0
	friccion_suelo = 3402.0
	friccion_aire = 1566.0
	peso_golpe = 0.96
	vida_maxima = 240.0
	vida = 240.0
	dano_punetazo = 11.0
	cooldown_punetazo = 0.21
	poder_por_golpe = 15.0
	# 91.02.78 — PRE-RC HOTFIX: se conserva TODO el bloque de proyectil certificado
	# y se elimina únicamente la referencia inexistente a punetazo_9.png.
	# En el remix de CORE II priorizamos 4 patadas + 1 puño para que sus cinco
	# poses de pierna se perciban con la misma riqueza que en combo manual.
	combo_core_remix_prioriza_patadas = true
	combo_core_remix_patadas_objetivo = 4
	ia_prob_patada = 0.35
	ia_prob_bloqueo = 0.20
	ia_prob_retroceso = 0.15

	escala_sprite = 0.6486
	textura_parado = load("res://assets/helena/parado.png")

	# 90.10.56 — repertorio normal ampliado.
	# El doble puño nuevo queda como SEGUNDO cuadro de la rotación para que
	# aparezca temprano y corte la repetición visual de los golpes anteriores.
	textura_punetazo = load("res://assets/helena/punetazo_1.png")
	texturas_punetazo_extra = [
		load("res://assets/helena/punetazo_10.png"),
		load("res://assets/helena/punetazo_2.png"),
		load("res://assets/helena/punetazo_3.png"),
		load("res://assets/helena/punetazo_4.png"),
		load("res://assets/helena/punetazo_5.png"),
		load("res://assets/helena/punetazo_6.png"),
		load("res://assets/helena/punetazo_7.png"),
		load("res://assets/helena/punetazo_8.png"),
	]

	# Dos patadas nuevas: patada frontal/rodilla y patada baja. Se intercalan
	# con las existentes para que la rotación no muestre poses similares juntas.
	textura_patada = load("res://assets/helena/patada_1.png")
	texturas_patada_extra = [
		load("res://assets/helena/patada_4.png"),
		load("res://assets/helena/patada_2.png"),
		load("res://assets/helena/patada_5.png"),
		load("res://assets/helena/patada_3.png"),
	]

	textura_golpe_recibido = load("res://assets/helena/golpe_recibido.png")
	texturas_golpe_recibido_extra = [
		load("res://assets/helena/golpe_recibido_2.png"),
		load("res://assets/helena/golpe_recibido_3.png"),
		load("res://assets/helena/golpe_recibido_4.png"),
	]
	textura_derribado = load("res://assets/helena/derribado.png")
	textura_especial = load("res://assets/helena/especial.png")
	textura_rematador = load("res://assets/helena/rematador.png")
	textura_absoluto = load("res://assets/helena/absoluto.png")
	textura_recarga = load("res://assets/helena/recarga.png")
	textura_furia_parado = load("res://assets/helena/furia_parado.png")

	# 90.10.56 — CORE III/Furia ampliado a 8 golpes visuales: 4 puños + 4
	# patadas. fighter.gd ya alterna automáticamente puño/patada durante la
	# racha, y este orden además intercala los nuevos con los anteriores.
	textura_furia_punetazo = load("res://assets/helena/furia_punetazo_1.png")
	texturas_furia_punetazo_extra = [
		load("res://assets/helena/furia_punetazo_4.png"),
		load("res://assets/helena/furia_punetazo_2.png"),
		load("res://assets/helena/furia_punetazo_3.png"),
	]
	textura_furia_patada = load("res://assets/helena/furia_patada_1.png")
	texturas_furia_patada_extra = [
		load("res://assets/helena/furia_patada_3.png"),
		load("res://assets/helena/furia_patada_2.png"),
		load("res://assets/helena/furia_patada_4.png"),
	]
	textura_furia_golpe_recibido = load("res://assets/helena/furia_golpe_recibido.png")
	textura_furia_derribado = load("res://assets/helena/furia_derribado.png")

	# Caminata rediseñada: ciclo de 2 cuadros.
	textura_salto = load("res://assets/helena/salto.png")
	textura_doble_salto = load("res://assets/helena/doble_salto.png")
	textura_bloqueo = load("res://assets/helena/bloqueo.png")
	texturas_caminata = [
		load("res://assets/helena/caminata_1.png"),
		load("res://assets/helena/caminata_2.png"),
	]

	# Pose dedicada para carrera/doble toque.
	textura_carrera = load("res://assets/helena/carrera.png")

	# 91.02.44 — PASS 12A / PROTOTIPO PROYECTIL HELENA.
	proyectil_especial_habilitado = true
	textura_proyectil_pose = load("res://assets/helena/poder_proyectil.png")
	textura_proyectil_nucleo = load("res://assets/helena/proyectil_oficial.png")
	proyectil_pose_escala_mult = 1.06
	color_proyectil_primario = Color(1.0, 0.08, 0.64, 1.0)
	color_proyectil_secundario = Color(1.0, 0.82, 0.96, 1.0)
	# 91.02.47 — incremento leve aprobado: +5.9 % respecto de 760.
	proyectil_velocidad = 805.0
	proyectil_dano_mult = 0.86
	proyectil_empuje = 148.0
	proyectil_hitstun = 0.22
	proyectil_startup = 0.16
	proyectil_recovery = 0.30
	proyectil_cooldown = 0.62
	# 91.02.48 — impacto corto procesado desde el audio suministrado.
	sonido_proyectil_impacto = load("res://assets/helena/proyectil_impacto.wav")

func _procesar_entrada(_delta: float, vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(vel_actual)
		return
	_comportamiento_ia_basico(_delta, vel_actual, 90.0, 300.0)
	if poder >= poder_maximo:
		intentar_poder_especial()

func _ejecutar_especial() -> void:
	_efecto_estallido(Color(1.0, 0.6, 0.9, 0.9), 175.0, 32.0)

# 90.10.58 — FIX EXCLUSIVO HELENA / CORE I.
# El CORE I global ya conecta correctamente en los demás luchadores, pero en
# Helena el cuadro final se leía visualmente como continuación de la carrera.
# Esta secuencia conserva todo el comportamiento base (homing, daño, póster,
# congelado del rival), pero fuerza el DOBLE PUÑO nuevo como golpe claramente
# visible y deja un beat corto antes de que entre la gigantografía.
func _secuencia_poder_simple() -> void:
	if en_secuencia_especial:
		return
	en_secuencia_especial = true
	_bloquear_cinematica()
	_congelar_rival(true)
	await _acercar_para_especial()

	# Segundo golpe de la rotación normal = doble puño nuevo (punetazo_10).
	# Se muestra explícitamente para que el CORE I nunca parezca sólo un dash.
	var golpe_core1: Texture2D = null
	if not texturas_punetazo_extra.is_empty():
		golpe_core1 = texturas_punetazo_extra[0]
	elif textura_punetazo:
		golpe_core1 = textura_punetazo
	if golpe_core1 and sprite:
		_actualizar_textura(golpe_core1)
		pose_timer = 0.34

	_ejecutar_especial()
	if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		var dir_previa: float = signf(objetivo.global_position.x - global_position.x)
		if dir_previa == 0.0:
			dir_previa = mirando
		objetivo.preparar_impacto_cinematico(1.10, dir_previa, "especial")
		_aplicar_impacto_especial(2.6)

	# Beat visual corto: permite ver el puñetazo conectado antes del póster.
	await get_tree().create_timer(0.18, true, false, true).timeout
	await _mostrar_poder_reemplazando(textura_especial, 1.05, 320.0, false, 2.6)
	_congelar_rival(false)
	_desbloquear_cinematica()
	en_secuencia_especial = false
