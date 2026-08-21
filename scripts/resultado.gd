extends Control

const FONDOS := {
	"Kai":"kai.jpg", "Cibor-X":"cibor-x.jpg", "Fang":"fang.jpg", "Kali":"kali.jpg",
	"Aethel":"aethel.jpg", "Magnus":"magnus.jpg", "Helena":"helena.jpg"
}
var estado

func _ready() -> void:
	estado = get_node("/root/GameState")
	crear_fondo(estado.ultimo_rival if estado.ultimo_rival != "" else estado.rival_actual)
	match estado.ultimo_resultado:
		"siguiente": await mostrar_siguiente()
		"campeon": mostrar_campeon()
		"derrota": mostrar_derrota()
		"victoria": mostrar_victoria_rapida()
		_: mostrar_victoria_rapida()

func crear_fondo(nombre: String) -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/fondos/" + str(FONDOS.get(nombre, "kai.jpg")))
	bg.position = Vector2.ZERO
	bg.size = Vector2(1280,720)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.modulate = Color(0.40,0.40,0.44,1.0)
	add_child(bg)
	var oscuro := ColorRect.new()
	oscuro.position = Vector2.ZERO
	oscuro.size = Vector2(1280,720)
	oscuro.color = Color(0,0,0,0.62)
	add_child(oscuro)

func etiqueta(texto: String, y: float, tam: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = texto
	l.position = Vector2(190,y)
	l.size = Vector2(900,90)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	add_child(l)
	return l

func boton(texto: String, pos: Vector2, accion: Callable) -> Button:
	var b := Button.new()
	b.text = texto
	b.position = pos
	b.size = Vector2(280,58)
	b.add_theme_font_size_override("font_size", 20)
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.03,0.025,0.07,0.94)
	s.border_color = Color(0.85,0.45,0.12)
	s.set_border_width_all(2)
	s.corner_radius_top_left = 8
	s.corner_radius_top_right = 8
	s.corner_radius_bottom_left = 8
	s.corner_radius_bottom_right = 8
	b.add_theme_stylebox_override("normal", s)
	var h := s.duplicate()
	h.border_color = Color(0.72,0.28,1.0)
	h.set_border_width_all(3)
	b.add_theme_stylebox_override("hover", h)
	b.add_theme_stylebox_override("focus", h)
	b.pressed.connect(accion)
	add_child(b)
	return b

func reproducir(ruta: String, vol: float = -3.0) -> void:
	var a := AudioStreamPlayer.new()
	a.stream = load(ruta)
	a.volume_db = vol
	add_child(a)
	a.play()

func mostrar_siguiente() -> void:
	etiqueta("¡VICTORIA!", 170, 64, Color(1.0,0.58,0.10))
	etiqueta("RIVAL SUPERADO: " + estado.ultimo_rival.to_upper(), 265, 24)
	etiqueta("PROGRESO DEL TORNEO  " + estado.progreso_arcade_texto(), 315, 22, Color(0.80,0.62,1.0))
	if estado.rival_actual == "Varkhos":
		etiqueta("EL NÚCLEO DESPIERTA...", 385, 36, Color(0.95,0.15,0.20))
	else:
		etiqueta("SIGUIENTE: " + estado.rival_actual.to_upper(), 385, 34, Color(0.45,0.86,1.0))
	reproducir("res://assets/sonidos/menu/next_level.mp3")
	await get_tree().create_timer(3.2).timeout
	get_tree().change_scene_to_file("res://scenes/PresentacionVS.tscn")

func mostrar_campeon() -> void:
	etiqueta("¡CAMPEÓN!", 150, 72, Color(1.0,0.62,0.08))
	etiqueta(estado.personaje_jugador.to_upper(), 245, 42, Color(0.84,0.62,1.0))
	etiqueta("HAS DERROTADO A TODOS LOS GUERREROS", 325, 26)
	etiqueta("TORNEO CORE AWAKENED COMPLETADO", 375, 22, Color(0.50,0.88,1.0))
	var b := boton("VOLVER AL MENÚ", Vector2(500,520), _menu)
	b.grab_focus()

func mostrar_derrota() -> void:
	etiqueta("HAS SIDO DERROTADO", 170, 56, Color(1.0,0.24,0.18))
	if estado.modo == "arcade":
		etiqueta("TORNEO TERMINADO — PROGRESO " + estado.progreso_arcade_texto(), 285, 24)
	else:
		etiqueta("BATALLA FINALIZADA", 285, 24)
	var b1 := boton("REINTENTAR", Vector2(340,470), _reintentar)
	boton("VOLVER AL MENÚ", Vector2(660,470), _menu)
	b1.grab_focus()

func mostrar_victoria_rapida() -> void:
	etiqueta("¡VICTORIA!", 180, 70, Color(1.0,0.58,0.10))
	etiqueta(estado.personaje_jugador.to_upper() + " GANA LA BATALLA", 290, 30)
	var b1 := boton("REVANCHA", Vector2(340,470), _reintentar)
	boton("SELECCIÓN", Vector2(660,470), _selector)
	boton("MENÚ PRINCIPAL", Vector2(500,555), _menu)
	b1.grab_focus()

func _reintentar() -> void:
	estado.reiniciar_combate_actual()
	get_tree().change_scene_to_file("res://scenes/PresentacionVS.tscn")

func _selector() -> void:
	get_tree().change_scene_to_file("res://scenes/SelectorPersonajes.tscn")

func _menu() -> void:
	estado.volver_al_menu()
	get_tree().change_scene_to_file("res://scenes/MenuPrincipal.tscn")
