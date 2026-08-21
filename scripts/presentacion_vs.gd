extends Control

const POSTERS := {
	"Kai": "kai_vs.png",
	"Cibor-X": "cibor-x_vs.png",
	"Fang": "fang_vs.png",
	"Kali": "kali_vs.png",
	"Aethel": "aethel_vs.png",
	"Magnus": "magnus_vs.png",
	"Helena": "helena_vs.png",
	# WIP: todavía no hay un póster VS cinematográfico propio para Jester
	# (los otros son ilustraciones dedicadas más grandes). Por ahora usa
	# directamente su pose de inicio de batalla como resguardo.
	"Jester": "jester_vs.png",
	# Varkhos usa directamente su ilustración de Modo Furia como resguardo
	# -- no tiene un póster VS dedicado tampoco.
	"Varkhos": "varkhos_vs.png"
}

# Ajustes finos para que en el VS siempre se lea la CARA y el nombre.
# Ya no usamos solo "cover" porque algunas ilustraciones quedaban demasiado
# cerca y cortaban ojos/rostro. Ahora cada mitad tiene:
# 1) fondo cubierto y oscurecido para llenar limpio la pantalla
# 2) póster principal completo, centrado y con zoom controlado.
const POSTER_FIT_SCALE := {
	"Kai": 0.96,
	"Cibor-X": 0.94,
	"Fang": 0.93,
	"Kali": 0.84,
	"Aethel": 0.95,
	"Magnus": 0.88,
	"Helena": 0.94,
	"Jester": 0.80,
	"Varkhos": 0.78
}

const POSTER_OFFSET := {
	"Kai": Vector2(-10.0, 0.0),
	"Cibor-X": Vector2(0.0, 0.0),
	"Fang": Vector2(-8.0, 6.0),
	"Kali": Vector2(0.0, -4.0),
	"Aethel": Vector2(0.0, 0.0),
	"Magnus": Vector2(0.0, 0.0),
	"Helena": Vector2(-6.0, 0.0)
}

func _ready() -> void:
	var estado = get_node("/root/GameState")
	crear_pantalla_vs(estado)
	crear_audio_y_transicion()

func crear_pantalla_vs(estado) -> void:
	var fondo := ColorRect.new()
	fondo.position = Vector2.ZERO
	fondo.size = Vector2(1280, 720)
	fondo.color = Color(0.01, 0.01, 0.02, 1.0)
	add_child(fondo)

	crear_panel_poster(estado.personaje_jugador, Rect2(0, 0, 640, 720), true)
	crear_panel_poster(estado.rival_actual, Rect2(640, 0, 640, 720), false)

	var linea := ColorRect.new()
	linea.position = Vector2(637, 0)
	linea.size = Vector2(6, 720)
	linea.color = Color(1.0, 1.0, 1.0, 0.18)
	linea.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(linea)

	var velo_centro := ColorRect.new()
	velo_centro.position = Vector2(520, 0)
	velo_centro.size = Vector2(240, 720)
	velo_centro.color = Color(0.0, 0.0, 0.0, 0.22)
	velo_centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(velo_centro)

	crear_info_superior(estado)
	crear_vs_centro()
	crear_nombres(estado)

func crear_panel_poster(nombre: String, area: Rect2, es_jugador: bool) -> void:
	var cont := Panel.new()
	cont.position = area.position
	cont.size = area.size
	cont.clip_contents = true
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 1)
	cont.add_theme_stylebox_override("panel", style)
	add_child(cont)

	var archivo: String = str(POSTERS.get(nombre, "kai_vs.png"))
	var tex: Texture2D = load("res://assets/vs/" + archivo)
	if tex == null:
		return

	# Capa de relleno cinematográfica: cubre toda la mitad para que nunca
	# queden huecos, pero muy oscurecida para que no compita con el arte frontal.
	var fondo_poster := TextureRect.new()
	fondo_poster.texture = tex
	fondo_poster.position = Vector2.ZERO
	fondo_poster.size = area.size
	fondo_poster.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo_poster.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fondo_poster.flip_h = not es_jugador
	fondo_poster.modulate = Color(1, 1, 1, 0.26)
	fondo_poster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cont.add_child(fondo_poster)

	# Póster principal: se ajusta entero, centrado, con zoom fino por personaje.
	var poster := TextureRect.new()
	poster.texture = tex
	poster.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	poster.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	poster.flip_h = not es_jugador
	poster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var base_scale: float = minf(area.size.x / float(tex.get_width()), area.size.y / float(tex.get_height()))
	var escala: float = base_scale * float(POSTER_FIT_SCALE.get(nombre, 0.94))
	poster.size = Vector2(float(tex.get_width()) * escala, float(tex.get_height()) * escala)
	var offset: Vector2 = POSTER_OFFSET.get(nombre, Vector2.ZERO)
	poster.position = Vector2((area.size.x - poster.size.x) * 0.5, (area.size.y - poster.size.y) * 0.5) + offset
	cont.add_child(poster)

	var gradiente_lados := ColorRect.new()
	gradiente_lados.position = Vector2.ZERO
	gradiente_lados.size = area.size
	gradiente_lados.color = Color(0, 0, 0, 0.12)
	gradiente_lados.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cont.add_child(gradiente_lados)

	var borde := ColorRect.new()
	borde.position = Vector2(0, 0)
	borde.size = Vector2(area.size.x, 14)
	borde.color = Color(0.78, 0.32, 1.0, 0.30) if es_jugador else Color(1.0, 0.55, 0.12, 0.30)
	borde.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cont.add_child(borde)

