extends Node2D

# FASE 93: secuencia narrativa "el origen del Core", entre el logo del
# estudio y el menú principal. 8 láminas ya armadas (arte + texto + marco,
# todo en el PNG) que se muestran una por vez con fundido cruzado, sobre
# el tema musical que definió su duración total. Se puede saltar en
# cualquier momento con cualquier tecla, click o toque.
const SIGUIENTE_ESCENA := "res://scenes/MenuPrincipal.tscn"
const TAMANO_PANTALLA := Vector2(1280.0, 720.0)
const FADE := 0.7
const RETRASO_ANTES_DE_PODER_SALTAR := 0.3
const FADE_SALIDA := 0.5

# Tiempo que queda cada lámina en pantalla (incluye su propio fundido de
# entrada). Calibrado contra la duración real del tema (33.7s), estirada
# un ~8.7% porque el audio corre a pitch_scale 0.92 (ver más abajo): la
# música se escucha casi igual pero dura más, y las láminas la acompañan
# sin sentirse apuradas.
const DURACIONES: Array[float] = [4.3, 3.9, 4.1, 4.9, 2.4, 5.2, 5.8, 6.0]

var laminas: Array[Sprite2D] = []
var overlay_negro: ColorRect
var audio: AudioStreamPlayer
var saltando := false
var puede_saltar := false

func _ready() -> void:
	var fondo := ColorRect.new()
	fondo.color = Color.BLACK
	fondo.position = Vector2.ZERO
	fondo.size = TAMANO_PANTALLA
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.z_index = -2
	add_child(fondo)

	for i in range(1, 9):
		var spr := Sprite2D.new()
		spr.texture = load("res://assets/historia/slide_%d.png" % i)
		spr.centered = true
		spr.position = TAMANO_PANTALLA * 0.5
		var tex_size: Vector2 = spr.texture.get_size()
		# "Cover": llena toda la pantalla sin dejar bordes, aunque recorte
		# un pelo de sobra a los costados -- el aspecto ya es casi idéntico
		# (1672x941 vs 1280x720) así que el recorte es mínimo.
		var escala: float = maxf(TAMANO_PANTALLA.x / tex_size.x, TAMANO_PANTALLA.y / tex_size.y)
		spr.scale = Vector2.ONE * escala
		spr.modulate = Color(1.0, 1.0, 1.0, 0.0)
		spr.z_index = 0
		add_child(spr)
		laminas.append(spr)

	overlay_negro = ColorRect.new()
	overlay_negro.color = Color(0.0, 0.0, 0.0, 0.0)
	overlay_negro.position = Vector2.ZERO
	overlay_negro.size = TAMANO_PANTALLA
	overlay_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_negro.z_index = 10
	add_child(overlay_negro)

	var ayuda := Label.new()
	ayuda.text = "Toca o presioná cualquier tecla para saltar"
	ayuda.position = Vector2(0.0, 688.0)
	ayuda.size = Vector2(TAMANO_PANTALLA.x, 26.0)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.add_theme_font_size_override("font_size", 14)
	ayuda.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.35))
	ayuda.z_index = 11
	ayuda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ayuda)

	audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/sonidos/historia_intro.mp3")
	audio.volume_db = -4.0
	# FASE 94.1: 8% más lento (baja el tono un poco menos de 1.5 semitonos,
	# casi imperceptible en un tema instrumental/cinemático) para darle más
	# aire a cada lámina sin que la música se sienta "arrastrada".
	audio.pitch_scale = 0.92
	add_child(audio)
	audio.play()

	await get_tree().create_timer(RETRASO_ANTES_DE_PODER_SALTAR).timeout
	puede_saltar = true
	_reproducir_secuencia()

func _reproducir_secuencia() -> void:
	for i in range(laminas.size()):
		if saltando:
			return
		var spr: Sprite2D = laminas[i]
		spr.z_index = 1
		var tween_in := create_tween()
		tween_in.tween_property(spr, "modulate:a", 1.0, FADE)
		await tween_in.finished
		if saltando:
			return
		var espera: float = maxf(DURACIONES[i] - FADE * 2.0, 0.3)
		await get_tree().create_timer(espera).timeout
		if saltando:
			return
		if i < laminas.size() - 1:
			var tween_out := create_tween()
			tween_out.tween_property(spr, "modulate:a", 0.0, FADE)
			await tween_out.finished
			spr.z_index = 0
	if not saltando:
		_ir_al_menu()

func _unhandled_input(event: InputEvent) -> void:
	if not puede_saltar or saltando:
		return
	var es_toque := false
	if event is InputEventKey:
		es_toque = (event as InputEventKey).pressed
	elif event is InputEventMouseButton:
		es_toque = (event as InputEventMouseButton).pressed
	elif event is InputEventScreenTouch:
		es_toque = (event as InputEventScreenTouch).pressed
	if es_toque:
		_saltar()

func _saltar() -> void:
	if saltando:
		return
	saltando = true
	_ir_al_menu()

func _ir_al_menu() -> void:
	var tw_audio := create_tween()
	tw_audio.tween_property(audio, "volume_db", -40.0, FADE_SALIDA)
	var tw_negro := create_tween()
	tw_negro.set_trans(Tween.TRANS_SINE)
	tw_negro.tween_property(overlay_negro, "color:a", 1.0, FADE_SALIDA)
	await tw_negro.finished
	get_tree().change_scene_to_file(SIGUIENTE_ESCENA)
