extends Node2D

const ANCHO_ARENA := 1280.0
const SUELO_Y := 560.0
const ANCHO_BARRA := 300.0
const PODER_MAXIMO := 100.0
const RONDAS_PARA_GANAR := 2
const POS_KAI := Vector2(400, 560)
const POS_RIVAL := Vector2(880, 560)

var kai: Fighter
var rival: Fighter
var barra_poder_kai: ColorRect
var barra_poder_rival: ColorRect
var etiqueta_combo: Label
var etiqueta_poder_listo: Label
var etiqueta_cargas_kai: Label
var etiqueta_cargas_rival: Label
var cores_kai: Array[ColorRect] = []
var cores_rival: Array[ColorRect] = []
var etiqueta_rival: Label
var etiqueta_jugador: Label
var fondo_rival: ColorRect

var camara: Camera2D
var shake_tiempo := 0.0
var shake_fuerza := 0.0
var shake_intervalo := 0.05
var shake_reloj := 0.0
var congelando_ko := false
var fondo_sprite: Sprite2D
var fondo_material: ShaderMaterial
var destello_rect: ColorRect
var destello_material: ShaderMaterial
var destello_tween: Tween
var vineta_rect: ColorRect
var vineta_material: ShaderMaterial
var ambiente_particulas: Node2D
var ambiente_particulas_delante: Node2D
var camara_cinematica_activa := false
var foco_camara_suave := Vector2.ZERO
var pulso_cam_combate := 0.0
# FASE 75 — cámara de impacto: pequeño "punch in" al punto de contacto,
# sin interferir con los zooms cinematográficos de recarga/Absoluto.
var foco_impacto_camara_x: float = 0.0
var foco_impacto_timer: float = 0.0
var tween_camara_cinematica: Tween

# --- FASE 44: escenario vivo / profundidad ---
var escenario_vivo: Node2D
var escenario_far: Node2D
var escenario_mid: Node2D
var escenario_front: Node2D
var escenario_effect_color := Color(1.0, 1.0, 1.0)
var escenario_tipo := "neutral"
var escenario_pulso := 0.0
var escenario_tiempo := 0.0
var piso_overlay: Node2D
var luz_impacto: PointLight2D
var luz_escenario: DirectionalLight2D
var piso_luz_ambiente: Polygon2D

# --- FASE 73: integración luchador-escenario ---
var iluminacion_luchadores: Node2D
var halo_luchador_kai: Polygon2D
var halo_luchador_rival: Polygon2D
var escenario_flash_energia: float = 0.0
var escenario_impulso_aire_x: float = 0.0
var escenario_impulso_aire_objetivo: float = 0.0
# --- FASE 87: escenarios vivos y reactivos ---
var escenario_nombre_actual := "Kai"
var escenario_ambiente_reloj: float = 0.0
var escenario_ambiente_intervalo: float = 1.5
var escenario_energia_reactiva: float = 0.0
var helena_ojos: Array[Polygon2D] = []
var helena_aura_cabeza: Polygon2D
var cibor_reactor_halo: Polygon2D
var seleccion_jugador_label: Label

const AMBIENTE_COLORES := {
	"Kai": Color(0.55, 0.30, 1.0),
	"Fang": Color(1.0, 0.35, 0.08),
	"Cibor-X": Color(0.15, 0.65, 1.0),
	"Kali": Color(0.35, 1.0, 0.20),
	"Aethel": Color(0.45, 0.85, 1.0),
	"Magnus": Color(1.0, 0.55, 0.15),
	"Helena": Color(1.0, 0.25, 0.80),
	# Jester todavía no tiene fondo propio en FONDOS -- este color queda
	# listo para cuando se sume assets/fondos/jester.jpg.
	"Jester": Color(0.85, 0.25, 0.85),
	# Ídem Varkhos -- listo para cuando exista assets/fondos/varkhos.jpg
	# (el arena del jefe final, probablemente el propio Núcleo).
	"Varkhos": Color(0.85, 0.08, 0.16),
}

const FONDOS := {
	"Kai": "res://assets/fondos/kai.jpg",
	"Fang": "res://assets/fondos/fang.jpg",
	"Cibor-X": "res://assets/fondos/cibor-x.jpg",
	"Kali": "res://assets/fondos/kali.jpg",
	"Aethel": "res://assets/fondos/aethel.jpg",
	"Magnus": "res://assets/fondos/magnus.jpg",
	"Helena": "res://assets/fondos/helena.jpg",
}

const SND_GOLPE := preload("res://assets/sonidos/golpe.wav")
const SND_ESPECIAL := preload("res://assets/sonidos/especial.wav")
const SND_KO := preload("res://assets/sonidos/ko.wav")
const SND_VICTORIA := preload("res://assets/sonidos/cinematicas/finaliza_pelea.mp3")
const SND_PODER_FINAL_NUEVO := preload("res://assets/sonidos/cinematicas/poder_final.mp3")
const SND_READY_FIGHT_NUEVO := preload("res://assets/sonidos/cinematicas/ready_fight.mp3")
const SND_SALTO := preload("res://assets/sonidos/salto.wav")

# --- FASE 86: banco de impacto premium ---
const SND_PUNO_1 := preload("res://assets/sonidos/punetazo_1.wav")
const SND_PUNO_2 := preload("res://assets/sonidos/punetazo_2.wav")
const SND_PUNO_FUERTE := preload("res://assets/sonidos/punetazo_fuerte.wav")
const SND_PATADA_1 := preload("res://assets/sonidos/patada_1.wav")
const SND_PATADA_2 := preload("res://assets/sonidos/patada_2.wav")
const SND_BLOQUEO := preload("res://assets/sonidos/bloqueo_impacto.wav")
const SND_WHOOSH_PUNO := preload("res://assets/sonidos/whoosh_puno.wav")
const SND_WHOOSH_PATADA := preload("res://assets/sonidos/whoosh_patada.wav")
const SND_ATERRIZAJE := preload("res://assets/sonidos/aterrizaje.wav")
const SND_CAIDA_FUERTE := preload("res://assets/sonidos/caida_fuerte.wav")
const SND_CORE_CARGA := preload("res://assets/sonidos/core_carga.wav")
const SND_CORE_CARGA_ABSOLUTA := preload("res://assets/sonidos/core_carga_absoluta.wav")
const SND_CORE_LISTO := preload("res://assets/sonidos/core_listo.wav")
const SND_REMATADOR_IMPACTO := preload("res://assets/sonidos/rematador_impacto.wav")
const SND_ABSOLUTO_IMPACTO := preload("res://assets/sonidos/absoluto_impacto.wav")
const SND_KAI_OSCURO := preload("res://assets/sonidos/kai_oscuro.wav")
const SND_HELENA_LUZ := preload("res://assets/sonidos/helena_luz.wav")
const SND_FANG_FUEGO := preload("res://assets/sonidos/fang_fuego.wav")
const SND_CIBOR_ELECTRICO := preload("res://assets/sonidos/cibor_electrico.wav")
const SND_KALI_ACIDO := preload("res://assets/sonidos/kali_acido.wav")
const SND_AETHEL_VIENTO := preload("res://assets/sonidos/aethel_viento.wav")
const SND_MAGNUS_PIEDRA := preload("res://assets/sonidos/magnus_piedra.wav")

# --- FASE 86.1: impactos reales aportados por el creador ---
const SND_REAL_PUNO_CRUNCH_A := preload("res://assets/sonidos/impactos_reales/puno_crunch_a.wav")
const SND_REAL_PUNO_CRUNCH_B := preload("res://assets/sonidos/impactos_reales/puno_crunch_b.wav")
const SND_REAL_PUNO_SECO_A := preload("res://assets/sonidos/impactos_reales/puno_seco_a.wav")
const SND_REAL_IMPACTO_MIXTO_A := preload("res://assets/sonidos/impactos_reales/impacto_mixto_a.wav")
const SND_REAL_IMPACTO_MIXTO_B := preload("res://assets/sonidos/impactos_reales/impacto_mixto_b.wav")
const SND_REAL_PATADA_A := preload("res://assets/sonidos/impactos_reales/patada_real_a.wav")
const SND_REAL_PATADA_B := preload("res://assets/sonidos/impactos_reales/patada_real_b.wav")
const SND_REAL_BLOQUEO_A := preload("res://assets/sonidos/impactos_reales/bloqueo_real_a.wav")

# --- FASE 86.2: segundo banco real + reacciones vocales ---
const SND_REAL_PATADA_CORTA := preload("res://assets/sonidos/impactos_reales2/patada_corta.wav")
const SND_REAL_PUNO_SORDO_PESADO := preload("res://assets/sonidos/impactos_reales2/puno_sordo_pesado.wav")
const SND_VOZ_REACCION_HOMBRE := preload("res://assets/sonidos/voces_reales/reaccion_golpe_hombre.wav")
const SND_VOZ_GRITO_ATAQUE_1 := preload("res://assets/sonidos/voces_reales/grito_ataque_1.wav")
const SND_VOZ_GRITO_ATAQUE_2 := preload("res://assets/sonidos/voces_reales/grito_ataque_2.wav")
const SND_VOZ_GRITO_ATAQUE_3 := preload("res://assets/sonidos/voces_reales/grito_ataque_3.wav")
const SND_VOZ_DOLOR_1 := preload("res://assets/sonidos/voces_reales/dolor_respiro_1.wav")
const SND_VOZ_DOLOR_2 := preload("res://assets/sonidos/voces_reales/dolor_respiro_2.wav")
const SND_VOZ_DOLOR_3 := preload("res://assets/sonidos/voces_reales/dolor_respiro_3.wav")
const SND_VOZ_GRITO_PELEA_FUERTE := preload("res://assets/sonidos/voces_reales/grito_pelea_fuerte.wav")
const PERSONAJES_VOZ_MASCULINA := ["Kai", "Fang", "Aethel", "Magnus"]

# --- FASE 86.3: pegadas pesadas + ambiente Kai + identidad robótica Cibor-X ---
# Se retiraron por completo del selector los sonidos derivados de Slap/Hard Slap.
# Los golpes normales ahora parten de impactos de boxeo fuertes y una capa grave
# de cuerpo para que el contacto se sienta contundente sin sonar a palmada.
const SND_PUNO_BOXING_FUERTE := preload("res://assets/sonidos/impactos_pesados/boxing_strong_punch.wav")
const SND_PUNO_TOUGH_FUERTE := preload("res://assets/sonidos/impactos_pesados/tough_fighter_punch.wav")
const SND_THUMP_GRAVE := preload("res://assets/sonidos/impactos_pesados/thump_grave.wav")
const SND_KAI_AMBIENTE := preload("res://assets/sonidos/ambientes/kai_human_pain.ogg")
const SND_AETHEL_AMBIENTE := preload("res://assets/sonidos/escenarios/aethel.mp3")
const SND_CIBOR_AMBIENTE := preload("res://assets/sonidos/escenarios/cibor-x.mp3")
const SND_MAGNUS_AMBIENTE := preload("res://assets/sonidos/escenarios/magnus.mp3")
const SND_HELENA_AMBIENTE := preload("res://assets/sonidos/escenarios/helena.mp3")
const SND_KALI_AMBIENTE := preload("res://assets/sonidos/escenarios/kali.mp3")
const SND_FANG_AMBIENTE := preload("res://assets/sonidos/escenarios/fang.mp3")
const SND_CIBOR_STUN := preload("res://assets/sonidos/cibor_real/stun_intermitente.wav")
const SND_CIBOR_STUN_BURST := preload("res://assets/sonidos/cibor_real/stun_burst.wav")
const SND_CIBOR_BLASTER := preload("res://assets/sonidos/cibor_real/space_blaster.wav")

# --- FASE 86.4: nuevos gritos + voz Helena + golpe metálico Cibor-X ---
const SND_GRITO_HOMBRE_NUEVO_1 := preload("res://assets/sonidos/voces_reales_nuevas/grito_hombre_nuevo_1.wav")
const SND_GRITO_HOMBRE_NUEVO_2 := preload("res://assets/sonidos/voces_reales_nuevas/grito_hombre_nuevo_2.wav")
const SND_GRITO_HOMBRE_NUEVO_3 := preload("res://assets/sonidos/voces_reales_nuevas/grito_hombre_nuevo_3.wav")
const SND_GRITO_HOMBRE_NUEVO_4 := preload("res://assets/sonidos/voces_reales_nuevas/grito_hombre_nuevo_4.wav")
const SND_HELENA_GRITO_ATAQUE_1 := preload("res://assets/sonidos/helena_real/helena_grito_ataque_1.wav")
const SND_CIBOR_GOLPE_METAL_REAL := preload("res://assets/sonidos/cibor_real/golpe_metal_real.wav")
const SND_AETHEL_PODER_FINAL := preload("res://assets/sonidos/voces_aethel/aethel_poder_final_candidata.wav")
const SND_CIBOR_DOLOR_1 := preload("res://assets/sonidos/voces_cibor/cibor_dolor_1_candidata.wav")
const SND_CIBOR_DOLOR_2 := preload("res://assets/sonidos/voces_cibor/cibor_dolor_2_candidata.wav")
const SND_CIBOR_MUERTE := preload("res://assets/sonidos/voces_cibor/cibor_muerte_candidata.wav")
const SND_KALI_ATAQUE_1 := preload("res://assets/sonidos/voces_kali/kali_ataque_1_candidata.wav")

# --- FASE 86.5: voces dedicadas de recarga de energía ---
const SND_VOZ_RECARGA_MASC_A := preload("res://assets/sonidos/voces_recarga/recarga_masculina_a.wav")
const SND_VOZ_RECARGA_MASC_B := preload("res://assets/sonidos/voces_recarga/recarga_masculina_b.wav")
const PERSONAJES_VOZ_RECARGA_MASC := ["Kai", "Fang", "Aethel", "Magnus"]

var audio_golpe: AudioStreamPlayer
var audio_especial: AudioStreamPlayer
var audio_ko: AudioStreamPlayer
var audio_victoria: AudioStreamPlayer
var audio_poder_final: AudioStreamPlayer
var audio_salto: AudioStreamPlayer
var audio_musica_batalla: AudioStreamPlayer
var audio_ambiente_escenario: AudioStreamPlayer
var ambiente_escenario_actual := ""
# Evita una pared de gritos cuando conecta un combo de muchos impactos.
var ultima_voz_reaccion_ms: Dictionary = {}
var ultimo_grito_ataque_ms: Dictionary = {}

# --- Sistema de rondas ---
var rondas_kai := 0
var rondas_rival := 0
var ronda_activa := true
var etiqueta_resultado: Label
var etiqueta_marcador: Label

func _ready() -> void:
	_crear_escenario()
	_crear_ambiente()
	_crear_escenario_vivo()
	_crear_camara()
	_crear_ambiente_glow()
	_crear_audio()
	_crear_personajes()
	_crear_iluminacion_luchadores()
	_crear_ui()
	_crear_capa_destello()
	call_deferred("_presentar_ready_fight")

# FASE 92: capa de destello de pantalla completa para golpes fuertes. Va en
# una CanvasLayer bien arriba (por encima incluso de la UI) para que un
# remate/absoluto se sienta en TODA la pantalla, no solo en el personaje.
func _crear_capa_destello() -> void:
	var capa := CanvasLayer.new()
	capa.layer = 60
	add_child(capa)

	# La viñeta va ANTES que el destello en la misma capa: así el flash de
	# un golpe fuerte queda dibujado encima, no tapado por la viñeta.
	vineta_rect = ColorRect.new()
	vineta_rect.position = Vector2.ZERO
	vineta_rect.size = Vector2(ANCHO_ARENA, 720.0)
	vineta_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vineta_material = ShaderMaterial.new()
	vineta_material.shader = load("res://shaders/vineta_tension.gdshader")
	vineta_material.set_shader_parameter("intensidad", 0.0)
	vineta_rect.material = vineta_material
	capa.add_child(vineta_rect)

	destello_rect = ColorRect.new()
	destello_rect.position = Vector2.ZERO
	destello_rect.size = Vector2(ANCHO_ARENA, 720.0)
	destello_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	destello_material = ShaderMaterial.new()
	destello_material.shader = load("res://shaders/destello_impacto.gdshader")
	destello_material.set_shader_parameter("intensidad", 0.0)
	destello_rect.material = destello_material
	capa.add_child(destello_rect)

# FASE 99 — sube/baja la viñeta de tensión según la vida del jugador (el
# slot "kai", que representa al personaje controlado sea cual sea el
# elegido). Recién arranca a notarse por debajo del 40% de vida.
func _actualizar_vineta_tension(delta: float) -> void:
	if not vineta_material or not is_instance_valid(kai):
		return
	var ratio: float = clampf(kai.vida / maxf(kai.vida_maxima, 1.0), 0.0, 1.0)
	var objetivo: float = 0.0
	if ratio < 0.40:
		objetivo = clampf((0.40 - ratio) / 0.40, 0.0, 1.0) * 0.60
	var actual: float = vineta_material.get_shader_parameter("intensidad")
	vineta_material.set_shader_parameter("intensidad", lerpf(actual, objetivo, 1.0 - exp(-4.0 * delta)))

