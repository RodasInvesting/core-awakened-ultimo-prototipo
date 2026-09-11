class_name InputRecorder
extends RefCounted

# CORE AWAKENED 91.00.00-H10.2 — INPUT RECORDER + TRACE DETERMINISTA
# Registra la intención normalizada que Main ya envía a J1/J2 en Versus Local.
# El stream principal sigue guardando únicamente inputs compactos. En esta build D
# se agrega temporalmente una traza lógica por tick (posición/estado) sólo para
# localizar la primera divergencia; esa traza NO será el paquete de red definitivo.

const FORMATO := "core_awakened_input_recording"
const VERSION_FORMATO := 3
const RUTA_ULTIMA_GRABACION := "user://replays/last_input_recording.json"

const BIT_IZQUIERDA := 1 << 0
const BIT_DERECHA := 1 << 1
const BIT_SALTO := 1 << 2
const BIT_BLOQUEO := 1 << 3
const BIT_PUNO := 1 << 4
const BIT_PATADA := 1 << 5
const BIT_ESPECIAL := 1 << 6

var grabando: bool = false
var frames: Array = []
var metadata: Dictionary = {}
var marcadores_ronda: Array = []
var checkpoints: Array = []
var trazas_tick: Array = []

func iniciar(datos_partida: Dictionary) -> void:
	frames.clear()
	marcadores_ronda.clear()
	checkpoints.clear()
	trazas_tick.clear()
	metadata = datos_partida.duplicate(true)
	metadata["formato"] = FORMATO
	metadata["version_formato"] = VERSION_FORMATO
	metadata["creado_unix"] = int(Time.get_unix_time_from_system())
	grabando = true

func grabar_tick(frame_j1: Dictionary, frame_j2: Dictionary) -> void:
	if not grabando:
		return
	# Dos enteros por tick. El orden del Array ES el número de tick, por lo que
	# no hace falta repetir un índice y el archivo se mantiene pequeño.
	frames.append([codificar_frame(frame_j1), codificar_frame(frame_j2)])

func grabar_checkpoint(tick: int, estado: Dictionary) -> void:
	if not grabando:
		return
	checkpoints.append({
		"tick": tick,
		"estado": estado.duplicate(true),
	})


func grabar_traza_tick(estado: Dictionary) -> void:
	if not grabando:
		return
	# Una fotografía lógica por input ya encolado. El índice 0 corresponde al
	# estado previo a procesar el primer Input Frame; se usa sólo durante la
	# fase de diagnóstico de determinismo y después podrá sustituirse por hashes.
	trazas_tick.append(estado.duplicate(true))

func marcar_inicio_ronda(numero_ronda: int) -> void:
	if not grabando:
		return
	marcadores_ronda.append({
		"ronda": numero_ronda,
		"tick": frames.size(),
	})

func finalizar_y_guardar(datos_finales: Dictionary = {}) -> String:
	if not grabando:
		return ""
	grabando = false
	for clave in datos_finales.keys():
		metadata[clave] = datos_finales[clave]
	metadata["ticks_totales"] = frames.size()
	metadata["marcadores_ronda"] = marcadores_ronda.duplicate(true)

	var ruta_dir_absoluta := ProjectSettings.globalize_path("user://replays")
	var error_dir := DirAccess.make_dir_recursive_absolute(ruta_dir_absoluta)
	if error_dir != OK and error_dir != ERR_ALREADY_EXISTS:
		push_warning("91.00.00-H Input Recorder: no se pudo crear user://replays (error %s)" % error_dir)
		return ""

	var archivo := FileAccess.open(RUTA_ULTIMA_GRABACION, FileAccess.WRITE)
	if archivo == null:
		push_warning("91.00.00-H Input Recorder: no se pudo abrir %s (error %s)" % [RUTA_ULTIMA_GRABACION, FileAccess.get_open_error()])
		return ""

	var paquete := {
		"metadata": metadata,
		"frames": frames,
		"checkpoints": checkpoints,
		"trazas_tick": trazas_tick,
	}
	archivo.store_string(JSON.stringify(paquete))
	archivo.close()
	return RUTA_ULTIMA_GRABACION

func total_ticks() -> int:
	return frames.size()

static func codificar_frame(frame: Dictionary) -> int:
	var mascara := 0
	if bool(frame.get("izquierda", false)):
		mascara |= BIT_IZQUIERDA
	if bool(frame.get("derecha", false)):
		mascara |= BIT_DERECHA
	if bool(frame.get("salto", false)):
		mascara |= BIT_SALTO
	if bool(frame.get("bloqueo", false)):
		mascara |= BIT_BLOQUEO
	if bool(frame.get("puno", false)):
		mascara |= BIT_PUNO
	if bool(frame.get("patada", false)):
		mascara |= BIT_PATADA
	if bool(frame.get("especial", false)):
		mascara |= BIT_ESPECIAL
	return mascara

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
