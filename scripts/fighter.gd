class_name Fighter
extends CharacterBody2D

# --- Partículas GPU (compartidas por todos los personajes) ---
# Godot no estaba usando GPUParticles2D en ningún lado -- todos los efectos
# de impacto eran Polygon2D creados a mano con Tween. Esto agrega una
# textura circular suave, generada una sola vez y cacheada, para usar con
# GPUParticles2D reales: se renderizan en la GPU (mucho más livianas que
# decenas de nodos Polygon2D) y permiten variación orgánica real de
# velocidad/rotación/escala por partícula, algo que a mano es tedioso.
static var _textura_particula_cache: ImageTexture = null

static func _obtener_textura_particula() -> ImageTexture:
	if _textura_particula_cache:
		return _textura_particula_cache
	var tam := 16
	var img := Image.create(tam, tam, false, Image.FORMAT_RGBA8)
	var centro := Vector2(tam / 2.0, tam / 2.0)
	for y in range(tam):
		for x in range(tam):
			var d: float = Vector2(x + 0.5, y + 0.5).distance_to(centro) / (tam / 2.0)
			var a: float = clampf(1.0 - d, 0.0, 1.0)
			a = a * a
			img.set_pixel(x, y, Color(1.0, 1.0, 1.0, a))
	_textura_particula_cache = ImageTexture.create_from_image(img)
	return _textura_particula_cache

# FASE 97 — relieve 2D compartido. Un solo ShaderMaterial para todo el
# roster (mismo shader, mismos parámetros): más liviano que crear una
# instancia de material por luchador, y asegura que todos reaccionen
# igual a la luz de escenario.
static var _material_volumen_cache: ShaderMaterial = null

static func _material_volumen_compartido() -> ShaderMaterial:
	if _material_volumen_cache:
		return _material_volumen_cache
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/volumen_personaje.gdshader")
	_material_volumen_cache = mat
	return _material_volumen_cache

signal impacto(fuerza: float)
# FASE 86 — audio/impacto premium. Se conservó `impacto` por compatibilidad,
# pero Main usa la versión detallada para elegir sonido según golpe/bloqueo.
signal impacto_detallado(fuerza: float, tipo: String, bloqueado: bool)
signal ataque_lanzado(tipo: String, furia: bool)
signal aterrizaje_hecho(fuerza: float, derribo: bool)
signal core_listo
signal fase_activada
signal rematador_iniciado
signal rematador_conectado
signal finalizacion_absoluta
signal recarga_iniciada(camara_lenta: bool)
signal derrotado
signal salto_hecho

# --- Estos valores los pisa cada personaje en su _init() ---
var nombre_luchador := "Luchador"
var velocidad := 260.0
var fuerza_salto := -420.0
var gravedad := 1200.0

# Multiplicador global de daño: bajalo para peleas más largas (la vida
# tarda más en bajar), subilo para peleas más rápidas. Se aplica sobre
# TODO el daño (golpes normales y especiales) de todos los personajes.
const MULT_DANO_GLOBAL := 0.32

# Multiplicador global de la barra de poder: bajalo para que tarde más en
# llenarse (peleas más largas hasta ver la Fase Absoluta).
const MULT_PODER_GLOBAL := 0.55

# FASE 90.2 — golpes con más presencia física: que ningún golpe deje al
# rival "pegado" en el lugar, ni en combate normal ni durante el combo
# automático del CORE. Sube el empuje base de TODOS los golpes del juego.
const MULT_EMPUJE_GLOBAL := 1.35

# FASE 85 — CORE competitivo: todos los luchadores cargan a un ritmo más
# parejo por impacto limpio. Las diferencias de personalidad siguen viniendo
# de su velocidad/timing, pero nadie obtiene casi el doble de CORE por golpe.
const CORE_GANANCIA_MIN := 5.8
const CORE_GANANCIA_MAX := 7.2
const CORE_BLOQUEO_MULT := 0.18

# FASE 85 — cajas de contacto más cercanas al cuerpo que realmente se ve.
# La colisión física sigue compacta para que los personajes no se empujen
# desde demasiado lejos, mientras la hurtbox de golpes cubre torso/cabeza.
const HURTBOX_ALTURA_VISIBLE_MULT := 0.60
const HURTBOX_ANCHO_CUERPO_MULT := 1.18
const COLISION_ALTURA_VISIBLE_MULT := 0.36

# Cuánto dura el combo automático de puños/patadas que se dispara al entrar
# en Fase Absoluta, antes del golpe rematador final.
const DURACION_COMBO_AUTO := 2.0
# Distancia objetivo para los combos automáticos: el atacante se acerca
# físicamente antes de lanzar cada golpe para no perder la secuencia por
# estar unos píxeles fuera de rango.
const DISTANCIA_COMBO_AUTO_OBJETIVO := 82.0
const DISTANCIA_COMBO_AUTO_MAX := 250.0
# FASE 60 — asistencia de avance durante ataques normales. Da una pequeña
# transferencia de peso automática hacia el rival para que los golpes no
# parezcan "anclados" al piso cuando el jugador pulsa X/C cerca del objetivo.
const DISTANCIA_LUNGE_ATAQUE := 240.0
const DISTANCIA_LUNGE_MINIMA := 74.0
const VELOCIDAD_LUNGE_PUNETAZO := 118.0
const VELOCIDAD_LUNGE_PATADA := 104.0

var rango_punetazo := 90.0
var dano_punetazo := 8.0
var cooldown_punetazo := 0.26

var rango_patada := 100.0
var dano_patada := 13.0
var cooldown_patada := 0.47

var ventana_combo := 1.1

var poder_maximo := 100.0
var poder_por_golpe := 14.0
var duracion_fase := 13.0
var mult_velocidad_fase := 1.3
var mult_dano_fase := 1.6
var mult_escala_fase := 1.45

var ancho_cuerpo := 40.0
var alto_cuerpo := 70.0
var color_base := Color(0.7, 0.7, 0.7)
var color_fase := Color(1.0, 1.0, 1.0)

# --- Sprites reales (opcional). Si textura_parado queda en null, se usa el
#     rectángulo de color de siempre. Así los personajes sin arte todavía
#     no se rompen. ---
var textura_parado: Texture2D = null
var textura_punetazo: Texture2D = null
var textura_patada: Texture2D = null
var textura_golpe_recibido: Texture2D = null
# Variantes de reacción normal: la primera, segunda y tercera reciben impactos distintos.
var texturas_golpe_recibido_extra: Array[Texture2D] = []
var indice_golpe_recibido := -1
var textura_derribado: Texture2D = null
var textura_especial: Texture2D = null
var textura_rematador: Texture2D = null
var textura_absoluto: Texture2D = null
var textura_recarga: Texture2D = null
# Opcional para futuros PNG de victoria. Mientras no exista un asset propio,
# el sistema usa la pose Furia/Parado como respaldo sin romper el juego.
var textura_victoria: Texture2D = null

# --- Caminata / salto / bloqueo (opcional). Si un personaje no carga nada
#     acá, se sigue comportando como antes: rebote procedural sobre
#     "parado" al caminar, sin cambio de pose al saltar, y solo el tinte
#     de color al bloquear. ---
var texturas_caminata: Array[Texture2D] = []
var textura_caminata_der: Texture2D = null
var textura_caminata_izq: Texture2D = null
var textura_salto: Texture2D = null
var textura_doble_salto: Texture2D = null
var textura_descenso: Texture2D = null
var textura_bloqueo: Texture2D = null
var textura_carrera: Texture2D = null

# --- Golpes extra (opcional). Si un personaje carga más de un puñetazo o
#     patada acá, el botón va a ir alternando entre todos en vez de
#     repetir siempre el mismo. Si queda vacío, no cambia nada. ---
var texturas_punetazo_extra: Array[Texture2D] = []
var texturas_patada_extra: Array[Texture2D] = []
var indice_punetazo := 0
var indice_patada := 0

# --- Versiones "Modo Furia" (Fase Absoluta). Si no están cargadas, se
#     sigue usando la versión normal, así los personajes sin arte de furia
#     todavía no se rompen. ---
var textura_furia_parado: Texture2D = null
var textura_furia_punetazo: Texture2D = null
var textura_furia_patada: Texture2D = null
var textura_furia_golpe_recibido: Texture2D = null
var textura_furia_derribado: Texture2D = null
var texturas_furia_punetazo_extra: Array[Texture2D] = []
var texturas_furia_patada_extra: Array[Texture2D] = []
var texturas_furia_caminata: Array[Texture2D] = []
var textura_furia_caminata_der: Texture2D = null
var textura_furia_caminata_izq: Texture2D = null
var textura_furia_salto: Texture2D = null
var textura_furia_doble_salto: Texture2D = null
var textura_furia_descenso: Texture2D = null
var textura_furia_bloqueo: Texture2D = null
var textura_furia_carrera: Texture2D = null

var escala_sprite := 1.0

# Tamaño general de todos los luchadores (subilo/bajalo acá, afecta a todos
# por igual). Además cada personaje puede tener su propio "plus" de tamaño
# (Magnus y Cibor-X lo usan para ser un poco más grandes que el resto) sin
# tener que retocar el escala_sprite base de cada uno.
const MULT_TAMANO_GLOBAL := 1.15
# Altura visible común del personaje en modo normal. Todos los luchadores
# comparten esta altura visual para evitar que una pose parezca más chica
# o que un personaje quede claramente más grande que otro.
const ALTURA_VISIBLE_NORMAL_GLOBAL := 255.0
# Calibración visual por personaje. No cambia la colisión ni el peso: corrige
# únicamente diferencias de lienzo/efectos incluidos dentro de los PNG base
# para que todos se vean con la misma altura corporal en estado normal.
const ALTURA_AJUSTES_VISUALES := {
	"Kai": 1.00,
	"Cibor-X": 1.00,
	"Fang": 1.00,
	"Kali": 1.00,
	"Aethel": 1.00,
	# FASE 92.1: pedido explícito de que el golem se vea un poco más grande.
	"Magnus": 1.15,
	"Helena": 1.00,
	"Jester": 1.00,
	# Jefe final de Arcade: visiblemente más grande que el resto del roster.
	"Varkhos": 1.35,
}

# FASE 83: escala visual precalculada por PNG. Se calcula por masa alfa del
# arte respecto al parado del personaje, para que un frame horizontal, uno
# vertical o uno generado a mayor resolución NO cambie el tamaño corporal.
const ESCALAS_POSE_PRECALCULADAS := {
	"res://assets/aethel/absoluto.png": 0.174353,
	"res://assets/aethel/bloqueo.png": 0.939958,
	"res://assets/aethel/derribado.png": 0.865472,
	"res://assets/aethel/doble_salto.png": 0.854701,
	"res://assets/aethel/especial.png": 0.272713,
	"res://assets/aethel/furia_derribado.png": 0.871972,
	"res://assets/aethel/furia_golpe_recibido.png": 0.882353,
	"res://assets/aethel/furia_parado.png": 0.743486,
	"res://assets/aethel/furia_patada.png": 0.474339,
	"res://assets/aethel/furia_patada_1.png": 0.866477,
	"res://assets/aethel/furia_patada_2.png": 0.727367,
	"res://assets/aethel/furia_patada_3.png": 0.891813,
	"res://assets/aethel/furia_punetazo.png": 0.362233,
	"res://assets/aethel/furia_punetazo_1.png": 0.768262,
	"res://assets/aethel/furia_punetazo_2.png": 0.780051,
	"res://assets/aethel/furia_punetazo_3.png": 0.819892,
	"res://assets/aethel/furia_punetazo_4.png": 0.780051,
	"res://assets/aethel/furia_punetazo_5.png": 0.769593,
	"res://assets/aethel/furia_punetazo_6.png": 0.836738,
	"res://assets/aethel/golpe_recibido.png": 0.755668,
	"res://assets/aethel/golpe_recibido_2.png": 0.517080,
	"res://assets/aethel/golpe_recibido_3.png": 0.524622,
	"res://assets/aethel/patada.png": 0.531687,
	"res://assets/aethel/patada_1.png": 0.818133,
	"res://assets/aethel/patada_2.png": 0.806878,
	"res://assets/aethel/patada_3.png": 0.782746,
	"res://assets/aethel/punetazo.png": 0.471322,
	"res://assets/aethel/rematador.png": 0.195418,
	"res://assets/aethel/salto.png": 1.060785,
	"res://assets/cibor-x/absoluto.png": 0.203433,
	"res://assets/cibor-x/bloqueo.png": 0.653844,
	"res://assets/cibor-x/caminata_1.png": 0.213046,
	"res://assets/cibor-x/caminata_2.png": 0.203286,
	"res://assets/cibor-x/derribado.png": 0.207552,
	"res://assets/cibor-x/descenso.png": 0.203619,
	"res://assets/cibor-x/doble_salto.png": 0.207483,
	"res://assets/cibor-x/especial.png": 0.206181,
	"res://assets/cibor-x/furia_derribado.png": 0.801284,
	"res://assets/cibor-x/furia_golpe_recibido.png": 0.912517,
	"res://assets/cibor-x/furia_parado.png": 0.205527,
	"res://assets/cibor-x/furia_patada.png": 0.476184,
	"res://assets/cibor-x/furia_patada_1.png": 0.200840,
	"res://assets/cibor-x/furia_patada_2.png": 0.203870,
	"res://assets/cibor-x/furia_punetazo.png": 0.356308,
	"res://assets/cibor-x/furia_punetazo_1.png": 0.202543,
	"res://assets/cibor-x/furia_punetazo_2.png": 0.200840,
	"res://assets/cibor-x/furia_punetazo_3.png": 0.202052,
	"res://assets/cibor-x/furia_punetazo_4.png": 0.201808,
	"res://assets/cibor-x/golpe_recibido.png": 0.213472,
	"res://assets/cibor-x/golpe_recibido_2.png": 0.216606,
	"res://assets/cibor-x/golpe_recibido_3.png": 0.201564,
	"res://assets/cibor-x/golpe_recibido_4.png": 0.203203,
	"res://assets/cibor-x/parado.png": 0.208504,
	"res://assets/cibor-x/patada.png": 0.491722,
	"res://assets/cibor-x/patada_1.png": 0.204713,
	"res://assets/cibor-x/patada_2.png": 0.205223,
	"res://assets/cibor-x/patada_3.png": 0.203518,
	"res://assets/cibor-x/patada_4.png": 0.205910,
	"res://assets/cibor-x/punetazo.png": 0.474362,
	"res://assets/cibor-x/punetazo_1.png": 0.206188,
	"res://assets/cibor-x/punetazo_2.png": 0.202945,
	"res://assets/cibor-x/punetazo_3.png": 0.204681,
	"res://assets/cibor-x/punetazo_4.png": 0.202297,
	"res://assets/cibor-x/punetazo_5.png": 0.207760,
	"res://assets/cibor-x/recarga.png": 0.200803,
	"res://assets/cibor-x/rematador.png": 0.201645,
	"res://assets/cibor-x/salto.png": 0.215290,
	"res://assets/cibor-x/victoria.png": 0.200834,
	"res://assets/fang/absoluto.png": 0.202254,
	"res://assets/fang/bloqueo.png": 0.203449,
	"res://assets/fang/caminata_1.png": 0.206396,
	"res://assets/fang/caminata_2.png": 0.215213,
	"res://assets/fang/derribado.png": 0.207383,
	"res://assets/fang/descenso.png": 0.208947,
	"res://assets/fang/doble_salto.png": 0.203251,
	"res://assets/fang/especial.png": 0.209597,
	"res://assets/fang/furia_derribado.png": 0.745897,
	"res://assets/fang/furia_golpe_recibido.png": 0.781857,
	"res://assets/fang/furia_parado.png": 0.203088,
	"res://assets/fang/furia_patada.png": 0.480315,
	"res://assets/fang/furia_patada_1.png": 0.202925,
	"res://assets/fang/furia_patada_2.png": 0.203991,
	"res://assets/fang/furia_patada_3.png": 0.204074,
	"res://assets/fang/furia_patada_4.png": 0.202925,
	"res://assets/fang/furia_punetazo.png": 0.376543,
	"res://assets/fang/furia_punetazo_1.png": 0.203991,
	"res://assets/fang/furia_punetazo_2.png": 0.203006,
	"res://assets/fang/furia_punetazo_3.png": 0.204406,
	"res://assets/fang/golpe_recibido.png": 0.204890,
	"res://assets/fang/golpe_recibido_2.png": 0.209249,
	"res://assets/fang/golpe_recibido_3.png": 0.204808,
	"res://assets/fang/golpe_recibido_4.png": 0.210066,
	"res://assets/fang/parado.png": 0.206478,
	"res://assets/fang/patada.png": 0.520111,
	"res://assets/fang/patada_1.png": 0.205214,
	"res://assets/fang/patada_2.png": 0.209118,
	"res://assets/fang/punetazo.png": 0.506263,
	"res://assets/fang/punetazo_1.png": 0.203333,
	"res://assets/fang/punetazo_2.png": 0.204231,
	"res://assets/fang/punetazo_3.png": 0.203909,
	"res://assets/fang/punetazo_4.png": 0.202276,
	"res://assets/fang/recarga.png": 0.202925,
	"res://assets/fang/rematador.png": 0.202276,
	"res://assets/fang/salto.png": 0.203823,
	"res://assets/fang/victoria.png": 0.202271,
	"res://assets/helena/absoluto.png": 0.201952,
	"res://assets/helena/bloqueo.png": 0.202906,
	"res://assets/helena/derribado.png": 0.203800,
	"res://assets/helena/doble_salto.png": 0.212870,
	"res://assets/helena/especial.png": 0.204811,
	"res://assets/helena/furia_derribado.png": 0.950496,
	"res://assets/helena/furia_golpe_recibido.png": 0.829570,
	"res://assets/helena/furia_parado.png": 0.202250,
	"res://assets/helena/furia_patada.png": 0.596083,
	"res://assets/helena/furia_patada_1.png": 0.200955,
	"res://assets/helena/furia_patada_2.png": 0.200955,
	"res://assets/helena/furia_punetazo.png": 0.350172,
	"res://assets/helena/furia_punetazo_1.png": 0.202332,
	"res://assets/helena/furia_punetazo_2.png": 0.200955,
	"res://assets/helena/furia_punetazo_3.png": 0.201438,
	"res://assets/helena/golpe_recibido.png": 0.204713,
	"res://assets/helena/golpe_recibido_2.png": 0.202413,
	"res://assets/helena/golpe_recibido_3.png": 0.202121,
	"res://assets/helena/golpe_recibido_4.png": 0.204325,
	"res://assets/helena/parado.png": 0.205811,
	"res://assets/helena/patada.png": 0.533467,
	"res://assets/helena/patada_1.png": 0.202167,
	"res://assets/helena/patada_2.png": 0.200955,
	"res://assets/helena/patada_3.png": 0.201761,
	"res://assets/helena/punetazo.png": 0.498457,
	"res://assets/helena/punetazo_1.png": 0.203307,
	"res://assets/helena/punetazo_2.png": 0.203142,
	"res://assets/helena/punetazo_3.png": 0.200955,
	"res://assets/helena/punetazo_4.png": 0.203224,
	"res://assets/helena/punetazo_5.png": 0.202979,
	"res://assets/helena/punetazo_6.png": 0.201761,
	"res://assets/helena/punetazo_7.png": 0.206462,
	"res://assets/helena/punetazo_8.png": 0.210893,
	"res://assets/helena/recarga.png": 0.202087,
	"res://assets/helena/salto.png": 0.203403,
	"res://assets/helena/victoria.png": 0.205342,
	# FASE 92.2: calibrado a mano para que el combo de poder de Jester tenga
	# presencia real (mismo criterio que Magnus: +18% sobre el cálculo
	# automático, porque el aura de energía infla el rectángulo visible más
	# que en una pose parada común).
	"res://assets/jester/absoluto.png": 0.236541,
	"res://assets/jester/especial.png": 0.238838,
	"res://assets/jester/furia_parado.png": 0.237490,
	"res://assets/jester/furia_patada_1.png": 0.239130,
	"res://assets/jester/furia_punetazo_1.png": 0.236541,
	"res://assets/jester/furia_punetazo_2.png": 0.243376,
	"res://assets/jester/furia_punetazo_3.png": 0.238065,
	"res://assets/jester/furia_punetazo_4.png": 0.238065,
	"res://assets/jester/furia_punetazo_5.png": 0.239130,
	"res://assets/jester/recarga.png": 0.237490,
	"res://assets/jester/rematador.png": 0.236541,
	"res://assets/kai/absoluto.png": 0.196786,
	"res://assets/kai/bloqueo.png": 0.460016,
	"res://assets/kai/caminata_1.png": 0.588085,
	"res://assets/kai/caminata_2.png": 0.606073,
	"res://assets/kai/caminata_3.png": 0.602047,
	"res://assets/kai/caminata_4.png": 0.627806,
	"res://assets/kai/derribado.png": 0.523443,
	"res://assets/kai/especial.png": 0.197110,
	"res://assets/kai/furia_bloqueo.png": 1.011131,
	"res://assets/kai/furia_caminata_1.png": 0.571803,
	"res://assets/kai/furia_caminata_2.png": 0.558888,
	"res://assets/kai/furia_caminata_3.png": 0.584881,
	"res://assets/kai/furia_caminata_4.png": 0.607234,
	"res://assets/kai/furia_derribado.png": 0.777772,
	"res://assets/kai/furia_descenso.png": 0.428706,
	"res://assets/kai/furia_doble_salto.png": 0.436571,
	"res://assets/kai/furia_golpe_recibido.png": 0.791644,
	"res://assets/kai/furia_salto.png": 0.423807,
	"res://assets/kai/golpe_recibido.png": 0.447219,
	"res://assets/kai/golpe_recibido_2.png": 0.517970,
	"res://assets/kai/golpe_recibido_3.png": 0.464098,
	"res://assets/kai/parado.png": 0.302491,
	"res://assets/kai/patada.png": 0.464822,
	"res://assets/kai/patada_1.png": 0.406788,
	"res://assets/kai/patada_2.png": 0.397480,
	"res://assets/kai/punetazo.png": 0.442730,
	"res://assets/kai/punetazo_1.png": 0.409644,
	"res://assets/kai/punetazo_2.png": 0.411108,
	"res://assets/kai/punetazo_3.png": 0.444467,
	"res://assets/kai/punetazo_4.png": 0.433820,
	"res://assets/kai/punetazo_5.png": 0.437775,
	"res://assets/kai/punetazo_6.png": 0.492426,
	"res://assets/kai/punetazo_7.png": 0.463262,
	"res://assets/kai/punetazo_8.png": 0.499418,
	"res://assets/kai/punetazo_9.png": 0.496358,
	"res://assets/kai/recarga.png": 0.197785,
	"res://assets/kai/salto.png": 0.463023,
	"res://assets/kai/doble_salto.png": 0.434927,
	"res://assets/kai/victoria.png": 0.306652,
	"res://assets/kali/absoluto.png": 0.152102,
	"res://assets/kali/especial.png": 0.190687,
	"res://assets/kali/furia_derribado.png": 0.844056,
	"res://assets/kali/furia_golpe_recibido.png": 0.840183,
	"res://assets/magnus/absoluto.png": 0.174706,
	"res://assets/magnus/especial.png": 0.272933,
	"res://assets/magnus/furia_derribado.png": 0.845040,
	"res://assets/magnus/furia_golpe_recibido.png": 0.972314,
	"res://assets/magnus/furia_patada.png": 0.580550,
	"res://assets/magnus/furia_patada_1.png": 0.785135,
	"res://assets/magnus/furia_patada_2.png": 0.842266,
	"res://assets/magnus/furia_punetazo_1.png": 0.272710,
	"res://assets/magnus/furia_punetazo_2.png": 0.269539,
	"res://assets/magnus/furia_punetazo_3.png": 0.272266,
	"res://assets/magnus/furia_punetazo_4.png": 0.269539,
	"res://assets/magnus/furia_punetazo_5.png": 0.269539,
	"res://assets/magnus/furia_punetazo_6.png": 0.269539,
	"res://assets/magnus/recarga.png": 0.269539,
	"res://assets/magnus/rematador.png": 0.270511,
}
var mult_tamano_extra := 1.0

