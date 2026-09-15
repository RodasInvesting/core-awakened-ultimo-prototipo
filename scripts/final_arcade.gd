extends Control

# 91.05.19 — PASS 3C
# Ajuste solicitado:
# - imagen 1 (Varkhos derrotado) +3.0 segundos
# - imagen 2 (héroes alrededor) +3.0 segundos
# No modifica audios, ganador final ni navegación.
const DURACION_IMAGEN_1 := 6.4
const DURACION_IMAGEN_2 := 6.6
const DURACION_FADE := 0.35

const RUTA_IMAGEN_1 := "res://assets/final_arcade/secuencia/01_varkhos_derrotado.png"
const RUTA_IMAGEN_2 := "res://assets/final_arcade/secuencia/02_heroes_alrededor.png"
const RUTA_AUDIO_SECUENCIA := "res://assets/sonidos/cinematicas/varkhos_derrotado_secuencia.mp3"
const RUTA_AUDIO_GANADOR := "res://assets/sonidos/cinematicas/final_ganador_arcade.mp3"

const GANADORES := {
	"Helena": "res://assets/final_arcade/ganadores/helena.png",
	"Kai": "res://assets/final_arcade/ganadores/kai.png",
	"Fang": "res://assets/final_arcade/ganadores/fang.png",
	"Aethel": "res://assets/final_arcade/ganadores/aethel.png",
	"Xenoid": "res://assets/final_arcade/ganadores/xenoid.png",
	"Cibor-X": "res://assets/final_arcade/ganadores/cibor-x.png",
	"Dax": "res://assets/final_arcade/ganadores/dax.png",
	"Jester": "res://assets/final_arcade/ganadores/jester.png",
	"Kali": "res://assets/final_arcade/ganadores/kali.png",
	"Krovan": "res://assets/final_arcade/ganadores/krovan.png",
	"Magnus": "res://assets/final_arcade/ganadores/magnus.png",
	"Nekhar": "res://assets/final_arcade/ganadores/nekhar.png",
	"Virgilio": "res://assets/final_arcade/ganadores/virgilio.png"
}

var estado: Node
var imagen: TextureRect
var cortina: ColorRect
var barra_ayuda: ColorRect
var ayuda: Label
var audio: AudioStreamPlayer
var en_pantalla_final := false
var cerrando := false

func _ready() -> void:
	estado = get_node_or_null("/root/GameState")
	_crear_capas()
	call_deferred("_iniciar_secuencia")

func _crear_capas() -> void:
	var fondo := ColorRect.new()
	fondo.color = Color(0, 0, 0, 1)
	fondo.position = Vector2.ZERO
	fondo.size = Vector2(1280, 720)
	add_child(fondo)

	imagen = TextureRect.new()
	imagen.position = Vector2.ZERO
	imagen.size = Vector2(1280, 720)
	imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen.stretch_mode = TextureRect.STRETCH_SCALE
	imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(imagen)

	barra_ayuda = ColorRect.new()
	barra_ayuda.position = Vector2(0, 672)
	barra_ayuda.size = Vector2(1280, 48)
	barra_ayuda.color = Color(0, 0, 0, 0.42)
	barra_ayuda.visible = false
	barra_ayuda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(barra_ayuda)

	ayuda = Label.new()
	ayuda.text = "A / ENTER / ESC / CLICK  •  VOLVER AL MENÚ"
	ayuda.position = Vector2(260, 680)
	ayuda.size = Vector2(760, 28)
	ayuda.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ayuda.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ayuda.add_theme_font_size_override("font_size", 18)
	ayuda.add_theme_color_override("font_color", Color(1, 1, 1, 0.96))
	ayuda.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	ayuda.add_theme_constant_override("outline_size", 5)
	ayuda.visible = false
	ayuda.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ayuda)

	cortina = ColorRect.new()
	cortina.position = Vector2.ZERO
	cortina.size = Vector2(1280, 720)
	cortina.color = Color(0, 0, 0, 1)
	cortina.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cortina)

	audio = AudioStreamPlayer.new()
	audio.volume_db = -4.0
	add_child(audio)

func _iniciar_secuencia() -> void:
	_reproducir_audio(RUTA_AUDIO_SECUENCIA, -3.0)
	await _cambiar_imagen(RUTA_IMAGEN_1, true)
	await get_tree().create_timer(DURACION_IMAGEN_1).timeout
	if not is_inside_tree() or cerrando:
		return
	await _cambiar_imagen(RUTA_IMAGEN_2)
	await get_tree().create_timer(DURACION_IMAGEN_2).timeout
	if not is_inside_tree() or cerrando:
		return
	_reproducir_audio(RUTA_AUDIO_GANADOR, -4.0)
	await _cambiar_imagen(_ruta_ganador())
	en_pantalla_final = true
	barra_ayuda.visible = true
	ayuda.visible = true

func _ruta_ganador() -> String:
	var nombre := ""
	if estado != null:
		nombre = str(estado.ultimo_ganador)
		if nombre.is_empty():
			nombre = str(estado.personaje_jugador)
	if GANADORES.has(nombre):
		return str(GANADORES[nombre])
	if GANADORES.has("Helena"):
		return str(GANADORES["Helena"])
	return RUTA_IMAGEN_2

func _cargar_textura(ruta: String) -> Texture2D:
	if ruta.is_empty():
		return null
	if not ResourceLoader.exists(ruta):
		return null
	var recurso := load(ruta)
	return recurso as Texture2D

func _cambiar_imagen(ruta: String, primer_panel: bool = false) -> void:
	var textura := _cargar_textura(ruta)
	if textura == null:
		return
	if primer_panel and imagen.texture == null:
		imagen.texture = textura
		var tween_inicio := create_tween()
		tween_inicio.tween_property(cortina, "color", Color(0, 0, 0, 0), DURACION_FADE)
		await tween_inicio.finished
		return
	var tween_out := create_tween()
	tween_out.tween_property(cortina, "color", Color(0, 0, 0, 1), DURACION_FADE)
	await tween_out.finished
	imagen.texture = textura
	var tween_in := create_tween()
	tween_in.tween_property(cortina, "color", Color(0, 0, 0, 0), DURACION_FADE)
	await tween_in.finished

func _reproducir_audio(ruta: String, volumen_db: float) -> void:
	if audio == null:
		return
	audio.stop()
	if not ResourceLoader.exists(ruta):
		return
	audio.stream = load(ruta)
	audio.volume_db = volumen_db
	audio.play()

func _unhandled_input(event: InputEvent) -> void:
	if not en_pantalla_final or cerrando:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_volver_al_menu()
		return
	if event is InputEventMouseButton and event.pressed:
		_volver_al_menu()

func _volver_al_menu() -> void:
	if cerrando:
		return
	cerrando = true
	if estado != null and estado.has_method("volver_al_menu"):
		estado.volver_al_menu()
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
