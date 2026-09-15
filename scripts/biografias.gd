extends Control

const TAMANO := Vector2(1280.0, 720.0)
const ORDEN: Array[String] = [
	"Kai", "Cibor-X", "Fang", "Kali", "Aethel", "Magnus", "Helena",
	"Jester", "Xenoid", "Dax", "Krovan", "Nekhar", "Virgilio", "Varkhos"
]

const IMAGENES := {
	"Kai": "res://assets/biografias/kai.png",
	"Cibor-X": "res://assets/biografias/cibor-x.png",
	"Fang": "res://assets/biografias/fang.png",
	"Kali": "res://assets/biografias/kali.png",
	"Aethel": "res://assets/biografias/aethel.png",
	"Magnus": "res://assets/biografias/magnus.png",
	"Helena": "res://assets/biografias/helena.png",
	"Jester": "res://assets/biografias/jester.png",
	"Xenoid": "res://assets/biografias/xenoid.png",
	"Dax": "res://assets/biografias/dax.png",
	"Krovan": "res://assets/biografias/krovan.png",
	"Nekhar": "res://assets/biografias/nekhar.png",
	"Virgilio": "res://assets/biografias/virgilio.png",
	"Varkhos": "res://assets/biografias/varkhos.png",
}

const MUSICAS := {
	"Kai": "res://assets/sonidos/escenarios/kai_nuevo.mp3",
	"Cibor-X": "res://assets/sonidos/escenarios/cibor-x.mp3",
	"Fang": "res://assets/sonidos/escenarios/fang.mp3",
	"Kali": "res://assets/sonidos/escenarios/kali.mp3",
	"Aethel": "res://assets/sonidos/escenarios/aethel.mp3",
	"Magnus": "res://assets/sonidos/escenarios/magnus.mp3",
	"Helena": "res://assets/sonidos/escenarios/helena.mp3",
	"Jester": "res://assets/sonidos/escenarios/jester.wav",
	"Xenoid": "res://assets/sonidos/escenarios/xenoid.mp3",
	"Dax": "res://assets/sonidos/escenarios/dax.mp3",
	"Krovan": "res://assets/sonidos/escenarios/krovan.mp3",
	"Nekhar": "res://assets/sonidos/escenarios/nekhar.mp3",
	"Virgilio": "res://assets/sonidos/escenarios/virgilio_chaco_paraguayo.mp3",
	"Varkhos": "res://assets/sonidos/escenarios/varkhos.mp3",
}

# Mismos niveles ya calibrados en combate para cada pista.
const VOLUMENES := {
	"Kai": -11.0,
	"Cibor-X": -13.0,
	"Fang": -15.5,
	"Kali": 2.5,
	"Aethel": -6.5,
	"Magnus": -13.0,
	"Helena": -11.0,
	"Jester": -13.0,
	"Xenoid": -13.5,
	"Dax": -15.0,
	"Krovan": -10.0,
	"Nekhar": -8.5,
	"Virgilio": -2.5,
	"Varkhos": -14.0,
}

var indice: int = 0
var imagen: TextureRect
var nombre_label: Label
var ayuda: Label
var audio_a: AudioStreamPlayer
var audio_b: AudioStreamPlayer
var audio_activo: AudioStreamPlayer
var audio_entrante: AudioStreamPlayer
var tween_audio: Tween
var tween_imagen: Tween
var bloqueado: bool = false

func _ready() -> void:
	crear_interfaz()
	crear_audio()
	mostrar_actual(false)

func crear_interfaz() -> void:
	var fondo := ColorRect.new()
	fondo.color = Color.BLACK
	fondo.position = Vector2.ZERO
	fondo.size = TAMANO
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fondo)

	imagen = TextureRect.new()
	imagen.position = Vector2(0.0, 0.0)
	imagen.size = Vector2(1280.0, 676.0)
	imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(imagen)

	var banda := ColorRect.new()
	banda.position = Vector2(0.0, 676.0)
	banda.size = Vector2(1280.0, 44.0)
	banda.color = Color(0.0, 0.0, 0.0, 0.62)
	banda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(banda)

	nombre_label = Label.new()
	nombre_label.position = Vector2(32.0, 684.0)
	nombre_label.size = Vector2(360.0, 26.0)
	nombre_label.add_theme_font_size_override("font_size", 18)
	nombre_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(nombre_label)

	ayuda = Label.new()
	ayuda.text = "←  →  CAMBIAR BIOGRAFÍA     •     ESC / B  VOLVER"
	ayuda.position = Vector2(470.0, 684.0)
	ayuda.size = Vector2(770.0, 26.0)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ayuda.add_theme_font_size_override("font_size", 15)
	ayuda.add_theme_color_override("font_color", Color(0.95, 0.92, 1.0))
	add_child(ayuda)