# --- Estado en tiempo real ---
var vida_maxima := 220.0
var vida := 220.0
# Ya no hay K.O. por vida (podés perder toda la vida y seguir jugando
# normal). "Derrotado" ahora es un estado aparte que SOLO se activa desde
# _derrotado() (el remate absoluto), nunca por vida en 0. Todo lo que
# antes chequeaba "vida > 0.0" para decidir si seguir animando/moviendo
# al personaje debe chequear esto en cambio -- si no, apenas la vida
# llega a 0 en una pelea larga (algo normal ahora, sin K.O.) el personaje
# se queda trabado en la última pose para siempre.
var esta_derrotado := false
var objetivo: Fighter
# Control humano del luchador actual. Cuando es false usa la IA del personaje.
var controlado_por_jugador := false
var z_estaba_presionado: bool = false
var mirando := 1.0

var combo_count := 0
var combo_timer := 0.0
var poder := 0.0
var en_fase_absoluta := false
var fase_timer := 0.0
var flash_timer := 0.0
var pose_timer := 0.0
var en_pose_recarga := false
var en_combo_auto_visual := false
# FASE 92.1: por defecto el combo automático alterna golpe/patada. Poner
# esto en false hace que el combo use SOLO puñetazos -- pensado para
# personajes que todavía no tienen arte furia_patada a la altura de su
# arte furia_punetazo (para no mezclar una patada de la camada vieja en
# medio de un combo con puños ya rediseñados).
var combo_auto_incluye_patada := true
var empuje_x := 0.0
var empuje_timer := 0.0
# FASE 79 — remates con vuelo hacia atrás + caída al piso.
var derribo_especial_activo := false
var derribo_especial_esperando_aterrizar := false
var derribo_especial_se_levanta := false
var derribo_especial_timer := 0.0
var derribo_especial_rebote_muro_usado := false
var derribo_especial_deslizando := false
var derribo_especial_tiempo_deslizamiento := 0.0
var recuperacion_post_levantada_timer := 0.0

# --- FASE 2: hitbox/hurtbox con ventanas de tiempo reales ---
# Cada golpe ahora pasa por 3 etapas en vez de resolverse al instante:
# STARTUP (se prepara, todavía no puede pegar) -> ACTIVO (acá sí puede
# conectar, una sola vez) -> RECOVERY (ya pegó o falló, no puede hacer
# nada más hasta que termine). Mientras cualquiera de las tres está
# activa, el personaje queda "comprometido" con el golpe: no puede
# moverse, bloquear ni atacar de nuevo -- así un puñetazo realmente
# tiene que alcanzar el cuerpo, y no se puede spamear.
enum FaseAtaque { NINGUNA, STARTUP, ACTIVO, RECOVERY }
var fase_ataque := FaseAtaque.NINGUNA
var timer_fase_ataque := 0.0
var _atk_tipo := ""
var _atk_rango := 0.0
var _atk_dano := 0.0
var _atk_empuje_base := 0.0
var _atk_hitstun := 0.0
var _atk_ya_conecto := false
var _atk_dur_activo := 0.0
var _atk_dur_recovery := 0.0

# Cuánto tiempo sigue aturdido (sin poder actuar) el que RECIBE un golpe.
# Es lo que antes faltaba: antes el daño se aplicaba y el personaje
# seguía caminando como si nada al toque.
var hitstun_timer := 0.0
var hitstop_timer := 0.0

# "Peso" del golpe de este personaje: multiplica el empuje y el hit-stun
# que le mete al rival cuando conecta. Magnus pega pesado, Kali pega
# rápido y liviano -- cada personaje puede pisar este valor.
var peso_golpe := 1.0
var sprite_base_y := 0.0
var escala_actual := 1.0
# --- Peso del movimiento (FASE 1: "que el personaje deje de parecer un
# papel"). Cada personaje puede pisar estos dos valores para sentirse
# más liviano o más pesado -- por default todos usan lo mismo. Son
# unidades de velocidad ganada/perdida por segundo (no un tope de
# velocidad, eso lo sigue poniendo "vel_actual" en cada mover()).
var aceleracion := 2400.0
var friccion_suelo := 2800.0
var friccion_aire := 1100.0
var _delta_actual := 0.0166
var _rect_visual_cache: Dictionary = {}
const DISTANCIA_MINIMA_LUCHADORES := 46.0
const ARENA_LIMITE_IZQUIERDO := 58.0
const ARENA_LIMITE_DERECHO := 1222.0
const FUERZA_REBOTE_MURO_ESPECIAL := 0.42
# FASE 78: al impactar, los cuerpos no deben sentirse como dos papeles
# superpuestos. Estas distancias extra fuerzan mejor lectura del contacto.
const DISTANCIA_MINIMA_CONTACTO := 58.0
const DISTANCIA_MINIMA_CONTACTO_BLOQUEO := 62.0
const DISTANCIA_MINIMA_CONTACTO_PESADO := 66.0
const Z_BASE_Y_DIVISOR := 12.0
var ciclo_caminata := 0.0
var ciclo_reposo := 0.0
var indice_caminata := 0
# FASE 47 — expresividad corporal
var estado_visual_tension := 0.0
var estado_visual_balance := 0.0
var paso_timer := 0.0
var paso_fase := 0
var ultima_velocidad_x := 0.0
var impulso_visual := 0.0
var impulso_visual_vel := 0.0
var luz_contacto: Polygon2D
# FASE 55 — expresión facial procedural para estados tranquilos:
# parpadeo sutil y una respuesta facial de defensa/impacto sin reemplazar
# las ilustraciones ni alterar su escala física.
var capa_facial: Node2D
var parpado_izq: Polygon2D
var parpado_der: Polygon2D
var parpadeo_timer: float = 3.4
var parpadeo_fase: int = 0
var parpadeo_progreso: float = 0.0
var parpadeo_cooldown: float = 0.0
var parpadeo_bloqueado: bool = false
# FASE 56 — lectura física del CORE sin cambiar la escala del luchador.
var aura_core: Polygon2D
var fase_expresion: float = 0.0
# FASE 90.5: recalibrado desde cero. Los valores viejos eran de una versión
# anterior del arte de cada personaje (antes de varios rediseños) y ya no
# correspondían a los ojos reales de los parado.png actuales -- por eso el
# parpadeo aparecía "flotando" arriba del personaje, sin sentido.
# Formato Vector4(x, y, separación, ancho) = posición del CENTRO entre los
# dos ojos respecto del centro geométrico del PNG (x, y), medio de la
# distancia entre ojos (separación) y ancho aproximado de cada ojo, TODO
# en píxeles crudos de ese PNG (se reescala solo, según el zoom del sprite).
# Medido a mano sobre el parado.png actual de cada uno.
#
# Solo entran acá los personajes con dos ojos simétricos y bien visibles de
# frente. El resto del roster tiene diseños donde un parpadeo genérico no
# tiene dónde ir: Fang y Aethel muestran un solo ojo (perfil/rostro girado),
# Cibor-X tiene un único lente robótico, Kali tiene un ojo compuesto grande
# y otro chico muy asimétricos, Magnus es un único cristal brillante sin
# ojos pareados, y Varkhos tiene ojos-vacío sin párpado (más un tercer ojo
# aparte). Para esos, es mejor no mostrar nada que inventar una posición
# que no calce -- si en algún momento cambian de pose a una más de frente,
# se puede calibrar igual que estos tres.
const DATOS_CARA := {
	"Kai": Vector4(83.5, -175.5, 45.0, 32.0),
	"Helena": Vector4(108.0, -304.5, 70.0, 51.0),
	"Jester": Vector4(58.0, -164.5, 70.0, 42.0),
}
var en_el_aire := false
var saltos_maximos := 2
var saltos_usados := 0
var en_secuencia_especial := false
# Bloqueo duro durante poderes/remates: congela movimiento, gravedad e input
# para que el luchador sea quien ejecute la pose y el póster quede detrás.
var bloqueo_cinematico := false
var en_pose_victoria := false
var tween_victoria: Tween
# Se pone en true desde AFUERA (el rival, cuando arranca su secuencia de
# poder) para que este personaje deje de responder al control mientras
# dura esa cinemática -- si no, se lo podía seguir caminando mientras el
# otro tiraba su especial, y no se sentía como estar recibiendo un golpe.
var congelado_por_rival := false
# Red de seguridad: por si alguna secuencia queda trabada por algún
# motivo que no contemplamos, este reloj la corta sola. Ninguna
# secuencia real (especial simple, remate, o absoluto) tarda más de
# ~8 segundos, así que 10 da margen de sobra sin arriesgar cortar una
# secuencia legítima.
var reloj_seguridad_secuencia := 0.0
const TIEMPO_MAXIMO_SECUENCIA := 10.0
# Cuenta cuántas veces este personaje llenó la barra en TODA la pelea
# (persiste entre rondas, se resetea solo al empezar una partida nueva).
# 1ra vez: nada más el especial cargado. 2da vez: especial + combo +
# remate normal. 3ra vez en adelante: especial + combo x2 + remate
# ABSOLUTO (el póster), que termina la partida entera ahí mismo.
var veces_fase_absoluta := 0
var bloqueando := false
var bloqueo_timer := 0.0

# --- Personalidad de IA (cada personaje puede pisar estos valores) ---
var ia_prob_patada := 0.35
var ia_prob_bloqueo := 0.20
var ia_prob_retroceso := 0.15
var ia_cooldown_decision := 0.0
var ia_retrocediendo := false

var visual: Polygon2D
var sprite: Sprite2D
var sombra: Polygon2D
var colision_shape: CollisionShape2D
var forma_colision: RectangleShape2D
var _estaba_en_aire := false
var _reaccion_impacto_timer := 0.0
var _reaccion_impacto_direccion := 1.0
var _reaccion_impacto_fuerza := 0.0
# FASE 72 — contacto físico sin alterar escala: desplazamiento vertical
# mínimo del sprite al absorber impactos y follow-through visual del atacante.
var impacto_visual_y: float = 0.0
var seguimiento_ataque_x: float = 0.0
var nivel_impacto_actual: int = 0
# FASE 75 — Impact & Combat Feedback PRO. El impacto primero se absorbe y
# recién después desplaza el cuerpo. Esto vende masa sin cambiar escala.
var empuje_pendiente_timer: float = 0.0
var empuje_pendiente_direccion: float = 0.0
var empuje_pendiente_fuerza: float = 0.0
var absorcion_impacto_timer: float = 0.0
var anticipacion_ataque_x: float = 0.0
# FASE 61 — movimiento secundario y estela de alta velocidad. No cambia
# la escala base del luchador; solo agrega inercia visual y una estela muy
# corta cuando la velocidad realmente lo justifica.
var capa_estela: Node2D
var estela_timer: float = 0.0
var ultima_direccion_movimiento: float = 0.0
# FASE 62 — carrera por doble pulsación de dirección. La segunda pulsación
# dentro de una ventana corta activa una carrera breve mientras la tecla se
# mantenga presionada. No modifica la escala física ni atraviesa al rival.
const VENTANA_DOBLE_PULSO_CARRERA := 0.28
const MULT_CARRERA := 1.65
var doble_pulso_izq_timer: float = 0.0
var doble_pulso_der_timer: float = 0.0
var tecla_izq_previa: bool = false
var tecla_der_previa: bool = false
var carrera_activa: bool = false
var carrera_direccion: float = 0.0
var carrera_inicio_timer: float = 0.0
var carrera_frenado_timer: float = 0.0
var carrera_humo_timer: float = 0.0
const CARRERA_IMPULSO_INICIAL := 55.0
const CARRERA_POLVO_INTERVALO := 0.12
var asentamiento_aterrizaje: float = 0.0
const SUELO_REFERENCIA_Y := 560.0

func _ready() -> void:
	# FASE 85: si más adelante se agrega assets/<personaje>/victoria.png, se
	# detecta solo. Así podemos incorporar las poses de victoria sin volver a
	# tocar cada script individual.
	if not textura_victoria and textura_parado:
		var ruta_victoria: String = textura_parado.resource_path.get_base_dir() + "/victoria.png"
		if ResourceLoader.exists(ruta_victoria):
			textura_victoria = load(ruta_victoria)

	# Los luchadores son cuerpos físicos entre sí: evita que se atraviesen
	# durante el roce normal y mantiene una separación mínima natural.
	collision_layer = 1
	collision_mask = 1
	_crear_sombra_dinamica()
	_crear_luz_contacto()
	colision_shape = CollisionShape2D.new()
	forma_colision = RectangleShape2D.new()
	forma_colision.size = Vector2(ancho_cuerpo, alto_cuerpo)
	colision_shape.shape = forma_colision
	colision_shape.position = Vector2(0, -alto_cuerpo / 2.0)
	add_child(colision_shape)

	if textura_parado:
		sprite = Sprite2D.new()
		sprite.centered = true
		# .duplicate(): cada luchador necesita SU PROPIA instancia del
		# material a partir de FASE 98b, porque el shader ahora recibe
		# parámetros por personaje (en_furia, color_furia). Compartir la
		# misma instancia haría que el estado de Furia de uno se filtre
		# visualmente al otro.
		sprite.material = _material_volumen_compartido().duplicate()
		sprite.material.set_shader_parameter("color_furia", color_fase)
		sprite.light_mask = 1 | 2
		add_child(sprite)
		_actualizar_textura(_tex_parado())
		_crear_capa_facial()
		_crear_aura_core()
		_crear_capa_estela()
	else:
		var mitad := ancho_cuerpo / 2.0
		visual = Polygon2D.new()
		visual.polygon = PackedVector2Array([
			Vector2(-mitad, -alto_cuerpo), Vector2(mitad, -alto_cuerpo),
			Vector2(mitad, 0), Vector2(-mitad, 0)
		])
		visual.color = color_base
		add_child(visual)

	ciclo_reposo = randf_range(0.0, TAU)
	parpadeo_timer = randf_range(2.0, 4.2)

func _crear_capa_estela() -> void:
	if capa_estela or not sprite:
		return
	capa_estela = Node2D.new()
	capa_estela.name = "EstelaMovimiento"
	capa_estela.z_index = -1
	add_child(capa_estela)

func _crear_capa_facial() -> void:
	if not sprite:
		return
	# FASE 90.5: antes esto SIEMPRE creaba la capa facial, usando un
	# resguardo (Vector4(0, -195, ...)) para cualquier personaje sin
	# calibrar -- ese resguardo no correspondía a los ojos de nadie, por
	# eso el parpadeo podía aparecer flotando arriba del personaje. Ahora,
	# si el personaje no está en DATOS_CARA, directamente no se crea la
	# capa (parpado_izq/der quedan null) y el parpadeo queda apagado para
	# ese personaje sin arriesgar una posición inventada.
	if not DATOS_CARA.has(nombre_luchador):
		return
	capa_facial = Node2D.new()
	capa_facial.name = "ExpresionFacial"
	capa_facial.z_index = 8
	add_child(capa_facial)
	var datos: Vector4 = DATOS_CARA[nombre_luchador]
	var centro_x: float = datos.x
	var centro_y: float = datos.y
	var separacion: float = datos.z
	var ancho_ojo: float = datos.w
	parpado_izq = _crear_parpado()
	parpado_der = _crear_parpado()
	parpado_izq.position = Vector2(centro_x - separacion, centro_y)
	parpado_der.position = Vector2(centro_x + separacion, centro_y)
	capa_facial.add_child(parpado_izq)
	capa_facial.add_child(parpado_der)
	parpado_izq.scale = Vector2(ancho_ojo / 6.0, 1.0)
	parpado_der.scale = Vector2(ancho_ojo / 6.0, 1.0)
	parpado_izq.visible = false
	parpado_der.visible = false

func _crear_parpado() -> Polygon2D:
	var p := Polygon2D.new()
	# Forma muy fina para que el parpadeo no parezca una barra.
	p.polygon = PackedVector2Array([
		Vector2(-4.2, -0.35), Vector2(-2.2, -0.70), Vector2(0.0, -0.55),
		Vector2(2.2, -0.70), Vector2(4.2, -0.35), Vector2(2.2, 0.25),
		Vector2(0.0, 0.35), Vector2(-2.2, 0.25)
	])
	# Muy sutil: evita que el parpadeo parezca una barra negra.
	p.color = Color(0.015, 0.012, 0.020, 0.30)
	return p

