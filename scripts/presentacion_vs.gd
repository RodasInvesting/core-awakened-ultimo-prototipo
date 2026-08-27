extends Control

# 90.10.53 — VS CLASH SCREEN
# Las gigantografias oficiales apuntan hacia el centro: jugador normal a la
# izquierda, rival reflejado horizontalmente a la derecha.
const POSTERS := {
	"Kai": "gigantografias/kai.png",
	"Cibor-X": "gigantografias/cibor-x.png",
	"Fang": "gigantografias/fang.png",
	"Kali": "gigantografias/kali.png",
	"Aethel": "gigantografias/aethel.png",
	"Magnus": "gigantografias/magnus.png",
	"Helena": "gigantografias/helena.png",
	"Jester": "gigantografias/jester.png",
	"Xenoid": "gigantografias/xenoid.png",
	"Dax": "gigantografias/dax.png",
	# Varkhos queda con su VS anterior hasta completar su arte final.
	"Varkhos": "varkhos_vs.png"
}

const POSTER_FIT_SCALE := {
	"Kai": 1.16,
	"Cibor-X": 1.14,
	"Fang": 1.12,
	"Kali": 1.13,
	"Aethel": 1.12,
	"Magnus": 1.14,
	"Helena": 1.13,
	"Jester": 1.12,
	"Xenoid": 1.12,
	"Varkhos": 0.78
}

# X positivo significa acercar el foco/poder al centro. Para el rival se
# invierte automaticamente luego del flip horizontal.
const POSTER_OFFSET := {
	"Kai": Vector2(34.0, 0.0),
	"Cibor-X": Vector2(30.0, 0.0),
	"Fang": Vector2(34.0, 4.0),
	"Kali": Vector2(36.0, -2.0),
	"Aethel": Vector2(32.0, 0.0),
	"Magnus": Vector2(38.0, 0.0),
	"Helena": Vector2(36.0, 0.0),
	"Jester": Vector2(34.0, 0.0),
	"Xenoid": Vector2(32.0, 0.0),
	"Varkhos": Vector2.ZERO
}

func _ready() -> void:
	var estado = get_node("/root/GameState")
	crear_pantalla_vs(estado)
	crear_audio_y_transicion()

func crear_pantalla_vs(estado) -> void:
	var fondo := ColorRect.new()
	fondo.position = Vector2.ZERO
	fondo.size = Vector2(1280, 720)
	fondo.color = Color(0.006, 0.006, 0.014, 1.0)
	add_child(fondo)

	crear_panel_poster(estado.personaje_jugador, Rect2(0, 0, 640, 720), true)
	crear_panel_poster(estado.rival_actual, Rect2(640, 0, 640, 720), false)

	# Centro oscuro fino: deja que las dos energias lleguen visualmente hasta
	# el VS, pero mantiene legible el logo.
	var velo_centro := ColorRect.new()
	velo_centro.position = Vector2(566, 0)
	velo_centro.size = Vector2(148, 720)
	velo_centro.color = Color(0.0, 0.0, 0.0, 0.16)
	velo_centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(velo_centro)

	crear_choque_centro()
	crear_info_superior(estado)
	crear_vs_centro()
	crear_nombres(estado)