# Dispara el destello: sube la intensidad rápido y la deja caer. Se puede
# llamar seguido (un golpe atrás de otro) sin que se corte feo: si ya hay
# un destello en curso, lo reinicia desde el punto más alto en vez de que
# compitan dos tweens.
func _destello_pantalla(color: Color, intensidad_max: float, duracion_caida: float = 0.28) -> void:
	if not destello_material:
		return
	if destello_tween and is_instance_valid(destello_tween):
		destello_tween.kill()
	destello_material.set_shader_parameter("flash_color", color)
	destello_material.set_shader_parameter("intensidad", intensidad_max)
	destello_tween = create_tween()
	destello_tween.tween_property(destello_material, "shader_parameter/intensidad", 0.0, duracion_caida).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _presentar_ready_fight() -> void:
	if not is_instance_valid(kai) or not is_instance_valid(rival) or not etiqueta_resultado:
		return
	ronda_activa = false
	kai.congelado_por_rival = true
	rival.congelado_por_rival = true
	kai.velocity = Vector2.ZERO
	rival.velocity = Vector2.ZERO
	etiqueta_resultado.add_theme_font_size_override("font_size", 72)
	etiqueta_resultado.add_theme_color_override("font_color", Color(1.0, 0.92, 0.72))
	etiqueta_resultado.text = "READY"

	var anuncio := AudioStreamPlayer.new()
	anuncio.stream = SND_READY_FIGHT_NUEVO
	anuncio.volume_db = -1.5
	add_child(anuncio)
	anuncio.play()

	await get_tree().create_timer(1.65).timeout
	etiqueta_resultado.text = "FIGHT!"
	etiqueta_resultado.add_theme_color_override("font_color", Color(1.0, 0.55, 0.12))
	sacudir_camara(5.0, 0.14)
	await get_tree().create_timer(1.98).timeout
	if is_instance_valid(anuncio):
		anuncio.queue_free()
	etiqueta_resultado.text = ""
	etiqueta_resultado.add_theme_font_size_override("font_size", 40)
	etiqueta_resultado.add_theme_color_override("font_color", Color.WHITE)
	kai.congelado_por_rival = false
	rival.congelado_por_rival = false
	kai.reloj_seguridad_secuencia = 0.0
	rival.reloj_seguridad_secuencia = 0.0
	ronda_activa = true

func _crear_audio() -> void:
	audio_golpe = AudioStreamPlayer.new()
	audio_golpe.stream = SND_GOLPE
	add_child(audio_golpe)

	audio_especial = AudioStreamPlayer.new()
	audio_especial.stream = SND_ESPECIAL
	add_child(audio_especial)

	audio_ko = AudioStreamPlayer.new()
	audio_ko.stream = SND_KO
	add_child(audio_ko)

	audio_victoria = AudioStreamPlayer.new()
	audio_victoria.stream = SND_VICTORIA
	audio_victoria.volume_db = -2.0
	add_child(audio_victoria)

	audio_poder_final = AudioStreamPlayer.new()
	audio_poder_final.stream = SND_PODER_FINAL_NUEVO
	audio_poder_final.volume_db = -4.0
	add_child(audio_poder_final)

	audio_salto = AudioStreamPlayer.new()
	audio_salto.stream = SND_SALTO
	add_child(audio_salto)

	# PROTO 89.9: música/ambiente dedicado por escenario. Cada arena tiene
	# su propia pista y se repite mientras dure el combate.
	audio_ambiente_escenario = AudioStreamPlayer.new()
	audio_ambiente_escenario.volume_db = -10.0
	add_child(audio_ambiente_escenario)
	audio_ambiente_escenario.finished.connect(_al_ambiente_escenario_finalizado)

	# Se conserva el player de música de batalla para futuras capas especiales,
	# pero no superponemos otra canción encima de la música propia del escenario.
	audio_musica_batalla = AudioStreamPlayer.new()
	audio_musica_batalla.volume_db = -18.0
	add_child(audio_musica_batalla)

# Reproduce SFX superpuestos sin cortar el golpe anterior. Para un juego de
# pelea esto es clave: whoosh, contacto, caída y energía pueden solaparse.
func _reproducir_sfx(stream: AudioStream, volumen_db: float = 0.0, pitch: float = 1.0) -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volumen_db
	player.pitch_scale = pitch
	add_child(player)
	player.finished.connect(func():
		if is_instance_valid(player):
			player.queue_free()
	)
	player.play()

func _actualizar_audio_escenario(nombre_luchador: String) -> void:
	if not audio_ambiente_escenario:
		return
	ambiente_escenario_actual = nombre_luchador
	audio_ambiente_escenario.stop()
	audio_ambiente_escenario.stream = null

	# Volúmenes compensados según el nivel real de cada archivo para que todas
	# las arenas queden al fondo de la mezcla sin tapar golpes, voces ni poderes.
	match nombre_luchador:
		"Kai":
			audio_ambiente_escenario.stream = SND_KAI_AMBIENTE
			audio_ambiente_escenario.volume_db = -8.0
		"Aethel":
			audio_ambiente_escenario.stream = SND_AETHEL_AMBIENTE
			audio_ambiente_escenario.volume_db = -6.5
		"Cibor-X":
			audio_ambiente_escenario.stream = SND_CIBOR_AMBIENTE
			audio_ambiente_escenario.volume_db = -13.0
		"Magnus":
			audio_ambiente_escenario.stream = SND_MAGNUS_AMBIENTE
			audio_ambiente_escenario.volume_db = -13.0
		"Helena":
			audio_ambiente_escenario.stream = SND_HELENA_AMBIENTE
			audio_ambiente_escenario.volume_db = -11.0
		"Kali":
			audio_ambiente_escenario.stream = SND_KALI_AMBIENTE
			audio_ambiente_escenario.volume_db = 2.5
		"Fang":
			audio_ambiente_escenario.stream = SND_FANG_AMBIENTE
			audio_ambiente_escenario.volume_db = -15.5

	if audio_ambiente_escenario.stream != null:
		audio_ambiente_escenario.play()

func _al_ambiente_escenario_finalizado() -> void:
	# Loop universal: al terminar la pista vuelve a comenzar mientras la escena
	# de combate siga viva. Al cambiar de escena el AudioStreamPlayer desaparece.
	if audio_ambiente_escenario and audio_ambiente_escenario.stream != null and ambiente_escenario_actual != "":
		audio_ambiente_escenario.play()

func _elegir_sfx(pool: Array) -> AudioStream:
	if pool.is_empty():
		return SND_GOLPE
	return pool[randi() % pool.size()] as AudioStream

func _sfx_puno_real(fuerza: float) -> AudioStream:
	# FASE 86.3: cero palmadas. El pool usa boxeo fuerte/tough/crunch y
	# la jerarquía la da el volumen + la capa grave, no clips de slap.
	if fuerza >= 19.0:
		return _elegir_sfx([SND_PUNO_BOXING_FUERTE, SND_PUNO_TOUGH_FUERTE, SND_REAL_PUNO_CRUNCH_A, SND_REAL_PUNO_CRUNCH_B])
	if fuerza >= 13.0:
		return _elegir_sfx([SND_PUNO_BOXING_FUERTE, SND_PUNO_TOUGH_FUERTE, SND_REAL_PUNO_CRUNCH_A, SND_REAL_PUNO_CRUNCH_B, SND_REAL_PUNO_SECO_A])
	return _elegir_sfx([SND_PUNO_TOUGH_FUERTE, SND_PUNO_BOXING_FUERTE, SND_REAL_PUNO_SECO_A])

func _sfx_patada_real(fuerza: float) -> AudioStream:
	if fuerza >= 18.0:
		return _elegir_sfx([SND_REAL_PATADA_B, SND_REAL_IMPACTO_MIXTO_B, SND_REAL_PATADA_A, SND_PUNO_TOUGH_FUERTE])
	return _elegir_sfx([SND_REAL_PATADA_CORTA, SND_REAL_PATADA_A, SND_REAL_PATADA_B, SND_REAL_IMPACTO_MIXTO_A, SND_REAL_IMPACTO_MIXTO_B])

func _sfx_pesado_real() -> AudioStream:
	return _elegir_sfx([SND_PUNO_BOXING_FUERTE, SND_PUNO_TOUGH_FUERTE, SND_REAL_PUNO_CRUNCH_A, SND_REAL_PUNO_CRUNCH_B])

func _usa_voz_masculina(personaje: Fighter) -> bool:
	return is_instance_valid(personaje) and personaje.nombre_luchador in PERSONAJES_VOZ_MASCULINA

func _pitch_voz(personaje: Fighter) -> float:
	if not is_instance_valid(personaje):
		return 1.0
	match personaje.nombre_luchador:
		"Magnus": return randf_range(0.76, 0.82)
		"Fang": return randf_range(0.91, 0.97)
		"Aethel": return randf_range(1.01, 1.07)
		_: return randf_range(0.96, 1.03)

func _reproducir_voz_recarga(personaje: Fighter, absoluta: bool) -> bool:
	# Voces específicas para el beat cinematográfico de carga. No se usan
	# como gritos de impacto y nunca se aplican a Helena, Kali o Cibor-X.
	if not is_instance_valid(personaje) or not (personaje.nombre_luchador in PERSONAJES_VOZ_RECARGA_MASC):
		return false
	var stream: AudioStream = SND_VOZ_RECARGA_MASC_A
	var pitch: float = 1.0
	var volumen: float = -4.8 if absoluta else -6.2
	match personaje.nombre_luchador:
		"Kai":
			stream = _elegir_sfx([SND_VOZ_RECARGA_MASC_A, SND_VOZ_RECARGA_MASC_B]) if absoluta else SND_VOZ_RECARGA_MASC_A
			pitch = randf_range(0.97, 1.015)
		"Fang":
			stream = SND_VOZ_RECARGA_MASC_B
			pitch = randf_range(0.89, 0.94)
		"Aethel":
			stream = SND_VOZ_RECARGA_MASC_A
			pitch = randf_range(1.035, 1.075)
		"Magnus":
			stream = SND_VOZ_RECARGA_MASC_B
			pitch = randf_range(0.76, 0.82)
	_reproducir_sfx(stream, volumen, pitch)
	return true

func _reaccion_vocal_golpe(personaje: Fighter, fuerza: float, tipo: String) -> void:
	var es_cibor: bool = is_instance_valid(personaje) and personaje.nombre_luchador == "Cibor-X"
	if not es_cibor and not _usa_voz_masculina(personaje):
		return
	var ahora: int = Time.get_ticks_msec()
	var clave: int = personaje.get_instance_id()
	var ultimo: int = int(ultima_voz_reaccion_ms.get(clave, -100000))
	if ahora - ultimo < 430:
		return
	var chance: float = 0.18
	if fuerza >= 13.0:
		chance = 0.34
	if fuerza >= 19.0:
		chance = 0.56
	if tipo in ["especial", "rematador", "absoluto"]:
		chance = 0.76
	if randf() > chance:
		return
	ultima_voz_reaccion_ms[clave] = ahora
	# Cibor-X todavía tiene un único clip propio -- se usa siempre igual,
	# con variación de pitch para que no suene idéntico cada vez.
	if es_cibor:
		var stream_cibor: AudioStream = _elegir_sfx([SND_CIBOR_DOLOR_1, SND_CIBOR_DOLOR_2])
		_reproducir_sfx(stream_cibor, -6.0 if fuerza >= 17.0 else -8.5, randf_range(0.94, 1.05))
		return
	var stream: AudioStream
	if fuerza >= 17.0 or tipo in ["especial", "rematador", "absoluto"]:
		stream = _elegir_sfx([SND_VOZ_REACCION_HOMBRE, SND_VOZ_DOLOR_2, SND_VOZ_DOLOR_3, SND_GRITO_HOMBRE_NUEVO_1, SND_GRITO_HOMBRE_NUEVO_2, SND_GRITO_HOMBRE_NUEVO_4])
	else:
		stream = _elegir_sfx([SND_VOZ_DOLOR_1, SND_VOZ_DOLOR_2, SND_VOZ_DOLOR_3, SND_GRITO_HOMBRE_NUEVO_3])
	_reproducir_sfx(stream, -6.5 if fuerza >= 17.0 else -9.0, _pitch_voz(personaje))

func _intentar_grito_ataque(personaje: Fighter, fuerte: bool = false, chance: float = 0.25) -> void:
	if not is_instance_valid(personaje):
		return
	var es_helena: bool = personaje.nombre_luchador == "Helena"
	var es_kali: bool = personaje.nombre_luchador == "Kali"
	var es_masculino: bool = _usa_voz_masculina(personaje)
	if not es_helena and not es_kali and not es_masculino:
		return
	# Helena y Kali tienen por ahora un solo grito propio cada una. Se usan
	# con moderación para que no se repitan en cada frame/impacto del combo.
	var chance_real: float = chance
	if es_helena or es_kali:
		chance_real = minf(0.82 if fuerte else maxf(chance * 1.55, 0.16), 0.82)
	if randf() > chance_real:
		return
	var ahora: int = Time.get_ticks_msec()
	var clave: int = personaje.get_instance_id()
	var ultimo: int = int(ultimo_grito_ataque_ms.get(clave, -100000))
	var cooldown: int = 1150 if (es_helena or es_kali) else 950
	if ahora - ultimo < cooldown:
		return
	ultimo_grito_ataque_ms[clave] = ahora
	if es_helena:
		_reproducir_sfx(SND_HELENA_GRITO_ATAQUE_1, -6.8 if fuerte else -8.6, randf_range(0.985, 1.02))
		return
	if es_kali:
		_reproducir_sfx(SND_KALI_ATAQUE_1, -5.5 if fuerte else -7.5, randf_range(0.96, 1.06))
		return
	var stream: AudioStream
	if fuerte:
		stream = _elegir_sfx([SND_VOZ_GRITO_PELEA_FUERTE, SND_GRITO_HOMBRE_NUEVO_1, SND_GRITO_HOMBRE_NUEVO_2, SND_GRITO_HOMBRE_NUEVO_4])
	else:
		stream = _elegir_sfx([SND_VOZ_GRITO_ATAQUE_1, SND_VOZ_GRITO_ATAQUE_2, SND_VOZ_GRITO_ATAQUE_3, SND_GRITO_HOMBRE_NUEVO_1, SND_GRITO_HOMBRE_NUEVO_3])
	_reproducir_sfx(stream, -7.5 if fuerte else -10.0, _pitch_voz(personaje))

func _sfx_elemento(personaje: Fighter) -> AudioStream:
	if not is_instance_valid(personaje):
		return SND_ESPECIAL
	match personaje.nombre_luchador:
		"Kai": return SND_KAI_OSCURO
		"Helena": return SND_HELENA_LUZ
		"Fang": return SND_FANG_FUEGO
		"Cibor-X": return _elegir_sfx([SND_CIBOR_ELECTRICO, SND_CIBOR_STUN])
		"Kali": return SND_KALI_ACIDO
		"Aethel": return SND_AETHEL_VIENTO
		"Magnus": return SND_MAGNUS_PIEDRA
		_: return SND_ESPECIAL