func _physics_process(delta: float) -> void:
	_delta_actual = delta
	if hitstop_timer > 0.0:
		hitstop_timer -= delta
		return

	var vel_actual := velocidad
	if en_fase_absoluta:
		vel_actual *= mult_velocidad_fase

	# Durante una secuencia cinematográfica el luchador no puede caminar,
	# deslizarse ni caer por gravedad. La escena debe quedarse en una pose
	# intencional hasta que el golpe termine.
	if bloqueo_cinematico or en_secuencia_especial:
		velocity = Vector2.ZERO
	else:
		if not is_on_floor():
			velocity.y += gravedad * delta
		else:
			velocity.y = 0.0

		var bajo_derribo: bool = derribo_especial_activo and not esta_derrotado
		if bajo_derribo:
			# Mientras está volando o acostado no puede actuar. En el aire conserva
			# bastante inercia; ya en el suelo la va perdiendo hasta quedar tendido.
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0.0, 1150.0 * delta)
			else:
				velocity.x = move_toward(velocity.x, 0.0, 220.0 * delta)
		else:
			var puede_actuar: bool = not esta_derrotado and not congelado_por_rival 				and fase_ataque == FaseAtaque.NINGUNA and hitstun_timer <= 0.0 and recuperacion_post_levantada_timer <= 0.0
			if puede_actuar:
				_procesar_entrada(delta, vel_actual)
			elif fase_ataque != FaseAtaque.NINGUNA and not esta_derrotado and not congelado_por_rival and hitstun_timer <= 0.0 and recuperacion_post_levantada_timer <= 0.0:
				# Durante un golpe normal seguimos permitiendo FOOTWORK horizontal:
				# el jugador puede acercarse al rival con la flecha sin cancelar la pose
				# del golpe. El avance es más lento que caminar y no permite atravesar
				# al oponente. Así un combo no queda pegando al aire por unos píxeles.
				_procesar_footwork_durante_ataque(vel_actual)
			elif esta_derrotado or congelado_por_rival or hitstun_timer > 0.0 or recuperacion_post_levantada_timer > 0.0:
				velocity.x = 0.0

	if hitstun_timer > 0.0:
		hitstun_timer -= delta

	if recuperacion_post_levantada_timer > 0.0:
		recuperacion_post_levantada_timer = maxf(0.0, recuperacion_post_levantada_timer - delta)

	# FASE 75: microfase de absorción antes del retroceso. Durante unas
	# centésimas el cuerpo recibe el golpe casi clavado al suelo y después
	# cede con el empuje real. No hay tween de escala.
	if absorcion_impacto_timer > 0.0:
		absorcion_impacto_timer = maxf(0.0, absorcion_impacto_timer - delta)
	if empuje_pendiente_timer > 0.0:
		empuje_pendiente_timer -= delta
		if empuje_pendiente_timer <= 0.0 and empuje_pendiente_fuerza > 0.0:
			aplicar_empuje(empuje_pendiente_direccion, empuje_pendiente_fuerza)
			empuje_pendiente_fuerza = 0.0

	if derribo_especial_deslizando and is_on_floor():
		derribo_especial_tiempo_deslizamiento = maxf(0.0, derribo_especial_tiempo_deslizamiento - delta)
		velocity.x = move_toward(velocity.x, 0.0, 1780.0 * delta)
		if derribo_especial_tiempo_deslizamiento <= 0.0 or absf(velocity.x) < 10.0:
			derribo_especial_deslizando = false

	_actualizar_carrera_visual(delta)
	_actualizar_fase_ataque(delta)

	# Profundidad dinámica: un luchador más bajo en pantalla queda delante
	# de uno que está saltando. Durante un impacto, el que recibe queda un
	# poco por delante para que el golpe se lea como contacto físico y no
	# como dos papeles atravesándose.
	_actualizar_profundidad_visual()

	if en_secuencia_especial or congelado_por_rival:
		reloj_seguridad_secuencia += delta
		if reloj_seguridad_secuencia > TIEMPO_MAXIMO_SECUENCIA:
			en_secuencia_especial = false
			congelado_por_rival = false
			reloj_seguridad_secuencia = 0.0
	else:
		reloj_seguridad_secuencia = 0.0

	if empuje_timer > 0.0:
		empuje_timer -= delta
		velocity.x = empuje_x
		empuje_x = move_toward(empuje_x, 0.0, 900.0 * delta)

	if bloqueo_timer > 0.0:
		bloqueo_timer -= delta
		if bloqueo_timer <= 0.0:
			_detener_bloqueo()

	move_and_slide()
	_aplicar_separacion_fisica()
	_aplicar_limites_arena()

	var aterrizo_ahora := _estaba_en_aire and is_on_floor()
	en_el_aire = not is_on_floor()
	if not esta_derrotado and derribo_especial_activo and derribo_especial_esperando_aterrizar and is_on_floor():
		# FASE 81: seguro anti-bug. Si por timing de físicas el aterrizaje fuerte
		# ya tocó piso pero no entró por el frame exacto de "aterrizo_ahora",
		# resolvemos igual el derribo para que no quede colgado en la pose.
		_resolver_aterrizaje_derribo_especial()
	elif aterrizo_ahora and not esta_derrotado:
		# El aterrizaje conserva una cantidad distinta de inercia según el
		# cuerpo: Magnus se planta, Aethel/Kali deslizan un poco más. Todo se
		# expresa con movimiento/sombra/polvo, nunca escalando el personaje.
		velocity.x *= _retencion_horizontal_aterrizaje()
		_efecto_aterrizaje()
	_estaba_en_aire = en_el_aire

	if derribo_especial_activo and not derribo_especial_esperando_aterrizar and derribo_especial_se_levanta and not esta_derrotado:
		derribo_especial_timer = maxf(0.0, derribo_especial_timer - delta)
		if derribo_especial_timer <= 0.0:
			_terminar_derribo_especial()

	if is_on_floor():
		saltos_usados = 0

	if sprite:
		sprite.flip_h = mirando < 0.0

		var moviendose: bool = is_on_floor() and not esta_derrotado and not derribo_especial_activo and absf(velocity.x) > 10.0
		if moviendose:
			var ritmo_personal: float = _mult_ritmo_pasos()
			ciclo_caminata += delta * (9.5 + minf(absf(velocity.x) / maxf(velocidad, 1.0), 1.0) * 3.5) * ritmo_personal
			paso_timer += delta * (7.5 + minf(absf(velocity.x) / maxf(velocidad, 1.0), 1.0) * 6.0) * ritmo_personal
			if paso_timer >= PI:
				paso_timer -= PI
				paso_fase = 1 - paso_fase
				_efecto_paso(paso_fase)
		else:
			ciclo_caminata = 0.0
			paso_timer = 0.0
			paso_fase = 0

		# indice_caminata = 0 -> pierna "der", 1 -> pierna "izq" (para personajes
		# con caminata_der/caminata_izq). También sirve como índice dentro de
		# texturas_caminata para los que todavía usan el array viejo de 5 frames.
		if moviendose:
			var n_fallback: int = maxi(1, _lista_caminata().size())
			if n_fallback > 2:
				var paso := int((ciclo_caminata / TAU) * n_fallback)
				var periodo := (2 * n_fallback) - 2
				var fase := paso % periodo
				indice_caminata = fase if fase < n_fallback else periodo - fase
			else:
				indice_caminata = int(ciclo_caminata / PI) % 2

		# Mientras no haya una pose transitoria (golpe/patada/golpe recibido)
		# activa, la textura "de reposo" se recalcula todos los cuadros:
		# esto es lo que hace que el bloqueo, el salto y la caminata real
		# aparezcan y desaparezcan solos según el estado del personaje.
		if pose_timer <= 0.0 and not esta_derrotado and not derribo_especial_activo:
			_actualizar_textura(_tex_reposo())

		# Rebote procedural: solo para personajes que todavía no tienen arte
		# real de caminata (así no se rompen). Si ya hay caminata cargada,
		# el propio ciclo de sprites transmite el movimiento.
		var rebote: float = 0.0
		if moviendose and not _tiene_caminata_real():
			rebote = -absf(sin(ciclo_caminata)) * 10.0 * escala_actual

		# Animación de reposo: cuando está parado quieto (nada de golpe,
		# bloqueo, salto ni combo en curso), un balanceo sutil tipo
		# "respirando" -- así no se ve como una foto pegada. Es 100%
		# procedural (posición y una rotación mínima), no necesita arte
		# nuevo. Se apaga solo apenas hay cualquier otra pose activa.
		# FASE 90.4: la respiración ahora también sube con el cansancio
		# (vida restante), no solo con la carga de CORE -- un personaje a
		# punto de perder se ve más agitado, no solo cuando está por usar
		# su poder. Además, bloqueando ya no queda completamente estático:
		# tiene su propio balanceo, más chico y más rápido que el de reposo
		# (tensión sostenida en vez de respiración relajada), con un leve
		# sesgo hacia el rival como si estuviera empujando el bloqueo.
		var fatiga: float = clampf(1.0 - vida / maxf(vida_maxima, 1.0), 0.0, 1.0)
		var quieto: bool = is_on_floor() and not moviendose and not en_el_aire \
			and not bloqueando and pose_timer <= 0.0 and not esta_derrotado \
			and not en_secuencia_especial and not congelado_por_rival and not derribo_especial_activo
		var en_guardia: bool = is_on_floor() and bloqueando and not en_el_aire \
			and pose_timer <= 0.0 and not esta_derrotado and not en_secuencia_especial \
			and not congelado_por_rival and not derribo_especial_activo
		if quieto:
			# La respiración aumenta con la carga de CORE o con el cansancio
			# por vida perdida, lo que sea mayor: el luchador transmite
			# concentración o esfuerzo sin cambiar su tamaño normal.
			var carga_core: float = clampf(poder / maxf(poder_maximo, 1.0), 0.0, 1.0)
			var intensidad: float = maxf(carga_core, fatiga)
			var ritmo_respiracion: float = lerpf(1.6, 2.6, intensidad * intensidad)
			ciclo_reposo += delta * ritmo_respiracion
			var amplitud_respiracion: float = lerpf(2.5, 5.2, intensidad) * escala_actual
			var respiracion: float = sin(ciclo_reposo) * amplitud_respiracion
			var transferencia_peso: float = sin(ciclo_reposo * 0.5 + 0.8) * (0.65 + intensidad * 0.35) * escala_actual
			sprite.position.y = sprite_base_y + rebote + respiracion
			sprite.position.x = _sprite_ancla_x() + transferencia_peso
			sprite.rotation = sin(ciclo_reposo * 0.5) * lerpf(0.010, 0.018, intensidad)
		elif en_guardia:
			var carga_core_g: float = clampf(poder / maxf(poder_maximo, 1.0), 0.0, 1.0)
			var intensidad_g: float = maxf(carga_core_g, fatiga)
			ciclo_reposo += delta * lerpf(2.6, 3.4, intensidad_g)
			var tension: float = sin(ciclo_reposo) * lerpf(1.4, 2.6, intensidad_g) * escala_actual
			sprite.position.y = sprite_base_y + rebote + tension
			sprite.position.x = _sprite_ancla_x() + mirando * lerpf(0.6, 1.4, intensidad_g) * escala_actual
			sprite.rotation = mirando * lerpf(0.006, 0.012, intensidad_g)
		else:
			ciclo_reposo = 0.0
			sprite.position.y = sprite_base_y + rebote
			sprite.rotation = 0.0

	if combo_timer > 0.0:
		combo_timer -= delta
		if combo_timer <= 0.0:
			combo_count = 0

	if flash_timer > 0.0:
		flash_timer -= delta
		if flash_timer <= 0.0 and not esta_derrotado:
			if bloqueando:
				_set_color(Color.WHITE)
			else:
				_set_color(Color.WHITE)

	if pose_timer > 0.0:
		pose_timer -= delta
		if pose_timer <= 0.0 and not esta_derrotado and not derribo_especial_activo:
			_actualizar_textura(_tex_reposo())

	# Se ejecuta al final para que squash/impacto no sea pisado por la
	# actualización normal de textura/respiración del cuadro.
	_actualizar_sensacion_fisica(delta)
	_actualizar_expresion_facial(delta)
	_actualizar_aura_core(delta)

# Cada personaje decide cómo se mueve: teclado (jugador) o IA.
func _procesar_entrada(_delta: float, _vel_actual: float) -> void:
	if controlado_por_jugador:
		_entrada_jugador(_vel_actual)

func _entrada_jugador(vel_actual: float) -> void:
	var izquierda: bool = Input.is_physical_key_pressed(KEY_LEFT)
	var derecha: bool = Input.is_physical_key_pressed(KEY_RIGHT)
	var izquierda_justa: bool = izquierda and not tecla_izq_previa
	var derecha_justa: bool = derecha and not tecla_der_previa

	# Ventana temporal para reconocer doble toque sin interferir con el
	# movimiento normal. Cada dirección tiene su propio temporizador.
	doble_pulso_izq_timer = maxf(0.0, doble_pulso_izq_timer - _delta_actual)
	doble_pulso_der_timer = maxf(0.0, doble_pulso_der_timer - _delta_actual)

	if izquierda_justa:
		if doble_pulso_izq_timer > 0.0:
			_iniciar_carrera(-1.0)
			doble_pulso_izq_timer = 0.0
		else:
			doble_pulso_izq_timer = VENTANA_DOBLE_PULSO_CARRERA
		if carrera_activa and carrera_direccion > 0.0:
			_detener_carrera()

	if derecha_justa:
		if doble_pulso_der_timer > 0.0:
			_iniciar_carrera(1.0)
			doble_pulso_der_timer = 0.0
		else:
			doble_pulso_der_timer = VENTANA_DOBLE_PULSO_CARRERA
		if carrera_activa and carrera_direccion < 0.0:
			_detener_carrera()

	# Soltar la dirección corta la carrera inmediatamente.
	if carrera_activa:
		if (carrera_direccion < 0.0 and not izquierda) or (carrera_direccion > 0.0 and not derecha):
			_detener_carrera()

	tecla_izq_previa = izquierda
	tecla_der_previa = derecha

	var direccion: float = 0.0
	if izquierda:
		direccion -= 1.0
	if derecha:
		direccion += 1.0
	var velocidad_input: float = vel_actual * (MULT_CARRERA if carrera_activa else 1.0)
	mover(direccion, velocidad_input)

	if Input.is_action_just_pressed("ui_up"):
		saltar()

	if Input.is_physical_key_pressed(KEY_DOWN):
		if not bloqueando:
			_iniciar_bloqueo(999.0)
	elif bloqueando:
		_detener_bloqueo()

	if Input.is_physical_key_pressed(KEY_X):
		intentar_punetazo()

	if Input.is_physical_key_pressed(KEY_C):
		intentar_patada()

	var z_presionado: bool = Input.is_physical_key_pressed(KEY_Z)
	if z_presionado and not z_estaba_presionado:
		intentar_poder_especial()
	z_estaba_presionado = z_presionado

func _procesar_footwork_durante_ataque(vel_actual: float) -> void:
	var direccion_input: float = 0.0
	if controlado_por_jugador:
		if Input.is_physical_key_pressed(KEY_LEFT):
			direccion_input -= 1.0
		if Input.is_physical_key_pressed(KEY_RIGHT):
			direccion_input += 1.0
	else:
		# La IA conserva su comportamiento actual durante ataques; el avance
		# cinematográfico de sus combos se maneja en _racha_combo_auto().
		velocity.x = move_toward(velocity.x, 0.0, friccion_suelo * _delta_actual)
		return

	if direccion_input == 0.0:
		# Conserva un poco de la transferencia inicial del golpe y la deja
		# morir rápidamente. Esto da inercia sin convertir el ataque en un desliz.
		velocity.x = move_toward(velocity.x, 0.0, friccion_suelo * 0.92 * _delta_actual)
		return

	var velocidad_ataque: float = maxf(90.0, vel_actual * 0.44)
	var hacia_rival: bool = false
	if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		var dx: float = objetivo.global_position.x - global_position.x
		if absf(dx) > 1.0:
			var direccion_rival: float = signf(dx)
			hacia_rival = direccion_input == direccion_rival
			# Mientras golpeás, la orientación sigue al rival si avanzás hacia él.
			if hacia_rival:
				mirando = direccion_rival

	# Acercarse al rival es la opción favorecida. Hacia atrás todavía se permite
	# un paso pequeño para no convertir el control en un estado "congelado".
	var factor: float = 1.0 if hacia_rival else 0.42
	var objetivo_velocidad: float = direccion_input * velocidad_ataque * factor
	velocity.x = move_toward(velocity.x, objetivo_velocidad, aceleracion * 0.55 * _delta_actual)

	# Límite de seguridad: no atravesar al rival mientras se hace el footwork.
	if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		var dx_actual: float = objetivo.global_position.x - global_position.x
		var separacion: float = absf(dx_actual)
		var distancia_objetivo: float = maxf(_distancia_minima_contextual(objetivo) + 4.0, 62.0)
		if separacion <= distancia_objetivo and hacia_rival:
			velocity.x = 0.0

func _iniciar_carrera(direccion: float) -> void:
	carrera_activa = true
	carrera_direccion = direccion
	carrera_inicio_timer = 0.18
	carrera_frenado_timer = 0.0
	carrera_humo_timer = 0.0
	mirando = direccion
	velocity.x = move_toward(velocity.x, direccion * velocidad * MULT_CARRERA, CARRERA_IMPULSO_INICIAL * _mult_arranque_carrera())
	_efecto_inicio_carrera()

func _detener_carrera() -> void:
	if not carrera_activa:
		return
	carrera_activa = false
	carrera_frenado_timer = 0.16
	carrera_inicio_timer = 0.0
	carrera_direccion = 0.0

func _actualizar_carrera_visual(delta: float) -> void:
	carrera_inicio_timer = maxf(0.0, carrera_inicio_timer - delta)
	carrera_frenado_timer = maxf(0.0, carrera_frenado_timer - delta)
	if not carrera_activa or esta_derrotado or not is_on_floor() or en_secuencia_especial:
		return
	carrera_humo_timer -= delta
	if carrera_humo_timer <= 0.0:
		carrera_humo_timer = CARRERA_POLVO_INTERVALO
		_efecto_paso(1 if carrera_direccion < 0.0 else -1)
	if sprite and fase_ataque == FaseAtaque.NINGUNA and pose_timer <= 0.0:
		var objetivo_rot: float = -0.025 * carrera_direccion
		sprite.rotation = lerpf(sprite.rotation, objetivo_rot, clampf(delta * 12.0, 0.0, 1.0))
		var objetivo_y: float = sprite_base_y - 1.5 * escala_actual
		sprite.position.y = lerpf(sprite.position.y, objetivo_y, clampf(delta * 10.0, 0.0, 1.0))

func _efecto_inicio_carrera() -> void:
	if not is_on_floor() or esta_derrotado or en_secuencia_especial:
		return
	for i in range(3):
		var polvo := Polygon2D.new()
		var tam: float = randf_range(2.0, 3.6)
		polvo.polygon = PackedVector2Array([Vector2(-tam, 0), Vector2(0, -tam * 0.55), Vector2(tam, 0), Vector2(0, tam * 0.45)])
		polvo.color = Color(0.75, 0.72, 0.68, 0.22)
		polvo.position = Vector2(-carrera_direccion * randf_range(7.0, 16.0), -1.0)
		polvo.z_index = -1
		add_child(polvo)
		var destino := polvo.position + Vector2(-carrera_direccion * randf_range(8.0, 18.0), randf_range(-7.0, -1.0))
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(polvo, "position", destino, 0.18)
		tw.tween_property(polvo, "scale", Vector2(1.5, 0.65), 0.18)
		tw.tween_property(polvo, "modulate:a", 0.0, 0.18)
		tw.chain().tween_callback(polvo.queue_free)

func mover(direccion: float, vel_actual: float) -> void:
	if direccion != 0.0:
		mirando = sign(direccion)
		velocity.x = move_toward(velocity.x, direccion * vel_actual, aceleracion * _delta_actual)
	else:
		var friccion: float = friccion_suelo if is_on_floor() else friccion_aire
		velocity.x = move_toward(velocity.x, 0.0, friccion * _delta_actual)

func saltar() -> void:
	if is_on_floor():
		velocity.y = fuerza_salto
		saltos_usados = 1
		salto_hecho.emit()
	elif saltos_usados < saltos_maximos:
		velocity.y = fuerza_salto * 1.2
		saltos_usados += 1
		salto_hecho.emit()

func intentar_punetazo() -> void:
	if fase_ataque != FaseAtaque.NINGUNA or bloqueando:
		return
	var lista := _lista_punetazo()
	if lista.is_empty():
		return
	# El primer X usa el golpe 1; cada X siguiente avanza al siguiente frame.
	indice_punetazo = indice_punetazo % lista.size()
	_iniciar_ataque("punetazo", rango_punetazo, dano_punetazo, 120.0, 0.22, cooldown_punetazo)
	indice_punetazo = (indice_punetazo + 1) % lista.size()

func intentar_patada() -> void:
	if fase_ataque != FaseAtaque.NINGUNA or bloqueando:
		return
	var lista := _lista_patada()
	if lista.is_empty():
		return
	# FASE 85: igual que el puño, la primera pulsación usa patada_1. Antes se
	# incrementaba el índice antes de mostrarla y arrancaba desde el frame 2.
	indice_patada = indice_patada % lista.size()
	_iniciar_ataque("patada", rango_patada, dano_patada, 200.0, 0.32, cooldown_patada)
	indice_patada = (indice_patada + 1) % lista.size()

func intentar_poder_especial() -> void:
	if poder < poder_maximo or en_fase_absoluta or en_secuencia_especial:
		return
	# Blindaje extra: si el rival ya está en SU secuencia de poder (o
	# recién la está por arrancar en este mismo cuadro), no dejamos que
	# los dos arranquen a la vez -- eso era lo que a veces dejaba a los
	# dos personajes trabados uno enfrente del otro sin que la pelea
	# avanzara más.
	if objetivo and is_instance_valid(objetivo) and objetivo.en_secuencia_especial:
		return
	_activar_fase_absoluta()