func crear_info_superior(estado) -> void:
	var info_panel := Panel.new()
	info_panel.position = Vector2(390, 20)
	info_panel.size = Vector2(500, 48)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.03, 0.03, 0.05, 0.72)
	panel_style.border_color = Color(1, 1, 1, 0.18)
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 14
	panel_style.corner_radius_top_right = 14
	panel_style.corner_radius_bottom_left = 14
	panel_style.corner_radius_bottom_right = 14
	info_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(info_panel)

	var info := Label.new()
	if estado.modo == "arcade":
		info.text = "NEXT LEVEL  •  TORNEO %d DE %d" % [estado.arcade_indice + 1, estado.arcade_oponentes.size()]
	else:
		info.text = "NEXT LEVEL  •  BATALLA RÁPIDA"
	info.position = Vector2(405, 32)
	info.size = Vector2(470, 24)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 22)
	info.add_theme_color_override("font_color", Color.WHITE)
	add_child(info)

func crear_vs_centro() -> void:
	var vs_shadow := Label.new()
	vs_shadow.text = "VS"
	vs_shadow.position = Vector2(480, 262)
	vs_shadow.size = Vector2(320, 140)
	vs_shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vs_shadow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vs_shadow.add_theme_font_size_override("font_size", 116)
	vs_shadow.add_theme_color_override("font_color", Color(0.05, 0.0, 0.08, 0.72))
	add_child(vs_shadow)

	var vs := Label.new()
	vs.text = "VS"
	vs.position = Vector2(480, 252)
	vs.size = Vector2(320, 140)
	vs.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vs.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vs.add_theme_font_size_override("font_size", 116)
	vs.add_theme_color_override("font_color", Color(1.0, 0.65, 0.12))
	add_child(vs)

func crear_nombres(estado) -> void:
	crear_nombre_panel(estado.personaje_jugador.to_upper(), Rect2(42, 620, 420, 58), Color(0.72, 0.34, 1.0), true)
	crear_nombre_panel(estado.rival_actual.to_upper(), Rect2(818, 620, 420, 58), Color(1.0, 0.56, 0.10), false)

func crear_nombre_panel(texto: String, area: Rect2, color_borde: Color, izquierda: bool) -> void:
	var panel := Panel.new()
	panel.position = area.position
	panel.size = area.size
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.02, 0.04, 0.78)
	style.border_color = color_borde
	style.set_border_width_all(3)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var label := Label.new()
	label.text = texto
	label.position = area.position + Vector2(18, 10)
	label.size = Vector2(area.size.x - 36, 36)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color.WHITE)
	add_child(label)

	var tag := Label.new()
	tag.text = "JUGADOR 1" if izquierda else "RIVAL"
	tag.position = area.position + Vector2(20, -24)
	tag.size = Vector2(120, 20)
	tag.add_theme_font_size_override("font_size", 16)
	tag.add_theme_color_override("font_color", color_borde)
	add_child(tag)

func crear_audio_y_transicion() -> void:
	var sfx := AudioStreamPlayer.new()
	sfx.stream = load("res://assets/sonidos/menu/next_level.mp3")
	sfx.volume_db = -3.0
	add_child(sfx)
	sfx.play()
	await get_tree().create_timer(3.2).timeout
	# FASE 94.2: acá es donde más se sentía la espera -- Main.tscn carga
	# TODO el set de texturas de los dos personajes de la pelea. Pasa por
	# la pantalla de carga en vez de trabarse en seco.
	var estado := get_node("/root/GameState")
	estado.escena_destino_carga = "res://scenes/Main.tscn"
	get_tree().change_scene_to_file("res://scenes/PantallaCarga.tscn")