func _crear_onda_impacto_premium(tipo: String, bloqueado: bool, intensidad: float) -> void:
	if not escenario_front or not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	var centro: Vector2 = (kai.global_position + rival.global_position) * 0.5
	centro.y -= 72.0
	var radio_base: float = 14.0
	var escala_final: float = 3.2 + intensidad * 2.4
	var ancho: float = 2.2
	if tipo == "patada":
		radio_base = 17.0
		escala_final += 0.8
		ancho = 2.8
	elif tipo == "especial":
		radio_base = 20.0
		escala_final = 5.4
		ancho = 3.0
	elif tipo == "rematador":
		radio_base = 24.0
		escala_final = 7.2
		ancho = 4.0
	elif tipo == "absoluto":
		radio_base = 30.0
		escala_final = 10.5
		ancho = 5.0
	if bloqueado:
		radio_base *= 0.72
		escala_final *= 0.62
		ancho = 2.0

	var aro := Line2D.new()
	var puntos := PackedVector2Array()
	for i in range(33):
		var a: float = TAU * float(i) / 32.0
		puntos.append(Vector2(cos(a), sin(a)) * radio_base)
	aro.points = puntos
	aro.width = ancho
	aro.antialiased = true
	var c: Color = Color(0.82, 0.92, 1.0) if bloqueado else escenario_effect_color.lerp(Color.WHITE, 0.62)
	aro.default_color = Color(c.r, c.g, c.b, 0.78 if bloqueado else 0.92)
	aro.position = centro
	aro.z_index = 12
	escenario_front.add_child(aro)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(aro, "scale", Vector2.ONE * escala_final, 0.16 if tipo != "absoluto" else 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(aro, "modulate:a", 0.0, 0.20 if tipo != "absoluto" else 0.30)
	tw.chain().tween_callback(aro.queue_free)

func _crear_camara() -> void:
	camara = Camera2D.new()
	camara.position = Vector2(ANCHO_ARENA / 2.0, 360.0)
	camara.enabled = true
	# Límites duros: la cámara nunca puede mostrar más allá del escenario,
	# así el zoom dramático no deja ver espacio vacío ni "descuadra" a
	# ninguno de los dos personajes por acercarse demasiado a un borde.
	camara.limit_left = 0
	camara.limit_right = int(ANCHO_ARENA)
	camara.limit_top = 0
	camara.limit_bottom = 760
	add_child(camara)

# FASE 98 — Glow/Bloom. Godot aplica esto sobre TODO lo que se vea más
# brillante que glow_hdr_threshold, así que se deja el umbral relativamente
# alto (0.90) para que agarre solo los picos de brillo reales -- el blanco
# pintado a mano en el centro del fuego/energía, los destellos de impacto --
# y no toda la escena. background_mode = BG_CANVAS es crítico: sin eso el
# Environment reemplaza el fondo ya dibujado por un color plano/cielo 3D en
# vez de solo aplicar el post-proceso encima.
func _crear_ambiente_glow() -> void:
	var entorno := Environment.new()
	entorno.background_mode = Environment.BG_CANVAS
	entorno.glow_enabled = true
	entorno.glow_hdr_threshold = 0.90
	entorno.glow_hdr_scale = 2.0
	entorno.glow_intensity = 0.55
	entorno.glow_strength = 0.85
	entorno.glow_bloom = 0.12
	entorno.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT

	# FASE 99 — color grading sutil: un poco más de contraste y saturación
	# para que la escena no se sienta "plana" en cámara, sin cambiar la
	# exposición general (adjustment_brightness se deja en 1.0).
	entorno.adjustment_enabled = true
	entorno.adjustment_brightness = 1.0
	entorno.adjustment_contrast = 1.08
	entorno.adjustment_saturation = 1.12

	var mundo := WorldEnvironment.new()
	mundo.environment = entorno
	add_child(mundo)

func _crear_escenario() -> void:
	fondo_sprite = Sprite2D.new()
	fondo_sprite.centered = false
	# Los fondos vienen a 1280x720 (mismo tamaño que la ventana), así que a
	# escala 1:1 se ve TODA la ilustración -- cielo, estatuas, columnas
	# lejanas -- y la arena de pelea termina siendo un cuadrito chico en el
	# medio, no una escena inmersiva. Lo agrando un poco y recorto un poco
	# más de abajo que de arriba (varios fondos, como el de Helena, tienen
	# el elemento principal -el dragón- llegando hasta el borde superior
	# mismo de la imagen, así que recortar fuerte de arriba lo cortaba).
	var zoom_fondo := 1.18
	fondo_sprite.scale = Vector2(zoom_fondo, zoom_fondo)
	var sobrante_x: float = ANCHO_ARENA * (zoom_fondo - 1.0)
	var sobrante_y: float = 720.0 * (zoom_fondo - 1.0)
	fondo_sprite.position = Vector2(-sobrante_x / 2.0, -sobrante_y * 0.1)
	fondo_sprite.z_index = -10
	fondo_material = ShaderMaterial.new()
	fondo_material.shader = load("res://shaders/escenario_ambiental.gdshader")
	fondo_sprite.material = fondo_material
	add_child(fondo_sprite)

	var suelo := StaticBody2D.new()
	var forma_suelo := RectangleShape2D.new()
	forma_suelo.size = Vector2(ANCHO_ARENA, 40)
	var colision_suelo := CollisionShape2D.new()
	colision_suelo.shape = forma_suelo
	suelo.add_child(colision_suelo)
	suelo.position = Vector2(ANCHO_ARENA / 2.0, SUELO_Y + 20)
	add_child(suelo)

	# Capa de piso viva: sombras, ondas de impacto y un brillo ambiental
	# extremadamente suave. No reemplaza el arte del suelo; lo hace reaccionar.
	piso_overlay = Node2D.new()
	piso_overlay.name = "PisoVivo"
	piso_overlay.z_index = 2
	add_child(piso_overlay)

	luz_impacto = PointLight2D.new()
	luz_impacto.energy = 0.0
	luz_impacto.shadow_enabled = false
	luz_impacto.z_index = 2
	add_child(luz_impacto)

	# FASE 97 — luz de escenario constante (a diferencia de luz_impacto,
	# que solo prende un instante al golpear). Es la que le da relieve
	# real al roster junto con el shader de volumen_personaje: sin esto,
	# el shader no tiene ninguna luz activa para reaccionar y los
	# personajes se ven exactamente igual que antes.
	# IMPORTANTE: restringida a range_item_cull_mask=2 para que SOLO
	# afecte a los sprites de los luchadores (que van a quedar en esa
	# misma capa). Si no se restringe, también ilumina el fondo -- que no
	# tiene el shader de relieve y se queda a brillo pleno -- y el
	# resultado es que la escena entera se ve sobre-expuesta y los
	# personajes pierden contraste contra el fondo.
	luz_escenario = DirectionalLight2D.new()
	luz_escenario.rotation = deg_to_rad(-50.0)
	luz_escenario.height = 0.75
	luz_escenario.energy = 0.45
	luz_escenario.color = Color(1.0, 0.95, 0.88)
	luz_escenario.shadow_enabled = false
	luz_escenario.range_item_cull_mask = 2
	luz_escenario.z_index = 2
	add_child(luz_escenario)

func _crear_iluminacion_luchadores() -> void:
	# Halos de contacto separados del sprite: integran a cada luchador con
	# el piso sin tocar su escala ni deformar sus PNG.
	iluminacion_luchadores = Node2D.new()
	iluminacion_luchadores.name = "IluminacionLuchadores"
	iluminacion_luchadores.z_index = -1
	add_child(iluminacion_luchadores)

	halo_luchador_kai = Polygon2D.new()
	halo_luchador_kai.polygon = _crear_poligono_elipse(92.0, 17.0)
	halo_luchador_kai.color = Color(1.0, 1.0, 1.0, 1.0)
	halo_luchador_kai.modulate.a = 0.0
	iluminacion_luchadores.add_child(halo_luchador_kai)

	halo_luchador_rival = Polygon2D.new()
	halo_luchador_rival.polygon = _crear_poligono_elipse(92.0, 17.0)
	halo_luchador_rival.color = Color(1.0, 1.0, 1.0, 1.0)
	halo_luchador_rival.modulate.a = 0.0
	iluminacion_luchadores.add_child(halo_luchador_rival)

func _actualizar_halo_luchador(halo: Polygon2D, luchador: Fighter, delta: float) -> void:
	if not halo or not is_instance_valid(luchador):
		return
	var carga: float = clampf(luchador.poder / maxf(luchador.poder_maximo, 1.0), 0.0, 1.0)
	var en_ataque: bool = luchador.fase_ataque == Fighter.FaseAtaque.ACTIVO
	var en_poder: bool = luchador.en_secuencia_especial or luchador.en_fase_absoluta
	var movimiento: float = clampf(absf(luchador.velocity.x) / 460.0, 0.0, 1.0)
	var pulso: float = 0.5 + 0.5 * sin(escenario_tiempo * 3.1 + float(luchador.get_instance_id() % 13))
	var alpha_objetivo: float = 0.020 + carga * 0.045 + movimiento * 0.012
	if en_ataque:
		alpha_objetivo += 0.025
	if en_poder:
		alpha_objetivo += 0.070 + pulso * 0.020
	alpha_objetivo = clampf(alpha_objetivo, 0.015, 0.145)

	var c: Color = luchador.color_fase.lerp(Color.WHITE, 0.18)
	halo.color = Color(c.r, c.g, c.b, 1.0)
	halo.position = Vector2(luchador.global_position.x, SUELO_Y - 4.0)
	var ancho_objetivo: float = 1.0 + movimiento * 0.22 + (0.10 if en_ataque else 0.0)
	var alto_objetivo: float = 1.0 - movimiento * 0.08
	halo.scale = halo.scale.lerp(Vector2(ancho_objetivo, alto_objetivo), 1.0 - exp(-8.0 * delta))
	halo.modulate.a = lerpf(halo.modulate.a, alpha_objetivo, 1.0 - exp(-10.0 * delta))

func _actualizar_iluminacion_luchadores(delta: float) -> void:
	if halo_luchador_kai and is_instance_valid(kai):
		_actualizar_halo_luchador(halo_luchador_kai, kai, delta)
	if halo_luchador_rival and is_instance_valid(rival):
		_actualizar_halo_luchador(halo_luchador_rival, rival, delta)

func _actualizar_fondo(nombre_luchador: String) -> void:
	escenario_nombre_actual = nombre_luchador
	var ruta: String = FONDOS.get(nombre_luchador, "")
	if ruta == "":
		return
	fondo_sprite.texture = load(ruta)
	var c: Color = AMBIENTE_COLORES.get(nombre_luchador, Color(0.8, 0.8, 0.9))
	_aplicar_color_ambiente(c)
	_configurar_escenario_vivo(nombre_luchador, c)
	_actualizar_audio_escenario(nombre_luchador)

func _crear_ambiente() -> void:
	ambiente_particulas = Node2D.new()
	ambiente_particulas.name = "AmbienteVivo"
	ambiente_particulas.z_index = -2
	add_child(ambiente_particulas)
	var tex := load("res://assets/ambient_particle.png")
	for i in range(24):
		var p := Sprite2D.new()
		p.texture = tex
		p.position = Vector2(randf_range(25.0, ANCHO_ARENA - 25.0), randf_range(150.0, 620.0))
		p.scale = Vector2.ONE * randf_range(0.12, 0.38)
		p.modulate = Color(1.0, 1.0, 1.0, randf_range(0.12, 0.42))
		ambiente_particulas.add_child(p)
		_animar_particula_ambiental(p, i)

	# Capa atmosférica cercana: partículas más grandes y lentas, con
	# opacidad baja. Da separación entre cámara y fondo sin tapar la pelea.
	ambiente_particulas_delante = Node2D.new()
	ambiente_particulas_delante.name = "AtmosferaCercana"
	ambiente_particulas_delante.z_index = -1
	add_child(ambiente_particulas_delante)
	for i in range(10):
		var p2 := Sprite2D.new()
		p2.texture = tex
		p2.position = Vector2(randf_range(20.0, ANCHO_ARENA - 20.0), randf_range(180.0, 600.0))
		p2.scale = Vector2.ONE * randf_range(0.35, 0.75)
		p2.modulate = Color(1.0, 1.0, 1.0, randf_range(0.04, 0.12))
		ambiente_particulas_delante.add_child(p2)
		_animar_particula_ambiental_cercana(p2, i)

	# Brumas lineales muy suaves que se desplazan lentamente en primer
	# plano. Dan sensación de aire y profundidad sin distraer de la pelea.
	for i in range(3):
		var bruma := Polygon2D.new()
		bruma.polygon = PackedVector2Array([
			Vector2(-140, -3), Vector2(-35, -8), Vector2(140, -3),
			Vector2(140, 3), Vector2(-35, 8), Vector2(-140, 3)
		])
		bruma.color = Color(1.0, 1.0, 1.0, 0.018)
		bruma.position = Vector2(randf_range(100.0, ANCHO_ARENA - 100.0), randf_range(180.0, 530.0))
		bruma.rotation = randf_range(-0.06, 0.06)
		bruma.z_index = 0
		ambiente_particulas_delante.add_child(bruma)
		var tw_bruma := create_tween()
		tw_bruma.set_loops()
		tw_bruma.set_parallel(true)
		tw_bruma.tween_property(bruma, "position:x", bruma.position.x + randf_range(-100.0, 100.0), randf_range(5.5, 8.0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw_bruma.tween_property(bruma, "modulate:a", 0.050, 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw_bruma.chain().tween_property(bruma, "modulate:a", 0.010, 2.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _animar_particula_ambiental(p: Sprite2D, indice: int) -> void:
	await get_tree().process_frame
	while is_instance_valid(p):
		var inicio := Vector2(randf_range(20.0, ANCHO_ARENA - 20.0), randf_range(170.0, 620.0))
		var destino := inicio + Vector2(randf_range(-35.0, 35.0), randf_range(-95.0, -25.0))
		p.position = inicio
		p.modulate.a = randf_range(0.10, 0.38)
		var duracion := randf_range(2.8, 5.5) + indice * 0.015
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(p, "position", destino, duracion).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(p, "rotation", randf_range(-1.2, 1.2), duracion)
		tw.tween_property(p, "modulate:a", 0.0, duracion)
		await tw.finished

func _animar_particula_ambiental_cercana(p: Sprite2D, indice: int) -> void:
	await get_tree().process_frame
	while is_instance_valid(p):
		var inicio := Vector2(randf_range(10.0, ANCHO_ARENA - 10.0), randf_range(160.0, 610.0))
		var destino := inicio + Vector2(randf_range(-55.0, 55.0), randf_range(-35.0, 35.0))
		p.position = inicio
		p.modulate.a = randf_range(0.04, 0.12)
		var duracion := randf_range(4.0, 7.0) + indice * 0.03
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(p, "position", destino, duracion).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(p, "rotation", randf_range(-0.8, 0.8), duracion)
		tw.tween_property(p, "modulate:a", 0.0, duracion)
		await tw.finished


func _aplicar_color_ambiente(c: Color) -> void:
	if ambiente_particulas:
		for nodo in ambiente_particulas.get_children():
			if nodo is Sprite2D:
				var alpha: float = nodo.modulate.a
				nodo.modulate = Color(c.r, c.g, c.b, alpha)
	if ambiente_particulas_delante:
		for nodo in ambiente_particulas_delante.get_children():
			if nodo is Sprite2D:
				var alpha_delante: float = nodo.modulate.a
				nodo.modulate = Color(minf(c.r * 1.15, 1.0), minf(c.g * 1.15, 1.0), minf(c.b * 1.15, 1.0), alpha_delante)
	if fondo_material:
		fondo_material.set_shader_parameter("pulse_strength", 0.014 + (c.r + c.g + c.b) / 3.0 * 0.010)

func _crear_escenario_vivo() -> void:
	# Capas procedurales. No reemplazan el arte: agregan profundidad, aire,
	# partículas y movimiento para que el fondo deje de sentirse plano.
	escenario_vivo = Node2D.new()
	escenario_vivo.name = "EscenarioVivo"
	escenario_vivo.z_index = -6
	add_child(escenario_vivo)

	escenario_far = Node2D.new()
	escenario_far.name = "ParallaxLejano"
	escenario_far.z_index = -5
	escenario_vivo.add_child(escenario_far)

	escenario_mid = Node2D.new()
	escenario_mid.name = "ParallaxMedio"
	escenario_mid.z_index = -3
	escenario_vivo.add_child(escenario_mid)

	escenario_front = Node2D.new()
	escenario_front.name = "ElementosFrente"
	escenario_front.z_index = 3
	add_child(escenario_front)

	for i in range(7):
		var banda := Polygon2D.new()
		banda.polygon = PackedVector2Array([
			Vector2(-180.0, -6.0), Vector2(180.0, -12.0),
			Vector2(180.0, 12.0), Vector2(-180.0, 6.0)
		])
		banda.position = Vector2(randf_range(60.0, ANCHO_ARENA - 60.0), randf_range(150.0, 500.0))
		banda.rotation = randf_range(-0.12, 0.12)
		banda.modulate = Color(1.0, 1.0, 1.0, 0.0)
		escenario_far.add_child(banda)
		var tw := create_tween()
		tw.set_loops()
		tw.set_parallel(true)
		tw.tween_property(banda, "modulate:a", 0.055, randf_range(2.8, 4.2)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.chain().tween_property(banda, "modulate:a", 0.008, randf_range(3.0, 4.8)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(banda, "position:x", banda.position.x + randf_range(-120.0, 120.0), randf_range(6.0, 10.0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _limpiar_hijos(nodo: Node) -> void:
	if not is_instance_valid(nodo):
		return
	for hijo in nodo.get_children():
		if is_instance_valid(hijo):
			hijo.queue_free()

func _configurar_escenario_vivo(nombre_luchador: String, c: Color) -> void:
	escenario_effect_color = c
	escenario_tipo = _tipo_escenario(nombre_luchador)
	escenario_pulso = 0.0
		
	if piso_overlay:
		for hijo in piso_overlay.get_children():
			if is_instance_valid(hijo) and hijo != luz_impacto:
				hijo.queue_free()
		if piso_luz_ambiente and is_instance_valid(piso_luz_ambiente):
			piso_luz_ambiente.queue_free()
		piso_luz_ambiente = Polygon2D.new()
		piso_luz_ambiente.polygon = _crear_poligono_elipse(340.0, 38.0)
		piso_luz_ambiente.position = Vector2(ANCHO_ARENA * 0.5, SUELO_Y - 3.0)
		piso_luz_ambiente.color = Color(c.r, c.g, c.b, 0.075)
		piso_luz_ambiente.z_index = 1
		piso_overlay.add_child(piso_luz_ambiente)
		var tw_piso := create_tween()
		tw_piso.set_loops()
		tw_piso.tween_property(piso_luz_ambiente, "scale", Vector2(1.05, 1.16), 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw_piso.chain().tween_property(piso_luz_ambiente, "scale", Vector2(0.98, 0.92), 2.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw_piso.parallel().tween_property(piso_luz_ambiente, "modulate:a", 0.62, 2.2)
		tw_piso.chain().tween_property(piso_luz_ambiente, "modulate:a", 0.36, 2.2)
	
	if escenario_mid:
		_limpiar_hijos(escenario_mid)
	if escenario_front:
		_limpiar_hijos(escenario_front)
	
	# Halo ambiental grande: muy tenue y detrás de los luchadores.
	if escenario_mid:
		for i in range(3):
			var halo := Polygon2D.new()
			halo.polygon = _crear_poligono_elipse(190.0 + float(i) * 80.0, 90.0 + float(i) * 50.0)
			halo.position = Vector2(ANCHO_ARENA * (0.25 + float(i) * 0.25), 290.0 + float(i) * 35.0)
			halo.color = Color(c.r, c.g, c.b, 0.028 - float(i) * 0.006)
			halo.z_index = -4
			escenario_mid.add_child(halo)
			var tw_halo := create_tween()
			tw_halo.set_loops()
			tw_halo.tween_property(halo, "scale", Vector2(1.08, 1.04), 2.8 + float(i) * 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tw_halo.chain().tween_property(halo, "scale", Vector2.ONE, 2.8 + float(i) * 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	escenario_ambiente_reloj = randf_range(0.15, 0.75)
	escenario_energia_reactiva = 0.0
	helena_ojos.clear()
	helena_aura_cabeza = null
	cibor_reactor_halo = null
	_configurar_shader_escenario(escenario_tipo)
	_crear_efectos_elementales(c)
	_crear_detalles_escenario(nombre_luchador, c)

func _tipo_escenario(nombre: String) -> String:
	match nombre:
		"Fang": return "fuego"
		"Cibor-X": return "electrico"
		"Kali": return "veneno"
		"Aethel": return "aire"
		"Magnus": return "tierra"
		"Helena": return "luz"
		"Jester": return "veneno"
		_: return "oscuro"

func _crear_poligono_elipse(rx: float, ry: float) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	for i in range(28):
		var ang: float = TAU * float(i) / 28.0
		puntos.append(Vector2(cos(ang) * rx, sin(ang) * ry))
	return puntos

func _crear_efectos_elementales(c: Color) -> void:
	if not escenario_front:
		return
	
	match escenario_tipo:
		"fuego":
			_crear_motas_elementales(c, 38, 0.24, Vector2(0.0, -110.0), Vector2(0.0, -300.0), 1.2)
			_crear_bruma_elemental(c, 4, 0.045, 0.72)
		"electrico":
			_crear_destellos(c, 13)
			_crear_motas_elementales(c, 20, 0.12, Vector2(0.0, 0.0), Vector2(0.0, -70.0), 0.9)
		"veneno":
			_crear_motas_elementales(c, 34, 0.17, Vector2(0.0, -30.0), Vector2(0.0, -110.0), 1.6)
			_crear_bruma_elemental(c, 5, 0.055, 0.42)
		"aire":
			_crear_rastros_aire(c, 12)
			_crear_motas_elementales(c, 18, 0.10, Vector2(-90.0, 0.0), Vector2(220.0, -35.0), 1.0)
		"tierra":
			_crear_motas_elementales(c, 24, 0.14, Vector2(0.0, 0.0), Vector2(0.0, -50.0), 1.35)
			_crear_fragmentsuelo(c, 14)
		"luz":
			_crear_motas_elementales(c, 34, 0.13, Vector2(0.0, 30.0), Vector2(0.0, -140.0), 1.35)
			_crear_destellos(c, 9)
		_:
			_crear_motas_elementales(c, 14, 0.09, Vector2(0.0, 0.0), Vector2(0.0, -80.0), 1.0)

func _crear_motas_elementales(c: Color, cantidad: int, alpha_max: float, delta_inicio: Vector2, delta_destino: Vector2, tam_mult: float) -> void:
	# Partículas procedurales: el PNG original era demasiado pequeño para
	# algunos fondos, así que usamos pequeñas formas reales. Son sutiles pero
	# visibles y no dependen de una textura externa.
	for i in range(cantidad):
		var p := Polygon2D.new()
		var radio: float = randf_range(2.0, 5.2) * tam_mult
		var forma := i % 3
		if escenario_tipo == "fuego":
			radio = randf_range(2.0, 5.8) * tam_mult
			forma = 1
		elif escenario_tipo == "electrico":
			radio = randf_range(1.8, 4.5) * tam_mult
			forma = 2
		elif escenario_tipo == "tierra":
			radio = randf_range(2.0, 6.0) * tam_mult
			forma = 1
		if forma == 0:
			p.polygon = _crear_poligono_elipse(radio, radio * 0.7)
		elif forma == 1:
			p.polygon = PackedVector2Array([Vector2(0,-radio), Vector2(radio*0.55,0), Vector2(0,radio), Vector2(-radio*0.55,0)])
		else:
			p.polygon = PackedVector2Array([Vector2(-radio,0), Vector2(-radio*0.2,-radio*0.32), Vector2(radio*0.15,-radio), Vector2(radio*0.45,-radio*0.3), Vector2(radio,0), Vector2(radio*0.25,radio*0.28)])
		p.position = Vector2(randf_range(30.0, ANCHO_ARENA - 30.0), randf_range(220.0, 590.0))
		p.rotation = randf_range(0.0, TAU)
		p.color = Color(c.r, c.g, c.b, randf_range(alpha_max * 0.35, alpha_max))
		p.z_index = 4
		escenario_front.add_child(p)
		_animar_efecto_elemental(p, delta_inicio, delta_destino, i)

func _animar_efecto_elemental(p: Node2D, delta_inicio: Vector2, delta_destino: Vector2, indice: int) -> void:
	await get_tree().process_frame
	while is_instance_valid(p):
		var inicio: Vector2 = Vector2(randf_range(20.0, ANCHO_ARENA - 20.0), randf_range(180.0, 620.0)) + delta_inicio
		var destino: Vector2 = inicio + delta_destino + Vector2(randf_range(-35.0, 35.0), randf_range(-25.0, 25.0))
		var dur: float = randf_range(2.5, 5.5) + float(indice % 7) * 0.08
		p.position = inicio
		p.modulate.a = randf_range(0.03, 0.16)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(p, "position", destino, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(p, "rotation", randf_range(-1.8, 1.8), dur)
		tw.tween_property(p, "modulate:a", 0.0, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tw.finished

func _crear_bruma_elemental(c: Color, cantidad: int, alpha: float, velocidad: float) -> void:
	for i in range(cantidad):
		var bruma := Polygon2D.new()
		var ancho: float = randf_range(130.0, 240.0)
		bruma.polygon = PackedVector2Array([
			Vector2(-ancho, -6.0), Vector2(-ancho * 0.55, -10.0),
			Vector2(ancho, -4.0), Vector2(ancho, 6.0),
			Vector2(ancho * 0.35, 11.0), Vector2(-ancho, 6.0)
		])
		bruma.position = Vector2(randf_range(50.0, ANCHO_ARENA - 50.0), randf_range(230.0, 560.0))
		bruma.color = Color(c.r, c.g, c.b, alpha)
		bruma.z_index = 4
		escenario_front.add_child(bruma)
		var tw := create_tween()
		tw.set_loops()
		tw.set_parallel(true)
		tw.tween_property(bruma, "position:x", bruma.position.x + randf_range(-110.0, 110.0), 6.0 / maxf(velocidad, 0.1)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(bruma, "modulate:a", alpha * 1.5, 2.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.chain().tween_property(bruma, "modulate:a", alpha * 0.25, 2.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _crear_destellos(c: Color, cantidad: int) -> void:
	for i in range(cantidad):
		var destello := Polygon2D.new()
		var largo: float = randf_range(12.0, 28.0)
		destello.polygon = PackedVector2Array([
			Vector2(-largo, 0), Vector2(0, -2), Vector2(largo, 0), Vector2(0, 2)
		])
		destello.position = Vector2(randf_range(50.0, ANCHO_ARENA - 50.0), randf_range(170.0, 520.0))
		destello.rotation = randf_range(0.0, TAU)
		destello.color = Color(c.r, c.g, c.b, 0.0)
		destello.z_index = 4
		escenario_front.add_child(destello)
		var tw := create_tween()
		tw.set_loops()
		tw.tween_property(destello, "modulate:a", randf_range(0.12, 0.32), randf_range(1.0, 1.8))
		tw.chain().tween_property(destello, "modulate:a", 0.0, randf_range(1.0, 1.8))

func _crear_rastros_aire(c: Color, cantidad: int) -> void:
	for i in range(cantidad):
		var rastro := Polygon2D.new()
		var largo: float = randf_range(60.0, 140.0)
		rastro.polygon = PackedVector2Array([
			Vector2(-largo, -2), Vector2(largo, -1),
			Vector2(largo * 0.7, 2), Vector2(-largo * 0.65, 3)
		])
		rastro.position = Vector2(randf_range(40.0, ANCHO_ARENA - 40.0), randf_range(180.0, 540.0))
		rastro.color = Color(c.r, c.g, c.b, randf_range(0.02, 0.05))
		rastro.z_index = 4
		escenario_front.add_child(rastro)
		var tw := create_tween()
		tw.set_loops()
		tw.set_parallel(true)
		tw.tween_property(rastro, "position:x", rastro.position.x + randf_range(120.0, 260.0), randf_range(2.5, 5.0)).set_trans(Tween.TRANS_SINE)
		tw.tween_property(rastro, "modulate:a", 0.0, randf_range(2.5, 5.0))
		tw.chain().tween_property(rastro, "position:x", randf_range(-80.0, 100.0), 0.01)

func _crear_fragmentsuelo(c: Color, cantidad: int) -> void:
	for i in range(cantidad):
		var piedra := Polygon2D.new()
		var tam: float = randf_range(2.0, 5.0)
		piedra.polygon = PackedVector2Array([
			Vector2(-tam, 0), Vector2(-tam * 0.3, -tam * 1.1),
			Vector2(tam, -tam * 0.2), Vector2(tam * 0.2, tam)
		])
		piedra.position = Vector2(randf_range(30.0, ANCHO_ARENA - 30.0), randf_range(535.0, 560.0))
		piedra.color = Color(c.r, c.g, c.b, randf_range(0.10, 0.22))
		piedra.z_index = 4
		escenario_front.add_child(piedra)
		var tw := create_tween()
		tw.set_loops()
		tw.set_parallel(true)
		tw.tween_property(piedra, "position:y", piedra.position.y - randf_range(4.0, 9.0), randf_range(1.8, 3.0)).set_trans(Tween.TRANS_SINE)
		tw.tween_property(piedra, "rotation", randf_range(-1.2, 1.2), randf_range(1.8, 3.0))
		tw.chain().tween_property(piedra, "position:y", piedra.position.y, randf_range(1.8, 3.0)).set_trans(Tween.TRANS_SINE)


# -----------------------------------------------------------------------------
# FASE 87 — ESCENARIOS VIVOS
# El arte original sigue siendo el fondo. Estos nodos son una capa de vida:
# fuego, humo, viento, electricidad, ácido, polvo y detalles exclusivos.
# Todo queda detrás o alrededor de los luchadores y se intensifica con CORE.
# -----------------------------------------------------------------------------
func _configurar_shader_escenario(tipo: String) -> void:
	if not fondo_material:
		return
	var deformacion := 0.00035
	var velocidad := 0.75
	var frecuencia := 16.0
	match tipo:
		"fuego":
			deformacion = 0.00185
			velocidad = 2.35
			frecuencia = 31.0
		"electrico":
			deformacion = 0.00055
			velocidad = 3.10
			frecuencia = 24.0
		"veneno":
			deformacion = 0.00110
			velocidad = 0.75
			frecuencia = 18.0
		"aire":
			deformacion = 0.00095
			velocidad = 0.58
			frecuencia = 13.0
		"tierra":
			deformacion = 0.00018
			velocidad = 0.35
			frecuencia = 10.0
		"luz":
			deformacion = 0.00055
			velocidad = 0.48
			frecuencia = 12.0
		_:
			deformacion = 0.00075
			velocidad = 0.42
			frecuencia = 15.0
	fondo_material.set_shader_parameter("warp_strength", deformacion)
	fondo_material.set_shader_parameter("warp_speed", velocidad)
	fondo_material.set_shader_parameter("warp_frequency", frecuencia)

func _crear_detalles_escenario(nombre: String, c: Color) -> void:
	if not escenario_mid or not escenario_front:
		return
	match nombre:
		"Helena":
			_crear_detalle_dragon_helena(c)
			_crear_petalos_helena(c, 20)
		"Fang":
			_crear_llamas_fang(c, 12)
			_crear_humo_fang(6)
		"Cibor-X":
			_crear_reactor_cibor(c)
			_crear_vapor_cibor(7)
		"Kali":
			_crear_burbujas_kali(c, 14)
		"Aethel":
			_crear_plumas_aethel(c, 14)
		"Magnus":
			_crear_rocas_magnus(c, 12)
		"Kai":
			_crear_niebla_kai(c, 7)

func _crear_detalle_dragon_helena(c: Color) -> void:
	# Coordenadas ajustadas al zoom actual del fondo de Helena. No movemos el
	# PNG completo: animamos ojos/aura/aliento sobre la cabeza del dragón.
	helena_aura_cabeza = Polygon2D.new()
	helena_aura_cabeza.polygon = _crear_poligono_elipse(56.0, 38.0)
	helena_aura_cabeza.position = Vector2(350.0, 145.0)
	helena_aura_cabeza.color = Color(1.0, 0.20, 0.72, 0.035)
	helena_aura_cabeza.z_index = -2
	escenario_mid.add_child(helena_aura_cabeza)
	var ta := create_tween()
	ta.set_loops()
	ta.set_parallel(true)
	ta.tween_property(helena_aura_cabeza, "scale", Vector2(1.16, 1.10), 1.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ta.tween_property(helena_aura_cabeza, "position", Vector2(352.0, 142.5), 1.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ta.chain().tween_property(helena_aura_cabeza, "scale", Vector2(0.96, 0.98), 1.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ta.parallel().tween_property(helena_aura_cabeza, "position", Vector2(348.5, 146.0), 1.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	for pos in [Vector2(339.0, 129.0), Vector2(353.0, 132.0)]:
		var ojo := Polygon2D.new()
		ojo.polygon = _crear_poligono_elipse(3.8, 2.1)
		ojo.position = pos
		ojo.color = Color(1.0, 0.72, 0.95, 0.55)
		ojo.z_index = 0
		escenario_mid.add_child(ojo)
		helena_ojos.append(ojo)
		var to := create_tween()
		to.set_loops()
		to.tween_property(ojo, "scale", Vector2(1.75, 1.45), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		to.parallel().tween_property(ojo, "modulate:a", 0.95, 0.55)
		to.chain().tween_property(ojo, "scale", Vector2(0.85, 0.85), 0.70).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		to.parallel().tween_property(ojo, "modulate:a", 0.42, 0.70)

func _crear_petalo_helena(pos: Vector2, c: Color, grande: bool = false) -> Polygon2D:
	var p := Polygon2D.new()
	var tam: float = randf_range(2.5, 5.2) * (1.35 if grande else 1.0)
	p.polygon = PackedVector2Array([Vector2(-tam,0), Vector2(0,-tam*0.55), Vector2(tam,0), Vector2(0,tam*0.38)])
	p.position = pos
	p.rotation = randf_range(0.0, TAU)
	p.color = Color(1.0, 0.45 + randf()*0.18, 0.82 + randf()*0.12, randf_range(0.16, 0.34))
	p.z_index = 4
	return p

func _crear_petalos_helena(c: Color, cantidad: int) -> void:
	for i in range(cantidad):
		var p := _crear_petalo_helena(Vector2(randf_range(-80.0, ANCHO_ARENA), randf_range(80.0, 520.0)), c)
		escenario_front.add_child(p)
		_animar_petalo_helena(p, i)

func _animar_petalo_helena(p: Polygon2D, indice: int) -> void:
	await get_tree().process_frame
	while is_instance_valid(p):
		p.position = Vector2(randf_range(-100.0, 80.0), randf_range(80.0, 500.0))
		p.modulate.a = randf_range(0.12, 0.30)
		var destino := Vector2(ANCHO_ARENA + randf_range(80.0, 220.0), p.position.y + randf_range(70.0, 180.0))
		var dur := randf_range(5.0, 8.0) + float(indice % 6) * 0.12
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(p, "position", destino, dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(p, "rotation", p.rotation + randf_range(4.0, 9.0), dur)
		tw.tween_property(p, "modulate:a", 0.0, dur)
		await tw.finished

func _emitir_aliento_helena(intensidad: float = 1.0) -> void:
	if escenario_nombre_actual != "Helena" or not escenario_front:
		return
	var cantidad := 5 + int(7.0 * intensidad)
	for i in range(cantidad):
		var vapor := Polygon2D.new()
		var rx := randf_range(8.0, 18.0)
		vapor.polygon = _crear_poligono_elipse(rx, rx * 0.42)
		vapor.position = Vector2(365.0, 168.0) + Vector2(randf_range(-4.0, 4.0), randf_range(-4.0, 5.0))
		vapor.color = Color(1.0, 0.30, 0.80, randf_range(0.05, 0.12) * intensidad)
		vapor.z_index = 3
		escenario_front.add_child(vapor)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(vapor, "position", vapor.position + Vector2(randf_range(70.0, 150.0), randf_range(15.0, 55.0)), randf_range(1.2, 2.2)).set_trans(Tween.TRANS_SINE)
		tw.tween_property(vapor, "scale", Vector2(randf_range(2.0,3.2), randf_range(1.4,2.2)), 1.7)
		tw.tween_property(vapor, "modulate:a", 0.0, 1.7)
		tw.chain().tween_callback(vapor.queue_free)

func _crear_llamas_fang(c: Color, cantidad: int) -> void:
	for i in range(cantidad):
		var llama := Polygon2D.new()
		var w := randf_range(5.0, 11.0)
		var h := randf_range(16.0, 38.0)
		llama.polygon = PackedVector2Array([Vector2(-w,h*0.4), Vector2(-w*0.45,-h*0.10), Vector2(0,-h), Vector2(w*0.50,-h*0.12), Vector2(w,h*0.4)])
		var lado := -1.0 if i % 2 == 0 else 1.0
		llama.position = Vector2(70.0 if lado < 0.0 else ANCHO_ARENA-70.0, randf_range(330.0, 535.0)) + Vector2(randf_range(-45.0,45.0),0)
		llama.color = Color(1.0, randf_range(0.25,0.55), 0.03, randf_range(0.12,0.28))
		llama.z_index = 2
		escenario_front.add_child(llama)
		var tw := create_tween()
		tw.set_loops()
		tw.tween_property(llama, "scale", Vector2(randf_range(0.65,0.90), randf_range(1.25,1.65)), randf_range(0.28,0.50)).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(llama, "modulate:a", randf_range(0.55,0.85), randf_range(0.28,0.50))
		tw.chain().tween_property(llama, "scale", Vector2(randf_range(1.0,1.2), 0.75), randf_range(0.30,0.55)).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(llama, "modulate:a", randf_range(0.16,0.30), randf_range(0.30,0.55))

func _crear_humo_fang(cantidad: int) -> void:
	for i in range(cantidad):
		var humo := Polygon2D.new()
		humo.polygon = _crear_poligono_elipse(randf_range(30.0,70.0), randf_range(10.0,24.0))
		humo.position = Vector2(randf_range(50.0, ANCHO_ARENA-50.0), randf_range(230.0,470.0))
		humo.color = Color(0.16,0.10,0.08,randf_range(0.025,0.055))
		humo.z_index = -1
		escenario_mid.add_child(humo)
		var tw := create_tween()
		tw.set_loops()
		tw.set_parallel(true)
		tw.tween_property(humo, "position", humo.position + Vector2(randf_range(-80.0,80.0), randf_range(-65.0,-25.0)), randf_range(4.5,7.5)).set_trans(Tween.TRANS_SINE)
		tw.tween_property(humo, "scale", Vector2(randf_range(1.3,1.8),randf_range(1.2,1.6)), randf_range(4.5,7.5))

func _crear_reactor_cibor(c: Color) -> void:
	cibor_reactor_halo = Polygon2D.new()
	cibor_reactor_halo.polygon = _crear_poligono_elipse(86.0, 86.0)
	cibor_reactor_halo.position = Vector2(ANCHO_ARENA*0.5, 210.0)
	cibor_reactor_halo.color = Color(0.15,0.75,1.0,0.035)
	cibor_reactor_halo.z_index = -2
	escenario_mid.add_child(cibor_reactor_halo)
	var tw := create_tween()
	tw.set_loops()
	tw.tween_property(cibor_reactor_halo, "scale", Vector2(1.16,1.16), 0.72).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(cibor_reactor_halo, "modulate:a", 0.80, 0.72)
	tw.chain().tween_property(cibor_reactor_halo, "scale", Vector2(0.94,0.94), 0.72).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(cibor_reactor_halo, "modulate:a", 0.35, 0.72)

func _crear_vapor_cibor(cantidad: int) -> void:
	for i in range(cantidad):
		var v := Polygon2D.new()
		v.polygon = _crear_poligono_elipse(randf_range(16.0,34.0), randf_range(5.0,10.0))
		v.position = Vector2(randf_range(80.0, ANCHO_ARENA-80.0), randf_range(260.0,510.0))
		v.color = Color(0.70,0.90,1.0,randf_range(0.025,0.060))
		v.z_index = 1
		escenario_front.add_child(v)
		var tw := create_tween()
		tw.set_loops()
		tw.set_parallel(true)
		tw.tween_property(v, "position", v.position + Vector2(randf_range(-25.0,25.0), randf_range(-80.0,-35.0)), randf_range(2.5,4.5)).set_trans(Tween.TRANS_SINE)
		tw.tween_property(v, "scale", Vector2(1.8,1.5), randf_range(2.5,4.5))
		tw.tween_property(v, "modulate:a", 0.0, randf_range(2.5,4.5))

func _crear_arco_electrico(intensidad: float = 1.0) -> void:
	if escenario_nombre_actual != "Cibor-X" or not escenario_front:
		return
	var linea := Line2D.new()
	linea.width = randf_range(1.2, 2.8) * intensidad
	linea.default_color = Color(0.45,0.88,1.0,clampf(0.28*intensidad,0.15,0.70))
	var inicio := Vector2(randf_range(120.0, ANCHO_ARENA-120.0), randf_range(145.0,390.0))
	var fin := inicio + Vector2(randf_range(-150.0,150.0), randf_range(25.0,130.0))
	var pts := PackedVector2Array([inicio])
	for i in range(1,7):
		var t := float(i)/7.0
		pts.append(inicio.lerp(fin,t) + Vector2(randf_range(-15.0,15.0),randf_range(-9.0,9.0)))
	pts.append(fin)
	linea.points = pts
	linea.z_index = 2
	escenario_front.add_child(linea)
	var tw := create_tween()
	tw.tween_property(linea, "modulate:a", 0.0, randf_range(0.08,0.18))
	tw.tween_callback(linea.queue_free)

func _crear_burbujas_kali(c: Color, cantidad: int) -> void:
	for i in range(cantidad):
		var b := Polygon2D.new()
		var r := randf_range(3.0,8.0)
		b.polygon = _crear_poligono_elipse(r,r)
		b.position = Vector2(randf_range(20.0,ANCHO_ARENA-20.0),randf_range(500.0,620.0))
		b.color = Color(0.42,1.0,0.08,randf_range(0.07,0.18))
		b.z_index = 2
		escenario_front.add_child(b)
		_animar_burbuja_kali(b,i)

func _animar_burbuja_kali(b: Polygon2D, indice: int) -> void:
	await get_tree().process_frame
	while is_instance_valid(b):
		b.position = Vector2(randf_range(20.0, ANCHO_ARENA-20.0), randf_range(535.0,620.0))
		b.scale = Vector2.ONE
		b.modulate.a = randf_range(0.12,0.30)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(b,"position:y",b.position.y-randf_range(35.0,95.0),randf_range(1.8,3.2))
		tw.tween_property(b,"scale",Vector2(randf_range(1.4,2.1),randf_range(1.4,2.1)),randf_range(1.8,3.2))
		tw.tween_property(b,"modulate:a",0.0,randf_range(1.8,3.2))
		await tw.finished

func _crear_plumas_aethel(c: Color, cantidad: int) -> void:
	for i in range(cantidad):
		var p := Polygon2D.new()
		var l := randf_range(8.0,17.0)
		p.polygon = PackedVector2Array([Vector2(-l,0),Vector2(0,-2.0),Vector2(l,0),Vector2(0,2.0)])
		p.position = Vector2(randf_range(-120.0,ANCHO_ARENA),randf_range(90.0,500.0))
		p.rotation = randf_range(-0.8,0.8)
		p.color = Color(0.86,0.96,1.0,randf_range(0.06,0.16))
		p.z_index = 3
		escenario_front.add_child(p)
		_animar_pluma_aethel(p,i)

func _animar_pluma_aethel(p: Polygon2D, indice: int) -> void:
	await get_tree().process_frame
	while is_instance_valid(p):
		p.position = Vector2(randf_range(-150.0,-20.0),randf_range(80.0,500.0))
		p.modulate.a = randf_range(0.07,0.18)
		var destino := Vector2(ANCHO_ARENA+randf_range(80.0,220.0),p.position.y+randf_range(-80.0,110.0))
		var dur := randf_range(3.8,6.4)+float(indice%5)*0.1
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(p,"position",destino,dur).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(p,"rotation",p.rotation+randf_range(2.0,5.0),dur)
		tw.tween_property(p,"modulate:a",0.0,dur)
		await tw.finished

func _crear_rocas_magnus(c: Color, cantidad: int) -> void:
	for i in range(cantidad):
		var r := Polygon2D.new()
		var t := randf_range(3.0,7.0)
		r.polygon = PackedVector2Array([Vector2(-t,0),Vector2(-t*0.35,-t),Vector2(t*0.8,-t*0.55),Vector2(t,t*0.45),Vector2(-t*0.2,t)])
		r.position = Vector2(randf_range(40.0,ANCHO_ARENA-40.0),randf_range(420.0,555.0))
		r.color = Color(0.58,0.64,0.68,randf_range(0.08,0.18))
		r.z_index = 3
		escenario_front.add_child(r)
		var y0 := r.position.y
		var tw := create_tween()
		tw.set_loops()
		tw.tween_property(r,"position:y",y0-randf_range(8.0,22.0),randf_range(1.5,2.8)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.parallel().tween_property(r,"rotation",randf_range(-1.5,1.5),randf_range(1.5,2.8))
		tw.chain().tween_property(r,"position:y",y0,randf_range(1.5,2.8)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _crear_niebla_kai(c: Color, cantidad: int) -> void:
	for i in range(cantidad):
		var n := Polygon2D.new()
		var ancho := randf_range(120.0,260.0)
		n.polygon = PackedVector2Array([Vector2(-ancho,-8),Vector2(-ancho*0.3,-15),Vector2(ancho,-5),Vector2(ancho,7),Vector2(ancho*0.2,14),Vector2(-ancho,8)])
		n.position = Vector2(randf_range(0.0,ANCHO_ARENA),randf_range(180.0,535.0))
		n.color = Color(0.42,0.16,0.88,randf_range(0.018,0.045))
		n.z_index = 1
		escenario_front.add_child(n)
		var tw := create_tween()
		tw.set_loops()
		tw.set_parallel(true)
		tw.tween_property(n,"position:x",n.position.x+randf_range(-180.0,180.0),randf_range(5.0,9.0)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(n,"modulate:a",randf_range(0.35,0.85),randf_range(2.0,3.5)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _rafaga_escenario(intensidad: float) -> void:
	# Respuesta de ambiente a CORE/rematador/absoluto. No bloquea gameplay.
	intensidad = clampf(intensidad,0.25,2.2)
	escenario_energia_reactiva = maxf(escenario_energia_reactiva,intensidad)
	match escenario_nombre_actual:
		"Helena":
			_emitir_aliento_helena(intensidad)
			for ojo in helena_ojos:
				if is_instance_valid(ojo):
					var tw := create_tween()
					tw.tween_property(ojo,"scale",Vector2(2.8,2.0),0.08)
					tw.parallel().tween_property(ojo,"modulate:a",1.0,0.08)
					tw.chain().tween_property(ojo,"scale",Vector2.ONE,0.35)
		"Fang":
			for i in range(5+int(5*intensidad)):
				_crear_chispa_temporal(Color(1.0,0.28,0.03),Vector2(randf_range(40.0,ANCHO_ARENA-40.0),randf_range(430.0,560.0)),Vector2(randf_range(-35.0,35.0),randf_range(-120.0,-55.0)),0.30)
		"Cibor-X":
			for i in range(2+int(2*intensidad)):
				_crear_arco_electrico(0.8+intensidad*0.35)
		"Kali":
			for i in range(5+int(4*intensidad)):
				_crear_chispa_temporal(Color(0.45,1.0,0.08),Vector2(randf_range(30.0,ANCHO_ARENA-30.0),randf_range(510.0,585.0)),Vector2(randf_range(-18.0,18.0),randf_range(-75.0,-30.0)),0.22)
		"Aethel":
			escenario_impulso_aire_objetivo = randf_range(35.0,65.0) * intensidad
		"Magnus":
			for i in range(5+int(4*intensidad)):
				_crear_chispa_temporal(Color(0.55,0.66,0.74),Vector2(randf_range(80.0,ANCHO_ARENA-80.0),randf_range(530.0,560.0)),Vector2(randf_range(-45.0,45.0),randf_range(-55.0,-20.0)),0.22)
		"Kai":
			for i in range(4+int(3*intensidad)):
				_crear_chispa_temporal(Color(0.55,0.20,1.0),Vector2(randf_range(80.0,ANCHO_ARENA-80.0),randf_range(260.0,540.0)),Vector2(randf_range(-60.0,60.0),randf_range(-55.0,30.0)),0.18)

func _crear_chispa_temporal(c: Color, inicio: Vector2, delta_pos: Vector2, alpha: float) -> void:
	if not escenario_front:
		return
	var p := Polygon2D.new()
	var t := randf_range(2.0,5.0)
	p.polygon = PackedVector2Array([Vector2(0,-t),Vector2(t*0.5,0),Vector2(0,t),Vector2(-t*0.5,0)])
	p.position = inicio
	p.color = Color(c.r,c.g,c.b,alpha)
	p.z_index = 5
	escenario_front.add_child(p)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(p,"position",inicio+delta_pos,randf_range(0.35,0.75)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(p,"rotation",randf_range(-2.0,2.0),0.55)
	tw.tween_property(p,"modulate:a",0.0,randf_range(0.35,0.75))
	tw.chain().tween_callback(p.queue_free)

func _actualizar_ambiente_87(delta: float) -> void:
	escenario_ambiente_reloj -= delta
	escenario_energia_reactiva = move_toward(escenario_energia_reactiva,0.0,0.75*delta)
	if escenario_ambiente_reloj > 0.0:
		return
	match escenario_nombre_actual:
		"Helena":
			_emitir_aliento_helena(randf_range(0.45,0.75))
			escenario_ambiente_intervalo = randf_range(2.8,4.8)
		"Fang":
			for i in range(3):
				_crear_chispa_temporal(Color(1.0,0.30,0.04),Vector2(randf_range(30.0,ANCHO_ARENA-30.0),randf_range(470.0,560.0)),Vector2(randf_range(-18.0,18.0),randf_range(-85.0,-35.0)),0.16)
			escenario_ambiente_intervalo = randf_range(0.55,1.05)
		"Cibor-X":
			_crear_arco_electrico(randf_range(0.55,0.90))
			escenario_ambiente_intervalo = randf_range(0.75,1.55)
		"Kali":
			_crear_chispa_temporal(Color(0.45,1.0,0.08),Vector2(randf_range(20.0,ANCHO_ARENA-20.0),randf_range(540.0,585.0)),Vector2(randf_range(-8.0,8.0),randf_range(-40.0,-18.0)),0.12)
			escenario_ambiente_intervalo = randf_range(0.65,1.20)
		"Aethel":
			escenario_impulso_aire_objetivo = randf_range(-16.0,24.0)
			escenario_ambiente_intervalo = randf_range(1.8,3.2)
		"Magnus":
			if randf() < 0.50:
				_crear_chispa_temporal(Color(0.50,0.64,0.72),Vector2(randf_range(80.0,ANCHO_ARENA-80.0),randf_range(535.0,558.0)),Vector2(randf_range(-12.0,12.0),randf_range(-24.0,-10.0)),0.10)
			escenario_ambiente_intervalo = randf_range(1.5,2.8)
		_:
			escenario_ambiente_intervalo = randf_range(1.8,3.0)
	escenario_ambiente_reloj = escenario_ambiente_intervalo

func _crear_luchador(nombre: String) -> Fighter:
	match nombre:
		"Kai": return Kai.new()
		"Fang": return Fang.new()
		"Cibor-X": return CiborX.new()
		"Kali": return Kali.new()
		"Aethel": return Aethel.new()
		"Magnus": return Magnus.new()
		"Helena": return Helena.new()
		"Jester": return Jester.new()
		"Varkhos": return Varkhos.new()
		_: return Kai.new()

func _conectar_luchador(personaje: Fighter, es_jugador: bool) -> void:
	personaje.controlado_por_jugador = es_jugador
	personaje.impacto_detallado.connect(_al_impactar_detallado.bind(personaje))
	personaje.ataque_lanzado.connect(_al_ataque_lanzado.bind(personaje))
	personaje.aterrizaje_hecho.connect(_al_aterrizaje_hecho)
	personaje.core_listo.connect(_al_core_listo.bind(personaje))
	personaje.fase_activada.connect(_al_activar_fase.bind(personaje))
	personaje.rematador_iniciado.connect(_al_rematador_iniciado.bind(personaje))
	personaje.rematador_conectado.connect(_al_rematador.bind(personaje))
	personaje.finalizacion_absoluta.connect(_al_finalizacion_absoluta.bind(personaje))
	personaje.recarga_iniciada.connect(_al_recarga_iniciada.bind(personaje))
	personaje.salto_hecho.connect(_al_saltar)
	if es_jugador:
		personaje.derrotado.connect(_al_kai_derrotado)
	else:
		personaje.derrotado.connect(_al_rival_derrotado)

func _crear_personajes() -> void:
	# FASE 89: cuando venimos del menú, el combate respeta la selección y el
	# progreso de Arcade. En modo debug conserva Kai vs Cibor-X como respaldo.
	var nombre_jugador := "Kai"
	var nombre_rival := "Cibor-X"
	var nombre_escenario := "Cibor-X"
	var estado = get_node_or_null("/root/GameState")
	if estado and estado.flujo_menu_activo:
		nombre_jugador = estado.personaje_jugador
		nombre_rival = estado.rival_actual
		nombre_escenario = estado.escenario_actual

	kai = _crear_luchador(nombre_jugador)
	kai.position = POS_KAI
	add_child(kai)

	rival = _crear_luchador(nombre_rival)
	rival.position = POS_RIVAL
	add_child(rival)

	kai.objetivo = rival
	rival.objetivo = kai
	_conectar_luchador(kai, true)
	_conectar_luchador(rival, false)
	_actualizar_fondo(nombre_escenario if nombre_escenario != "" else rival.nombre_luchador)

func _al_impactar(fuerza: float) -> void:
	# FASE 77: golpes pesados también repercuten mejor en el escenario y en
	# el piso, no solo en los cuerpos.
	var intensidad: float = clampf(fuerza / 24.0, 0.0, 1.0)
	escenario_flash_energia = maxf(escenario_flash_energia, 0.02 + intensidad * 0.05)
	var shake: float = lerpf(1.2, 7.0, intensidad)
	var duracion_shake: float = lerpf(0.055, 0.115, intensidad)
	sacudir_camara(shake, duracion_shake)
	# En vez de vibrar mucho, la cámara hace un micro punch-in hacia el
	# centro real de los dos cuerpos durante una fracción de segundo.
	if is_instance_valid(kai) and is_instance_valid(rival):
		foco_impacto_camara_x = (kai.global_position.x + rival.global_position.x) * 0.5
		foco_impacto_timer = 0.10 + intensidad * 0.06
		pulso_cam_combate = maxf(pulso_cam_combate, intensidad)
	if fuerza >= 10.0:
		_respuesta_piso_al_impacto()
		_reaccion_ambiente_al_impacto(fuerza)
		escenario_impulso_aire_objetivo = randf_range(-22.0, 22.0) * intensidad
		_crear_estallido_ambiental(intensidad)
		if fuerza >= 18.0:
			_rafaga_escenario(0.30 + intensidad * 0.22)
	if fuerza >= 10.0:
		var pausa_real: float = lerpf(0.025, 0.052, intensidad)
		var escala_tiempo: float = lerpf(0.16, 0.07, intensidad)
		_congelar_un_instante(pausa_real, escala_tiempo)

func _al_impactar_detallado(fuerza: float, tipo: String, bloqueado: bool, victima: Fighter) -> void:
	_al_impactar(fuerza)
	var intensidad: float = clampf(fuerza / 24.0, 0.0, 1.0)
	_crear_onda_impacto_premium(tipo, bloqueado, intensidad)

	if bloqueado:
		# El bloqueo conserva su sonido seco específico; no usa ninguna palmada.
		_reproducir_sfx(SND_REAL_BLOQUEO_A, -1.0, randf_range(0.97, 1.035))
		sacudir_camara(2.8 + intensidad * 1.8, 0.07)
		return

	# El signal lo emite quien recibe el impacto, así que obtenemos al atacante
	# para poder aplicar identidad sonora (especialmente Cibor-X).
	var atacante: Fighter = null
	if is_instance_valid(kai) and is_instance_valid(rival):
		atacante = rival if victima == kai else kai

	# Helena: por ahora existe un único grito propio. Priorizamos el contacto
	# real para que la voz se sienta asociada a una pegada que efectivamente entró.
	if is_instance_valid(atacante) and atacante.nombre_luchador == "Helena":
		var helena_fuerte: bool = tipo in ["especial", "rematador", "absoluto"] or fuerza >= 18.0
		_intentar_grito_ataque(atacante, helena_fuerte, 0.72 if helena_fuerte else 0.34)

	match tipo:
		"punetazo":
			var stream: AudioStream = _sfx_puno_real(fuerza)
			var vol_puno: float = lerpf(-2.2, 0.6, intensidad)
			_reproducir_sfx(stream, vol_puno, randf_range(0.965, 1.035))
			# Capa subgrave corta: da cuerpo al contacto sin convertirlo en explosión.
			_reproducir_sfx(SND_THUMP_GRAVE, lerpf(-9.0, -4.2, intensidad), randf_range(0.90, 1.00))
			if intensidad > 0.55:
				_destello_pantalla(Color(1.0, 1.0, 1.0), 0.05 + intensidad * 0.06, 0.14)
		"patada":
			var stream_patada: AudioStream = _sfx_patada_real(fuerza)
			var vol_patada: float = lerpf(-2.0, 0.8, intensidad)
			_reproducir_sfx(stream_patada, vol_patada, randf_range(0.95, 1.025))
			_reproducir_sfx(SND_THUMP_GRAVE, lerpf(-7.0, -2.8, intensidad), randf_range(0.86, 0.96))
			sacudir_camara(5.0 + intensidad * 3.0, 0.11)
			if intensidad > 0.45:
				_destello_pantalla(Color(1.0, 1.0, 1.0), 0.06 + intensidad * 0.08, 0.16)
		"especial":
			_reproducir_sfx(_sfx_pesado_real(), 0.0, randf_range(0.90, 0.99))
			_reproducir_sfx(SND_THUMP_GRAVE, -2.0, 0.82)
			_reproducir_sfx(SND_ESPECIAL, -7.0, randf_range(0.96, 1.04))
			sacudir_camara(10.0, 0.18)
			var color_especial := Color(1.0, 0.92, 0.6)
			if is_instance_valid(atacante):
				color_especial = atacante.color_energia_poder()
			_destello_pantalla(color_especial, 0.30, 0.30)
		"rematador":
			_reproducir_sfx(SND_REMATADOR_IMPACTO, 0.5, randf_range(0.96, 1.02))
			_reproducir_sfx(_sfx_pesado_real(), -0.5, randf_range(0.86, 0.95))
			_reproducir_sfx(SND_THUMP_GRAVE, -0.8, 0.74)
			sacudir_camara(19.0, 0.34)
			var color_remate := Color(1.0, 0.85, 0.35)
			if is_instance_valid(atacante):
				color_remate = atacante.color_energia_poder().lightened(0.25)
			_destello_pantalla(color_remate, 0.52, 0.42)
		"absoluto":
			_reproducir_sfx(SND_ABSOLUTO_IMPACTO, 1.5, 1.0)
			_reproducir_sfx(_sfx_pesado_real(), -0.2, 0.84)
			_reproducir_sfx(SND_THUMP_GRAVE, 0.0, 0.66)
			_reproducir_sfx(SND_REMATADOR_IMPACTO, -2.0, 0.72)
			sacudir_camara(30.0, 0.52)
			_destello_pantalla(Color(1.0, 1.0, 1.0), 0.85, 0.62)
		_:
			_reproducir_sfx(_sfx_puno_real(fuerza), -1.8, randf_range(0.97, 1.03))
			_reproducir_sfx(SND_THUMP_GRAVE, -7.0, 0.94)

	# Identidad robótica Cibor-X: acentos eléctricos cortos en contacto y
	# blaster dedicado en sus poderes. No invade los sonidos de otros luchadores.
	if is_instance_valid(atacante) and atacante.nombre_luchador == "Cibor-X":
		if tipo in ["especial", "rematador", "absoluto"]:
			_reproducir_sfx(SND_CIBOR_BLASTER, -4.5 if tipo == "especial" else -2.5, randf_range(0.94, 1.02))
			if tipo != "especial":
				_reproducir_sfx(SND_CIBOR_STUN_BURST, -9.0, randf_range(0.93, 1.03))
		elif fuerza >= 12.0 and randf() < 0.28:
			_reproducir_sfx(SND_CIBOR_STUN_BURST, -12.0, randf_range(0.96, 1.05))

	# Cibor-X también responde como cuerpo mecánico: cuando ÉL recibe un impacto
	# se suma un golpe metálico corto debajo de la pegada principal.
	if is_instance_valid(victima) and victima.nombre_luchador == "Cibor-X":
		var vol_metal: float = -7.5 if fuerza < 16.0 else -4.8
		_reproducir_sfx(SND_CIBOR_GOLPE_METAL_REAL, vol_metal, randf_range(0.94, 1.04))

	# La voz pertenece al personaje que RECIBE el golpe. No se dispara en
	# bloqueo y tiene cooldown/probabilidad para que los combos no sean ruido.
	_reaccion_vocal_golpe(victima, fuerza, tipo)

func _al_ataque_lanzado(tipo: String, furia: bool, atacante: Fighter) -> void:
	var volumen_extra: float = 2.0 if furia else 0.0
	if tipo == "patada":
		_reproducir_sfx(SND_WHOOSH_PATADA, -11.0 + volumen_extra, randf_range(0.92, 1.08))
	else:
		_reproducir_sfx(SND_WHOOSH_PUNO, -14.0 + volumen_extra, randf_range(0.94, 1.10))
	# Cibor-X suma una descarga corta al movimiento en Furia, a volumen bajo,
	# para vender servo/electricidad sin tapar el whoosh ni el golpe.
	if is_instance_valid(atacante) and atacante.nombre_luchador == "Cibor-X" and furia and randf() < 0.24:
		_reproducir_sfx(SND_CIBOR_STUN_BURST, -15.0, randf_range(0.98, 1.06))
	# Grito breve solo ocasional; en Furia aparece un poco más.
	_intentar_grito_ataque(atacante, false, 0.18 if furia else 0.06)

func _al_aterrizaje_hecho(fuerza: float, derribo: bool) -> void:
	if derribo:
		_reproducir_sfx(SND_CAIDA_FUERTE, -2.0, randf_range(0.88, 1.02))
		sacudir_camara(clampf(fuerza / 55.0, 5.0, 10.0), 0.13)
	else:
		var vol: float = clampf(-13.0 + fuerza / 42.0, -13.0, -7.0)
		_reproducir_sfx(SND_ATERRIZAJE, vol, randf_range(0.93, 1.08))

func _al_core_listo(personaje: Fighter) -> void:
	_reproducir_sfx(SND_CORE_LISTO, -2.5, 1.0)
	_reaccion_escenario_poder(personaje, 0.34)

func _al_activar_fase(personaje: Fighter) -> void:
	sacudir_camara(10.0, 0.25)
	_reaccion_escenario_poder(personaje, 1.0)
	_reproducir_sfx(_sfx_elemento(personaje), -1.5, 1.0)
	# Audio nuevo de poder: se reinicia en cada activación CORE para que el
	# especial siempre tenga una entrada sonora clara y consistente.
	if audio_poder_final:
		audio_poder_final.stop()
		audio_poder_final.pitch_scale = 1.0
		audio_poder_final.play()

func _al_rematador_iniciado(personaje: Fighter) -> void:
	_reaccion_escenario_poder(personaje, 1.05)
	_intentar_grito_ataque(personaje, false, 0.58)
	_reproducir_sfx(_sfx_elemento(personaje), -4.0, randf_range(0.88, 0.98))
	_reproducir_sfx(SND_WHOOSH_PATADA, -8.0, 0.72)
	sacudir_camara(6.0, 0.14)

func _al_rematador(personaje: Fighter) -> void:
	sacudir_camara(16.0, 0.35)
	_reaccion_escenario_poder(personaje, 1.35)

# Beat antes del combo automático (cargas 2 y 3): fighter.gd ya puso al
# personaje en su pose de recarga y avisa acá. El fondo y el rival se
# atenúan, la cámara hace zoom sobre el personaje, y en la carga 3
# (Absoluto) todo corre en cámara lenta -- el único brillo en pantalla es
# el del luchador cargando energía (ese brillo lo maneja fighter.gd).
func _al_recarga_iniciada(camara_lenta: bool, personaje: Fighter) -> void:
	if not is_instance_valid(personaje):
		return
	_reaccion_escenario_poder(personaje, 0.85 if camara_lenta else 0.58)
	_reproducir_sfx(SND_CORE_CARGA_ABSOLUTA if camara_lenta else SND_CORE_CARGA, -2.5 if camara_lenta else -4.0, 1.0)
	if personaje.nombre_luchador == "Cibor-X":
		_reproducir_sfx(SND_CIBOR_STUN, -12.0 if camara_lenta else -15.0, 1.0)
	# Kai/Fang/Aethel/Magnus usan una voz dedicada de carga tanto en CORE 2
	# como en CORE 3. Si ya sonó esa voz, evitamos apilar encima el grito genérico.
	var uso_voz_recarga: bool = _reproducir_voz_recarga(personaje, camara_lenta)
	if camara_lenta and not uso_voz_recarga:
		_intentar_grito_ataque(personaje, true, 0.72)
	var duracion: float = 1.75 if camara_lenta else 1.15
	var otro: Fighter = rival if personaje == kai else kai
	_oscurecer_escenario(0.72 if camara_lenta else 0.58, duracion, otro)
	# La recarga tiene que LEERSE: acercamos la cámara al personaje, pero
	# manteniendo al rival todavía dentro de cuadro. Nada de alejar el zoom.
	_zoom_dramatico(personaje, 1.24 if camara_lenta else 1.18, 0.14, duracion - 0.18, true)
	sacudir_camara(4.0, 0.16)
	if camara_lenta and not congelando_ko:
		Engine.time_scale = 0.32
		var t := get_tree().create_timer(duracion, true, false, true)
		t.timeout.connect(func():
			if not congelando_ko:
				Engine.time_scale = 1.0
		)

# Atenúa fondo, capas del escenario y al rival (nunca al que está cargando)
# para que la pose de recarga sea la que brille en pantalla.
func _oscurecer_escenario(fuerza: float, tiempo_total: float, personaje_a_atenuar: Fighter) -> void:
	var tw := create_tween()
	tw.set_parallel(true)
	var tono_fondo := Color(1.0 - fuerza, 1.0 - fuerza, 1.0 - fuerza, 1.0)
	var tono_suelo := Color(1.0 - fuerza * 0.75, 1.0 - fuerza * 0.75, 1.0 - fuerza * 0.75, 1.0)
	if fondo_sprite:
		tw.tween_property(fondo_sprite, "modulate", tono_fondo, 0.18)
	if escenario_vivo:
		tw.tween_property(escenario_vivo, "modulate", tono_fondo, 0.18)
	if ambiente_particulas:
		tw.tween_property(ambiente_particulas, "modulate", tono_fondo, 0.18)
	if ambiente_particulas_delante:
		tw.tween_property(ambiente_particulas_delante, "modulate", tono_fondo, 0.18)
	if piso_overlay:
		tw.tween_property(piso_overlay, "modulate", tono_suelo, 0.18)
	if is_instance_valid(personaje_a_atenuar) and personaje_a_atenuar.sprite:
		var tono: float = 1.0 - fuerza * 0.90
		tw.tween_property(personaje_a_atenuar.sprite, "modulate", Color(tono, tono, tono, 1.0), 0.18)
	tw.chain().tween_interval(maxf(tiempo_total - 0.45, 0.05))
	tw.chain().set_parallel(true)
	if fondo_sprite:
		tw.tween_property(fondo_sprite, "modulate", Color.WHITE, 0.32)
	if escenario_vivo:
		tw.tween_property(escenario_vivo, "modulate", Color.WHITE, 0.32)
	if ambiente_particulas:
		tw.tween_property(ambiente_particulas, "modulate", Color.WHITE, 0.32)
	if ambiente_particulas_delante:
		tw.tween_property(ambiente_particulas_delante, "modulate", Color.WHITE, 0.32)
	if piso_overlay:
		tw.tween_property(piso_overlay, "modulate", Color.WHITE, 0.32)
	if is_instance_valid(personaje_a_atenuar) and personaje_a_atenuar.sprite:
		tw.tween_property(personaje_a_atenuar.sprite, "modulate", Color.WHITE, 0.32)

func _reaccion_escenario_poder(personaje: Fighter, intensidad: float) -> void:
	if not is_instance_valid(personaje):
		return
	var color: Color = personaje.color_fase
	escenario_effect_color = color
	escenario_flash_energia = maxf(escenario_flash_energia, clampf(0.10 * intensidad, 0.0, 0.22))
	_rafaga_escenario(intensidad)
	if fondo_material:
		fondo_material.set_shader_parameter("pulse_strength", 0.030 * intensidad)
		fondo_material.set_shader_parameter("energy_flash", escenario_flash_energia)
	if luz_impacto:
		luz_impacto.position = personaje.global_position + Vector2(personaje.mirando * 35.0, -80.0)
		luz_impacto.color = color.lerp(Color.WHITE, 0.50)
		luz_impacto.energy = 1.35 * intensidad
	if piso_overlay:
		var onda := Polygon2D.new()
		onda.polygon = _crear_poligono_elipse(26.0, 5.0)
		onda.color = Color(color.r, color.g, color.b, 0.16)
		onda.position = Vector2(personaje.global_position.x, SUELO_Y - 2.0)
		onda.z_index = 3
		piso_overlay.add_child(onda)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(onda, "scale", Vector2(4.8 * intensidad, 1.8 * intensidad), 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(onda, "modulate:a", 0.0, 0.34)
		tw.chain().tween_callback(onda.queue_free)

func _crear_estallido_ambiental(intensidad: float) -> void:
	if not escenario_front or not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	var centro: Vector2 = (kai.global_position + rival.global_position) * 0.5
	centro.y -= 72.0
	var cantidad: int = 4 + int(round(intensidad * 5.0))
	for i in range(cantidad):
		var mota := Polygon2D.new()
		var tam: float = randf_range(1.8, 4.2)
		if escenario_tipo == "tierra":
			tam *= 1.35
		mota.polygon = PackedVector2Array([
			Vector2(-tam, 0.0), Vector2(0.0, -tam),
			Vector2(tam, 0.0), Vector2(0.0, tam)
		])
		var c: Color = escenario_effect_color.lerp(Color.WHITE, 0.28)
		mota.color = Color(c.r, c.g, c.b, 0.22 + intensidad * 0.15)
		mota.position = centro + Vector2(randf_range(-20.0, 20.0), randf_range(-18.0, 18.0))
		mota.rotation = randf_range(0.0, TAU)
		mota.z_index = 5
		escenario_front.add_child(mota)
		var direccion: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-0.9, 0.45)).normalized()
		var destino: Vector2 = mota.position + direccion * randf_range(30.0, 82.0) * (0.6 + intensidad)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(mota, "position", destino, 0.22 + intensidad * 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(mota, "rotation", mota.rotation + randf_range(-2.2, 2.2), 0.28)
		tw.tween_property(mota, "modulate:a", 0.0, 0.28)
		tw.chain().tween_callback(mota.queue_free)

func _reaccion_ambiente_al_impacto(fuerza: float) -> void:
	var factor: float = clampf(fuerza / 220.0, 0.25, 1.0)
	if ambiente_particulas_delante:
		for nodo in ambiente_particulas_delante.get_children():
			if nodo is Sprite2D:
				var tw := create_tween()
				tw.tween_property(nodo, "position:x", nodo.position.x + randf_range(-14.0, 14.0) * factor, 0.10)
	# Respuesta visual del mundo: impactos fuertes levantan una onda de polvo
	# y luz en el piso. Es corta para no ensuciar la escena.
	if factor > 0.55 and piso_overlay:
		var onda_suelo := Polygon2D.new()
		onda_suelo.polygon = _crear_poligono_elipse(18.0, 4.0)
		onda_suelo.position = Vector2(ANCHO_ARENA * 0.5, SUELO_Y - 2.0)
		onda_suelo.color = Color(1.0, 0.94, 0.82, 0.10 * factor)
		onda_suelo.z_index = 3
		piso_overlay.add_child(onda_suelo)
		var tw_onda := create_tween()
		tw_onda.set_parallel(true)
		tw_onda.tween_property(onda_suelo, "scale", Vector2(2.8 + factor * 1.8, 1.0), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw_onda.tween_property(onda_suelo, "modulate:a", 0.0, 0.20)
		tw_onda.chain().tween_callback(onda_suelo.queue_free)

func _al_saltar() -> void:
	audio_salto.pitch_scale = randf_range(0.95, 1.08)
	audio_salto.play()

func sacudir_camara(fuerza: float, duracion: float) -> void:
	shake_fuerza = max(shake_fuerza, fuerza)
	shake_tiempo = max(shake_tiempo, duracion)

# Zoom cinematográfico hacia el personaje que lanza el poder (no al punto
# medio: eso lo hacía ver descuadrado). El objetivo se corre un poco hacia
# donde está mirando, así el rival -que está ahí cerca por el combo
# automático- entra en cuadro igual. En Godot Camera2D un zoom MAYOR a 1 acerca la cámara.
# El valor se limita para que ambos luchadores sigan dentro del cuadro. Vuelve sola a la
# cámara normal después.
func _zoom_dramatico(personaje: Fighter, nivel: float, entrada: float, sostener: float, mantener_dos_luchadores: bool = true) -> void:
	if not camara or not is_instance_valid(personaje):
		return
	camara_cinematica_activa = true
	var centro: Vector2 = personaje.global_position + Vector2(personaje.mirando * 60.0, -100.0)
	var nivel_final: float = nivel
	if mantener_dos_luchadores:
		var datos := _objetivo_camara_cinematica(personaje)
		centro = datos.get("centro", centro)
		nivel_final = minf(nivel, float(datos.get("zoom", nivel)))
	if tween_camara_cinematica and is_instance_valid(tween_camara_cinematica):
		tween_camara_cinematica.kill()
	tween_camara_cinematica = create_tween()
	tween_camara_cinematica.set_parallel(true)
	tween_camara_cinematica.tween_property(camara, "zoom", Vector2(nivel_final, nivel_final), entrada)
	tween_camara_cinematica.tween_property(camara, "position", centro, entrada)
	tween_camara_cinematica.chain().tween_interval(sostener)
	tween_camara_cinematica.chain().set_parallel(true)
	tween_camara_cinematica.tween_property(camara, "zoom", Vector2.ONE, 0.4)
	tween_camara_cinematica.tween_property(camara, "position", Vector2(ANCHO_ARENA / 2.0, 360.0), 0.4)
	tween_camara_cinematica.chain().tween_callback(func():
		camara_cinematica_activa = false
		tween_camara_cinematica = null
	)

func _objetivo_camara_cinematica(personaje: Fighter) -> Dictionary:
	var foco_atacante: Vector2 = personaje.global_position + Vector2(personaje.mirando * 44.0, -112.0)
	var centro: Vector2 = foco_atacante
	var zoom_sugerido: float = 1.18
	var otro: Fighter = rival if personaje == kai else kai
	if is_instance_valid(otro):
		var foco_rival: Vector2 = otro.global_position + Vector2(-personaje.mirando * 26.0, -90.0)
		var medio: Vector2 = (foco_atacante + foco_rival) * 0.5
		# Sesgo a favor del atacante: el zoom sigue sintiéndose "sobre el
		# personaje", pero el rival no se sale del encuadre.
		centro = medio.lerp(foco_atacante, 0.30)
		var separacion: float = absf(foco_atacante.x - foco_rival.x)
		zoom_sugerido = clampf(1.22 - separacion / 4200.0, 1.10, 1.22)
	centro.x = clampf(centro.x, 380.0, ANCHO_ARENA - 380.0)
	centro.y = clampf(centro.y, 210.0, 410.0)
	return {"centro": centro, "zoom": zoom_sugerido}

func _congelar_un_instante(duracion_real: float, escala: float = 0.05) -> void:
	if congelando_ko:
		return
	Engine.time_scale = escala
	var t := get_tree().create_timer(duracion_real, true, false, true)
	t.timeout.connect(func():
		if not congelando_ko:
			Engine.time_scale = 1.0
	)

# --- Sistema de rondas ---

func _al_kai_derrotado() -> void:
	if not ronda_activa:
		return
	await _reproducir_ko_lento(kai)
	_procesar_fin_de_ronda(rival, kai)

func _al_rival_derrotado() -> void:
	if not ronda_activa:
		return
	await _reproducir_ko_lento(rival)
	_procesar_fin_de_ronda(kai, rival)

# El remate ABSOLUTO (3ra carga de barra en la pelea) termina la PARTIDA
# entera ahí mismo -- ya no hay barra de vida que decida nada, gana quien
# llega primero acá. Pone ronda_activa en false de entrada para que, si
# el golpe también dispara el "derrotado" normal del perdedor,
# _procesar_fin_de_ronda no haga nada (el guard de ahí ya corta solo).
# Este es el ÚNICO momento de toda la pelea con zoom + cámara lenta.
# El remate ABSOLUTO (3ra carga de barra en la pelea) termina la PARTIDA
# entera ahí mismo -- ya no hay barra de vida que decida nada, gana quien
# llega primero acá. Pone ronda_activa en false de entrada para que, si
# el golpe también dispara el "derrotado" normal del perdedor,
# _procesar_fin_de_ronda no haga nada (el guard de ahí ya corta solo).
# Este es el ÚNICO momento de toda la pelea con zoom + cámara lenta.
func _al_finalizacion_absoluta(personaje: Fighter) -> void:
	if not ronda_activa:
		return
	_reaccion_escenario_poder(personaje, 1.8)
	ronda_activa = false
	var perdedor: Fighter = rival if personaje == kai else kai

	congelando_ko = true
	sacudir_camara(26.0, 0.5)
	_zoom_dramatico(personaje, 1.22, 0.22, 2.6, true)
	_reproducir_sfx(_sfx_elemento(personaje), -1.0, 0.84)
	# Grito propio de Aethel en SU poder final -- capa extra sobre el
	# elemento (viento), no lo reemplaza.
	if personaje.nombre_luchador == "Aethel":
		_reproducir_sfx(SND_AETHEL_PODER_FINAL, -2.0, randf_range(0.97, 1.03))
	Engine.time_scale = 0.18

	# FASE 83: el rival NO reacciona mientras el póster está visible. El
	# Fighter aplica el vuelo/derribo recién al terminar su arte cinematográfico.
	await get_tree().create_timer(3.15, true, false, true).timeout
	# Dejamos un instante para leer el vuelo final y luego fijamos el K.O.
	Engine.time_scale = 0.42
	await get_tree().create_timer(0.70, true, false, true).timeout
	perdedor.vida = 0.0
	perdedor._derrotado()
	await get_tree().create_timer(0.65, true, false, true).timeout

	Engine.time_scale = 1.0
	congelando_ko = false

	# FASE 85: después de leer la caída definitiva, el ganador tiene su beat
	# de victoria. Si más adelante agregamos victoria.png por personaje,
	# Fighter ya tiene el hook; por ahora usa Furia/parado como respaldo.
	personaje.mostrar_pose_victoria()
	_zoom_dramatico(personaje, 1.18, 0.22, 2.9, false)
	_reaccion_escenario_poder(personaje, 0.72)
	if perdedor.sprite:
		var tw_perdedor := create_tween()
		tw_perdedor.tween_property(perdedor.sprite, "modulate", Color(0.48, 0.48, 0.52, 1.0), 0.28)

	rondas_kai = 3 if personaje == kai else 0
	rondas_rival = 3 if personaje == rival else 0
	_actualizar_marcador()
	etiqueta_resultado.text = "¡%s GANA LA PARTIDA!" % personaje.nombre_luchador.to_upper()
	audio_victoria.play()
	var t := get_tree().create_timer(9.20)
	t.timeout.connect(_finalizar_partida_flujo.bind(personaje))

func _reproducir_ko_lento(perdedor: Fighter = null) -> void:
	congelando_ko = true
	sacudir_camara(18.0, 0.4)
	audio_ko.play()
	# Cibor-X tiene su propio sonido de "apagado" al perder, en capa
	# aparte del KO genérico (no lo reemplaza).
	if is_instance_valid(perdedor) and perdedor.nombre_luchador == "Cibor-X":
		_reproducir_sfx(SND_CIBOR_MUERTE, -3.0, 1.0)
	Engine.time_scale = 0.25
	await get_tree().create_timer(1.1, true, false, true).timeout
	Engine.time_scale = 1.0
	congelando_ko = false

func _procesar_fin_de_ronda(ganador: Fighter, _perdedor: Fighter) -> void:
	if not ronda_activa:
		return
	ronda_activa = false

	if ganador == kai:
		rondas_kai += 1
	else:
		rondas_rival += 1
	_actualizar_marcador()

	if rondas_kai >= RONDAS_PARA_GANAR or rondas_rival >= RONDAS_PARA_GANAR:
		etiqueta_resultado.text = "¡%s GANA LA PARTIDA!" % ganador.nombre_luchador.to_upper()
		audio_victoria.play()
		var t := get_tree().create_timer(9.20)
		t.timeout.connect(_finalizar_partida_flujo.bind(ganador))
	else:
		etiqueta_resultado.text = "K.O. — %s gana la ronda" % ganador.nombre_luchador.to_upper()
		var t := get_tree().create_timer(2.2)
		t.timeout.connect(_siguiente_ronda)

func _siguiente_ronda() -> void:
	kai.position = POS_KAI
	rival.position = POS_RIVAL
	kai.reiniciar_para_ronda()
	rival.reiniciar_para_ronda()
	ronda_activa = true
	etiqueta_resultado.text = "¡Ronda!"
	var t := get_tree().create_timer(0.9)
	t.timeout.connect(func(): etiqueta_resultado.text = "")

func _finalizar_partida_flujo(ganador: Fighter) -> void:
	var estado = get_node_or_null("/root/GameState")
	if estado and estado.flujo_menu_activo:
		estado.registrar_resultado(ganador == kai)
		get_tree().change_scene_to_file("res://scenes/Resultado.tscn")
		return
	_reiniciar_partida()

func _reiniciar_partida() -> void:
	rondas_kai = 0
	rondas_rival = 0
	_actualizar_marcador()
	# Partida nueva: se resetea el progreso de cargas de barra de los dos.
	kai.veces_fase_absoluta = 0
	rival.veces_fase_absoluta = 0
	_siguiente_ronda()

func _actualizar_marcador() -> void:
	etiqueta_marcador.text = "CORE RACE"

func _cambiar_rival(nuevo: Fighter) -> void:
	if is_instance_valid(rival):
		rival.queue_free()
	rival = nuevo
	rival.position = POS_RIVAL
	add_child(rival)
	kai.objetivo = rival
	rival.objetivo = kai
	_conectar_luchador(rival, false)
	etiqueta_rival.text = rival.nombre_luchador + " (IA)"
	barra_poder_rival.color = rival.color_base.lightened(0.2)
	fondo_rival.color = rival.color_base.darkened(0.75)
	_actualizar_fondo(rival.nombre_luchador)

	rondas_kai = 0
	rondas_rival = 0
	_actualizar_marcador()
	ronda_activa = true
	etiqueta_resultado.text = ""
	kai.veces_fase_absoluta = 0
	rival.veces_fase_absoluta = 0
	kai.reiniciar_para_ronda()
	rival.reiniciar_para_ronda()
	kai.position = POS_KAI
	rival.position = POS_RIVAL

func _cambiar_jugador(nuevo: Fighter) -> void:
	var nombre_nuevo := nuevo.nombre_luchador
	if is_instance_valid(kai):
		kai.queue_free()
	kai = nuevo
	kai.position = POS_KAI
	add_child(kai)

	# Nunca dejamos al mismo personaje en ambos lados: si el jugador elige
	# al rival actual, el rival salta al siguiente del roster.
	if is_instance_valid(rival) and rival.nombre_luchador == nombre_nuevo:
		var reemplazo: Fighter
		match nombre_nuevo:
			"Kai": reemplazo = Fang.new()
			"Fang": reemplazo = CiborX.new()
			"Cibor-X": reemplazo = Kali.new()
			"Kali": reemplazo = Aethel.new()
			"Aethel": reemplazo = Magnus.new()
			"Magnus": reemplazo = Helena.new()
			_: reemplazo = Kai.new()
		_cambiar_rival(reemplazo)

	kai.objetivo = rival
	rival.objetivo = kai
	_conectar_luchador(kai, true)
	if seleccion_jugador_label:
		seleccion_jugador_label.text = "JUGADOR: " + kai.nombre_luchador
	if etiqueta_jugador:
		etiqueta_jugador.text = kai.nombre_luchador
	_actualizar_fondo(rival.nombre_luchador)
	rondas_kai = 0
	rondas_rival = 0
	kai.veces_fase_absoluta = 0
	rival.veces_fase_absoluta = 0
	kai.reiniciar_para_ronda()
	rival.reiniciar_para_ronda()
	kai.position = POS_KAI
	rival.position = POS_RIVAL
	ronda_activa = true
	etiqueta_resultado.text = ""

func _crear_ui() -> void:
	var capa := CanvasLayer.new()
	add_child(capa)

	etiqueta_jugador = Label.new()
	etiqueta_jugador.text = kai.nombre_luchador.to_upper()
	etiqueta_jugador.position = Vector2(40, 4)
	capa.add_child(etiqueta_jugador)

	# Ya no hay barra de vida: la que importa ahora es la de PODER, porque
	# quien llega primero a la 3ra carga (el remate absoluto) gana la
	# partida directo, sin importar los golpes que haya recibido.
	var fondo_poder_kai := ColorRect.new()
	fondo_poder_kai.color = Color(0.25, 0.2, 0.05)
	fondo_poder_kai.position = Vector2(40, 30)
	fondo_poder_kai.size = Vector2(ANCHO_BARRA, 20)
	capa.add_child(fondo_poder_kai)

	barra_poder_kai = ColorRect.new()
	barra_poder_kai.color = Color(0.95, 0.8, 0.2)
	barra_poder_kai.position = Vector2(40, 30)
	barra_poder_kai.size = Vector2(0, 20)
	capa.add_child(barra_poder_kai)

	etiqueta_cargas_kai = Label.new()
	etiqueta_cargas_kai.text = "CORE 0/3"
	etiqueta_cargas_kai.position = Vector2(40, 54)
	capa.add_child(etiqueta_cargas_kai)
	cores_kai = _crear_indicadores_core(capa, Vector2(125, 56), kai.color_base)

	etiqueta_poder_listo = Label.new()
	etiqueta_poder_listo.text = ""
	etiqueta_poder_listo.position = Vector2(40, 78)
	capa.add_child(etiqueta_poder_listo)

	etiqueta_combo = Label.new()
	etiqueta_combo.text = ""
	etiqueta_combo.position = Vector2(560, 150)
	capa.add_child(etiqueta_combo)

	etiqueta_marcador = Label.new()
	etiqueta_marcador.text = "CORE RACE"
	etiqueta_marcador.position = Vector2(560, 30)
	capa.add_child(etiqueta_marcador)

	etiqueta_resultado = Label.new()
	etiqueta_resultado.text = ""
	etiqueta_resultado.add_theme_font_size_override("font_size", 40)
	etiqueta_resultado.position = Vector2(300, 200)
	etiqueta_resultado.size = Vector2(680, 60)
	etiqueta_resultado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	capa.add_child(etiqueta_resultado)

	var fondo_poder_rival := ColorRect.new()
	fondo_poder_rival.color = rival.color_base.darkened(0.75)
	fondo_poder_rival.position = Vector2(ANCHO_ARENA - 40 - ANCHO_BARRA, 30)
	fondo_poder_rival.size = Vector2(ANCHO_BARRA, 20)
	capa.add_child(fondo_poder_rival)

	barra_poder_rival = ColorRect.new()
	barra_poder_rival.color = rival.color_base.lightened(0.2)
	barra_poder_rival.position = Vector2(ANCHO_ARENA, 30)
	barra_poder_rival.size = Vector2(0, 20)
	capa.add_child(barra_poder_rival)

	etiqueta_cargas_rival = Label.new()
	etiqueta_cargas_rival.text = "CORE 0/3"
	etiqueta_cargas_rival.position = Vector2(ANCHO_ARENA - 40 - ANCHO_BARRA, 54)
	capa.add_child(etiqueta_cargas_rival)
	cores_rival = _crear_indicadores_core(capa, Vector2(ANCHO_ARENA - 230, 56), rival.color_base, true)

	fondo_rival = fondo_poder_rival

	etiqueta_rival = Label.new()
	etiqueta_rival.text = rival.nombre_luchador + " (IA)"
	etiqueta_rival.position = Vector2(ANCHO_ARENA - 40 - ANCHO_BARRA, 4)
	capa.add_child(etiqueta_rival)

	var ayuda := Label.new()
	ayuda.text = "Flechas: mover/saltar   Abajo: bloquear   X: puñetazo   C: patada   Z: poder especial"
	ayuda.position = Vector2(40, 660)
	capa.add_child(ayuda)

	var ayuda2 := Label.new()
	ayuda2.text = "Rival: 1 Fang  2 Cibor-X  3 Kali  4 Aethel  5 Magnus  6 Helena  7 Jester  8 Varkhos"
	ayuda2.position = Vector2(40, 684)
	capa.add_child(ayuda2)

	seleccion_jugador_label = Label.new()
	seleccion_jugador_label.text = "J1: Q Kai  W Fang  E Cibor-X  R Kali  T Aethel  Y Magnus  U Helena  I Jester"
	seleccion_jugador_label.position = Vector2(650, 684)
	capa.add_child(seleccion_jugador_label)
	var estado_ui = get_node_or_null("/root/GameState")
	if estado_ui and estado_ui.flujo_menu_activo:
		ayuda2.visible = false
		seleccion_jugador_label.visible = false

func _crear_indicadores_core(capa: CanvasLayer, posicion: Vector2, color_base: Color, invertido: bool = false) -> Array[ColorRect]:
	var resultado: Array[ColorRect] = []
	for i in range(3):
		var celda := ColorRect.new()
		celda.position = posicion + Vector2(i * 22.0, 0.0) if not invertido else posicion + Vector2((2 - i) * 22.0, 0.0)
		celda.size = Vector2(16, 8)
		celda.color = color_base.darkened(0.55)
		capa.add_child(celda)
		resultado.append(celda)
	return resultado

func _actualizar_cores(celdas: Array[ColorRect], cargas: int, listo: bool, color_base: Color) -> void:
	for i in range(celdas.size()):
		var llena := i < cargas
		if llena:
			celdas[i].color = color_base.lightened(0.25 if not listo else 0.65)
			var pulso := 1.0 + (0.08 * sin(Time.get_ticks_msec() * 0.008)) if listo and i == cargas - 1 else 1.0
			celdas[i].scale = Vector2(pulso, pulso)
		else:
			celdas[i].color = color_base.darkened(0.55)
			celdas[i].scale = Vector2.ONE

func _unhandled_input(event: InputEvent) -> void:
	var estado_input = get_node_or_null("/root/GameState")
	if estado_input and estado_input.flujo_menu_activo:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1:
				_cambiar_rival(Fang.new())
			KEY_2:
				_cambiar_rival(CiborX.new())
			KEY_3:
				_cambiar_rival(Kali.new())
			KEY_4:
				_cambiar_rival(Aethel.new())
			KEY_5:
				_cambiar_rival(Magnus.new())
			KEY_6:
				_cambiar_rival(Helena.new())
			KEY_7:
				_cambiar_rival(Jester.new())
			KEY_8:
				_cambiar_rival(Varkhos.new())
			KEY_Q:
				_cambiar_jugador(_crear_luchador("Kai"))
			KEY_W:
				_cambiar_jugador(_crear_luchador("Fang"))
			KEY_E:
				_cambiar_jugador(_crear_luchador("Cibor-X"))
			KEY_R:
				_cambiar_jugador(_crear_luchador("Kali"))
			KEY_T:
				_cambiar_jugador(_crear_luchador("Aethel"))
			KEY_Y:
				_cambiar_jugador(_crear_luchador("Magnus"))
			KEY_U:
				_cambiar_jugador(_crear_luchador("Helena"))
			KEY_I:
				_cambiar_jugador(_crear_luchador("Jester"))

func _process(delta: float) -> void:
	escenario_tiempo += delta
	_actualizar_escenario_parallax(delta)
	_actualizar_escenario_pulso(delta)
	_actualizar_ambiente_87(delta)
	_actualizar_piso_vivo(delta)
	_actualizar_iluminacion_luchadores(delta)
	_actualizar_vineta_tension(delta)
	if is_instance_valid(kai):
		barra_poder_kai.size.x = ANCHO_BARRA * clampf(kai.poder / PODER_MAXIMO, 0.0, 1.0)
		etiqueta_cargas_kai.text = "CORE %d/3" % mini(kai.veces_fase_absoluta, 3)
		_actualizar_cores(cores_kai, mini(kai.veces_fase_absoluta, 3), kai.poder >= PODER_MAXIMO and not kai.en_fase_absoluta, kai.color_base)
		if kai.combo_count > 1:
			etiqueta_combo.text = "COMBO x%d" % kai.combo_count
		else:
			etiqueta_combo.text = ""
		if kai.poder >= PODER_MAXIMO and not kai.en_fase_absoluta:
			etiqueta_poder_listo.text = "¡PODER LISTO! Presioná Z"
		else:
			etiqueta_poder_listo.text = ""
	if is_instance_valid(rival):
		var ancho_rival: float = ANCHO_BARRA * clampf(rival.poder / PODER_MAXIMO, 0.0, 1.0)
		barra_poder_rival.size.x = ancho_rival
		barra_poder_rival.position.x = ANCHO_ARENA - 40.0 - ancho_rival
		etiqueta_cargas_rival.text = "CORE %d/3" % mini(rival.veces_fase_absoluta, 3)
		_actualizar_cores(cores_rival, mini(rival.veces_fase_absoluta, 3), rival.poder >= PODER_MAXIMO and not rival.en_fase_absoluta, rival.color_base)

	if is_instance_valid(kai) and is_instance_valid(rival) and not camara_cinematica_activa and not congelando_ko:
		var medio := (kai.global_position + rival.global_position) * 0.5
		var separacion := absf(kai.global_position.x - rival.global_position.x)
		# La cámara anticipa ligeramente la dirección de la acción: cuando uno
		# está atacando, el encuadre se corre unos píxeles hacia el atacante y
		# hacia su rival. Evita que los golpes rápidos se sientan fuera de cuadro.
		var foco_ataque := Vector2.ZERO
		for luchador in [kai, rival]:
			if is_instance_valid(luchador) and luchador.fase_ataque != Fighter.FaseAtaque.NINGUNA:
				foco_ataque.x += luchador.mirando * 28.0
		var objetivo_x_base := clampf(medio.x + foco_ataque.x * 0.45, 420.0, ANCHO_ARENA - 420.0)
		if foco_impacto_timer > 0.0:
			objetivo_x_base = lerpf(objetivo_x_base, clampf(foco_impacto_camara_x, 420.0, ANCHO_ARENA - 420.0), 0.34)
		var objetivo_y := 355.0 + clampf((560.0 - medio.y) * 0.12, -25.0, 25.0)
		var alpha_camara := 1.0 - exp(-7.0 * delta)
		camara.position.x = lerpf(camara.position.x, objetivo_x_base, alpha_camara)
		camara.position.y = lerpf(camara.position.y, objetivo_y, alpha_camara)
		var zoom_objetivo: float = clampf(1.03 - (separacion - 360.0) / 1800.0, 0.95, 1.03)
		if pulso_cam_combate > 0.0:
			zoom_objetivo += 0.010 + pulso_cam_combate * 0.018
		if absf(kai.velocity.x) > 280.0 or absf(rival.velocity.x) > 280.0:
			zoom_objetivo = minf(zoom_objetivo, 1.015)
		var alpha_zoom := 1.0 - exp(-5.0 * delta)
		camara.zoom = camara.zoom.lerp(Vector2.ONE * zoom_objetivo, alpha_zoom)

	if foco_impacto_timer > 0.0:
		foco_impacto_timer = maxf(0.0, foco_impacto_timer - delta)
	pulso_cam_combate = move_toward(pulso_cam_combate, 0.0, 7.5 * delta)

	if shake_tiempo > 0.0:
		shake_tiempo -= delta
		shake_reloj -= delta
		if shake_reloj <= 0.0:
			shake_reloj = shake_intervalo
			camara.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_fuerza
		if shake_tiempo <= 0.0:
			camara.offset = Vector2.ZERO


func _actualizar_escenario_parallax(delta: float) -> void:
	if not camara or not escenario_far or not escenario_mid or not escenario_front:
		return
	var desplazamiento_x: float = camara.global_position.x - ANCHO_ARENA * 0.5
	var desplazamiento_y: float = camara.global_position.y - 360.0
	var arrastre_movimiento: float = 0.0
	if is_instance_valid(kai) and is_instance_valid(rival):
		arrastre_movimiento = clampf((kai.velocity.x + rival.velocity.x) * 0.012, -10.0, 10.0)
	escenario_impulso_aire_x = lerpf(escenario_impulso_aire_x, escenario_impulso_aire_objetivo, 1.0 - exp(-18.0 * delta))
	escenario_impulso_aire_objetivo = move_toward(escenario_impulso_aire_objetivo, 0.0, 90.0 * delta)
	escenario_far.position = Vector2(-desplazamiento_x * 0.10, -desplazamiento_y * 0.035)
	escenario_mid.position = Vector2(-desplazamiento_x * 0.22 + escenario_impulso_aire_x * 0.22, -desplazamiento_y * 0.075)
	escenario_front.position = Vector2(-desplazamiento_x * 0.035 + escenario_impulso_aire_x + arrastre_movimiento, -desplazamiento_y * 0.12)
	if ambiente_particulas_delante:
		ambiente_particulas_delante.position.x = lerpf(ambiente_particulas_delante.position.x, escenario_impulso_aire_x * 0.55 + arrastre_movimiento * 0.45, 1.0 - exp(-8.0 * delta))

func _actualizar_piso_vivo(delta: float) -> void:
	if not piso_overlay:
		return
	# Pulso ambiental casi imperceptible que evita que el piso parezca una
	# textura completamente inmóvil. La intensidad depende del elemento.
	var intensidad: float = 0.6 + 0.4 * sin(escenario_tiempo * 1.1)
	var energia_cuerpos: float = 0.0
	if is_instance_valid(kai):
		energia_cuerpos += clampf(absf(kai.velocity.x) / 650.0, 0.0, 0.35)
	if is_instance_valid(rival):
		energia_cuerpos += clampf(absf(rival.velocity.x) / 650.0, 0.0, 0.35)
	var escala_base: float = 1.0
	if escenario_tipo == "tierra":
		escala_base = 1.02
	elif escenario_tipo == "fuego" or escenario_tipo == "electrico":
		escala_base = 1.005
	else:
		escala_base = 1.001
	piso_overlay.scale = Vector2.ONE * lerpf(piso_overlay.scale.x, escala_base + intensidad * 0.002 + energia_cuerpos * 0.003, 1.0 - exp(-4.0 * delta))
	if luz_impacto:
		luz_impacto.energy = move_toward(luz_impacto.energy, 0.0, 6.0 * delta)

func _respuesta_piso_al_impacto() -> void:
	if not piso_overlay or not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	var centro: Vector2 = (kai.global_position + rival.global_position) * 0.5
	centro.y = SUELO_Y - 2.0

	# Onda elíptica muy corta: da sensación de contacto con el suelo sin
	# parecer un terremoto cada vez que hay un puñetazo.
	var onda := Polygon2D.new()
	onda.polygon = _crear_poligono_elipse(12.0, 3.5)
	onda.color = Color(escenario_effect_color.r, escenario_effect_color.g, escenario_effect_color.b, 0.18)
	onda.position = centro
	onda.z_index = 3
	piso_overlay.add_child(onda)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(onda, "scale", Vector2(4.5, 2.0), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(onda, "modulate:a", 0.0, 0.18)
	tw.chain().tween_callback(onda.queue_free)

	if luz_impacto:
		luz_impacto.position = centro
		luz_impacto.energy = 0.8
		luz_impacto.color = escenario_effect_color.lerp(Color.WHITE, 0.45)

	# Fragmentos minúsculos para golpes fuertes. Se recogen solos.
	for i in range(3):
		var fragmento := Polygon2D.new()
		var tam: float = randf_range(1.5, 3.2)
		fragmento.polygon = PackedVector2Array([Vector2(-tam,0), Vector2(0,-tam*0.6), Vector2(tam,0), Vector2(0,tam*0.6)])
		fragmento.color = Color(0.72, 0.67, 0.58, 0.30)
		fragmento.position = centro + Vector2(randf_range(-18.0,18.0), randf_range(-2.0,1.0))
		fragmento.z_index = 4
		piso_overlay.add_child(fragmento)
		var destino := fragmento.position + Vector2(randf_range(-16.0,16.0), randf_range(-10.0,-4.0))
		var tf := create_tween()
		tf.set_parallel(true)
		tf.tween_property(fragmento, "position", destino, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tf.tween_property(fragmento, "rotation", randf_range(-1.5,1.5), 0.22)
		tf.tween_property(fragmento, "modulate:a", 0.0, 0.22)
		tf.chain().tween_callback(fragmento.queue_free)

func _actualizar_escenario_pulso(delta: float) -> void:
	if not fondo_material:
		return
	var pulso_base: float = 0.014
	var pulso_extra: float = 0.006 * (0.5 + 0.5 * sin(escenario_tiempo * 0.8))
	if escenario_tipo == "electrico":
		pulso_extra += 0.006 * maxf(0.0, sin(escenario_tiempo * 2.2))
	elif escenario_tipo == "fuego" or escenario_tipo == "veneno":
		pulso_extra += 0.003 * (0.5 + 0.5 * sin(escenario_tiempo * 1.15))
	elif escenario_tipo == "luz":
		pulso_extra += 0.004 * (0.5 + 0.5 * sin(escenario_tiempo * 0.65))
	escenario_flash_energia = move_toward(escenario_flash_energia, 0.0, 0.55 * delta)
	fondo_material.set_shader_parameter("pulse_strength", pulso_base + pulso_extra)
	fondo_material.set_shader_parameter("energy_flash", escenario_flash_energia)