# Arranca un golpe con ventanas de tiempo reales en vez de resolverlo al
# instante. "ciclo_total" es el cooldown ya tunado por personaje (cada
# uno tiene el suyo, eso ya venía diferenciando velocidad); se reparte en
# startup 28% / activo 14% / recovery 58%, así los personajes rápidos
# (cooldown chico) siguen siendo rápidos con el sistema nuevo, y los
# lentos (Magnus) siguen siendo lentos, pero ahora con ventanas de verdad.
func _iniciar_ataque(tipo: String, rango: float, dano_base: float, empuje_base: float, hitstun_base: float, ciclo_total: float) -> void:
	_detener_carrera()
	_atk_tipo = tipo
	ataque_lanzado.emit(tipo, en_fase_absoluta)
	_atk_rango = rango
	_atk_dano = dano_base
	_atk_empuje_base = empuje_base
	_atk_hitstun = hitstun_base
	_atk_ya_conecto = false

	# FASE 74 — identidad física: cada cuerpo prepara y recupera el golpe a
	# un ritmo ligeramente distinto. No cambia la escala del sprite ni la
	# lógica de CORE; solo el timing corporal del ataque normal.
	var startup: float = ciclo_total * 0.28 * _mult_startup_personalidad()
	_atk_dur_activo = ciclo_total * 0.14
	_atk_dur_recovery = ciclo_total * 0.58 * _mult_recovery_personalidad()

	fase_ataque = FaseAtaque.STARTUP
	timer_fase_ataque = startup
	# Anticipación corporal mínima: el cuerpo carga peso hacia atrás antes
	# del contacto y después lo libera en el follow-through.
	anticipacion_ataque_x = -mirando * (2.4 if tipo == "punetazo" else 3.6) * _mult_followthrough_personalidad()
	_preparar_avance_ataque()
	# El sprite no cambia de color durante los combos: los colores del
	# personaje se conservan intactos y el impacto se vende con partículas,
	# hit-stop y luz de contacto.
	_set_color(Color.WHITE)
	flash_timer = 0.0
	_mostrar_pose(tipo, startup + _atk_dur_activo + _atk_dur_recovery)

func _preparar_avance_ataque() -> void:
	# Asistencia muy corta y física: solo acerca al atacante si el rival está
	# relativamente cerca y delante. No teletransporta ni atraviesa al oponente.
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return
	if not is_on_floor():
		return
	var dx: float = objetivo.global_position.x - global_position.x
	var distancia: float = absf(dx)
	if distancia < DISTANCIA_LUNGE_MINIMA or distancia > DISTANCIA_LUNGE_ATAQUE:
		return
	var lado: float = signf(dx)
	if lado == 0.0:
		return
	# Si ya está mirando en la dirección del rival, el avance es automático.
	# Si estaba mirando al lado contrario, primero orienta el golpe y usa una
	# velocidad menor para que el giro no parezca un "snap" instantáneo.
	var factor_direccion: float = 1.0 if mirando == lado else 0.55
	mirando = lado
	var velocidad_objetivo: float = (VELOCIDAD_LUNGE_PUNETAZO if _atk_tipo == "punetazo" else VELOCIDAD_LUNGE_PATADA) * factor_direccion
	velocidad_objetivo *= _mult_lunge_personalidad()
	if carrera_frenado_timer > 0.0:
		velocidad_objetivo *= 1.08
	# Cuanto más cerca está el rival, menor es el impulso; así el ataque se
	# detiene antes del cuerpo y conserva espacio para la hurtbox.
	var factor_distancia: float = clampf((distancia - DISTANCIA_LUNGE_MINIMA) / 120.0, 0.22, 1.0)
	velocity.x = lado * velocidad_objetivo * factor_distancia

# Se llama todos los cuadros desde _physics_process mientras dure el
# golpe: pasa de STARTUP a ACTIVO a RECOVERY solo, y durante ACTIVO
# chequea el impacto (una sola vez por golpe).
func _actualizar_fase_ataque(delta: float) -> void:
	if fase_ataque == FaseAtaque.NINGUNA:
		return
	timer_fase_ataque -= delta
	match fase_ataque:
		FaseAtaque.STARTUP:
			if timer_fase_ataque <= 0.0:
				fase_ataque = FaseAtaque.ACTIVO
				timer_fase_ataque = _atk_dur_activo
		FaseAtaque.ACTIVO:
			if not _atk_ya_conecto:
				_chequear_impacto_ataque()
			if timer_fase_ataque <= 0.0:
				fase_ataque = FaseAtaque.RECOVERY
				timer_fase_ataque = _atk_dur_recovery
		FaseAtaque.RECOVERY:
			if timer_fase_ataque <= 0.0:
				fase_ataque = FaseAtaque.NINGUNA

# La hitbox en sí: durante los frames activos, ¿el rival está dentro del
# alcance? Si sí, conecta UNA vez (no todos los cuadros activos).
func _chequear_impacto_ataque() -> void:
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return

	var hitbox := _obtener_hitbox_ataque()
	var hurtbox := _obtener_hurtbox_global(objetivo)
	if not hitbox.intersects(hurtbox):
		return

	# El objetivo tiene que estar delante del atacante. Así evitamos golpes
	# que atraviesen al rival por detrás mientras mantenemos una hitbox amplia.
	var dx := objetivo.global_position.x - global_position.x
	if absf(dx) > 1.0 and sign(dx) != mirando:
		return

	_atk_ya_conecto = true
	var dano := _atk_dano * MULT_DANO_GLOBAL
	if en_fase_absoluta:
		dano *= mult_dano_fase
	var bloqueado := objetivo.bloqueando
	var empuje_final: float = (_atk_empuje_base * peso_golpe + dano * 4.0) * MULT_EMPUJE_GLOBAL
	# Transferencia de masa: un cuerpo pesado pega con más presencia y un
	# cuerpo pesado también absorbe mejor. El rango es deliberadamente corto
	# para conservar el balance que ya funciona.
	var transferencia_masa: float = clampf((_masa_corporal() * peso_golpe) / maxf(objetivo._masa_corporal(), 0.55), 0.72, 1.32)
	empuje_final *= transferencia_masa
	# FASE 90.2: antes esto casi anulaba el empuje (x0.22) durante el combo
	# automático del CORE, y era justamente la causa de que el rival quedara
	# "pegado" recibiendo golpes sin moverse. _acercar_para_combo_auto() ya
	# recalcula la distancia al objetivo en cada golpe del combo, así que un
	# empuje real acá no rompe nada -- al contrario, es lo que hace que cada
	# golpe lo tire para atrás y el atacante tenga que avanzar de nuevo para
	# conectar el siguiente, que es exactamente el efecto que buscamos.
	var hitstun_final: float = _atk_hitstun * peso_golpe * lerpf(0.90, 1.08, clampf((transferencia_masa - 0.72) / 0.60, 0.0, 1.0))
	if objetivo.global_position.y < global_position.y - 25.0:
		hitstun_final *= 0.85

	# Transferencia de peso en el contacto. No escalamos el sprite: el golpe
	# se vende con avance, follow-through, hit-stop y la reacción del rival.
	var avance_contacto: float = (19.0 if _atk_tipo == "punetazo" else 28.0) * _mult_followthrough_personalidad()
	velocity.x = mirando * avance_contacto
	seguimiento_ataque_x = mirando * (3.0 if _atk_tipo == "punetazo" else 5.0) * _mult_followthrough_personalidad()
	var intensidad_contacto: float = clampf(empuje_final / 280.0, 0.65, 1.45)
	# Hit-stop distinto por tipo de ataque: la patada pesa un poco más, el
	# puño conserva velocidad. Bloqueando, la pausa es seca y corta.
	var pausa_contacto: float = 0.024 + intensidad_contacto * (0.010 if _atk_tipo == "punetazo" else 0.016)
	hitstop_timer = pausa_contacto if not bloqueado else 0.018 + intensidad_contacto * 0.004
	objetivo.recibir_dano(dano, empuje_final, hitstun_final, mirando, _atk_tipo)
	_aplicar_contacto_corporal_post_golpe(objetivo, empuje_final, bloqueado)
	# Un bloqueo firme devuelve presión al atacante. La patada rebota un poco
	# más que el puño, pero sin teletransportes ni cambios de escala.
	if bloqueado:
		# El bloqueo ahora tiene más "peso": el defensor aguanta el golpe y el
		# atacante siente resistencia real antes de recuperar. Sin escalar sprites.
		var rebote_bloqueo: float = 0.26 if _atk_tipo == "punetazo" else 0.36
		velocity.x = -mirando * empuje_final * rebote_bloqueo
		seguimiento_ataque_x -= mirando * (3.2 if _atk_tipo == "punetazo" else 4.8)
		_atk_dur_recovery *= 1.12
		if objetivo.is_on_floor():
			objetivo._efecto_golpe_suelo(empuje_final * 0.55)
		if is_on_floor():
			_efecto_golpe_suelo(empuje_final * 0.26)
	else:
		# Si conectó limpio, la recuperación puede encadenar un poco mejor sin
		# acelerar artificialmente el personaje.
		_atk_dur_recovery *= 0.94
	_efecto_chispas(bloqueado, hitbox.get_center(), intensidad_contacto)
	if objetivo.is_on_floor() and empuje_final >= 170.0:
		objetivo._efecto_golpe_suelo(empuje_final)
	_registrar_golpe_conectado(bloqueado)

func _obtener_hurtbox_global(personaje: Fighter) -> Rect2:
	# FASE 85: la caja anterior medía ~80 px de alto frente a cuerpos visuales
	# de ~255 px. Eso hacía que varios puños/patadas que se veían conectados no
	# contaran. Cubrimos torso + cabeza sin convertir todo el aura/ropa en hitbox.
	var mult_cuerpo := personaje._mult_cuerpo_actual()
	var ancho_fisico: float = personaje.ancho_cuerpo * mult_cuerpo
	var alto_fisico: float = personaje.alto_cuerpo * mult_cuerpo
	var alto_visible_contacto: float = personaje._altura_visible_objetivo() * HURTBOX_ALTURA_VISIBLE_MULT
	var size := Vector2(
		maxf(ancho_fisico * HURTBOX_ANCHO_CUERPO_MULT, ancho_fisico),
		maxf(alto_fisico, alto_visible_contacto)
	)
	return Rect2(
		personaje.global_position + Vector2(-size.x * 0.5, -size.y),
		size
	)

func _obtener_hitbox_ataque() -> Rect2:
	var mult_cuerpo := _mult_cuerpo_actual()
	var cuerpo_ancho := ancho_cuerpo * mult_cuerpo
	var cuerpo_alto := alto_cuerpo * mult_cuerpo
	var alcance: float = _atk_rango + (12.0 if _atk_tipo == "patada" else 6.0)
	# Puño: tronco/cabeza. Patada: una ventana algo más baja y más alta.
	var alto_hit: float = 46.0 if _atk_tipo == "punetazo" else 58.0
	var centro_y: float = -cuerpo_alto * (0.52 if _atk_tipo == "punetazo" else 0.42)
	var ancho_hit: float = maxf(alcance - cuerpo_ancho * 0.08, 60.0)
	# La caja comienza muy cerca del cuerpo y se proyecta hacia delante.
	# Esto corrige el problema de ataques que se veían conectados a simple
	# vista pero no tocaban la hurtbox por unos píxeles.
	var avance_inicial: float = cuerpo_ancho * 0.10
	var izquierda: float = avance_inicial if mirando > 0.0 else -avance_inicial - ancho_hit
	return Rect2(
		global_position + Vector2(izquierda, centro_y - alto_hit * 0.5),
		Vector2(ancho_hit, alto_hit)
	)

func _registrar_golpe_conectado(bloqueado: bool = false) -> void:
	combo_count += 1
	combo_timer = ventana_combo
	# Los golpes de una cinemática CORE no recargan el siguiente CORE mientras
	# el poder todavía se está ejecutando. Evita el auto-refill del especial.
	if en_fase_absoluta or en_secuencia_especial:
		return
	var ganancia: float = clampf(poder_por_golpe * MULT_PODER_GLOBAL, CORE_GANANCIA_MIN, CORE_GANANCIA_MAX)
	if _atk_tipo == "patada":
		ganancia *= 1.08
	# Bloquear ahora sí protege también la carrera de CORE: el atacante recibe
	# solo una fracción pequeña por mantener presión, no la carga completa.
	if bloqueado:
		ganancia *= CORE_BLOQUEO_MULT
	var poder_anterior: float = poder
	poder = min(poder_maximo, poder + ganancia)
	if poder_anterior < poder_maximo and poder >= poder_maximo:
		core_listo.emit()

func _activar_fase_absoluta() -> void:
	poder = 0.0
	indice_punetazo = 0
	indice_patada = 0
	indice_golpe_recibido = -1
	veces_fase_absoluta += 1
	fase_activada.emit()

	if veces_fase_absoluta == 1:
		# Primera vez en toda la pelea: el especial reemplaza al personaje
		# un toque y listo. Sigue todo en modo normal, sin transformarse.
		_secuencia_poder_simple()
	elif veces_fase_absoluta == 2:
		# Segunda vez: especial (reemplaza al personaje) -> ahí SÍ se
		# transforma para el combo -> remate normal -> vuelve a la normalidad.
		_secuencia_rematador()
	else:
		# Tercera vez (y de ahí en adelante): especial -> se transforma
		# para el combo -> remate ABSOLUTO con el póster, en cámara lenta.
		# Esto termina la partida entera.
		_secuencia_absoluta()

# Entra/sale de Fase Absoluta -- ahora es SOLO un cambio de color/textura
# (nunca de tamaño) y dura nada más lo que dura el combo automático de
# cada secuencia, no toda la pelea.
func _entrar_furia() -> void:
	en_fase_absoluta = true
	# No teñimos el PNG base. La Furia se comunica con su textura propia,
	# aura y efectos, no pintando artificialmente todo el personaje.
	_set_color(Color.WHITE)
	_actualizar_textura(_tex_parado())

func _salir_furia() -> void:
	en_fase_absoluta = false
	indice_punetazo = 0
	indice_patada = 0
	indice_golpe_recibido = -1
	_set_color(Color.WHITE)
	_actualizar_textura(_tex_parado())

# Compatibilidad: algunos lugares viejos podían llamar a esto por nombre.
func _terminar_fase_absoluta() -> void:
	_salir_furia()

# Cada personaje define su propio golpe definitivo
func _ejecutar_especial() -> void:
	pass

# El bucle de puños/patadas automáticos en sí (sin el remate al final).
# Lo usan tanto el remate normal como el absoluto. Corre en Fase Absoluta
# (ya la habrá activado quien llama antes de esto). Ahora que cada golpe
# tiene su propio ciclo real (startup/activo/recovery), este bucle espera
# a que el golpe anterior termine su ciclo antes de tirar el siguiente --
# si no, con un intervalo fijo la mitad de los intentos caían a mitad de
# otro golpe y se perdían en silencio.
func _racha_combo_auto() -> void:
	en_combo_auto_visual = true
	var t := 0.0
	var golpe_es_patada := false
	while t < DURACION_COMBO_AUTO and not esta_derrotado and en_fase_absoluta:
		if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
			# Durante la cinemática el _physics_process mantiene velocity en cero,
			# así que no sirve "mover()" para cerrar la distancia. Hacemos un
			# pequeño avance cinematográfico con tween, pero solo cuando el golpe
			# anterior ya terminó su recovery.
			if fase_ataque == FaseAtaque.NINGUNA:
				await _acercar_para_combo_auto()
				if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
					break
				var distancia: float = objetivo.global_position.x - global_position.x
				if absf(distancia) > 1.0:
					mirando = signf(distancia)
				if golpe_es_patada and combo_auto_incluye_patada:
					intentar_patada()
				else:
					intentar_punetazo()
				golpe_es_patada = not golpe_es_patada
		await get_tree().create_timer(0.05, true, false, true).timeout
		t += 0.05
	velocity.x = 0.0
	en_combo_auto_visual = false

func _acercar_para_combo_auto() -> void:
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return
	var dx: float = objetivo.global_position.x - global_position.x
	var distancia: float = absf(dx)
	if distancia <= DISTANCIA_COMBO_AUTO_OBJETIVO:
		return
	var lado: float = signf(dx)
	mirando = lado
	# Si están demasiado separados, cerramos la distancia con una entrada
	# más marcada; si ya están relativamente cerca, el avance es mínimo.
	var distancia_objetivo: float = DISTANCIA_COMBO_AUTO_OBJETIVO
	if distancia > DISTANCIA_COMBO_AUTO_MAX:
		distancia_objetivo = 96.0
	var destino_x: float = objetivo.global_position.x - lado * distancia_objetivo
	var duracion: float = clampf(distancia / 900.0, 0.08, 0.20)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:x", destino_x, duracion)
	await tween.finished
	velocity.x = 0.0

func _congelar_rival(activo: bool) -> void:
	if objetivo and is_instance_valid(objetivo):
		objetivo.congelado_por_rival = activo

# Beat cinematográfico antes del combo automático (cargas 2 y 3): el
# personaje pasa a su pose de "recarga de energía" propia, brilla, y le
# avisa a main.gd para que oscurezca el escenario y haga zoom -- con
# cámara lenta cuando es la carga 3 (el Absoluto). Recién cuando termina
# este beat arranca _racha_combo_auto().
func _mostrar_recarga_energia(camara_lenta: bool) -> void:
	if not textura_recarga or not sprite:
		return
	# FASE AUDIO: escena de recarga alargada ~0.65s (antes 1.05/1.55) para
	# que entre un grito de voz más largo sin que se corte a la fuerza.
	var espera: float = 2.20 if camara_lenta else 1.70
	en_pose_recarga = true
	velocity = Vector2.ZERO
	pose_timer = espera + 0.08
	_actualizar_textura(textura_recarga)
	sprite.rotation = 0.0
	sprite.position.x = _sprite_ancla_x()
	recarga_iniciada.emit(camara_lenta)

	var brillo := create_tween()
	brillo.set_loops(5 if camara_lenta else 4)
	brillo.tween_property(sprite, "modulate", Color(1.48, 1.48, 1.48, 1.0), 0.14)
	brillo.tween_property(sprite, "modulate", Color(1.08, 1.08, 1.08, 1.0), 0.14)

	await get_tree().create_timer(espera, true, false, true).timeout
	if is_instance_valid(brillo):
		brillo.kill()
	if sprite:
		sprite.modulate = Color.WHITE
	en_pose_recarga = false

func _bloquear_cinematica() -> void:
	bloqueo_cinematico = true
	velocity = Vector2.ZERO
	bloqueando = false
	fase_ataque = FaseAtaque.NINGUNA
	timer_fase_ataque = 0.0
	# Mira siempre hacia el rival antes de ejecutar el golpe especial.
	if objetivo and is_instance_valid(objetivo):
		var dx: float = objetivo.global_position.x - global_position.x
		if absf(dx) > 1.0:
			mirando = signf(dx)

func _desbloquear_cinematica() -> void:
	bloqueo_cinematico = false
	velocity = Vector2.ZERO

func _pose_final_especial(duracion: float) -> void:
	# Usa el último frame de puñetazo como pose de lanzamiento: el cuerpo
	# hace realmente el golpe mientras la ilustración queda detrás.
	var lista: Array[Texture2D] = _lista_punetazo()
	if not lista.is_empty():
		_actualizar_textura(lista[lista.size() - 1])
		pose_timer = duracion

func _acercar_para_especial() -> void:
	if not objetivo or not is_instance_valid(objetivo):
		return
	var distancia: float = absf(objetivo.global_position.x - global_position.x)
	if distancia <= 210.0:
		return
	var lado: float = signf(objetivo.global_position.x - global_position.x)
	var destino_x: float = objetivo.global_position.x - lado * 150.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:x", destino_x, 0.18)
	await tween.finished
	velocity = Vector2.ZERO

func preparar_impacto_cinematico(duracion: float, direccion_atacante: float = 0.0, tipo_impacto: String = "especial") -> void:
	if esta_derrotado:
		return
	bloqueando = false
	bloqueo_timer = 0.0
	en_pose_recarga = false
	fase_ataque = FaseAtaque.NINGUNA
	timer_fase_ataque = 0.0
	velocity = Vector2.ZERO
	empuje_timer = 0.0
	empuje_x = 0.0
	empuje_pendiente_timer = 0.0
	empuje_pendiente_fuerza = 0.0
	flash_timer = 0.0
	_set_color(Color.WHITE)
	if direccion_atacante != 0.0:
		mirando = -signf(direccion_atacante)
	if not en_fase_absoluta:
		var reacciones := _lista_golpe_recibido()
		if not reacciones.is_empty():
			indice_golpe_recibido = (indice_golpe_recibido + 1) % reacciones.size()
	# Golpe visual fuerte mientras el póster está en pantalla: el rival ya no
	# queda mirando quieto el especial. Se mantiene trabado en pose de impacto.
	match tipo_impacto:
		"absoluto":
			nivel_impacto_actual = 3
			_reaccion_impacto_fuerza = 360.0
			impulso_visual = 1.10
			impacto_visual_y = -3.0
		"rematador":
			nivel_impacto_actual = 3
			_reaccion_impacto_fuerza = 300.0
			impulso_visual = 0.95
			impacto_visual_y = -2.2
		_:
			nivel_impacto_actual = 2
			_reaccion_impacto_fuerza = 220.0
			impulso_visual = 0.75
			impacto_visual_y = -1.5
	_reaccion_impacto_direccion = -signf(direccion_atacante) if direccion_atacante != 0.0 else 1.0
	_reaccion_impacto_timer = maxf(_reaccion_impacto_timer, minf(duracion, 0.60))
	hitstun_timer = maxf(hitstun_timer, duracion)
	_mostrar_pose("golpe_recibido", duracion)