func crear_audio() -> void:
	audio_a = AudioStreamPlayer.new()
	audio_b = AudioStreamPlayer.new()
	audio_a.pitch_scale = 1.0
	audio_b.pitch_scale = 1.0
	add_child(audio_a)
	add_child(audio_b)
	audio_a.finished.connect(func(): _reiniciar_musica_si_corresponde(audio_a))
	audio_b.finished.connect(func(): _reiniciar_musica_si_corresponde(audio_b))
	audio_activo = audio_a
	audio_entrante = audio_b


func _reiniciar_musica_si_corresponde(player: AudioStreamPlayer) -> void:
	if player == null:
		return
	if player != audio_activo:
		return
	if player.stream == null:
		return
	player.play(0.0)

func _unhandled_input(event: InputEvent) -> void:
	if bloqueado:
		return
	if event.is_action_pressed("ui_left"):
		cambiar(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		cambiar(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		volver_menu()
		get_viewport().set_input_as_handled()

func cambiar(delta: int) -> void:
	indice = wrapi(indice + delta, 0, ORDEN.size())
	var estado := get_node_or_null("/root/GameState")
	if estado and estado.has_method("reproducir_navegacion_ui"):
		estado.reproducir_navegacion_ui()
	mostrar_actual(true)

func mostrar_actual(animar: bool) -> void:
	var personaje := ORDEN[indice]
	nombre_label.text = "%02d / %02d   %s" % [indice + 1, ORDEN.size(), personaje.to_upper()]
	var tex := load(str(IMAGENES[personaje])) as Texture2D
	if animar:
		if tween_imagen and tween_imagen.is_running():
			tween_imagen.kill()
		tween_imagen = create_tween()
		tween_imagen.tween_property(imagen, "modulate:a", 0.0, 0.10)
		tween_imagen.tween_callback(func(): imagen.texture = tex)
		tween_imagen.tween_property(imagen, "modulate:a", 1.0, 0.16)
	else:
		imagen.texture = tex
		imagen.modulate.a = 1.0
	cambiar_musica(personaje, animar)

func cambiar_musica(personaje: String, usar_crossfade: bool) -> void:
	var nueva := load(str(MUSICAS[personaje])) as AudioStream
	if nueva == null:
		return
	var volumen_objetivo: float = float(VOLUMENES.get(personaje, -10.0))

	if not usar_crossfade or not audio_activo.playing:
		audio_activo.stop()
		audio_activo.stream = nueva
		audio_activo.pitch_scale = 1.0
		audio_activo.volume_db = volumen_objetivo
		audio_activo.play()
		return

	if tween_audio and tween_audio.is_running():
		tween_audio.kill()

	audio_entrante.stop()
	audio_entrante.stream = nueva
	audio_entrante.pitch_scale = 1.0
	audio_entrante.volume_db = -40.0
	audio_entrante.play()

	tween_audio = create_tween()
	tween_audio.set_parallel(true)
	tween_audio.tween_property(audio_activo, "volume_db", -40.0, 0.35)
	tween_audio.tween_property(audio_entrante, "volume_db", volumen_objetivo, 0.35)
	var viejo := audio_activo
	tween_audio.set_parallel(false)
	tween_audio.tween_callback(func(): viejo.stop())
	var tmp := audio_activo
	audio_activo = audio_entrante
	audio_entrante = tmp

func volver_menu() -> void:
	if bloqueado:
		return
	bloqueado = true
	if tween_audio and tween_audio.is_running():
		tween_audio.kill()
	var t := create_tween()
	if audio_activo and audio_activo.playing:
		t.tween_property(audio_activo, "volume_db", -40.0, 0.18)
	await t.finished
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
