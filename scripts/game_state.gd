extends Node

const ROSTER: Array[String] = ["Kai", "Cibor-X", "Fang", "Kali", "Aethel", "Magnus", "Helena", "Jester", "Xenoid", "Dax", "Krovan", "Nekhar", "Virgilio"]

# Jefe final de Arcade. A propósito NO está en ROSTER: no es seleccionable
# ni entra al sorteo de Batalla Rápida. Se agrega únicamente al final del
# recorrido Arcade, por eso el selector puede mostrarlo bloqueado.
const JEFE_FINAL := "Varkhos"

# Escenarios disponibles en Versus. 90.11.15 integra también la arena final
# de Varkhos. Los IDs coinciden con las claves que usa main.gd.
const ESCENARIOS_VERSUS: Array[String] = [
	"Kai", "Cibor-X", "Fang", "Kali", "Aethel",
	"Magnus", "Helena", "Jester", "Xenoid", "Dax", "Krovan", "Nekhar", "Virgilio", "Varkhos"
]

var flujo_menu_activo: bool = true
var modo: String = "rapida"
var personaje_jugador: String = "Kai"
# 90.10.78: segundo jugador explícito. `rival_actual` sigue siendo la fuente
# que usa Main para instanciar el lado derecho, pero este campo deja claro el
# estado del Versus local y será reutilizable por el futuro online.
var personaje_jugador2: String = "Cibor-X"
var rival_actual: String = "Cibor-X"
var escenario_actual: String = "Cibor-X"
# 91.02.62 — PASS 14C: configuración canónica compartida HOST/CLIENTE.
var online_seed: int = 0

# 91.02.40 — PASS 11B / dificultad IA centralizada.
# 0 = Fácil, 1 = Medio, 2 = Difícil. Por ahora el selector visual se integra
# en el PASS siguiente; este valor ya gobierna toda CPU de Batalla Rápida/Arcade.
const IA_FACIL := 0
const IA_MEDIA := 1
const IA_DIFICIL := 2
# 91.02.41 — QA temporal: arrancar en DIFÍCIL para certificar este perfil.
# El selector final restaurará la elección explícita Fácil/Medio/Difícil.
var dificultad_ia: int = IA_DIFICIL

func configurar_dificultad_ia(nivel: int) -> void:
	dificultad_ia = clampi(nivel, IA_FACIL, IA_DIFICIL)

func nombre_dificultad_ia() -> String:
	match dificultad_ia:
		IA_DIFICIL: return "DIFÍCIL"
		IA_MEDIA: return "MEDIO"
		_: return "FÁCIL"

var arcade_oponentes: Array[String] = []
var arcade_indice: int = 0
var arcade_victorias: int = 0
var ultimo_rival: String = ""
var ultimo_resultado: String = ""
# 90.12.00 — ganador explícito para que Versus Local sea neutral: J1 y J2
# pueden cerrar la pelea como vencedores sin convertir la victoria de J2 en
# una pantalla genérica de derrota desde la perspectiva de J1.
var ultimo_ganador: String = ""
# 91.00.00-B — solicitud efímera para reproducir el último Input Recording.
# La bandera sobrevive a PresentacionVS y Main la consume al iniciar la pelea.
var replay_solicitado: bool = false
var replay_ultimo_mensaje: String = ""

# PantallaCarga.tscn lee esto para saber a qué escena pesada cargar
# en segundo plano antes de mostrarla.
var escena_destino_carga: String = ""

const RUTA_SFX_NAVEGACION_UI := "res://assets/sonidos/menu/navegacion_unificada.wav"
var _audio_navegacion_ui: AudioStreamPlayer

func _ready() -> void:
	_audio_navegacion_ui = AudioStreamPlayer.new()
	_audio_navegacion_ui.stream = load(RUTA_SFX_NAVEGACION_UI)
	_audio_navegacion_ui.volume_db = -6.0
	_audio_navegacion_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_audio_navegacion_ui)

func reproducir_navegacion_ui() -> void:
	if _audio_navegacion_ui == null:
		return
	# Reiniciar en cada paso evita que varias colas del mismo sonido se amontonen
	# cuando el jugador recorre opciones rápidamente con mando o teclado.
	_audio_navegacion_ui.stop()
	_audio_navegacion_ui.pitch_scale = 1.0
	_audio_navegacion_ui.play()