func crear_panel_poster(nombre: String, area: Rect2, es_jugador: bool) -> void:
	var cont := Panel.new()
	var entrada_x: float = -74.0 if es_jugador else 74.0
	cont.position = area.position + Vector2(entrada_x, 0.0)
	cont.size = area.size
	cont.clip_contents = true
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 1)
	cont.add_theme_stylebox_override("panel", style)
	add_child(cont)

	var archivo: String = str(POSTERS.get(nombre, "gigantografias/kai.png"))
	var tex: Texture2D = load("res://assets/vs/" + archivo)
	if tex == null:
		return

	# Fondo lleno, oscuro y ligeramente ampliado. Da continuidad visual a la
	# mitad de pantalla sin quitar protagonismo a la gigantografia frontal.
	var fondo_poster := TextureRect.new()
	fondo_poster.texture = tex
	fondo_poster.position = Vector2.ZERO
	fondo_poster.size = area.size
	fondo_poster.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fondo_poster.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fondo_poster.flip_h = not es_jugador
	fondo_poster.modulate = Color(0.66, 0.66, 0.72, 0.34)
	fondo_poster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cont.add_child(fondo_poster)

	# Gigantografia principal completa. La derecha se refleja para que el poder
	# apunte hacia el centro; la izquierda conserva la orientacion original.
	var poster := TextureRect.new()
	poster.texture = tex
	poster.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	poster.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	poster.flip_h = not es_jugador
	poster.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var base_scale: float = minf(area.size.x / float(tex.get_width()), area.size.y / float(tex.get_height()))
	var escala: float = base_scale * float(POSTER_FIT_SCALE.get(nombre, 1.12))
	poster.size = Vector2(float(tex.get_width()) * escala, float(tex.get_height()) * escala)
	var offset: Vector2 = POSTER_OFFSET.get(nombre, Vector2.ZERO)
	if not es_jugador:
		offset.x = -offset.x
	poster.position = Vector2((area.size.x - poster.size.x) * 0.5, (area.size.y - poster.size.y) * 0.5) + offset
	cont.add_child(poster)

	# Viñeta sutil para que el centro y los nombres sigan leyendo sobre artes
	# extremadamente luminosas.
	var velo := ColorRect.new()
	velo.position = Vector2.ZERO
	velo.size = area.size
	velo.color = Color(0, 0, 0, 0.08)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cont.add_child(velo)

	# Entrada simultanea desde los extremos hasta el choque central.
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(cont, "position", area.position, 0.42)

func crear_choque_centro() -> void:
	# Núcleo luminoso que representa el choque de las dos gigantografias.
	var impacto := Panel.new()
	impacto.position = Vector2(588, 292)
	impacto.size = Vector2(104, 104)
	impacto.pivot_offset = impacto.size * 0.5
	impacto.scale = Vector2(0.42, 0.42)
	impacto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var st := StyleBoxFlat.new()
	st.bg_color = Color(1.0, 0.96, 0.82, 0.34)
	st.border_color = Color(0.96, 0.58, 1.0, 0.90)
	st.set_border_width_all(5)
	st.corner_radius_top_left = 54
	st.corner_radius_top_right = 54
	st.corner_radius_bottom_left = 54
	st.corner_radius_bottom_right = 54
	st.shadow_color = Color(0.68, 0.24, 1.0, 0.72)
	st.shadow_size = 28
	impacto.add_theme_stylebox_override("panel", st)
	add_child(impacto)

	var t := create_tween()
	t.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(impacto, "scale", Vector2(1.24, 1.24), 0.36)
	t.tween_property(impacto, "scale", Vector2.ONE, 0.18)

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
	vs_shadow.add_theme_color_override("font_color", Color(0.04, 0.0, 0.06, 0.86))
	vs_shadow.add_theme_constant_override("outline_size", 12)
	vs_shadow.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.90))
	add_child(vs_shadow)

	var vs := Label.new()
	vs.text = "VS"
	vs.position = Vector2(480, 252)
	vs.size = Vector2(320, 140)
	vs.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vs.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vs.add_theme_font_size_override("font_size", 116)
	vs.add_theme_color_override("font_color", Color(1.0, 0.72, 0.18))
	vs.add_theme_constant_override("outline_size", 5)
	vs.add_theme_color_override("font_outline_color", Color(0.55, 0.10, 0.78, 0.96))
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
	var estado := get_node("/root/GameState")
	estado.escena_destino_carga = "res://scenes/Main.tscn"
	get_tree().change_scene_to_file("res://scenes/PantallaCarga.tscn")