func _aplicar_impacto_especial(multiplicador_dano: float = 2.6) -> void:
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return
	var direccion: float = signf(objetivo.global_position.x - global_position.x)
	if direccion == 0.0:
		direccion = mirando
	var bloqueado: bool = objetivo.bloqueando
	var dano: float = dano_punetazo * MULT_DANO_GLOBAL * multiplicador_dano
	# FASE IMPACTO: empuje del primer CORE subido (antes 360) para que se
	# note más el golpe, en línea con el remate y el absoluto.
	var empuje: float = 620.0 * peso_golpe
	var stun: float = 0.55 * peso_golpe
	if bloqueado:
		dano *= 0.35
		empuje *= 0.4
		stun *= 0.5
	objetivo.recibir_dano(dano, empuje, stun, direccion, "especial")
	_efecto_chispas(bloqueado, objetivo.global_position)
	_onda_impacto_local(objetivo.global_position, color_energia_poder(), 1.0)
	impulso_visual = 0.9
	hitstop_timer = 0.07 if not bloqueado else 0.035

# 1ra carga de barra: el especial se ejecuta con el cuerpo del luchador,
# el último golpe usa la misma pose heroica que acompaña a la ilustración,
# y recién después vuelve al combate.
func _secuencia_poder_simple() -> void:
	if en_secuencia_especial:
		return
	en_secuencia_especial = true
	_bloquear_cinematica()
	_congelar_rival(true)
	await _acercar_para_especial()
	_pose_final_especial(0.95)
	_ejecutar_especial()
	if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		var dir_previa: float = signf(objetivo.global_position.x - global_position.x)
		if dir_previa == 0.0:
			dir_previa = mirando
		objetivo.preparar_impacto_cinematico(1.10, dir_previa, "especial")
	await _mostrar_poder_reemplazando(textura_especial, 1.05, 320.0, true, 2.6)
	_congelar_rival(false)
	_desbloquear_cinematica()
	en_secuencia_especial = false

# 2da carga: especial (reemplaza, en modo normal) -> se transforma ->
# combo -> remate normal (reemplaza) -> vuelve a modo normal.
func _secuencia_rematador() -> void:
	if en_secuencia_especial:
		return
	en_secuencia_especial = true
	_bloquear_cinematica()
	_congelar_rival(true)

	await _acercar_para_especial()
	_pose_final_especial(0.95)
	_ejecutar_especial()
	if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		var dir_previa: float = signf(objetivo.global_position.x - global_position.x)
		if dir_previa == 0.0:
			dir_previa = mirando
		objetivo.preparar_impacto_cinematico(1.00, dir_previa, "especial")
	await _mostrar_poder_reemplazando(textura_especial, 0.95, 320.0, true, 2.4)

	_entrar_furia()
	# Primero la pose de recarga en el lugar actual del luchador; recién
	# después avanza hacia el rival para iniciar el combo automático. Así la
	# ilustración no se monta encima del oponente.
	await _mostrar_recarga_energia(false)
	await _acercar_para_combo_auto()
	await _racha_combo_auto()
	if not esta_derrotado:
		await _ejecutar_rematador()
	_salir_furia()
	_congelar_rival(false)
	_desbloquear_cinematica()
	en_secuencia_especial = false

func _ejecutar_rematador() -> void:
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return
	var distancia: float = absf(objetivo.global_position.x - global_position.x)
	var puede_conectar: bool = distancia <= maxf(rango_patada * 2.8, 360.0)
	var bloqueado: bool = objetivo.bloqueando
	var direccion: float = signf(objetivo.global_position.x - global_position.x)
	if direccion == 0.0:
		direccion = mirando

	# FASE REDISEÑO: el remate del segundo CORE ahora lo da el cuerpo real
	# del luchador (pose propia, escala normal), sin la gigantografía de
	# fondo. Esa ilustración grande queda reservada solo para el remate
	# ABSOLUTO del tercer CORE (ver _ejecutar_finalizacion_absoluta).
	rematador_iniciado.emit()
	_congelar_rival(true)
	if puede_conectar and objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		objetivo.preparar_impacto_cinematico(1.35, direccion, "rematador")
	await _mostrar_remate_personaje(textura_rematador, 1.30)
	_congelar_rival(false)
	if puede_conectar and objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		var dano: float = dano_patada * MULT_DANO_GLOBAL * mult_dano_fase * 2.4
		objetivo.recibir_dano(dano, 520.0, 0.75, direccion, "rematador")
		# FASE IMPACTO: vuelo hacia atrás más largo en el remate (antes
		# 620/360), para que se sienta como un golpe de cierre de combo.
		objetivo.recibir_derribo_especial(direccion, 1045.0 if not bloqueado else 570.0, 505.0 if not bloqueado else 310.0, 0.95 if not bloqueado else 0.45, true)
		_efecto_chispas(bloqueado, objetivo.global_position)
		_onda_impacto_local(objetivo.global_position, color_energia_poder(), 0.85)
		hitstop_timer = 0.08 if not bloqueado else 0.04
		await get_tree().create_timer(0.10, true, false, true).timeout
	rematador_conectado.emit()

# Muestra el remate con el sprite real del personaje (misma escala normal
# calibrada en ESCALAS_POSE_PRECALCULADAS), en vez de una ilustración grande
# de fondo. El personaje queda trabado en esa pose el tiempo indicado.
func _mostrar_remate_personaje(tex: Texture2D, tiempo_visible: float) -> void:
	if not tex or not sprite:
		return
	bloqueo_cinematico = true
	velocity = Vector2.ZERO
	_set_color(Color.WHITE)
	flash_timer = 0.0
	_actualizar_textura(tex)
	pose_timer = tiempo_visible + 0.25
	await get_tree().create_timer(tiempo_visible, true, false, true).timeout

# Tercera carga de la barra en toda la pelea: especial (modo normal) ->
# se transforma -> combo -> remate ABSOLUTO con el póster, cámara lenta.
# Esto termina la partida entera (ver finalizacion_absoluta), no solo la
# ronda -- ya no hay K.O. por vida, gana quien llega primero acá.
func _secuencia_absoluta() -> void:
	if en_secuencia_especial:
		return
	en_secuencia_especial = true
	_bloquear_cinematica()
	_congelar_rival(true)

	await _acercar_para_especial()
	_pose_final_especial(1.0)
	_ejecutar_especial()
	if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		var dir_previa: float = signf(objetivo.global_position.x - global_position.x)
		if dir_previa == 0.0:
			dir_previa = mirando
		objetivo.preparar_impacto_cinematico(1.00, dir_previa, "especial")
	await _mostrar_poder_reemplazando(textura_especial, 0.95, 320.0, true, 2.4)

	_entrar_furia()
	# Igual que en la carga 2: recarga primero en posición, luego avance y
	# combo. La recarga no debe tapar al rival ni salirse de pantalla.
	await _mostrar_recarga_energia(true)
	await _acercar_para_combo_auto()
	await _racha_combo_auto()
	if not esta_derrotado:
		await _ejecutar_finalizacion_absoluta()
	_salir_furia()
	_congelar_rival(false)
	_desbloquear_cinematica()
	en_secuencia_especial = false

func _ejecutar_finalizacion_absoluta() -> void:
	bloqueo_cinematico = true
	velocity = Vector2.ZERO
	_pose_final_especial(3.0)
	finalizacion_absoluta.emit()
	_congelar_rival(true)
	if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		var dir_previa: float = signf(objetivo.global_position.x - global_position.x)
		if dir_previa == 0.0:
			dir_previa = mirando
		objetivo.preparar_impacto_cinematico(2.95, dir_previa, "absoluto")
	await _mostrar_poder_reemplazando(textura_absoluto, 2.80, 430.0)
	_congelar_rival(false)
	if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		var direccion: float = signf(objetivo.global_position.x - global_position.x)
		if direccion == 0.0:
			direccion = mirando
		objetivo.recibir_dano(999.0, 980.0, 1.2, direccion, "absoluto")
		# Este es el que pediste reforzar de nuevo puntualmente: +10%
		# general más un extra propio, así el vuelo se nota claramente
		# más que en especial/rematador.
		objetivo.recibir_derribo_especial(direccion, 1550.0, 680.0, 99.0, false)
		_efecto_chispas(false, objetivo.global_position)
		_onda_impacto_local(objetivo.global_position, color_energia_poder(), 1.6)
		impulso_visual = 1.3
		hitstop_timer = 0.08

func _resolver_aterrizaje_derribo_especial() -> void:
	derribo_especial_esperando_aterrizar = false
	derribo_especial_deslizando = true
	derribo_especial_tiempo_deslizamiento = 0.22 if derribo_especial_se_levanta else 0.34
	velocity.x *= 0.42 if derribo_especial_se_levanta else 0.56
	pose_timer = 0.0
	_actualizar_textura(_tex_derribado())
	var fuerza_caida: float = 430.0 if derribo_especial_se_levanta else 560.0
	_efecto_golpe_suelo(fuerza_caida)
	aterrizaje_hecho.emit(fuerza_caida, true)

func recibir_derribo_especial(direccion: float, fuerza_x: float, fuerza_y: float, tiempo_tendido: float, se_levanta: bool) -> void:
	if esta_derrotado:
		return
	if direccion == 0.0:
		direccion = mirando if mirando != 0.0 else 1.0
	derribo_especial_activo = true
	derribo_especial_esperando_aterrizar = true
	derribo_especial_se_levanta = se_levanta
	derribo_especial_timer = maxf(tiempo_tendido, 0.0)
	derribo_especial_rebote_muro_usado = false
	derribo_especial_deslizando = false
	derribo_especial_tiempo_deslizamiento = 0.0
	recuperacion_post_levantada_timer = 0.0
	bloqueando = false
	bloqueo_timer = 0.0
	en_pose_recarga = false
	# FASE 82: no liberar aquí el congelado del rival. En los remates
	# cinemáticos el oponente debe permanecer controlado hasta que termine
	# el póster/impacto final.
	fase_ataque = FaseAtaque.NINGUNA
	timer_fase_ataque = 0.0
	pose_timer = 0.0
	flash_timer = 0.0
	hitstop_timer = 0.0
	empuje_timer = 0.0
	empuje_x = 0.0
	empuje_pendiente_timer = 0.0
	empuje_pendiente_fuerza = 0.0
	mirando = -signf(direccion)
	# FASE IMPACTO: tope de velocidad de vuelo horizontal más alto (antes
	# 760) -- SOLO lo usan los remates de CORE (rematador/absoluto), nunca
	# los golpes normales, así que subirlo no afecta el combate cuerpo a
	# cuerpo de todos los días.
	velocity.x = clampf((fuerza_x / maxf(_masa_corporal(), 0.65)) * direccion, -1300.0, 1300.0)
	velocity.y = -fuerza_y
	hitstun_timer = maxf(hitstun_timer, 0.9 if se_levanta else 1.35)
	var t: Texture2D = _tex_golpe_recibido()
	if t:
		_actualizar_textura(t)

func _terminar_derribo_especial() -> void:
	derribo_especial_activo = false
	derribo_especial_esperando_aterrizar = false
	derribo_especial_se_levanta = false
	derribo_especial_timer = 0.0
	derribo_especial_rebote_muro_usado = false
	derribo_especial_deslizando = false
	derribo_especial_tiempo_deslizamiento = 0.0
	velocity.x = 0.0
	hitstun_timer = maxf(hitstun_timer, 0.16)
	recuperacion_post_levantada_timer = maxf(recuperacion_post_levantada_timer, 0.22)
	if not esta_derrotado:
		_actualizar_textura(_tex_reposo())

func _masa_corporal() -> float:
	# Masa defensiva: no cambia tamaño ni velocidad máxima. Solo determina
	# cuánto cede cada cuerpo cuando recibe un impacto.
	match nombre_luchador:
		"Magnus": return 1.60
		"Cibor-X": return 1.28
		"Fang": return 1.16
		"Kai": return 1.00
		"Helena": return 0.92
		"Kali": return 0.82
		"Aethel": return 0.78
		_: return 1.00

# --- FASE 74: personalidad física por luchador ---
# Los multiplicadores son deliberadamente cortos para no romper el balance.
# Cambian timing, inercia y presencia corporal; la escala visual permanece fija.
func _mult_startup_personalidad() -> float:
	match nombre_luchador:
		"Aethel": return 0.90
		"Kali": return 0.92
		"Kai": return 0.95
		"Helena": return 0.96
		"Cibor-X": return 1.02
		"Fang": return 1.04
		"Magnus": return 1.10
		_: return 1.0

func _mult_recovery_personalidad() -> float:
	match nombre_luchador:
		"Aethel": return 0.90
		"Kali": return 0.92
		"Helena": return 0.95
		"Kai": return 0.97
		"Cibor-X": return 1.04
		"Fang": return 1.06
		"Magnus": return 1.12
		_: return 1.0

func _mult_lunge_personalidad() -> float:
	match nombre_luchador:
		"Kai": return 1.12
		"Kali": return 1.10
		"Helena": return 1.06
		"Aethel": return 1.05
		"Fang": return 1.04
		"Cibor-X": return 0.96
		"Magnus": return 0.84
		_: return 1.0

func _mult_followthrough_personalidad() -> float:
	match nombre_luchador:
		"Fang": return 1.16
		"Magnus": return 1.12
		"Kai": return 1.10
		"Helena": return 1.02
		"Cibor-X": return 0.98
		"Kali": return 0.94
		"Aethel": return 0.92
		_: return 1.0

func _mult_arranque_carrera() -> float:
	match nombre_luchador:
		"Kali": return 1.18
		"Aethel": return 1.16
		"Kai": return 1.12
		"Helena": return 1.08
		"Fang": return 0.98
		"Cibor-X": return 0.92
		"Magnus": return 0.78
		_: return 1.0

func _mult_ritmo_pasos() -> float:
	match nombre_luchador:
		"Kali": return 1.14
		"Aethel": return 1.12
		"Kai": return 1.07
		"Helena": return 1.04
		"Cibor-X": return 0.96
		"Fang": return 0.94
		"Magnus": return 0.82
		_: return 1.0

func _retencion_horizontal_aterrizaje() -> float:
	match nombre_luchador:
		"Aethel": return 0.91
		"Kali": return 0.89
		"Helena": return 0.85
		"Kai": return 0.82
		"Fang": return 0.76
		"Cibor-X": return 0.70
		"Magnus": return 0.60
		_: return 0.82

func _peso_visual_aterrizaje() -> float:
	return clampf(_masa_corporal(), 0.72, 1.55)

func aplicar_empuje(direccion: float, fuerza: float) -> void:
	var fuerza_final: float = fuerza / _masa_corporal()
	if bloqueando:
		fuerza_final *= 0.40
	# Limita desplazamientos extremos: el golpe puede sentirse pesado sin que
	# el rival salga disparado o atraviese media arena.
	fuerza_final = clampf(fuerza_final, 35.0, 620.0)
	empuje_x = direccion * fuerza_final
	empuje_timer = clampf(0.13 + fuerza_final / 2600.0, 0.14, 0.27)

func _iniciar_bloqueo(duracion: float) -> void:
	bloqueando = true
	bloqueo_timer = duracion
	_set_color(Color.WHITE)
	if pose_timer <= 0.0 and not esta_derrotado:
		_actualizar_textura(_tex_reposo())

func _detener_bloqueo() -> void:
	bloqueando = false
	bloqueo_timer = 0.0
	if flash_timer <= 0.0 and not esta_derrotado:
		_set_color(Color.WHITE)
	if pose_timer <= 0.0 and not esta_derrotado:
		_actualizar_textura(_tex_reposo())

func recibir_dano(cantidad: float, empuje_fuerza: float = 150.0, hitstun: float = 0.25, direccion_atacante: float = 0.0, tipo_impacto: String = "golpe") -> void:
	# Ya no hay K.O. por vida: los golpes siguen empujando y aturdiendo
	# normal, pero la única forma de perder la partida es que el rival
	# llegue a su remate ABSOLUTO (ver finalizacion_absoluta en main.gd).
	var en_bloqueo := bloqueando
	var dano_final := cantidad
	if en_bloqueo:
		dano_final *= 0.35
	vida = max(0.0, vida - dano_final)
	_set_color(Color.WHITE)
	flash_timer = 0.0
	var stun: float = hitstun * 0.5 if en_bloqueo else hitstun
	# Tres niveles físicos de reacción, todos con la MISMA escala corporal.
	# Cambia cuánto cede/inclina el cuerpo, nunca su tamaño.
	var fuerza_relativa: float = empuje_fuerza / _masa_corporal()
	if fuerza_relativa < 155.0:
		nivel_impacto_actual = 1
	elif fuerza_relativa < 300.0:
		nivel_impacto_actual = 2
	else:
		nivel_impacto_actual = 3
	var extra_reaccion: float = 0.04 * float(nivel_impacto_actual - 1)
	_reaccion_impacto_timer = maxf(_reaccion_impacto_timer, minf(stun + 0.08 + extra_reaccion, 0.46))
	_reaccion_impacto_direccion = -sign(direccion_atacante) if direccion_atacante != 0.0 else 1.0
	_reaccion_impacto_fuerza = fuerza_relativa
	impulso_visual = clampf(fuerza_relativa / 190.0, 0.25, 1.20)
	impulso_visual_vel = -_reaccion_impacto_direccion * clampf(fuerza_relativa / 125.0, 0.35, 1.55)
	impacto_visual_y = -float(nivel_impacto_actual) * (0.75 if en_bloqueo else 1.15)
	# Primero absorbe el contacto y luego aparece el desplazamiento. Los
	# golpes pesados tienen una compresión temporal mayor, pero siempre por
	# posición/rotación: la escala visual queda bloqueada.
	absorcion_impacto_timer = 0.020 + float(nivel_impacto_actual) * 0.010
	# Al recibir un golpe, el cuerpo vuelve a orientarse hacia quien atacó.
	# Esto evita la sensación de que un sprite simplemente recibe el impacto
	# de espaldas sin reaccionar.
	if direccion_atacante != 0.0:
		mirando = -sign(direccion_atacante)
	if fuerza_relativa >= 190.0 and is_on_floor():
		_efecto_golpe_suelo(fuerza_relativa)
	hitstop_timer = 0.030 if fuerza_relativa >= 250.0 else (0.018 if fuerza_relativa >= 150.0 else 0.0)

	# Hit-stun real: mientras dure, el que lo recibe no puede hacer nada
	# (ver "comprometido" en _physics_process). Bloqueando, el aturdimiento
	# es la mitad -- por eso bloquear a tiempo importa de verdad ahora.
	hitstun_timer = maxf(hitstun_timer, stun)
	# Rotación de reacciones: cada impacto normal cambia de pose (A -> B -> C).
	if not en_fase_absoluta:
		var reacciones := _lista_golpe_recibido()
		if not reacciones.is_empty():
			indice_golpe_recibido = (indice_golpe_recibido + 1) % reacciones.size()
	_mostrar_pose("golpe_recibido", stun)

	# Si quien llama pasó una dirección, el empuje se aplica directo acá
	# (lo usan los golpes normales, con hitbox propia). Si no la pasó
	# (direccion_atacante = 0), es porque ya lo va a aplicar por su cuenta
	# después -- así los remates/especiales que ya llamaban aplicar_empuje
	# aparte siguen funcionando igual, sin duplicar el empujón.
	if direccion_atacante != 0.0:
		# El empuje ya no ocurre exactamente en el mismo instante del contacto.
		# Primero se lee la pose/recoil y unas centésimas después el cuerpo cede.
		empuje_pendiente_direccion = direccion_atacante
		empuje_pendiente_fuerza = empuje_fuerza
		empuje_pendiente_timer = 0.018 if en_bloqueo else (0.026 + float(nivel_impacto_actual) * 0.006)

	var fuerza_audio: float = maxf(dano_final, empuje_fuerza * 0.08)
	impacto.emit(fuerza_audio)
	impacto_detallado.emit(fuerza_audio, tipo_impacto, en_bloqueo)