func iniciar_arcade(personaje: String) -> void:
	modo = "arcade"
	personaje_jugador = personaje
	arcade_oponentes.clear()
	for nombre in ROSTER:
		if nombre != personaje:
			arcade_oponentes.append(nombre)
	arcade_oponentes.shuffle()
	arcade_oponentes.append(JEFE_FINAL)
	arcade_indice = 0
	arcade_victorias = 0
	ultimo_rival = ""
	ultimo_resultado = ""
	ultimo_ganador = ""
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
	ultimo_ganador = ""

func iniciar_versus_local(jugador1: String, jugador2: String) -> void:
	# 90.10.78 — J1 y J2 son dos humanos. Se permite mirror match: el sistema
	# de Fighter ya soporta dos instancias del mismo personaje sin compartir estado.
	modo = "versus_local"
	personaje_jugador = jugador1
	personaje_jugador2 = jugador2
	rival_actual = jugador2
	# El escenario definitivo se elegirá en SelectorEscenarios.
	if escenario_actual not in ESCENARIOS_VERSUS:
		escenario_actual = "Kai"
	arcade_oponentes.clear()
	arcade_indice = 0
	arcade_victorias = 0
	ultimo_rival = ""
	ultimo_resultado = ""
	ultimo_ganador = ""

func es_versus_local() -> bool:
	return modo == "versus_local"

# 91.02.61 — PASS 14B / modo de transporte real.
# La autoridad/peer viven en NetworkManager; GameState sólo expone el flujo.
func es_online() -> bool:
	return modo == "online"

# J1 siempre es HOST; J2 siempre es CLIENTE. Ambos peers guardan la misma
# orientación canónica para que PresentacionVS y el futuro rollback coincidan.
func preparar_online_personajes(jugador_host: String, jugador_cliente: String) -> void:
	modo = "online"
	personaje_jugador = jugador_host
	personaje_jugador2 = jugador_cliente
	rival_actual = jugador_cliente
	ultimo_rival = ""
	ultimo_resultado = ""
	ultimo_ganador = ""

func iniciar_online_sincronizado(jugador_host: String, jugador_cliente: String, escenario: String, semilla: int) -> void:
	preparar_online_personajes(jugador_host, jugador_cliente)
	seleccionar_escenario(escenario)
	online_seed = semilla if semilla != 0 else 9102062

func seleccionar_escenario(escenario: String) -> void:
	if escenario in ESCENARIOS_VERSUS:
		escenario_actual = escenario


func _preparar_rival_arcade() -> void:
	if arcade_oponentes.is_empty():
		rival_actual = "Cibor-X"
	else:
		arcade_indice = clampi(arcade_indice, 0, arcade_oponentes.size() - 1)
		rival_actual = arcade_oponentes[arcade_indice]
	escenario_actual = rival_actual

func registrar_resultado(jugador_gano: bool) -> String:
	ultimo_rival = rival_actual

	# 90.12.00 — Versus Local no tiene un "jugador principal" a efectos de
	# resultado. Guardamos el ganador real y mostramos una pantalla neutral.
	if modo == "versus_local":
		ultimo_ganador = personaje_jugador if jugador_gano else personaje_jugador2
		ultimo_resultado = "versus_local"
		return ultimo_resultado

	ultimo_ganador = personaje_jugador if jugador_gano else rival_actual
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
	# Arcade conserva la regla escenario = rival. En Versus se mantiene
	# el escenario elegido por el jugador para que "Revancha" no lo cambie.
	if modo == "arcade":
		escenario_actual = rival_actual
	ultimo_resultado = ""
	ultimo_ganador = ""

func solicitar_replay_ultima_partida() -> void:
	replay_solicitado = true
	replay_ultimo_mensaje = ""

func cancelar_replay() -> void:
	replay_solicitado = false

func reproducir_sfx_global(ruta: String, volumen_db: float = -3.0) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = load(ruta)
	player.volume_db = volumen_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func volver_al_menu() -> void:
	replay_solicitado = false
	modo = "rapida"
	online_seed = 0
	personaje_jugador2 = "Cibor-X"
	ultimo_resultado = ""
	ultimo_rival = ""
	ultimo_ganador = ""
