class_name InputReplay
extends RefCounted

# CORE AWAKENED 91.00.00-H10.2 — REPLAY LOCAL + TRACE DETERMINISTA
# Lee el mismo paquete compacto generado por InputRecorder y devuelve un par
# de Input Frames por physics tick. No restaura posiciones ni fuerza estados:
# los Fighter deben reconstruir la pelea exclusivamente a partir de inputs.

const FORMATO := "core_awakened_input_recording"
const VERSION_FORMATO_MIN := 1
const RUTA_ULTIMA_GRABACION := "user://replays/last_input_recording.json"

const BIT_IZQUIERDA := 1 << 0
const BIT_DERECHA := 1 << 1
const BIT_SALTO := 1 << 2
const BIT_BLOQUEO := 1 << 3
const BIT_PUNO := 1 << 4
const BIT_PATADA := 1 << 5
const BIT_ESPECIAL := 1 << 6

var metadata: Dictionary = {}
var frames: Array = []
var tick_actual: int = 0
var activo: bool = false
var ultimo_error: String = ""
var checkpoints_por_tick: Dictionary = {}
var trazas_tick: Array = []

func cargar(ruta: String = RUTA_ULTIMA_GRABACION) -> bool:
	metadata.clear()
	frames.clear()
	checkpoints_por_tick.clear()
	trazas_tick.clear()
	tick_actual = 0
	activo = false
	ultimo_error = ""

	if not FileAccess.file_exists(ruta):
		ultimo_error = "No existe la grabación: %s" % ruta
		return false

	var archivo := FileAccess.open(ruta, FileAccess.READ)
	if archivo == null:
		ultimo_error = "No se pudo abrir la grabación (error %s)" % FileAccess.get_open_error()
		return false

	var texto := archivo.get_as_text()
	archivo.close()
	var paquete = JSON.parse_string(texto)
	if typeof(paquete) != TYPE_DICTIONARY:
		ultimo_error = "El JSON de replay no contiene un diccionario válido"
		return false

	var meta = paquete.get("metadata", {})
	var raw_frames = paquete.get("frames", [])
	var raw_checkpoints = paquete.get("checkpoints", [])
	var raw_trazas = paquete.get("trazas_tick", [])
	if typeof(meta) != TYPE_DICTIONARY or typeof(raw_frames) != TYPE_ARRAY:
		ultimo_error = "Formato de replay incompleto"
		return false
	if str(meta.get("formato", "")) != FORMATO:
		ultimo_error = "Formato de replay desconocido"
		return false
	if int(meta.get("version_formato", 0)) < VERSION_FORMATO_MIN:
		ultimo_error = "Versión de replay no soportada"
		return false

	metadata = meta.duplicate(true)
	frames = raw_frames.duplicate(true)
	if typeof(raw_checkpoints) == TYPE_ARRAY:
		for checkpoint in raw_checkpoints:
			if typeof(checkpoint) != TYPE_DICTIONARY:
				continue
			var tick := int(checkpoint.get("tick", -1))
			var estado = checkpoint.get("estado", {})
			if tick >= 0 and typeof(estado) == TYPE_DICTIONARY:
				checkpoints_por_tick[str(tick)] = estado.duplicate(true)
	if typeof(raw_trazas) == TYPE_ARRAY:
		trazas_tick = raw_trazas.duplicate(true)
	activo = true
	return true

func siguiente_tick() -> Dictionary:
	if not activo or tick_actual >= frames.size():
		return {
			"valido": false,
			"j1": frame_neutro(),
			"j2": frame_neutro(),
		}

	var par = frames[tick_actual]
	tick_actual += 1
	if typeof(par) != TYPE_ARRAY or par.size() < 2:
		ultimo_error = "Frame inválido en tick %d" % (tick_actual - 1)
		return {
			"valido": false,
			"j1": frame_neutro(),
			"j2": frame_neutro(),
		}

	return {
		"valido": true,
		"j1": decodificar_frame(int(par[0])),
		"j2": decodificar_frame(int(par[1])),
	}


func traza_para_tick(tick: int) -> Dictionary:
	# La traza se captura después de encolar el input N pero antes de que los
	# Fighter lo procesen. Por eso tick=1 corresponde al índice 0.
	var indice := tick - 1
	if indice < 0 or indice >= trazas_tick.size():
		return {}
	var estado = trazas_tick[indice]
	return estado.duplicate(true) if typeof(estado) == TYPE_DICTIONARY else {}

func checkpoint_para_tick(tick: int) -> Dictionary:
	var estado = checkpoints_por_tick.get(str(tick), {})
	return estado.duplicate(true) if typeof(estado) == TYPE_DICTIONARY else {}

func total_ticks() -> int:
	return frames.size()

func ticks_restantes() -> int:
	return maxi(frames.size() - tick_actual, 0)

func tick_inicio_ronda(numero_ronda: int) -> int:
	var marcadores = metadata.get("marcadores_ronda", [])
	if typeof(marcadores) != TYPE_ARRAY:
		return -1
	for marcador in marcadores:
		if typeof(marcador) == TYPE_DICTIONARY and int(marcador.get("ronda", -1)) == numero_ronda:
			return int(marcador.get("tick", -1))
	return -1

static func frame_neutro() -> Dictionary:
	return {
		"izquierda": false,
		"derecha": false,
		"salto": false,
		"bloqueo": false,
		"puno": false,
		"patada": false,
		"especial": false,
	}

static func decodificar_frame(mascara: int) -> Dictionary:
	return {
		"izquierda": (mascara & BIT_IZQUIERDA) != 0,
		"derecha": (mascara & BIT_DERECHA) != 0,
		"salto": (mascara & BIT_SALTO) != 0,
		"bloqueo": (mascara & BIT_BLOQUEO) != 0,
		"puno": (mascara & BIT_PUNO) != 0,
		"patada": (mascara & BIT_PATADA) != 0,
		"especial": (mascara & BIT_ESPECIAL) != 0,
	}
