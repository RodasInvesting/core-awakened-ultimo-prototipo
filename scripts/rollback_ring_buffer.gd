class_name RollbackRingBuffer
extends RefCounted

# CORE AWAKENED 91.00.00-H10.2 — RING BUFFER LOCAL
# Guarda snapshots al INICIO de cada physics tick y los dos Input Frames que
# gobiernan ese tick. En H el flag `seguro` admite ataque NORMAL/hitstop/hitstun; CORE/KO siguen excluidos.

var capacidad: int = 180
var entradas: Array[Dictionary] = []

func _init(capacidad_ticks: int = 180) -> void:
	capacidad = maxi(16, capacidad_ticks)

func limpiar() -> void:
	entradas.clear()

func total() -> int:
	return entradas.size()

func agregar_inicio_tick(tick: int, snapshot: Dictionary, seguro: bool) -> void:
	entradas.append({
		"tick": tick,
		"snapshot": snapshot.duplicate(true),
		"seguro": seguro,
		"j1": {},
		"j2": {},
		"native_recovery_j1": 0.0,
		"native_recovery_j2": 0.0,
		"native_recovery_seguro_j1": false,
		"native_recovery_seguro_j2": false,
	})
	while entradas.size() > capacidad:
		entradas.pop_front()

func asignar_inputs_ultimo(j1: Dictionary, j2: Dictionary) -> void:
	if entradas.is_empty():
		return
	entradas[entradas.size() - 1]["j1"] = j1.duplicate(true)
	entradas[entradas.size() - 1]["j2"] = j2.duplicate(true)

func asignar_native_recovery_ultimo(j1: float, j2: float, seguro_j1: bool, seguro_j2: bool) -> void:
	if entradas.is_empty():
		return
	var i := entradas.size() - 1
	entradas[i]["native_recovery_j1"] = j1
	entradas[i]["native_recovery_j2"] = j2
	entradas[i]["native_recovery_seguro_j1"] = seguro_j1
	entradas[i]["native_recovery_seguro_j2"] = seguro_j2

func ventana_desde_el_final(cantidad_ticks: int) -> Array[Dictionary]:
	var n := maxi(1, cantidad_ticks)
	if entradas.size() < n:
		return []
	var inicio := entradas.size() - n
	var salida: Array[Dictionary] = []
	for i in range(inicio, entradas.size()):
		salida.append(entradas[i].duplicate(true))
	return salida

func ventana_es_segura(ventana: Array[Dictionary]) -> bool:
	if ventana.is_empty():
		return false
	for entrada in ventana:
		if not bool(entrada.get("seguro", false)):
			return false
		if (entrada.get("j1", {}) as Dictionary).is_empty():
			return false
		if (entrada.get("j2", {}) as Dictionary).is_empty():
			return false
	return true

func tick_mas_antiguo() -> int:
	if entradas.is_empty():
		return -1
	return int(entradas[0].get("tick", -1))

func tick_mas_nuevo() -> int:
	if entradas.is_empty():
		return -1
	return int(entradas[entradas.size() - 1].get("tick", -1))