func _derrotado() -> void:
	esta_derrotado = true
	en_pose_victoria = false
	if tween_victoria and is_instance_valid(tween_victoria):
		tween_victoria.kill()
	tween_victoria = null
	_set_color(Color(0.2, 0.2, 0.2))
	poder = 0.0
	combo_count = 0
	bloqueando = false
	bloqueo_timer = 0.0
	derribo_especial_activo = false
	derribo_especial_esperando_aterrizar = false
	derribo_especial_se_levanta = false
	derribo_especial_timer = 0.0
	derribo_especial_rebote_muro_usado = false
	derribo_especial_deslizando = false
	derribo_especial_tiempo_deslizamiento = 0.0
	recuperacion_post_levantada_timer = 0.0
	en_secuencia_especial = false
	congelado_por_rival = false
	fase_ataque = FaseAtaque.NINGUNA
	timer_fase_ataque = 0.0
	hitstun_timer = 0.0
	pose_timer = 0.0
	if sprite:
		sprite.visible = true
		_actualizar_textura(_tex_derribado())
	derrotado.emit()

func reiniciar_para_ronda() -> void:
	vida = vida_maxima
	esta_derrotado = false
	en_fase_absoluta = false
	en_pose_victoria = false
	bloqueo_cinematico = false
	if tween_victoria and is_instance_valid(tween_victoria):
		tween_victoria.kill()
	tween_victoria = null
	fase_timer = 0.0
	poder = 0.0
	combo_count = 0
	en_secuencia_especial = false
	congelado_por_rival = false
	derribo_especial_activo = false
	derribo_especial_esperando_aterrizar = false
	derribo_especial_se_levanta = false
	derribo_especial_timer = 0.0
	derribo_especial_rebote_muro_usado = false
	derribo_especial_deslizando = false
	derribo_especial_tiempo_deslizamiento = 0.0
	recuperacion_post_levantada_timer = 0.0
	fase_ataque = FaseAtaque.NINGUNA
	timer_fase_ataque = 0.0
	hitstun_timer = 0.0
	hitstop_timer = 0.0
	pose_timer = 0.0
	flash_timer = 0.0
	empuje_pendiente_timer = 0.0
	empuje_pendiente_fuerza = 0.0
	absorcion_impacto_timer = 0.0
	indice_punetazo = 0
	indice_patada = 0
	indice_golpe_recibido = -1
	indice_caminata = 0
	ciclo_caminata = 0.0
	bloqueando = false
	bloqueo_timer = 0.0
	_set_color(Color.WHITE)
	if sprite:
		sprite.visible = true
		_actualizar_textura(_tex_parado())

# FASE 85 — presentación de victoria. Admite un PNG específico en el futuro
# (textura_victoria), pero desde ahora ya funciona con el arte existente.
func mostrar_pose_victoria() -> void:
	if esta_derrotado:
		return
	en_pose_victoria = true
	bloqueo_cinematico = true
	en_secuencia_especial = false
	congelado_por_rival = false
	bloqueando = false
	fase_ataque = FaseAtaque.NINGUNA
	timer_fase_ataque = 0.0
	hitstun_timer = 0.0
	velocity = Vector2.ZERO
	pose_timer = 999.0
	# Preferimos una pose específica; si aún no existe, Furia parado comunica
	# mejor que una pose neutra y mantiene el tamaño normalizado.
	var tex: Texture2D = textura_victoria
	if not tex:
		tex = textura_furia_parado if textura_furia_parado else textura_parado
	if tex and sprite:
		sprite.visible = true
		sprite.rotation = 0.0
		sprite.modulate = Color.WHITE
		_actualizar_textura(tex)
		if tween_victoria and is_instance_valid(tween_victoria):
			tween_victoria.kill()
		tween_victoria = create_tween()
		tween_victoria.set_loops()
		tween_victoria.tween_property(sprite, "modulate", Color(1.14, 1.14, 1.14, 1.0), 0.45).set_trans(Tween.TRANS_SINE)
		tween_victoria.tween_property(sprite, "modulate", Color.WHITE, 0.45).set_trans(Tween.TRANS_SINE)

# --- Herramientas compartidas para que cada personaje sea chico ---

func _comportamiento_ia_basico(delta: float, vel_actual: float, distancia_ataque: float, distancia_perseguir: float) -> void:
	if esta_derrotado or not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		mover(0.0, vel_actual)
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	var distancia_abs: float = absf(distancia)

	ia_cooldown_decision -= delta
	if ia_cooldown_decision <= 0.0:
		ia_cooldown_decision = randf_range(0.5, 1.1)
		ia_retrocediendo = distancia_abs < distancia_ataque * 1.4 and randf() < ia_prob_retroceso
		if distancia_abs <= distancia_ataque * 1.2 and not bloqueando and randf() < ia_prob_bloqueo:
			_iniciar_bloqueo(randf_range(0.35, 0.7))

	if distancia_abs > distancia_ataque:
		if ia_retrocediendo:
			mover(-sign(distancia), vel_actual)
		elif distancia_abs < distancia_perseguir:
			mover(sign(distancia), vel_actual)
		else:
			mover(0.0, vel_actual)
	else:
		if ia_retrocediendo:
			mover(-sign(distancia), vel_actual)
		else:
			mover(0.0, vel_actual)
		mirando = sign(distancia)
		if not bloqueando:
			if randf() < ia_prob_patada:
				intentar_patada()
			else:
				intentar_punetazo()

func _mult_cuerpo_actual() -> float:
	# Fase Absoluta ya NO agranda a los personajes -- solo cambia color.
	# Se dejó la función (en vez de borrarla) porque la usan la caja de
	# colisión y el anclaje de los pósters, así el tamaño queda parejo
	# siempre sin tener que tocar esos otros lugares.
	return MULT_TAMANO_GLOBAL * mult_tamano_extra

func _alto_cuerpo_efectivo() -> float:
	return alto_cuerpo * _mult_cuerpo_actual()

func _altura_visible_objetivo() -> float:
	var ajuste: float = float(ALTURA_AJUSTES_VISUALES.get(nombre_luchador, 1.0))
	return ALTURA_VISIBLE_NORMAL_GLOBAL * ajuste

