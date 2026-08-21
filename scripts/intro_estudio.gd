extends Node2D

const SIGUIENTE_ESCENA := "res://scenes/IntroHistoria.tscn"
const TAMANO_PANTALLA := Vector2(1280.0, 720.0)
const ESCALA_INICIAL_RELATIVA := 0.10
const MARGEN_FINAL := 0.94
const FADE_IN_LOGO := 4.2
const PAUSA_FINAL := 0.65
const FADE_FINAL := 0.85
# FASE 94.3: la música no traía ningún fundido propio -- se escuchaba
# hasta la última muestra cruda del archivo y ahí cortaba en seco. Este es
# el fundido que le faltaba, calculado para terminar justo cuando el
# archivo llega a su fin natural (así no hace falta cortar el audio antes
# de tiempo, solo bajarle el volumen hasta que no se note el corte).
const FADE_AUDIO_FINAL := 1.8
const VOLUMEN_BASE := -7.5
const VOLUMEN_SILENCIO := -40.0

var logo: Sprite2D
var audio: AudioStreamPlayer
var fondo: ColorRect
var overlay_negro: ColorRect
var terminando := false
var escala_final := 1.0
var duracion_musica := 19.6

func _ready() -> void:
	fondo = ColorRect.new()
	fondo.color = Color("07182c")
	fondo.position = Vector2.ZERO
	fondo.size = TAMANO_PANTALLA
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.z_index = -2
	add_child(fondo)

	logo = Sprite2D.new()
	logo.texture = load("res://assets/branding/rrodass_estudio_intro.png")
	logo.centered = true
	logo.position = TAMANO_PANTALLA * 0.5
	logo.z_index = 1
	add_child(logo)

	var tex_size: Vector2 = logo.texture.get_size()
	# 89.1: FIT real. El logo nunca sobrepasa los 1280x720.
	# Se deja un 6% de aire alrededor para que quede perfectamente encuadrado.
	escala_final = min(TAMANO_PANTALLA.x / tex_size.x, TAMANO_PANTALLA.y / tex_size.y) * MARGEN_FINAL
	var escala_inicial := escala_final * ESCALA_INICIAL_RELATIVA
	logo.scale = Vector2.ONE * escala_inicial
	logo.modulate = Color(0.68, 0.75, 0.90, 0.0)

	overlay_negro = ColorRect.new()
	overlay_negro.color = Color(0.0, 0.0, 0.0, 0.0)
	overlay_negro.position = Vector2.ZERO
	overlay_negro.size = TAMANO_PANTALLA
	overlay_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_negro.z_index = 10
	add_child(overlay_negro)

	audio = AudioStreamPlayer.new()
	audio.stream = load("res://assets/sonidos/intro_estudio.mp3")
	audio.volume_db = VOLUMEN_BASE
	add_child(audio)

	if audio.stream:
		var largo := audio.stream.get_length()
		if largo > 1.0:
			duracion_musica = largo

	# Movimiento lineal y muy lento durante prácticamente toda la canción.
	# El último instante de la pista ya muestra el logo quieto y encuadrado.
	var duracion_zoom: float = maxf(duracion_musica - 0.55, 1.0)
	var tween_movimiento := create_tween()
	tween_movimiento.set_trans(Tween.TRANS_LINEAR)
	tween_movimiento.set_ease(Tween.EASE_IN_OUT)
	tween_movimiento.tween_property(logo, "scale", Vector2.ONE * escala_final, duracion_zoom)

	var tween_aparicion := create_tween()
	tween_aparicion.set_trans(Tween.TRANS_SINE)
	tween_aparicion.set_ease(Tween.EASE_OUT)
	tween_aparicion.tween_property(logo, "modulate", Color.WHITE, FADE_IN_LOGO)

	audio.finished.connect(_musica_terminada)
	audio.play()
	_iniciar_fundido_de_audio()

func _iniciar_fundido_de_audio() -> void:
	var espera: float = maxf(duracion_musica - FADE_AUDIO_FINAL, 0.1)
	await get_tree().create_timer(espera).timeout
	if terminando:
		return
	var tween_audio := create_tween()
	tween_audio.tween_property(audio, "volume_db", VOLUMEN_SILENCIO, FADE_AUDIO_FINAL)

func _musica_terminada() -> void:
	if terminando:
		return
	terminando = true
	# Fuerza el valor final exacto por seguridad frente a diferencias de duración
	# entre importación MP3/editor/exportación.
	logo.scale = Vector2.ONE * escala_final
	await get_tree().create_timer(PAUSA_FINAL).timeout
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(overlay_negro, "color:a", 1.0, FADE_FINAL)
	await tween.finished
	# FASE 94.2: IntroHistoria carga 8 imágenes grandes -- pasa por la
	# pantalla de carga en vez de cargarla directo, para no volver a la
	# espera "congelada" que arreglamos.
	var estado := get_node("/root/GameState")
	estado.escena_destino_carga = SIGUIENTE_ESCENA
	get_tree().change_scene_to_file("res://scenes/PantallaCarga.tscn")
