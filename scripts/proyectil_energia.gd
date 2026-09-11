extends Node2D
# CORE AWAKENED 91.02.44 — PASS 12A / PROYECTIL DE ENERGÍA.

var atacante: Node
var objetivo: Node
var direccion := 1.0
var velocidad := 720.0
var dano := 3.0
var empuje := 148.0
var hitstun := 0.22
var color_primario := Color(1.0, 0.1, 0.7, 1.0)
var color_secundario := Color(1.0, 0.85, 0.98, 1.0)
var textura_nucleo: Texture2D
var sonido_impacto: AudioStream
var sprite_nucleo: Sprite2D

var vida_restante := 1.85

# 91.02.45 — PASS 12B / CALIBRACIÓN VISUAL.
# El video 12A confirmó que el proyectil funciona, pero se percibe chico.
# Separamos radio visual y radio de impacto para agrandarlo SIN cambiar balance.
# 91.02.46 — PASS 12C / EVASIÓN AÉREA.
# Conservamos el ancho de contacto, pero afinamos la altura para que a larga
# distancia un salto/doble salto limpio pueda pasar por encima del proyectil.
var radio_hitbox_x := 27.0
var radio_hitbox_y := 15.0
var radio_visual := 42.0
var pulso := 0.0
var terminado := false


func configurar(
	p_atacante: Node,
	p_objetivo: Node,
	p_direccion: float,
	p_velocidad: float,
	p_dano: float,
	p_empuje: float,
	p_hitstun: float,
	p_color_primario: Color,
	p_color_secundario: Color,
	p_textura_nucleo: Texture2D = null,
	p_sonido_impacto: AudioStream = null
) -> void:
	atacante = p_atacante
	objetivo = p_objetivo
	direccion = signf(p_direccion)
	if direccion == 0.0:
		direccion = 1.0
	velocidad = p_velocidad
	dano = p_dano
	empuje = p_empuje
	hitstun = p_hitstun
	color_primario = p_color_primario
	color_secundario = p_color_secundario
	textura_nucleo = p_textura_nucleo
	sonido_impacto = p_sonido_impacto
	z_index = 45

	if textura_nucleo:
		sprite_nucleo = Sprite2D.new()
		sprite_nucleo.texture = textura_nucleo
		sprite_nucleo.centered = true
		sprite_nucleo.z_index = 1
		add_child(sprite_nucleo)

		# 91.02.49 — el video 91.02.48 confirma que el diseño funciona,
		# pero el dragón del PNG todavía se lee algo chico. Aumentamos sólo
		# el núcleo visual; la hitbox permanece exactamente igual.
		var tam := textura_nucleo.get_size()
		if tam.y > 0.0:
			var escala := 124.0 / tam.y
			sprite_nucleo.scale = Vector2(escala, escala)
			sprite_nucleo.flip_h = direccion < 0.0



func _ready() -> void:
	# 91.02.49 — el sonido pertenece a la SALIDA del poder, no al impacto.
	# _ready corre justo después de que Fighter agrega el proyectil a la escena.
	_reproducir_sonido_salida()


func _physics_process(delta: float) -> void:
	if terminado:
		return
	vida_restante -= delta
	pulso += delta * 13.0

	if vida_restante <= 0.0:
		_terminar()
		return
	if not is_instance_valid(atacante) or not is_instance_valid(objetivo):
		_terminar()
		return
	if bool(objetivo.get("esta_derrotado")):
		_terminar()
		return

	global_position.x += direccion * velocidad * delta
	queue_redraw()

	if global_position.x < -140.0 or global_position.x > 1420.0:
		_terminar()
		return

	if _intersecta_objetivo():
		_impactar()


func _intersecta_objetivo() -> bool:
	if not is_instance_valid(atacante) or not is_instance_valid(objetivo):
		return false

	if atacante.has_method("_obtener_hurtbox_global"):
		var hurt_var = atacante.call("_obtener_hurtbox_global", objetivo)
		if hurt_var is Rect2:
			var caja := Rect2(
				global_position - Vector2(radio_hitbox_x, radio_hitbox_y),
				Vector2(radio_hitbox_x * 2.0, radio_hitbox_y * 2.0)
			)
			return caja.intersects(hurt_var)

	var dx: float = absf(objetivo.global_position.x - global_position.x)
	var dy: float = absf((objetivo.global_position.y - 125.0) - global_position.y)
	return dx <= 54.0 and dy <= 110.0


func _impactar() -> void:
	if terminado or not is_instance_valid(objetivo):
		return
	terminado = true

	var bloqueado: bool = bool(objetivo.get("bloqueando"))
	if objetivo.has_method("recibir_dano"):
		objetivo.call("recibir_dano", dano, empuje, hitstun, direccion, "especial")

	# 91.02.57 — sólo el impacto LIMPIO alimenta CORE.
	# Bloqueado = cero carga, como decisión de balance final.
	if not bloqueado and is_instance_valid(atacante):
		if atacante.has_method("_registrar_proyectil_conectado"):
			atacante.call("_registrar_proyectil_conectado")

	if is_instance_valid(atacante):
		if atacante.has_method("_efecto_chispas"):
			atacante.call("_efecto_chispas", bloqueado, global_position, 1.08)
		if atacante.has_method("_onda_impacto_local"):
			atacante.call("_onda_impacto_local", global_position, color_primario, 0.82)
		var hs = atacante.get("hitstop_timer")
		if hs != null:
			atacante.set("hitstop_timer", maxf(float(hs), 0.030))

	_terminar()



func _reproducir_sonido_salida() -> void:
	if not sonido_impacto:
		return
	var escena := get_tree().current_scene
	if not escena:
		return

	# Reproductor independiente para que el sonido no se corte cuando el
	# proyectil se destruye inmediatamente después del impacto.
	var reproductor := AudioStreamPlayer.new()
	reproductor.stream = sonido_impacto
	reproductor.volume_db = -4.5
	escena.add_child(reproductor)
	reproductor.finished.connect(reproductor.queue_free)
	reproductor.play()


func _draw() -> void:
	var atras := -direccion
	var brillo: float = 1.0 + sin(pulso) * 0.08

	var cola := PackedVector2Array([
		Vector2(atras * 102.0, -14.0),
		Vector2(atras * 34.0, -31.0),
		Vector2(18.0 * direccion, 0.0),
		Vector2(atras * 34.0, 31.0),
		Vector2(atras * 102.0, 14.0),
	])
	draw_colored_polygon(cola, Color(color_primario.r, color_primario.g, color_primario.b, 0.34))

	# El PNG oficial es el núcleo. El código sólo suma aura/anillos dinámicos.
	draw_circle(Vector2.ZERO, radio_visual * 1.68 * brillo, Color(color_primario.r, color_primario.g, color_primario.b, 0.16))
	draw_circle(Vector2.ZERO, radio_visual * 1.26 * brillo, Color(color_primario.r, color_primario.g, color_primario.b, 0.23))

	draw_arc(Vector2.ZERO, radio_visual * 1.10, -1.0 + pulso * 0.05, 2.2 + pulso * 0.05, 30, color_secundario, 4.0)
	draw_arc(Vector2.ZERO, radio_visual * 1.40, 2.0 - pulso * 0.04, 5.2 - pulso * 0.04, 30, Color(color_primario.r, color_primario.g, color_primario.b, 0.53), 3.0)


func _terminar() -> void:
	if is_instance_valid(atacante) and atacante.has_method("_notificar_proyectil_terminado"):
		atacante.call("_notificar_proyectil_terminado", self)
	if not is_queued_for_deletion():
		queue_free()