# Oculta el sprite del personaje y lo reemplaza por la ilustración del
# poder (especial / remate / absoluto) durante un rato, PARADA EN EL
# MISMO PISO que el personaje (igual que el sprite normal: ancla por
# abajo, no por el centro) y a una altura pareja a la del rival. Le suma
# pulso + anillos de energía + rayitos animados alrededor para que no se
# sienta una estampita pegada, sino algo con vida. Al terminar, vuelve a
# mostrar al personaje. Se usa con "await" para que quien la llama pueda
# esperar a que termine antes de seguir con el combo.
func _mostrar_poder_reemplazando(tex: Texture2D, tiempo_visible: float, alto_deseado: float, aplicar_impacto: bool = false, multiplicador_dano: float = 2.4) -> void:
	if not tex or not sprite:
		return

	# El personaje permanece visible y bloqueado en la pose final del golpe.
	# La ilustración grande vive detrás como apoyo cinematográfico; nunca
	# reemplaza al cuerpo del luchador.
	bloqueo_cinematico = true
	velocity = Vector2.ZERO
	_pose_final_especial(tiempo_visible + 0.25)
	var img := Sprite2D.new()
	img.texture = tex
	img.centered = true
	# Más atrás en la composición: queda claramente detrás del luchador y de
	# sus efectos de primer plano, pero sigue dentro del mundo de la pelea.
	img.z_index = -4
	# FASE 84: los PÓSTERS/PODERES vuelven al tamaño cinematográfico que tenían
	# antes de la 83. Esta escala es independiente de la escala corporal de
	# golpes/recibir golpes, que se mantiene calibrada y estable.
	var esc: float = alto_deseado / maxf(float(tex.get_height()), 1.0)
	img.scale = Vector2(esc, esc)
	img.flip_h = mirando < 0.0
	var pos_base := Vector2(-mirando * 18.0, -(float(tex.get_height()) * esc) / 2.0 - 18.0)
	img.position = pos_base

	# El póster se ve como arte integrado detrás del personaje.
	# No usamos ninguna placa/rectángulo: el oscurecimiento vive en el propio
	# póster. Ahora tiene más presencia y menos transparencia, y el Absoluto
	# recibe un poco más de fuerza visual que los poderes 1/2.	
	var es_absoluto: bool = tex == textura_absoluto
	var alpha_poster: float = 0.90 if es_absoluto else 0.84
	var tono_poster: Color = Color(0.66, 0.68, 0.74, 0.0)
	img.modulate = tono_poster
	var escala_inicial: Vector2 = Vector2(esc, esc)
	var escala_final: Vector2 = Vector2(esc, esc)
	img.scale = escala_inicial
	add_child(img)

	# Halo de poder sobre el piso: el golpe especial "enciende" el suelo
	# sin cubrir la pantalla con otra placa. Es muy sutil y queda detrás
	# del luchador/póster.
	var halo_piso := Polygon2D.new()
	halo_piso.polygon = _elipse_poder_poligono(74.0, 10.0)
	halo_piso.color = Color(color_energia_poder().r, color_energia_poder().g, color_energia_poder().b, 0.0)
	halo_piso.position = Vector2(0.0, 3.0)
	halo_piso.z_index = -1
	add_child(halo_piso)

	var tw_halo := create_tween()
	tw_halo.set_parallel(true)
	tw_halo.tween_property(halo_piso, "modulate:a", 0.22, 0.16)
	tw_halo.tween_property(halo_piso, "scale", Vector2(1.18, 1.0), 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(img, "modulate:a", alpha_poster, 0.12)
	tween.tween_property(img, "scale", escala_final, 0.01)
	tween.set_parallel(false)
	tween.tween_interval(tiempo_visible)
	tween.tween_property(img, "modulate:a", 0.0, 0.30)

	# El póster ya no pulsa de tamaño. La energía vive en luz/partículas;
	# la escala permanece clavada para no reintroducir el efecto de "crecer".
	var tween_pulso := create_tween()
	tween_pulso.set_loops()
	tween_pulso.tween_property(img, "modulate:a", alpha_poster * 0.96, 0.24)
	tween_pulso.tween_property(img, "modulate:a", alpha_poster, 0.24)

	# Capa de aura profunda: muy tenue, detrás del póster, para que el poder
	# parezca emitir energía hacia el escenario en vez de ser una imagen plana.
	var aura_fondo := Polygon2D.new()
	aura_fondo.polygon = _elipse_poder_poligono(145.0 if es_absoluto else 120.0, 42.0 if es_absoluto else 34.0)
	aura_fondo.position = Vector2(-mirando * 28.0, 4.0)
	aura_fondo.color = Color(color_energia_poder().r, color_energia_poder().g, color_energia_poder().b, 0.0)
	aura_fondo.z_index = -5
	add_child(aura_fondo)
	var tw_aura := create_tween()
	tw_aura.set_parallel(true)
	tw_aura.tween_property(aura_fondo, "modulate:a", 0.12 if not es_absoluto else 0.17, 0.20)
	tw_aura.tween_property(aura_fondo, "scale", Vector2(1.08, 1.0), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	_animar_energia_poder(pos_base, tiempo_visible + 0.5)

	var impacto_pendiente: bool = aplicar_impacto

	await tween.finished
	tween_pulso.kill()
	if is_instance_valid(halo_piso):
		var tw_halo_out := create_tween()
		tw_halo_out.tween_property(halo_piso, "modulate:a", 0.0, 0.18)
		await tw_halo_out.finished
		halo_piso.queue_free()
	if is_instance_valid(aura_fondo):
		var tw_aura_out := create_tween()
		tw_aura_out.tween_property(aura_fondo, "modulate:a", 0.0, 0.16)
		await tw_aura_out.finished
		aura_fondo.queue_free()
	img.queue_free()
	if impacto_pendiente:
		_aplicar_impacto_especial(multiplicador_dano)
	velocity = Vector2.ZERO


func _elipse_poder_poligono(rx: float, ry: float) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	for i in range(24):
		var a: float = TAU * float(i) / 24.0
		puntos.append(Vector2(cos(a) * rx, sin(a) * ry))
	return puntos

func color_energia_poder() -> Color:
	return color_fase if color_fase else color_base


# Dispara anillos que se expanden y se desvanecen, y un par de rayos
# cortos que titilan, alrededor del póster -- para que se sienta como
# energía activa y no una imagen fija. Todo con Line2D/Polygon2D, sin
# arte nuevo.
func _animar_energia_poder(centro: Vector2, duracion: float) -> void:
	var color_energia: Color = color_fase if color_fase else Color(1.0, 1.0, 1.0)
	var t := 0.0
	var proximo_anillo := 0.0
	var proximo_rayo := 0.15
	while t < duracion:
		if t >= proximo_anillo:
			_spawn_anillo_energia(centro, color_energia)
			proximo_anillo = t + 0.5
		if t >= proximo_rayo:
			_spawn_rayo_energia(centro, color_energia)
			proximo_rayo = t + randf_range(0.35, 0.6)
		await get_tree().create_timer(0.1, true, false, true).timeout
		t += 0.1

func _spawn_anillo_energia(centro: Vector2, color: Color) -> void:
	var anillo := Line2D.new()
	anillo.width = 4.0
	anillo.default_color = Color(color.r, color.g, color.b, 0.8)
	anillo.z_index = 4
	var puntos := PackedVector2Array()
	for i in range(33):
		var ang: float = (TAU / 32.0) * i
		puntos.append(Vector2(cos(ang), sin(ang) * 0.55) * 20.0)
	anillo.points = puntos
	anillo.position = centro
	add_child(anillo)

	var radio_final := randf_range(90.0, 150.0)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(anillo, "scale", Vector2.ONE * (radio_final / 20.0), 0.6).set_trans(Tween.TRANS_SINE)
	tw.tween_property(anillo, "modulate:a", 0.0, 0.6)
	tw.chain().tween_callback(anillo.queue_free)

func _spawn_rayo_energia(centro: Vector2, color: Color) -> void:
	var rayo := Line2D.new()
	rayo.width = 3.0
	rayo.default_color = Color(1.0, 1.0, 1.0, 0.9).lerp(color, 0.3)
	rayo.z_index = 6
	var ang: float = randf_range(0.0, TAU)
	var dist: float = randf_range(60.0, 130.0)
	var punta := Vector2(cos(ang), sin(ang) * 0.6) * dist
	var medio := punta * 0.5 + Vector2(randf_range(-18.0, 18.0), randf_range(-18.0, 18.0))
	rayo.points = PackedVector2Array([Vector2.ZERO, medio, punta])
	rayo.position = centro
	add_child(rayo)

	var tw := create_tween()
	tw.tween_property(rayo, "modulate:a", 0.0, 0.18)
	tw.tween_callback(rayo.queue_free)

func _onda_impacto_local(centro_global: Vector2, color: Color, intensidad: float = 1.0) -> void:
	var onda := Polygon2D.new()
	onda.polygon = _elipse_poder_poligono(18.0, 5.0)
	onda.position = to_local(centro_global)
	onda.color = Color(color.r, color.g, color.b, 0.30)
	onda.z_index = 88
	add_child(onda)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(onda, "scale", Vector2(5.0 * intensidad, 2.1 * intensidad), 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(onda, "modulate:a", 0.0, 0.22)
	tw.chain().tween_callback(onda.queue_free)

func _efecto_chispas(bloqueado: bool = false, centro_global: Vector2 = Vector2.INF, intensidad: float = 1.0) -> void:
	var offset_base: float = 0.0
	if mirando <= 0.0:
		offset_base = PI

	var color_chispa := Color(1.0, 0.9, 0.4)
	if bloqueado:
		color_chispa = Color(0.5, 0.85, 1.0)

	var centro := Vector2(mirando * (ancho_cuerpo / 2.0 + 15.0), -alto_cuerpo * 0.6)
	if centro_global != Vector2.INF:
		centro = to_local(centro_global)
	var cantidad_chispas: int = clampi(int(round(6.0 + intensidad * 3.0)), 6, 11)
	for i in range(cantidad_chispas):
		var chispa := Polygon2D.new()
		var s: float = 3.2 + intensidad * 0.8
		chispa.polygon = PackedVector2Array([Vector2(-s, 0), Vector2(0, -s), Vector2(s, 0), Vector2(0, s)])
		chispa.color = color_chispa
		chispa.position = centro
		chispa.z_index = 90
		add_child(chispa)

		var angulo: float = randf_range(-0.6, 0.6) + offset_base
		var dist: float = randf_range(26.0, 52.0 + intensidad * 13.0)
		var destino: Vector2 = centro + Vector2(cos(angulo), sin(angulo) - 0.5) * dist

		var tween := create_tween()
		tween.tween_property(chispa, "position", destino, 0.25)
		tween.parallel().tween_property(chispa, "modulate:a", 0.0, 0.25)
		tween.tween_callback(chispa.queue_free)

	_particulas_impacto_gpu(centro, color_chispa, intensidad)

# Estallido de partículas GPU reales en el punto de contacto: polvo/chispa
# fina que acompaña a las chispas de siempre, con caída por gravedad y
# variación real de velocidad/rotación por partícula. No reemplaza nada,
# se suma en el mismo momento en que ya se llama a _efecto_chispas.
func _particulas_impacto_gpu(centro_local: Vector2, color: Color, intensidad: float = 1.0) -> void:
	var particulas := GPUParticles2D.new()
	particulas.texture = _obtener_textura_particula()
	particulas.position = centro_local
	particulas.z_index = 91
	var cantidad: int = clampi(int(round(10.0 + intensidad * 6.0)), 10, 22)
	particulas.amount = cantidad
	particulas.lifetime = 0.5
	particulas.one_shot = true
	particulas.explosiveness = 0.9
	particulas.speed_scale = 1.35

	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0.0, -1.0, 0.0)
	mat.spread = 180.0
	mat.gravity = Vector3(0.0, 420.0, 0.0)
	mat.initial_velocity_min = 50.0 * intensidad
	mat.initial_velocity_max = 170.0 * intensidad
	mat.angular_velocity_min = -420.0
	mat.angular_velocity_max = 420.0
	mat.damping_min = 35.0
	mat.damping_max = 95.0
	mat.scale_min = 0.30
	mat.scale_max = 0.65 + intensidad * 0.25
	# FASE 98: color llevado por encima de 1.0 en RGB (sin tocar el alpha)
	# para que estas partículas sí crucen el umbral de Glow y "prendan" de
	# verdad, en vez de depender de que el color base ya sea lo bastante
	# brillante por casualidad.
	mat.color = Color(color.r * 1.6, color.g * 1.6, color.b * 1.6, color.a)

	var curva := Curve.new()
	curva.add_point(Vector2(0.0, 0.15))
	curva.add_point(Vector2(0.12, 1.0))
	curva.add_point(Vector2(1.0, 0.0))
	var curva_tex := CurveTexture.new()
	curva_tex.curve = curva
	mat.scale_curve = curva_tex

	particulas.process_material = mat
	add_child(particulas)
	particulas.emitting = true

	var t := get_tree().create_timer(particulas.lifetime + 0.2, true, false, true)
	t.timeout.connect(particulas.queue_free)

func _efecto_estallido(color: Color, radio: float, dano_base: float) -> void:
	var dano := dano_base * MULT_DANO_GLOBAL
	var estallido := Polygon2D.new()
	var puntos := PackedVector2Array()
	var lados := 16
	for i in range(lados):
		var angulo: float = (TAU / lados) * i
		puntos.append(Vector2(cos(angulo), sin(angulo)) * 10.0)
	estallido.polygon = puntos
	estallido.color = color
	estallido.position = Vector2(0, -alto_cuerpo / 2.0)
	add_child(estallido)

	var radio_final := radio / 10.0
	var tween := create_tween()
	tween.tween_property(estallido, "scale", Vector2(radio_final, radio_final), 0.3)
	tween.parallel().tween_property(estallido, "modulate:a", 0.0, 0.3)
	tween.tween_callback(estallido.queue_free)

	if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		# Los poderes tienen alcance de arena. El efecto puede nacer alrededor
		# del personaje, pero la colisión llega al rival aunque esté algo más
		# lejos que el radio visual del estallido.
		var distancia: float = absf(objetivo.global_position.x - global_position.x)
		var alcance_poder: float = maxf(radio * 2.8, 480.0)
		if distancia <= alcance_poder:
			var direccion: float = signf(objetivo.global_position.x - global_position.x)
			if direccion == 0.0:
				direccion = mirando
			objetivo.recibir_dano(dano, 360.0, 0.55, direccion, "especial")
			_registrar_golpe_conectado()

# --- Helpers internos que abstraen "sprite real" vs "rectángulo" ---

func _crear_sombra_dinamica() -> void:
	sombra = Polygon2D.new()
	sombra.polygon = PackedVector2Array([
		Vector2(-30, 0), Vector2(-21, -3), Vector2(-10, -5), Vector2(0, -6),
		Vector2(10, -5), Vector2(21, -3), Vector2(30, 0),
		Vector2(21, 3), Vector2(10, 5), Vector2(0, 6),
		Vector2(-10, 5), Vector2(-21, 3)
	])
	sombra.color = Color(0.01, 0.01, 0.015, 0.34)
	sombra.position = Vector2(0, 3)
	sombra.z_index = -5
	add_child(sombra)

func _actualizar_sombra() -> void:
	if not sombra:
		return
	var altura := clampf(SUELO_REFERENCIA_Y - global_position.y, 0.0, 320.0)
	var factor := clampf(1.0 - altura / 260.0, 0.42, 1.0)
	sombra.scale = Vector2(1.0 + (1.0 - factor) * 0.25, factor)
	sombra.modulate.a = 0.34 * factor

func _actualizar_sensacion_fisica(delta: float) -> void:
	if not sprite:
		return

	asentamiento_aterrizaje = move_toward(asentamiento_aterrizaje, 0.0, 5.0 * delta)
	impacto_visual_y = move_toward(impacto_visual_y, 0.0, 28.0 * delta)
	seguimiento_ataque_x = move_toward(seguimiento_ataque_x, 0.0, 34.0 * delta)
	anticipacion_ataque_x = move_toward(anticipacion_ataque_x, 0.0, 30.0 * delta)
	impulso_visual_vel = move_toward(impulso_visual_vel, 0.0, 24.0 * delta)
	impulso_visual = move_toward(impulso_visual, 0.0, (9.0 + peso_golpe * 4.0) * delta)
	if _reaccion_impacto_timer > 0.0:
		var direccion_impacto: float = _reaccion_impacto_direccion
		var fuerza_impacto: float = clampf(_reaccion_impacto_fuerza / 240.0, 0.0, 1.0)
		impulso_visual_vel += direccion_impacto * fuerza_impacto * 5.0
		_reaccion_impacto_timer -= delta

	_actualizar_sombra()
	var base: float = escala_actual
	var sx: float = 1.0
	var sy: float = 1.0
	var vel_ratio: float = clampf(absf(velocity.x) / maxf(velocidad, 1.0), 0.0, 1.0)
	var aceleracion_visual: float = absf(velocity.x - ultima_velocidad_x) / maxf(delta * maxf(velocidad, 1.0), 1.0)
	ultima_velocidad_x = velocity.x

	if en_el_aire:
		var velocidad_vertical: float = clampf(absf(velocity.y) / 800.0, 0.0, 1.0)
		sx = 1.0 - velocidad_vertical * 0.007
		sy = 1.0 + velocidad_vertical * 0.010
	else:
		sx = 1.0 + vel_ratio * 0.006
		sy = 1.0 - vel_ratio * 0.005
		if aceleracion_visual > 0.45:
			sx *= 1.004
			sy *= 0.996

	if _reaccion_impacto_timer > 0.0:
		var recoil: float = clampf(_reaccion_impacto_fuerza * 0.016, 1.0, 8.5)
		sprite.position.x = _sprite_ancla_x() - _reaccion_impacto_direccion * recoil

	var base_rot: float = impulso_visual * 0.006
	# Escala física bloqueada: golpes, impacto, salto y recoil NO pueden
	# agrandar/achicar al luchador. Solo el atacante del combo automático
	# recibe un +7% cinematográfico muy controlado.
	var mult_combo: float = 1.0
	sprite.scale = Vector2(base * mult_combo, base * mult_combo)
	sprite.rotation = lerpf(sprite.rotation, base_rot, 1.0 - exp(-15.0 * delta))
	_actualizar_expresion_mecanica(delta)
	# Offset de impacto/follow-through aplicado DESPUÉS de la expresión para
	# que no sea pisado. Es posición pura; la escala queda bloqueada.
	sprite.position.x += seguimiento_ataque_x + anticipacion_ataque_x
	sprite.position.y += impacto_visual_y
	_actualizar_luz_contacto(vel_ratio, _reaccion_impacto_timer > 0.0)
	_actualizar_sombra_dinamica(vel_ratio)
	_actualizar_estela_movimiento(delta, vel_ratio)
	if sprite.material:
		sprite.material.set_shader_parameter("en_furia", en_fase_absoluta)

func _actualizar_sombra_dinamica(vel_ratio: float) -> void:
	if not sombra:
		return
	var direccion: float = signf(velocity.x) if absf(velocity.x) > 8.0 else 0.0
	sombra.position.x = clampf(direccion * vel_ratio * 5.5, -5.5, 5.5)
	sombra.scale.x = 1.0 + vel_ratio * 0.12

func _actualizar_estela_movimiento(delta: float, vel_ratio: float) -> void:
	if not sprite or not capa_estela:
		return
	estela_timer -= delta
	var velocidad_abs: float = absf(velocity.x)
	var debe_crear: bool = velocidad_abs >= maxf(300.0, velocidad * 0.95)
	debe_crear = debe_crear or (fase_ataque == FaseAtaque.ACTIVO and velocidad_abs > 120.0)
	if not debe_crear or estela_timer > 0.0 or en_secuencia_especial or esta_derrotado:
		return
	estela_timer = 0.085

	var eco := Sprite2D.new()
	eco.texture = sprite.texture
	eco.centered = sprite.centered
	eco.position = sprite.position - Vector2(signf(velocity.x) * 7.0, 0.0)
	eco.rotation = sprite.rotation
	eco.scale = sprite.scale
	eco.flip_h = sprite.flip_h
	var c: Color = Color(color_energia_poder().r, color_energia_poder().g, color_energia_poder().b, 0.10)
	eco.modulate = c
	eco.z_index = -1
	capa_estela.add_child(eco)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(eco, "modulate:a", 0.0, 0.13).set_trans(Tween.TRANS_SINE)
	tw.tween_property(eco, "scale", sprite.scale * 0.985, 0.13).set_trans(Tween.TRANS_SINE)
	tw.chain().tween_callback(eco.queue_free)

func _actualizar_expresion_mecanica(delta: float) -> void:
	if not sprite or esta_derrotado:
		return

	var objetivo_inclinacion: float = 0.0
	var objetivo_x: float = _sprite_ancla_x()
	var tension: float = 0.0
	var micro_balance: float = sin(Time.get_ticks_msec() * 0.0024 + float(get_instance_id() % 17))
	var peso_cuerpo: float = 1.0
	if nombre_luchador == "Magnus":
		peso_cuerpo = 1.35
	elif nombre_luchador == "Kali" or nombre_luchador == "Aethel":
		peso_cuerpo = 0.72
	elif nombre_luchador == "Cibor-X":
		peso_cuerpo = 1.18

	if bloqueando:
		objetivo_inclinacion = -0.030 * mirando * peso_cuerpo
		objetivo_x -= 2.2 * mirando
		tension = 0.55
	elif fase_ataque == FaseAtaque.STARTUP:
		objetivo_inclinacion = -0.050 * mirando * peso_cuerpo
		objetivo_x -= (2.5 + peso_cuerpo) * mirando
		tension = 0.45
	elif fase_ataque == FaseAtaque.ACTIVO:
		objetivo_inclinacion = 0.030 * mirando * peso_cuerpo
		objetivo_x += (3.5 + peso_cuerpo * 1.4) * mirando
		tension = 0.82
	elif hitstun_timer > 0.0 or _reaccion_impacto_timer > 0.0:
		var nivel_reaccion: float = clampf(float(nivel_impacto_actual), 1.0, 3.0)
		objetivo_inclinacion = (0.026 + nivel_reaccion * 0.012) * _reaccion_impacto_direccion * peso_cuerpo
		objetivo_x -= minf(_reaccion_impacto_fuerza * (0.010 + nivel_reaccion * 0.002), 7.5) * _reaccion_impacto_direccion
		tension = 0.72 + nivel_reaccion * 0.09
	elif en_pose_recarga:
		# Durante la recarga el cuerpo queda clavado en la pose propia del PNG,
		# con una vibración mínima para que el zoom se lea claro y estable.
		objetivo_inclinacion = micro_balance * 0.003
		objetivo_x = _sprite_ancla_x()
		tension = 1.0
	elif en_secuencia_especial:
		# Tensión previa al poder: postura firme, orientada al lanzamiento.
		objetivo_inclinacion = micro_balance * 0.006 - mirando * 0.012
		objetivo_x -= 1.2 * mirando
		tension = 1.0
	else:
		var moviendo: bool = is_on_floor() and absf(velocity.x) > 10.0
		if moviendo:
			var velocidad_relativa: float = clampf(velocity.x / maxf(velocidad, 1.0), -1.0, 1.0)
			var inclinacion_extra_carrera: float = 0.0
			if carrera_activa:
				inclinacion_extra_carrera = -0.012 * float(carrera_direccion) * peso_cuerpo
			objetivo_inclinacion = clampf(-velocidad_relativa * 0.020 * peso_cuerpo + inclinacion_extra_carrera, -0.045, 0.045)
			objetivo_x += micro_balance * 0.45 - velocidad_relativa * (1.65 if carrera_activa else 1.3)
			# Al cambiar de sentido aparece una micro-contraposición antes de asentarse.
			if ultima_direccion_movimiento != 0.0 and signf(velocity.x) != ultima_direccion_movimiento and absf(velocity.x) > 28.0:
				objetivo_inclinacion *= 0.55
		else:
			objetivo_inclinacion = micro_balance * 0.006 - asentamiento_aterrizaje * 0.014 * peso_cuerpo
			objetivo_x += micro_balance * 0.35

	if absf(velocity.x) > 18.0:
		ultima_direccion_movimiento = signf(velocity.x)

	estado_visual_tension = lerpf(estado_visual_tension, tension, 1.0 - exp(-9.0 * delta))
	estado_visual_balance = lerpf(estado_visual_balance, micro_balance, 1.0 - exp(-5.0 * delta))
	# La escala queda completamente estable entre poses.
	# La sensación de respiración/peso se expresa con posición y rotación,
	# nunca encogiendo el sprite, para evitar el bug de "papel que se achica".
	var mult_combo: float = 1.0
	sprite.scale = Vector2(escala_actual * mult_combo, escala_actual * mult_combo)
	sprite.rotation = lerpf(sprite.rotation, objetivo_inclinacion, 1.0 - exp(-18.0 * delta))
	sprite.position.x = lerpf(sprite.position.x, objetivo_x, 1.0 - exp(-18.0 * delta))

func _actualizar_expresion_facial(delta: float) -> void:
	if not capa_facial or not sprite or esta_derrotado:
		return

	# La capa acompaña exactamente al sprite para que la expresión no se
	# despegue durante zooms, recoil, inclinación o animaciones.
	capa_facial.position = sprite.position
	capa_facial.rotation = sprite.rotation
	capa_facial.scale = sprite.scale

	# Expresión procedural sutil por estado: no dibuja una cara nueva ni
	# altera la proporción del personaje; solo mueve la capa facial unos
	# píxeles para acompañar la intención corporal.
	var objetivo_exp_y: float = 0.0
	var objetivo_exp_x: float = 0.0
	var objetivo_exp_rot: float = 0.0
	if bloqueando:
		objetivo_exp_y = 1.2
		objetivo_exp_rot = -0.010 * mirando
		fase_expresion = 0.85
	elif fase_ataque == FaseAtaque.STARTUP:
		objetivo_exp_x = -0.7 * mirando
		objetivo_exp_y = -0.9
		objetivo_exp_rot = -0.008 * mirando
		fase_expresion = 0.9
	elif fase_ataque == FaseAtaque.ACTIVO:
		objetivo_exp_x = 1.1 * mirando
		objetivo_exp_y = -0.5
		fase_expresion = 1.0
	elif hitstun_timer > 0.0 or _reaccion_impacto_timer > 0.0:
		objetivo_exp_x = -1.3 * _reaccion_impacto_direccion
		objetivo_exp_y = 1.0
		objetivo_exp_rot = 0.012 * _reaccion_impacto_direccion
		fase_expresion = 1.0
	elif en_secuencia_especial or en_fase_absoluta:
		objetivo_exp_y = -1.0
		fase_expresion = 1.0
	else:
		fase_expresion = 0.15 + clampf(poder / maxf(poder_maximo, 1.0), 0.0, 1.0) * 0.35
	capa_facial.position += Vector2(objetivo_exp_x, objetivo_exp_y)
	capa_facial.rotation += objetivo_exp_rot

	var quieto: bool = is_on_floor() and absf(velocity.x) <= 10.0 and not bloqueando \
		and pose_timer <= 0.0 and hitstun_timer <= 0.0 and fase_ataque == FaseAtaque.NINGUNA \
		and not en_secuencia_especial and not bloqueo_cinematico

	if not quieto:
		parpadeo_fase = 0
		parpadeo_progreso = 0.0
		parpadeo_cooldown = 0.0
		if parpado_izq:
			parpado_izq.visible = false
			parpado_der.visible = false
			parpado_izq.scale.y = 0.0
			parpado_der.scale.y = 0.0
		return

	parpadeo_timer -= delta
	if parpadeo_fase == 0 and parpadeo_timer <= 0.0:
		parpadeo_fase = 1
		parpadeo_progreso = 0.0

	# FASE 90.5: se termina de conectar la animación (antes quedaba
	# calculada pero nunca aplicada -- parpado_izq/der se forzaban a
	# invisible siempre, con la posición vieja mal calibrada). Ahora la
	# cobertura del párpado (scale.y, 0 = ojo abierto, 1 = cerrado) sigue
	# el progreso real: cierra rápido en la fase 1 y abre un poco más
	# lento en la fase 2, como un parpadeo natural. Solo corre para
	# personajes calibrados en DATOS_CARA (parpado_izq queda null para
	# el resto, así que esto no hace nada en ellos).
	if parpadeo_fase == 1:
		parpadeo_progreso += delta / 0.055
		if parpado_izq:
			var cobertura: float = clampf(parpadeo_progreso, 0.0, 1.0)
			parpado_izq.visible = true
			parpado_der.visible = true
			parpado_izq.scale.y = cobertura
			parpado_der.scale.y = cobertura
		if parpadeo_progreso >= 1.0:
			parpadeo_fase = 2
			parpadeo_progreso = 0.0
	elif parpadeo_fase == 2:
		parpadeo_progreso += delta / 0.07
		var apertura: float = 1.0 - clampf(parpadeo_progreso, 0.0, 1.0)
		if parpado_izq:
			parpado_izq.visible = apertura > 0.02
			parpado_der.visible = apertura > 0.02
			parpado_izq.scale.y = apertura
			parpado_der.scale.y = apertura
		if parpadeo_progreso >= 1.0:
			parpadeo_fase = 0
			parpadeo_timer = randf_range(2.0, 4.2)
			if parpado_izq:
				parpado_izq.visible = false
				parpado_der.visible = false
				parpado_izq.scale.y = 0.0
				parpado_der.scale.y = 0.0

func _crear_aura_core() -> void:
	if aura_core or not sprite:
		return
	aura_core = Polygon2D.new()
	aura_core.name = "AuraCore"
	aura_core.polygon = _crear_elipse_local(46.0, 12.0)
	aura_core.position = Vector2(0.0, -2.0)
	aura_core.z_index = -3
	aura_core.color = Color(color_energia_poder().r, color_energia_poder().g, color_energia_poder().b, 0.0)
	add_child(aura_core)

func _actualizar_aura_core(delta: float) -> void:
	if not aura_core:
		return
	var carga: float = clampf(poder / maxf(poder_maximo, 1.0), 0.0, 1.0)
	var objetivo_alpha: float = 0.0
	if not esta_derrotado and not en_secuencia_especial and not en_fase_absoluta and carga >= 0.65:
		objetivo_alpha = lerpf(0.018, 0.075, (carga - 0.65) / 0.35)
	var pulso: float = 0.86 + sin(Time.get_ticks_msec() * 0.004 + float(get_instance_id() % 19)) * 0.14
	aura_core.modulate.a = lerpf(aura_core.modulate.a, objetivo_alpha * pulso, 1.0 - exp(-7.0 * delta))
	aura_core.scale = aura_core.scale.lerp(Vector2(1.0 + carga * 0.08, 1.0 + carga * 0.035), 1.0 - exp(-6.0 * delta))

func _crear_luz_contacto() -> void:
	luz_contacto = Polygon2D.new()
	luz_contacto.polygon = _crear_elipse_local(44.0, 10.0)
	luz_contacto.position = Vector2(0.0, 1.0)
	luz_contacto.z_index = -4
	luz_contacto.color = Color(color_base.r, color_base.g, color_base.b, 0.045)
	add_child(luz_contacto)

func _crear_elipse_local(rx: float, ry: float) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	for i in range(20):
		var ang: float = TAU * float(i) / 20.0
		puntos.append(Vector2(cos(ang) * rx, sin(ang) * ry))
	return puntos

func _actualizar_luz_contacto(vel_ratio: float, en_impacto: bool) -> void:
	if not luz_contacto:
		return
	var ancho: float = 0.92 + vel_ratio * 0.20
	var alto: float = 0.92 - vel_ratio * 0.10
	if en_impacto:
		ancho += 0.16
		alto += 0.08
	luz_contacto.scale = Vector2(ancho, alto)
	var alpha: float = 0.045 + (0.022 if en_impacto else 0.0)
	luz_contacto.color = Color(color_base.r, color_base.g, color_base.b, alpha)

func _efecto_paso(lado: int) -> void:
	if not is_on_floor() or esta_derrotado or en_secuencia_especial:
		return
	var intensidad: float = clampf(absf(velocity.x) / maxf(velocidad, 1.0), 0.15, 1.0)
	var corriendo: bool = absf(velocity.x) > velocidad * 1.18
	var humo := Polygon2D.new()
	var tam: float = 1.8 + intensidad * (3.0 if corriendo else 2.4)
	humo.polygon = PackedVector2Array([Vector2(-tam,0), Vector2(0,-tam*0.5), Vector2(tam,0), Vector2(0,tam*0.45)])
	humo.color = Color(0.70, 0.67, 0.62, 0.11 + intensidad * (0.14 if corriendo else 0.10))
	humo.position = Vector2(lado * 6.0, -1.0)
	humo.z_index = -1
	add_child(humo)
	var destino := humo.position + Vector2(lado * randf_range(5.0, 11.0 if not corriendo else 14.0), randf_range(-5.0, -1.0))
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(humo, "position", destino, 0.20).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(humo, "scale", Vector2(1.8 if not corriendo else 2.1, 0.7), 0.20)
	tw.tween_property(humo, "modulate:a", 0.0, 0.20)
	tw.chain().tween_callback(humo.queue_free)
	if corriendo:
		var estela := Polygon2D.new()
		estela.polygon = PackedVector2Array([Vector2(-tam * 0.6, 0), Vector2(0, -tam * 0.28), Vector2(tam * 0.6, 0), Vector2(0, tam * 0.24)])
		estela.color = Color(0.78, 0.75, 0.70, 0.08 + intensidad * 0.08)
		estela.position = Vector2(lado * 2.0, -0.5)
		estela.z_index = -1
		add_child(estela)
		var tw2 := create_tween()
		tw2.set_parallel(true)
		tw2.tween_property(estela, "position", estela.position + Vector2(lado * randf_range(10.0, 16.0), randf_range(-3.0, -0.5)), 0.16)
		tw2.tween_property(estela, "scale", Vector2(2.0, 0.55), 0.16)
		tw2.tween_property(estela, "modulate:a", 0.0, 0.16)
		tw2.chain().tween_callback(estela.queue_free)

func _efecto_golpe_suelo(fuerza: float) -> void:
	# Cuando un golpe realmente pesado impacta a alguien que está plantado,
	# el suelo responde un instante después con polvo/fragmentos. Es un
	# detalle pequeño, pero ayuda muchísimo a vender masa.
	var intensidad := clampf(fuerza / 420.0, 0.35, 1.0)
	for i in range(5):
		var fragmento := Polygon2D.new()
		var tam := randf_range(2.0, 4.0) * intensidad
		fragmento.polygon = PackedVector2Array([
			Vector2(-tam, 0), Vector2(0, -tam * 0.7),
			Vector2(tam, 0), Vector2(0, tam * 0.5)
		])
		fragmento.color = Color(0.68, 0.64, 0.59, 0.28)
		fragmento.position = Vector2(randf_range(-18.0, 18.0), -2.0)
		fragmento.z_index = -1
		add_child(fragmento)
		var destino := fragmento.position + Vector2(randf_range(-28.0, 28.0), randf_range(-18.0, -4.0))
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(fragmento, "position", destino, randf_range(0.16, 0.24)).set_trans(Tween.TRANS_SINE)
		tw.tween_property(fragmento, "rotation", randf_range(-1.2, 1.2), 0.2)
		tw.tween_property(fragmento, "modulate:a", 0.0, 0.22)
		tw.tween_callback(fragmento.queue_free)

func _efecto_aterrizaje() -> void:
	var peso_aterrizaje: float = _peso_visual_aterrizaje()
	aterrizaje_hecho.emit(120.0 * peso_aterrizaje, false)
	impulso_visual = 0.72 + peso_aterrizaje * 0.18
	impulso_visual_vel = -1.25 - peso_aterrizaje * 0.55
	asentamiento_aterrizaje = 0.72 + peso_aterrizaje * 0.28
	# El cuerpo NO cambia de escala al aterrizar. El peso se vende con una
	# microcaída visual, la sombra y el polvo para conservar proporciones.
	impacto_visual_y = maxf(impacto_visual_y, 1.4 + peso_aterrizaje * 0.9)
	if sombra:
		var tw_sombra := create_tween()
		tw_sombra.set_parallel(true)
		tw_sombra.tween_property(sombra, "scale", Vector2(1.12 + peso_aterrizaje * 0.16, 0.84 - peso_aterrizaje * 0.08), 0.08)
		tw_sombra.tween_property(sombra, "modulate:a", 0.36 + peso_aterrizaje * 0.12, 0.08)
		tw_sombra.chain().tween_property(sombra, "scale", Vector2.ONE, 0.18)

	var punto := Vector2(0.0, -2.0)
	var cantidad_polvo: int = clampi(int(round(3.0 + peso_aterrizaje * 3.0)), 3, 8)
	for i in range(cantidad_polvo):
		var polvo := Polygon2D.new()
		var s := randf_range(2.5, 4.5)
		polvo.polygon = PackedVector2Array([Vector2(-s, 0), Vector2(0, -s * 0.5), Vector2(s, 0), Vector2(0, s * 0.5)])
		polvo.color = Color(0.75, 0.72, 0.68, 0.30)
		polvo.position = punto + Vector2(randf_range(-18.0, 18.0), randf_range(-2.0, 2.0))
		polvo.z_index = -1
		add_child(polvo)
		var destino := polvo.position + Vector2(randf_range(-24.0, 24.0), randf_range(-12.0, -4.0))
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(polvo, "position", destino, 0.25)
		tween.tween_property(polvo, "scale", Vector2(1.7, 0.7), 0.25)
		tween.tween_property(polvo, "modulate:a", 0.0, 0.25)
		tween.chain().tween_callback(polvo.queue_free)

func _set_color(c: Color) -> void:
	if sprite:
		sprite.modulate = c
	elif visual:
		visual.color = c

# Recalcula escala Y POSICION juntas, para que los pies del personaje
# se queden siempre pegados al piso sin importar si está agrandado
# por la Fase Absoluta o en su tamaño normal.
func _actualizar_textura(tex: Texture2D) -> void:
	if not sprite or not tex:
		return
	sprite.texture = tex

	# NORMALIZACIÓN VISUAL POR POSE: cada PNG tiene un lienzo distinto.
	# En vez de reutilizar siempre la escala de parado.png, calculamos una
	# escala específica para que el tamaño visible del cuerpo se mantenga
	# consistente durante salto, caminata, golpes y recibir golpes.
	var rect := _obtener_rect_visual(tex)
	var escala_efectiva: float = _escala_normalizada_por_pose(tex, rect)
	sprite.scale = Vector2(escala_efectiva, escala_efectiva)
	escala_actual = escala_efectiva

	# El borde visible inferior sigue anclado al piso. En derribado usamos
	# una escala por ancho para que el cuerpo tumbado no crezca de golpe.
	sprite_base_y = tex.get_height() * 0.5 * escala_efectiva - (rect.position.y + rect.size.y) * escala_efectiva
	sprite.position.y = sprite_base_y
	sprite.position.x = _sprite_ancla_x()

	if forma_colision:
		var mult_cuerpo: float = _mult_cuerpo_actual()
		var ancho_colision: float = ancho_cuerpo * mult_cuerpo
		var alto_colision: float = maxf(alto_cuerpo * mult_cuerpo, _altura_visible_objetivo() * COLISION_ALTURA_VISIBLE_MULT)
		forma_colision.size = Vector2(ancho_colision, alto_colision)
		colision_shape.position.y = -alto_colision / 2.0

func _escala_normalizada_por_pose(tex: Texture2D, rect: Rect2) -> float:
	if not tex:
		return escala_sprite * MULT_TAMANO_GLOBAL
	var ruta: String = tex.resource_path
	if ESCALAS_POSE_PRECALCULADAS.has(ruta):
		return float(ESCALAS_POSE_PRECALCULADAS[ruta])

	# Fallback para arte nuevo todavía no calibrado: usa el área visible
	# geométrica, nunca un clamp contra la escala del parado. Esto evita el
	# error que hacía gigantes los frames anchos/horizontales y las recargas.
	if rect.size.y <= 1.0 or rect.size.x <= 1.0:
		return escala_sprite * MULT_TAMANO_GLOBAL
	var ref_rect: Rect2 = _obtener_rect_visual(textura_parado) if textura_parado else Rect2()
	if ref_rect.size.y <= 1.0 or ref_rect.size.x <= 1.0:
		return escala_sprite * MULT_TAMANO_GLOBAL
	var escala_parado: float = _altura_visible_objetivo() / ref_rect.size.y
	var metrica_ref: float = sqrt(maxf(ref_rect.size.x * ref_rect.size.y, 1.0))
	var metrica_pose: float = sqrt(maxf(rect.size.x * rect.size.y, 1.0))
	var escala_pose: float = escala_parado * (metrica_ref / metrica_pose)
	return clampf(escala_pose, 0.08, 2.0)

func _textura_en_lista(tex: Texture2D, lista: Array[Texture2D]) -> bool:
	for item in lista:
		if item == tex:
			return true
	return false

func _factor_compensacion_pose(tex: Texture2D) -> float:
	if tex == textura_recarga:
		return 1.10
	if tex == textura_especial:
		return 1.08
	if tex == textura_rematador:
		return 1.06
	if tex == textura_absoluto:
		return 1.05
	if tex == textura_golpe_recibido or tex == textura_furia_golpe_recibido:
		return 1.01
	if _textura_en_lista(tex, texturas_golpe_recibido_extra):
		return 1.03
	if tex == textura_punetazo or tex == textura_patada or _textura_en_lista(tex, texturas_punetazo_extra) or _textura_en_lista(tex, texturas_patada_extra):
		return 1.02
	if tex == textura_furia_punetazo or tex == textura_furia_patada or _textura_en_lista(tex, texturas_furia_punetazo_extra) or _textura_en_lista(tex, texturas_furia_patada_extra):
		return 1.03
	return 1.0

func _obtener_rect_visual(tex: Texture2D) -> Rect2:
	if not tex:
		return Rect2()
	var key := tex.get_instance_id()
	if _rect_visual_cache.has(key):
		return _rect_visual_cache[key]
	var imagen := tex.get_image()
	if imagen and not imagen.is_empty():
		var rect := imagen.get_used_rect()
		# Si el PNG no tiene alpha útil, usar toda la imagen para no perder
		# el frame.
		if rect.size.x > 0 and rect.size.y > 0:
			var out := Rect2(float(rect.position.x), float(rect.position.y), float(rect.size.x), float(rect.size.y))
			_rect_visual_cache[key] = out
			return out
	var fallback := Rect2(Vector2.ZERO, tex.get_size())
	_rect_visual_cache[key] = fallback
	return fallback

func _sprite_ancla_x() -> float:
	# La imagen queda centrada sobre el cuerpo. Lo mantenemos en 0 para que
	# el desplazamiento visual solo aparezca durante el impacto y vuelva a
	# su sitio sin saltos.
	return 0.0

func _distancia_minima_contextual(otro: Fighter = null) -> float:
	var minimo: float = DISTANCIA_MINIMA_LUCHADORES
	if otro and is_instance_valid(otro):
		var cuerpo_yo: float = ancho_cuerpo * _mult_cuerpo_actual()
		var cuerpo_otro: float = otro.ancho_cuerpo * otro._mult_cuerpo_actual()
		minimo = maxf(minimo, (cuerpo_yo + cuerpo_otro) * 0.54)
		if fase_ataque == FaseAtaque.ACTIVO or otro.fase_ataque == FaseAtaque.ACTIVO:
			minimo = maxf(minimo, DISTANCIA_MINIMA_CONTACTO)
		if hitstun_timer > 0.0 or otro.hitstun_timer > 0.0:
			minimo = maxf(minimo, DISTANCIA_MINIMA_CONTACTO_PESADO)
		if bloqueando or otro.bloqueando:
			minimo = maxf(minimo, DISTANCIA_MINIMA_CONTACTO_BLOQUEO)
	return minimo

func _aplicar_contacto_corporal_post_golpe(otro: Fighter, fuerza: float, bloqueado: bool) -> void:
	if not otro or not is_instance_valid(otro):
		return
	# FASE 90.3: antes esta función entera se saltaba durante el combo
	# automático del CORE (en_secuencia_especial), incluido el
	# microdesplazamiento instantáneo del defensor -- eso también aportaba
	# a que el rival se sintiera "pegado" en el combo, aparte del empuje
	# físico ya corregido en 90.2. Durante el combo dejamos pasar SOLO el
	# golpe instantáneo al defensor (se nota en el mismo frame del
	# impacto, antes de que el empuje físico termine de acelerarlo). Lo
	# que seguimos evitando durante el combo es tocar la posición del
	# ATACANTE acá (separación + auto-recoil): esa la controla por completo
	# el tween de _acercar_para_combo_auto(), y sumarle un ajuste instantáneo
	# aparte podría generar un microtemblor peleando contra ese tween.
	if en_secuencia_especial or otro.en_secuencia_especial:
		if otro.esta_derrotado:
			return
		var dir_combo: float = signf(otro.global_position.x - global_position.x)
		if dir_combo == 0.0:
			dir_combo = mirando if mirando != 0.0 else 1.0
		var energia_combo: float = clampf(fuerza / 320.0, 0.0, 1.0)
		otro.global_position.x += dir_combo * lerpf(5.5, 14.0, energia_combo)
		return
	var dir: float = signf(otro.global_position.x - global_position.x)
	if dir == 0.0:
		dir = mirando if mirando != 0.0 else 1.0
	var actual: float = absf(otro.global_position.x - global_position.x)
	var separacion_objetivo: float = _distancia_minima_contextual(otro)
	separacion_objetivo = maxf(separacion_objetivo, DISTANCIA_MINIMA_CONTACTO_BLOQUEO if bloqueado else DISTANCIA_MINIMA_CONTACTO)
	var energia: float = clampf(fuerza / 320.0, 0.0, 1.0)
	var impulso_defensor: float = lerpf(5.5, 14.0, energia)
	var impulso_atacante: float = lerpf(1.0, 4.0, energia)
	if bloqueado:
		impulso_defensor *= 0.45
		impulso_atacante *= 1.25
		separacion_objetivo = maxf(separacion_objetivo, DISTANCIA_MINIMA_CONTACTO_BLOQUEO)
	else:
		separacion_objetivo = maxf(separacion_objetivo, DISTANCIA_MINIMA_CONTACTO + lerpf(1.0, 5.0, energia))
	# Primero asegura una separación mínima limpia: el golpe se lee sobre el
	# cuerpo del rival y no como dos dibujos interpenetrados.
	if actual < separacion_objetivo:
		var penetracion: float = separacion_objetivo - actual
		global_position.x -= dir * penetracion * (0.34 if bloqueado else 0.18)
		otro.global_position.x += dir * penetracion * (0.66 if bloqueado else 0.82)
	# Luego suma un microdesplazamiento instantáneo del defensor para que el
	# retroceso se sienta en el mismo frame del impacto, antes del empuje total.
	otro.global_position.x += dir * impulso_defensor
	global_position.x -= dir * impulso_atacante

func _aplicar_limites_arena() -> void:
	var x_anterior: float = global_position.x
	global_position.x = clampf(global_position.x, ARENA_LIMITE_IZQUIERDO, ARENA_LIMITE_DERECHO)
	if global_position.x == x_anterior:
		return
	# Durante un derribo especial fuerte el cuerpo puede rebotar una vez contra
	# el borde del escenario antes de caer/deslizar. En combate normal solo se
	# frena para no salirse de la arena.
	if derribo_especial_activo and derribo_especial_esperando_aterrizar and not derribo_especial_rebote_muro_usado:
		derribo_especial_rebote_muro_usado = true
		velocity.x = -velocity.x * FUERZA_REBOTE_MURO_ESPECIAL
		_reaccion_impacto_timer = maxf(_reaccion_impacto_timer, 0.12)
		_reaccion_impacto_fuerza = maxf(_reaccion_impacto_fuerza, 220.0)
		hitstop_timer = maxf(hitstop_timer, 0.028)
		_efecto_golpe_suelo(260.0)
	elif signf(velocity.x) == signf(global_position.x - x_anterior):
		velocity.x = 0.0

func _actualizar_profundidad_visual() -> void:
	var base_z := int(round(global_position.y / Z_BASE_Y_DIVISOR))
	# Saltar hacia arriba = ligeramente más atrás; permanecer en el suelo =
	# más adelante. El estado de impacto añade una pequeña prioridad para
	# que el contacto se vea limpio.
	if fase_ataque == FaseAtaque.ACTIVO:
		base_z += 1
	if hitstun_timer > 0.0:
		base_z += 2
	if en_secuencia_especial:
		base_z += 4
	z_index = base_z

func _aplicar_separacion_fisica() -> void:
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return
	if en_secuencia_especial or objetivo.en_secuencia_especial:
		return
	var dx := objetivo.global_position.x - global_position.x
	var dist := absf(dx)
	var distancia_minima: float = _distancia_minima_contextual(objetivo)
	if dist <= 0.01 or dist >= distancia_minima:
		return
	var dir: float = signf(dx)
	var penetracion := distancia_minima - dist
	# Separación según masa real: el cuerpo liviano cede más y el pesado se
	# planta. Si alguien está aturdido o golpeando, todavía cede una porción adicional.
	var masa_yo: float = maxf(_masa_corporal(), 0.55)
	var masa_otro: float = maxf(objetivo._masa_corporal(), 0.55)
	var suma_masa: float = masa_yo + masa_otro
	var factor_yo: float = masa_otro / suma_masa
	var factor_objetivo: float = masa_yo / suma_masa
	if fase_ataque == FaseAtaque.ACTIVO and objetivo.hitstun_timer > 0.0:
		factor_yo = minf(0.28, factor_yo)
		factor_objetivo = 1.0 - factor_yo
	elif objetivo.fase_ataque == FaseAtaque.ACTIVO and hitstun_timer > 0.0:
		factor_objetivo = minf(0.28, factor_objetivo)
		factor_yo = 1.0 - factor_objetivo
	elif hitstun_timer > 0.0:
		factor_yo = minf(0.78, factor_yo + 0.18)
		factor_objetivo = 1.0 - factor_yo
	elif objetivo.hitstun_timer > 0.0:
		factor_objetivo = minf(0.78, factor_objetivo + 0.18)
		factor_yo = 1.0 - factor_objetivo
	global_position.x -= dir * penetracion * factor_yo
	objetivo.global_position.x += dir * penetracion * factor_objetivo

# ¿Esta textura es uno de los puñetazos/patadas (normales o furia) de
# este personaje? Se usa solo para la compensación de tamaño de arriba.
func _es_textura_de_golpe(tex: Texture2D) -> bool:
	if tex == textura_punetazo or tex == textura_patada:
		return true
	if tex == textura_furia_punetazo or tex == textura_furia_patada:
		return true
	if texturas_punetazo_extra.has(tex) or texturas_patada_extra.has(tex):
		return true
	if texturas_furia_punetazo_extra.has(tex) or texturas_furia_patada_extra.has(tex):
		return true
	return false

func _tex_parado() -> Texture2D:
	if en_fase_absoluta and textura_furia_parado:
		return textura_furia_parado
	return textura_parado

func _lista_caminata() -> Array[Texture2D]:
	if en_fase_absoluta and not texturas_furia_caminata.is_empty():
		return texturas_furia_caminata
	return texturas_caminata

func _tex_caminata_der() -> Texture2D:
	if en_fase_absoluta and textura_furia_caminata_der:
		return textura_furia_caminata_der
	return textura_caminata_der

func _tex_caminata_izq() -> Texture2D:
	if en_fase_absoluta and textura_furia_caminata_izq:
		return textura_furia_caminata_izq
	return textura_caminata_izq

func _tiene_caminata_real() -> bool:
	return not _lista_caminata().is_empty() or _tex_caminata_der() != null

func _tex_salto() -> Texture2D:
	if en_fase_absoluta and textura_furia_salto:
		return textura_furia_salto
	return textura_salto

func _tex_doble_salto() -> Texture2D:
	if en_fase_absoluta and textura_furia_doble_salto:
		return textura_furia_doble_salto
	if textura_doble_salto:
		return textura_doble_salto
	return _tex_salto()

func _tex_descenso() -> Texture2D:
	if en_fase_absoluta and textura_furia_descenso:
		return textura_furia_descenso
	if textura_descenso:
		return textura_descenso
	return _tex_salto()

func _tex_bloqueo() -> Texture2D:
	if en_fase_absoluta and textura_furia_bloqueo:
		return textura_furia_bloqueo
	return textura_bloqueo

# Pose dedicada para la carrera (doble toque de flecha). Si el personaje no
# tiene este arte cargado, no pasa nada: se sigue usando el ciclo normal de
# caminata (más rápido) como hasta ahora.
func _tex_carrera() -> Texture2D:
	if en_fase_absoluta and textura_furia_carrera:
		return textura_furia_carrera
	return textura_carrera

# Decide qué textura "de fondo" mostrar cuando no hay un golpe/impacto
# puntual en curso. Prioridad: bloqueando > en el aire (salto/doble
# salto/descenso según corresponda) > carrera (doble toque de flecha,
# si el personaje tiene arte propio) > caminando > parado.
func _tex_reposo() -> Texture2D:
	if bloqueando:
		var t_bloqueo := _tex_bloqueo()
		if t_bloqueo:
			return t_bloqueo
	if en_el_aire:
		var t_aire: Texture2D
		if velocity.y < 0.0:
			t_aire = _tex_doble_salto() if saltos_usados >= 2 else _tex_salto()
		else:
			t_aire = _tex_descenso()
		if t_aire:
			return t_aire
	if carrera_activa and is_on_floor() and not esta_derrotado:
		var t_carrera := _tex_carrera()
		if t_carrera:
			return t_carrera
	if is_on_floor() and absf(velocity.x) > 10.0 and not esta_derrotado:
		var der := _tex_caminata_der()
		if der:
			return der if indice_caminata == 0 else (_tex_caminata_izq() if _tex_caminata_izq() else der)
		var lista := _lista_caminata()
		if not lista.is_empty():
			return lista[indice_caminata % lista.size()]
	return _tex_parado()

func _lista_punetazo() -> Array[Texture2D]:
	var base: Texture2D = textura_furia_punetazo if (en_fase_absoluta and textura_furia_punetazo) else textura_punetazo
	var extra: Array[Texture2D] = texturas_furia_punetazo_extra if en_fase_absoluta else texturas_punetazo_extra
	var lista: Array[Texture2D] = []
	if base:
		lista.append(base)
	lista.append_array(extra)
	return lista

func _lista_patada() -> Array[Texture2D]:
	var base: Texture2D = textura_furia_patada if (en_fase_absoluta and textura_furia_patada) else textura_patada
	var extra: Array[Texture2D] = texturas_furia_patada_extra if en_fase_absoluta else texturas_patada_extra
	var lista: Array[Texture2D] = []
	if base:
		lista.append(base)
	lista.append_array(extra)
	return lista

func _tex_punetazo() -> Texture2D:
	var lista := _lista_punetazo()
	if lista.is_empty():
		return null
	return lista[indice_punetazo % lista.size()]

func _tex_patada() -> Texture2D:
	var lista := _lista_patada()
	if lista.is_empty():
		return null
	return lista[indice_patada % lista.size()]

func _lista_golpe_recibido() -> Array[Texture2D]:
	var lista: Array[Texture2D] = []
	if textura_golpe_recibido:
		lista.append(textura_golpe_recibido)
	lista.append_array(texturas_golpe_recibido_extra)
	return lista

func _tex_golpe_recibido() -> Texture2D:
	if en_fase_absoluta and textura_furia_golpe_recibido:
		return textura_furia_golpe_recibido
	var lista := _lista_golpe_recibido()
	if lista.is_empty():
		return textura_golpe_recibido
	return lista[indice_golpe_recibido % lista.size()]

func _tex_derribado() -> Texture2D:
	if en_fase_absoluta and textura_furia_derribado:
		return textura_furia_derribado
	return textura_derribado

func _mostrar_pose(nombre: String, duracion: float) -> void:
	if not sprite:
		return
	pose_timer = duracion
	match nombre:
		"punetazo":
			var t := _tex_punetazo()
			if t:
				_actualizar_textura(t)
		"patada":
			var t := _tex_patada()
			if t:
				_actualizar_textura(t)
		"golpe_recibido":
			var t := _tex_golpe_recibido()
			if t:
				_actualizar_textura(t)
