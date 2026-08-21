extends Node

const ROSTER: Array[String] = ["Kai", "Cibor-X", "Fang", "Kali", "Aethel", "Magnus", "Helena", "Jester"]
# Jefe final de Arcade. A propósito NO está en ROSTER: no es seleccionable
# ni entra al sorteo de Batalla Rápida, y en Arcade se agrega aparte al
# final de la lista de oponentes (ver iniciar_arcade) para que quede
# bloqueado hasta el final del torneo.
const JEFE_FINAL := "Varkhos"

var flujo_menu_activo: bool = true
var modo: String = "rapida"
var personaje_jugador: String = "Kai"
var rival_actual: String = "Cibor-X"
var escenario_actual: String = "Cibor-X"

var arcade_oponentes: Array[String] = []
var arcade_indice: int = 0
var arcade_victorias: int = 0
var ultimo_rival: String = ""
var ultimo_resultado: String = ""

# FASE 94.2: PantallaCarga.tscn lee esto para saber a qué escena pesada
# cargar en segundo plano antes de mostrarla.
var escena_destino_carga: String = ""

func iniciar_arcade(personaje: String) -> void:
	modo = "arcade"
	personaje_jugador = personaje
	arcade_oponentes.clear()
	for nombre in ROSTER:
		if nombre != personaje:
			arcade_oponentes.append(nombre)
	arcade_oponentes.shuffle()
	# El jefe final siempre cierra el torneo -- nunca entra al sorteo con
	# el resto.
	arcade_oponentes.append(JEFE_FINAL)
	arcade_indice = 0
	arcade_victorias = 0
	ultimo_rival = ""
	ultimo_resultado = ""
	_preparar_rival_arcade()

func iniciar_batalla_rapida(personaje: String) -> void:
	modo = "rapida"
	personaje_jugador = personaje
	var candidatos: Array[String] = []
	for nombre in ROSTER:
		if nombre != personaje:
			candidatos.append(nombre)
	candidatos.shuffle()
	rival_actual = candidatos[0] if not candidatos.is_empty() else "Cibor-X"
	escenario_actual = rival_actual
	arcade_oponentes.clear()
	arcade_indice = 0
	arcade_victorias = 0
	ultimo_rival = ""
	ultimo_resultado = ""

func _preparar_rival_arcade() -> void:
	if arcade_oponentes.is_empty():
		rival_actual = "Cibor-X"
	else:
		arcade_indice = clampi(arcade_indice, 0, arcade_oponentes.size() - 1)
		rival_actual = arcade_oponentes[arcade_indice]
	escenario_actual = rival_actual

func registrar_resultado(jugador_gano: bool) -> String:
	ultimo_rival = rival_actual
	if modo == "arcade":
		if not jugador_gano:
			ultimo_resultado = "derrota"
			return ultimo_resultado
		arcade_victorias += 1
		if arcade_victorias >= arcade_oponentes.size():
			ultimo_resultado = "campeon"
			return ultimo_resultado
		arcade_indice += 1
		_preparar_rival_arcade()
		ultimo_resultado = "siguiente"
		return ultimo_resultado

	ultimo_resultado = "victoria" if jugador_gano else "derrota"
	return ultimo_resultado

func es_final_arcade() -> bool:
	return modo == "arcade" and not arcade_oponentes.is_empty() and arcade_indice >= arcade_oponentes.size() - 1

func progreso_arcade_texto() -> String:
	if arcade_oponentes.is_empty():
		return "0/0"
	return "%d/%d" % [arcade_victorias, arcade_oponentes.size()]

func reiniciar_combate_actual() -> void:
	escenario_actual = rival_actual
	ultimo_resultado = ""


func reproducir_sfx_global(ruta: String, volumen_db: float = -3.0) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = load(ruta)
	player.volume_db = volumen_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func volver_al_menu() -> void:
	modo = "rapida"
	ultimo_resultado = ""
	ultimo_rival = ""
