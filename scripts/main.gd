extends Node2D

# 91.00.00-A — grabador compacto de Input Frames para la futura capa online.
const InputRecorderScript := preload("res://scripts/input_recorder.gd")
# 91.00.00-H10.13 — replay determinista + seed compartida + traza por tick. El replay alimenta
# la misma entrada EXTERNA del Fighter; nunca escribe posición/vida/CORE directamente.
const InputReplayScript := preload("res://scripts/input_replay.gd")
const RollbackSnapshotScript := preload("res://scripts/rollback_snapshot.gd")
const RollbackRingBufferScript := preload("res://scripts/rollback_ring_buffer.gd")
const RollbackNeutralMotionGuardScript := preload("res://scripts/rollback_neutral_motion_guard.gd")

# CORE AWAKENED 90.10.96 — CÁMARA DINÁMICA RESTAURADA + INPUT ROUTER CONSERVADO.
# El dash espejo quedó resuelto en perfect_block_90_1.gd (90.10.95), por lo que
# ya no necesitamos restricciones artificiales de cámara en Versus Local.
# Vuelve el seguimiento dinámico por distancia, paneo, zoom y aire de carrera.

const ANCHO_ARENA := 1280.0
const SUELO_Y := 560.0
const ANCHO_BARRA := 300.0
const PODER_MAXIMO := 100.0
const RONDAS_PARA_GANAR := 2
const POS_KAI := Vector2(400, 560)
const POS_RIVAL := Vector2(880, 560)

# 90.10.93 — ROUTER CENTRAL DE INPUT.
# Estos índices coinciden con SDL/Godot y con Fighter, pero Main es la única
# capa que toca Input en Versus Local.
const ROUTER_PAD_A := 0
const ROUTER_PAD_B := 1
const ROUTER_PAD_X := 2
const ROUTER_PAD_Y := 3
const ROUTER_PAD_RB := 10
const ROUTER_DPAD_UP := 11
const ROUTER_DPAD_DOWN := 12
const ROUTER_DPAD_LEFT := 13
const ROUTER_DPAD_RIGHT := 14
const ROUTER_AXIS_LX := 0
const ROUTER_AXIS_LY := 1
const ROUTER_AXIS_LT := 4
const ROUTER_AXIS_RT := 5
const ROUTER_DEADZONE_X := 0.45
const ROUTER_DEADZONE_Y := 0.64


var kai: Fighter
var rival: Fighter
# 90.10.77 — estado local de control. No cambia las reglas del combate; sólo
# decide si el lado derecho recibe IA o input humano J2.
var versus_local_activo := false
# 91.02.64 — PASS 14D1. Online reutiliza la entrada EXTERNA certificada de
# Versus Local, pero cada peer sólo lee SU dispositivo local.
var online_activo: bool = false
var online_combate_habilitado: bool = false
var online_tick_simulacion: int = 0
const ONLINE_INPUT_DELAY_TICKS := 4
var online_inputs_locales: Dictionary = {}
var online_ultimo_frame_remoto: Dictionary = {}
var online_remote_misses: int = 0
var online_remote_hits: int = 0

# 91.02.68 — PASS 14D2A / DETECTOR DE ROLLBACK REMOTO.
# Antes de rebobinar gameplay, medimos qué paquetes tardíos CAMBIAN realmente
# la predicción aplicada. Un paquete tardío idéntico a la predicción no requiere
# rollback. Esta capa es sólo telemetría: no restaura snapshots ni toca Fighter.
const ONLINE_ROLLBACK_DIAG_HISTORY_TICKS := 180
var online_prediccion_remota_por_tick: Dictionary = {}
var online_late_evaluados: int = 0
var online_late_iguales: int = 0
var online_rollback_necesarios: int = 0
var online_rollback_max_edad: int = 0
var online_rollback_tick_mas_antiguo: int = -1

# 91.02.70 — PASS 14D2C / ROLLBACK REMOTO REAL.
# 14D2A midió 1–4 ticks durante combate normal; usamos techo 8 para margen.
# La re-simulación usa el scheduler real de Godot, un subtick histórico por
# physics frame, preservando Fighter/PB/proyectiles sin reescribir esos sistemas.
const ONLINE_ROLLBACK_MAX_TICKS := 8
var online_rollback_tick_pendiente: int = -1
var online_rollback_catchup_modo: bool = false
var online_rollback_finalizar_pendiente: bool = false
var online_rollbacks_ejecutados: int = 0
var online_rollback_ticks_reprocesados: int = 0
var online_rollback_fuera_ventana: int = 0
var online_rollback_ultimo_inicio: int = -1
var online_rollback_ultima_cantidad: int = 0

# 91.02.67 — PERF-1 / COMPATIBILIDAD VISUAL.
# No altera physics, Fighter, hitboxes, velocidades, daño, CORE ni rollback.
# Se activa automáticamente en gl_compatibility (PCs antiguas) y también en
# ONLINE para que ambos peers usen el mismo perfil visual durante estas pruebas.
var modo_bajo_visual: bool = false
var perf_diag_acumulado: float = 0.0
var perf_renderer_actual: String = ""
# 91.02.66 — buffers exclusivos del harness localhost. No se usan entre 2 PCs.
var online_inputs_loopback_j2: Dictionary = {}
var online_loopback_ultimo_j1: Dictionary = {}
var online_loopback_ultimo_j2: Dictionary = {}
var online_loopback_hits: int = 0
var online_loopback_misses: int = 0
# 91.00.00-A — SOLO observación: no modifica el frame que recibe Fighter.
var input_recorder = null
var input_recorder_ronda_actual: int = 1
# 91.00.00-H10.13 — estado local de reproducción determinista.
var input_replay = null
var replay_modo_activo: bool = false
var replay_ronda_actual: int = 1
var replay_agotado_reportado: bool = false
var replay_final_evaluado: bool = false
var replay_marcadores_ok: bool = true
var replay_tick_primer_desync: int = -1
var replay_checkpoints_ok: bool = true
var replay_trace_ok: bool = true
var replay_rng_seed_actual: int = 0
var replay_ticks_neutros_post_buffer: int = 0
const REPLAY_GRACIA_POST_BUFFER_TICKS := 30
const REPLAY_CHECKPOINT_INTERVALO := 60

# 91.00.00-H10.13 — snapshot manual de diagnóstico. Se mantiene completamente
# fuera del flujo competitivo normal: F9 guarda / F10 restaura sólo en Versus Local.
var rollback_snapshot_manual: Dictionary = {}
var rollback_snapshot_disponible: bool = false

# 91.00.00-H10.13 — rollback local simulado.
# El historial conserva ~3 s a 60 Hz, pero F11 rebobina sólo 8 ticks (~133 ms),
# una ventana típica de rollback competitivo.
const ROLLBACK_BUFFER_TICKS := 180
const ROLLBACK_TEST_TICKS := 8
const ROLLBACK_COUNTER_LOOKBACK_TICKS := 180
var rollback_ring = null
var rollback_tick_logico: int = 0
var rollback_catchup_activo: bool = false
var rollback_catchup_ventana: Array[Dictionary] = []
var rollback_catchup_indice: int = 0
# H10.2 — frontera de time_scale para catch-up CORE III.
# El frame donde se pide rollback puede haber nacido ya con delta escalado
# por la cámara lenta LIVE. Preparar un frame permite que el siguiente delta
# sea calculado con el time_scale histórico restaurado.
var rollback_catchup_preparando_timescale: bool = false
var rollback_catchup_inicio_timescale: Dictionary = {}
# H10.6 — barrera CORE III de dos frames + commit restore.
# Frame A restaura time_scale histórico y apaga simuladores; Frame B deja un tick
# completo de estabilización a 1.0. Al final de B se reactivan sólo los Fighters.
# En el siguiente Main (antes de Fighter/PB) hacemos un tercer restore y recién
# entonces reactivamos PerfectBlock + catch-up. Así el delta del primer subtick ya
# nació a 1/60 y ningún callback administrativo puede contaminar el snapshot 0.
var rollback_catchup_reactivar_tactico_next_tick: bool = false
var rollback_catchup_reactivacion_deferred_pendiente: bool = false
var rollback_catchup_barrier_frames_restantes: int = 0
var rollback_catchup_commit_restore_pendiente: bool = false
var rollback_comparacion_pendiente: bool = false
var rollback_estado_presente_esperado: Dictionary = {}
var rollback_tick_origen: int = -1
var rollback_motion_guard = null
var rollback_test_solicitado: bool = false
var rollback_subtrace_primer_error: int = -1
var rollback_subtrace_diferencias: Array[String] = []
var rollback_h_clasificacion: String = ""
var rollback_h_atacante: String = ""
var rollback_counter_serial_ya_probado: int = 0
var rollback_counter_defer_activo: bool = false
var rollback_counter_serial_defer: int = -1
# H10.72 — Perfect Block se localiza por la transición snapshotable
# _counter_disponible false->true. No toca PerfectBlock/Fighter.
var rollback_perfect_tick_ya_probado: int = -1
var h1072_perfect_auto_armado: bool = false
var h1072_perfect_tick_evento: int = -1
var h1072_perfect_lado: String = ""
# H10.73 — Launcher certificado. Sus variables se conservan por compatibilidad
# del localizador histórico, pero H10.76 ya no arma autocaptura de Launcher.
var h1073_launcher_auto_armado: bool = false
var h1073_launcher_tick_evento: int = -1
var h1073_launcher_lado: String = ""
# H10.76 — AIR x3 certificado. Variables conservadas por compatibilidad
# del localizador histórico; H10.78 ya no arma autocaptura AIR.
var h1076_airx3_auto_armado: bool = false
var h1076_airx3_tick_evento: int = -1
var h1076_airx3_lado: String = ""
# H10.78 — BACK DASH target-only automático. Observa el serial snapshotable
# ya existente de PerfectBlock y no modifica la mecánica de movimiento.
var h1077_backdash_auto_armado: bool = false
var h1077_backdash_tick_evento: int = -1
var h1077_backdash_lado: String = ""
var h1077_backdash_serial_evento: int = -1
var h1077_backdash_direccion: float = 0.0
var rollback_backdash_serial_ya_probado: int = 0
var rollback_backdash_serial_defer: int = -1
# H10.78 — FORWARD DASH/CARRERA target-only automático. Se detecta sólo por
# estado Fighter snapshotable: carrera_activa false->true y dirección hacia rival.
# Fighter permanece congelado; no se agrega serial nuevo a gameplay.
var h1078_forward_dash_auto_armado: bool = false
var h1078_forward_dash_tick_evento: int = -1
var h1078_forward_dash_lado: String = ""
var h1078_forward_dash_direccion: float = 0.0
var rollback_forward_dash_tick_ya_probado: int = -1
# H10.80 — impacto normal limpio de PATADA target-only automático. Se detecta
# exclusivamente por la transición snapshotable _atk_ya_conecto false->true
# con ambos luchadores en suelo, sin guardia, sin dash y sin Launcher/AIR.
# Fighter permanece congelado.
var h1080_kick_impact_auto_armado: bool = false
var h1080_kick_impact_tick_evento: int = -1
var h1080_kick_impact_lado: String = ""
var rollback_kick_impact_tick_ya_probado: int = -1
# H10.81 — BLOQUEO NORMAL contra PUÑO target-only automático. El evento se
# identifica por impacto de punetazo en suelo con defensor ya bloqueando,
# hitstun de guardia > 0 y SIN apertura de Counter (excluye Perfect Block).
# Fighter / PerfectBlock / RollbackSnapshot permanecen congelados.
var h1081_punch_block_auto_armado: bool = false
var h1081_punch_block_tick_evento: int = -1
var h1081_punch_block_atacante: String = ""
var h1081_punch_block_defensor: String = ""
var rollback_punch_block_tick_ya_probado: int = -1
# H10.85 — RECUPERACIÓN POST-BLOQUEO. H10.83 ya certificó el impacto de
# patada bloqueada; ahora observamos el cruce hitstun > 0 -> <= 0 con el
# botón de bloqueo ya soltado. La ventana incluye la liberación lógica de
# bloqueando y el retorno a neutral. Sólo diagnóstico en Main.
var h1084_block_watch_activo: bool = false
var h1084_block_atacante: String = ""
var h1084_block_defensor: String = ""
var h1084_block_tick_impacto: int = -1
var h1084_block_recovery_auto_armado: bool = false
var h1084_block_recovery_tick_evento: int = -1
var rollback_block_recovery_tick_ya_probado: int = -1
# H10.87 — RECUPERACIÓN OFENSIVA POST-IMPACTO NORMAL. H10.80 certificó
# el contacto de patada; ahora seguimos al atacante hasta RECOVERY->NINGUNA.
# Sólo diagnóstico en Main; Fighter permanece congelado.
var h1086_attack_watch_activo: bool = false
var h1086_attack_lado: String = ""
var h1086_attack_tick_impacto: int = -1
var h1086_attack_recovery_auto_armado: bool = false
var h1086_attack_recovery_tick_evento: int = -1
var rollback_attack_recovery_tick_ya_probado: int = -1
# H10.87 — REGRESIÓN INTEGRAL FINAL DEL COMBATE NORMAL. No crea gameplay:
# encadena seis checkpoints ya certificados de forma aislada y sólo avanza
# al siguiente cuando el rollback anterior devuelve presente idéntico.
# 0 Forward Dash -> 1 Kick Impact -> 2 Attack Recovery -> 3 Backdash
# -> 4 Kick Block -> 5 Block Recovery.
var h1087_integral_fase: int = 0
var h1087_integral_lado_usuario: String = ""
var h1087_integral_fallo: bool = false
var h1087_integral_completo: bool = false
var rollback_launcher_serial_ya_probado: int = 0
var rollback_launcher_serial_defer: int = -1
var rollback_airhit_serial_ya_probado: int = 0
var rollback_airhit_serial_defer: int = -1
# H6.1 — los seriales diagnósticos forman parte del snapshot y por tanto
# pueden retroceder tras F11. El tick del ring NO retrocede: es la identidad
# correcta para saber si un evento ya fue probado.
var rollback_launcher_tick_ya_probado: int = -1
var rollback_airhit_tick_ya_probado: int = -1
# H8.1 — marcador de diagnóstico CORE I en Main.
# NO forma parte del snapshot: su identidad no retrocede durante F11.
var rollback_core1_event_serial: int = 0
var rollback_core1_event_serial_ya_probado: int = 0
var rollback_core1_event_tick_hint: int = -1
var rollback_core1_event_lado: String = ""
# H8.4 — marcador monotónico de finalización del Target Lock CORE I.
# Vive en Main y NO se restaura con snapshots.
var rollback_core1_target_end_serial: int = 0
var rollback_core1_target_end_serial_ya_probado: int = 0
var rollback_core1_target_end_tick_hint: int = -1
var rollback_core1_target_end_lado: String = ""
# H8.6 — último tick histórico de fin de póster CORE I ya probado.
# El tick del ring es monotónico dentro de la pelea y no forma parte del snapshot.
var rollback_core1_poster_end_tick_ya_probado: int = -1
# H9 — activación CORE II. Main-only marker: no forma parte del snapshot.
var rollback_core2_event_serial: int = 0
var rollback_core2_event_serial_ya_probado: int = 0
var rollback_core2_event_tick_hint: int = -1
var rollback_core2_event_lado: String = ""
# H10 — activación CORE III. Main-only; no entra al snapshot.
var rollback_core3_event_serial: int = 0
var rollback_core3_event_serial_ya_probado: int = 0
var rollback_core3_event_tick_hint: int = -1
var rollback_core3_event_lado: String = ""
var h10_core3_auto_armado: bool = false
const H101_CORE3_POST_TICKS_REQUERIDOS := ROLLBACK_TEST_TICKS - 2
# H10.9 — siguiente frontera certificable de CORE III: fin de la recarga lenta
# 1.55 s (en_pose_recarga true -> false) antes de Furia/acercamiento.
# Diagnóstico puro: todavía NO reemplaza SceneTreeTimer/await.
var rollback_core3_recarga_end_tick_ya_probado: int = -1
var h109_recarga_prev_j1: bool = false
var h109_recarga_prev_j2: bool = false
var h109_recarga_observador_inicializado: bool = false
var h109_auto_test_armado: bool = false
var h109_auto_test_tick_evento: int = -1
var h109_auto_test_lado: String = ""
# H10.13 — frontera siguiente: fin del primer Target Lock CORE III.
# Detecta core3_secuencia_etapa 2 -> 3, ahora entrando al primer beat FSM snapshotable.
var rollback_core3_approach_end_tick_ya_probado: int = -1
var h1012_core3_etapa_prev_j1: int = 0
var h1012_core3_etapa_prev_j2: int = 0
var h1012_approach_observador_inicializado: bool = false
var h1012_auto_test_armado: bool = false
var h1012_auto_test_tick_evento: int = -1
var h1012_auto_test_lado: String = ""
# H10.15 — revalidación de la misma frontera stage 3 -> 4, ahora con el
# segundo beat gobernado por FSM física snapshotable en vez de coroutine/Tween.
var rollback_core3_first_beat_end_tick_ya_probado: int = -1
var h1014_core3_etapa_prev_j1: int = 0
var h1014_core3_etapa_prev_j2: int = 0
var h1014_first_beat_observador_inicializado: bool = false
var h1014_auto_test_armado: bool = false
var h1014_auto_test_tick_evento: int = -1
var h1014_auto_test_lado: String = ""
# H10.20 — SECOND BEAT END certificado en H10.18; frontera congelada.
# Detecta stage 4 -> 5, entrada al tercer beat FSM físico snapshotable.
var rollback_core3_second_beat_end_tick_ya_probado: int = -1
var h1016_core3_etapa_prev_j1: int = 0
var h1016_core3_etapa_prev_j2: int = 0
var h1016_second_beat_observador_inicializado: bool = false
var h1016_auto_test_armado: bool = false
var h1016_auto_test_tick_evento: int = -1
var h1016_auto_test_lado: String = ""
# H10.20 — revalidación del fin del TERCER beat físico CORE III.
# Detecta stage 5 -> 6, ahora entrando al cuarto beat físico snapshotable.
var rollback_core3_third_beat_end_tick_ya_probado: int = -1
var h1019_core3_etapa_prev_j1: int = 0
var h1019_core3_etapa_prev_j2: int = 0
var h1019_third_beat_observador_inicializado: bool = false
var h1019_auto_test_armado: bool = false
var h1019_auto_test_tick_evento: int = -1
var h1019_auto_test_lado: String = ""
# H10.24 — FOURTH BEAT END certificado en H10.22; frontera congelada.
# Detecta stage 6 -> 7, entrada al quinto beat FSM físico snapshotable.
var rollback_core3_fourth_beat_end_tick_ya_probado: int = -1
var h1021_core3_etapa_prev_j1: int = 0
var h1021_core3_etapa_prev_j2: int = 0
var h1021_fourth_beat_observador_inicializado: bool = false
var h1021_auto_test_armado: bool = false
var h1021_auto_test_tick_evento: int = -1
var h1021_auto_test_lado: String = ""
# H10.26 — FIFTH BEAT END certificado en H10.24; frontera congelada.
# Detecta stage 7 -> 8, entrada al sexto beat FSM físico snapshotable.
var rollback_core3_fifth_beat_end_tick_ya_probado: int = -1
var h1023_core3_etapa_prev_j1: int = 0
var h1023_core3_etapa_prev_j2: int = 0
var h1023_fifth_beat_observador_inicializado: bool = false
var h1023_auto_test_armado: bool = false
var h1023_auto_test_tick_evento: int = -1
var h1023_auto_test_lado: String = ""
# H10.26 — revalidación del fin del SEXTO beat físico CORE III.
# Detecta stage 8 -> 9, ahora entrando al séptimo beat físico snapshotable.
var rollback_core3_sixth_beat_end_tick_ya_probado: int = -1
var h1025_core3_etapa_prev_j1: int = 0
var h1025_core3_etapa_prev_j2: int = 0
var h1025_sixth_beat_observador_inicializado: bool = false
var h1025_auto_test_armado: bool = false
var h1025_auto_test_tick_evento: int = -1
var h1025_auto_test_lado: String = ""
# H10.32 — revalidación del fin del SÉPTIMO beat CORE III.
# H10.29 mostró regresión al entregar a beat 8 histórico; stage 9 -> 10 ahora entra al octavo beat físico.
var rollback_core3_seventh_beat_end_tick_ya_probado: int = -1
var h1027_core3_etapa_prev_j1: int = 0
var h1027_core3_etapa_prev_j2: int = 0
var h1027_seventh_beat_observador_inicializado: bool = false
var h1027_auto_test_armado: bool = false
var h1027_auto_test_tick_evento: int = -1
var h1027_auto_test_lado: String = ""
# H10.32 — revalidación del fin del OCTAVO beat CORE III: stage 10->11 entra al noveno beat físico.
# Detecta stage 10 -> 11: entrega al noveno beat histórico.
# No observa fases internas ni imprime por tick; una sola frontera snapshotable.
var rollback_core3_eighth_beat_end_tick_ya_probado: int = -1
var h1028_core3_etapa_prev_j1: int = 0
var h1028_core3_etapa_prev_j2: int = 0
var h1028_fase_prev_j1: int = 0
var h1028_fase_prev_j2: int = 0
var h1028_esperando_octavo_j1: bool = false
var h1028_esperando_octavo_j2: bool = false
# H10.29: un 9->10 también termina con fase_ataque -> 0, pero ese cierre
# pertenece al SÉPTIMO beat. Exigimos ver un ataque NUEVO ya dentro de stage 10
# antes de aceptar cualquier fase !=0 -> 0 como fin del octavo beat.
var h1029_octavo_ataque_visto_j1: bool = false
var h1029_octavo_ataque_visto_j2: bool = false
var h1028_eighth_beat_observador_inicializado: bool = false
var h1028_auto_test_armado: bool = false
var h1028_auto_test_tick_evento: int = -1
var h1028_auto_test_lado: String = ""
var h1029_localizacion_espera_ticks: int = 0
const H1029_LOCALIZACION_MAX_TICKS := 4
# H10.51 — diagnóstico del fin del DECIMOCTAVO beat CORE III.
# Detecta stage 20 -> 21: fin del decimoctavo beat físico y entrega al beat 19 histórico.
var rollback_core3_eighteenth_beat_end_tick_ya_probado: int = -1
var h1051_core3_etapa_prev_j1: int = 0
var h1051_core3_etapa_prev_j2: int = 0
var h1051_eighteenth_beat_observador_inicializado: bool = false
var h1051_auto_test_armado: bool = false
var h1051_auto_test_tick_evento: int = -1
var h1051_auto_test_lado: String = ""
var h1051_localizacion_espera_ticks: int = 0
const H1051_LOCALIZACION_MAX_TICKS := 4
# H10.53 — stage 21 contiene toda la continuación histórica desde beat 19.
# Diagnosticamos el PRIMER ataque histórico: fase_ataque 0 -> activa dentro de stage 21.
var rollback_core3_nineteenth_beat_attack_start_tick_ya_probado: int = -1
var h1053_core3_etapa_prev_j1: int = 0
var h1053_core3_etapa_prev_j2: int = 0
var h1053_fase_prev_j1: int = 0
var h1053_fase_prev_j2: int = 0
var h1053_esperando_primer_ataque_j1: bool = false
var h1053_esperando_primer_ataque_j2: bool = false
var h1053_nineteenth_attack_observador_inicializado: bool = false
var h1053_auto_test_armado: bool = false
var h1053_auto_test_tick_evento: int = -1
var h1053_auto_test_lado: String = ""
var h1053_localizacion_espera_ticks: int = 0
# H10.60 — siguiente frontera real tras la entrada ABSOLUTA certificada en H10.58.
# Diagnostica el fin del reveal/slow-motion de gigantografia en Main:
# time_scale 0.18 -> 0.42 mientras ronda_activa=false y CORE III permanece en stage 21.
var rollback_core3_absolute_reveal_end_tick_ya_probado: int = -1
var h1057_auto_test_armado: bool = false
var h1057_event_tick_hint: int = -1
var h1057_event_lado: String = ""
var h1057_localizacion_espera_ticks: int = 0
var h1057_scale_prev: float = 1.0
var h1057_scale_observador_inicializado: bool = false
const H1057_LOCALIZACION_MAX_TICKS := 4
# H10.60 — el SceneTreeTimer de 3.15 s del reveal ABSOLUTO no se rebobina.
# Lo reemplazamos SOLO en esta fase por un contador de physics ticks, capturable
# y restaurable. La continuación posterior (0.70 / 0.65) permanece histórica.
var core3_absolute_reveal_fsm_activo: bool = false
var core3_absolute_reveal_timer: float = 0.0
var core3_absolute_reveal_lado: int = 0 # 1=J1 / 2=J2
const CORE3_ABSOLUTE_REVEAL_DURACION := 3.15
# H10.62 — el runtime H10.61 probó que el SceneTreeTimer(0.70) del K.O.
# absoluto no se rebobina. Convertimos SOLO esa espera a contador physics
# snapshotable. La espera posterior de 0.65 s permanece histórica.
var core3_absolute_ko_fsm_activo: bool = false
var core3_absolute_ko_timer: float = 0.0
var core3_absolute_ko_lado: int = 0 # 1=J1 / 2=J2
const CORE3_ABSOLUTE_KO_DURACION := 0.70
var rollback_core3_absolute_ko_entry_tick_ya_probado: int = -1
var h1061_derrotado_prev_j1: bool = false
var h1061_derrotado_prev_j2: bool = false
var h1061_derrotado_observador_inicializado: bool = false
# H10.65 — el runtime H10.64 probó que el SceneTreeTimer(0.65) post-K.O.
# no se reproduce durante catch-up. Convertimos SOLO esa espera a contador
# physics snapshotable y revalidamos ABSOLUTE VICTORY ENTRY.
var core3_absolute_victory_fsm_activo: bool = false
var core3_absolute_victory_timer: float = 0.0
var core3_absolute_victory_lado: int = 0 # 1=J1 / 2=J2
const CORE3_ABSOLUTE_VICTORY_DURACION := 0.65
var rollback_core3_absolute_victory_entry_tick_ya_probado: int = -1
var h1063_victoria_prev_j1: bool = false
var h1063_victoria_prev_j2: bool = false
var h1063_victoria_observador_inicializado: bool = false
# H10.68 — target-only posterior a la entrada certificada H10.66. Esperamos
# nueve snapshots estables de victoria: ocho ticks a re-simular + el snapshot
# presente histórico inmediatamente posterior para comparar el HOLD completo.
var h1067_victory_hold_auto_test_armado: bool = false
var h1067_victory_hold_lado: String = ""
var h1067_victory_hold_snapshots_estables: int = 0
var h1067_victory_hold_localizacion_espera_ticks: int = 0
var rollback_core3_absolute_victory_hold_tick_ya_probado: int = -1
const H1067_VICTORY_HOLD_SNAPSHOTS_NECESARIOS := ROLLBACK_TEST_TICKS + 1

# H10.69 — target-only del borde posterior al HOLD: el SceneTreeTimer LIVE de
# 9.20 s llama _finalizar_partida_flujo() y en Versus local resetea la partida.
# No modifica gameplay: sólo espera suficientes snapshots post-reset para cruzar
# históricamente ese callback y exponer el primer causal si no es rebobinable.
var h1069_match_reset_auto_test_armado: bool = false
var h1069_match_reset_lado: String = ""
var h1069_match_reset_post_snapshots: int = 0
var h1069_match_reset_localizacion_espera_ticks: int = 0
var rollback_core3_absolute_match_reset_tick_ya_probado: int = -1
const H1069_MATCH_RESET_POST_SNAPSHOTS_NECESARIOS := 7
const H1069_LOCALIZACION_MAX_TICKS := 4
const H1067_LOCALIZACION_MAX_TICKS := 4
const H1053_LOCALIZACION_MAX_TICKS := 4
# H9.1 — último tick histórico de fin de recarga CORE II probado.
var rollback_core2_recarga_end_tick_ya_probado: int = -1
# H9.2 — observador automático del borde de fin de recarga CORE II.
# Main corre antes que Fighter: al inicio del tick ve el estado final del tick anterior.
var h92_recarga_prev_j1: bool = false
var h92_recarga_prev_j2: bool = false
var h92_recarga_observador_inicializado: bool = false
var h92_auto_test_armado: bool = false
var h92_auto_test_tick_evento: int = -1
var h92_auto_test_lado: String = ""
# H9.4 — observador automático del fin del PRIMER acercamiento CORE II.
# Detecta snapshotable stage 2 -> 3 (ACERCAMIENTO -> COMBO_ASYNC).
var h94_core2_etapa_prev_j1: int = 0
var h94_core2_etapa_prev_j2: int = 0
var h94_observador_inicializado: bool = false
var h94_auto_test_armado: bool = false
var h94_auto_test_tick_evento: int = -1
var h94_auto_test_lado: String = ""
var rollback_core2_combo_entry_tick_ya_probado: int = -1
# H9.6 — primer beat DENTRO de la ráfaga CORE II.
var h96_fase_prev_j1: int = 0
var h96_fase_prev_j2: int = 0
var h96_etapa_prev_j1: int = 0
var h96_etapa_prev_j2: int = 0
var h96_observador_inicializado: bool = false
var h96_esperando_first_beat_j1: bool = false
var h96_esperando_first_beat_j2: bool = false
var h96_auto_test_armado: bool = false
var h96_auto_test_tick_evento: int = -1
var h96_auto_test_lado: String = ""
var rollback_core2_first_beat_end_tick_ya_probado: int = -1
# H9.8 — borde ráfaga completa -> rematador CORE II.
var h98_etapa_prev_j1: int = 0
var h98_etapa_prev_j2: int = 0
var h98_observador_inicializado: bool = false
var h98_auto_test_armado: bool = false
var h98_auto_test_tick_evento: int = -1
var h98_auto_test_lado: String = ""
var rollback_core2_rematador_entry_tick_ya_probado: int = -1
# H9.9 — fin exacto del póster del rematador CORE II.
var rollback_core2_rematador_poster_serial: int = 0
var rollback_core2_rematador_poster_serial_ya_probado: int = 0
var rollback_core2_rematador_poster_tick_hint: int = -1
var rollback_core2_rematador_poster_lado: String = ""
var h99_auto_test_armado: bool = false
# H9.11 — cierre definitivo CORE II: espera final -> stage 0/control.
var h911_etapa_prev_j1: int = 0
var h911_etapa_prev_j2: int = 0
var h911_sub_prev_j1: int = 0
var h911_sub_prev_j2: int = 0
var h911_sec_prev_j1: bool = false
var h911_sec_prev_j2: bool = false
var h911_observador_inicializado: bool = false
var h911_auto_test_armado: bool = false
var h911_auto_test_tick_evento: int = -1
var h911_auto_test_lado: String = ""
var rollback_core2_sequence_end_tick_ya_probado: int = -1

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

# FASE 90.10.19 — DYNAMIC FIGHT CAMERA
# La cámara "respira" con la distancia: se abre cuando los luchadores se
# separan y se acerca de forma progresiva al entrar en cuerpo a cuerpo.
# La separación se filtra aparte para que el zoom no tiemble con cada paso.
var camara_separacion_suave: float = 480.0
const CAM_ZOOM_LEJOS := 0.93
const CAM_ZOOM_NORMAL := 1.00
const CAM_ZOOM_CERCA := 1.18
const CAM_FONDO_OVERSCAN_X := ANCHO_ARENA * 0.09

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
	# Arena propia de Jester integrada en 90.10.10.
	"Jester": Color(0.85, 0.25, 0.85),
	"Xenoid": Color(0.42, 1.0, 0.08),
	"Dax": Color(0.96, 0.18, 0.08),
	"Krovan": Color(1.0, 0.62, 0.12),
	"Nekhar": Color(1.0, 0.38, 0.08),
	# 90.11.15 — arena final violeta de Varkhos / El Ojo del Núcleo.
	"Varkhos": Color(0.62, 0.18, 1.0),
}

const FONDOS := {
	"Kai": "res://assets/fondos/kai.jpg",
	"Fang": "res://assets/fondos/fang.jpg",
	"Cibor-X": "res://assets/fondos/cibor-x.png",
	"Kali": "res://assets/fondos/kali.png",
	"Aethel": "res://assets/fondos/aethel.png",
	"Magnus": "res://assets/fondos/magnus.jpg",
	"Helena": "res://assets/fondos/helena.png",
	"Jester": "res://assets/fondos/jester.png",
	"Xenoid": "res://assets/fondos/xenoid.png",
	"Dax": "res://assets/fondos/dax.png",
	"Krovan": "res://assets/fondos/krovan.png",
	"Nekhar": "res://assets/fondos/nekhar.png",
	"Varkhos": "res://assets/fondos/varkhos.png",
}

const SND_GOLPE := preload("res://assets/sonidos/golpe.wav")
const SND_ESPECIAL := preload("res://assets/sonidos/especial.wav")
const SND_KO := preload("res://assets/sonidos/ko.wav")
const SND_VICTORIA := preload("res://assets/sonidos/cinematicas/finaliza_pelea.mp3")
const SND_PODER_FINAL_NUEVO := preload("res://assets/sonidos/cinematicas/poder_final.mp3")
const SND_READY_FIGHT_NUEVO := preload("res://assets/sonidos/cinematicas/ready_fight.mp3")
const SND_SALTO := preload("res://assets/sonidos/movimiento/salto_nuevo.wav")

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
const SND_CORE_LISTO := preload("res://assets/sonidos/core/core_listo_unificado.wav")
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
# 91.02.10 — pool masculino compartido basado en las voces ya usadas por Kai.
# Cibor-X conserva voz robótica; Helena conserva voz femenina propia.
const PERSONAJES_VOZ_MASCULINA := [
	"Kai", "Fang", "Aethel", "Magnus", "Dax",
	"Jester", "Xenoid", "Krovan", "Nekhar", "Varkhos"
]

# --- FASE 86.3: pegadas pesadas + ambiente Kai + identidad robótica Cibor-X ---
# Se retiraron por completo del selector los sonidos derivados de Slap/Hard Slap.
# Los golpes normales ahora parten de impactos de boxeo fuertes y una capa grave
# de cuerpo para que el contacto se sienta contundente sin sonar a palmada.
const SND_PUNO_BOXING_FUERTE := preload("res://assets/sonidos/impactos_pesados/boxing_strong_punch.wav")
const SND_PUNO_TOUGH_FUERTE := preload("res://assets/sonidos/impactos_pesados/tough_fighter_punch.wav")
const SND_THUMP_GRAVE := preload("res://assets/sonidos/impactos_pesados/thump_grave.wav")
const SND_KAI_AMBIENTE := preload("res://assets/sonidos/escenarios/kai_nuevo.mp3")
const SND_AETHEL_AMBIENTE := preload("res://assets/sonidos/escenarios/aethel.mp3")
const SND_CIBOR_AMBIENTE := preload("res://assets/sonidos/escenarios/cibor-x.mp3")
const SND_MAGNUS_AMBIENTE := preload("res://assets/sonidos/escenarios/magnus.mp3")
const SND_HELENA_AMBIENTE := preload("res://assets/sonidos/escenarios/helena.mp3")
const SND_KALI_AMBIENTE := preload("res://assets/sonidos/escenarios/kali.mp3")
const SND_FANG_AMBIENTE := preload("res://assets/sonidos/escenarios/fang.mp3")
const SND_JESTER_AMBIENTE := preload("res://assets/sonidos/escenarios/jester.wav")
const SND_XENOID_AMBIENTE := preload("res://assets/sonidos/escenarios/xenoid.mp3")
const SND_DAX_AMBIENTE := preload("res://assets/sonidos/escenarios/dax.mp3")
const SND_VARKHOS_AMBIENTE := preload("res://assets/sonidos/escenarios/varkhos.mp3")
# 91.02.10 — música oficial de las dos arenas nuevas.
const SND_KROVAN_AMBIENTE := preload("res://assets/sonidos/escenarios/krovan.mp3")
const SND_NEKHAR_AMBIENTE := preload("res://assets/sonidos/escenarios/nekhar.mp3")
const SND_CIBOR_STUN := preload("res://assets/sonidos/cibor_real/stun_intermitente.wav")
const SND_CIBOR_STUN_BURST := preload("res://assets/sonidos/cibor_real/stun_burst.wav")
const SND_CIBOR_BLASTER := preload("res://assets/sonidos/cibor_real/space_blaster.wav")

# --- FASE 86.4: nuevos gritos + voz Helena + golpe metálico Cibor-X ---
const SND_GRITO_HOMBRE_NUEVO_1 := preload("res://assets/sonidos/voces_reales_nuevas/grito_hombre_nuevo_1.wav")
const SND_GRITO_HOMBRE_NUEVO_2 := preload("res://assets/sonidos/voces_reales_nuevas/grito_hombre_nuevo_2.wav")
const SND_GRITO_HOMBRE_NUEVO_3 := preload("res://assets/sonidos/voces_reales_nuevas/grito_hombre_nuevo_3.wav")
const SND_GRITO_HOMBRE_NUEVO_4 := preload("res://assets/sonidos/voces_reales_nuevas/grito_hombre_nuevo_4.wav")
const SND_HELENA_GRITO_ATAQUE_1 := preload("res://assets/sonidos/helena_real/helena_grito_ataque_1.wav")
const SND_HELENA_RECARGA_CORE2 := preload("res://assets/sonidos/helena_real/helena_recarga_core2.wav")
const SND_HELENA_RECARGA_CORE3 := preload("res://assets/sonidos/helena_real/helena_recarga_core3.wav")
const SND_CIBOR_GOLPE_METAL_REAL := preload("res://assets/sonidos/cibor_real/golpe_metal_real.wav")
const SND_AETHEL_PODER_FINAL := preload("res://assets/sonidos/voces_aethel/aethel_poder_final_candidata.wav")
const SND_CIBOR_DOLOR_1 := preload("res://assets/sonidos/voces_cibor/cibor_dolor_1_candidata.wav")
const SND_CIBOR_DOLOR_2 := preload("res://assets/sonidos/voces_cibor/cibor_dolor_2_candidata.wav")
const SND_CIBOR_MUERTE := preload("res://assets/sonidos/voces_cibor/cibor_muerte_candidata.wav")
const SND_KALI_ATAQUE_1 := preload("res://assets/sonidos/voces_kali/kali_ataque_1_candidata.wav")

# --- FASE 86.5: voces dedicadas de recarga de energía ---
const SND_VOZ_RECARGA_MASC_A := preload("res://assets/sonidos/voces_recarga/recarga_masculina_a.wav")
const SND_VOZ_RECARGA_MASC_B := preload("res://assets/sonidos/voces_recarga/recarga_masculina_b.wav")
# 90.10.48 — aporte de audio: aura universal, impactos cortos y grito de recarga.
const SND_AURA_RECARGA_CORE2 := preload("res://assets/sonidos/aporte_90_10_48/aura_recarga_core2.wav")
const SND_AURA_RECARGA_CORE3 := preload("res://assets/sonidos/aporte_90_10_48/aura_recarga_core3.wav")
const SND_PUNO_USUARIO_SUAVE := preload("res://assets/sonidos/aporte_90_10_48/weakpunch_usuario.wav")
const SND_PATADA_USUARIO_SUAVE := preload("res://assets/sonidos/aporte_90_10_48/weakkick_usuario.wav")
const SND_VOZ_RECARGA_GENERICA := preload("res://assets/sonidos/aporte_90_10_48/grito_recarga_hombre.wav")
# 90.10.49 — sting cinematográfico dedicado al instante en que aparece la gigantografía CORE III.
const SND_GIGANTOGRAFIA_FINAL_USUARIO := preload("res://assets/sonidos/aporte_90_10_49/gigantografia_final_usuario.wav")
const PERSONAJES_VOZ_RECARGA_MASC := [
	"Kai", "Fang", "Aethel", "Magnus", "Jester", "Xenoid", "Kali", "Dax",
	"Krovan", "Nekhar", "Varkhos"
]

var audio_golpe: AudioStreamPlayer
var audio_especial: AudioStreamPlayer
var audio_ko: AudioStreamPlayer
var audio_victoria: AudioStreamPlayer
var audio_poder_final: AudioStreamPlayer
var audio_salto: AudioStreamPlayer
# 91.02.12 — player dedicado para recortar el grito de Helena exactamente al tiempo de recarga.
var audio_helena_recarga: AudioStreamPlayer
var helena_recarga_serial: int = 0
var audio_musica_batalla: AudioStreamPlayer
var audio_ambiente_escenario: AudioStreamPlayer
var ambiente_escenario_actual := ""
# 90.10.50 — al entrar el cierre de partida bloqueamos el loop del escenario
# para que gigantografía y victoria tengan espacio sonoro limpio.
var audio_escenario_bloqueado_final := false
# Evita una pared de gritos cuando conecta un combo de muchos impactos.
var ultima_voz_reaccion_ms: Dictionary = {}
var ultimo_grito_ataque_ms: Dictionary = {}

# --- Sistema de rondas ---
var rondas_kai := 0
var rondas_rival := 0
var ronda_activa := true
var etiqueta_resultado: Label
var etiqueta_marcador: Label

func _configurar_modo_bajo_visual_perf1() -> void:
	perf_renderer_actual = str(RenderingServer.get_current_rendering_method())
	modo_bajo_visual = online_activo or perf_renderer_actual == "gl_compatibility"
	print("[91.02.67-PERF1] PERFIL VISUAL=%s renderer=%s online=%s" % [
		"BAJO" if modo_bajo_visual else "NORMAL",
		perf_renderer_actual,
		str(online_activo)
	])


func _perf1_log_fps(delta: float) -> void:
	perf_diag_acumulado += delta
	if perf_diag_acumulado < 2.0:
		return
	perf_diag_acumulado = 0.0
	print("[91.02.67-PERF1] FPS=%d perfil=%s renderer=%s" % [
		Engine.get_frames_per_second(),
		"BAJO" if modo_bajo_visual else "NORMAL",
		perf_renderer_actual
	])


func _ready() -> void:
	# Debe ocurrir antes de crear escenario/personajes para que la metadata del
	# replay pueda restaurar J1, J2 y arena sin tocar el estado del Fighter.
	online_activo = _detectar_modo_online()
	_configurar_modo_bajo_visual_perf1()
	_preparar_solicitud_replay()
	_preparar_rng_determinista_versus()
	_crear_escenario()
	_crear_ambiente()
	_crear_escenario_vivo()
	_crear_camara()
	_crear_ambiente_glow()
	_crear_audio()
	_crear_personajes()
	if replay_modo_activo:
		_iniciar_replay_inputs()
	else:
		_iniciar_grabacion_inputs()
	_crear_iluminacion_luchadores()
	_crear_ui()
	_crear_capa_destello()
	if (versus_local_activo or online_activo) and not replay_modo_activo:
		rollback_ring = RollbackRingBufferScript.new(ROLLBACK_BUFFER_TICKS)
		if online_activo:
			print("[91.02.69-P14D2B] ONLINE RING ARMADO — capacidad=%d ticks; captura aún diagnóstica" % ROLLBACK_BUFFER_TICKS)
	if versus_local_activo and not online_activo and not replay_modo_activo:
		print("[91.00.00-H10.88] ROLLBACK BUFFER ACTIVO — F11 rebobina %d ticks" % ROLLBACK_TEST_TICKS)
		rollback_motion_guard = RollbackNeutralMotionGuardScript.new()
		rollback_motion_guard.name = "RollbackNeutralMotionGuard"
		add_child(rollback_motion_guard)
		rollback_motion_guard.configurar(self, kai, rival)
		print("[91.00.00-H10.88] HISTORICAL X GUARD — LIVE pasivo / rollback usa X absoluta del snapshot siguiente")
		print("[91.00.00-H10.88] TACTICAL PHYSICS CLOCK — PerfectBlock sin Time.get_ticks_msec(); reloj+deadlines en snapshot")
		print("[91.00.00-H10.88] BACKDASH PHYSICS STEP — movimiento/timer fuera de _process(); simulación fija")
		print("[91.00.00-H10.88] LAUNCHER/AIR COMBO TEST — F11 localiza LAUNCH! o AIR xN dentro del ring")
		print("[91.00.00-H10.88] EVENT TICK LOCATOR — eventos identificados por tick monotónico; PRETICK compacto")
		print("[91.00.00-H10.88] CORE I SAFE ENTRY — safety gate H6.1 intacto; evento por señal fase_activada")
		print("[91.00.00-H10.88] CORE I PHYSICS TARGET LOCK — Tween eliminado sólo del acercamiento CORE I")
		print("[91.00.00-H10.88] CORE I TARGET END TEST — cruza final del lock -> continuación async/impacto")
		print("[91.00.00-H10.88] CORE I EXPLICIT FSM — continuación post-lock + espera lógica del poster por physics ticks")
		print("[91.00.00-H10.88] CORE I POSTER END TEST — transición snapshot POSTER->INACTIVO y devolución de control")
		print("[91.00.00-H10.88] CORE II ENTRY TEST — activación 1->2 + arranque de recarga; sin cambios de gameplay")
		print("[91.00.00-H10.88] CORE II RECARGA END TEST — cruza timer 1.05 s -> continuación await / acercamiento combo")
		print("[91.00.00-H10.88] AUTO CAPTURE — fin de recarga CORE II dispara rollback automáticamente; no usar F11")
		print("[91.00.00-H10.88] CORE II PHYSICS RECARGA+APPROACH — SceneTreeTimer y primer Tween eliminados de lógica CORE II")
		print("[91.00.00-H10.88] CORE II COMBO ENTRY AUTO — cruza stage 2->3 e inicio de _racha_combo_auto(); no usar F11")
		print("[91.00.00-H10.88] CORE II COMBO APPROACH PHYSICS — sin Tween por beat; stage 3 gobernado por FSM")
		print("[91.00.00-H10.88] CORE II FIRST BEAT END AUTO — prueba restore dentro de stage 3; no usar F11")
		print("[91.00.00-H10.88] CORE II COMBO FSM — coreografía/índice/subfase/acercamiento internos snapshotables; combo ya no usa coroutine")
		print("[91.00.00-H10.88] CORE II REMATADOR ENTRY AUTO — cruza stage 3->4; rematador aún async; no usar F11")
		print("[91.00.00-H10.88] CORE II REMATADOR FSM — póster lógico + impacto + espera 0.10 por physics ticks; sin coroutine")
		print("[91.00.00-H10.88] CORE II SEQUENCE END AUTO — cruza espera final 0.10 -> stage0/control; diagnóstico puro")
		print("[91.00.00-H10.88] CORE III ENTRY AUTO — tercera activación + inicio de recarga lenta 1.55 s; sin cambios de gameplay")
		print("[91.00.00-H10.88] CORE III EXACT ENTRY — espera 6 ticks post-evento; restore un tick antes; sin contaminación de movimiento previo")
		print("[91.00.00-H10.88] CORE III EXPLICIT HISTORICAL DELTA — J1/J2/PB reproducen el delta LIVE; sin depender del scheduler")
		print("[91.00.00-H10.88] CORE III ENTRY CERTIFIED — J1/J2 8 ticks idénticos en H10.8; frontera congelada")
		print("[91.00.00-H10.88] CORE III RECARGA+APPROACH PHYSICS — timer no escalado + Target Lock snapshotable; SceneTreeTimer/Tween lógicos eliminados")
		print("[91.00.00-H10.88] CORE III RECARGA END CERTIFIED — J1/J2 8 ticks idénticos en H10.11; frontera congelada")
		print("[91.00.00-H10.88] CORE III PB DELTA CERTIFIED — H10.18 reconfirmó ENTRY/RECARGA/APPROACH J1/J2; frontera congelada")
		print("[91.00.00-H10.88] CORE III FIRST+SECOND+THIRD+FOURTH+FIFTH+SIXTH+SEVENTH+EIGHTH+NINTH+TENTH+ELEVENTH+TWELFTH+THIRTEENTH+FOURTEENTH+FIFTEENTH+SIXTEENTH+SEVENTEENTH+EIGHTEENTH BEAT PHYSICS — beats 1-18 sin Tween/coroutine; resto histórico desde beat 19")
		print("[91.00.00-H10.88] CORE III FIRST BEAT END CERTIFIED — J1/J2 8 ticks idénticos en H10.15; frontera congelada")
		print("[91.00.00-H10.88] CORE III SECOND BEAT END CERTIFIED — J1/J2 8 ticks idénticos en H10.18; frontera congelada")
		print("[91.00.00-H10.88] CORE III THIRD BEAT END CERTIFIED — J1/J2 8 ticks idénticos en H10.20; frontera congelada")
		print("[91.00.00-H10.88] CORE III FOURTH BEAT END CERTIFIED — J1/J2 8 ticks idénticos en H10.22; frontera congelada")
		print("[91.00.00-H10.88] CORE III FIFTH BEAT END CERTIFIED — J1/J2 8 ticks idénticos en H10.24; frontera congelada")
		print("[91.00.00-H10.88] CORE III SIXTH BEAT END CERTIFIED — J1/J2 8 ticks idénticos en H10.26; frontera congelada")
		print("[91.00.00-H10.88] CORE III SEVENTH BEAT END CERTIFIED — H10.30 revalidó J1/J2 8 ticks idénticos; frontera recongelada")
		print("[91.00.00-H10.88] CORE III EIGHTH BEAT END CERTIFIED — H10.32 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III NINTH BEAT END CERTIFIED — H10.34 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III TENTH BEAT END CERTIFIED — H10.36 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III ELEVENTH BEAT END CERTIFIED — H10.38 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III TWELFTH BEAT END CERTIFIED — H10.40 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III THIRTEENTH BEAT END CERTIFIED — H10.42 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III FOURTEENTH BEAT END CERTIFIED — H10.44 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III FIFTEENTH BEAT END CERTIFIED — H10.46 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III SIXTEENTH BEAT END CERTIFIED — H10.48 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III SEVENTEENTH BEAT END CERTIFIED — H10.50 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III EIGHTEENTH BEAT END CERTIFIED — H10.52 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III ABSOLUTE FINISHER ENTRY CERTIFIED — H10.58 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III ABSOLUTE REVEAL END CERTIFIED — H10.60 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III ABSOLUTE KO ENTRY CERTIFIED — H10.62 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III ABSOLUTE VICTORY ENTRY CERTIFIED — H10.66 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE III ABSOLUTE VICTORY HOLD CERTIFIED — H10.68 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] CORE I/II/III ROLLBACK CERTIFIED BASELINE — frontera terminal en ABSOLUTE VICTORY HOLD; salida a Resultado.tscn queda fuera del dominio rollback")
		print("[91.00.00-H10.88] PERFECT BLOCK CERTIFIED — H10.72 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] COUNTER CERTIFIED — H10.71 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] LAUNCHER CERTIFIED — H10.73 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] AIR x1 CERTIFIED — H10.74 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] AIR x2 CERTIFIED — H10.75 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] AIR x3 CERTIFIED — H10.76 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] BACKDASH CERTIFIED — H10.77 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] FORWARD DASH CERTIFIED — H10.78 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] NORMAL PUNCH IMPACT CERTIFIED — H10.79 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] NORMAL KICK IMPACT CERTIFIED — H10.80 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] NORMAL PUNCH BLOCK CERTIFIED — H10.82 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] NORMAL KICK BLOCK CERTIFIED — H10.83 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] NORMAL BLOCK RECOVERY CERTIFIED — H10.85 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] NORMAL ATTACK RECOVERY CERTIFIED — H10.86 revalidó J1/J2 8 ticks idénticos; frontera congelada")
		print("[91.00.00-H10.88] NORMAL COMBAT INTEGRAL CERTIFIED — H10.87 revalidó J1/J2 6/6 checkpoints; frontera congelada")
		print("[91.00.00-H10.88] CLEAN BASELINE — arnés integral automático desactivado; rollback manual F11 permanece disponible para diagnóstico")
	if online_activo:
		_preparar_online_combate()
	else:
		call_deferred("_presentar_ready_fight")

# 90.10.94 — Main sigue siendo el único lector de dispositivos en Versus Local.
# Al ser el padre de los Fighter, inyecta el frame antes de sus physics ticks.
func _physics_process(_delta: float) -> void:
	# PASS 14D1 — Main puede terminar de cargar antes que el otro peer. Hasta
	# recibir COMBATE GO no consumimos ticks lógicos, input ni snapshots.
	if online_activo and not online_combate_habilitado:
		return

	# 91.02.70 — reconciliación ONLINE siempre empieza en frontera Main.
	# NetworkManager puede recibir paquetes en cualquier momento, pero nunca
	# restauramos estado desde el callback RPC.
	if online_activo:
		if online_rollback_finalizar_pendiente:
			_online_finalizar_rollback()
		if online_rollback_tick_pendiente >= 0 and not rollback_catchup_activo:
			_online_iniciar_rollback_pendiente()

	# H10.6 — FRAME A: segundo restore y pausa total. Este frame puede haber
	# nacido todavía con delta heredado de la cámara lenta LIVE, por eso no se
	# permite ejecutar ningún simulador ni consumir input histórico.
	if rollback_catchup_preparando_timescale:
		rollback_catchup_preparando_timescale = false

		if not rollback_catchup_inicio_timescale.is_empty():
			RollbackSnapshotScript.restaurar_partida(
				self,
				kai,
				rival,
				rollback_catchup_inicio_timescale
			)

		if is_instance_valid(kai):
			kai.set_physics_process(false)
		if is_instance_valid(rival):
			rival.set_physics_process(false)
		if is_instance_valid(PerfectBlock90_1):
			PerfectBlock90_1.set_physics_process(false)

		rollback_catchup_activo = false
		rollback_catchup_reactivar_tactico_next_tick = false
		rollback_catchup_reactivacion_deferred_pendiente = false
		rollback_catchup_commit_restore_pendiente = false
		rollback_catchup_barrier_frames_restantes = 1
		print("[91.00.00-H10.88] CORE III BARRIER FRAME A — segundo restore; simuladores pausados; falta 1 frame de estabilización")
		return

	# H10.6 — FRAME B: time_scale ya lleva un frame restaurado en 1.0. Dejamos
	# pasar otro physics frame COMPLETO con Fighter/PB apagados para que el delta
	# del frame de commit nazca inequívocamente a 1/60.
	if rollback_catchup_barrier_frames_restantes > 0:
		rollback_catchup_barrier_frames_restantes -= 1
		if not rollback_catchup_inicio_timescale.is_empty():
			Engine.time_scale = float(rollback_catchup_inicio_timescale.get("time_scale", 1.0))
		if is_instance_valid(kai):
			kai.set_physics_process(false)
		if is_instance_valid(rival):
			rival.set_physics_process(false)
		if is_instance_valid(PerfectBlock90_1):
			PerfectBlock90_1.set_physics_process(false)

		if rollback_catchup_barrier_frames_restantes <= 0 and not rollback_catchup_reactivacion_deferred_pendiente:
			rollback_catchup_reactivacion_deferred_pendiente = true
			call_deferred("_h106_armar_core3_commit_post_frame")
		print("[91.00.00-H10.88] CORE III BARRIER FRAME B — estabilización completa a time_scale=%.4f; commit deferred armado" % [float(Engine.time_scale)])
		return

	# H10.6 — COMMIT: Fighters ya están schedulados para este frame. Restauramos
	# por TERCERA vez al entrar Main, antes de cualquier Fighter/PB. El delta de
	# este frame ya nació a escala 1.0 gracias a FRAME B.
	if rollback_catchup_commit_restore_pendiente:
		rollback_catchup_commit_restore_pendiente = false
		if not rollback_catchup_inicio_timescale.is_empty():
			RollbackSnapshotScript.restaurar_partida(
				self,
				kai,
				rival,
				rollback_catchup_inicio_timescale
			)
		if is_instance_valid(kai):
			kai.set_physics_process(true)
		if is_instance_valid(rival):
			rival.set_physics_process(true)
		if is_instance_valid(PerfectBlock90_1):
			PerfectBlock90_1.set_physics_process(true)
		rollback_catchup_activo = true
		print("[91.00.00-H10.88] CORE III BARRIER COMMIT RESTORE — estado histórico reimpuesto; primer subtick inicia en este frame")

	# La comparación debe hacerse al INICIO del tick siguiente al último frame
	# re-simulado, porque los Fighter procesan después de Main.
	if rollback_comparacion_pendiente:
		_finalizar_prueba_rollback_local()

	# 91.00.00-H10.13 — F11 sólo arma una solicitud desde el ciclo de input.
	# El rebobinado real empieza acá, en una frontera exacta de physics tick.
	if online_activo and rollback_test_solicitado:
		# Los armadores históricos de F11 no pertenecen al combate online.
		rollback_test_solicitado = false
	if rollback_test_solicitado and not online_activo and not rollback_catchup_activo and not rollback_comparacion_pendiente:
		rollback_test_solicitado = false
		_iniciar_prueba_rollback_local()

	# Si _iniciar_prueba_rollback_local() armó H10.2 ahora mismo, no registrar
	# snapshots ni inyectar input LIVE. Fighters y PB están pausados hasta el
	# próximo physics frame.
	if rollback_catchup_preparando_timescale:
		return

	if rollback_catchup_activo:
		_rollback_verificar_subtick()

	# Durante catch-up no agregamos snapshots nuevos: estamos recorriendo historia.
	if (versus_local_activo or online_activo) and not replay_modo_activo and not rollback_catchup_activo:
		_rollback_registrar_inicio_tick()
		# El arnés TARGET-ONLY/F11 sigue siendo EXCLUSIVO de Versus Local.
		# Online 14D2B sólo captura historia; todavía no restaura ni re-simula.
		if versus_local_activo and not online_activo:
			_h1057_observar_absolute_finisher_stage_trace_post_snapshot()
		# H10.88 — regresión integral H10.87 certificada; arnés automático desactivado.

	_inyectar_inputs_versus_local()
	# H10.65 — VICTORY se actualiza ANTES que KO. Si KO arma la espera 0.65 s
	# en este mismo frame, VICTORY recién consume su primer tick REAL en el
	# physics frame siguiente; esto conserva la frontera temporal LIVE.
	_h1065_actualizar_core3_absolute_victory_fsm()
	# H10.62 — el K.O. physics se actualiza ANTES del reveal. Así, cuando el
	# reveal 3.15 s arma la espera 0.70 s en este mismo frame, el contador KO
	# recién consume su primer tick REAL en el physics frame siguiente.
	_h1062_actualizar_core3_absolute_ko_fsm()
	# H10.60 — actualizar DESPUÉS de fijar deltas históricos. Si este tick
	# cruza el final del reveal, Engine.time_scale queda en 0.42 antes de que
	# Fighters/PB consuman el subtick causal.
	_h1060_actualizar_core3_absolute_reveal_fsm()

# H10.6 — deferred al terminar FRAME B. Sólo reactiva Fighters para que queden
# incluidos en el scheduler del próximo physics frame. PerfectBlock permanece
# apagado hasta el COMMIT RESTORE de Main; así no puede sumar un tick fantasma.
func _h106_armar_core3_commit_post_frame() -> void:
	if not rollback_catchup_reactivacion_deferred_pendiente:
		return
	rollback_catchup_reactivacion_deferred_pendiente = false

	if not rollback_catchup_inicio_timescale.is_empty():
		Engine.time_scale = float(rollback_catchup_inicio_timescale.get("time_scale", 1.0))

	if is_instance_valid(kai):
		kai.set_physics_process(true)
	if is_instance_valid(rival):
		rival.set_physics_process(true)
	if is_instance_valid(PerfectBlock90_1):
		PerfectBlock90_1.set_physics_process(false)

	rollback_catchup_activo = false
	rollback_catchup_commit_restore_pendiente = true
	print("[91.00.00-H10.88] CORE III BARRIER DEFERRED ARM — Fighters schedulados; PerfectBlock sigue pausado; commit en próximo Main")

# FASE 92: capa de destello de pantalla completa para golpes fuertes. Va en
# una CanvasLayer bien arriba (por encima incluso de la UI) para que un
# remate/absoluto se sienta en TODA la pantalla, no solo en el personaje.
func _crear_capa_destello() -> void:
	if modo_bajo_visual:
		vineta_rect = null
		vineta_material = null
		destello_rect = null
		destello_material = null
		return
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
	if modo_bajo_visual:
		return
	if not destello_material:
		return
	if destello_tween and is_instance_valid(destello_tween):
		destello_tween.kill()
	destello_material.set_shader_parameter("flash_color", color)
	destello_material.set_shader_parameter("intensidad", intensidad_max)
	destello_tween = create_tween()
	destello_tween.tween_property(destello_material, "shader_parameter/intensidad", 0.0, duracion_caida).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# 91.00.00-H10.13 — RELOJ DETERMINISTA DE COMBATE.
# Cualquier espera que habilite/deshabilite gameplay en Versus Local debe medirse
# en physics ticks, no con timers de tiempo real. Esto evita que READY/FIGHT o
# el cambio de ronda caigan un tick distinto entre grabación y replay.
func _segundos_a_ticks_fisica(segundos: float) -> int:
	return maxi(1, int(round(segundos * float(Engine.physics_ticks_per_second))))

func _esperar_ticks_fisica(cantidad: int) -> void:
	for _i in range(maxi(cantidad, 0)):
		await get_tree().physics_frame

func _esperar_segundos_fisica(segundos: float) -> void:
	await _esperar_ticks_fisica(_segundos_a_ticks_fisica(segundos))

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

	# 91.00.00-H: 1.65 s y 1.98 s se convierten una sola vez a ticks enteros.
	# Grabación y replay cruzan el gate en el MISMO physics frame.
	await _esperar_segundos_fisica(1.65)
	etiqueta_resultado.text = "FIGHT!"
	etiqueta_resultado.add_theme_color_override("font_color", Color(1.0, 0.55, 0.12))
	sacudir_camara(5.0, 0.14)
	await _esperar_segundos_fisica(1.98)
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

# 91.02.10 — AUDIO COMPLETION PASS
# Cobertura auditada: impactos/bloqueo/caída/CORE universal; recarga CORE II/III
# con aura universal; voces masculinas completadas con el pool de Kai; Cibor-X
# conserva identidad robótica; Helena ya tiene voz femenina dedicada de recarga.
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

	# 91.02.12 — Helena usa un player dedicado para poder cortar su voz
	# exactamente cuando termina la recarga, sin dejarla invadir el combo.
	audio_helena_recarga = AudioStreamPlayer.new()
	audio_helena_recarga.stream = SND_HELENA_RECARGA_CORE2
	add_child(audio_helena_recarga)

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
	audio_escenario_bloqueado_final = false
	ambiente_escenario_actual = nombre_luchador
	audio_ambiente_escenario.stop()
	audio_ambiente_escenario.stream = null

	# Volúmenes compensados según el nivel real de cada archivo para que todas
	# las arenas queden al fondo de la mezcla sin tapar golpes, voces ni poderes.
	match nombre_luchador:
		"Kai":
			audio_ambiente_escenario.stream = SND_KAI_AMBIENTE
			audio_ambiente_escenario.volume_db = -11.0
		"Aethel":
			audio_ambiente_escenario.stream = SND_AETHEL_AMBIENTE
			audio_ambiente_escenario.volume_db = -6.5
		"Cibor-X":
			audio_ambiente_escenario.stream = SND_CIBOR_AMBIENTE
			audio_ambiente_escenario.volume_db = -13.0
		"Jester":
			audio_ambiente_escenario.stream = SND_JESTER_AMBIENTE
			audio_ambiente_escenario.volume_db = -13.0
		"Xenoid":
			audio_ambiente_escenario.stream = SND_XENOID_AMBIENTE
			audio_ambiente_escenario.volume_db = -13.5
		"Dax":
			audio_ambiente_escenario.stream = SND_DAX_AMBIENTE
			audio_ambiente_escenario.volume_db = -15.0
		"Varkhos":
			audio_ambiente_escenario.stream = SND_VARKHOS_AMBIENTE
			audio_ambiente_escenario.volume_db = -14.0
		"Krovan":
			audio_ambiente_escenario.stream = SND_KROVAN_AMBIENTE
			# Pista entregada a ~-17.5 dBFS: queda al fondo sin tapar golpes/voces.
			audio_ambiente_escenario.volume_db = -10.0
		"Nekhar":
			audio_ambiente_escenario.stream = SND_NEKHAR_AMBIENTE
			# Intro más atmosférica; un poco más presente que Krovan.
			audio_ambiente_escenario.volume_db = -8.5
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
	# de combate siga viva. En el cierre final 90.10.50 queda bloqueado para que
	# la música del escenario no reaparezca encima de gigantografía/victoria.
	if audio_escenario_bloqueado_final:
		return
	if audio_ambiente_escenario and audio_ambiente_escenario.stream != null and ambiente_escenario_actual != "":
		audio_ambiente_escenario.play()

# 90.10.50 — corte cinematográfico del escenario al entrar el final.
# No toca SFX, voces ni audio de victoria; sólo las capas musicales/ambientales
# persistentes que podrían competir con el golpe final.
func _detener_audio_escenario_final() -> void:
	audio_escenario_bloqueado_final = true
	if audio_ambiente_escenario and audio_ambiente_escenario.playing:
		audio_ambiente_escenario.stop()
	if audio_musica_batalla and audio_musica_batalla.playing:
		audio_musica_batalla.stop()

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
	return _elegir_sfx([SND_PUNO_TOUGH_FUERTE, SND_PUNO_BOXING_FUERTE, SND_REAL_PUNO_SECO_A, SND_PUNO_USUARIO_SUAVE])

func _sfx_patada_real(fuerza: float) -> AudioStream:
	if fuerza >= 18.0:
		return _elegir_sfx([SND_REAL_PATADA_B, SND_REAL_IMPACTO_MIXTO_B, SND_REAL_PATADA_A, SND_PUNO_TOUGH_FUERTE])
	return _elegir_sfx([SND_REAL_PATADA_CORTA, SND_REAL_PATADA_A, SND_REAL_PATADA_B, SND_REAL_IMPACTO_MIXTO_A, SND_REAL_IMPACTO_MIXTO_B, SND_PATADA_USUARIO_SUAVE])

func _sfx_pesado_real() -> AudioStream:
	return _elegir_sfx([SND_PUNO_BOXING_FUERTE, SND_PUNO_TOUGH_FUERTE, SND_REAL_PUNO_CRUNCH_A, SND_REAL_PUNO_CRUNCH_B])

func _usa_voz_masculina(personaje: Fighter) -> bool:
	return is_instance_valid(personaje) and personaje.nombre_luchador in PERSONAJES_VOZ_MASCULINA

func _pitch_voz(personaje: Fighter) -> float:
	if not is_instance_valid(personaje):
		return 1.0
	match personaje.nombre_luchador:
		"Magnus": return randf_range(0.76, 0.82)
		"Varkhos": return randf_range(0.78, 0.84)
		"Nekhar": return randf_range(0.84, 0.90)
		"Krovan": return randf_range(0.90, 0.96)
		"Fang": return randf_range(0.91, 0.97)
		"Jester": return randf_range(0.97, 1.03)
		"Xenoid": return randf_range(1.02, 1.08)
		"Aethel": return randf_range(1.01, 1.07)
		_: return randf_range(0.96, 1.03)

func _reproducir_recarga_helena(absoluta: bool) -> void:
	if not is_instance_valid(audio_helena_recarga):
		return
	# CORE II dura 1.05 s y CORE III 1.55 s en Fighter. El corte usa tiempo
	# real (ignore_time_scale=true) para que la cámara lenta de CORE III no
	# alargue la voz más allá de la pose de recarga.
	var duracion: float = 1.55 if absoluta else 1.05
	helena_recarga_serial += 1
	var serial_actual: int = helena_recarga_serial
	audio_helena_recarga.stop()
	audio_helena_recarga.stream = SND_HELENA_RECARGA_CORE3 if absoluta else SND_HELENA_RECARGA_CORE2
	audio_helena_recarga.volume_db = -5.0 if absoluta else -6.0
	audio_helena_recarga.pitch_scale = 1.0
	audio_helena_recarga.play()
	# El archivo ya viene recortado exactamente a la duración de la pose;
	# este timer queda como seguro de corte por si el decoder agrega cola.
	var corte := get_tree().create_timer(duracion, true, false, true)
	corte.timeout.connect(func():
		if serial_actual == helena_recarga_serial and is_instance_valid(audio_helena_recarga):
			audio_helena_recarga.stop()
	)

func _reproducir_voz_recarga(personaje: Fighter, absoluta: bool) -> bool:
	# 91.02.12 — Helena ya tiene clip femenino dedicado y corte exacto por duración de recarga.
	# Cibor-X sigue sin voz humana y el resto conserva el pool masculino ya auditado.
	if not is_instance_valid(personaje):
		return false
	if personaje.nombre_luchador == "Helena":
		_reproducir_recarga_helena(absoluta)
		return true
	if not (personaje.nombre_luchador in PERSONAJES_VOZ_RECARGA_MASC):
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
			stream = SND_VOZ_RECARGA_GENERICA
			pitch = 0.88
			volumen = -5.0 if absoluta else -6.0
		"Jester":
			stream = SND_VOZ_RECARGA_GENERICA
			pitch = 0.98
			volumen = -5.2 if absoluta else -6.2
		"Xenoid":
			stream = SND_VOZ_RECARGA_GENERICA
			pitch = 1.04
			volumen = -5.6 if absoluta else -6.5
		"Kali":
			stream = SND_VOZ_RECARGA_GENERICA
			pitch = 0.96
			volumen = -5.5 if absoluta else -6.4
		"Krovan":
			# Reutiliza la voz de Kai con pitch más áspero/grave.
			stream = SND_VOZ_RECARGA_MASC_A
			pitch = 0.93
			volumen = -5.4 if absoluta else -6.4
		"Nekhar":
			stream = SND_VOZ_RECARGA_MASC_B
			pitch = 0.87
			volumen = -5.2 if absoluta else -6.2
		"Varkhos":
			stream = SND_VOZ_RECARGA_MASC_B
			pitch = 0.80
			volumen = -4.8 if absoluta else -5.8
	_reproducir_sfx(stream, volumen, pitch)
	return true

# 91.02.56 — voz corta de lanzamiento de proyectil.
# Usa los MISMOS bancos de voz de recarga ya existentes, pero sólo deja sonar
# una fracción inicial para que funcione como "¡HA!" / esfuerzo breve.
func _al_proyectil_disparado(personaje: Fighter) -> void:
	if not is_instance_valid(personaje):
		return
	# Varkhos queda deliberadamente excluido del sistema de proyectiles.
	if personaje.nombre_luchador == "Varkhos":
		return

	var stream: AudioStream = null
	var pitch: float = 1.0
	var volumen: float = -9.0
	var duracion: float = 0.30

	match personaje.nombre_luchador:
		"Helena":
			stream = SND_HELENA_RECARGA_CORE2
			pitch = 1.0
			volumen = -9.4
			duracion = 0.28
		"Cibor-X":
			# Mantiene identidad robótica: esfuerzo electrónico corto en lugar
			# de insertar una voz humana que nunca usa en sus recargas.
			stream = SND_CIBOR_STUN_BURST
			pitch = 1.03
			volumen = -12.0
			duracion = 0.20
		"Kai":
			stream = SND_VOZ_RECARGA_MASC_A
			pitch = 1.0
		"Fang":
			stream = SND_VOZ_RECARGA_MASC_B
			pitch = 0.92
		"Aethel":
			stream = SND_VOZ_RECARGA_MASC_A
			pitch = 1.055
		"Magnus":
			stream = SND_VOZ_RECARGA_GENERICA
			pitch = 0.88
			duracion = 0.32
		"Jester":
			stream = SND_VOZ_RECARGA_GENERICA
			pitch = 0.98
		"Xenoid":
			stream = SND_VOZ_RECARGA_GENERICA
			pitch = 1.04
		"Kali":
			stream = SND_VOZ_RECARGA_GENERICA
			pitch = 0.96
		"Dax":
			stream = SND_VOZ_RECARGA_MASC_A
			pitch = 0.98
		"Krovan":
			stream = SND_VOZ_RECARGA_MASC_A
			pitch = 0.93
		"Nekhar":
			stream = SND_VOZ_RECARGA_MASC_B
			pitch = 0.87
			duracion = 0.32
		_:
			return

	if not stream:
		return

	# Player temporal independiente: no corta el SFX propio del proyectil.
	var voz := AudioStreamPlayer.new()
	voz.stream = stream
	voz.volume_db = volumen
	voz.pitch_scale = pitch
	add_child(voz)
	voz.play()

	# Corte en tiempo real para que sea sólo un ataque vocal corto.
	var corte := get_tree().create_timer(duracion, true, false, true)
	corte.timeout.connect(func():
		if is_instance_valid(voz):
			voz.stop()
			voz.queue_free()
	)


func _reaccion_vocal_golpe(personaje: Fighter, fuerza: float, tipo: String) -> void:
	var es_cibor: bool = is_instance_valid(personaje) and personaje.nombre_luchador == "Cibor-X"
	var es_helena: bool = is_instance_valid(personaje) and personaje.nombre_luchador == "Helena"
	var es_kali: bool = is_instance_valid(personaje) and personaje.nombre_luchador == "Kali"
	if not es_cibor and not es_helena and not es_kali and not _usa_voz_masculina(personaje):
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
	# Hasta recibir clips de dolor dedicados, Helena/Kali reutilizan SU propia
	# voz existente a volumen/pitch de reacción; nunca se les aplica voz masculina.
	if es_helena:
		_reproducir_sfx(SND_HELENA_GRITO_ATAQUE_1, -9.2 if fuerza < 17.0 else -7.2, randf_range(0.90, 0.96))
		return
	if es_kali:
		_reproducir_sfx(SND_KALI_ATAQUE_1, -8.8 if fuerza < 17.0 else -6.8, randf_range(0.90, 0.98))
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
		"Dax": return SND_FANG_FUEGO
		_: return SND_ESPECIAL

func _crear_onda_impacto_premium(tipo: String, bloqueado: bool, intensidad: float) -> void:
	if modo_bajo_visual:
		return
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
	# FASE 90.10.19: el fondo base tiene 18 % de overscan (escala 1.18).
	# Aprovechamos una parte de ese margen para que la cámara pueda acompañar
	# una pelea cerca de los extremos sin mostrar vacío fuera de la ilustración.
	camara.limit_left = -110
	camara.limit_right = int(ANCHO_ARENA + 110.0)
	camara.limit_top = -12
	camara.limit_bottom = 836
	add_child(camara)

# FASE 98 — Glow/Bloom. Godot aplica esto sobre TODO lo que se vea más
# brillante que glow_hdr_threshold, así que se deja el umbral relativamente
# alto (0.90) para que agarre solo los picos de brillo reales -- el blanco
# pintado a mano en el centro del fuego/energía, los destellos de impacto --
# y no toda la escena. background_mode = BG_CANVAS es crítico: sin eso el
# Environment reemplaza el fondo ya dibujado por un color plano/cielo 3D en
# vez de solo aplicar el post-proceso encima.
func _crear_ambiente_glow() -> void:
	if modo_bajo_visual:
		return
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
	if not modo_bajo_visual:
		fondo_material = ShaderMaterial.new()
		fondo_material.shader = load("res://shaders/escenario_ambiental.gdshader")
		fondo_sprite.material = fondo_material
	else:
		fondo_material = null
		fondo_sprite.material = null
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

	if not modo_bajo_visual:
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
	if not modo_bajo_visual:
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
	if modo_bajo_visual:
		return

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

func _obtener_brillo_base_escenario(nombre_luchador: String) -> float:
	match nombre_luchador:
		# 90.11.24 — Helena y Aethel ya usan PNGs oscurecidos de origen;
		# Kali y Cibor-X conservan la atenuación suave por código.
		"Helena":
			# 90.11.24 — nuevo PNG ya viene oscurecido; se usa sin atenuación extra.
			return 1.0
		"Kali":
			return 0.76
		"Aethel":
			# 90.11.24 — nuevo PNG ya viene oscurecido; se usa sin atenuación extra.
			return 1.0
		"Cibor-X":
			return 0.80
		"Xenoid":
			# 90.11.25 — leve rebaja para que el escenario no compita con el luchador.
			return 0.84
		"Krovan":
			# Campo nocturno cálido: conservar la luna/linternas sin apagar al luchador.
			return 0.92
		"Nekhar":
			# Sepulcro oscuro con fuego ámbar: ligero refuerzo sin lavar los negros.
			return 0.94
		_:
			return 1.0

func _obtener_tono_base_escenario(nombre_luchador: String) -> Color:
	var b: float = _obtener_brillo_base_escenario(nombre_luchador)
	return Color(b, b, b, 1.0)

func _obtener_tono_base_suelo(nombre_luchador: String) -> Color:
	var b: float = _obtener_brillo_base_escenario(nombre_luchador)
	# El suelo queda apenas más claro que el fondo para que la línea de apoyo
	# siga leyendo bien y no se apaguen demasiado las plataformas.
	var bs: float = minf(b + 0.08, 1.0)
	return Color(bs, bs, bs, 1.0)

func _escenario_redisenado(nombre_luchador: String) -> bool:
	return nombre_luchador in ["Varkhos", "Aethel", "Cibor-X", "Helena", "Kali", "Krovan", "Nekhar"]

func _zoom_base_escenario(nombre_luchador: String) -> float:
	return 1.08 if _escenario_redisenado(nombre_luchador) else 1.18

func _transform_fondo(nombre_luchador: String, zoom_fondo_actual: float) -> Dictionary:
	var sobrante_x_actual: float = ANCHO_ARENA * (zoom_fondo_actual - 1.0)
	var sobrante_y_actual: float = 720.0 * (zoom_fondo_actual - 1.0)
	var fondo_y_base: float = -sobrante_y_actual * 0.1
	if nombre_luchador == "Dax":
		# Coliseo Rojo aprobado: conserva su calibración específica.
		fondo_y_base = 14.0
	elif _escenario_redisenado(nombre_luchador):
		# El piso diseñado de los rediseños está compuesto para quedar sobre la
		# línea física Y=560. Recalculamos el offset según el zoom actual.
		fondo_y_base = 560.0 - (560.0 * zoom_fondo_actual)
	return {
		"scale": Vector2(zoom_fondo_actual, zoom_fondo_actual),
		"position": Vector2(-sobrante_x_actual / 2.0, fondo_y_base)
	}

func _aplicar_transform_fondo(nombre_luchador: String, zoom_fondo_actual: float, duracion: float = 0.0) -> void:
	if not fondo_sprite:
		return
	var datos := _transform_fondo(nombre_luchador, zoom_fondo_actual)
	var escala: Vector2 = datos.get("scale", Vector2.ONE)
	var posicion: Vector2 = datos.get("position", Vector2.ZERO)
	if duracion <= 0.0:
		fondo_sprite.scale = escala
		fondo_sprite.position = posicion
	else:
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(fondo_sprite, "scale", escala, duracion).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(fondo_sprite, "position", posicion, duracion).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _ajustar_overscan_cinematico(activo: bool, duracion: float) -> void:
	if not fondo_sprite:
		return
	if not _escenario_redisenado(escenario_nombre_actual):
		return
	var zoom_objetivo: float = _zoom_base_escenario(escenario_nombre_actual)
	if activo:
		# 90.11.23 — en las cinemáticas de poder la cámara panea fuerte.
		# Aumentamos cobertura temporal del fondo para que no entren bordes negros.
		zoom_objetivo = maxf(zoom_objetivo, 1.18)
	_aplicar_transform_fondo(escenario_nombre_actual, zoom_objetivo, duracion)

func _actualizar_fondo(nombre_luchador: String) -> void:
	escenario_nombre_actual = nombre_luchador
	var ruta: String = FONDOS.get(nombre_luchador, "")
	if ruta == "":
		return
	fondo_sprite.texture = load(ruta)
	# 90.11.23 — base por escenario: los rediseños usan 1.08 en juego normal
	# y suben temporalmente a 1.18 durante cinemáticas de poder para que la
	# cámara no muestre bordes negros al panear.
	var zoom_fondo_actual: float = _zoom_base_escenario(nombre_luchador)
	_aplicar_transform_fondo(nombre_luchador, zoom_fondo_actual)
	var c: Color = AMBIENTE_COLORES.get(nombre_luchador, Color(0.8, 0.8, 0.9))
	_aplicar_color_ambiente(c)
	_configurar_escenario_vivo(nombre_luchador, c)
	# Brillo base del escenario ya estructurado. Se aplica al fondo y a sus
	# capas vivas para que los luchadores resalten más.
	var tono_base := _obtener_tono_base_escenario(nombre_luchador)
	var tono_suelo_base := _obtener_tono_base_suelo(nombre_luchador)
	fondo_sprite.modulate = tono_base
	if escenario_vivo:
		escenario_vivo.modulate = tono_base
	if ambiente_particulas:
		ambiente_particulas.modulate = tono_base
	if ambiente_particulas_delante:
		ambiente_particulas_delante.modulate = tono_base
	if piso_overlay:
		piso_overlay.modulate = tono_suelo_base
	_actualizar_audio_escenario(nombre_luchador)

func _crear_ambiente() -> void:
	ambiente_particulas = Node2D.new()
	ambiente_particulas.name = "AmbienteVivo"
	ambiente_particulas.z_index = -2
	add_child(ambiente_particulas)

	ambiente_particulas_delante = Node2D.new()
	ambiente_particulas_delante.name = "AtmosferaCercana"
	ambiente_particulas_delante.z_index = -1
	add_child(ambiente_particulas_delante)
	if modo_bajo_visual:
		return

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
	if modo_bajo_visual:
		return

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
	if modo_bajo_visual:
		escenario_ambiente_reloj = 0.0
		escenario_energia_reactiva = 0.0
		helena_ojos.clear()
		helena_aura_cabeza = null
		cibor_reactor_halo = null
		return
		
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
		"Xenoid": return "electrico"
		"Krovan": return "tierra"
		"Nekhar": return "oscuro"
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
	helena_aura_cabeza.position = Vector2(680.0, 158.0)
	helena_aura_cabeza.color = Color(1.0, 0.20, 0.72, 0.035)
	helena_aura_cabeza.z_index = -2
	escenario_mid.add_child(helena_aura_cabeza)
	var ta := create_tween()
	ta.set_loops()
	ta.set_parallel(true)
	ta.tween_property(helena_aura_cabeza, "scale", Vector2(1.16, 1.10), 1.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ta.tween_property(helena_aura_cabeza, "position", Vector2(683.0, 155.5), 1.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ta.chain().tween_property(helena_aura_cabeza, "scale", Vector2(0.96, 0.98), 1.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	ta.parallel().tween_property(helena_aura_cabeza, "position", Vector2(677.5, 161.0), 1.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	for pos in [Vector2(674.0, 149.0), Vector2(687.0, 151.0)]:
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
		vapor.position = Vector2(754.0, 205.0) + Vector2(randf_range(-4.0, 4.0), randf_range(-4.0, 5.0))
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
		"Xenoid": return Xenoid.new()
		"Dax": return Dax.new()
		"Krovan": return Krovan.new()
		"Nekhar": return Nekhar.new()
		"Varkhos": return Varkhos.new()
		_: return Kai.new()

func _detectar_modo_versus_local() -> bool:
	var estado = get_node_or_null("/root/GameState")
	if not estado:
		return false
	var modo_actual: String = str(estado.get("modo")).to_lower()
	return modo_actual in ["versus", "versus_local", "pvp_local", "local_vs"]


func _detectar_modo_online() -> bool:
	var estado = get_node_or_null("/root/GameState")
	if not estado:
		return false
	return str(estado.get("modo")).to_lower() == "online"

func _gamepad_para_jugador_local(indice_jugador: int) -> int:
	# Se conserva para compatibilidad fuera del router. En Versus Local 90.10.93
	# la asignación real ocurre exclusivamente en _inyectar_inputs_versus_local().
	var pads := Input.get_connected_joypads()
	if pads.size() >= 2:
		return int(pads[indice_jugador])
	if pads.size() == 1:
		return -2 if indice_jugador == 0 else int(pads[0])
	return -2

func _teclado_habilitado_para_jugador_local(indice_jugador: int) -> bool:
	var cantidad_pads: int = Input.get_connected_joypads().size()
	if cantidad_pads >= 2:
		return false
	if cantidad_pads == 1:
		return indice_jugador == 0
	return true


func _router_frame_neutro() -> Dictionary:
	return {
		"izquierda": false,
		"derecha": false,
		"salto": false,
		"bloqueo": false,
		"puno": false,
		"patada": false,
		"especial": false,
	}

func _router_frame_teclado_j1() -> Dictionary:
	return {
		"izquierda": Input.is_physical_key_pressed(KEY_LEFT),
		"derecha": Input.is_physical_key_pressed(KEY_RIGHT),
		"salto": Input.is_physical_key_pressed(KEY_UP),
		"bloqueo": Input.is_physical_key_pressed(KEY_DOWN),
		"puno": Input.is_physical_key_pressed(KEY_X),
		"patada": Input.is_physical_key_pressed(KEY_C),
		"especial": Input.is_physical_key_pressed(KEY_Z),
	}

func _router_frame_teclado_j2() -> Dictionary:
	return {
		"izquierda": Input.is_physical_key_pressed(KEY_A),
		"derecha": Input.is_physical_key_pressed(KEY_D),
		"salto": Input.is_physical_key_pressed(KEY_W),
		"bloqueo": Input.is_physical_key_pressed(KEY_S),
		"puno": Input.is_physical_key_pressed(KEY_F),
		"patada": Input.is_physical_key_pressed(KEY_G),
		"especial": Input.is_physical_key_pressed(KEY_H),
	}

func _router_pad_boton(id: int, boton: int) -> bool:
	return id >= 0 and Input.is_joy_button_pressed(id, boton)

func _router_pad_eje(id: int, eje: int) -> float:
	if id < 0:
		return 0.0
	return Input.get_joy_axis(id, eje)

func _router_frame_mando(id: int) -> Dictionary:
	if id < 0:
		return _router_frame_neutro()
	var lx := _router_pad_eje(id, ROUTER_AXIS_LX)
	var ly := _router_pad_eje(id, ROUTER_AXIS_LY)
	return {
		"izquierda": _router_pad_boton(id, ROUTER_DPAD_LEFT) or lx < -ROUTER_DEADZONE_X,
		"derecha": _router_pad_boton(id, ROUTER_DPAD_RIGHT) or lx > ROUTER_DEADZONE_X,
		"salto": _router_pad_boton(id, ROUTER_PAD_A) or _router_pad_boton(id, ROUTER_DPAD_UP) or ly < -ROUTER_DEADZONE_Y,
		"bloqueo": _router_pad_boton(id, ROUTER_PAD_B) or _router_pad_boton(id, ROUTER_DPAD_DOWN) or ly > ROUTER_DEADZONE_Y or _router_pad_eje(id, ROUTER_AXIS_LT) > 0.55,
		"puno": _router_pad_boton(id, ROUTER_PAD_X),
		"patada": _router_pad_boton(id, ROUTER_PAD_Y),
		"especial": _router_pad_boton(id, ROUTER_PAD_RB) or _router_pad_eje(id, ROUTER_AXIS_RT) > 0.55,
	}

func _h1_probe_pretick(indice: int, entrada: Dictionary, frame_j1: Dictionary, frame_j2: Dictionary) -> void:
	if indice < 0 or indice >= rollback_catchup_ventana.size():
		return
	var snap: Dictionary = entrada.get("snapshot", {})
	var e1: Dictionary = snap.get("j1", {})
	var e2: Dictionary = snap.get("j2", {})

	var relevante_j1: bool = bool(frame_j1.get("puno", false)) or bool(frame_j1.get("patada", false)) \
		or float(e1.get("hitstop_timer", 0.0)) > 0.0 or int(e1.get("fase_ataque", 0)) != 0 \
		or float(e1.get("hitstun_timer", 0.0)) > 0.0
	var relevante_j2: bool = bool(frame_j2.get("puno", false)) or bool(frame_j2.get("patada", false)) \
		or float(e2.get("hitstop_timer", 0.0)) > 0.0 or int(e2.get("fase_ataque", 0)) != 0 \
		or float(e2.get("hitstun_timer", 0.0)) > 0.0
	if not relevante_j1 and not relevante_j2:
		return

	# H6.1 — Launcher/Air Hit generaban ~15 líneas por subtick y Godot
	# terminaba con "output overflow". Seguimos COMPARANDO todos los subticks,
	# pero imprimimos detalle sólo en 1, 2 y 8 salvo que el validador causal
	# detecte una divergencia (esa traza se imprime por otra ruta).
	if rollback_h_clasificacion in ["NORMAL IMPACT", "NORMAL ATTACK RECOVERY", "FORWARD DASH", "LAUNCHER", "AIR HIT", "PROYECTIL STARTUP", "PROYECTIL VUELO", "PROYECTIL IMPACTO CORE", "PROYECTIL BLOQUEO", "CORE I ENTRY", "CORE I TARGET END", "CORE I POSTER END", "CORE II ENTRY", "CORE II RECARGA END", "CORE II COMBO ENTRY", "CORE II FIRST BEAT END", "CORE II REMATADOR ENTRY", "CORE II REMATADOR POSTER END", "CORE II SEQUENCE END", "CORE III ENTRY", "CORE III RECARGA END", "CORE III APPROACH END", "CORE III FIRST BEAT END", "CORE III SECOND BEAT END", "CORE III THIRD BEAT END", "CORE III FOURTH BEAT END", "CORE III FIFTH BEAT END", "CORE III SIXTH BEAT END", "CORE III SEVENTH BEAT END", "CORE III EIGHTH BEAT END", "CORE III EIGHTEENTH BEAT END", "CORE III NINETEENTH BEAT ATTACK START", "CORE III ABSOLUTE FINISHER ENTRY", "CORE III ABSOLUTE REVEAL END", "CORE III ABSOLUTE KO ENTRY", "CORE III ABSOLUTE VICTORY ENTRY", "CORE III ABSOLUTE VICTORY HOLD", "CORE III ABSOLUTE MATCH RESET ENTRY"]:
		var ultimo_probe := rollback_catchup_ventana.size() - 1
		if indice != 0 and indice != 1 and indice != ultimo_probe:
			return

	print("[91.00.00-H10.88] PRETICK %d/%d — tick histórico %d" % [
		indice + 1, rollback_catchup_ventana.size(), int(entrada.get("tick", -1))
	])
	print("  • J1 INPUT=%s" % str(frame_j1))
	print("  • J1 esperado hitstop=%.6f fase=%s timer=%.6f idxP=%s idxK=%s prevP=%s prevK=%s buffer=%s/%.6f extDisp=%s" % [
		float(e1.get("hitstop_timer", 0.0)), str(e1.get("fase_ataque", 0)),
		float(e1.get("timer_fase_ataque", 0.0)), str(e1.get("indice_punetazo", -1)),
		str(e1.get("indice_patada", -1)), str(e1.get("puno_estaba_presionado", false)),
		str(e1.get("patada_estaba_presionada", false)), str(e1.get("ataque_buffer_tipo", "")),
		float(e1.get("ataque_buffer_timer", 0.0)), str(e1.get("input_externo_disponible", false))
	])
	print("  • J1 actual   hitstop=%.6f fase=%s timer=%.6f idxP=%s idxK=%s prevP=%s prevK=%s buffer=%s/%.6f extDisp=%s" % [
		float(kai.hitstop_timer), str(kai.fase_ataque), float(kai.timer_fase_ataque),
		str(kai.indice_punetazo), str(kai.indice_patada),
		str(kai.puno_estaba_presionado), str(kai.patada_estaba_presionada),
		str(kai.ataque_buffer_tipo), float(kai.ataque_buffer_timer),
		str(kai.input_externo_disponible)
	])

	print("  • J2 INPUT=%s" % str(frame_j2))
	print("  • J2 esperado hitstop=%.6f hitstun=%.6f fase=%s timer=%.6f idxP=%s idxK=%s prevP=%s prevK=%s buffer=%s/%.6f extDisp=%s" % [
		float(e2.get("hitstop_timer", 0.0)), float(e2.get("hitstun_timer", 0.0)),
		str(e2.get("fase_ataque", 0)), float(e2.get("timer_fase_ataque", 0.0)),
		str(e2.get("indice_punetazo", -1)), str(e2.get("indice_patada", -1)),
		str(e2.get("puno_estaba_presionado", false)), str(e2.get("patada_estaba_presionada", false)),
		str(e2.get("ataque_buffer_tipo", "")), float(e2.get("ataque_buffer_timer", 0.0)),
		str(e2.get("input_externo_disponible", false))
	])
	print("  • J2 actual   hitstop=%.6f hitstun=%.6f fase=%s timer=%.6f idxP=%s idxK=%s prevP=%s prevK=%s buffer=%s/%.6f extDisp=%s" % [
		float(rival.hitstop_timer), float(rival.hitstun_timer), str(rival.fase_ataque),
		float(rival.timer_fase_ataque), str(rival.indice_punetazo), str(rival.indice_patada),
		str(rival.puno_estaba_presionado), str(rival.patada_estaba_presionada),
		str(rival.ataque_buffer_tipo), float(rival.ataque_buffer_timer),
		str(rival.input_externo_disponible)
	])

	var tactico := get_node_or_null("/root/PerfectBlock90_1")
	if tactico != null:
		var tid1 := kai.get_instance_id()
		var tid2 := rival.get_instance_id()
		var prevs: Dictionary = tactico.get("_input_previo_por_id")
		var disp: Dictionary = tactico.get("_combo_cancel_disponible")
		var cadena: Dictionary = tactico.get("_combo_cancel_cadena")
		var snap_t: Dictionary = snap.get("tactico", {})
		var prevs_e: Dictionary = snap_t.get("_input_previo_por_id", {})
		var disp_e: Dictionary = snap_t.get("_combo_cancel_disponible", {})
		var cadena_e: Dictionary = snap_t.get("_combo_cancel_cadena", {})
		var counters: Dictionary = tactico.get("_counter_disponible")
		var counters_e: Dictionary = snap_t.get("_counter_disponible", {})
		var ventanas: Dictionary = tactico.get("_ventana_hasta")
		var ventanas_e: Dictionary = snap_t.get("_ventana_hasta", {})

		print("  • TACTICO J1 esperado prev=%s perfectWin=%s counter=%s cancel=%s cadena=%s | actual prev=%s perfectWin=%s counter=%s cancel=%s cadena=%s" % [
			str(prevs_e.get(tid1, {})), str(float(ventanas_e.get(tid1, 0.0)) > 0.0),
			str(counters_e.get(tid1, false)), str(disp_e.get(tid1, false)), str(cadena_e.get(tid1, 0)),
			str(prevs.get(tid1, {})), str(float(ventanas.get(tid1, 0.0)) > 0.0),
			str(counters.get(tid1, false)), str(disp.get(tid1, false)), str(cadena.get(tid1, 0))
		])
		print("  • TACTICO J2 esperado prev=%s perfectWin=%s counter=%s cancel=%s cadena=%s | actual prev=%s perfectWin=%s counter=%s cancel=%s cadena=%s" % [
			str(prevs_e.get(tid2, {})), str(float(ventanas_e.get(tid2, 0.0)) > 0.0),
			str(counters_e.get(tid2, false)), str(disp_e.get(tid2, false)), str(cadena_e.get(tid2, 0)),
			str(prevs.get(tid2, {})), str(float(ventanas.get(tid2, 0.0)) > 0.0),
			str(counters.get(tid2, false)), str(disp.get(tid2, false)), str(cadena.get(tid2, 0))
		])

		print("  • COUNTER MARK esperado serial=%s id=%s tipo=%s | actual serial=%s id=%s tipo=%s" % [
			str(snap_t.get("_rollback_counter_event_serial", 0)),
			str(snap_t.get("_rollback_counter_event_fighter_id", -1)),
			str(snap_t.get("_rollback_counter_event_tipo", "")),
			str(tactico.get("_rollback_counter_event_serial")),
			str(tactico.get("_rollback_counter_event_fighter_id")),
			str(tactico.get("_rollback_counter_event_tipo"))
		])
		print("  • TACTICAL CLOCK esperado tick=%s t=%.6f | actual tick=%s t=%.6f" % [
			str(snap_t.get("_rollback_tactical_clock_ticks", -1)),
			float(snap_t.get("_rollback_tactical_clock_seconds", -1.0)),
			str(tactico.get("_rollback_tactical_clock_ticks")),
			float(tactico.get("_rollback_tactical_clock_seconds"))
		])
		var la_e: Dictionary = snap_t.get("_launcher_armado_hasta", {})
		var la_a: Dictionary = tactico.get("_launcher_armado_hasta")
		var ac_e: Dictionary = snap_t.get("_air_combo_activo", {})
		var ac_a: Dictionary = tactico.get("_air_combo_activo")
		var ah_e: Dictionary = snap_t.get("_air_combo_hasta", {})
		var ah_a: Dictionary = tactico.get("_air_combo_hasta")
		var ag_e: Dictionary = snap_t.get("_air_combo_golpes", {})
		var ag_a: Dictionary = tactico.get("_air_combo_golpes")
		print("  • LAUNCH/AIR J1 esperado launcher=%.6f activo=%s hasta=%.6f golpes=%s | actual launcher=%.6f activo=%s hasta=%.6f golpes=%s" % [
			float(la_e.get(tid1, 0.0)), str(ac_e.get(tid1, false)), float(ah_e.get(tid1, 0.0)), str(ag_e.get(tid1, 0)),
			float(la_a.get(tid1, 0.0)), str(ac_a.get(tid1, false)), float(ah_a.get(tid1, 0.0)), str(ag_a.get(tid1, 0))
		])
		print("  • LAUNCH/AIR J2 esperado launcher=%.6f activo=%s hasta=%.6f golpes=%s | actual launcher=%.6f activo=%s hasta=%.6f golpes=%s" % [
			float(la_e.get(tid2, 0.0)), str(ac_e.get(tid2, false)), float(ah_e.get(tid2, 0.0)), str(ag_e.get(tid2, 0)),
			float(la_a.get(tid2, 0.0)), str(ac_a.get(tid2, false)), float(ah_a.get(tid2, 0.0)), str(ag_a.get(tid2, 0))
		])
		print("  • EVENT MARKS esperado launcher=%s airhit=%s air_x=%s | actual launcher=%s airhit=%s air_x=%s" % [
			str(snap_t.get("_rollback_launcher_event_serial", 0)), str(snap_t.get("_rollback_airhit_event_serial", 0)), str(snap_t.get("_rollback_airhit_event_count", 0)),
			str(tactico.get("_rollback_launcher_event_serial")), str(tactico.get("_rollback_airhit_event_serial")), str(tactico.get("_rollback_airhit_event_count"))
		])
		if rollback_h_clasificacion in ["CORE I ENTRY", "CORE I TARGET END", "CORE I POSTER END", "CORE II ENTRY", "CORE II RECARGA END", "CORE II COMBO ENTRY", "CORE II FIRST BEAT END", "CORE II REMATADOR ENTRY", "CORE II REMATADOR POSTER END", "CORE II SEQUENCE END", "CORE III ENTRY", "CORE III RECARGA END", "CORE III APPROACH END", "CORE III FIRST BEAT END", "CORE III SECOND BEAT END", "CORE III THIRD BEAT END", "CORE III FOURTH BEAT END", "CORE III FIFTH BEAT END", "CORE III SIXTH BEAT END", "CORE III SEVENTH BEAT END", "CORE III EIGHTH BEAT END", "CORE III EIGHTEENTH BEAT END", "CORE III NINETEENTH BEAT ATTACK START", "CORE III ABSOLUTE FINISHER ENTRY", "CORE III ABSOLUTE REVEAL END", "CORE III ABSOLUTE KO ENTRY", "CORE III ABSOLUTE VICTORY ENTRY", "CORE III ABSOLUTE VICTORY HOLD", "CORE III ABSOLUTE MATCH RESET ENTRY"]:
			var cj1: Dictionary = snap.get("j1", {})
			var cj2: Dictionary = snap.get("j2", {})
			print("  • CORE J1 esp nivel=%s poder=%.3f sec=%s lock=%s t=%.6f/%.6f dest=%s | act nivel=%s poder=%.3f sec=%s lock=%s t=%.6f/%.6f dest=%s" % [
				str(cj1.get("veces_fase_absoluta", 0)), float(cj1.get("poder", 0.0)),
				str(cj1.get("en_secuencia_especial", false)), str(cj1.get("core1_target_lock_activo", false)),
				float(cj1.get("core1_target_lock_tiempo", 0.0)), float(cj1.get("core1_target_lock_duracion", 0.0)),
				str(cj1.get("core1_target_lock_destino", Vector2.ZERO)),
				str(kai.get("veces_fase_absoluta")), float(kai.get("poder")),
				str(kai.get("en_secuencia_especial")), str(kai.get("core1_target_lock_activo")),
				float(kai.get("core1_target_lock_tiempo")), float(kai.get("core1_target_lock_duracion")),
				str(kai.get("core1_target_lock_destino"))
			])
			print("  • CORE J2 esp nivel=%s poder=%.3f sec=%s lock=%s t=%.6f/%.6f dest=%s | act nivel=%s poder=%.3f sec=%s lock=%s t=%.6f/%.6f dest=%s" % [
				str(cj2.get("veces_fase_absoluta", 0)), float(cj2.get("poder", 0.0)),
				str(cj2.get("en_secuencia_especial", false)), str(cj2.get("core1_target_lock_activo", false)),
				float(cj2.get("core1_target_lock_tiempo", 0.0)), float(cj2.get("core1_target_lock_duracion", 0.0)),
				str(cj2.get("core1_target_lock_destino", Vector2.ZERO)),
				str(rival.get("veces_fase_absoluta")), float(rival.get("poder")),
				str(rival.get("en_secuencia_especial")), str(rival.get("core1_target_lock_activo")),
				float(rival.get("core1_target_lock_tiempo")), float(rival.get("core1_target_lock_duracion")),
				str(rival.get("core1_target_lock_destino"))
			])
			print("  • CORE1 FSM J1 esp etapa=%s poster=%.6f/%.6f | act etapa=%s poster=%.6f/%.6f" % [
				str(cj1.get("core1_secuencia_etapa", 0)),
				float(cj1.get("core1_poster_timer", 0.0)),
				float(cj1.get("core1_poster_duracion", 0.0)),
				str(kai.get("core1_secuencia_etapa")),
				float(kai.get("core1_poster_timer")),
				float(kai.get("core1_poster_duracion"))
			])
			print("  • CORE1 FSM J2 esp etapa=%s poster=%.6f/%.6f | act etapa=%s poster=%.6f/%.6f" % [
				str(cj2.get("core1_secuencia_etapa", 0)),
				float(cj2.get("core1_poster_timer", 0.0)),
				float(cj2.get("core1_poster_duracion", 0.0)),
				str(rival.get("core1_secuencia_etapa")),
				float(rival.get("core1_poster_timer")),
				float(rival.get("core1_poster_duracion"))
			])
			if rollback_h_clasificacion in ["CORE II ENTRY", "CORE II RECARGA END", "CORE II COMBO ENTRY", "CORE II FIRST BEAT END", "CORE II REMATADOR ENTRY", "CORE II REMATADOR POSTER END", "CORE II SEQUENCE END", "CORE III ENTRY", "CORE III RECARGA END", "CORE III APPROACH END", "CORE III FIRST BEAT END", "CORE III SECOND BEAT END", "CORE III THIRD BEAT END", "CORE III FOURTH BEAT END", "CORE III FIFTH BEAT END", "CORE III SIXTH BEAT END", "CORE III SEVENTH BEAT END", "CORE III EIGHTH BEAT END", "CORE III EIGHTEENTH BEAT END", "CORE III NINETEENTH BEAT ATTACK START", "CORE III ABSOLUTE FINISHER ENTRY", "CORE III ABSOLUTE REVEAL END", "CORE III ABSOLUTE KO ENTRY", "CORE III ABSOLUTE VICTORY ENTRY", "CORE III ABSOLUTE VICTORY HOLD", "CORE III ABSOLUTE MATCH RESET ENTRY"]:
				print("  • CORE2 J1 esp nivel=%s sec=%s recarga=%s pose=%.6f cine=%s frozen=%s | act nivel=%s sec=%s recarga=%s pose=%.6f cine=%s frozen=%s" % [
					str(cj1.get("veces_fase_absoluta", 0)),
					str(cj1.get("en_secuencia_especial", false)),
					str(cj1.get("en_pose_recarga", false)),
					float(cj1.get("pose_timer", 0.0)),
					str(cj1.get("bloqueo_cinematico", false)),
					str(cj1.get("congelado_por_rival", false)),
					str(kai.get("veces_fase_absoluta")),
					str(kai.get("en_secuencia_especial")),
					str(kai.get("en_pose_recarga")),
					float(kai.get("pose_timer")),
					str(kai.get("bloqueo_cinematico")),
					str(kai.get("congelado_por_rival"))
				])
				print("  • CORE2 J2 esp nivel=%s sec=%s recarga=%s pose=%.6f cine=%s frozen=%s | act nivel=%s sec=%s recarga=%s pose=%.6f cine=%s frozen=%s" % [
					str(cj2.get("veces_fase_absoluta", 0)),
					str(cj2.get("en_secuencia_especial", false)),
					str(cj2.get("en_pose_recarga", false)),
					float(cj2.get("pose_timer", 0.0)),
					str(cj2.get("bloqueo_cinematico", false)),
					str(cj2.get("congelado_por_rival", false)),
					str(rival.get("veces_fase_absoluta")),
					str(rival.get("en_secuencia_especial")),
					str(rival.get("en_pose_recarga")),
					float(rival.get("pose_timer")),
					str(rival.get("bloqueo_cinematico")),
					str(rival.get("congelado_por_rival"))
				])
				print("  • CORE2 FSM J1 etapa=%s rec=%.6f/%.6f app=%.6f/%.6f dest=%s | act etapa=%s rec=%.6f/%.6f app=%.6f/%.6f dest=%s" % [
					str(cj1.get("core2_secuencia_etapa", 0)),
					float(cj1.get("core2_recarga_timer", 0.0)),
					float(cj1.get("core2_recarga_duracion", 0.0)),
					float(cj1.get("core2_acercamiento_tiempo", 0.0)),
					float(cj1.get("core2_acercamiento_duracion", 0.0)),
					str(cj1.get("core2_acercamiento_destino", Vector2.ZERO)),
					str(kai.get("core2_secuencia_etapa")),
					float(kai.get("core2_recarga_timer")),
					float(kai.get("core2_recarga_duracion")),
					float(kai.get("core2_acercamiento_tiempo")),
					float(kai.get("core2_acercamiento_duracion")),
					str(kai.get("core2_acercamiento_destino"))
				])
				print("  • CORE2 FSM J2 etapa=%s rec=%.6f/%.6f app=%.6f/%.6f dest=%s | act etapa=%s rec=%.6f/%.6f app=%.6f/%.6f dest=%s" % [
					str(cj2.get("core2_secuencia_etapa", 0)),
					float(cj2.get("core2_recarga_timer", 0.0)),
					float(cj2.get("core2_recarga_duracion", 0.0)),
					float(cj2.get("core2_acercamiento_tiempo", 0.0)),
					float(cj2.get("core2_acercamiento_duracion", 0.0)),
					str(cj2.get("core2_acercamiento_destino", Vector2.ZERO)),
					str(rival.get("core2_secuencia_etapa")),
					float(rival.get("core2_recarga_timer")),
					float(rival.get("core2_recarga_duracion")),
					float(rival.get("core2_acercamiento_tiempo")),
					float(rival.get("core2_acercamiento_duracion")),
					str(rival.get("core2_acercamiento_destino"))
				])
				print("  • CORE2 COMBO J1 paso=%s/%s sub=%s app=%.6f/%.6f dest=%s | act paso=%s/%s sub=%s app=%.6f/%.6f dest=%s" % [
					str(cj1.get("core2_combo_paso_idx", 0)),
					str(cj1.get("core2_combo_total_pasos", 0)),
					str(cj1.get("core2_combo_subfase", 0)),
					float(cj1.get("core2_combo_acercamiento_tiempo", 0.0)),
					float(cj1.get("core2_combo_acercamiento_duracion", 0.0)),
					str(cj1.get("core2_combo_acercamiento_destino", Vector2.ZERO)),
					str(kai.get("core2_combo_paso_idx")),
					str(kai.get("core2_combo_total_pasos")),
					str(kai.get("core2_combo_subfase")),
					float(kai.get("core2_combo_acercamiento_tiempo")),
					float(kai.get("core2_combo_acercamiento_duracion")),
					str(kai.get("core2_combo_acercamiento_destino"))
				])
				print("  • CORE2 COMBO J2 paso=%s/%s sub=%s app=%.6f/%.6f dest=%s | act paso=%s/%s sub=%s app=%.6f/%.6f dest=%s" % [
					str(cj2.get("core2_combo_paso_idx", 0)),
					str(cj2.get("core2_combo_total_pasos", 0)),
					str(cj2.get("core2_combo_subfase", 0)),
					float(cj2.get("core2_combo_acercamiento_tiempo", 0.0)),
					float(cj2.get("core2_combo_acercamiento_duracion", 0.0)),
					str(cj2.get("core2_combo_acercamiento_destino", Vector2.ZERO)),
					str(rival.get("core2_combo_paso_idx")),
					str(rival.get("core2_combo_total_pasos")),
					str(rival.get("core2_combo_subfase")),
					float(rival.get("core2_combo_acercamiento_tiempo")),
					float(rival.get("core2_combo_acercamiento_duracion")),
					str(rival.get("core2_combo_acercamiento_destino"))
				])
				print("  • CORE2 REM J1 sub=%s timer=%.6f/%.6f conecta=%s block=%s dir=%.1f | act sub=%s timer=%.6f/%.6f conecta=%s block=%s dir=%.1f" % [
					str(cj1.get("core2_rematador_subfase", 0)),
					float(cj1.get("core2_rematador_timer", 0.0)),
					float(cj1.get("core2_rematador_duracion", 0.0)),
					str(cj1.get("core2_rematador_puede_conectar", false)),
					str(cj1.get("core2_rematador_bloqueado", false)),
					float(cj1.get("core2_rematador_direccion", 1.0)),
					str(kai.get("core2_rematador_subfase")),
					float(kai.get("core2_rematador_timer")),
					float(kai.get("core2_rematador_duracion")),
					str(kai.get("core2_rematador_puede_conectar")),
					str(kai.get("core2_rematador_bloqueado")),
					float(kai.get("core2_rematador_direccion"))
				])
				print("  • CORE2 REM J2 sub=%s timer=%.6f/%.6f conecta=%s block=%s dir=%.1f | act sub=%s timer=%.6f/%.6f conecta=%s block=%s dir=%.1f" % [
					str(cj2.get("core2_rematador_subfase", 0)),
					float(cj2.get("core2_rematador_timer", 0.0)),
					float(cj2.get("core2_rematador_duracion", 0.0)),
					str(cj2.get("core2_rematador_puede_conectar", false)),
					str(cj2.get("core2_rematador_bloqueado", false)),
					float(cj2.get("core2_rematador_direccion", 1.0)),
					str(rival.get("core2_rematador_subfase")),
					float(rival.get("core2_rematador_timer")),
					float(rival.get("core2_rematador_duracion")),
					str(rival.get("core2_rematador_puede_conectar")),
					str(rival.get("core2_rematador_bloqueado")),
					float(rival.get("core2_rematador_direccion"))
				])
				if rollback_h_clasificacion in ["CORE III ENTRY", "CORE III RECARGA END", "CORE III APPROACH END", "CORE III FIRST BEAT END", "CORE III SECOND BEAT END", "CORE III THIRD BEAT END", "CORE III FOURTH BEAT END", "CORE III FIFTH BEAT END", "CORE III SIXTH BEAT END", "CORE III SEVENTH BEAT END", "CORE III EIGHTH BEAT END", "CORE III EIGHTEENTH BEAT END", "CORE III NINETEENTH BEAT ATTACK START", "CORE III ABSOLUTE FINISHER ENTRY", "CORE III ABSOLUTE REVEAL END", "CORE III ABSOLUTE KO ENTRY", "CORE III ABSOLUTE VICTORY ENTRY", "CORE III ABSOLUTE VICTORY HOLD", "CORE III ABSOLUTE MATCH RESET ENTRY"]:
					print("  • CORE3 J1 esp nivel=%s sec=%s recarga=%s furia=%s pose=%.6f cine=%s frozen=%s | act nivel=%s sec=%s recarga=%s furia=%s pose=%.6f cine=%s frozen=%s" % [
						str(cj1.get("veces_fase_absoluta", 0)),
						str(cj1.get("en_secuencia_especial", false)),
						str(cj1.get("en_pose_recarga", false)),
						str(cj1.get("en_fase_absoluta", false)),
						float(cj1.get("pose_timer", 0.0)),
						str(cj1.get("bloqueo_cinematico", false)),
						str(cj1.get("congelado_por_rival", false)),
						str(kai.get("veces_fase_absoluta")),
						str(kai.get("en_secuencia_especial")),
						str(kai.get("en_pose_recarga")),
						str(kai.get("en_fase_absoluta")),
						float(kai.get("pose_timer")),
						str(kai.get("bloqueo_cinematico")),
						str(kai.get("congelado_por_rival"))
					])
					print("  • CORE3 J2 esp nivel=%s sec=%s recarga=%s furia=%s pose=%.6f cine=%s frozen=%s | act nivel=%s sec=%s recarga=%s furia=%s pose=%.6f cine=%s frozen=%s" % [
						str(cj2.get("veces_fase_absoluta", 0)),
						str(cj2.get("en_secuencia_especial", false)),
						str(cj2.get("en_pose_recarga", false)),
						str(cj2.get("en_fase_absoluta", false)),
						float(cj2.get("pose_timer", 0.0)),
						str(cj2.get("bloqueo_cinematico", false)),
						str(cj2.get("congelado_por_rival", false)),
						str(rival.get("veces_fase_absoluta")),
						str(rival.get("en_secuencia_especial")),
						str(rival.get("en_pose_recarga")),
						str(rival.get("en_fase_absoluta")),
						float(rival.get("pose_timer")),
						str(rival.get("bloqueo_cinematico")),
						str(rival.get("congelado_por_rival"))
					])
					print("  • CORE3 FSM J1 etapa=%s beatSub=%s beatApp=%.6f/%.6f dest=%s | act etapa=%s beatSub=%s beatApp=%.6f/%.6f dest=%s" % [
						str(cj1.get("core3_secuencia_etapa", 0)),
						str(cj1.get("core3_primer_beat_subfase", 0)),
						float(cj1.get("core3_primer_beat_acercamiento_tiempo", 0.0)),
						float(cj1.get("core3_primer_beat_acercamiento_duracion", 0.0)),
						str(cj1.get("core3_primer_beat_acercamiento_destino", Vector2.ZERO)),
						str(kai.get("core3_secuencia_etapa")),
						str(kai.get("core3_primer_beat_subfase")),
						float(kai.get("core3_primer_beat_acercamiento_tiempo")),
						float(kai.get("core3_primer_beat_acercamiento_duracion")),
						str(kai.get("core3_primer_beat_acercamiento_destino"))
					])
					print("  • CORE3 FSM J2 etapa=%s beatSub=%s beatApp=%.6f/%.6f dest=%s | act etapa=%s beatSub=%s beatApp=%.6f/%.6f dest=%s" % [
						str(cj2.get("core3_secuencia_etapa", 0)),
						str(cj2.get("core3_primer_beat_subfase", 0)),
						float(cj2.get("core3_primer_beat_acercamiento_tiempo", 0.0)),
						float(cj2.get("core3_primer_beat_acercamiento_duracion", 0.0)),
						str(cj2.get("core3_primer_beat_acercamiento_destino", Vector2.ZERO)),
						str(rival.get("core3_secuencia_etapa")),
						str(rival.get("core3_primer_beat_subfase")),
						float(rival.get("core3_primer_beat_acercamiento_tiempo")),
						float(rival.get("core3_primer_beat_acercamiento_duracion")),
						str(rival.get("core3_primer_beat_acercamiento_destino"))
					])
		var bd_timer_e: Dictionary = snap_t.get("_backdash_timer", {})
		var bd_dir_e: Dictionary = snap_t.get("_backdash_direccion", {})
		var bd_timer_a: Dictionary = tactico.get("_backdash_timer")
		var bd_dir_a: Dictionary = tactico.get("_backdash_direccion")
		print("  • BACKDASH MARK esperado serial=%s id=%s dir=%s | actual serial=%s id=%s dir=%s" % [
			str(snap_t.get("_rollback_backdash_event_serial", 0)),
			str(snap_t.get("_rollback_backdash_event_fighter_id", -1)),
			str(snap_t.get("_rollback_backdash_event_direccion", 0.0)),
			str(tactico.get("_rollback_backdash_event_serial")),
			str(tactico.get("_rollback_backdash_event_fighter_id")),
			str(tactico.get("_rollback_backdash_event_direccion"))
		])
		print("  • BACKDASH STATE J1 esperado timer=%.6f dir=%.1f | actual timer=%.6f dir=%.1f" % [
			float(bd_timer_e.get(tid1, 0.0)), float(bd_dir_e.get(tid1, 0.0)),
			float(bd_timer_a.get(tid1, 0.0)), float(bd_dir_a.get(tid1, 0.0))
		])
		print("  • BACKDASH STATE J2 esperado timer=%.6f dir=%.1f | actual timer=%.6f dir=%.1f" % [
			float(bd_timer_e.get(tid2, 0.0)), float(bd_dir_e.get(tid2, 0.0)),
			float(bd_timer_a.get(tid2, 0.0)), float(bd_dir_a.get(tid2, 0.0))
		])

# H10.51 — DELTA HISTÓRICO EXPLÍCITO CORE III. ENTRY hasta EIGHTEENTH BEAT END
# reproducen el delta de cada snapshot sin depender del frame LIVE que inició rollback.
# El cambio 1.0 -> 0.32 ocurre dentro del callback del Fighter que activa CORE III.
# En LIVE eso implica:
#   - J1 siempre recibe la escala al inicio del tick.
#   - J2 recibe la escala posterior sólo si J1 fue quien cambió time_scale antes.
#   - PerfectBlock, que corre después de los Fighters, recibe la escala posterior.
# Reproducimos exactamente esa semántica sin depender del delta que Godot entregue
# al reactivar nodos durante una prueba de rollback.
func _h108_aplicar_delta_historico_core3(indice: int) -> void:
	if rollback_h_clasificacion not in ["CORE III ENTRY", "CORE III RECARGA END", "CORE III APPROACH END", "CORE III FIRST BEAT END", "CORE III SECOND BEAT END", "CORE III THIRD BEAT END", "CORE III FOURTH BEAT END", "CORE III FIFTH BEAT END", "CORE III SIXTH BEAT END", "CORE III SEVENTH BEAT END", "CORE III EIGHTH BEAT END", "CORE III EIGHTEENTH BEAT END", "CORE III NINETEENTH BEAT ATTACK START", "CORE III ABSOLUTE FINISHER ENTRY", "CORE III ABSOLUTE REVEAL END", "CORE III ABSOLUTE KO ENTRY", "CORE III ABSOLUTE VICTORY ENTRY", "CORE III ABSOLUTE VICTORY HOLD", "CORE III ABSOLUTE MATCH RESET ENTRY"]:
		return
	if indice < 0 or indice >= rollback_catchup_ventana.size():
		return
	var actual_entry: Dictionary = rollback_catchup_ventana[indice]
	var actual_snap: Dictionary = actual_entry.get("snapshot", {})
	var siguiente_snap: Dictionary = {}
	if indice + 1 < rollback_catchup_ventana.size():
		siguiente_snap = rollback_catchup_ventana[indice + 1].get("snapshot", {})
	else:
		siguiente_snap = rollback_estado_presente_esperado
	if actual_snap.is_empty():
		return
	if siguiente_snap.is_empty():
		siguiente_snap = actual_snap

	var hz := maxi(1, Engine.physics_ticks_per_second)
	var base_delta := 1.0 / float(hz)
	var escala_inicio := float(actual_snap.get("time_scale", 1.0))
	var escala_post := float(siguiente_snap.get("time_scale", escala_inicio))
	var delta_j1 := base_delta * escala_inicio
	var delta_j2 := base_delta * escala_inicio
	var delta_pb := base_delta * escala_post
	var cambio_escala := absf(escala_post - escala_inicio) > 0.000001
	var activador_j1 := rollback_h_atacante.begins_with("J1")
	var h1052_stage20_a21_j1 := false
	var h1060_absolute_reveal_end_j1 := false
	var h1066_absolute_victory_entry_j1 := false
	if cambio_escala and activador_j1:
		var j1_trans_actual: Dictionary = actual_snap.get("j1", {})
		var j1_trans_siguiente: Dictionary = siguiente_snap.get("j1", {})
		h1052_stage20_a21_j1 = int(j1_trans_actual.get("core3_secuencia_etapa", 0)) == 20 \
			and int(j1_trans_siguiente.get("core3_secuencia_etapa", 0)) == 21
		h1060_absolute_reveal_end_j1 = rollback_h_clasificacion == "CORE III ABSOLUTE REVEAL END" \
			and absf(escala_inicio - 0.18) <= 0.001 and absf(escala_post - 0.42) <= 0.001
		h1066_absolute_victory_entry_j1 = rollback_h_clasificacion == "CORE III ABSOLUTE VICTORY ENTRY" \
			and absf(escala_inicio - 0.42) <= 0.001 and absf(escala_post - 1.0) <= 0.001

	# Orden histórico de Fighters en Versus Local: J1 antes de J2. Si J1 activa
	# CORE III, J2 ya entra al callback con la nueva escala. Si activa J2, ambos
	# Fighters comenzaron su callback con la escala anterior y sólo PB ve la nueva.
	var delta_seguridad_rival := -1.0
	if cambio_escala and activador_j1:
		delta_j2 = base_delta * escala_post
		# H10.52: excepción PROBADA sólo para EIGHTEENTH BEAT END stage 20->21.
		# H10.51 (Kai/J1) mostró que la transición 1.0->0.18 ocurre después de
		# que J2 ya consumió su callback histórico de ese tick: sus timers LIVE
		# bajan 0.016667, no 0.003. No alterar ENTRY/RECARGA, ya certificados.
		if h1052_stage20_a21_j1 or h1060_absolute_reveal_end_j1 or h1066_absolute_victory_entry_j1:
			delta_j2 = base_delta * escala_inicio
		# H10.11: los logs LIVE de ENTRY y RECARGA END muestran la misma
		# semántica asimétrica cuando J1 cambia time_scale antes del callback de J2:
		# el callback general de J2 ve la escala posterior, pero su reloj auxiliar
		# de seguridad conserva durante ese único tick el delta pre-transición.
		# ENTRY: 1.0 -> 0.32 => J2 general 0.005333, safety 0.016667.
		# RECARGA END: 0.32 -> 1.0 => J2 general 0.016667, safety 0.005333.
		delta_seguridad_rival = base_delta * escala_inicio

	# H10.18: H10.16 reveló una latencia real de un physics tick después de
	# 0.32 -> 1.0 cuando APPROACH END queda muy cerca de RECARGA END. Para
	# Fighters, reloj_seguridad_secuencia avanza DIRECTAMENTE con el delta que
	# recibió el Fighter, por lo que su diferencia entre snapshots es una fuente
	# válida para capturar ese tick residual. PerfectBlock es distinto: su reloj
	# táctico convierte internamente delta a tiempo no escalado (delta/time_scale),
	# así que NUNCA debemos realimentar la diferencia de ese reloj como delta.
	# PB conserva la fórmula certificada H10.11: base_delta * escala_post.
	var clock_override_j1 := false
	var clock_override_j2 := false
	if not cambio_escala:
		var j1_actual: Dictionary = actual_snap.get("j1", {})
		var j1_siguiente: Dictionary = siguiente_snap.get("j1", {})
		var j2_actual: Dictionary = actual_snap.get("j2", {})
		var j2_siguiente: Dictionary = siguiente_snap.get("j2", {})

		var j1_reloj_activo := bool(j1_actual.get("en_secuencia_especial", false)) or bool(j1_actual.get("congelado_por_rival", false))
		var j2_reloj_activo := bool(j2_actual.get("en_secuencia_especial", false)) or bool(j2_actual.get("congelado_por_rival", false))
		if j1_reloj_activo and not j1_actual.is_empty() and not j1_siguiente.is_empty():
			var delta_reloj_j1 := float(j1_siguiente.get("reloj_seguridad_secuencia", 0.0)) - float(j1_actual.get("reloj_seguridad_secuencia", 0.0))
			if delta_reloj_j1 > 0.000001 and delta_reloj_j1 <= 0.05:
				delta_j1 = delta_reloj_j1
				clock_override_j1 = true
		if j2_reloj_activo and not j2_actual.is_empty() and not j2_siguiente.is_empty():
			var delta_reloj_j2 := float(j2_siguiente.get("reloj_seguridad_secuencia", 0.0)) - float(j2_actual.get("reloj_seguridad_secuencia", 0.0))
			if delta_reloj_j2 > 0.000001 and delta_reloj_j2 <= 0.05:
				delta_j2 = delta_reloj_j2
				clock_override_j2 = true

		if clock_override_j1 or clock_override_j2:
			var delta_formula_fighter := base_delta * escala_inicio
			if absf(delta_j1 - delta_formula_fighter) > 0.000001 or absf(delta_j2 - delta_formula_fighter) > 0.000001:
				print("[91.00.00-H10.88] CORE III HISTORICAL FIGHTER CLOCK DELTA — subtick=%d escala=%.4f J1=%.6f J2=%.6f PB_formula=%.6f" % [
					indice, escala_inicio, delta_j1, delta_j2, delta_pb
				])

	# Reimponer la escala al inicio del subtick evita arrastrar el estado global
	# del frame administrativo que disparó el rollback.
	Engine.time_scale = escala_inicio
	if is_instance_valid(kai):
		kai.set("rollback_delta_override", delta_j1)
	if is_instance_valid(rival):
		rival.set("rollback_delta_override", delta_j2)
		if delta_seguridad_rival >= 0.0:
			rival.set("rollback_reloj_seguridad_delta_override", delta_seguridad_rival)
	if is_instance_valid(PerfectBlock90_1):
		PerfectBlock90_1.set("rollback_delta_override", delta_pb)

	if cambio_escala:
		if h1052_stage20_a21_j1:
			print("[91.00.00-H10.88] CORE III EIGHTEENTH J1 DELTA FIX — stage 20->21; J2 conserva delta pre-transicion %.6f" % delta_j2)
		if h1060_absolute_reveal_end_j1:
			print("[91.00.00-H10.88] CORE III ABS REVEAL J1 DELTA FIX — 0.18->0.42 ocurre en Main; J2 conserva delta pre-transicion %.6f" % delta_j2)
		if h1066_absolute_victory_entry_j1:
			print("[91.00.00-H10.88] CORE III ABS VICTORY J1 DELTA FIX — 0.42->1.0 ocurre en Main despues del callback historico de J2; J2 conserva delta pre-transicion %.6f" % delta_j2)
		print("[91.00.00-H10.88] CORE III HISTORICAL DELTA TRANSITION — subtick=%d activador=%s escala %.4f->%.4f J1=%.6f J2=%.6f PB=%.6f J2Safety=%s" % [
			indice, "J1" if activador_j1 else "J2", escala_inicio, escala_post,
			delta_j1, delta_j2, delta_pb,
			"%.6f" % delta_seguridad_rival if delta_seguridad_rival >= 0.0 else "normal"
		])

func _inyectar_inputs_versus_local() -> void:
	if not versus_local_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	# 91.00.00-H: catch-up de rollback local. Se alimentan únicamente los inputs
	# históricos de la ventana rebobinada; teclado/mando quedan ignorados.
	if rollback_catchup_activo:
		if rollback_catchup_indice < rollback_catchup_ventana.size():
			_h108_aplicar_delta_historico_core3(rollback_catchup_indice)
			var entrada_rb: Dictionary = rollback_catchup_ventana[rollback_catchup_indice]
			var rb_j1: Dictionary = entrada_rb.get("j1", _router_frame_neutro())
			var rb_j2: Dictionary = entrada_rb.get("j2", _router_frame_neutro())
			if not online_rollback_catchup_modo:
				_h1_probe_pretick(rollback_catchup_indice, entrada_rb, rb_j1, rb_j2)
			kai.inyectar_input_frame(rb_j1)
			rival.inyectar_input_frame(rb_j2)
			rollback_catchup_indice += 1
			if rollback_catchup_indice >= rollback_catchup_ventana.size():
				rollback_catchup_activo = false
				if online_rollback_catchup_modo:
					online_rollback_finalizar_pendiente = true
				else:
					rollback_comparacion_pendiente = true
			return
		rollback_catchup_activo = false
		if online_rollback_catchup_modo:
			online_rollback_finalizar_pendiente = true
		else:
			rollback_comparacion_pendiente = true
		kai.inyectar_input_frame(_router_frame_neutro())
		rival.inyectar_input_frame(_router_frame_neutro())
		return

	# 91.00.00-H: durante replay NO se consulta teclado ni mando. Cada tick sale
	# exclusivamente del archivo grabado y entra por la misma API de Fighter.
	if replay_modo_activo and input_replay != null:
		var paquete: Dictionary = input_replay.siguiente_tick()
		var valido: bool = bool(paquete.get("valido", false))
		var frame_replay_j1: Dictionary = paquete.get("j1", _router_frame_neutro())
		var frame_replay_j2: Dictionary = paquete.get("j2", _router_frame_neutro())
		kai.inyectar_input_frame(frame_replay_j1)
		rival.inyectar_input_frame(frame_replay_j2)

		if valido:
			replay_ticks_neutros_post_buffer = 0
			_validar_traza_replay(input_replay.tick_actual)
			_validar_checkpoint_replay(input_replay.tick_actual)
		else:
			# El último input puede disparar una animación/await cuyo evento terminal
			# ocurre unos physics ticks después. B lo marcaba como DESYNC demasiado
			# pronto. C mantiene inputs neutros brevemente y espera el evento real.
			replay_ticks_neutros_post_buffer += 1
			if not replay_agotado_reportado:
				replay_agotado_reportado = true
				print("[91.00.00-H10.88] Buffer de inputs completo — tick %d; esperando evento terminal" % input_replay.tick_actual)
			if replay_ticks_neutros_post_buffer > REPLAY_GRACIA_POST_BUFFER_TICKS and not replay_final_evaluado:
				if replay_tick_primer_desync < 0:
					replay_tick_primer_desync = input_replay.tick_actual
				print("[91.00.00-H10.88] REPLAY DESYNC — no llegó el evento terminal tras %d ticks neutros" % REPLAY_GRACIA_POST_BUFFER_TICKS)
				replay_final_evaluado = true
		return

	# 91.02.64 — Online: cada máquina lee sólo su dispositivo local y recibe
	# el rival por ENet. No se consulta el layout J2 local.
	if online_activo:
		_inyectar_inputs_online()
		return

	var pads := Input.get_connected_joypads()
	var frame_j1 := _router_frame_neutro()
	var frame_j2 := _router_frame_neutro()

	if pads.size() >= 2:
		# Dos mandos: J1 = mando 1, J2 = mando 2. Teclado queda fuera del combate.
		frame_j1 = _router_frame_mando(int(pads[0]))
		frame_j2 = _router_frame_mando(int(pads[1]))
	elif pads.size() == 1:
		# Configuración objetivo del usuario: J1 teclado, J2 mando.
		frame_j1 = _router_frame_teclado_j1()
		frame_j2 = _router_frame_mando(int(pads[0]))
	else:
		# Sin mando: dos jugadores en un teclado, layouts totalmente separados.
		frame_j1 = _router_frame_teclado_j1()
		frame_j2 = _router_frame_teclado_j2()

	# El ring buffer asocia estos inputs con el snapshot capturado al inicio
	# de este mismo physics tick.
	if rollback_ring != null and not rollback_catchup_activo:
		rollback_ring.asignar_inputs_ultimo(frame_j1, frame_j2)

	# 91.00.00-H: copiamos exactamente los frames que YA iban a recibir los
	# Fighter. Cada 60 ticks guardamos además un checkpoint lógico de diagnóstico.
	if input_recorder != null:
		input_recorder.grabar_tick(frame_j1, frame_j2)
		var tick_grabado: int = input_recorder.total_ticks()
		# Diagnóstico D: una traza lógica por tick para localizar el PRIMER frame
		# divergente, no sólo el bloque de 60 en el que ya se hizo visible.
		input_recorder.grabar_traza_tick(_capturar_estado_traza_replay())
		if tick_grabado % REPLAY_CHECKPOINT_INTERVALO == 0:
			input_recorder.grabar_checkpoint(tick_grabado, _capturar_estado_checkpoint_replay())

	kai.inyectar_input_frame(frame_j1)
	rival.inyectar_input_frame(frame_j2)

# -------------------- PASS 14D1 / INPUT ONLINE REAL --------------------
func _network_online() -> Node:
	return get_node_or_null("/root/NetworkManager")


func _preparar_online_combate() -> void:
	var red := _network_online()
	if red == null or not red.hay_rival_conectado():
		push_warning("91.02.64-P14D1: Main online sin rival conectado")
		return
	if not red.combate_go.is_connected(_al_online_combate_go):
		red.combate_go.connect(_al_online_combate_go)
	if not red.input_remoto_recibido.is_connected(_al_online_input_remoto_recibido):
		red.input_remoto_recibido.connect(_al_online_input_remoto_recibido)

	online_combate_habilitado = false
	online_tick_simulacion = 0
	rollback_tick_logico = 0
	if rollback_ring != null:
		rollback_ring.limpiar()
	online_inputs_locales.clear()
	online_inputs_loopback_j2.clear()
	online_ultimo_frame_remoto = _router_frame_neutro()
	online_loopback_ultimo_j1 = _router_frame_neutro()
	online_loopback_ultimo_j2 = _router_frame_neutro()
	online_remote_misses = 0
	online_remote_hits = 0
	online_prediccion_remota_por_tick.clear()
	online_late_evaluados = 0
	online_late_iguales = 0
	online_rollback_necesarios = 0
	online_rollback_max_edad = 0
	online_rollback_tick_mas_antiguo = -1
	online_rollback_tick_pendiente = -1
	online_rollback_catchup_modo = false
	online_rollback_finalizar_pendiente = false
	online_rollbacks_ejecutados = 0
	online_rollback_ticks_reprocesados = 0
	online_rollback_fuera_ventana = 0
	online_rollback_ultimo_inicio = -1
	online_rollback_ultima_cantidad = 0
	rollback_catchup_activo = false
	rollback_comparacion_pendiente = false
	rollback_catchup_ventana.clear()
	rollback_catchup_indice = 0
	online_loopback_hits = 0
	online_loopback_misses = 0

	print("[91.02.64-P14D1] MAIN LISTO peer=%d rol=%s — esperando barrera" % [red.mi_peer_id(), red.rol])
	red.marcar_main_lista()


func _al_online_combate_go(seed_recibida: int) -> void:
	# Reiniciar RNG JUSTO en la barrera elimina cualquier consumo visual ocurrido
	# mientras un peer cargaba antes que el otro.
	replay_rng_seed_actual = seed_recibida if seed_recibida != 0 else 9100004
	seed(replay_rng_seed_actual)

	online_tick_simulacion = 0
	rollback_tick_logico = 0
	if rollback_ring != null:
		rollback_ring.limpiar()
	online_inputs_locales.clear()
	online_inputs_loopback_j2.clear()
	online_ultimo_frame_remoto = _router_frame_neutro()
	online_loopback_ultimo_j1 = _router_frame_neutro()
	online_loopback_ultimo_j2 = _router_frame_neutro()
	online_remote_misses = 0
	online_remote_hits = 0
	online_prediccion_remota_por_tick.clear()
	online_late_evaluados = 0
	online_late_iguales = 0
	online_rollback_necesarios = 0
	online_rollback_max_edad = 0
	online_rollback_tick_mas_antiguo = -1
	online_rollback_tick_pendiente = -1
	online_rollback_catchup_modo = false
	online_rollback_finalizar_pendiente = false
	online_rollbacks_ejecutados = 0
	online_rollback_ticks_reprocesados = 0
	online_rollback_fuera_ventana = 0
	online_rollback_ultimo_inicio = -1
	online_rollback_ultima_cantidad = 0
	rollback_catchup_activo = false
	rollback_comparacion_pendiente = false
	rollback_catchup_ventana.clear()
	rollback_catchup_indice = 0
	online_loopback_hits = 0
	online_loopback_misses = 0

	# Los primeros N ticks son neutrales en ambos peers; mientras tanto los
	# inputs reales etiquetados N ticks hacia adelante viajan por ENet.
	for t in range(ONLINE_INPUT_DELAY_TICKS):
		online_inputs_locales[str(t)] = _router_frame_neutro()
		online_inputs_loopback_j2[str(t)] = _router_frame_neutro()

	online_combate_habilitado = true
	var red_control := _network_online()
	var control_legible := str(red_control.obtener_control_local()).to_upper() if red_control != null and red_control.has_method("obtener_control_local") else "TECLADO"
	print("[91.02.65-P14D1B] INPUT ONLINE ACTIVO — control=%s delay=%d ticks (~%d ms) seed=%d" % [
		control_legible,
		ONLINE_INPUT_DELAY_TICKS,
		int(round(1000.0 * float(ONLINE_INPUT_DELAY_TICKS) / float(Engine.physics_ticks_per_second))),
		replay_rng_seed_actual
	])
	if red_control != null and red_control.has_method("es_loopback_misma_pc") and bool(red_control.es_loopback_misma_pc()):
		if red_control.es_host():
			print("[91.02.66-P14D1C] QA MISMA PC — HOST captura J1=TECLADO + J2=PRIMER MANDO — pads=%s" % str(Input.get_connected_joypads()))
		else:
			print("[91.02.66-P14D1C] QA MISMA PC — CLIENTE replica los 2 frames del HOST; no lee hardware")
	call_deferred("_presentar_ready_fight")


func _online_ring_indice_por_tick(tick: int) -> int:
	if rollback_ring == null:
		return -1
	for i in range(rollback_ring.entradas.size()):
		var entrada: Dictionary = rollback_ring.entradas[i]
		if int(entrada.get("tick", -1)) == tick:
			return i
	return -1


func _online_parchear_input_recorder_tick(tick: int, j1: Dictionary, j2: Dictionary) -> void:
	if input_recorder == null:
		return
	var frames_var = input_recorder.get("frames")
	if not (frames_var is Array):
		return
	var frames_arr: Array = frames_var
	if tick < 0 or tick >= frames_arr.size():
		return
	frames_arr[tick] = [
		InputRecorderScript.codificar_frame(j1),
		InputRecorderScript.codificar_frame(j2),
	]


func _online_ventana_corregida(desde_tick: int, hasta_exclusivo: int) -> Array[Dictionary]:
	var salida: Array[Dictionary] = []
	if rollback_ring == null:
		return salida
	var red := _network_online()
	if red == null:
		return salida

	var ultimo_remoto_corregido: Dictionary = {}
	for tick in range(desde_tick, hasta_exclusivo):
		var idx: int = _online_ring_indice_por_tick(tick)
		if idx < 0:
			salida.clear()
			return salida

		var entrada: Dictionary = (rollback_ring.entradas[idx] as Dictionary).duplicate(true)
		var j1: Dictionary = (entrada.get("j1", _router_frame_neutro()) as Dictionary).duplicate(true)
		var j2: Dictionary = (entrada.get("j2", _router_frame_neutro()) as Dictionary).duplicate(true)
		var paquete: Dictionary = red.obtener_input_remoto(tick)
		if bool(paquete.get("disponible", false)):
			var remoto_real: Dictionary = InputRecorderScript.decodificar_frame(int(paquete.get("mascara", 0)))
			if red.es_host():
				j2 = remoto_real.duplicate(true)
			else:
				j1 = remoto_real.duplicate(true)
			ultimo_remoto_corregido = remoto_real.duplicate(true)

		entrada["j1"] = j1.duplicate(true)
		entrada["j2"] = j2.duplicate(true)
		rollback_ring.entradas[idx]["j1"] = j1.duplicate(true)
		rollback_ring.entradas[idx]["j2"] = j2.duplicate(true)
		_online_parchear_input_recorder_tick(tick, j1, j2)
		salida.append(entrada)

	if not ultimo_remoto_corregido.is_empty():
		online_ultimo_frame_remoto = ultimo_remoto_corregido.duplicate(true)
	return salida


func _online_reescribir_snapshot_catchup_actual() -> void:
	if not online_rollback_catchup_modo:
		return
	if rollback_catchup_indice <= 0 or rollback_catchup_indice >= rollback_catchup_ventana.size():
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var tick_actual: int = int(rollback_catchup_ventana[rollback_catchup_indice].get("tick", -1))
	var idx_ring: int = _online_ring_indice_por_tick(tick_actual)
	if idx_ring < 0:
		return
	var snap: Dictionary = RollbackSnapshotScript.capturar_partida(self, kai, rival)
	rollback_catchup_ventana[rollback_catchup_indice]["snapshot"] = snap.duplicate(true)
	rollback_ring.entradas[idx_ring]["snapshot"] = snap.duplicate(true)
	rollback_ring.entradas[idx_ring]["seguro"] = _snapshot_estado_rollback_h_seguro()


func _online_iniciar_rollback_pendiente() -> bool:
	if not online_activo or not online_combate_habilitado:
		return false
	if online_rollback_tick_pendiente < 0:
		return false
	if rollback_catchup_activo or online_rollback_finalizar_pendiente:
		return false
	if rollback_ring == null or not is_instance_valid(kai) or not is_instance_valid(rival):
		return false

	var desde_tick: int = online_rollback_tick_pendiente
	online_rollback_tick_pendiente = -1
	var hasta_exclusivo: int = online_tick_simulacion
	var cantidad: int = hasta_exclusivo - desde_tick
	if cantidad <= 0:
		return false
	if cantidad > ONLINE_ROLLBACK_MAX_TICKS:
		online_rollback_fuera_ventana += 1
		print("[91.02.70-P14D2C] ROLLBACK FUERA DE VENTANA — desde=%d presente=%d edad=%d max=%d" % [
			desde_tick, hasta_exclusivo, cantidad, ONLINE_ROLLBACK_MAX_TICKS
		])
		return false

	var ventana: Array[Dictionary] = _online_ventana_corregida(desde_tick, hasta_exclusivo)
	if ventana.size() != cantidad:
		online_rollback_fuera_ventana += 1
		print("[91.02.70-P14D2C] ROLLBACK SIN HISTORIA — desde=%d presente=%d pedidos=%d disponibles=%d ring=%d..%d" % [
			desde_tick, hasta_exclusivo, cantidad, ventana.size(),
			rollback_ring.tick_mas_antiguo(), rollback_ring.tick_mas_nuevo()
		])
		return false

	# 14D2C limita el primer rollback real al reloj normal. CORE III usa cambios
	# de time_scale certificados por otro arnés; no mezclamos esa frontera en el
	# primer pase online. En combate normal/CORE I/CORE II el scale es 1.0.
	for entrada in ventana:
		var snap_check: Dictionary = entrada.get("snapshot", {})
		if absf(float(snap_check.get("time_scale", 1.0)) - 1.0) > 0.001:
			online_rollback_fuera_ventana += 1
			print("[91.02.70-P14D2C] ROLLBACK OMITIDO TIMESCALE — tick=%d scale=%.4f" % [
				int(entrada.get("tick", -1)), float(snap_check.get("time_scale", 1.0))
			])
			return false

	var inicio: Dictionary = ventana[0].get("snapshot", {})
	if inicio.is_empty():
		return false

	rollback_catchup_ventana = ventana
	rollback_catchup_indice = 0
	rollback_tick_origen = desde_tick
	rollback_comparacion_pendiente = false
	rollback_catchup_preparando_timescale = false
	rollback_catchup_inicio_timescale = {}
	rollback_catchup_reactivar_tactico_next_tick = false
	rollback_catchup_reactivacion_deferred_pendiente = false
	rollback_catchup_barrier_frames_restantes = 0
	rollback_catchup_commit_restore_pendiente = false
	online_rollback_catchup_modo = true
	online_rollback_finalizar_pendiente = false
	online_rollbacks_ejecutados += 1
	online_rollback_ticks_reprocesados += cantidad
	online_rollback_ultimo_inicio = desde_tick
	online_rollback_ultima_cantidad = cantidad

	# Evita repetir pósters/sonidos de CORE I/II al recorrer historia.
	if is_instance_valid(kai):
		kai.set("rollback_suprimir_presentacion_core1", true)
		kai.set("rollback_suprimir_presentacion_core2", true)
	if is_instance_valid(rival):
		rival.set("rollback_suprimir_presentacion_core1", true)
		rival.set("rollback_suprimir_presentacion_core2", true)
		rival.set("rollback_reloj_seguridad_delta_override", -1.0)

	# Si el snapshot contiene un proyectil vivo, activamos la compensación ya
	# certificada en 91.02.60 para el primer tick del nodo reconstruido.
	var proy_j1: Dictionary = inicio.get("proyectil_j1", {})
	var proy_j2: Dictionary = inicio.get("proyectil_j2", {})
	if bool(proy_j1.get("activo", false)) or bool(proy_j2.get("activo", false)):
		rollback_h_clasificacion = "PROYECTIL ONLINE"
	else:
		rollback_h_clasificacion = "ONLINE ROLLBACK"
	rollback_h_atacante = "NET"

	RollbackSnapshotScript.restaurar_partida(self, kai, rival, inicio)
	rollback_catchup_activo = true
	print("[91.02.70-P14D2C] ROLLBACK START — desde=%d presente=%d ticks=%d ejecutados=%d" % [
		desde_tick, hasta_exclusivo, cantidad, online_rollbacks_ejecutados
	])
	return true


func _online_finalizar_rollback() -> void:
	if not online_rollback_finalizar_pendiente:
		return
	online_rollback_finalizar_pendiente = false
	online_rollback_catchup_modo = false
	rollback_catchup_activo = false
	rollback_comparacion_pendiente = false
	rollback_catchup_ventana.clear()
	rollback_catchup_indice = 0
	rollback_tick_origen = -1
	rollback_catchup_preparando_timescale = false
	rollback_catchup_inicio_timescale = {}
	rollback_catchup_reactivar_tactico_next_tick = false
	rollback_catchup_reactivacion_deferred_pendiente = false
	rollback_catchup_barrier_frames_restantes = 0
	rollback_catchup_commit_restore_pendiente = false

	if is_instance_valid(kai):
		kai.set("rollback_delta_override", -1.0)
		kai.set("rollback_suprimir_presentacion_core1", false)
		kai.set("rollback_suprimir_presentacion_core2", false)
	if is_instance_valid(rival):
		rival.set("rollback_delta_override", -1.0)
		rival.set("rollback_reloj_seguridad_delta_override", -1.0)
		rival.set("rollback_suprimir_presentacion_core1", false)
		rival.set("rollback_suprimir_presentacion_core2", false)
	if is_instance_valid(PerfectBlock90_1):
		PerfectBlock90_1.set("rollback_delta_override", -1.0)

	rollback_h_clasificacion = ""
	rollback_h_atacante = ""
	print("[91.02.70-P14D2C] ROLLBACK END — presente=%d ultimo_desde=%d ticks=%d total_rb=%d total_reprocesados=%d" % [
		online_tick_simulacion, online_rollback_ultimo_inicio, online_rollback_ultima_cantidad,
		online_rollbacks_ejecutados, online_rollback_ticks_reprocesados
	])


func _al_online_input_remoto_recibido(tick: int) -> void:
	# Sólo interesa un frame que llegó DESPUÉS de que ese tick ya fue simulado.
	# Los frames futuros o recibidos a tiempo no necesitan reconciliación.
	if not online_activo or not online_combate_habilitado:
		return
	if tick >= online_tick_simulacion:
		return

	var clave: String = str(tick)
	if not online_prediccion_remota_por_tick.has(clave):
		return
	var registro: Dictionary = online_prediccion_remota_por_tick[clave]
	if not bool(registro.get("predicho", false)):
		return
	if bool(registro.get("evaluado", false)):
		return

	var red := _network_online()
	if red == null:
		return
	var paquete: Dictionary = red.obtener_input_remoto(tick)
	if not bool(paquete.get("disponible", false)):
		return

	var mascara_real: int = int(paquete.get("mascara", 0))
	var mascara_predicha: int = int(registro.get("mascara", 0))
	var edad: int = maxi(0, online_tick_simulacion - tick)
	registro["evaluado"] = true
	registro["real"] = mascara_real
	registro["edad"] = edad
	online_prediccion_remota_por_tick[clave] = registro

	online_late_evaluados += 1
	online_rollback_max_edad = maxi(online_rollback_max_edad, edad)
	if mascara_real == mascara_predicha:
		online_late_iguales += 1
		if online_late_iguales <= 6:
			print("[91.02.68-P14D2A] LATE SIN ROLLBACK — tick=%d edad=%d pred=%d real=%d" % [
				tick, edad, mascara_predicha, mascara_real
			])
		return

	online_rollback_necesarios += 1
	if online_rollback_tick_mas_antiguo < 0 or tick < online_rollback_tick_mas_antiguo:
		online_rollback_tick_mas_antiguo = tick
	print("[91.02.68-P14D2A] ROLLBACK NECESARIO — tick=%d edad=%d pred=%d real=%d total=%d" % [
		tick, edad, mascara_predicha, mascara_real, online_rollback_necesarios
	])

	if edad <= ONLINE_ROLLBACK_MAX_TICKS:
		if online_rollback_tick_pendiente < 0 or tick < online_rollback_tick_pendiente:
			online_rollback_tick_pendiente = tick
	else:
		online_rollback_fuera_ventana += 1
		print("[91.02.70-P14D2C] LATE NO CORREGIBLE — tick=%d edad=%d max=%d" % [
			tick, edad, ONLINE_ROLLBACK_MAX_TICKS
		])


func _router_frame_online_local() -> Dictionary:
	# 91.02.65 — El origen de input es EXPLÍCITO por instancia.
	# Antes, la mera presencia de un Xbox hacía que ambas instancias ignorasen
	# teclado y leyesen el mismo mando físico, duplicando el movimiento.
	var red := _network_online()
	var origen := "teclado"
	if red != null and red.has_method("obtener_control_local"):
		origen = str(red.obtener_control_local()).to_lower()

	if origen == "mando":
		var pads := Input.get_connected_joypads()
		if pads.is_empty():
			return _router_frame_neutro()
		return _router_frame_mando(int(pads[0]))

	# TECLADO siempre significa exclusivamente el layout principal; un gamepad
	# conectado ya no puede secuestrar esta instancia.
	return _router_frame_teclado_j1()


func _inyectar_inputs_online_loopback(red: Node) -> void:
	var tick_sim: int = online_tick_simulacion
	var tick_captura: int = tick_sim + ONLINE_INPUT_DELAY_TICKS
	var frame_j1: Dictionary = _router_frame_neutro()
	var frame_j2: Dictionary = _router_frame_neutro()

	if red.es_host():
		# Una sola ventana enfocada posee los dispositivos físicos durante QA.
		# J1 siempre es teclado principal; J2 siempre el primer Xbox/gamepad.
		var frame_j1_capturado: Dictionary = _router_frame_teclado_j1()
		var frame_j2_capturado: Dictionary = _router_frame_neutro()
		var pads := Input.get_connected_joypads()
		if not pads.is_empty():
			frame_j2_capturado = _router_frame_mando(int(pads[0]))

		online_inputs_locales[str(tick_captura)] = frame_j1_capturado.duplicate(true)
		online_inputs_loopback_j2[str(tick_captura)] = frame_j2_capturado.duplicate(true)
		red.enviar_input_frames_loopback(
			tick_captura,
			InputRecorderScript.codificar_frame(frame_j1_capturado),
			InputRecorderScript.codificar_frame(frame_j2_capturado)
		)

		frame_j1 = online_inputs_locales.get(str(tick_sim), _router_frame_neutro())
		frame_j2 = online_inputs_loopback_j2.get(str(tick_sim), _router_frame_neutro())
	else:
		if tick_sim >= ONLINE_INPUT_DELAY_TICKS:
			var paquete: Dictionary = red.obtener_input_frames_loopback(tick_sim)
			if bool(paquete.get("disponible", false)):
				frame_j1 = InputRecorderScript.decodificar_frame(int(paquete.get("j1", 0)))
				frame_j2 = InputRecorderScript.decodificar_frame(int(paquete.get("j2", 0)))
				online_loopback_ultimo_j1 = frame_j1.duplicate(true)
				online_loopback_ultimo_j2 = frame_j2.duplicate(true)
				online_loopback_hits += 1
			else:
				frame_j1 = online_loopback_ultimo_j1.duplicate(true)
				frame_j2 = online_loopback_ultimo_j2.duplicate(true)
				online_loopback_misses += 1
				if online_loopback_misses <= 8:
					print("[91.02.66-P14D1C] LOOPBACK FRAME LATE — tick=%d" % tick_sim)

	if rollback_ring != null and not rollback_catchup_activo:
		rollback_ring.asignar_inputs_ultimo(frame_j1, frame_j2)

	if input_recorder != null:
		input_recorder.grabar_tick(frame_j1, frame_j2)
		var tick_grabado: int = input_recorder.total_ticks()
		input_recorder.grabar_traza_tick(_capturar_estado_traza_replay())
		if tick_grabado % REPLAY_CHECKPOINT_INTERVALO == 0:
			input_recorder.grabar_checkpoint(tick_grabado, _capturar_estado_checkpoint_replay())

	kai.inyectar_input_frame(frame_j1)
	rival.inyectar_input_frame(frame_j2)

	online_tick_simulacion += 1
	if online_tick_simulacion % 60 == 0:
		var mascara_j1: int = InputRecorderScript.codificar_frame(frame_j1)
		var mascara_j2: int = InputRecorderScript.codificar_frame(frame_j2)
		print("[91.02.66-P14D1C] LOOPBACK INPUT — peer=%d rol=%s tick=%d J1mask=%d J2mask=%d hits=%d late=%d" % [
			red.mi_peer_id(), red.rol, online_tick_simulacion, mascara_j1, mascara_j2,
			online_loopback_hits, online_loopback_misses
		])
	if online_tick_simulacion > ONLINE_INPUT_DELAY_TICKS + 180:
		red.descartar_inputs_loopback_anteriores_a(online_tick_simulacion - 180)


func _inyectar_inputs_online() -> void:
	if not online_combate_habilitado:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var red := _network_online()
	if red == null or not red.hay_rival_conectado():
		kai.inyectar_input_frame(_router_frame_neutro())
		rival.inyectar_input_frame(_router_frame_neutro())
		return

	# 91.02.66 — En 127.0.0.1 no repartimos hardware entre dos procesos de
	# Windows. El HOST, que está enfocado, captura teclado + mando y manda ambos
	# Input Frames al cliente. El online real entre 2 PCs NO entra aquí.
	if red.has_method("es_loopback_misma_pc") and bool(red.es_loopback_misma_pc()):
		_inyectar_inputs_online_loopback(red)
		return

	var tick_sim := online_tick_simulacion
	var tick_captura := tick_sim + ONLINE_INPUT_DELAY_TICKS

	# Capturamos el input local para un tick FUTURO. Esto da a ENet cuatro
	# physics ticks para entregar el paquete sin introducir predicción en LAN.
	var frame_local_capturado := _router_frame_online_local()
	online_inputs_locales[str(tick_captura)] = frame_local_capturado.duplicate(true)
	var mascara_local := InputRecorderScript.codificar_frame(frame_local_capturado)
	red.enviar_input_frame(tick_captura, mascara_local)

	var frame_local_sim: Dictionary = online_inputs_locales.get(str(tick_sim), _router_frame_neutro())
	var frame_remoto_sim := _router_frame_neutro()
	var frame_remoto_fue_predicho: bool = false

	if tick_sim >= ONLINE_INPUT_DELAY_TICKS:
		var paquete_remoto: Dictionary = red.obtener_input_remoto(tick_sim)
		if bool(paquete_remoto.get("disponible", false)):
			frame_remoto_sim = InputRecorderScript.decodificar_frame(int(paquete_remoto.get("mascara", 0)))
			online_ultimo_frame_remoto = frame_remoto_sim.duplicate(true)
			online_remote_hits += 1
		else:
			# PASS 14D2A todavía NO rebobina. Marcamos exactamente la predicción
			# aplicada para compararla cuando llegue el paquete real.
			frame_remoto_sim = online_ultimo_frame_remoto.duplicate(true)
			frame_remoto_fue_predicho = true
			online_remote_misses += 1
			if online_remote_misses <= 8:
				print("[91.02.64-P14D1] REMOTE INPUT LATE — tick=%d; predicción=último frame" % tick_sim)

	# Registro de reconciliación 14D2A: sólo intención remota ya aplicada.
	# No forma parte del snapshot y no modifica el resultado del tick.
	online_prediccion_remota_por_tick[str(tick_sim)] = {
		"mascara": InputRecorderScript.codificar_frame(frame_remoto_sim),
		"predicho": frame_remoto_fue_predicho,
		"evaluado": false,
	}

	var frame_j1 := _router_frame_neutro()
	var frame_j2 := _router_frame_neutro()
	if red.es_host():
		frame_j1 = frame_local_sim
		frame_j2 = frame_remoto_sim
	else:
		frame_j1 = frame_remoto_sim
		frame_j2 = frame_local_sim

	# El ring certificado guarda exactamente los frames que se simulan.
	if rollback_ring != null and not rollback_catchup_activo:
		rollback_ring.asignar_inputs_ultimo(frame_j1, frame_j2)

	if input_recorder != null:
		input_recorder.grabar_tick(frame_j1, frame_j2)
		var tick_grabado: int = input_recorder.total_ticks()
		input_recorder.grabar_traza_tick(_capturar_estado_traza_replay())
		if tick_grabado % REPLAY_CHECKPOINT_INTERVALO == 0:
			input_recorder.grabar_checkpoint(tick_grabado, _capturar_estado_checkpoint_replay())

	kai.inyectar_input_frame(frame_j1)
	rival.inyectar_input_frame(frame_j2)

	online_tick_simulacion += 1
	if online_tick_simulacion % 60 == 0:
		print("[91.02.64-P14D1] NET INPUT — peer=%d rol=%s tick=%d hits=%d late=%d remoto_hasta=%d" % [
			red.mi_peer_id(),
			red.rol,
			online_tick_simulacion,
			online_remote_hits,
			online_remote_misses,
			red.ultimo_tick_remoto_recibido
		])
		print("[91.02.68-P14D2A] ROLLBACK DIAG — peer=%d tick=%d late_eval=%d iguales=%d necesarios=%d max_edad=%d" % [
			red.mi_peer_id(), online_tick_simulacion, online_late_evaluados,
			online_late_iguales, online_rollback_necesarios, online_rollback_max_edad
		])
		print("[91.02.70-P14D2C] ROLLBACK REAL — peer=%d tick=%d ejecutados=%d reprocesados=%d pendientes=%d fuera=%d" % [
			red.mi_peer_id(), online_tick_simulacion, online_rollbacks_ejecutados,
			online_rollback_ticks_reprocesados, online_rollback_tick_pendiente,
			online_rollback_fuera_ventana
		])
		if rollback_ring != null:
			var ring_total: int = rollback_ring.total()
			var ring_old: int = rollback_ring.tick_mas_antiguo()
			var ring_new: int = rollback_ring.tick_mas_nuevo()
			var ring_esperado: int = online_tick_simulacion - 1
			print("[91.02.69-P14D2B] ONLINE RING — peer=%d sim=%d total=%d old=%d new=%d esperado=%d alineado=%s" % [
				red.mi_peer_id(), online_tick_simulacion, ring_total, ring_old, ring_new, ring_esperado,
				str(ring_new == ring_esperado)
			])

	# Mantener buffers pequeños. El ring de rollback conserva su propia historia.
	if online_tick_simulacion % 30 == 0:
		var minimo := maxi(online_tick_simulacion - 16, 0)
		var borrar_local: Array[String] = []
		for clave in online_inputs_locales.keys():
			if int(clave) < minimo:
				borrar_local.append(str(clave))
		for clave in borrar_local:
			online_inputs_locales.erase(clave)
		red.descartar_inputs_remotos_anteriores_a(minimo)

		var minimo_diag: int = maxi(online_tick_simulacion - ONLINE_ROLLBACK_DIAG_HISTORY_TICKS, 0)
		var borrar_diag: Array[String] = []
		for clave_diag in online_prediccion_remota_por_tick.keys():
			if int(clave_diag) < minimo_diag:
				borrar_diag.append(str(clave_diag))
		for clave_diag in borrar_diag:
			online_prediccion_remota_por_tick.erase(clave_diag)


func _iniciar_grabacion_inputs() -> void:
	if not versus_local_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	input_recorder = InputRecorderScript.new()
	input_recorder_ronda_actual = 1
	var estado = get_node_or_null("/root/GameState")
	var escenario_grabado: String = escenario_nombre_actual
	if estado and estado.flujo_menu_activo:
		escenario_grabado = str(estado.escenario_actual)
	input_recorder.iniciar({
		"build": "91.00.00-H10.13",
		"rng_seed": replay_rng_seed_actual,
		"modo": "online" if online_activo else "versus_local",
		"j1": kai.nombre_luchador,
		"j2": rival.nombre_luchador,
		"escenario": escenario_grabado,
		"physics_hz": Engine.physics_ticks_per_second,
		"rondas_para_ganar": RONDAS_PARA_GANAR,
	})
	input_recorder.marcar_inicio_ronda(input_recorder_ronda_actual)
	input_recorder.grabar_checkpoint(0, _capturar_estado_checkpoint_replay())
	print("[91.00.00-H10.88] Input Recorder ACTIVO — %s vs %s" % [kai.nombre_luchador, rival.nombre_luchador])
	print("[91.00.00-H10.88] SNAPSHOT TEST — F9 guardar / F10 restaurar (estado neutral)")
	print("[91.00.00-H10.88] LOCAL ROLLBACK TEST — F11 rebobina 8 ticks (~133 ms)")
	print("[91.02.59-P13B] PROJECTILE ROLLBACK TEST — F11 localiza VUELO / IMPACTO+CORE / BLOQUEO")

func _marcar_nueva_ronda_input_recorder() -> void:
	if input_recorder == null or not input_recorder.grabando:
		return
	input_recorder_ronda_actual += 1
	input_recorder.marcar_inicio_ronda(input_recorder_ronda_actual)

func _cerrar_grabacion_inputs(ganador: Fighter, motivo: String) -> void:
	if input_recorder == null or not input_recorder.grabando:
		return
	var nombre_ganador := ganador.nombre_luchador if is_instance_valid(ganador) else ""
	var ruta: String = input_recorder.finalizar_y_guardar({
		"ganador": nombre_ganador,
		"motivo_fin": motivo,
		"rondas_j1": rondas_kai,
		"rondas_j2": rondas_rival,
		# 91.00.00-B: las grabaciones nuevas incluyen una fotografía mínima del
		# estado final. El replay viejo 91.00.00-A sigue siendo compatible.
		"estado_final": _capturar_estado_replay(),
	})
	if ruta != "":
		print("[91.00.00-H10.88] Input Recorder GUARDADO — %d ticks — %s" % [input_recorder.total_ticks(), ruta])

func _preparar_solicitud_replay() -> void:
	var estado = get_node_or_null("/root/GameState")
	if estado == null or not bool(estado.get("replay_solicitado")):
		return
	# Consumimos la solicitud una sola vez. Si la carga falla, el combate vuelve
	# a ser Versus Local normal y se puede generar otra grabación.
	estado.replay_solicitado = false
	input_replay = InputReplayScript.new()
	if not input_replay.cargar():
		print("[91.00.00-H10.88] REPLAY ERROR — %s" % input_replay.ultimo_error)
		estado.replay_ultimo_mensaje = "REPLAY ERROR: " + input_replay.ultimo_error
		input_replay = null
		return

	var meta: Dictionary = input_replay.metadata
	if str(meta.get("modo", "")) != "versus_local":
		print("[91.00.00-H10.88] REPLAY ERROR — la grabación no es Versus Local")
		estado.replay_ultimo_mensaje = "REPLAY ERROR: modo incompatible"
		input_replay = null
		return
	var hz_grabado := int(meta.get("physics_hz", Engine.physics_ticks_per_second))
	if hz_grabado != Engine.physics_ticks_per_second:
		print("[91.00.00-H10.88] REPLAY ERROR — physics_hz grabado=%d actual=%d" % [hz_grabado, Engine.physics_ticks_per_second])
		estado.replay_ultimo_mensaje = "REPLAY ERROR: physics_hz distinto"
		input_replay = null
		return

	var j1 := str(meta.get("j1", "Kai"))
	var j2 := str(meta.get("j2", "Cibor-X"))
	var escenario := str(meta.get("escenario", "Kai"))
	estado.iniciar_versus_local(j1, j2)
	estado.seleccionar_escenario(escenario)
	replay_modo_activo = true
	replay_ronda_actual = 1
	replay_agotado_reportado = false
	replay_final_evaluado = false
	replay_marcadores_ok = true
	replay_checkpoints_ok = true
	replay_trace_ok = true
	replay_tick_primer_desync = -1
	replay_ticks_neutros_post_buffer = 0

func _preparar_rng_determinista_versus() -> void:
	# El RNG global también alimenta partículas, voces y microvariaciones visuales.
	# Versus Local genera seed; Online DEBE usar la seed canónica ya acordada
	# por Host/Cliente en PASS 14C.
	var es_local := _detectar_modo_versus_local()
	var es_online := _detectar_modo_online()
	if not es_local and not es_online:
		return
	if replay_modo_activo and input_replay != null:
		replay_rng_seed_actual = int(input_replay.metadata.get("rng_seed", 0))
	elif es_online:
		var estado_online = get_node_or_null("/root/GameState")
		replay_rng_seed_actual = int(estado_online.online_seed) if estado_online != null else 0
	else:
		replay_rng_seed_actual = int(Time.get_ticks_usec() & 0x7fffffff)
	if replay_rng_seed_actual == 0:
		replay_rng_seed_actual = 9100004
	seed(replay_rng_seed_actual)
	print("[91.02.64-P14D1] RNG combate — modo=%s seed=%d" % ["ONLINE" if es_online else "LOCAL", replay_rng_seed_actual])

func _iniciar_replay_inputs() -> void:
	if input_replay == null or not replay_modo_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	var meta: Dictionary = input_replay.metadata
	if kai.nombre_luchador != str(meta.get("j1", "")) or rival.nombre_luchador != str(meta.get("j2", "")):
		print("[91.00.00-H10.88] REPLAY ERROR — personajes instanciados no coinciden con metadata")
		replay_modo_activo = false
		return
	_validar_marcador_ronda_replay()
	_validar_checkpoint_replay(0)
	print("[91.00.00-H10.88] REPLAY ACTIVO — %s vs %s — %d ticks" % [kai.nombre_luchador, rival.nombre_luchador, input_replay.total_ticks()])

func _validar_marcador_ronda_replay() -> void:
	if not replay_modo_activo or input_replay == null:
		return
	var esperado: int = input_replay.tick_inicio_ronda(replay_ronda_actual)
	if esperado < 0:
		return
	var actual: int = input_replay.tick_actual
	if actual == esperado:
		print("[91.00.00-H10.88] RONDA %d sincronizada — tick %d" % [replay_ronda_actual, actual])
	else:
		replay_marcadores_ok = false
		print("[91.00.00-H10.88] DESYNC RONDA %d — esperado tick %d / actual %d / delta %d" % [replay_ronda_actual, esperado, actual, actual - esperado])

func _capturar_estado_traza_replay() -> Dictionary:
	return {
		"rondas_j1": rondas_kai,
		"rondas_j2": rondas_rival,
		"ronda_activa": ronda_activa,
		"time_scale": snappedf(Engine.time_scale, 0.0001),
		"j1": _capturar_estado_luchador_traza(kai),
		"j2": _capturar_estado_luchador_traza(rival),
	}

func _capturar_estado_luchador_traza(personaje: Fighter) -> Dictionary:
	if not is_instance_valid(personaje):
		return {}
	return {
		"x": snappedf(personaje.position.x, 0.001),
		"y": snappedf(personaje.position.y, 0.001),
		"vx": snappedf(personaje.velocity.x, 0.001),
		"vy": snappedf(personaje.velocity.y, 0.001),
		"vida": snappedf(personaje.vida, 0.001),
		"poder": snappedf(personaje.poder, 0.001),
		"cargas": int(personaje.veces_fase_absoluta),
		"mirando": snappedf(personaje.mirando, 0.001),
		"fase_ataque": int(personaje.fase_ataque),
		"timer_ataque": snappedf(personaje.timer_fase_ataque, 0.0001),
		"atk_conecto": bool(personaje._atk_ya_conecto),
		"atk_tipo": str(personaje._atk_tipo),
		"hitstun": snappedf(personaje.hitstun_timer, 0.0001),
		"hitstop": snappedf(personaje.hitstop_timer, 0.0001),
		"empuje_timer": snappedf(personaje.empuje_timer, 0.0001),
		"empuje_x": snappedf(personaje.empuje_x, 0.001),
		"empuje_pendiente_timer": snappedf(personaje.empuje_pendiente_timer, 0.0001),
		"empuje_pendiente_fuerza": snappedf(personaje.empuje_pendiente_fuerza, 0.001),
		"carrera": bool(personaje.carrera_activa),
		"carrera_dir": snappedf(personaje.carrera_direccion, 0.001),
		"carrera_inicio": snappedf(personaje.carrera_inicio_timer, 0.0001),
		"carrera_freno": snappedf(personaje.carrera_frenado_timer, 0.0001),
		"dash_aereo": bool(personaje.dash_aereo_activo),
		"dash_aereo_dir": snappedf(personaje.dash_aereo_direccion, 0.001),
		"dash_aereo_timer": snappedf(personaje.dash_aereo_timer, 0.0001),
		"dash_aereo_usado": bool(personaje.dash_aereo_usado),
		"saltos": int(personaje.saltos_usados),
		"en_aire": bool(personaje.en_el_aire),
		"cruce_aereo": bool(personaje.cruce_aereo_activo),
		"bloqueando": bool(personaje.bloqueando),
		"bloqueo_timer": snappedf(personaje.bloqueo_timer, 0.0001),
		"contacto_timer": snappedf(personaje.contacto_post_golpe_timer, 0.0001),
		"contacto_dist": snappedf(personaje.contacto_post_golpe_distancia, 0.001),
		"recuperacion_levantada": snappedf(personaje.recuperacion_post_levantada_timer, 0.0001),
		"combo_count": int(personaje.combo_count),
		"combo_timer": snappedf(personaje.combo_timer, 0.0001),
		"secuencia": bool(personaje.en_secuencia_especial),
		"cinematico": bool(personaje.bloqueo_cinematico),
		"congelado_rival": bool(personaje.congelado_por_rival),
		"derribo": bool(personaje.derribo_especial_activo),
		"furia": bool(personaje.en_fase_absoluta),
	}

func _comparar_diccionario_traza(esperado: Dictionary, actual: Dictionary, prefijo: String) -> Array[String]:
	var diferencias: Array[String] = []
	for clave in esperado.keys():
		if not actual.has(clave):
			diferencias.append("%s.%s ausente" % [prefijo, clave])
			continue
		var ve = esperado[clave]
		var va = actual[clave]
		if typeof(ve) == TYPE_FLOAT or typeof(va) == TYPE_FLOAT:
			if absf(float(va) - float(ve)) > 0.0009:
				diferencias.append("%s.%s esperado=%s actual=%s" % [prefijo, clave, ve, va])
		elif va != ve:
			diferencias.append("%s.%s esperado=%s actual=%s" % [prefijo, clave, ve, va])
	return diferencias

func _validar_traza_replay(tick: int) -> void:
	if not replay_modo_activo or input_replay == null or not replay_trace_ok:
		return
	var esperado: Dictionary = input_replay.traza_para_tick(tick)
	if esperado.is_empty():
		return
	var actual := _capturar_estado_traza_replay()
	var diferencias: Array[String] = []
	for clave in ["rondas_j1", "rondas_j2", "ronda_activa", "time_scale"]:
		if esperado.has(clave):
			var ve = esperado[clave]
			var va = actual.get(clave)
			if (typeof(ve) == TYPE_FLOAT or typeof(va) == TYPE_FLOAT):
				if absf(float(va) - float(ve)) > 0.0009:
					diferencias.append("%s esperado=%s actual=%s" % [clave, ve, va])
			elif va != ve:
				diferencias.append("%s esperado=%s actual=%s" % [clave, ve, va])
	var esp_j1 = esperado.get("j1", {})
	var esp_j2 = esperado.get("j2", {})
	if typeof(esp_j1) == TYPE_DICTIONARY:
		diferencias.append_array(_comparar_diccionario_traza(esp_j1, actual.get("j1", {}), "J1"))
	if typeof(esp_j2) == TYPE_DICTIONARY:
		diferencias.append_array(_comparar_diccionario_traza(esp_j2, actual.get("j2", {}), "J2"))
	if diferencias.is_empty():
		return
	replay_trace_ok = false
	if replay_tick_primer_desync < 0:
		replay_tick_primer_desync = tick
	print("[91.00.00-H10.88] TRACE DESYNC — primer tick EXACTO: %d" % tick)
	for i in range(mini(diferencias.size(), 14)):
		print("  • " + diferencias[i])
	if diferencias.size() > 14:
		print("  • ... %d diferencia(s) adicionales" % (diferencias.size() - 14))

func _capturar_estado_checkpoint_replay() -> Dictionary:
	return {
		"rondas_j1": rondas_kai,
		"rondas_j2": rondas_rival,
		"ronda_activa": ronda_activa,
		"j1": _capturar_estado_luchador_replay(kai),
		"j2": _capturar_estado_luchador_replay(rival),
	}

func _validar_checkpoint_replay(tick: int) -> void:
	if not replay_modo_activo or input_replay == null:
		return
	var esperado: Dictionary = input_replay.checkpoint_para_tick(tick)
	if esperado.is_empty():
		return
	var actual := _capturar_estado_checkpoint_replay()
	var diferencias: Array[String] = []
	if int(esperado.get("rondas_j1", rondas_kai)) != rondas_kai:
		diferencias.append("rondas J1 esperado=%s actual=%d" % [esperado.get("rondas_j1"), rondas_kai])
	if int(esperado.get("rondas_j2", rondas_rival)) != rondas_rival:
		diferencias.append("rondas J2 esperado=%s actual=%d" % [esperado.get("rondas_j2"), rondas_rival])
	if bool(esperado.get("ronda_activa", ronda_activa)) != ronda_activa:
		diferencias.append("ronda_activa esperado=%s actual=%s" % [esperado.get("ronda_activa"), ronda_activa])
	var esp_j1 = esperado.get("j1", {})
	var esp_j2 = esperado.get("j2", {})
	if typeof(esp_j1) == TYPE_DICTIONARY:
		diferencias.append_array(_comparar_estado_luchador_replay(esp_j1, actual.get("j1", {}), "J1"))
	if typeof(esp_j2) == TYPE_DICTIONARY:
		diferencias.append_array(_comparar_estado_luchador_replay(esp_j2, actual.get("j2", {}), "J2"))
	if diferencias.is_empty():
		return
	replay_checkpoints_ok = false
	if replay_tick_primer_desync < 0:
		replay_tick_primer_desync = tick
		print("[91.00.00-H10.88] CHECKSUM DESYNC — primer tick detectado: %d" % tick)
		for diferencia in diferencias:
			print("  • " + diferencia)

func _capturar_estado_luchador_replay(personaje: Fighter) -> Dictionary:
	if not is_instance_valid(personaje):
		return {}
	return {
		"x": snappedf(personaje.position.x, 0.01),
		"y": snappedf(personaje.position.y, 0.01),
		"vx": snappedf(personaje.velocity.x, 0.01),
		"vy": snappedf(personaje.velocity.y, 0.01),
		"vida": snappedf(personaje.vida, 0.01),
		"poder": snappedf(personaje.poder, 0.01),
		"cargas": int(personaje.veces_fase_absoluta),
		"bloqueando": bool(personaje.bloqueando),
		"furia": bool(personaje.en_fase_absoluta),
	}

func _capturar_estado_replay() -> Dictionary:
	return {
		"j1": _capturar_estado_luchador_replay(kai),
		"j2": _capturar_estado_luchador_replay(rival),
	}

func _comparar_estado_luchador_replay(esperado: Dictionary, actual: Dictionary, etiqueta: String) -> Array[String]:
	var diferencias: Array[String] = []
	for clave in ["x", "y", "vx", "vy", "vida", "poder"]:
		if esperado.has(clave) and absf(float(actual.get(clave, 0.0)) - float(esperado.get(clave, 0.0))) > 0.05:
			diferencias.append("%s.%s esperado=%s actual=%s" % [etiqueta, clave, esperado.get(clave), actual.get(clave)])
	for clave in ["cargas", "bloqueando", "furia"]:
		if esperado.has(clave) and actual.get(clave) != esperado.get(clave):
			diferencias.append("%s.%s esperado=%s actual=%s" % [etiqueta, clave, esperado.get(clave), actual.get(clave)])
	return diferencias

func _evaluar_replay_final(ganador: Fighter) -> bool:
	if not replay_modo_activo or input_replay == null:
		return true
	replay_final_evaluado = true
	var meta: Dictionary = input_replay.metadata
	var diferencias: Array[String] = []
	var ganador_actual := ganador.nombre_luchador if is_instance_valid(ganador) else ""
	var ganador_esperado := str(meta.get("ganador", ""))
	if ganador_esperado != "" and ganador_actual != ganador_esperado:
		diferencias.append("ganador esperado=%s actual=%s" % [ganador_esperado, ganador_actual])
	if meta.has("rondas_j1") and rondas_kai != int(meta.get("rondas_j1", rondas_kai)):
		diferencias.append("rondas J1 esperado=%s actual=%d" % [meta.get("rondas_j1"), rondas_kai])
	if meta.has("rondas_j2") and rondas_rival != int(meta.get("rondas_j2", rondas_rival)):
		diferencias.append("rondas J2 esperado=%s actual=%d" % [meta.get("rondas_j2"), rondas_rival])
	var ticks_esperados := int(meta.get("ticks_totales", input_replay.total_ticks()))
	if input_replay.tick_actual != ticks_esperados:
		diferencias.append("tick final esperado=%d actual=%d" % [ticks_esperados, input_replay.tick_actual])
	if not replay_marcadores_ok:
		diferencias.append("uno o más inicios de ronda no coincidieron")
	if not replay_checkpoints_ok:
		diferencias.append("checkpoints divergieron desde tick %d" % replay_tick_primer_desync)
	if not replay_trace_ok:
		diferencias.append("traza por tick divergió desde tick %d" % replay_tick_primer_desync)

	var estado_final = meta.get("estado_final", {})
	if typeof(estado_final) == TYPE_DICTIONARY and not estado_final.is_empty():
		var estado_actual := _capturar_estado_replay()
		var esp_j1 = estado_final.get("j1", {})
		var esp_j2 = estado_final.get("j2", {})
		if typeof(esp_j1) == TYPE_DICTIONARY:
			diferencias.append_array(_comparar_estado_luchador_replay(esp_j1, estado_actual.get("j1", {}), "J1"))
		if typeof(esp_j2) == TYPE_DICTIONARY:
			diferencias.append_array(_comparar_estado_luchador_replay(esp_j2, estado_actual.get("j2", {}), "J2"))

	var estado = get_node_or_null("/root/GameState")
	if diferencias.is_empty():
		var mensaje := "REPLAY OK — %d/%d ticks — resultado idéntico" % [input_replay.tick_actual, ticks_esperados]
		print("[91.00.00-H10.88] " + mensaje)
		if estado:
			estado.replay_ultimo_mensaje = mensaje
		return true

	print("[91.00.00-H10.88] REPLAY DESYNC — %d diferencia(s):" % diferencias.size())
	for diferencia in diferencias:
		print("  • " + diferencia)
	if estado:
		estado.replay_ultimo_mensaje = "REPLAY DESYNC — ver Output"
	return false

func _configurar_control_lado(personaje: Fighter, es_lado_kai: bool) -> void:
	if es_lado_kai:
		if versus_local_activo:
			personaje.configurar_control_enrutado(0)
		else:
			# Fuera de Versus conservamos exactamente el fallback histórico de J1.
			personaje.configurar_control_local(0, -1, true)
	else:
		if versus_local_activo:
			personaje.configurar_control_enrutado(1)
		else:
			# 91.02.40 — PASS 11B: la CPU usa la dificultad central de GameState.
			# Si el estado no la expone, MEDIO (1) es el fallback de release.
			var dificultad_cpu: int = 1
			var estado_dificultad = get_node_or_null("/root/GameState")
			if estado_dificultad and "dificultad_ia" in estado_dificultad:
				dificultad_cpu = int(estado_dificultad.get("dificultad_ia"))
			personaje.configurar_control_ia(dificultad_cpu)

func _conectar_luchador(personaje: Fighter, es_jugador: bool) -> void:
	# 90.10.84 — lado estable para que el pushbox se resuelva una sola vez.
	personaje.configurar_lado_combate(0 if es_jugador else 1)
	_configurar_control_lado(personaje, es_jugador)
	personaje.impacto_detallado.connect(_al_impactar_detallado.bind(personaje))
	personaje.ataque_lanzado.connect(_al_ataque_lanzado.bind(personaje))
	personaje.aterrizaje_hecho.connect(_al_aterrizaje_hecho)
	personaje.core_listo.connect(_al_core_listo.bind(personaje))
	personaje.fase_activada.connect(_al_activar_fase.bind(personaje))
	personaje.core1_target_lock_finalizado.connect(_al_core1_target_lock_finalizado_h84.bind(personaje))
	personaje.core2_rematador_poster_finalizado.connect(_al_core2_rematador_poster_finalizado_h99.bind(personaje))
	personaje.rematador_iniciado.connect(_al_rematador_iniciado.bind(personaje))
	personaje.rematador_conectado.connect(_al_rematador.bind(personaje))
	personaje.finalizacion_absoluta.connect(_al_finalizacion_absoluta.bind(personaje))
	personaje.recarga_iniciada.connect(_al_recarga_iniciada.bind(personaje))
	personaje.proyectil_disparado.connect(_al_proyectil_disparado.bind(personaje))
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
	online_activo = _detectar_modo_online()
	# La infraestructura de control externo/rollback de Versus Local es la base
	# certificada que también utiliza Online. La captura de dispositivos cambia
	# en _inyectar_inputs_online().
	versus_local_activo = _detectar_modo_versus_local() or online_activo
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
	# 90.10.73 — los impactos normales ya NO alteran Engine.time_scale.
	# Fighter maneja el hit-stop de atacante/receptor localmente y Main conserva
	# cámara, audio, destello y reacción del escenario. Esto elimina micro-cámara
	# lenta repetitiva entre golpes y deja el slow-motion global reservado para
	# secuencias verdaderamente cinematográficas (KO/Absoluto).

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
	_reproducir_sfx(SND_CORE_LISTO, -4.0, 1.0)
	_reaccion_escenario_poder(personaje, 0.34)

func _al_activar_fase(personaje: Fighter) -> void:
	# H8.1 — observador inerte de la PRIMERA activación CORE.
	# La señal llega durante physics de Fighter, después de que Main registró
	# el snapshot de inicio de ese tick. Por eso rollback_tick_logico apunta
	# exactamente al snapshot que capturará el estado CORE en el próximo tick.
	if versus_local_activo and not replay_modo_activo and is_instance_valid(personaje):
		var nivel_core := int(personaje.veces_fase_absoluta)
		var lado_core := "J1" if personaje == kai else "J2"

		if nivel_core == 1:
			rollback_core1_event_serial += 1
			rollback_core1_event_tick_hint = rollback_tick_logico
			rollback_core1_event_lado = lado_core
			# H10.56 — target-only real: CORE I queda fuera del arnés de rollback.
			rollback_core1_event_serial_ya_probado = rollback_core1_event_serial
			print("[91.00.00-H10.88] CORE I EVENT OBSERVADO — serial=%d tick_hint=%d %s — sin autocaptura (target-only)" % [
				rollback_core1_event_serial,
				rollback_core1_event_tick_hint,
				rollback_core1_event_lado
			])
		elif nivel_core == 2:
			if rollback_catchup_activo:
				print("[91.00.00-H10.88] CORE II ENTRY RESIM — %s tick_logico=%d" % [
					lado_core, rollback_tick_logico
				])
			else:
				rollback_core2_event_serial += 1
				rollback_core2_event_tick_hint = rollback_tick_logico
				rollback_core2_event_lado = lado_core
				# H10.56 — target-only real: no dejar CORE II pendiente para el buscador.
				rollback_core2_event_serial_ya_probado = rollback_core2_event_serial
				print("[91.00.00-H10.88] CORE II EVENT OBSERVADO — serial=%d tick_hint=%d %s — sin autocaptura (target-only)" % [
					rollback_core2_event_serial,
					rollback_core2_event_tick_hint,
					rollback_core2_event_lado
				])
		elif nivel_core == 3:
			if rollback_catchup_activo:
				print("[91.00.00-H10.88] CORE III ENTRY RESIM — %s tick_logico=%d" % [
					lado_core, rollback_tick_logico
				])
			else:
				rollback_core3_event_serial += 1
				rollback_core3_event_tick_hint = rollback_tick_logico
				rollback_core3_event_lado = lado_core
				# H10.56 — target-only real: ENTRY está certificado y no debe disparar rollback.
				h10_core3_auto_armado = false
				rollback_core3_event_serial_ya_probado = rollback_core3_event_serial
				print("[91.00.00-H10.88] CORE III ENTRY OBSERVADO — serial=%d tick_hint=%d %s — sin autocaptura; esperando ABSOLUTE VICTORY HOLD" % [
					rollback_core3_event_serial,
					rollback_core3_event_tick_hint,
					rollback_core3_event_lado
				])

	sacudir_camara(10.0, 0.25)
	_reaccion_escenario_poder(personaje, 1.0)
	_reproducir_sfx(_sfx_elemento(personaje), -1.5, 1.0)
	# Audio nuevo de poder: se reinicia en cada activación CORE para que el
	# especial siempre tenga una entrada sonora clara y consistente.
	if audio_poder_final:
		audio_poder_final.stop()
		audio_poder_final.pitch_scale = 1.0
		audio_poder_final.play()

func _al_core1_target_lock_finalizado_h84(personaje: Fighter) -> void:
	if not versus_local_activo or replay_modo_activo:
		return
	if not is_instance_valid(personaje):
		return
	if int(personaje.veces_fase_absoluta) != 1:
		return

	var lado := "J1" if personaje == kai else "J2"

	# Durante la re-simulación queremos que la señal ocurra, pero el marcador
	# de diagnóstico no debe convertirse en estado causal ni alterar la búsqueda.
	if rollback_catchup_activo:
		print("[91.00.00-H10.88] CORE I TARGET END RESIM — %s tick_logico=%d" % [
			lado, rollback_tick_logico
		])
		return

	rollback_core1_target_end_serial += 1
	rollback_core1_target_end_tick_hint = rollback_tick_logico
	rollback_core1_target_end_lado = lado
	print("[91.00.00-H10.88] CORE I TARGET END MARCADO — serial=%d tick_hint=%d %s" % [
		rollback_core1_target_end_serial,
		rollback_core1_target_end_tick_hint,
		rollback_core1_target_end_lado
	])


func _al_core2_rematador_poster_finalizado_h99(personaje: Fighter) -> void:
	if not versus_local_activo or replay_modo_activo:
		return
	if not is_instance_valid(personaje):
		return
	if int(personaje.veces_fase_absoluta) != 2:
		return
	if int(personaje.get("core2_secuencia_etapa")) != 4:
		return

	var lado := "J1" if personaje == kai else "J2"

	if rollback_catchup_activo:
		print("[91.00.00-H10.88] CORE II REMATADOR POSTER END RESIM — %s tick_logico=%d" % [
			lado, rollback_tick_logico
		])
		return

	rollback_core2_rematador_poster_serial += 1
	rollback_core2_rematador_poster_tick_hint = rollback_tick_logico
	rollback_core2_rematador_poster_lado = lado

	print("[91.00.00-H10.88] CORE II REMATADOR POSTER END MARCADO — serial=%d tick_hint=%d %s" % [
		rollback_core2_rematador_poster_serial,
		rollback_core2_rematador_poster_tick_hint,
		rollback_core2_rematador_poster_lado
	])


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
	# Nueva capa energética universal aportada por el creador. Está recortada a
	# la duración visual real de cada carga para que no invada el combo posterior.
	_reproducir_sfx(SND_AURA_RECARGA_CORE3 if camara_lenta else SND_AURA_RECARGA_CORE2, -4.0 if camara_lenta else -5.0, 1.0)
	if personaje.nombre_luchador == "Cibor-X":
		_reproducir_sfx(SND_CIBOR_STUN, -12.0 if camara_lenta else -15.0, 1.0)
	# Kai/Fang/Aethel/Magnus usan una voz dedicada de carga tanto en CORE 2
	# como en CORE 3. Si ya sonó esa voz, evitamos apilar encima el grito genérico.
	var uso_voz_recarga: bool = _reproducir_voz_recarga(personaje, camara_lenta)
	# Si un personaje no tiene voz dedicada de RECARGA, como respaldo usamos
	# el grito fuerte existente. Helena ya no entra en esta excepción porque
	# ahora tiene su clip femenino propio.
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
		# 90.10.47 — la pose real de recarga CORE III en Fighter dura 1.55 s.
		# Antes Main sostenía time_scale/cámara durante 1.75 s, de modo que el
		# homing ya había empezado mientras la cámara seguía en la cinemática lenta.
		Engine.time_scale = 0.32
		var t_camara := get_tree().create_timer(1.50, true, false, true)
		t_camara.timeout.connect(_entregar_camara_core3_al_combate.bind(personaje))
		# H10.10 — Main ya NO gobierna el fin lógico de la cámara lenta con un
		# SceneTreeTimer no snapshotable. Fighter CORE3_FSM devuelve time_scale a
		# 1.0 exactamente al cerrar su recarga lógica de 1.55 s.

func _entregar_camara_core3_al_combate(personaje: Fighter) -> void:
	# 90.10.47 — handoff explícito entre la recarga lenta y el homing rápido.
	# Se ejecuta apenas antes de que Fighter termine su recarga de 1.55 s.
	if not camara or not is_instance_valid(personaje):
		return
	if not personaje.en_secuencia_especial or personaje.veces_fase_absoluta < 3:
		return
	if tween_camara_cinematica and is_instance_valid(tween_camara_cinematica):
		tween_camara_cinematica.kill()
	tween_camara_cinematica = null
	camara_cinematica_activa = false

	# Entregamos la cámara ya orientada hacia el encuadre de ambos luchadores,
	# sin teletransportarla por completo. El seguimiento rápido de _process()
	# termina el movimiento durante el dash/homing del CORE III.
	if is_instance_valid(kai) and is_instance_valid(rival):
		camara_separacion_suave = absf(kai.global_position.x - rival.global_position.x)
		var datos := _objetivo_camara_combate(camara_separacion_suave)
		var centro: Vector2 = datos.get("centro", camara.position)
		var nivel: float = float(datos.get("zoom", camara.zoom.x))
		camara.position = camara.position.lerp(centro, 0.50)
		camara.zoom = camara.zoom.lerp(Vector2.ONE * nivel, 0.35)

# Atenúa fondo, capas del escenario y al rival (nunca al que está cargando)
# para que la pose de recarga sea la que brille en pantalla.
func _oscurecer_escenario(fuerza: float, tiempo_total: float, personaje_a_atenuar: Fighter) -> void:
	var tw := create_tween()
	tw.set_parallel(true)
	var base_fondo := _obtener_tono_base_escenario(escenario_nombre_actual)
	var base_suelo := _obtener_tono_base_suelo(escenario_nombre_actual)
	var tono_fondo := Color(base_fondo.r * (1.0 - fuerza), base_fondo.g * (1.0 - fuerza), base_fondo.b * (1.0 - fuerza), 1.0)
	var tono_suelo := Color(base_suelo.r * (1.0 - fuerza * 0.75), base_suelo.g * (1.0 - fuerza * 0.75), base_suelo.b * (1.0 - fuerza * 0.75), 1.0)
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
		tw.tween_property(fondo_sprite, "modulate", base_fondo, 0.32)
	if escenario_vivo:
		tw.tween_property(escenario_vivo, "modulate", base_fondo, 0.32)
	if ambiente_particulas:
		tw.tween_property(ambiente_particulas, "modulate", base_fondo, 0.32)
	if ambiente_particulas_delante:
		tw.tween_property(ambiente_particulas_delante, "modulate", base_fondo, 0.32)
	if piso_overlay:
		tw.tween_property(piso_overlay, "modulate", base_suelo, 0.32)
	if is_instance_valid(personaje_a_atenuar) and personaje_a_atenuar.sprite:
		tw.tween_property(personaje_a_atenuar.sprite, "modulate", Color.WHITE, 0.32)

func _reaccion_escenario_poder(personaje: Fighter, intensidad: float) -> void:
	if modo_bajo_visual:
		return
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
	if modo_bajo_visual:
		return
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
	if modo_bajo_visual:
		return
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
	audio_salto.pitch_scale = randf_range(0.97, 1.05)
	audio_salto.play()

func sacudir_camara(fuerza: float, duracion: float) -> void:
	var ajustes := get_node_or_null("/root/SettingsManager")
	if ajustes and not bool(ajustes.get("shake_camara")):
		shake_fuerza = 0.0
		shake_tiempo = 0.0
		if camara:
			camara.offset = Vector2.ZERO
		return
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
	_ajustar_overscan_cinematico(true, entrada)
	tween_camara_cinematica = create_tween()
	tween_camara_cinematica.set_parallel(true)
	tween_camara_cinematica.tween_property(camara, "zoom", Vector2(nivel_final, nivel_final), entrada)
	tween_camara_cinematica.tween_property(camara, "position", centro, entrada)
	tween_camara_cinematica.chain().tween_interval(sostener)
	# Al terminar una cinemática no volvemos obligatoriamente al centro/zoom 1.
	# Reingresamos al encuadre dinámico correspondiente a la posición ACTUAL
	# de los luchadores para evitar un pequeño salto visual al recuperar control.
	tween_camara_cinematica.chain().tween_callback(_restaurar_camara_dinamica)

func _restaurar_camara_dinamica() -> void:
	if not camara:
		camara_cinematica_activa = false
		tween_camara_cinematica = null
		return
	var datos := _objetivo_camara_combate()
	var centro: Vector2 = datos.get("centro", Vector2(ANCHO_ARENA * 0.5, 360.0))
	var nivel: float = float(datos.get("zoom", 1.0))
	var tw_regreso := create_tween()
	tween_camara_cinematica = tw_regreso
	tw_regreso.set_parallel(true)
	_ajustar_overscan_cinematico(false, 0.38)
	tw_regreso.tween_property(camara, "zoom", Vector2.ONE * nivel, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw_regreso.tween_property(camara, "position", centro, 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw_regreso.chain().tween_callback(func():
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
	# H10.60 — la entrada ABSOLUTA ya está certificada en H10.58. Aquí sólo
	# recordamos qué lado inició la cinematográfica; NO disparamos rollback.
	# El único target de esta build es el cruce time_scale 0.18->0.42.
	if versus_local_activo and not replay_modo_activo:
		var lado_abs := "J1" if personaje == kai else "J2"
		if not rollback_catchup_activo:
			h1057_event_lado = lado_abs
			print("[91.00.00-H10.88] CORE III ABSOLUTE FINISHER ENTRY OBSERVADO — %s; KO/reveal/victory entry certificados; esperando ABSOLUTE VICTORY HOLD" % lado_abs)
	_reaccion_escenario_poder(personaje, 1.8)
	ronda_activa = false

	congelando_ko = true
	sacudir_camara(26.0, 0.5)
	_zoom_dramatico(personaje, 1.22, 0.22, 2.6, true)
	# 90.10.50 — en el instante exacto del reveal se corta el audio del escenario.
	# Desde acá quedan sólo impacto, energía, gigantografía y luego victoria.
	_detener_audio_escenario_final()
	# 90.10.49 — entrada sonora sincronizada con el reveal de la gigantografía.
	# El clip dura 2.76 s, prácticamente lo mismo que el póster absoluto (2.80 s),
	# y su golpe principal cae ~0.21 s después del inicio, justo cuando termina
	# de entrar el arte grande. No reemplaza el impacto físico final existente.
	_reproducir_sfx(SND_GIGANTOGRAFIA_FINAL_USUARIO, -1.2, 1.0)
	_reproducir_sfx(_sfx_elemento(personaje), -1.0, 0.84)
	# Grito propio de Aethel en SU poder final -- capa extra sobre el
	# elemento (viento), no lo reemplaza.
	if personaje.nombre_luchador == "Aethel":
		_reproducir_sfx(SND_AETHEL_PODER_FINAL, -2.0, randf_range(0.97, 1.03))
	Engine.time_scale = 0.18

	# H10.60 — FASE 83 física/snapshotable. El viejo SceneTreeTimer(3.15,
	# ignore_time_scale=true) no podía volver al pasado. El contador arranca
	# después del callback actual y consume 1 physics tick REAL por frame.
	core3_absolute_reveal_fsm_activo = true
	core3_absolute_reveal_timer = CORE3_ABSOLUTE_REVEAL_DURACION
	core3_absolute_reveal_lado = 1 if personaje == kai else 2

func _h1060_actualizar_core3_absolute_reveal_fsm() -> void:
	if not core3_absolute_reveal_fsm_activo:
		return
	var paso_real := 1.0 / float(maxi(1, Engine.physics_ticks_per_second))
	core3_absolute_reveal_timer = maxf(0.0, core3_absolute_reveal_timer - paso_real)
	if core3_absolute_reveal_timer > 0.000001:
		return

	core3_absolute_reveal_fsm_activo = false
	core3_absolute_reveal_timer = 0.0
	# Este cambio es la frontera H10.60. Debe ocurrir aunque estemos en catch-up.
	Engine.time_scale = 0.42

	# H10.62 — el reveal certificado entrega directamente a la espera física
	# de 0.70 s. Se arma también durante catch-up para que el K.O. pueda volver
	# a ocurrir en el mismo tick histórico.
	core3_absolute_ko_fsm_activo = true
	core3_absolute_ko_timer = CORE3_ABSOLUTE_KO_DURACION
	core3_absolute_ko_lado = core3_absolute_reveal_lado

func _h1062_actualizar_core3_absolute_ko_fsm() -> void:
	if not core3_absolute_ko_fsm_activo:
		return
	var paso_real := 1.0 / float(maxi(1, Engine.physics_ticks_per_second))
	core3_absolute_ko_timer = maxf(0.0, core3_absolute_ko_timer - paso_real)
	if core3_absolute_ko_timer > 0.000001:
		return

	core3_absolute_ko_fsm_activo = false
	core3_absolute_ko_timer = 0.0
	var lado := core3_absolute_ko_lado
	var personaje: Fighter = kai if lado == 1 else rival
	if not is_instance_valid(personaje):
		return
	var perdedor: Fighter = rival if personaje == kai else kai
	if not is_instance_valid(perdedor):
		return

	# Esta es exactamente la frontera H10.62. Debe ejecutarse también durante
	# catch-up: _derrotado() limpia hitstun/derribo, fija la pose y separación
	# final y emite derrotado; Main ignora esa señal porque ronda_activa=false.
	perdedor.vida = 0.0
	perdedor._derrotado()

	# H10.65 — el K.O. certificado entrega directamente a una espera física
	# snapshotable de 0.65 s. Se arma también durante catch-up.
	core3_absolute_victory_fsm_activo = true
	core3_absolute_victory_timer = CORE3_ABSOLUTE_VICTORY_DURACION
	core3_absolute_victory_lado = lado

func _h1065_actualizar_core3_absolute_victory_fsm() -> void:
	if not core3_absolute_victory_fsm_activo:
		return
	var paso_real := 1.0 / float(maxi(1, Engine.physics_ticks_per_second))
	core3_absolute_victory_timer = maxf(0.0, core3_absolute_victory_timer - paso_real)
	if core3_absolute_victory_timer > 0.000001:
		return

	core3_absolute_victory_fsm_activo = false
	core3_absolute_victory_timer = 0.0
	var lado := core3_absolute_victory_lado
	core3_absolute_victory_lado = 0
	_h1065_entrar_victoria_absoluta(lado)

func _h1065_entrar_victoria_absoluta(lado: int) -> void:
	var personaje: Fighter = kai if lado == 1 else rival
	if not is_instance_valid(personaje):
		return
	var perdedor: Fighter = rival if personaje == kai else kai
	if not is_instance_valid(perdedor):
		return

	# H10.65 — núcleo determinista de ABSOLUTE VICTORY ENTRY. Esta parte DEBE
	# ejecutarse también en catch-up porque forma parte del snapshot histórico.
	Engine.time_scale = 1.0
	congelando_ko = false

	# FASE 85: después de leer la caída definitiva, el ganador tiene su beat
	# de victoria. Fighter.mostrar_pose_victoria() fija además el estado físico
	# que debe reaparecer exactamente en el subtick histórico de entrada.
	personaje.mostrar_pose_victoria()
	rondas_kai = 3 if personaje == kai else 0
	rondas_rival = 3 if personaje == rival else 0
	_actualizar_marcador()
	core3_absolute_reveal_lado = 0
	core3_absolute_ko_lado = 0
	core3_absolute_ko_fsm_activo = false
	core3_absolute_ko_timer = 0.0

	# Cámara, audio, tweens, grabación y timer de salida son presentación LIVE.
	# No se duplican durante catch-up; no pertenecen al estado rollback.
	if rollback_catchup_activo or rollback_comparacion_pendiente:
		return

	_zoom_dramatico(personaje, 1.18, 0.22, 2.9, false)
	_reaccion_escenario_poder(personaje, 0.72)
	if perdedor.sprite:
		var tw_perdedor := create_tween()
		tw_perdedor.tween_property(perdedor.sprite, "modulate", Color(0.48, 0.48, 0.52, 1.0), 0.28)

	# 91.00.00-H10.13 — conserva el fix de C: CORE III tiene su propio terminal de partida. En B el replay
	# nunca llamaba a _evaluar_replay_final() por esta ruta y por eso un replay
	# correcto podía imprimirse como "inputs agotados antes del final".
	var replay_ok_core := true
	if replay_modo_activo:
		replay_ok_core = _evaluar_replay_final(personaje)
	else:
		_cerrar_grabacion_inputs(personaje, "core_iii")
	if replay_modo_activo:
		etiqueta_resultado.text = ("REPLAY OK — " if replay_ok_core else "REPLAY DESYNC — ") + personaje.nombre_luchador.to_upper()
	else:
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
		_cerrar_grabacion_inputs(ganador, "rondas")
		# 90.10.15 — cualquier forma de ganar la partida termina en pose de
		# victoria bloqueada, no solamente el Golpe Absoluto.
		ganador.mostrar_pose_victoria()
		var replay_ok := _evaluar_replay_final(ganador)
		if replay_modo_activo:
			etiqueta_resultado.text = ("REPLAY OK — " if replay_ok else "REPLAY DESYNC — ") + ganador.nombre_luchador.to_upper()
		else:
			etiqueta_resultado.text = "¡%s GANA LA PARTIDA!" % ganador.nombre_luchador.to_upper()
		# 90.10.50 — una victoria normal también cierra la música del escenario
		# antes del sting de victoria, para evitar dos pistas simultáneas.
		_detener_audio_escenario_final()
		audio_victoria.play()
		var t := get_tree().create_timer(9.20)
		t.timeout.connect(_finalizar_partida_flujo.bind(ganador))
	else:
		etiqueta_resultado.text = "K.O. — %s gana la ronda" % ganador.nombre_luchador.to_upper()
		_programar_siguiente_ronda_por_ticks()

func _programar_siguiente_ronda_por_ticks() -> void:
	# 91.00.00-H: este delay cambia estado de combate, por lo tanto no puede
	# depender del reloj de render/idle.
	await _esperar_segundos_fisica(2.2)
	if is_inside_tree():
		_siguiente_ronda()

func _siguiente_ronda() -> void:
	kai.position = POS_KAI
	rival.position = POS_RIVAL
	kai.reiniciar_para_ronda()
	rival.reiniciar_para_ronda()
	ronda_activa = true
	if replay_modo_activo:
		replay_ronda_actual += 1
		_validar_marcador_ronda_replay()
	else:
		_marcar_nueva_ronda_input_recorder()
	etiqueta_resultado.text = "¡Ronda!"
	_limpiar_etiqueta_ronda_por_ticks()

func _limpiar_etiqueta_ronda_por_ticks() -> void:
	await _esperar_segundos_fisica(0.9)
	if is_inside_tree() and etiqueta_resultado:
		etiqueta_resultado.text = ""

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
	# En debug, una nueva partida arranca una grabación nueva después de resetear
	# la ronda; así el primer marcador vuelve a ser ronda 1 y no ronda 2.
	if versus_local_activo and not replay_modo_activo:
		_iniciar_grabacion_inputs()

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
	etiqueta_rival.text = rival.nombre_luchador + (" (J2)" if versus_local_activo else " (IA)")
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
	# 90.10.15 — el texto de victoria se perdía sobre escenarios muy luminosos.
	etiqueta_resultado.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.92))
	etiqueta_resultado.add_theme_constant_override("outline_size", 8)
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
	etiqueta_rival.text = rival.nombre_luchador + (" (J2)" if versus_local_activo else " (IA)")
	etiqueta_rival.position = Vector2(ANCHO_ARENA - 40 - ANCHO_BARRA, 4)
	capa.add_child(etiqueta_rival)

	var ayuda := Label.new()
	var pads_ui := Input.get_connected_joypads()
	if replay_modo_activo:
		ayuda.text = "REPLAY 91.00.00-B   •   INPUTS GRABADOS   •   TECLADO/MANDO NO CONTROLAN LA PELEA"
	elif versus_local_activo:
		if pads_ui.size() >= 2:
			ayuda.text = "VERSUS LOCAL   •   J1 MANDO 1   •   J2 MANDO 2"
		elif pads_ui.size() == 1:
			ayuda.text = "VERSUS LOCAL   •   J1 TECLADO: Flechas/X/C/Z   •   J2 MANDO"
		else:
			ayuda.text = "VERSUS LOCAL   •   J1 Flechas/X/C/Z   •   J2 WASD/F/G/H"
	else:
		if not pads_ui.is_empty():
			ayuda.text = "MANDO: Stick/D-Pad mover   A: salto   B/LT: bloqueo   X: puño   Y: patada   RB/RT: CORE"
		else:
			ayuda.text = "J1 Flechas: mover/saltar/bloquear   •   X: puño   C: patada   Z: CORE"
	ayuda.position = Vector2(40, 660)
	capa.add_child(ayuda)

	var ayuda2 := Label.new()
	ayuda2.text = "Rival: 1 Fang  2 Cibor-X  3 Kali  4 Aethel  5 Magnus  6 Helena  7 Jester  8 Varkhos  9 Xenoid  0 Dax"
	ayuda2.position = Vector2(40, 684)
	capa.add_child(ayuda2)

	seleccion_jugador_label = Label.new()
	seleccion_jugador_label.text = "J1: Q Kai  W Fang  E Cibor-X  R Kali  T Aethel  Y Magnus  U Helena  I Jester  O Xenoid  P Dax"
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

func _aplicar_modo_versus_local_runtime(activar: bool) -> void:
	versus_local_activo = activar
	if is_instance_valid(kai):
		_configurar_control_lado(kai, true)
	if is_instance_valid(rival):
		_configurar_control_lado(rival, false)
	if etiqueta_rival and is_instance_valid(rival):
		etiqueta_rival.text = rival.nombre_luchador + (" (J2)" if activar else " (IA)")
	if etiqueta_resultado:
		if activar:
			etiqueta_resultado.text = "VERSUS LOCAL — J2 LISTO"
		else:
			etiqueta_resultado.text = "CPU — DIFICULTAD FÁCIL"
		var t := get_tree().create_timer(1.15)
		t.timeout.connect(func():
			if etiqueta_resultado:
				etiqueta_resultado.text = ""
		)

func _rollback_verificar_subtick() -> void:
	if online_rollback_catchup_modo:
		_online_reescribir_snapshot_catchup_actual()
		return
	if rollback_catchup_indice < 0 or rollback_catchup_indice >= rollback_catchup_ventana.size():
		return
	var esperado: Dictionary = rollback_catchup_ventana[rollback_catchup_indice].get("snapshot", {})
	if esperado.is_empty():
		return
	var actual: Dictionary = RollbackSnapshotScript.capturar_partida(self, kai, rival)
	var diferencias: Array[String] = RollbackSnapshotScript.comparar_snapshots(esperado, actual)
	if diferencias.is_empty() or rollback_subtrace_primer_error >= 0:
		return

	rollback_subtrace_primer_error = rollback_catchup_indice
	rollback_subtrace_diferencias = diferencias.duplicate()

	var idx_actual: int = rollback_catchup_indice
	var idx_causal: int = maxi(0, idx_actual - 1)
	var entrada_actual: Dictionary = rollback_catchup_ventana[idx_actual]
	var entrada_causal: Dictionary = rollback_catchup_ventana[idx_causal]
	var inicio_causal: Dictionary = entrada_causal.get("snapshot", {})
	var tick_actual: int = int(entrada_actual.get("tick", -1))
	var tick_causal: int = int(entrada_causal.get("tick", -1))

	var e1: Dictionary = esperado.get("j1", {})
	var e2: Dictionary = esperado.get("j2", {})
	var s1: Dictionary = inicio_causal.get("j1", {})
	var s2: Dictionary = inicio_causal.get("j2", {})

	var input_causal_j1: Dictionary = entrada_causal.get("j1", {})
	var input_causal_j2: Dictionary = entrada_causal.get("j2", {})

	var pos_ini_j1: Vector2 = s1.get("position", Vector2.ZERO)
	var pos_ini_j2: Vector2 = s2.get("position", Vector2.ZERO)
	var pos_exp_j1: Vector2 = e1.get("position", Vector2.ZERO)
	var pos_exp_j2: Vector2 = e2.get("position", Vector2.ZERO)
	var motion_exp_j1: Vector2 = e1.get("__last_motion", Vector2.ZERO)
	var motion_exp_j2: Vector2 = e2.get("__last_motion", Vector2.ZERO)
	var motion_act_j1: Vector2 = kai.get_last_motion()
	var motion_act_j2: Vector2 = rival.get_last_motion()

	# Movimiento externo = delta mundial menos el desplazamiento propio informado
	# por CharacterBody2D. Si no es cero, alguien movió ese Fighter desde afuera
	# (pushbox, contacto post golpe, anchor de dash o límite de arena).
	var externo_exp_j1 := pos_exp_j1.x - pos_ini_j1.x - motion_exp_j1.x
	var externo_exp_j2 := pos_exp_j2.x - pos_ini_j2.x - motion_exp_j2.x
	var externo_act_j1 := kai.position.x - pos_ini_j1.x - motion_act_j1.x
	var externo_act_j2 := rival.position.x - pos_ini_j2.x - motion_act_j2.x

	var dist_inicio := absf(pos_ini_j2.x - pos_ini_j1.x)
	var dist_esperada := absf(pos_exp_j2.x - pos_exp_j1.x)
	var dist_actual := absf(rival.position.x - kai.position.x)

	print("[91.00.00-H10.88] ROLLBACK CAUSAL DESYNC — estado tick %d; causado por tick %d (subtick %d/%d)" % [
		tick_actual, tick_causal, idx_actual, rollback_catchup_ventana.size()
	])
	for i in range(mini(diferencias.size(), 12)):
		print("  • " + diferencias[i])

	print("  • INPUT CAUSAL J1=%s" % str(input_causal_j1))
	print("  • INPUT CAUSAL J2=%s" % str(input_causal_j2))
	print("  • ATAQUE J1 esperado fase=%s timer=%.5f tipo=%s conecto=%s hitstop=%.5f hitstun=%.5f vida=%.3f contacto=%.5f" % [
		str(e1.get("fase_ataque", 0)), float(e1.get("timer_fase_ataque", 0.0)),
		str(e1.get("_atk_tipo", "")), str(e1.get("_atk_ya_conecto", false)),
		float(e1.get("hitstop_timer", 0.0)), float(e1.get("hitstun_timer", 0.0)),
		float(e1.get("vida", 0.0)), float(e1.get("contacto_post_golpe_timer", 0.0))
	])
	print("  • ATAQUE J1 actual   fase=%s timer=%.5f tipo=%s conecto=%s hitstop=%.5f hitstun=%.5f vida=%.3f contacto=%.5f" % [
		str(kai.fase_ataque), float(kai.timer_fase_ataque), str(kai._atk_tipo), str(kai._atk_ya_conecto),
		float(kai.hitstop_timer), float(kai.hitstun_timer), float(kai.vida), float(kai.contacto_post_golpe_timer)
	])
	print("  • ATAQUE J2 esperado fase=%s timer=%.5f tipo=%s conecto=%s hitstop=%.5f hitstun=%.5f vida=%.3f contacto=%.5f" % [
		str(e2.get("fase_ataque", 0)), float(e2.get("timer_fase_ataque", 0.0)),
		str(e2.get("_atk_tipo", "")), str(e2.get("_atk_ya_conecto", false)),
		float(e2.get("hitstop_timer", 0.0)), float(e2.get("hitstun_timer", 0.0)),
		float(e2.get("vida", 0.0)), float(e2.get("contacto_post_golpe_timer", 0.0))
	])
	print("  • ATAQUE J2 actual   fase=%s timer=%.5f tipo=%s conecto=%s hitstop=%.5f hitstun=%.5f vida=%.3f contacto=%.5f" % [
		str(rival.fase_ataque), float(rival.timer_fase_ataque), str(rival._atk_tipo), str(rival._atk_ya_conecto),
		float(rival.hitstop_timer), float(rival.hitstun_timer), float(rival.vida), float(rival.contacto_post_golpe_timer)
	])
	print("  • DISTANCIA inicio=%.4f esperada=%.4f actual=%.4f" % [dist_inicio, dist_esperada, dist_actual])
	print("  • DESPLAZAMIENTO EXTERNO J1 esperado=%.4f actual=%.4f | J2 esperado=%.4f actual=%.4f" % [
		externo_exp_j1, externo_act_j1, externo_exp_j2, externo_act_j2
	])

	print("  • J1 INICIO pos=%s vel=%s carrera=%s dir=%s timer=%s contacto=%.4f/%.2f block=%s hitstun=%.4f hitstop=%.6f fase=%s atkTimer=%.6f idxP=%s idxK=%s prevP=%s prevK=%s buffer=%s/%.6f extDisp=%s" % [
		str(pos_ini_j1), str(s1.get("velocity", Vector2.ZERO)),
		str(s1.get("carrera_activa", false)), str(s1.get("carrera_direccion", 0.0)),
		str(s1.get("carrera_inicio_timer", 0.0)),
		float(s1.get("contacto_post_golpe_timer", 0.0)), float(s1.get("contacto_post_golpe_distancia", 0.0)),
		str(s1.get("bloqueando", false)), float(s1.get("hitstun_timer", 0.0)),
		float(s1.get("hitstop_timer", 0.0)), str(s1.get("fase_ataque", 0)),
		float(s1.get("timer_fase_ataque", 0.0)), str(s1.get("indice_punetazo", -1)),
		str(s1.get("indice_patada", -1)), str(s1.get("puno_estaba_presionado", false)),
		str(s1.get("patada_estaba_presionada", false)), str(s1.get("ataque_buffer_tipo", "")),
		float(s1.get("ataque_buffer_timer", 0.0)), str(s1.get("input_externo_disponible", false))
	])
	print("  • J2 INICIO pos=%s vel=%s carrera=%s dir=%s timer=%s contacto=%.4f/%.2f block=%s hitstun=%.4f fase=%s" % [
		str(pos_ini_j2), str(s2.get("velocity", Vector2.ZERO)),
		str(s2.get("carrera_activa", false)), str(s2.get("carrera_direccion", 0.0)),
		str(s2.get("carrera_inicio_timer", 0.0)),
		float(s2.get("contacto_post_golpe_timer", 0.0)), float(s2.get("contacto_post_golpe_distancia", 0.0)),
		str(s2.get("bloqueando", false)), float(s2.get("hitstun_timer", 0.0)), str(s2.get("fase_ataque", 0))
	])

	print("  • J1 FIN esperado pos=%s vel=%s last_motion=%s | actual pos=%s vel=%s last_motion=%s" % [
		str(pos_exp_j1), str(e1.get("velocity", Vector2.ZERO)), str(motion_exp_j1),
		str(kai.position), str(kai.velocity), str(motion_act_j1)
	])
	print("  • J2 FIN esperado pos=%s vel=%s last_motion=%s | actual pos=%s vel=%s last_motion=%s" % [
		str(pos_exp_j2), str(e2.get("velocity", Vector2.ZERO)), str(motion_exp_j2),
		str(rival.position), str(rival.velocity), str(motion_act_j2)
	])

	print("  • VISUAL INICIO J1 tex=%s scale=%s | J2 tex=%s scale=%s" % [
		str(s1.get("__sprite_texture_path", "")), str(s1.get("__sprite_scale", Vector2.ONE)),
		str(s2.get("__sprite_texture_path", "")), str(s2.get("__sprite_scale", Vector2.ONE))
	])
	print("  • EDGES INICIO J1 prevL=%s prevR=%s dblL=%s dblR=%s | J2 prevL=%s prevR=%s dblL=%s dblR=%s" % [
		str(s1.get("tecla_izq_previa", false)), str(s1.get("tecla_der_previa", false)),
		str(s1.get("doble_pulso_izq_timer", 0.0)), str(s1.get("doble_pulso_der_timer", 0.0)),
		str(s2.get("tecla_izq_previa", false)), str(s2.get("tecla_der_previa", false)),
		str(s2.get("doble_pulso_izq_timer", 0.0)), str(s2.get("doble_pulso_der_timer", 0.0))
	])

func _rollback_registrar_inicio_tick() -> void:
	if rollback_ring == null:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	var estado_tick: Dictionary = RollbackSnapshotScript.capturar_partida(self, kai, rival)
	# 91.00.00-H10.13 — el ring ahora acepta el ciclo completo de un ataque NORMAL
	# (startup/activo/recovery + hitstop/hitstun). CORE/KO/cinemáticas siguen fuera.
	rollback_ring.agregar_inicio_tick(rollback_tick_logico, estado_tick, _snapshot_estado_rollback_h_seguro())
	rollback_tick_logico += 1

func _h911_buscar_ventana_core2_sequence_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	if not h911_auto_test_armado:
		return {}
	if h911_auto_test_tick_evento < 0:
		return {}
	if h911_auto_test_tick_evento <= rollback_core2_sequence_end_tick_ya_probado:
		return {}

	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < ROLLBACK_TEST_TICKS:
		return {}

	var idx_evento := -1
	for i in range(historial.size()):
		if int(historial[i].get("tick", -1)) == h911_auto_test_tick_evento:
			idx_evento = i
			break
	if idx_evento < 0:
		return {}

	# Un tick antes del cierre para atravesar WAIT_FINAL -> INACTIVO.
	var inicio_idx := maxi(0, idx_evento - 1)
	if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
		inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
	if inicio_idx < 0:
		return {}

	var ventana: Array[Dictionary] = []
	for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
		ventana.append(historial[k])

	return {
		"encontrado": true,
		"ventana": ventana,
		"tick_evento": h911_auto_test_tick_evento,
		"lado": h911_auto_test_lado,
	}


func _h911_observar_core2_sequence_end_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core2_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core2_secuencia_etapa"))
	var sub_j1 := int(kai.get("core2_rematador_subfase"))
	var sub_j2 := int(rival.get("core2_rematador_subfase"))
	var sec_j1 := bool(kai.en_secuencia_especial)
	var sec_j2 := bool(rival.en_secuencia_especial)

	if not h911_observador_inicializado:
		h911_etapa_prev_j1 = etapa_j1
		h911_etapa_prev_j2 = etapa_j2
		h911_sub_prev_j1 = sub_j1
		h911_sub_prev_j2 = sub_j2
		h911_sec_prev_j1 = sec_j1
		h911_sec_prev_j2 = sec_j2
		h911_observador_inicializado = true
		return

	var lado := ""

	if h911_etapa_prev_j1 == 4 \
	and h911_sub_prev_j1 == 1 \
	and h911_sec_prev_j1 \
	and etapa_j1 == 0 \
	and not sec_j1 \
	and int(kai.veces_fase_absoluta) == 2:
		lado = "J1"
	elif h911_etapa_prev_j2 == 4 \
	and h911_sub_prev_j2 == 1 \
	and h911_sec_prev_j2 \
	and etapa_j2 == 0 \
	and not sec_j2 \
	and int(rival.veces_fase_absoluta) == 2:
		lado = "J2"

	h911_etapa_prev_j1 = etapa_j1
	h911_etapa_prev_j2 = etapa_j2
	h911_sub_prev_j1 = sub_j1
	h911_sub_prev_j2 = sub_j2
	h911_sec_prev_j1 = sec_j1
	h911_sec_prev_j2 = sec_j2

	if lado.is_empty() or h911_auto_test_armado:
		return

	h911_auto_test_armado = true
	h911_auto_test_tick_evento = rollback_tick_logico - 1
	h911_auto_test_lado = lado
	rollback_test_solicitado = true

	print("[91.00.00-H10.88] CORE II SEQUENCE END AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h911_auto_test_tick_evento,
		h911_auto_test_lado
	])


func _h99_buscar_ventana_core2_rematador_poster_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	if rollback_core2_rematador_poster_serial <= rollback_core2_rematador_poster_serial_ya_probado:
		return {}
	if rollback_core2_rematador_poster_tick_hint < 0:
		return {}

	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < ROLLBACK_TEST_TICKS:
		return {}

	var idx_evento := -1
	for i in range(historial.size()):
		if int(historial[i].get("tick", -1)) == rollback_core2_rematador_poster_tick_hint:
			idx_evento = i
			break
	if idx_evento < 0:
		return {}

	# Un tick antes del snapshot post-póster: se restaura dentro de stage 4
	# antes de que exista una continuación reconstruible del await.
	var inicio_idx := maxi(0, idx_evento - 1)
	if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
		inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
	if inicio_idx < 0:
		return {}

	var ventana: Array[Dictionary] = []
	for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
		ventana.append(historial[k])

	return {
		"encontrado": true,
		"ventana": ventana,
		"serial": rollback_core2_rematador_poster_serial,
		"tick_evento": rollback_core2_rematador_poster_tick_hint,
		"lado": rollback_core2_rematador_poster_lado,
	}


func _h99_armar_rematador_poster_end_post_snapshot() -> void:
	if rollback_catchup_activo or replay_modo_activo or not versus_local_activo:
		return
	if rollback_core2_rematador_poster_serial <= rollback_core2_rematador_poster_serial_ya_probado:
		return
	if rollback_core2_rematador_poster_tick_hint < 0:
		return
	if h99_auto_test_armado:
		return

	# El snapshot que corresponde al tick_hint debe existir ya en el ring.
	var ultimo_tick_capturado := rollback_tick_logico - 1
	if ultimo_tick_capturado < rollback_core2_rematador_poster_tick_hint:
		return

	h99_auto_test_armado = true
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE II REMATADOR POSTER END AUTO — snapshot capturado; rollback próximo physics tick")


func _h98_buscar_ventana_core2_rematador_entry() -> Dictionary:
	if rollback_ring == null:
		return {}
	if not h98_auto_test_armado:
		return {}
	if h98_auto_test_tick_evento < 0:
		return {}
	if h98_auto_test_tick_evento <= rollback_core2_rematador_entry_tick_ya_probado:
		return {}

	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < ROLLBACK_TEST_TICKS:
		return {}

	var idx_evento := -1
	for i in range(historial.size()):
		if int(historial[i].get("tick", -1)) == h98_auto_test_tick_evento:
			idx_evento = i
			break
	if idx_evento < 0:
		return {}

	var inicio_idx := maxi(0, idx_evento - 1)
	if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
		inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
	if inicio_idx < 0:
		return {}

	var ventana: Array[Dictionary] = []
	for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
		ventana.append(historial[k])

	return {
		"encontrado": true,
		"ventana": ventana,
		"tick_evento": h98_auto_test_tick_evento,
		"lado": h98_auto_test_lado,
	}


func _h98_observar_rematador_entry_core2_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core2_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core2_secuencia_etapa"))

	if not h98_observador_inicializado:
		h98_etapa_prev_j1 = etapa_j1
		h98_etapa_prev_j2 = etapa_j2
		h98_observador_inicializado = true
		return

	var lado := ""
	if h98_etapa_prev_j1 == 3 and etapa_j1 == 4 \
	and int(kai.veces_fase_absoluta) == 2 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
	elif h98_etapa_prev_j2 == 3 and etapa_j2 == 4 \
	and int(rival.veces_fase_absoluta) == 2 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"

	h98_etapa_prev_j1 = etapa_j1
	h98_etapa_prev_j2 = etapa_j2

	if lado.is_empty() or h98_auto_test_armado:
		return

	h98_auto_test_armado = true
	h98_auto_test_tick_evento = rollback_tick_logico - 1
	h98_auto_test_lado = lado
	rollback_test_solicitado = true

	print("[91.00.00-H10.88] CORE II REMATADOR ENTRY AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h98_auto_test_tick_evento,
		h98_auto_test_lado
	])


func _h96_buscar_ventana_core2_first_beat_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	if not h96_auto_test_armado:
		return {}
	if h96_auto_test_tick_evento < 0:
		return {}
	if h96_auto_test_tick_evento <= rollback_core2_first_beat_end_tick_ya_probado:
		return {}

	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < ROLLBACK_TEST_TICKS:
		return {}

	var idx_evento := -1
	for i in range(historial.size()):
		if int(historial[i].get("tick", -1)) == h96_auto_test_tick_evento:
			idx_evento = i
			break
	if idx_evento < 0:
		return {}

	# Restaurar el snapshot inmediatamente anterior al fin del primer ataque.
	var inicio_idx := maxi(0, idx_evento - 1)
	if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
		inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
	if inicio_idx < 0:
		return {}

	var ventana: Array[Dictionary] = []
	for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
		ventana.append(historial[k])

	return {
		"encontrado": true,
		"ventana": ventana,
		"tick_evento": h96_auto_test_tick_evento,
		"lado": h96_auto_test_lado,
	}


func _h96_observar_first_beat_end_core2_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core2_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core2_secuencia_etapa"))
	var fase_j1 := int(kai.fase_ataque)
	var fase_j2 := int(rival.fase_ataque)

	if not h96_observador_inicializado:
		h96_etapa_prev_j1 = etapa_j1
		h96_etapa_prev_j2 = etapa_j2
		h96_fase_prev_j1 = fase_j1
		h96_fase_prev_j2 = fase_j2
		h96_observador_inicializado = true
		return

	# Stage 2 -> 3 significa que acaba de comenzar la ráfaga.
	if h96_etapa_prev_j1 == 2 and etapa_j1 == 3 \
	and int(kai.veces_fase_absoluta) == 2 \
	and bool(kai.en_secuencia_especial):
		h96_esperando_first_beat_j1 = true

	if h96_etapa_prev_j2 == 2 and etapa_j2 == 3 \
	and int(rival.veces_fase_absoluta) == 2 \
	and bool(rival.en_secuencia_especial):
		h96_esperando_first_beat_j2 = true

	var lado := ""

	# Primer ciclo de ataque terminado: fase no-cero -> NINGUNA.
	if h96_esperando_first_beat_j1 \
	and h96_fase_prev_j1 != 0 and fase_j1 == 0 \
	and etapa_j1 == 3 \
	and int(kai.veces_fase_absoluta) == 2 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
		h96_esperando_first_beat_j1 = false
	elif h96_esperando_first_beat_j2 \
	and h96_fase_prev_j2 != 0 and fase_j2 == 0 \
	and etapa_j2 == 3 \
	and int(rival.veces_fase_absoluta) == 2 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"
		h96_esperando_first_beat_j2 = false

	h96_etapa_prev_j1 = etapa_j1
	h96_etapa_prev_j2 = etapa_j2
	h96_fase_prev_j1 = fase_j1
	h96_fase_prev_j2 = fase_j2

	if lado.is_empty() or h96_auto_test_armado:
		return

	h96_auto_test_armado = true
	h96_auto_test_tick_evento = rollback_tick_logico - 1
	h96_auto_test_lado = lado
	rollback_test_solicitado = true

	print("[91.00.00-H10.88] CORE II FIRST BEAT END AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h96_auto_test_tick_evento,
		h96_auto_test_lado
	])


func _h94_buscar_ventana_core2_combo_entry() -> Dictionary:
	if rollback_ring == null:
		return {}

	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core2_combo_entry_tick_ya_probado:
			continue

		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})

		var lado := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})

			if int(fprev.get("veces_fase_absoluta", 0)) != 2:
				continue
			if int(fact.get("veces_fase_absoluta", 0)) != 2:
				continue
			if not bool(fprev.get("en_secuencia_especial", false)):
				continue
			if not bool(fact.get("en_secuencia_especial", false)):
				continue

			var etapa_prev := int(fprev.get("core2_secuencia_etapa", 0))
			var etapa_act := int(fact.get("core2_secuencia_etapa", 0))
			if etapa_prev == 2 and etapa_act == 3:
				lado = "J1" if candidato == "j1" else "J2"
				break

		if lado.is_empty():
			continue

		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}

		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])

		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
		}

	return {}


func _h94_observar_combo_entry_core2_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core2_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core2_secuencia_etapa"))

	if not h94_observador_inicializado:
		h94_core2_etapa_prev_j1 = etapa_j1
		h94_core2_etapa_prev_j2 = etapa_j2
		h94_observador_inicializado = true
		return

	var lado := ""
	if h94_core2_etapa_prev_j1 == 2 and etapa_j1 == 3 \
	and int(kai.veces_fase_absoluta) == 2 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
	elif h94_core2_etapa_prev_j2 == 2 and etapa_j2 == 3 \
	and int(rival.veces_fase_absoluta) == 2 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"

	h94_core2_etapa_prev_j1 = etapa_j1
	h94_core2_etapa_prev_j2 = etapa_j2

	if lado.is_empty() or h94_auto_test_armado:
		return

	h94_auto_test_armado = true
	h94_auto_test_tick_evento = rollback_tick_logico - 1
	h94_auto_test_lado = lado
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE II COMBO ENTRY AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h94_auto_test_tick_evento,
		h94_auto_test_lado
	])


func _h92_observar_fin_recarga_core2_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var rec_j1 := bool(kai.en_pose_recarga)
	var rec_j2 := bool(rival.en_pose_recarga)

	if not h92_recarga_observador_inicializado:
		h92_recarga_prev_j1 = rec_j1
		h92_recarga_prev_j2 = rec_j2
		h92_recarga_observador_inicializado = true
		return

	var evento_lado := ""

	# En este punto _rollback_registrar_inicio_tick() ya agregó el snapshot
	# actual y aumentó rollback_tick_logico. Por eso el tick recién capturado
	# es rollback_tick_logico - 1.
	if h92_recarga_prev_j1 and not rec_j1 \
	and int(kai.veces_fase_absoluta) == 2 \
	and bool(kai.en_secuencia_especial):
		evento_lado = "J1"
	elif h92_recarga_prev_j2 and not rec_j2 \
	and int(rival.veces_fase_absoluta) == 2 \
	and bool(rival.en_secuencia_especial):
		evento_lado = "J2"

	h92_recarga_prev_j1 = rec_j1
	h92_recarga_prev_j2 = rec_j2

	if evento_lado.is_empty():
		return
	if h92_auto_test_armado:
		return

	h92_auto_test_armado = true
	h92_auto_test_tick_evento = rollback_tick_logico - 1
	h92_auto_test_lado = evento_lado
	rollback_test_solicitado = true

	print("[91.00.00-H10.88] CORE II RECARGA END AUTO MARCADO — tick=%d %s — rollback se ejecutará en próximo physics tick" % [
		h92_auto_test_tick_evento,
		h92_auto_test_lado
	])



func _h109_observar_fin_recarga_core3_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var rec_j1 := bool(kai.en_pose_recarga)
	var rec_j2 := bool(rival.en_pose_recarga)

	if not h109_recarga_observador_inicializado:
		h109_recarga_prev_j1 = rec_j1
		h109_recarga_prev_j2 = rec_j2
		h109_recarga_observador_inicializado = true
		return

	var lado := ""
	if h109_recarga_prev_j1 and not rec_j1 \
	and int(kai.veces_fase_absoluta) >= 3 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
	elif h109_recarga_prev_j2 and not rec_j2 \
	and int(rival.veces_fase_absoluta) >= 3 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"

	h109_recarga_prev_j1 = rec_j1
	h109_recarga_prev_j2 = rec_j2

	if lado.is_empty() or h109_auto_test_armado:
		return

	h109_auto_test_armado = true
	h109_auto_test_tick_evento = rollback_tick_logico - 1
	h109_auto_test_lado = lado
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE III RECARGA END AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h109_auto_test_tick_evento,
		h109_auto_test_lado
	])


func _h109_buscar_ventana_core3_recarga_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core3_recarga_end_tick_ya_probado:
			continue
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		var lado := ""
		var clave := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})
			var nivel_prev := int(fprev.get("veces_fase_absoluta", 0))
			var nivel_act := int(fact.get("veces_fase_absoluta", 0))
			var sec_prev := bool(fprev.get("en_secuencia_especial", false))
			var sec_act := bool(fact.get("en_secuencia_especial", false))
			var rec_prev := bool(fprev.get("en_pose_recarga", false))
			var rec_act := bool(fact.get("en_pose_recarga", false))
			if nivel_prev >= 3 and nivel_act >= 3 \
			and sec_prev and sec_act \
			and rec_prev and not rec_act:
				clave = candidato
				lado = "J1" if candidato == "j1" else "J2"
				break
		if lado.is_empty():
			continue

		# Ocho ticks terminando exactamente en el primer snapshot post-recarga.
		# Así el restore comienza dentro de la espera 1.55 y debe reconstruir el
		# cruce sin ayuda de un timer LIVE ya consumido.
		var inicio_idx := i - (ROLLBACK_TEST_TICKS - 1)
		if inicio_idx < 0:
			continue
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, i + 1):
			ventana.append(historial[k])
		if ventana.size() != ROLLBACK_TEST_TICKS:
			continue
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
			"clave": clave,
		}
	return {}

func _h1012_observar_approach_end_core3_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core3_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core3_secuencia_etapa"))

	if not h1012_approach_observador_inicializado:
		h1012_core3_etapa_prev_j1 = etapa_j1
		h1012_core3_etapa_prev_j2 = etapa_j2
		h1012_approach_observador_inicializado = true
		return

	var lado := ""
	if h1012_core3_etapa_prev_j1 == 2 and etapa_j1 == 3 \
	and int(kai.veces_fase_absoluta) >= 3 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
	elif h1012_core3_etapa_prev_j2 == 2 and etapa_j2 == 3 \
	and int(rival.veces_fase_absoluta) >= 3 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"

	h1012_core3_etapa_prev_j1 = etapa_j1
	h1012_core3_etapa_prev_j2 = etapa_j2

	if lado.is_empty() or h1012_auto_test_armado:
		return

	h1012_auto_test_armado = true
	h1012_auto_test_tick_evento = rollback_tick_logico - 1
	h1012_auto_test_lado = lado
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE III APPROACH END AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h1012_auto_test_tick_evento,
		h1012_auto_test_lado
	])


func _h1012_buscar_ventana_core3_approach_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core3_approach_end_tick_ya_probado:
			continue
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		var lado := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})
			if int(fprev.get("veces_fase_absoluta", 0)) < 3:
				continue
			if int(fact.get("veces_fase_absoluta", 0)) < 3:
				continue
			if not bool(fprev.get("en_secuencia_especial", false)):
				continue
			if not bool(fact.get("en_secuencia_especial", false)):
				continue
			var etapa_prev := int(fprev.get("core3_secuencia_etapa", 0))
			var etapa_act := int(fact.get("core3_secuencia_etapa", 0))
			if etapa_prev == 2 and etapa_act == 3:
				lado = "J1" if candidato == "j1" else "J2"
				break
		if lado.is_empty():
			continue

		# Igual que CORE II COMBO ENTRY: un tick antes del cruce y suficiente
		# historia posterior para observar el primer beat de la ráfaga.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
		}
	return {}


func _h1014_observar_first_beat_end_core3_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core3_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core3_secuencia_etapa"))

	if not h1014_first_beat_observador_inicializado:
		h1014_core3_etapa_prev_j1 = etapa_j1
		h1014_core3_etapa_prev_j2 = etapa_j2
		h1014_first_beat_observador_inicializado = true
		return

	var lado := ""
	if h1014_core3_etapa_prev_j1 == 3 and etapa_j1 == 4 \
	and int(kai.veces_fase_absoluta) >= 3 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
	elif h1014_core3_etapa_prev_j2 == 3 and etapa_j2 == 4 \
	and int(rival.veces_fase_absoluta) >= 3 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"

	h1014_core3_etapa_prev_j1 = etapa_j1
	h1014_core3_etapa_prev_j2 = etapa_j2

	if lado.is_empty() or h1014_auto_test_armado:
		return

	h1014_auto_test_armado = true
	h1014_auto_test_tick_evento = rollback_tick_logico - 1
	h1014_auto_test_lado = lado
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE III FIRST BEAT END AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h1014_auto_test_tick_evento,
		h1014_auto_test_lado
	])


func _h1014_buscar_ventana_core3_first_beat_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core3_first_beat_end_tick_ya_probado:
			continue
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		var lado := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})
			if int(fprev.get("veces_fase_absoluta", 0)) < 3:
				continue
			if int(fact.get("veces_fase_absoluta", 0)) < 3:
				continue
			if not bool(fprev.get("en_secuencia_especial", false)):
				continue
			if not bool(fact.get("en_secuencia_especial", false)):
				continue
			var etapa_prev := int(fprev.get("core3_secuencia_etapa", 0))
			var etapa_act := int(fact.get("core3_secuencia_etapa", 0))
			if etapa_prev == 3 and etapa_act == 4:
				lado = "J1" if candidato == "j1" else "J2"
				break
		if lado.is_empty():
			continue

		# Un tick antes del cruce + seis ticks posteriores: suficiente para
		# observar el arranque del segundo beat histórico sin ampliar alcance.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
		}
	return {}


func _h1016_observar_second_beat_end_core3_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core3_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core3_secuencia_etapa"))

	if not h1016_second_beat_observador_inicializado:
		h1016_core3_etapa_prev_j1 = etapa_j1
		h1016_core3_etapa_prev_j2 = etapa_j2
		h1016_second_beat_observador_inicializado = true
		return

	var lado := ""
	if h1016_core3_etapa_prev_j1 == 4 and etapa_j1 == 5 \
	and int(kai.veces_fase_absoluta) >= 3 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
	elif h1016_core3_etapa_prev_j2 == 4 and etapa_j2 == 5 \
	and int(rival.veces_fase_absoluta) >= 3 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"

	h1016_core3_etapa_prev_j1 = etapa_j1
	h1016_core3_etapa_prev_j2 = etapa_j2

	if lado.is_empty() or h1016_auto_test_armado:
		return

	h1016_auto_test_armado = true
	h1016_auto_test_tick_evento = rollback_tick_logico - 1
	h1016_auto_test_lado = lado
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE III SECOND BEAT END AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h1016_auto_test_tick_evento,
		h1016_auto_test_lado
	])


func _h1016_buscar_ventana_core3_second_beat_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core3_second_beat_end_tick_ya_probado:
			continue
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		var lado := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})
			if int(fprev.get("veces_fase_absoluta", 0)) < 3:
				continue
			if int(fact.get("veces_fase_absoluta", 0)) < 3:
				continue
			if not bool(fprev.get("en_secuencia_especial", false)):
				continue
			if not bool(fact.get("en_secuencia_especial", false)):
				continue
			var etapa_prev := int(fprev.get("core3_secuencia_etapa", 0))
			var etapa_act := int(fact.get("core3_secuencia_etapa", 0))
			if etapa_prev == 4 and etapa_act == 5:
				lado = "J1" if candidato == "j1" else "J2"
				break
		if lado.is_empty():
			continue

		# Un tick antes del cruce y seis posteriores: el objetivo es observar
		# únicamente la entrada al tercer beat físico snapshotable.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
		}
	return {}


func _h1019_observar_third_beat_end_core3_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core3_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core3_secuencia_etapa"))

	if not h1019_third_beat_observador_inicializado:
		h1019_core3_etapa_prev_j1 = etapa_j1
		h1019_core3_etapa_prev_j2 = etapa_j2
		h1019_third_beat_observador_inicializado = true
		return

	var lado := ""
	if h1019_core3_etapa_prev_j1 == 5 and etapa_j1 == 6 \
	and int(kai.veces_fase_absoluta) >= 3 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
	elif h1019_core3_etapa_prev_j2 == 5 and etapa_j2 == 6 \
	and int(rival.veces_fase_absoluta) >= 3 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"

	h1019_core3_etapa_prev_j1 = etapa_j1
	h1019_core3_etapa_prev_j2 = etapa_j2

	if lado.is_empty() or h1019_auto_test_armado:
		return

	h1019_auto_test_armado = true
	h1019_auto_test_tick_evento = rollback_tick_logico - 1
	h1019_auto_test_lado = lado
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE III THIRD BEAT END AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h1019_auto_test_tick_evento,
		h1019_auto_test_lado
	])


func _h1019_buscar_ventana_core3_third_beat_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core3_third_beat_end_tick_ya_probado:
			continue
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		var lado := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})
			if int(fprev.get("veces_fase_absoluta", 0)) < 3:
				continue
			if int(fact.get("veces_fase_absoluta", 0)) < 3:
				continue
			if not bool(fprev.get("en_secuencia_especial", false)):
				continue
			if not bool(fact.get("en_secuencia_especial", false)):
				continue
			var etapa_prev := int(fprev.get("core3_secuencia_etapa", 0))
			var etapa_act := int(fact.get("core3_secuencia_etapa", 0))
			if etapa_prev == 5 and etapa_act == 6:
				lado = "J1" if candidato == "j1" else "J2"
				break
		if lado.is_empty():
			continue

		# Un tick antes del cruce y seis posteriores. El cuarto beat permanece
		# físico/snapshotable en H10.20: el cuarto beat ya no nace como Tween/coroutine.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
		}
	return {}


func _h1021_observar_fourth_beat_end_core3_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core3_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core3_secuencia_etapa"))

	if not h1021_fourth_beat_observador_inicializado:
		h1021_core3_etapa_prev_j1 = etapa_j1
		h1021_core3_etapa_prev_j2 = etapa_j2
		h1021_fourth_beat_observador_inicializado = true
		return

	var lado := ""
	if h1021_core3_etapa_prev_j1 == 6 and etapa_j1 == 7 \
	and int(kai.veces_fase_absoluta) >= 3 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
	elif h1021_core3_etapa_prev_j2 == 6 and etapa_j2 == 7 \
	and int(rival.veces_fase_absoluta) >= 3 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"

	h1021_core3_etapa_prev_j1 = etapa_j1
	h1021_core3_etapa_prev_j2 = etapa_j2

	if lado.is_empty() or h1021_auto_test_armado:
		return

	h1021_auto_test_armado = true
	h1021_auto_test_tick_evento = rollback_tick_logico - 1
	h1021_auto_test_lado = lado
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE III FOURTH BEAT END AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h1021_auto_test_tick_evento,
		h1021_auto_test_lado
	])


func _h1021_buscar_ventana_core3_fourth_beat_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core3_fourth_beat_end_tick_ya_probado:
			continue
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		var lado := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})
			if int(fprev.get("veces_fase_absoluta", 0)) < 3:
				continue
			if int(fact.get("veces_fase_absoluta", 0)) < 3:
				continue
			if not bool(fprev.get("en_secuencia_especial", false)):
				continue
			if not bool(fact.get("en_secuencia_especial", false)):
				continue
			var etapa_prev := int(fprev.get("core3_secuencia_etapa", 0))
			var etapa_act := int(fact.get("core3_secuencia_etapa", 0))
			if etapa_prev == 6 and etapa_act == 7:
				lado = "J1" if candidato == "j1" else "J2"
				break
		if lado.is_empty():
			continue

		# Un tick antes del cruce y seis posteriores. Stage 7 sigue siendo histórico
		# en H10.21: este test diagnostica exactamente la entrega al quinto beat async.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
		}
	return {}


func _h1023_observar_fifth_beat_end_core3_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core3_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core3_secuencia_etapa"))

	if not h1023_fifth_beat_observador_inicializado:
		h1023_core3_etapa_prev_j1 = etapa_j1
		h1023_core3_etapa_prev_j2 = etapa_j2
		h1023_fifth_beat_observador_inicializado = true
		return

	var lado := ""
	if h1023_core3_etapa_prev_j1 == 7 and etapa_j1 == 8 \
	and int(kai.veces_fase_absoluta) >= 3 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
	elif h1023_core3_etapa_prev_j2 == 7 and etapa_j2 == 8 \
	and int(rival.veces_fase_absoluta) >= 3 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"

	h1023_core3_etapa_prev_j1 = etapa_j1
	h1023_core3_etapa_prev_j2 = etapa_j2

	if lado.is_empty() or h1023_auto_test_armado:
		return

	h1023_auto_test_armado = true
	h1023_auto_test_tick_evento = rollback_tick_logico - 1
	h1023_auto_test_lado = lado
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE III FIFTH BEAT END AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h1023_auto_test_tick_evento,
		h1023_auto_test_lado
	])


func _h1023_buscar_ventana_core3_fifth_beat_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core3_fifth_beat_end_tick_ya_probado:
			continue
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		var lado := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})
			if int(fprev.get("veces_fase_absoluta", 0)) < 3:
				continue
			if int(fact.get("veces_fase_absoluta", 0)) < 3:
				continue
			if not bool(fprev.get("en_secuencia_especial", false)):
				continue
			if not bool(fact.get("en_secuencia_especial", false)):
				continue
			var etapa_prev := int(fprev.get("core3_secuencia_etapa", 0))
			var etapa_act := int(fact.get("core3_secuencia_etapa", 0))
			if etapa_prev == 7 and etapa_act == 8:
				lado = "J1" if candidato == "j1" else "J2"
				break
		if lado.is_empty():
			continue

		# Un tick antes del cruce y seis posteriores. Stage 8 es físico desde H10.24;
		# esta frontera queda congelada y sirve como regresión.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
		}
	return {}


func _h1025_observar_sixth_beat_end_core3_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core3_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core3_secuencia_etapa"))

	if not h1025_sixth_beat_observador_inicializado:
		h1025_core3_etapa_prev_j1 = etapa_j1
		h1025_core3_etapa_prev_j2 = etapa_j2
		h1025_sixth_beat_observador_inicializado = true
		return

	var lado := ""
	if h1025_core3_etapa_prev_j1 == 8 and etapa_j1 == 9 \
	and int(kai.veces_fase_absoluta) >= 3 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
	elif h1025_core3_etapa_prev_j2 == 8 and etapa_j2 == 9 \
	and int(rival.veces_fase_absoluta) >= 3 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"

	h1025_core3_etapa_prev_j1 = etapa_j1
	h1025_core3_etapa_prev_j2 = etapa_j2

	if lado.is_empty() or h1025_auto_test_armado:
		return

	h1025_auto_test_armado = true
	h1025_auto_test_tick_evento = rollback_tick_logico - 1
	h1025_auto_test_lado = lado
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE III SIXTH BEAT END AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h1025_auto_test_tick_evento,
		h1025_auto_test_lado
	])


func _h1025_buscar_ventana_core3_sixth_beat_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core3_sixth_beat_end_tick_ya_probado:
			continue
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		var lado := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})
			if int(fprev.get("veces_fase_absoluta", 0)) < 3:
				continue
			if int(fact.get("veces_fase_absoluta", 0)) < 3:
				continue
			if not bool(fprev.get("en_secuencia_especial", false)):
				continue
			if not bool(fact.get("en_secuencia_especial", false)):
				continue
			var etapa_prev := int(fprev.get("core3_secuencia_etapa", 0))
			var etapa_act := int(fact.get("core3_secuencia_etapa", 0))
			if etapa_prev == 8 and etapa_act == 9:
				lado = "J1" if candidato == "j1" else "J2"
				break
		if lado.is_empty():
			continue

		# Un tick antes del cruce y seis posteriores. En H10.26 stage 9 ya es el
		# séptimo beat físico: revalidamos exactamente la antigua frontera async.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
		}
	return {}


func _h1027_observar_seventh_beat_end_core3_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core3_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core3_secuencia_etapa"))

	if not h1027_seventh_beat_observador_inicializado:
		h1027_core3_etapa_prev_j1 = etapa_j1
		h1027_core3_etapa_prev_j2 = etapa_j2
		h1027_seventh_beat_observador_inicializado = true
		return

	var lado := ""
	if h1027_core3_etapa_prev_j1 == 9 and etapa_j1 == 10 \
	and int(kai.veces_fase_absoluta) >= 3 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
	elif h1027_core3_etapa_prev_j2 == 9 and etapa_j2 == 10 \
	and int(rival.veces_fase_absoluta) >= 3 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"

	h1027_core3_etapa_prev_j1 = etapa_j1
	h1027_core3_etapa_prev_j2 = etapa_j2

	if lado.is_empty() or h1027_auto_test_armado:
		return

	h1027_auto_test_armado = true
	h1027_auto_test_tick_evento = rollback_tick_logico - 1
	h1027_auto_test_lado = lado
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE III SEVENTH BEAT END AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h1027_auto_test_tick_evento,
		h1027_auto_test_lado
	])


func _h1027_buscar_ventana_core3_seventh_beat_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core3_seventh_beat_end_tick_ya_probado:
			continue
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		var lado := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})
			if int(fprev.get("veces_fase_absoluta", 0)) < 3:
				continue
			if int(fact.get("veces_fase_absoluta", 0)) < 3:
				continue
			if not bool(fprev.get("en_secuencia_especial", false)):
				continue
			if not bool(fact.get("en_secuencia_especial", false)):
				continue
			var etapa_prev := int(fprev.get("core3_secuencia_etapa", 0))
			var etapa_act := int(fact.get("core3_secuencia_etapa", 0))
			if etapa_prev == 9 and etapa_act == 10:
				lado = "J1" if candidato == "j1" else "J2"
				break
		if lado.is_empty():
			continue

		# Un tick antes del cruce y suficientes posteriores para completar 8 ticks.
		# Stage 10 es ahora el octavo beat físico snapshotable.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
		}
	return {}



func _h1057_observar_absolute_finisher_stage_trace_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core3_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core3_secuencia_etapa"))
	var escala_actual := float(Engine.time_scale)
	if not h1053_nineteenth_attack_observador_inicializado:
		h1053_core3_etapa_prev_j1 = etapa_j1
		h1053_core3_etapa_prev_j2 = etapa_j2
		h1053_nineteenth_attack_observador_inicializado = true
	if etapa_j1 != h1053_core3_etapa_prev_j1 and (etapa_j1 >= 17 or h1053_core3_etapa_prev_j1 >= 17):
		print("[91.00.00-H10.88] CORE III ABS TARGET TRACE — J1 stage %d->%d abs=%d sec=%s ronda=%s scale=%.4f" % [
			h1053_core3_etapa_prev_j1, etapa_j1, int(kai.veces_fase_absoluta), str(bool(kai.en_secuencia_especial)), str(ronda_activa), escala_actual
		])
	if etapa_j2 != h1053_core3_etapa_prev_j2 and (etapa_j2 >= 17 or h1053_core3_etapa_prev_j2 >= 17):
		print("[91.00.00-H10.88] CORE III ABS TARGET TRACE — J2 stage %d->%d abs=%d sec=%s ronda=%s scale=%.4f" % [
			h1053_core3_etapa_prev_j2, etapa_j2, int(rival.veces_fase_absoluta), str(bool(rival.en_secuencia_especial)), str(ronda_activa), escala_actual
		])
	h1053_core3_etapa_prev_j1 = etapa_j1
	h1053_core3_etapa_prev_j2 = etapa_j2

	var victoria_j1 := bool(kai.en_pose_victoria)
	var victoria_j2 := bool(rival.en_pose_victoria)
	if not h1063_victoria_observador_inicializado:
		h1063_victoria_prev_j1 = victoria_j1
		h1063_victoria_prev_j2 = victoria_j2
		h1063_victoria_observador_inicializado = true
		return

	# H10.68 — H10.66 ya certificó la transición de entrada. Ahora esa frontera
	# sólo ARMA el observador de HOLD; no rebobinamos todavía. Necesitamos nueve
	# snapshots consecutivos estables (8 ticks + presente histórico posterior).
	if false and not h1067_victory_hold_auto_test_armado and h1057_event_lado != "" and not ronda_activa:
		var victoria_cruzo := false
		var perdedor_ko := false
		if h1057_event_lado == "J1":
			victoria_cruzo = (not h1063_victoria_prev_j1) and victoria_j1
			perdedor_ko = bool(rival.esta_derrotado)
		else:
			victoria_cruzo = (not h1063_victoria_prev_j2) and victoria_j2
			perdedor_ko = bool(kai.esta_derrotado)
		if victoria_cruzo and perdedor_ko and absf(escala_actual - 1.0) <= 0.001:
			h1067_victory_hold_auto_test_armado = true
			h1067_victory_hold_lado = h1057_event_lado
			h1067_victory_hold_snapshots_estables = 1
			h1067_victory_hold_localizacion_espera_ticks = 0
			print("[91.00.00-H10.88] CORE III ABSOLUTE VICTORY HOLD ARMADO — %s; snapshot estable 1/%d; esperando ventana completa" % [
				h1067_victory_hold_lado, H1067_VICTORY_HOLD_SNAPSHOTS_NECESARIOS
			])
	elif h1067_victory_hold_auto_test_armado and not rollback_test_solicitado:
		var ganador_hold: Fighter = kai if h1067_victory_hold_lado == "J1" else rival
		var perdedor_hold: Fighter = rival if h1067_victory_hold_lado == "J1" else kai
		var hold_estable := is_instance_valid(ganador_hold) and is_instance_valid(perdedor_hold) \
			and not ronda_activa and absf(escala_actual - 1.0) <= 0.001 \
			and bool(ganador_hold.en_pose_victoria) and bool(perdedor_hold.esta_derrotado) \
			and not core3_absolute_victory_fsm_activo and core3_absolute_victory_lado == 0
		if not hold_estable:
			print("[91.00.00-H10.88] CORE III ABSOLUTE VICTORY HOLD CANCELADO — estado dejó de ser estable antes de completar la ventana")
			h1067_victory_hold_auto_test_armado = false
			h1067_victory_hold_lado = ""
			h1067_victory_hold_snapshots_estables = 0
		else:
			h1067_victory_hold_snapshots_estables += 1
			if h1067_victory_hold_snapshots_estables >= H1067_VICTORY_HOLD_SNAPSHOTS_NECESARIOS:
				rollback_test_solicitado = true
				print("[91.00.00-H10.88] CORE III ABSOLUTE VICTORY HOLD AUTO MARCADO — %s; %d snapshots estables; rollback próximo physics tick" % [
					h1067_victory_hold_lado, h1067_victory_hold_snapshots_estables
				])

	h1063_victoria_prev_j1 = victoria_j1
	h1063_victoria_prev_j2 = victoria_j2


func _h1069_observar_match_reset_post_snapshot() -> void:
	if not h1069_match_reset_auto_test_armado or rollback_test_solicitado:
		return
	# El callback LIVE ya ejecutó _reiniciar_partida(). Esperamos una ventana con
	# el primer snapshot post-reset + seis snapshots posteriores; junto al snapshot
	# pre-reset forman exactamente ocho ticks para el catch-up.
	var reset_estable := ronda_activa and rondas_kai == 0 and rondas_rival == 0 \
		and not kai.en_pose_victoria and not rival.en_pose_victoria \
		and not kai.esta_derrotado and not rival.esta_derrotado \
		and int(kai.veces_fase_absoluta) == 0 and int(rival.veces_fase_absoluta) == 0
	if not reset_estable:
		return
	h1069_match_reset_post_snapshots += 1
	if h1069_match_reset_post_snapshots >= H1069_MATCH_RESET_POST_SNAPSHOTS_NECESARIOS:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE III ABSOLUTE MATCH RESET ENTRY AUTO MARCADO — %s; %d snapshots post-reset; rollback próximo physics tick" % [
			h1069_match_reset_lado, h1069_match_reset_post_snapshots
		])


func _h1069_buscar_ventana_core3_absolute_match_reset_entry() -> Dictionary:
	if rollback_ring == null or not h1069_match_reset_auto_test_armado:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < ROLLBACK_TEST_TICKS:
		return {}
	var ganador_clave := "j1" if h1069_match_reset_lado == "J1" else "j2"
	var perdedor_clave := "j2" if h1069_match_reset_lado == "J1" else "j1"
	for i in range(historial.size() - 1, 0, -1):
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		if previo.is_empty() or actual.is_empty():
			continue
		var ganador_prev: Dictionary = previo.get(ganador_clave, {})
		var perdedor_prev: Dictionary = previo.get(perdedor_clave, {})
		var ganador_act: Dictionary = actual.get(ganador_clave, {})
		var perdedor_act: Dictionary = actual.get(perdedor_clave, {})
		var prev_rondas_g := int(previo.get("rondas_j1" if h1069_match_reset_lado == "J1" else "rondas_j2", 0))
		var borde := not bool(previo.get("ronda_activa", true)) \
			and prev_rondas_g == 3 \
			and bool(ganador_prev.get("en_pose_victoria", false)) \
			and bool(perdedor_prev.get("esta_derrotado", false)) \
			and bool(actual.get("ronda_activa", false)) \
			and int(actual.get("rondas_j1", -1)) == 0 and int(actual.get("rondas_j2", -1)) == 0 \
			and not bool(ganador_act.get("en_pose_victoria", true)) \
			and not bool(perdedor_act.get("esta_derrotado", true)) \
			and int(ganador_act.get("veces_fase_absoluta", -1)) == 0 \
			and int(perdedor_act.get("veces_fase_absoluta", -1)) == 0
		if not borde:
			continue
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core3_absolute_match_reset_tick_ya_probado:
			continue
		var inicio_idx := i - 1
		if inicio_idx < 0 or inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			continue
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"lado": h1069_match_reset_lado,
			"tick_evento": tick_evt,
			"tick_inicio": int(ventana[0].get("tick", -1)),
			"tick_final": int(ventana[ventana.size() - 1].get("tick", -1)),
		}
	return {}


func _h1067_buscar_ventana_core3_absolute_victory_hold() -> Dictionary:
	if rollback_ring == null or not h1067_victory_hold_auto_test_armado:
		return {}
	if rollback_ring.total() < H1067_VICTORY_HOLD_SNAPSHOTS_NECESARIOS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(H1067_VICTORY_HOLD_SNAPSHOTS_NECESARIOS)
	if historial.size() < H1067_VICTORY_HOLD_SNAPSHOTS_NECESARIOS:
		return {}
	var ganador_clave := "j1" if h1067_victory_hold_lado == "J1" else "j2"
	var perdedor_clave := "j2" if h1067_victory_hold_lado == "J1" else "j1"
	for entrada in historial:
		var snap: Dictionary = entrada.get("snapshot", {})
		if snap.is_empty() or bool(snap.get("ronda_activa", true)):
			return {}
		if absf(float(snap.get("time_scale", 1.0)) - 1.0) > 0.001:
			return {}
		if bool(snap.get("core3_absolute_victory_fsm_activo", false)):
			return {}
		if int(snap.get("core3_absolute_victory_lado", 0)) != 0:
			return {}
		if int(snap.get("core3_absolute_reveal_lado", 0)) != 0 or int(snap.get("core3_absolute_ko_lado", 0)) != 0:
			return {}
		var ganador: Dictionary = snap.get(ganador_clave, {})
		var perdedor: Dictionary = snap.get(perdedor_clave, {})
		if not bool(ganador.get("en_pose_victoria", false)) or not bool(perdedor.get("esta_derrotado", false)):
			return {}
		if h1067_victory_hold_lado == "J1":
			if int(snap.get("rondas_j1", 0)) != 3 or int(snap.get("rondas_j2", 0)) != 0:
				return {}
		else:
			if int(snap.get("rondas_j2", 0)) != 3 or int(snap.get("rondas_j1", 0)) != 0:
				return {}

	var ultimo_tick := int(historial[historial.size() - 1].get("tick", -1))
	if ultimo_tick <= rollback_core3_absolute_victory_hold_tick_ya_probado:
		return {}
	var ventana: Array[Dictionary] = []
	for i in range(ROLLBACK_TEST_TICKS):
		ventana.append(historial[i])
	return {
		"encontrado": true,
		"ventana": ventana,
		"tick_inicio": int(historial[0].get("tick", -1)),
		"tick_final": ultimo_tick,
		"lado": h1067_victory_hold_lado,
	}


func _h1057_buscar_ventana_core3_absolute_finisher_entry() -> Dictionary:
	if rollback_ring == null or not h1057_auto_test_armado:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt != h1057_event_tick_hint:
			continue
		if tick_evt <= rollback_core3_absolute_victory_entry_tick_ya_probado:
			continue

		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		if bool(previo.get("ronda_activa", true)) or bool(actual.get("ronda_activa", true)):
			return {}
		if absf(float(previo.get("time_scale", 1.0)) - 0.42) > 0.001 \
		or absf(float(actual.get("time_scale", 1.0)) - 1.0) > 0.001:
			return {}

		var ganador_clave := "j1" if h1057_event_lado == "J1" else "j2"
		var perdedor_clave := "j2" if h1057_event_lado == "J1" else "j1"
		var ganador_prev: Dictionary = previo.get(ganador_clave, {})
		var ganador_act: Dictionary = actual.get(ganador_clave, {})
		var perdedor_prev: Dictionary = previo.get(perdedor_clave, {})
		var perdedor_act: Dictionary = actual.get(perdedor_clave, {})
		if int(ganador_prev.get("veces_fase_absoluta", 0)) < 3 \
		or int(ganador_act.get("veces_fase_absoluta", 0)) < 3:
			return {}
		if bool(ganador_prev.get("en_pose_victoria", false)):
			return {}
		if not bool(ganador_act.get("en_pose_victoria", false)):
			return {}
		if not bool(perdedor_prev.get("esta_derrotado", false)) \
		or not bool(perdedor_act.get("esta_derrotado", false)):
			return {}

		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": h1057_event_lado,
		}
	return {}


func _h1053_observar_nineteenth_beat_attack_start_core3_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core3_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core3_secuencia_etapa"))
	var fase_j1 := int(kai.get("fase_ataque"))
	var fase_j2 := int(rival.get("fase_ataque"))

	if not h1053_nineteenth_attack_observador_inicializado:
		h1053_core3_etapa_prev_j1 = etapa_j1
		h1053_core3_etapa_prev_j2 = etapa_j2
		h1053_fase_prev_j1 = fase_j1
		h1053_fase_prev_j2 = fase_j2
		h1053_nineteenth_attack_observador_inicializado = true
		return

	# H10.56 — traza pasiva de las últimas fronteras físicas. No altera estado.
	if etapa_j1 != h1053_core3_etapa_prev_j1 and (etapa_j1 >= 17 or h1053_core3_etapa_prev_j1 >= 17):
		print("[91.00.00-H10.88] CORE III TARGET TRACE — J1 stage %d->%d fase=%d abs=%d sec=%s" % [
			h1053_core3_etapa_prev_j1, etapa_j1, fase_j1, int(kai.veces_fase_absoluta), str(bool(kai.en_secuencia_especial))
		])
	if etapa_j2 != h1053_core3_etapa_prev_j2 and (etapa_j2 >= 17 or h1053_core3_etapa_prev_j2 >= 17):
		print("[91.00.00-H10.88] CORE III TARGET TRACE — J2 stage %d->%d fase=%d abs=%d sec=%s" % [
			h1053_core3_etapa_prev_j2, etapa_j2, fase_j2, int(rival.veces_fase_absoluta), str(bool(rival.en_secuencia_especial))
		])

	# H10.54 — Main captura antes de Fighter. Si beat 19 ya está a distancia,
	# Fighter puede hacer stage 20->21 y arrancar el ataque en el mismo physics tick.
	# En ese caso el snapshot siguiente ya ve stage 21 + fase activa y nunca existe
	# un snapshot Main intermedio con stage 21 + fase 0. Capturamos ambas variantes:
	#   A) entrada a stage 21 con fase ya activa;
	#   B) entrada a stage 21 con fase 0 y transición 0->ataque en un tick posterior.
	var lado := ""
	if h1053_core3_etapa_prev_j1 != 21 and etapa_j1 == 21 \
	and int(kai.veces_fase_absoluta) >= 3 and bool(kai.en_secuencia_especial):
		if fase_j1 != 0:
			lado = "J1"
			h1053_esperando_primer_ataque_j1 = false
		else:
			h1053_esperando_primer_ataque_j1 = true
	if h1053_core3_etapa_prev_j2 != 21 and etapa_j2 == 21 \
	and int(rival.veces_fase_absoluta) >= 3 and bool(rival.en_secuencia_especial):
		if fase_j2 != 0 and lado.is_empty():
			lado = "J2"
			h1053_esperando_primer_ataque_j2 = false
		else:
			h1053_esperando_primer_ataque_j2 = true

	if lado.is_empty() and h1053_esperando_primer_ataque_j1 and etapa_j1 == 21 \
	and h1053_fase_prev_j1 == 0 and fase_j1 != 0 \
	and int(kai.veces_fase_absoluta) >= 3 and bool(kai.en_secuencia_especial):
		lado = "J1"
		h1053_esperando_primer_ataque_j1 = false
	elif lado.is_empty() and h1053_esperando_primer_ataque_j2 and etapa_j2 == 21 \
	and h1053_fase_prev_j2 == 0 and fase_j2 != 0 \
	and int(rival.veces_fase_absoluta) >= 3 and bool(rival.en_secuencia_especial):
		lado = "J2"
		h1053_esperando_primer_ataque_j2 = false

	# Si stage 21 terminó sin capturar, no arrastramos el armamento a otra secuencia.
	if etapa_j1 != 21 and h1053_core3_etapa_prev_j1 == 21:
		h1053_esperando_primer_ataque_j1 = false
	if etapa_j2 != 21 and h1053_core3_etapa_prev_j2 == 21:
		h1053_esperando_primer_ataque_j2 = false

	h1053_core3_etapa_prev_j1 = etapa_j1
	h1053_core3_etapa_prev_j2 = etapa_j2
	h1053_fase_prev_j1 = fase_j1
	h1053_fase_prev_j2 = fase_j2

	if lado.is_empty() or h1053_auto_test_armado:
		return

	h1053_auto_test_armado = true
	h1053_auto_test_tick_evento = rollback_tick_logico - 1
	h1053_auto_test_lado = lado
	h1053_localizacion_espera_ticks = 0
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE III NINETEENTH BEAT ATTACK START AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h1053_auto_test_tick_evento,
		h1053_auto_test_lado
	])


func _h1053_buscar_ventana_core3_nineteenth_beat_attack_start() -> Dictionary:
	if rollback_ring == null or not h1053_auto_test_armado:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt != h1053_auto_test_tick_evento:
			continue
		if tick_evt <= rollback_core3_nineteenth_beat_attack_start_tick_ya_probado:
			continue
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		var lado := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})
			if int(fprev.get("veces_fase_absoluta", 0)) < 3 or int(fact.get("veces_fase_absoluta", 0)) < 3:
				continue
			if not bool(fprev.get("en_secuencia_especial", false)) or not bool(fact.get("en_secuencia_especial", false)):
				continue
			var etapa_prev := int(fprev.get("core3_secuencia_etapa", 0))
			var etapa_act := int(fact.get("core3_secuencia_etapa", 0))
			var fase_prev := int(fprev.get("fase_ataque", 0))
			var fase_act := int(fact.get("fase_ataque", 0))
			# Caso A: Fighter entra 20->21 y arranca el beat 19 en el mismo callback.
			var entrada_con_ataque_activo := etapa_prev != 21 and etapa_act == 21 and fase_act != 0
			# Caso B: stage 21 ya estaba visible y el ataque empieza después.
			var transicion_dentro_stage21 := etapa_prev == 21 and etapa_act == 21 and fase_prev == 0 and fase_act != 0
			if entrada_con_ataque_activo or transicion_dentro_stage21:
				lado = "J1" if candidato == "j1" else "J2"
				break
		if lado.is_empty():
			return {}

		# Restauramos un tick antes del primer ataque histórico. Esto prueba el final
		# del acercamiento async del beat 19 y su entrega al ataque sin inventar stage 22.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
		}
	return {}


func _h1051_observar_eighteenth_beat_end_core3_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core3_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core3_secuencia_etapa"))

	if not h1051_eighteenth_beat_observador_inicializado:
		h1051_core3_etapa_prev_j1 = etapa_j1
		h1051_core3_etapa_prev_j2 = etapa_j2
		h1051_eighteenth_beat_observador_inicializado = true
		return

	var lado := ""
	if h1051_core3_etapa_prev_j1 == 20 and etapa_j1 == 21 \
	and int(kai.veces_fase_absoluta) >= 3 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
	elif h1051_core3_etapa_prev_j2 == 20 and etapa_j2 == 21 \
	and int(rival.veces_fase_absoluta) >= 3 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"

	h1051_core3_etapa_prev_j1 = etapa_j1
	h1051_core3_etapa_prev_j2 = etapa_j2

	if lado.is_empty() or h1051_auto_test_armado:
		return

	h1051_auto_test_armado = true
	h1051_auto_test_tick_evento = rollback_tick_logico - 1
	h1051_auto_test_lado = lado
	h1051_localizacion_espera_ticks = 0
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE III EIGHTEENTH BEAT END AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h1051_auto_test_tick_evento,
		h1051_auto_test_lado
	])


func _h1051_buscar_ventana_core3_eighteenth_beat_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core3_eighteenth_beat_end_tick_ya_probado:
			continue
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		var lado := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})
			if int(fprev.get("veces_fase_absoluta", 0)) < 3:
				continue
			if int(fact.get("veces_fase_absoluta", 0)) < 3:
				continue
			if not bool(fprev.get("en_secuencia_especial", false)):
				continue
			if not bool(fact.get("en_secuencia_especial", false)):
				continue
			var etapa_prev := int(fprev.get("core3_secuencia_etapa", 0))
			var etapa_act := int(fact.get("core3_secuencia_etapa", 0))
			if etapa_prev == 20 and etapa_act == 21:
				lado = "J1" if candidato == "j1" else "J2"
				break
		if lado.is_empty():
			continue

		# Restauramos un tick antes del cruce 20->21. Los 8 ticks siguientes
		# diagnostican la entrega del beat 18 físico al beat 19 histórico.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
		}
	return {}

func _h1028_observar_eighth_beat_end_core3_post_snapshot() -> void:
	if not versus_local_activo or replay_modo_activo or rollback_catchup_activo:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return

	var etapa_j1 := int(kai.get("core3_secuencia_etapa"))
	var etapa_j2 := int(rival.get("core3_secuencia_etapa"))

	if not h1028_eighth_beat_observador_inicializado:
		h1028_core3_etapa_prev_j1 = etapa_j1
		h1028_core3_etapa_prev_j2 = etapa_j2
		h1028_eighth_beat_observador_inicializado = true
		return

	var lado := ""
	if h1028_core3_etapa_prev_j1 == 10 and etapa_j1 == 11 \
	and int(kai.veces_fase_absoluta) >= 3 \
	and bool(kai.en_secuencia_especial):
		lado = "J1"
	elif h1028_core3_etapa_prev_j2 == 10 and etapa_j2 == 11 \
	and int(rival.veces_fase_absoluta) >= 3 \
	and bool(rival.en_secuencia_especial):
		lado = "J2"

	h1028_core3_etapa_prev_j1 = etapa_j1
	h1028_core3_etapa_prev_j2 = etapa_j2

	if lado.is_empty() or h1028_auto_test_armado:
		return

	h1028_auto_test_armado = true
	h1028_auto_test_tick_evento = rollback_tick_logico - 1
	h1028_auto_test_lado = lado
	h1029_localizacion_espera_ticks = 0
	rollback_test_solicitado = true
	print("[91.00.00-H10.88] CORE III EIGHTH BEAT END AUTO MARCADO — tick=%d %s — rollback próximo physics tick" % [
		h1028_auto_test_tick_evento,
		h1028_auto_test_lado
	])


func _h1028_buscar_ventana_core3_eighth_beat_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core3_eighth_beat_end_tick_ya_probado:
			continue
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})
		var lado := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})
			if int(fprev.get("veces_fase_absoluta", 0)) < 3:
				continue
			if int(fact.get("veces_fase_absoluta", 0)) < 3:
				continue
			if not bool(fprev.get("en_secuencia_especial", false)):
				continue
			if not bool(fact.get("en_secuencia_especial", false)):
				continue
			var etapa_prev := int(fprev.get("core3_secuencia_etapa", 0))
			var etapa_act := int(fact.get("core3_secuencia_etapa", 0))
			if etapa_prev == 10 and etapa_act == 11:
				lado = "J1" if candidato == "j1" else "J2"
				break
		if lado.is_empty():
			continue

		# Restauramos un tick antes del cruce 10->11. Los 8 ticks siguientes
		# prueban la entrega al noveno beat histórico sin modificar gameplay.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
		}
	return {}


func _h91_buscar_ventana_core2_recarga_end() -> Dictionary:
	if rollback_ring == null:
		return {}

	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core2_recarga_end_tick_ya_probado:
			continue

		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})

		var lado := ""
		var clave := ""
		for candidato in ["j1", "j2"]:
			var fprev: Dictionary = previo.get(candidato, {})
			var fact: Dictionary = actual.get(candidato, {})

			var nivel_prev := int(fprev.get("veces_fase_absoluta", 0))
			var nivel_act := int(fact.get("veces_fase_absoluta", 0))
			var sec_prev := bool(fprev.get("en_secuencia_especial", false))
			var sec_act := bool(fact.get("en_secuencia_especial", false))
			var rec_prev := bool(fprev.get("en_pose_recarga", false))
			var rec_act := bool(fact.get("en_pose_recarga", false))

			if nivel_prev == 2 and nivel_act == 2 \
			and sec_prev and sec_act \
			and rec_prev and not rec_act:
				clave = candidato
				lado = "J1" if candidato == "j1" else "J2"
				break

		if lado.is_empty():
			continue

		# Re-simular desde el tick inmediatamente anterior a la transición.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}

		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])

		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
			"clave": clave,
		}

	return {}


func _h91_core2_recarga_termino_live() -> bool:
	for personaje in [kai, rival]:
		if not is_instance_valid(personaje):
			continue
		if int(personaje.veces_fase_absoluta) == 2 \
		and bool(personaje.en_secuencia_especial) \
		and not bool(personaje.en_pose_recarga):
			return true
	return false


func _h101_core3_post_ticks_disponibles() -> int:
	if rollback_ring == null or rollback_core3_event_tick_hint < 0:
		return -1
	var ultimo_tick := _h81_core1_ultimo_tick_ring()
	return maxi(-1, ultimo_tick - rollback_core3_event_tick_hint)


func _h10_buscar_ventana_core3_entry() -> Dictionary:
	if rollback_ring == null:
		return {}
	if rollback_core3_event_serial <= rollback_core3_event_serial_ya_probado:
		return {}
	if rollback_core3_event_tick_hint < 0:
		return {}

	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < ROLLBACK_TEST_TICKS:
		return {}

	var idx_evento := -1
	for i in range(historial.size()):
		if int(historial[i].get("tick", -1)) == rollback_core3_event_tick_hint:
			idx_evento = i
			break
	if idx_evento < 0:
		return {}

	# H10.1 — la ventana NO puede desplazarse hacia atrás.
	# Debe ser exactamente [evento-1 .. evento+6].
	if idx_evento <= 0:
		return {}
	var post_disponibles: int = historial.size() - 1 - idx_evento
	if post_disponibles < H101_CORE3_POST_TICKS_REQUERIDOS:
		return {}

	var inicio_idx := idx_evento - 1
	if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
		return {}

	var ventana: Array[Dictionary] = []
	for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
		ventana.append(historial[k])

	var contiene := false
	for entrada in ventana:
		if int(entrada.get("tick", -1)) == rollback_core3_event_tick_hint:
			contiene = true
			break
	if not contiene:
		return {}

	return {
		"encontrado": true,
		"ventana": ventana,
		"serial": rollback_core3_event_serial,
		"tick_evento": rollback_core3_event_tick_hint,
		"lado": rollback_core3_event_lado,
	}


func _h9_buscar_ventana_core2_entry() -> Dictionary:
	if rollback_ring == null:
		return {}
	if rollback_core2_event_serial <= rollback_core2_event_serial_ya_probado:
		return {}
	if rollback_core2_event_tick_hint < 0:
		return {}

	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < ROLLBACK_TEST_TICKS:
		return {}

	var idx_evento := -1
	for i in range(historial.size()):
		if int(historial[i].get("tick", -1)) == rollback_core2_event_tick_hint:
			idx_evento = i
			break
	if idx_evento < 0:
		return {}

	# Un tick antes para atravesar 1 -> 2 y el arranque de recarga.
	var inicio_idx := maxi(0, idx_evento - 1)
	if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
		inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
	if inicio_idx < 0:
		return {}

	var ventana: Array[Dictionary] = []
	for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
		ventana.append(historial[k])

	var contiene := false
	for entrada in ventana:
		if int(entrada.get("tick", -1)) == rollback_core2_event_tick_hint:
			contiene = true
			break
	if not contiene:
		return {}

	return {
		"encontrado": true,
		"ventana": ventana,
		"serial": rollback_core2_event_serial,
		"tick_evento": rollback_core2_event_tick_hint,
		"lado": rollback_core2_event_lado,
	}


func _h86_core1_etapa(snapshot: Dictionary, lado: String) -> int:
	var f: Dictionary = snapshot.get(lado, {})
	return int(f.get("core1_secuencia_etapa", 0))


func _h86_core1_en_secuencia(snapshot: Dictionary, lado: String) -> bool:
	var f: Dictionary = snapshot.get(lado, {})
	return bool(f.get("en_secuencia_especial", false))


func _h86_core1_nivel(snapshot: Dictionary, lado: String) -> int:
	var f: Dictionary = snapshot.get(lado, {})
	return int(f.get("veces_fase_absoluta", 0))


func _h86_buscar_ventana_core1_poster_end() -> Dictionary:
	if rollback_ring == null:
		return {}

	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	# Buscar la transición histórica más reciente:
	#   POSTER (2) + en_secuencia=true
	#        ->
	#   INACTIVO (0) + en_secuencia=false
	for i in range(historial.size() - 1, 0, -1):
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= rollback_core1_poster_end_tick_ya_probado:
			continue

		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var actual: Dictionary = historial[i].get("snapshot", {})

		var lado := ""
		var clave := ""
		for candidato in ["j1", "j2"]:
			var nivel_prev := _h86_core1_nivel(previo, candidato)
			var nivel_act := _h86_core1_nivel(actual, candidato)
			var etapa_prev := _h86_core1_etapa(previo, candidato)
			var etapa_act := _h86_core1_etapa(actual, candidato)
			var sec_prev := _h86_core1_en_secuencia(previo, candidato)
			var sec_act := _h86_core1_en_secuencia(actual, candidato)

			if nivel_prev == 1 and nivel_act == 1 \
			and etapa_prev == 2 and etapa_act == 0 \
			and sec_prev and not sec_act:
				clave = candidato
				lado = "J1" if candidato == "j1" else "J2"
				break

		if lado.is_empty():
			continue

		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		if inicio_idx < 0:
			return {}

		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])

		var contiene := false
		for entrada in ventana:
			if int(entrada.get("tick", -1)) == tick_evt:
				contiene = true
				break
		if not contiene:
			continue

		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": tick_evt,
			"lado": lado,
			"clave": clave,
		}

	return {}


func _h84_buscar_ventana_core1_target_end() -> Dictionary:
	if rollback_ring == null:
		return {}
	if rollback_core1_target_end_serial <= rollback_core1_target_end_serial_ya_probado:
		return {}
	if rollback_core1_target_end_tick_hint < 0:
		return {}

	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < ROLLBACK_TEST_TICKS:
		return {}

	var idx_evento := -1
	for i in range(historial.size()):
		if int(historial[i].get("tick", -1)) == rollback_core1_target_end_tick_hint:
			idx_evento = i
			break
	if idx_evento < 0:
		return {}

	# El tick_hint es el snapshot del tick siguiente al emit de la señal:
	# arrancamos un tick antes para cruzar exactamente activo -> finalizado.
	var inicio_idx := maxi(0, idx_evento - 1)
	if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
		inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
	if inicio_idx < 0:
		return {}

	var ventana: Array[Dictionary] = []
	for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
		ventana.append(historial[k])

	var contiene := false
	for entrada in ventana:
		if int(entrada.get("tick", -1)) == rollback_core1_target_end_tick_hint:
			contiene = true
			break
	if not contiene:
		return {}

	return {
		"encontrado": true,
		"ventana": ventana,
		"serial": rollback_core1_target_end_serial,
		"tick_evento": rollback_core1_target_end_tick_hint,
		"lado": rollback_core1_target_end_lado,
	}


func _h81_core1_ultimo_tick_ring() -> int:
	if rollback_ring == null or rollback_ring.entradas.is_empty():
		return -1
	return int((rollback_ring.entradas[-1] as Dictionary).get("tick", -1))


func _h81_buscar_ventana_core1() -> Dictionary:
	if rollback_ring == null:
		return {}
	if rollback_core1_event_serial <= rollback_core1_event_serial_ya_probado:
		return {}
	if rollback_core1_event_tick_hint < 0:
		return {}

	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < ROLLBACK_TEST_TICKS:
		return {}

	var idx_evento := -1
	for i in range(historial.size()):
		if int(historial[i].get("tick", -1)) == rollback_core1_event_tick_hint:
			idx_evento = i
			break

	if idx_evento < 0:
		return {}

	# Necesitamos una ventana de 8 ticks que atraviese la activación.
	# Preferimos arrancar un tick antes; si el evento está muy cerca del presente,
	# desplazamos la ventana hacia atrás sin perder el evento.
	var inicio_idx := maxi(0, idx_evento - 1)
	if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
		inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
	if inicio_idx < 0:
		return {}

	var ventana: Array[Dictionary] = []
	for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
		ventana.append(historial[k])

	var contiene_evento := false
	for entrada in ventana:
		if int(entrada.get("tick", -1)) == rollback_core1_event_tick_hint:
			contiene_evento = true
			break
	if not contiene_evento:
		return {}

	return {
		"encontrado": true,
		"ventana": ventana,
		"serial": rollback_core1_event_serial,
		"tick_evento": rollback_core1_event_tick_hint,
		"lado": rollback_core1_event_lado,
	}


func _h6_tactico_live() -> Object:
	return get_node_or_null("/root/PerfectBlock90_1")


func _h6_launcher_serial_live() -> int:
	var tactico := _h6_tactico_live()
	return 0 if tactico == null else int(tactico.get("_rollback_launcher_event_serial"))


func _h6_airhit_serial_live() -> int:
	var tactico := _h6_tactico_live()
	return 0 if tactico == null else int(tactico.get("_rollback_airhit_event_serial"))


func _h6_launcher_serial(snapshot: Dictionary) -> int:
	return int((snapshot.get("tactico", {}) as Dictionary).get("_rollback_launcher_event_serial", 0))


func _h6_airhit_serial(snapshot: Dictionary) -> int:
	return int((snapshot.get("tactico", {}) as Dictionary).get("_rollback_airhit_event_serial", 0))


func _h6_launcher_serial_ultimo_ring() -> int:
	if rollback_ring == null or rollback_ring.entradas.is_empty():
		return 0
	return _h6_launcher_serial((rollback_ring.entradas[-1] as Dictionary).get("snapshot", {}))


func _h6_airhit_serial_ultimo_ring() -> int:
	if rollback_ring == null or rollback_ring.entradas.is_empty():
		return 0
	return _h6_airhit_serial((rollback_ring.entradas[-1] as Dictionary).get("snapshot", {}))


func _h6_lado_desde_id(id: int) -> String:
	if is_instance_valid(kai) and id == kai.get_instance_id():
		return "J1"
	if is_instance_valid(rival) and id == rival.get_instance_id():
		return "J2"
	return "?"


func _h6_ventana_evento_por_serial(clave_serial: String, tick_ya_probado: int) -> Dictionary:
	if rollback_ring == null:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var prev_snap: Dictionary = historial[i - 1].get("snapshot", {})
		var evt_snap: Dictionary = historial[i].get("snapshot", {})
		var prev_t: Dictionary = prev_snap.get("tactico", {})
		var evt_t: Dictionary = evt_snap.get("tactico", {})
		var serial_prev := int(prev_t.get(clave_serial, 0))
		var serial_evt := int(evt_t.get(clave_serial, 0))
		if serial_evt <= serial_prev:
			continue

		# H6.1: el serial puede retroceder por rollback. El tick del ring es
		# monotónico y permite reconocer eventos nuevos incluso si el serial
		# histórico vuelve de 10 a 9, 8, etc.
		var tick_evt := int(historial[i].get("tick", -1))
		if tick_evt <= tick_ya_probado:
			continue

		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"serial": serial_evt,
			"tick_evento": tick_evt,
			"snapshot_evento": evt_snap,
		}
	return {}


func _h6_buscar_launcher() -> Dictionary:
	var r := _h6_ventana_evento_por_serial("_rollback_launcher_event_serial", rollback_launcher_tick_ya_probado)
	if r.is_empty():
		return r
	var t: Dictionary = (r.get("snapshot_evento", {}) as Dictionary).get("tactico", {})
	var aid := int(t.get("_rollback_launcher_event_attacker_id", -1))
	var did := int(t.get("_rollback_launcher_event_defender_id", -1))
	r["atacante_id"] = aid
	r["defensor_id"] = did
	r["lado"] = _h6_lado_desde_id(aid)
	return r


func _h6_buscar_airhit() -> Dictionary:
	var r := _h6_ventana_evento_por_serial("_rollback_airhit_event_serial", rollback_airhit_tick_ya_probado)
	if r.is_empty():
		return r
	var t: Dictionary = (r.get("snapshot_evento", {}) as Dictionary).get("tactico", {})
	var aid := int(t.get("_rollback_airhit_event_attacker_id", -1))
	var did := int(t.get("_rollback_airhit_event_defender_id", -1))
	r["atacante_id"] = aid
	r["defensor_id"] = did
	r["lado"] = _h6_lado_desde_id(aid)
	r["air_x"] = int(t.get("_rollback_airhit_event_count", 0))
	return r


func _h5_backdash_serial_live() -> int:
	var tactico := get_node_or_null("/root/PerfectBlock90_1")
	if tactico == null:
		return 0
	return int(tactico.get("_rollback_backdash_event_serial"))


func _h5_backdash_serial(snapshot: Dictionary) -> int:
	var tactico: Dictionary = snapshot.get("tactico", {})
	return int(tactico.get("_rollback_backdash_event_serial", 0))


func _h5_backdash_id(snapshot: Dictionary) -> int:
	var tactico: Dictionary = snapshot.get("tactico", {})
	return int(tactico.get("_rollback_backdash_event_fighter_id", -1))


func _h5_backdash_dir(snapshot: Dictionary) -> float:
	var tactico: Dictionary = snapshot.get("tactico", {})
	return float(tactico.get("_rollback_backdash_event_direccion", 0.0))


func _h5_backdash_serial_ultimo_ring() -> int:
	if rollback_ring == null or rollback_ring.entradas.is_empty():
		return 0
	var ultimo: Dictionary = rollback_ring.entradas[rollback_ring.entradas.size() - 1]
	return _h5_backdash_serial(ultimo.get("snapshot", {}))


func _h5_buscar_ventana_backdash() -> Dictionary:
	if rollback_ring == null:
		return {}

	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	for i in range(historial.size() - 1, 0, -1):
		var previo: Dictionary = historial[i - 1].get("snapshot", {})
		var evento: Dictionary = historial[i].get("snapshot", {})
		var serial_previo := _h5_backdash_serial(previo)
		var serial_evento := _h5_backdash_serial(evento)

		if serial_evento <= serial_previo:
			continue
		if serial_evento <= rollback_backdash_serial_ya_probado:
			continue

		var fighter_id := _h5_backdash_id(evento)
		var lado := "?"
		if is_instance_valid(kai) and fighter_id == kai.get_instance_id():
			lado = "J1"
		elif is_instance_valid(rival) and fighter_id == rival.get_instance_id():
			lado = "J2"

		# Empezamos un tick antes del sello. Así la re-simulación debe volver a
		# detectar el segundo toque, iniciar Back Dash y reproducir su movimiento.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS

		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])

		return {
			"encontrado": true,
			"ventana": ventana,
			"serial": serial_evento,
			"fighter_id": fighter_id,
			"lado": lado,
			"direccion": _h5_backdash_dir(evento),
			"tick_evento": int(historial[i].get("tick", -1)),
		}

	return {}


func _h1072_counter_disponible_snapshot(snapshot: Dictionary, fighter_id: int) -> bool:
	var tactico: Dictionary = snapshot.get("tactico", {})
	var disp: Dictionary = tactico.get("_counter_disponible", {})
	return bool(disp.get(fighter_id, false))


func _h1072_observar_perfect_post_snapshot() -> void:
	if rollback_ring == null or rollback_catchup_activo or rollback_comparacion_pendiente:
		return
	if rollback_test_solicitado:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	if rollback_ring.total() < 2:
		return

	var hist: Array[Dictionary] = rollback_ring.ventana_desde_el_final(mini(16, rollback_ring.total()))
	if hist.size() < 2:
		return
	var prev_entry: Dictionary = hist[hist.size() - 2]
	var evt_entry: Dictionary = hist[hist.size() - 1]
	var prev_snap: Dictionary = prev_entry.get("snapshot", {})
	var evt_snap: Dictionary = evt_entry.get("snapshot", {})
	var tick_evt := int(evt_entry.get("tick", -1))

	if not h1072_perfect_auto_armado:
		var id_j1 := kai.get_instance_id()
		var id_j2 := rival.get_instance_id()
		var j1_abre := (not _h1072_counter_disponible_snapshot(prev_snap, id_j1)) and _h1072_counter_disponible_snapshot(evt_snap, id_j1)
		var j2_abre := (not _h1072_counter_disponible_snapshot(prev_snap, id_j2)) and _h1072_counter_disponible_snapshot(evt_snap, id_j2)
		if not j1_abre and not j2_abre:
			return
		if tick_evt <= rollback_perfect_tick_ya_probado:
			return
		h1072_perfect_auto_armado = true
		h1072_perfect_tick_evento = tick_evt
		h1072_perfect_lado = "J1" if j1_abre else "J2"
		print("[91.00.00-H10.88] PERFECT BLOCK EVENT OBSERVADO — %s tick=%d; acumulando 7 snapshots post-evento" % [h1072_perfect_lado, tick_evt])
		return

	# Ventana: snapshot anterior al Perfect + 7 ticks posteriores; el snapshot
	# tick_evento+7 sirve como presente historico esperado tras los 8 subticks.
	var ultimo_tick := int(evt_entry.get("tick", -1))
	if ultimo_tick >= h1072_perfect_tick_evento + 7:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] PERFECT BLOCK AUTO MARCADO — %s tick=%d; rollback proximo physics tick" % [h1072_perfect_lado, h1072_perfect_tick_evento])


func _h1072_buscar_ventana_perfect_block() -> Dictionary:
	if rollback_ring == null or not h1072_perfect_auto_armado:
		return {}
	if h1072_perfect_tick_evento < 0 or h1072_perfect_tick_evento <= rollback_perfect_tick_ya_probado:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS + 1:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	var idx_evento := -1
	for i in range(historial.size()):
		if int(historial[i].get("tick", -1)) == h1072_perfect_tick_evento:
			idx_evento = i
			break
	if idx_evento <= 0:
		return {}
	var inicio_idx := idx_evento - 1
	# 8 subticks: [evento-1 .. evento+6], y necesitamos evento+7 como esperado.
	if inicio_idx + ROLLBACK_TEST_TICKS >= historial.size():
		return {}
	var ventana: Array[Dictionary] = []
	for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
		ventana.append(historial[k])
	return {
		"encontrado": true,
		"ventana": ventana,
		"lado": h1072_perfect_lado,
		"tick_evento": h1072_perfect_tick_evento,
	}


func _h1073_observar_launcher_post_snapshot() -> void:
	if rollback_ring == null or rollback_catchup_activo or rollback_comparacion_pendiente:
		return
	if rollback_test_solicitado:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	if rollback_ring.total() < 2:
		return

	var hist: Array[Dictionary] = rollback_ring.ventana_desde_el_final(mini(16, rollback_ring.total()))
	if hist.size() < 2:
		return
	var prev_entry: Dictionary = hist[hist.size() - 2]
	var evt_entry: Dictionary = hist[hist.size() - 1]
	var prev_snap: Dictionary = prev_entry.get("snapshot", {})
	var evt_snap: Dictionary = evt_entry.get("snapshot", {})
	var serial_prev := _h6_launcher_serial(prev_snap)
	var serial_evt := _h6_launcher_serial(evt_snap)
	var tick_evt := int(evt_entry.get("tick", -1))

	if not h1073_launcher_auto_armado:
		if serial_evt <= serial_prev:
			return
		if tick_evt <= rollback_launcher_tick_ya_probado:
			return
		var tactico: Dictionary = evt_snap.get("tactico", {})
		var atacante_id := int(tactico.get("_rollback_launcher_event_attacker_id", -1))
		h1073_launcher_auto_armado = true
		h1073_launcher_tick_evento = tick_evt
		h1073_launcher_lado = _h6_lado_desde_id(atacante_id)
		print("[91.00.00-H10.88] LAUNCHER EVENT OBSERVADO — serial=%d %s tick=%d; acumulando 7 snapshots post-evento" % [serial_evt, h1073_launcher_lado, tick_evt])
		return

	# Igual que Perfect: un snapshot anterior al evento + siete posteriores.
	# Esperamos evento+7 para disponer también del presente histórico esperado.
	var ultimo_tick := int(evt_entry.get("tick", -1))
	if ultimo_tick >= h1073_launcher_tick_evento + 7:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] LAUNCHER AUTO MARCADO — %s tick=%d; rollback próximo physics tick" % [h1073_launcher_lado, h1073_launcher_tick_evento])


func _h1076_observar_airx3_post_snapshot() -> void:
	if rollback_ring == null or rollback_catchup_activo or rollback_comparacion_pendiente:
		return
	if rollback_test_solicitado:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	if rollback_ring.total() < 2:
		return

	var hist: Array[Dictionary] = rollback_ring.ventana_desde_el_final(mini(16, rollback_ring.total()))
	if hist.size() < 2:
		return
	var prev_entry: Dictionary = hist[hist.size() - 2]
	var evt_entry: Dictionary = hist[hist.size() - 1]
	var prev_snap: Dictionary = prev_entry.get("snapshot", {})
	var evt_snap: Dictionary = evt_entry.get("snapshot", {})
	var serial_prev := _h6_airhit_serial(prev_snap)
	var serial_evt := _h6_airhit_serial(evt_snap)
	var tick_evt := int(evt_entry.get("tick", -1))

	if not h1076_airx3_auto_armado:
		if serial_evt <= serial_prev:
			return
		if tick_evt <= rollback_airhit_tick_ya_probado:
			return
		var tactico: Dictionary = evt_snap.get("tactico", {})
		var air_x := int(tactico.get("_rollback_airhit_event_count", 0))
		if air_x != 3:
			return
		var atacante_id := int(tactico.get("_rollback_airhit_event_attacker_id", -1))
		h1076_airx3_auto_armado = true
		h1076_airx3_tick_evento = tick_evt
		h1076_airx3_lado = _h6_lado_desde_id(atacante_id)
		print("[91.00.00-H10.88] AIR x3 EVENT OBSERVADO — serial=%d %s tick=%d; acumulando 7 snapshots post-evento" % [serial_evt, h1076_airx3_lado, tick_evt])
		return

	# Snapshot anterior al AIR x3 + siete posteriores; evento+7 es el presente
	# histórico esperado al terminar los 8 subticks.
	var ultimo_tick := int(evt_entry.get("tick", -1))
	if ultimo_tick >= h1076_airx3_tick_evento + 7:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] AIR x3 AUTO MARCADO — %s tick=%d; rollback próximo physics tick" % [h1076_airx3_lado, h1076_airx3_tick_evento])


func _h1077_observar_backdash_post_snapshot() -> void:
	if rollback_ring == null or rollback_catchup_activo or rollback_comparacion_pendiente:
		return
	if rollback_test_solicitado:
		return
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	if rollback_ring.total() < 2:
		return

	var hist: Array[Dictionary] = rollback_ring.ventana_desde_el_final(mini(16, rollback_ring.total()))
	if hist.size() < 2:
		return
	var prev_entry: Dictionary = hist[hist.size() - 2]
	var evt_entry: Dictionary = hist[hist.size() - 1]
	var prev_snap: Dictionary = prev_entry.get("snapshot", {})
	var evt_snap: Dictionary = evt_entry.get("snapshot", {})
	var serial_prev := _h5_backdash_serial(prev_snap)
	var serial_evt := _h5_backdash_serial(evt_snap)
	var tick_evt := int(evt_entry.get("tick", -1))

	if not h1077_backdash_auto_armado:
		if serial_evt <= serial_prev:
			return
		if serial_evt <= rollback_backdash_serial_ya_probado:
			return
		var fighter_id := _h5_backdash_id(evt_snap)
		var lado := "?"
		if fighter_id == kai.get_instance_id():
			lado = "J1"
		elif fighter_id == rival.get_instance_id():
			lado = "J2"
		h1077_backdash_auto_armado = true
		h1077_backdash_tick_evento = tick_evt
		h1077_backdash_lado = lado
		h1077_backdash_serial_evento = serial_evt
		h1077_backdash_direccion = _h5_backdash_dir(evt_snap)
		var dir_txt := "IZQUIERDA" if h1077_backdash_direccion < 0.0 else "DERECHA"
		print("[91.00.00-H10.88] BACKDASH EVENT OBSERVADO — serial=%d %s dir=%s tick=%d; acumulando 7 snapshots post-evento" % [serial_evt, lado, dir_txt, tick_evt])
		return

	# Un snapshot anterior al segundo toque + siete posteriores. evento+7 deja
	# disponible el presente histórico esperado después de 8 subticks.
	var ultimo_tick := int(evt_entry.get("tick", -1))
	if ultimo_tick >= h1077_backdash_tick_evento + 7:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] BACKDASH AUTO MARCADO — %s tick=%d; rollback próximo physics tick" % [h1077_backdash_lado, h1077_backdash_tick_evento])


func _h1078_estado_lado(snapshot: Dictionary, lado: String) -> Dictionary:
	return snapshot.get("j1" if lado == "J1" else "j2", {})


func _h1078_otro_estado(snapshot: Dictionary, lado: String) -> Dictionary:
	return snapshot.get("j2" if lado == "J1" else "j1", {})


func _h1078_es_forward_dash(snapshot: Dictionary, lado: String) -> bool:
	var yo: Dictionary = _h1078_estado_lado(snapshot, lado)
	var otro: Dictionary = _h1078_otro_estado(snapshot, lado)
	if yo.is_empty() or otro.is_empty():
		return false
	if not bool(yo.get("carrera_activa", false)):
		return false
	var dir := float(yo.get("carrera_direccion", 0.0))
	if absf(dir) < 0.5:
		return false
	var pos_yo: Vector2 = yo.get("position", Vector2.ZERO)
	var pos_otro: Vector2 = otro.get("position", Vector2.ZERO)
	var hacia_rival := signf(pos_otro.x - pos_yo.x)
	return hacia_rival != 0.0 and dir * hacia_rival > 0.0


func _h1078_inicio_forward_dash(prev_snap: Dictionary, evt_snap: Dictionary, lado: String) -> bool:
	var previo: Dictionary = _h1078_estado_lado(prev_snap, lado)
	if previo.is_empty():
		return false
	return not bool(previo.get("carrera_activa", false)) and _h1078_es_forward_dash(evt_snap, lado)


func _h1078_buscar_ventana_forward_dash() -> Dictionary:
	if rollback_ring == null or not h1078_forward_dash_auto_armado:
		return {}
	if h1078_forward_dash_tick_evento < 0 or h1078_forward_dash_tick_evento <= rollback_forward_dash_tick_ya_probado:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	for i in range(1, historial.size()):
		if int(historial[i].get("tick", -1)) != h1078_forward_dash_tick_evento:
			continue
		var prev_snap: Dictionary = historial[i - 1].get("snapshot", {})
		var evt_snap: Dictionary = historial[i].get("snapshot", {})
		if not _h1078_inicio_forward_dash(prev_snap, evt_snap, h1078_forward_dash_lado):
			return {}
		var inicio_idx := i - 1
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": h1078_forward_dash_tick_evento,
			"lado": h1078_forward_dash_lado,
			"direccion": h1078_forward_dash_direccion,
		}
	return {}


func _h1078_observar_forward_dash_post_snapshot() -> void:
	if rollback_ring == null or rollback_catchup_activo or rollback_comparacion_pendiente:
		return
	if rollback_test_solicitado or not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	if rollback_ring.total() < 2:
		return
	var hist: Array[Dictionary] = rollback_ring.ventana_desde_el_final(mini(16, rollback_ring.total()))
	if hist.size() < 2:
		return
	var prev_entry: Dictionary = hist[hist.size() - 2]
	var evt_entry: Dictionary = hist[hist.size() - 1]
	var prev_snap: Dictionary = prev_entry.get("snapshot", {})
	var evt_snap: Dictionary = evt_entry.get("snapshot", {})
	var tick_evt := int(evt_entry.get("tick", -1))

	if not h1078_forward_dash_auto_armado:
		if tick_evt <= rollback_forward_dash_tick_ya_probado:
			return
		var j1_inicio := _h1078_inicio_forward_dash(prev_snap, evt_snap, "J1")
		var j2_inicio := _h1078_inicio_forward_dash(prev_snap, evt_snap, "J2")
		# Si los dos arrancaron carrera exactamente en el mismo tick, no usamos una
		# ventana ambigua. Repetir el doble toque aislado produce un target limpio.
		if j1_inicio == j2_inicio:
			return
		var lado := "J1" if j1_inicio else "J2"
		var estado_evt: Dictionary = _h1078_estado_lado(evt_snap, lado)
		h1078_forward_dash_auto_armado = true
		h1078_forward_dash_tick_evento = tick_evt
		h1078_forward_dash_lado = lado
		h1078_forward_dash_direccion = float(estado_evt.get("carrera_direccion", 0.0))
		var dir_txt := "IZQUIERDA" if h1078_forward_dash_direccion < 0.0 else "DERECHA"
		print("[91.00.00-H10.88] FORWARD DASH EVENT OBSERVADO — %s dir=%s tick=%d; acumulando 7 snapshots post-evento" % [lado, dir_txt, tick_evt])
		return

	var ultimo_tick := int(evt_entry.get("tick", -1))
	if ultimo_tick >= h1078_forward_dash_tick_evento + 7:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] FORWARD DASH AUTO MARCADO — %s tick=%d; rollback próximo physics tick" % [h1078_forward_dash_lado, h1078_forward_dash_tick_evento])


func _h1080_tactico(snapshot: Dictionary) -> Dictionary:
	return snapshot.get("tactico", {})


func _h1080_es_kick_impact(prev_snap: Dictionary, evt_snap: Dictionary, lado: String) -> bool:
	var previo: Dictionary = _h1078_estado_lado(prev_snap, lado)
	var evento: Dictionary = _h1078_estado_lado(evt_snap, lado)
	var defensor_previo: Dictionary = _h1078_otro_estado(prev_snap, lado)
	var defensor_evento: Dictionary = _h1078_otro_estado(evt_snap, lado)
	if previo.is_empty() or evento.is_empty() or defensor_previo.is_empty() or defensor_evento.is_empty():
		return false
	if bool(previo.get("_atk_ya_conecto", false)) or not bool(evento.get("_atk_ya_conecto", false)):
		return false
	if str(evento.get("_atk_tipo", "")) != "patada":
		return false
	# Target limpio: golpe de suelo normal, sin carrera/backdash/aire/guardia.
	if not bool(previo.get("__on_floor", false)) or not bool(evento.get("__on_floor", false)):
		return false
	if not bool(defensor_previo.get("__on_floor", false)) or not bool(defensor_evento.get("__on_floor", false)):
		return false
	if bool(previo.get("carrera_activa", false)) or bool(evento.get("carrera_activa", false)):
		return false
	if bool(previo.get("dash_aereo_activo", false)) or bool(evento.get("dash_aereo_activo", false)):
		return false
	if bool(defensor_previo.get("bloqueando", false)) or bool(defensor_evento.get("bloqueando", false)):
		return false
	# Excluir explícitamente Launcher/AIR: sus seriales tácticos no deben cambiar
	# en la transición que estamos certificando.
	var tp: Dictionary = _h1080_tactico(prev_snap)
	var te: Dictionary = _h1080_tactico(evt_snap)
	if int(tp.get("_rollback_launcher_event_serial", 0)) != int(te.get("_rollback_launcher_event_serial", 0)):
		return false
	if int(tp.get("_rollback_airhit_event_serial", 0)) != int(te.get("_rollback_airhit_event_serial", 0)):
		return false
	return true


func _h1080_buscar_ventana_kick_impact() -> Dictionary:
	if rollback_ring == null or not h1080_kick_impact_auto_armado:
		return {}
	if h1080_kick_impact_tick_evento < 0 or h1080_kick_impact_tick_evento <= rollback_kick_impact_tick_ya_probado:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	for i in range(1, historial.size()):
		if int(historial[i].get("tick", -1)) != h1080_kick_impact_tick_evento:
			continue
		var prev_snap: Dictionary = historial[i - 1].get("snapshot", {})
		var evt_snap: Dictionary = historial[i].get("snapshot", {})
		if not _h1080_es_kick_impact(prev_snap, evt_snap, h1080_kick_impact_lado):
			return {}
		var inicio_idx := i - 1
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": h1080_kick_impact_tick_evento,
			"lado": h1080_kick_impact_lado,
		}
	return {}


func _h1080_observar_kick_impact_post_snapshot() -> void:
	if rollback_ring == null or rollback_catchup_activo or rollback_comparacion_pendiente:
		return
	if rollback_test_solicitado or not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	if rollback_ring.total() < 2:
		return
	var hist: Array[Dictionary] = rollback_ring.ventana_desde_el_final(mini(16, rollback_ring.total()))
	if hist.size() < 2:
		return
	var prev_entry: Dictionary = hist[hist.size() - 2]
	var evt_entry: Dictionary = hist[hist.size() - 1]
	var prev_snap: Dictionary = prev_entry.get("snapshot", {})
	var evt_snap: Dictionary = evt_entry.get("snapshot", {})
	var tick_evt := int(evt_entry.get("tick", -1))

	if not h1080_kick_impact_auto_armado:
		if tick_evt <= rollback_kick_impact_tick_ya_probado:
			return
		var j1_hit := _h1080_es_kick_impact(prev_snap, evt_snap, "J1")
		var j2_hit := _h1080_es_kick_impact(prev_snap, evt_snap, "J2")
		if j1_hit == j2_hit:
			return
		var lado := "J1" if j1_hit else "J2"
		h1080_kick_impact_auto_armado = true
		h1080_kick_impact_tick_evento = tick_evt
		h1080_kick_impact_lado = lado
		print("[91.00.00-H10.88] NORMAL KICK IMPACT EVENT OBSERVADO — %s tick=%d; acumulando 7 snapshots post-evento" % [lado, tick_evt])
		return

	var ultimo_tick := int(evt_entry.get("tick", -1))
	if ultimo_tick >= h1080_kick_impact_tick_evento + 7:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] NORMAL KICK IMPACT AUTO MARCADO — %s tick=%d; rollback próximo physics tick" % [h1080_kick_impact_lado, h1080_kick_impact_tick_evento])


func _h1081_es_punch_block(prev_snap: Dictionary, evt_snap: Dictionary, atacante_lado: String) -> bool:
	var atacante_previo: Dictionary = _h1078_estado_lado(prev_snap, atacante_lado)
	var atacante_evento: Dictionary = _h1078_estado_lado(evt_snap, atacante_lado)
	var defensor_previo: Dictionary = _h1078_otro_estado(prev_snap, atacante_lado)
	var defensor_evento: Dictionary = _h1078_otro_estado(evt_snap, atacante_lado)
	if atacante_previo.is_empty() or atacante_evento.is_empty() or defensor_previo.is_empty() or defensor_evento.is_empty():
		return false
	# Contacto único exactamente en esta transición.
	if bool(atacante_previo.get("_atk_ya_conecto", false)) or not bool(atacante_evento.get("_atk_ya_conecto", false)):
		return false
	if str(atacante_evento.get("_atk_tipo", "")) != "patada":
		return false
	# Ambos cuerpos en suelo; sin dash ni persecución aérea.
	if not bool(atacante_previo.get("__on_floor", false)) or not bool(atacante_evento.get("__on_floor", false)):
		return false
	if not bool(defensor_previo.get("__on_floor", false)) or not bool(defensor_evento.get("__on_floor", false)):
		return false
	if bool(atacante_previo.get("carrera_activa", false)) or bool(atacante_evento.get("carrera_activa", false)):
		return false
	if bool(atacante_previo.get("dash_aereo_activo", false)) or bool(atacante_evento.get("dash_aereo_activo", false)):
		return false
	# H10.83: detector reutilizado para PATADA. Guardia normal: el defensor ya venía bloqueando y sigue bloqueando al contacto.
	# El hitstun reducido de guardia debe existir; Perfect Block lo limpia a 0.
	if not bool(defensor_previo.get("bloqueando", false)) or not bool(defensor_evento.get("bloqueando", false)):
		return false
	if float(defensor_evento.get("hitstun_timer", 0.0)) <= 0.0:
		return false
	# Excluir Perfect de forma explícita. Si el impacto abrió Counter, esta frontera
	# pertenece a H10.72 y no puede certificarse como bloqueo normal.
	var defensor_id := -1
	if atacante_lado == "J1" and is_instance_valid(rival):
		defensor_id = rival.get_instance_id()
	elif atacante_lado == "J2" and is_instance_valid(kai):
		defensor_id = kai.get_instance_id()
	if defensor_id < 0:
		return false
	if _h1072_counter_disponible_snapshot(evt_snap, defensor_id):
		return false
	# Launcher/AIR deben permanecer invariantes en esta transición.
	var tp: Dictionary = _h1080_tactico(prev_snap)
	var te: Dictionary = _h1080_tactico(evt_snap)
	if int(tp.get("_rollback_launcher_event_serial", 0)) != int(te.get("_rollback_launcher_event_serial", 0)):
		return false
	if int(tp.get("_rollback_airhit_event_serial", 0)) != int(te.get("_rollback_airhit_event_serial", 0)):
		return false
	return true


func _h1081_buscar_ventana_punch_block() -> Dictionary:
	if rollback_ring == null or not h1081_punch_block_auto_armado:
		return {}
	if h1081_punch_block_tick_evento < 0 or h1081_punch_block_tick_evento <= rollback_punch_block_tick_ya_probado:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS + 1:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	for i in range(1, historial.size()):
		if int(historial[i].get("tick", -1)) != h1081_punch_block_tick_evento:
			continue
		var prev_snap: Dictionary = historial[i - 1].get("snapshot", {})
		var evt_snap: Dictionary = historial[i].get("snapshot", {})
		if not _h1081_es_punch_block(prev_snap, evt_snap, h1081_punch_block_atacante):
			return {}
		var inicio_idx := i - 1
		# Igual que Perfect/impactos: 8 subticks desde un tick antes del evento.
		if inicio_idx + ROLLBACK_TEST_TICKS >= historial.size():
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": h1081_punch_block_tick_evento,
			"atacante": h1081_punch_block_atacante,
			"defensor": h1081_punch_block_defensor,
		}
	return {}


func _h1081_observar_punch_block_post_snapshot() -> void:
	if rollback_ring == null or rollback_catchup_activo or rollback_comparacion_pendiente:
		return
	if rollback_test_solicitado or not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	if rollback_ring.total() < 2:
		return
	var hist: Array[Dictionary] = rollback_ring.ventana_desde_el_final(mini(16, rollback_ring.total()))
	if hist.size() < 2:
		return
	var prev_entry: Dictionary = hist[hist.size() - 2]
	var evt_entry: Dictionary = hist[hist.size() - 1]
	var prev_snap: Dictionary = prev_entry.get("snapshot", {})
	var evt_snap: Dictionary = evt_entry.get("snapshot", {})
	var tick_evt := int(evt_entry.get("tick", -1))

	if not h1081_punch_block_auto_armado:
		if tick_evt <= rollback_punch_block_tick_ya_probado:
			return
		var j1_ataca := _h1081_es_punch_block(prev_snap, evt_snap, "J1")
		var j2_ataca := _h1081_es_punch_block(prev_snap, evt_snap, "J2")
		if j1_ataca == j2_ataca:
			return
		h1081_punch_block_auto_armado = true
		h1081_punch_block_tick_evento = tick_evt
		h1081_punch_block_atacante = "J1" if j1_ataca else "J2"
		h1081_punch_block_defensor = "J2" if j1_ataca else "J1"
		print("[91.00.00-H10.88] NORMAL KICK BLOCK EVENT OBSERVADO — atacante=%s defensor=%s tick=%d; acumulando 7 snapshots post-evento" % [h1081_punch_block_atacante, h1081_punch_block_defensor, tick_evt])
		return

	var ultimo_tick := int(evt_entry.get("tick", -1))
	if ultimo_tick >= h1081_punch_block_tick_evento + 7:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] NORMAL KICK BLOCK AUTO MARCADO — atacante=%s defensor=%s tick=%d; rollback próximo physics tick" % [h1081_punch_block_atacante, h1081_punch_block_defensor, h1081_punch_block_tick_evento])



func _h1084_input_bloqueo(snapshot: Dictionary, lado: String) -> bool:
	var estado: Dictionary = _h1078_estado_lado(snapshot, lado)
	if estado.is_empty():
		return false
	var frame: Dictionary = estado.get("input_frame_enrutado_actual", {})
	return bool(frame.get("bloqueo", false))


func _h1084_es_block_recovery(prev_snap: Dictionary, evt_snap: Dictionary, defensor_lado: String) -> bool:
	var previo: Dictionary = _h1078_estado_lado(prev_snap, defensor_lado)
	var evento: Dictionary = _h1078_estado_lado(evt_snap, defensor_lado)
	if previo.is_empty() or evento.is_empty():
		return false
	# H10.85 — frontera semántica robusta: después de una patada bloqueada ya
	# confirmada por h1084_block_watch_activo, certificamos el tick en que Fighter
	# ejecuta _detener_bloqueo(). No dependemos de que el humano suelte el botón
	# dentro del mismo tick exacto en que hitstun cruza por cero.
	if not bool(previo.get("bloqueando", false)):
		return false
	if bool(evento.get("bloqueando", false)):
		return false
	if float(evento.get("hitstun_timer", 0.0)) > 0.0:
		return false
	if _h1084_input_bloqueo(evt_snap, defensor_lado):
		return false
	if float(evento.get("bloqueo_timer", 0.0)) > 0.0:
		return false
	if not bool(previo.get("__on_floor", false)) or not bool(evento.get("__on_floor", false)):
		return false
	if int(previo.get("fase_ataque", 0)) != 0 or int(evento.get("fase_ataque", 0)) != 0:
		return false
	if bool(evento.get("esta_derrotado", false)) or bool(evento.get("en_secuencia_especial", false)):
		return false
	return true


func _h1084_buscar_ventana_block_recovery() -> Dictionary:
	if rollback_ring == null or not h1084_block_recovery_auto_armado:
		return {}
	if h1084_block_recovery_tick_evento < 0 or h1084_block_recovery_tick_evento <= rollback_block_recovery_tick_ya_probado:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS + 1:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	for i in range(1, historial.size()):
		if int(historial[i].get("tick", -1)) != h1084_block_recovery_tick_evento:
			continue
		var prev_snap: Dictionary = historial[i - 1].get("snapshot", {})
		var evt_snap: Dictionary = historial[i].get("snapshot", {})
		if not _h1084_es_block_recovery(prev_snap, evt_snap, h1084_block_defensor):
			return {}
		var inicio_idx := i - 1
		if inicio_idx + ROLLBACK_TEST_TICKS >= historial.size():
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": h1084_block_recovery_tick_evento,
			"atacante": h1084_block_atacante,
			"defensor": h1084_block_defensor,
		}
	return {}


func _h1084_observar_block_recovery_post_snapshot() -> void:
	if rollback_ring == null or rollback_catchup_activo or rollback_comparacion_pendiente:
		return
	if rollback_test_solicitado or not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	if rollback_ring.total() < 2:
		return
	var hist: Array[Dictionary] = rollback_ring.ventana_desde_el_final(mini(32, rollback_ring.total()))
	if hist.size() < 2:
		return
	var prev_entry: Dictionary = hist[hist.size() - 2]
	var evt_entry: Dictionary = hist[hist.size() - 1]
	var prev_snap: Dictionary = prev_entry.get("snapshot", {})
	var evt_snap: Dictionary = evt_entry.get("snapshot", {})
	var tick_evt := int(evt_entry.get("tick", -1))

	# Preparación: detectar una PATADA bloqueada normal usando exactamente el
	# detector que quedó certificado en H10.83. No hacemos rollback aquí.
	if not h1084_block_watch_activo:
		var j1_ataca := _h1081_es_punch_block(prev_snap, evt_snap, "J1")
		var j2_ataca := _h1081_es_punch_block(prev_snap, evt_snap, "J2")
		if j1_ataca == j2_ataca:
			return
		h1084_block_watch_activo = true
		h1084_block_atacante = "J1" if j1_ataca else "J2"
		h1084_block_defensor = "J2" if j1_ataca else "J1"
		h1084_block_tick_impacto = tick_evt
		print("[91.00.00-H10.88] NORMAL BLOCK RECOVERY PREPARADO — atacante=%s defensor=%s impacto_tick=%d; soltá bloqueo después del impacto y quedate neutral" % [h1084_block_atacante, h1084_block_defensor, tick_evt])
		return

	if not h1084_block_recovery_auto_armado:
		if tick_evt <= rollback_block_recovery_tick_ya_probado:
			return
		if not _h1084_es_block_recovery(prev_snap, evt_snap, h1084_block_defensor):
			return
		h1084_block_recovery_auto_armado = true
		h1084_block_recovery_tick_evento = tick_evt
		print("[91.00.00-H10.88] NORMAL BLOCK RECOVERY EVENT OBSERVADO — defensor=%s bloqueando true->false con hitstun<=0 tick=%d; acumulando 7 snapshots post-evento" % [h1084_block_defensor, tick_evt])
		return

	var ultimo_tick := int(evt_entry.get("tick", -1))
	if ultimo_tick >= h1084_block_recovery_tick_evento + 7:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] NORMAL BLOCK RECOVERY AUTO MARCADO — defensor=%s tick=%d; rollback próximo physics tick" % [h1084_block_defensor, h1084_block_recovery_tick_evento])


func _h1087_otro_lado(lado: String) -> String:
	return "J2" if lado == "J1" else "J1"


func _h1087_armar_forward_dash(prev_snap: Dictionary, evt_snap: Dictionary, tick_evt: int) -> bool:
	var j1 := _h1078_inicio_forward_dash(prev_snap, evt_snap, "J1")
	var j2 := _h1078_inicio_forward_dash(prev_snap, evt_snap, "J2")
	if j1 == j2:
		return false
	var lado := "J1" if j1 else "J2"
	h1087_integral_lado_usuario = lado
	h1078_forward_dash_auto_armado = true
	h1078_forward_dash_tick_evento = tick_evt
	h1078_forward_dash_lado = lado
	var estado_evt: Dictionary = _h1078_estado_lado(evt_snap, lado)
	h1078_forward_dash_direccion = float(estado_evt.get("carrera_direccion", 0.0))
	var dir_txt := "IZQUIERDA" if h1078_forward_dash_direccion < 0.0 else "DERECHA"
	print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 1/6 OBSERVADO — %s FORWARD DASH %s tick=%d; acumulando 7 snapshots" % [lado, dir_txt, tick_evt])
	return true


func _h1087_armar_kick_impact(prev_snap: Dictionary, evt_snap: Dictionary, tick_evt: int) -> bool:
	if h1087_integral_lado_usuario == "":
		return false
	if not _h1080_es_kick_impact(prev_snap, evt_snap, h1087_integral_lado_usuario):
		return false
	h1080_kick_impact_auto_armado = true
	h1080_kick_impact_tick_evento = tick_evt
	h1080_kick_impact_lado = h1087_integral_lado_usuario
	# Preparar desde el mismo contacto el checkpoint 3, pero sin armar todavía su rollback.
	h1086_attack_watch_activo = true
	h1086_attack_lado = h1087_integral_lado_usuario
	h1086_attack_tick_impacto = tick_evt
	print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 2/6 OBSERVADO — %s PATADA LIMPIA tick=%d; acumulando 7 snapshots" % [h1087_integral_lado_usuario, tick_evt])
	return true


func _h1087_armar_attack_recovery(prev_snap: Dictionary, evt_snap: Dictionary, tick_evt: int) -> bool:
	if h1087_integral_lado_usuario == "" or not h1086_attack_watch_activo:
		return false
	if not _h1086_es_attack_recovery(prev_snap, evt_snap, h1087_integral_lado_usuario):
		return false
	h1086_attack_recovery_auto_armado = true
	h1086_attack_recovery_tick_evento = tick_evt
	print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 3/6 OBSERVADO — %s ATTACK RECOVERY 3->0 tick=%d; acumulando 7 snapshots" % [h1087_integral_lado_usuario, tick_evt])
	return true


func _h1087_armar_backdash(prev_snap: Dictionary, evt_snap: Dictionary, tick_evt: int) -> bool:
	if h1087_integral_lado_usuario == "":
		return false
	var serial_prev := _h5_backdash_serial(prev_snap)
	var serial_evt := _h5_backdash_serial(evt_snap)
	if serial_evt <= serial_prev or serial_evt <= rollback_backdash_serial_ya_probado:
		return false
	var fighter_id := _h5_backdash_id(evt_snap)
	var lado := _h6_lado_desde_id(fighter_id)
	if lado != h1087_integral_lado_usuario:
		return false
	h1077_backdash_auto_armado = true
	h1077_backdash_tick_evento = tick_evt
	h1077_backdash_lado = lado
	h1077_backdash_serial_evento = serial_evt
	h1077_backdash_direccion = _h5_backdash_dir(evt_snap)
	var dir_txt := "IZQUIERDA" if h1077_backdash_direccion < 0.0 else "DERECHA"
	print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 4/6 OBSERVADO — %s BACKDASH %s serial=%d tick=%d; acumulando 7 snapshots" % [lado, dir_txt, serial_evt, tick_evt])
	return true


func _h1087_armar_kick_block(prev_snap: Dictionary, evt_snap: Dictionary, tick_evt: int) -> bool:
	if h1087_integral_lado_usuario == "":
		return false
	var atacante := _h1087_otro_lado(h1087_integral_lado_usuario)
	if not _h1081_es_punch_block(prev_snap, evt_snap, atacante):
		return false
	h1081_punch_block_auto_armado = true
	h1081_punch_block_tick_evento = tick_evt
	h1081_punch_block_atacante = atacante
	h1081_punch_block_defensor = h1087_integral_lado_usuario
	# El mismo impacto prepara el checkpoint 6 de liberación de guardia.
	h1084_block_watch_activo = true
	h1084_block_atacante = atacante
	h1084_block_defensor = h1087_integral_lado_usuario
	h1084_block_tick_impacto = tick_evt
	print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 5/6 OBSERVADO — atacante=%s PATADA BLOQUEADA / defensor=%s tick=%d; acumulando 7 snapshots" % [atacante, h1087_integral_lado_usuario, tick_evt])
	return true


func _h1087_armar_block_recovery(prev_snap: Dictionary, evt_snap: Dictionary, tick_evt: int) -> bool:
	if h1087_integral_lado_usuario == "" or not h1084_block_watch_activo:
		return false
	if not _h1084_es_block_recovery(prev_snap, evt_snap, h1087_integral_lado_usuario):
		return false
	h1084_block_recovery_auto_armado = true
	h1084_block_recovery_tick_evento = tick_evt
	print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 6/6 OBSERVADO — %s BLOCK RECOVERY true->false tick=%d; acumulando 7 snapshots" % [h1087_integral_lado_usuario, tick_evt])
	return true


func _h1087_observar_regresion_integral_post_snapshot() -> void:
	if h1087_integral_fallo or h1087_integral_completo:
		return
	if rollback_ring == null or rollback_catchup_activo or rollback_comparacion_pendiente:
		return
	if rollback_test_solicitado or not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	if rollback_ring.total() < 2:
		return
	var hist: Array[Dictionary] = rollback_ring.ventana_desde_el_final(mini(32, rollback_ring.total()))
	if hist.size() < 2:
		return
	var prev_entry: Dictionary = hist[hist.size() - 2]
	var evt_entry: Dictionary = hist[hist.size() - 1]
	var prev_snap: Dictionary = prev_entry.get("snapshot", {})
	var evt_snap: Dictionary = evt_entry.get("snapshot", {})
	var tick_evt := int(evt_entry.get("tick", -1))

	match h1087_integral_fase:
		0:
			if not h1078_forward_dash_auto_armado:
				_h1087_armar_forward_dash(prev_snap, evt_snap, tick_evt)
			elif tick_evt >= h1078_forward_dash_tick_evento + 7:
				rollback_test_solicitado = true
				print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 1/6 AUTO MARCADO — rollback próximo physics tick")
		1:
			if not h1080_kick_impact_auto_armado:
				_h1087_armar_kick_impact(prev_snap, evt_snap, tick_evt)
			elif tick_evt >= h1080_kick_impact_tick_evento + 7:
				rollback_test_solicitado = true
				print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 2/6 AUTO MARCADO — rollback próximo physics tick")
		2:
			if not h1086_attack_recovery_auto_armado:
				_h1087_armar_attack_recovery(prev_snap, evt_snap, tick_evt)
			elif tick_evt >= h1086_attack_recovery_tick_evento + 7:
				rollback_test_solicitado = true
				print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 3/6 AUTO MARCADO — rollback próximo physics tick")
		3:
			if not h1077_backdash_auto_armado:
				_h1087_armar_backdash(prev_snap, evt_snap, tick_evt)
			elif tick_evt >= h1077_backdash_tick_evento + 7:
				rollback_test_solicitado = true
				print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 4/6 AUTO MARCADO — rollback próximo physics tick")
		4:
			if not h1081_punch_block_auto_armado:
				_h1087_armar_kick_block(prev_snap, evt_snap, tick_evt)
			elif tick_evt >= h1081_punch_block_tick_evento + 7:
				rollback_test_solicitado = true
				print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 5/6 AUTO MARCADO — rollback próximo physics tick")
		5:
			if not h1084_block_recovery_auto_armado:
				_h1087_armar_block_recovery(prev_snap, evt_snap, tick_evt)
			elif tick_evt >= h1084_block_recovery_tick_evento + 7:
				rollback_test_solicitado = true
				print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 6/6 AUTO MARCADO — rollback próximo physics tick")


func _h1087_integral_resultado(ok: bool, clasificacion: String) -> void:
	if h1087_integral_fallo or h1087_integral_completo:
		return
	var esperadas := ["FORWARD DASH", "NORMAL IMPACT", "NORMAL ATTACK RECOVERY", "BACK DASH", "NORMAL BLOCK", "NORMAL BLOCK RECOVERY"]
	if h1087_integral_fase < 0 or h1087_integral_fase >= esperadas.size():
		return
	if clasificacion != str(esperadas[h1087_integral_fase]):
		return
	if not ok:
		h1087_integral_fallo = true
		print("[91.00.00-H10.88] NORMAL COMBAT INTEGRAL REGRESSION FAILED — checkpoint %d/6 (%s); detener y diagnosticar sólo esta frontera" % [h1087_integral_fase + 1, clasificacion])
		return

	h1087_integral_fase += 1
	match h1087_integral_fase:
		1:
			print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 1/6 OK — ahora conectá UNA PATADA limpia, soltá el botón y quedate neutral")
		2:
			print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 2/6 OK — no hagas nada; esperando automáticamente RECOVERY->NEUTRAL")
		3:
			print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 3/6 OK — ahora hacé BACKDASH alejándote del rival")
		4:
			print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 4/6 OK — mantené BLOQUEO desde antes y recibí una PATADA normal del rival")
		5:
			print("[91.00.00-H10.88] INTEGRAL CHECKPOINT 5/6 OK — soltá BLOQUEO después del impacto y quedate completamente neutral")
		6:
			h1087_integral_completo = true
			print("[91.00.00-H10.88] NORMAL COMBAT INTEGRAL REGRESSION OK — 6/6 checkpoints; movimiento + impacto + recovery + backdash + guardia + retorno neutral idénticos")


func _h1086_input_patada(snapshot: Dictionary, lado: String) -> bool:
	var estado: Dictionary = _h1078_estado_lado(snapshot, lado)
	if estado.is_empty():
		return false
	var frame: Dictionary = estado.get("input_frame_enrutado_actual", {})
	return bool(frame.get("patada", false))


func _h1086_es_attack_recovery(prev_snap: Dictionary, evt_snap: Dictionary, atacante_lado: String) -> bool:
	var previo: Dictionary = _h1078_estado_lado(prev_snap, atacante_lado)
	var evento: Dictionary = _h1078_estado_lado(evt_snap, atacante_lado)
	if previo.is_empty() or evento.is_empty():
		return false
	# Frontera semántica: RECOVERY(3) -> NINGUNA(0) después de la patada limpia
	# previamente confirmada por h1086_attack_watch_activo.
	if int(previo.get("fase_ataque", 0)) != 3:
		return false
	if int(evento.get("fase_ataque", 0)) != 0:
		return false
	if str(previo.get("_atk_tipo", "")) != "patada" or str(evento.get("_atk_tipo", "")) != "patada":
		return false
	if not bool(previo.get("_atk_ya_conecto", false)) or not bool(evento.get("_atk_ya_conecto", false)):
		return false
	if _h1086_input_patada(evt_snap, atacante_lado):
		return false
	if not bool(previo.get("__on_floor", false)) or not bool(evento.get("__on_floor", false)):
		return false
	if float(evento.get("hitstun_timer", 0.0)) > 0.0 or bool(evento.get("bloqueando", false)):
		return false
	if bool(evento.get("carrera_activa", false)) or bool(evento.get("dash_aereo_activo", false)):
		return false
	if bool(evento.get("esta_derrotado", false)) or bool(evento.get("en_secuencia_especial", false)):
		return false
	return true


func _h1086_buscar_ventana_attack_recovery() -> Dictionary:
	if rollback_ring == null or not h1086_attack_recovery_auto_armado:
		return {}
	if h1086_attack_recovery_tick_evento < 0 or h1086_attack_recovery_tick_evento <= rollback_attack_recovery_tick_ya_probado:
		return {}
	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS + 1:
		return {}
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	for i in range(1, historial.size()):
		if int(historial[i].get("tick", -1)) != h1086_attack_recovery_tick_evento:
			continue
		var prev_snap: Dictionary = historial[i - 1].get("snapshot", {})
		var evt_snap: Dictionary = historial[i].get("snapshot", {})
		if not _h1086_es_attack_recovery(prev_snap, evt_snap, h1086_attack_lado):
			return {}
		var inicio_idx := i - 1
		if inicio_idx + ROLLBACK_TEST_TICKS >= historial.size():
			return {}
		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])
		return {
			"encontrado": true,
			"ventana": ventana,
			"tick_evento": h1086_attack_recovery_tick_evento,
			"lado": h1086_attack_lado,
		}
	return {}


func _h1086_observar_attack_recovery_post_snapshot() -> void:
	if rollback_ring == null or rollback_catchup_activo or rollback_comparacion_pendiente:
		return
	if rollback_test_solicitado or not is_instance_valid(kai) or not is_instance_valid(rival):
		return
	if rollback_ring.total() < 2:
		return
	var hist: Array[Dictionary] = rollback_ring.ventana_desde_el_final(mini(40, rollback_ring.total()))
	if hist.size() < 2:
		return
	var prev_entry: Dictionary = hist[hist.size() - 2]
	var evt_entry: Dictionary = hist[hist.size() - 1]
	var prev_snap: Dictionary = prev_entry.get("snapshot", {})
	var evt_snap: Dictionary = evt_entry.get("snapshot", {})
	var tick_evt := int(evt_entry.get("tick", -1))

	# Preparación: una PATADA normal limpia ya certificada en H10.80. No rollback acá.
	if not h1086_attack_watch_activo:
		var j1_hit := _h1080_es_kick_impact(prev_snap, evt_snap, "J1")
		var j2_hit := _h1080_es_kick_impact(prev_snap, evt_snap, "J2")
		if j1_hit == j2_hit:
			return
		h1086_attack_watch_activo = true
		h1086_attack_lado = "J1" if j1_hit else "J2"
		h1086_attack_tick_impacto = tick_evt
		print("[91.00.00-H10.88] NORMAL ATTACK RECOVERY PREPARADO — atacante=%s impacto_tick=%d; soltá PATADA y quedate neutral" % [h1086_attack_lado, tick_evt])
		return

	if not h1086_attack_recovery_auto_armado:
		if tick_evt <= rollback_attack_recovery_tick_ya_probado:
			return
		if not _h1086_es_attack_recovery(prev_snap, evt_snap, h1086_attack_lado):
			return
		h1086_attack_recovery_auto_armado = true
		h1086_attack_recovery_tick_evento = tick_evt
		print("[91.00.00-H10.88] NORMAL ATTACK RECOVERY EVENT OBSERVADO — atacante=%s fase 3->0 tick=%d; acumulando 7 snapshots post-evento" % [h1086_attack_lado, tick_evt])
		return

	var ultimo_tick := int(evt_entry.get("tick", -1))
	if ultimo_tick >= h1086_attack_recovery_tick_evento + 7:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] NORMAL ATTACK RECOVERY AUTO MARCADO — atacante=%s tick=%d; rollback próximo physics tick" % [h1086_attack_lado, h1086_attack_recovery_tick_evento])


func _h33_counter_serial_live() -> int:
	var tactico := get_node_or_null("/root/PerfectBlock90_1")
	if tactico == null:
		return 0
	return int(tactico.get("_rollback_counter_event_serial"))


func _h33_counter_serial_ultimo_ring() -> int:
	if rollback_ring == null or rollback_ring.entradas.is_empty():
		return 0
	var ultimo: Dictionary = rollback_ring.entradas[rollback_ring.entradas.size() - 1]
	return _h32_counter_serial(ultimo.get("snapshot", {}))


func _h32_counter_serial(snapshot: Dictionary) -> int:
	var tactico: Dictionary = snapshot.get("tactico", {})
	return int(tactico.get("_rollback_counter_event_serial", 0))


func _h32_counter_id(snapshot: Dictionary) -> int:
	var tactico: Dictionary = snapshot.get("tactico", {})
	return int(tactico.get("_rollback_counter_event_fighter_id", -1))


func _h32_counter_tipo(snapshot: Dictionary) -> String:
	var tactico: Dictionary = snapshot.get("tactico", {})
	return str(tactico.get("_rollback_counter_event_tipo", ""))


func _h32_buscar_ventana_counter_marcado() -> Dictionary:
	if rollback_ring == null:
		return {}

	var total_busqueda := mini(ROLLBACK_COUNTER_LOOKBACK_TICKS, rollback_ring.total())
	if total_busqueda < ROLLBACK_TEST_TICKS:
		return {}

	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(total_busqueda)
	if historial.size() < 2:
		return {}

	# Buscar el evento NUEVO más reciente. Un serial ya probado nunca se reutiliza.
	for i in range(historial.size() - 1, 0, -1):
		var snap_prev: Dictionary = historial[i - 1].get("snapshot", {})
		var snap_evt: Dictionary = historial[i].get("snapshot", {})
		var serial_prev := _h32_counter_serial(snap_prev)
		var serial_evt := _h32_counter_serial(snap_evt)

		if serial_evt <= serial_prev:
			continue
		if serial_evt <= rollback_counter_serial_ya_probado:
			continue

		var fighter_id := _h32_counter_id(snap_evt)
		var tipo := _h32_counter_tipo(snap_evt)
		var lado := "?"
		if is_instance_valid(kai) and fighter_id == kai.get_instance_id():
			lado = "J1"
		elif is_instance_valid(rival) and fighter_id == rival.get_instance_id():
			lado = "J2"

		# Snapshot i es el PRIMER snapshot que ya contiene el sello.
		# Empezamos en i-1 para que la re-simulación atraviese el physics tick
		# donde PerfectBlock90_1 vuelve a ejecutar el Counter.
		var inicio_idx := maxi(0, i - 1)
		if inicio_idx + ROLLBACK_TEST_TICKS > historial.size():
			inicio_idx = historial.size() - ROLLBACK_TEST_TICKS

		var ventana: Array[Dictionary] = []
		for k in range(inicio_idx, inicio_idx + ROLLBACK_TEST_TICKS):
			ventana.append(historial[k])

		return {
			"encontrado": true,
			"ventana": ventana,
			"atacante": lado,
			"tipo": tipo,
			"serial": serial_evt,
			"tick_counter": int(historial[i].get("tick", -1)),
		}

	return {}


func _h32_presente_historico_despues_de_ventana(ventana: Array[Dictionary]) -> Dictionary:
	# Necesitamos el estado inmediatamente DESPUÉS del último tick de la ventana
	# elegida, no necesariamente el presente real de F11.
	if rollback_ring == null or ventana.is_empty():
		return {}

	var ultimo_tick := int(ventana[ventana.size() - 1].get("tick", -1))
	for entrada in rollback_ring.entradas:
		if int(entrada.get("tick", -1)) == ultimo_tick + 1:
			return entrada.get("snapshot", {}).duplicate(true)

	# Si la ventana termina en el tick más reciente, usamos el presente real.
	return RollbackSnapshotScript.capturar_partida(self, kai, rival)



# 91.02.59 — PASS 13B / localizador histórico de proyectiles.
# El ring ya contiene snapshot + inputs por tick; 91.02.58 agregó proyectil_j1/j2.
# Este arnés NO modifica simulación: sólo elige una ventana de 8 ticks para F11.
func _h13b_proyectil_snapshot(snapshot: Dictionary, lado: String) -> Dictionary:
	var clave := "proyectil_j1" if lado == "J1" else "proyectil_j2"
	var valor = snapshot.get(clave, {})
	return valor if typeof(valor) == TYPE_DICTIONARY else {}


func _h13b_fighter_snapshot(snapshot: Dictionary, lado: String) -> Dictionary:
	var clave := "j1" if lado == "J1" else "j2"
	var valor = snapshot.get(clave, {})
	return valor if typeof(valor) == TYPE_DICTIONARY else {}


func _h13b_input_entrada(entrada: Dictionary, lado: String) -> Dictionary:
	var clave := "j1" if lado == "J1" else "j2"
	var valor = entrada.get(clave, {})
	return valor if typeof(valor) == TYPE_DICTIONARY else {}


func _h13b_ventana_8_alrededor(historial: Array[Dictionary], indice_evento: int) -> Array[Dictionary]:
	var salida: Array[Dictionary] = []
	if historial.size() < ROLLBACK_TEST_TICKS:
		return salida

	# Preferimos tres snapshots previos al evento; si F11 llegó enseguida,
	# desplazamos la ventana hacia atrás sin salir del historial disponible.
	var max_inicio := historial.size() - ROLLBACK_TEST_TICKS
	var inicio := clampi(indice_evento - 3, 0, max_inicio)
	for k in range(inicio, inicio + ROLLBACK_TEST_TICKS):
		salida.append(historial[k].duplicate(true))
	return salida


func _h13b_buscar_ventana_proyectil() -> Dictionary:
	if rollback_ring == null or rollback_ring.total() < ROLLBACK_TEST_TICKS:
		return {}

	# ~0.60 s de búsqueda histórica. El rollback ejecutado sigue siendo 8 ticks;
	# este lookback sólo hace practicable presionar F11 después del impacto.
	var cantidad := mini(36, rollback_ring.total())
	var historial: Array[Dictionary] = rollback_ring.ventana_desde_el_final(cantidad)
	if historial.size() < ROLLBACK_TEST_TICKS:
		return {}

	# PRIORIDAD 1: transición PROYECTIL ACTIVO -> INACTIVO.
	# Puede ser impacto limpio, bloqueo o simplemente fin de vida. Sólo aceptamos
	# como impacto si hay evidencia lógica en el Fighter/inputs.
	for i in range(historial.size() - 1, 0, -1):
		var snap_prev: Dictionary = historial[i - 1].get("snapshot", {})
		var snap_evt: Dictionary = historial[i].get("snapshot", {})
		if snap_prev.is_empty() or snap_evt.is_empty():
			continue

		for lado in ["J1", "J2"]:
			var defensor := "J2" if lado == "J1" else "J1"
			var p_prev := _h13b_proyectil_snapshot(snap_prev, lado)
			var p_evt := _h13b_proyectil_snapshot(snap_evt, lado)
			var activo_prev := bool(p_prev.get("activo", false))
			var activo_evt := bool(p_evt.get("activo", false))
			if not activo_prev or activo_evt:
				continue

			var atk_prev := _h13b_fighter_snapshot(snap_prev, lado)
			var atk_evt := _h13b_fighter_snapshot(snap_evt, lado)
			var def_prev := _h13b_fighter_snapshot(snap_prev, defensor)
			var def_evt := _h13b_fighter_snapshot(snap_evt, defensor)
			var in_def_prev := _h13b_input_entrada(historial[i - 1], defensor)
			var in_def_evt := _h13b_input_entrada(historial[i], defensor)

			var bloqueado := (
				bool(def_prev.get("bloqueando", false))
				or bool(def_evt.get("bloqueando", false))
				or bool(in_def_prev.get("bloqueo", false))
				or bool(in_def_evt.get("bloqueo", false))
			)

			var poder_prev := float(atk_prev.get("poder", 0.0))
			var poder_evt := float(atk_evt.get("poder", 0.0))
			var core_subio := poder_evt > poder_prev + 0.0005

			var hitstun_prev := float(def_prev.get("hitstun_timer", 0.0))
			var hitstun_evt := float(def_evt.get("hitstun_timer", 0.0))
			var hubo_reaccion := hitstun_evt > hitstun_prev + 0.0005 or hitstun_evt > 0.0

			if not bloqueado and not core_subio and not hubo_reaccion:
				# Probable timeout/salida de arena: no es el target PASS 13B.
				continue

			var ventana := _h13b_ventana_8_alrededor(historial, i)
			if ventana.size() != ROLLBACK_TEST_TICKS:
				continue

			var clase := "PROYECTIL BLOQUEO" if bloqueado else "PROYECTIL IMPACTO CORE"
			return {
				"encontrado": true,
				"ventana": ventana,
				"clasificacion": clase,
				"lado": lado,
				"defensor": defensor,
				"tick_evento": int(historial[i].get("tick", -1)),
				"poder_antes": poder_prev,
				"poder_despues": poder_evt,
			}

	# PRIORIDAD 2: proyectil actualmente en vuelo dentro de los últimos 8 ticks.
	# Usamos exactamente la ventana final para comparar contra el presente real.
	var ultimos8: Array[Dictionary] = rollback_ring.ventana_desde_el_final(ROLLBACK_TEST_TICKS)
	var lado_vuelo := ""
	for entrada in ultimos8:
		var snap: Dictionary = entrada.get("snapshot", {})
		if bool(_h13b_proyectil_snapshot(snap, "J1").get("activo", false)):
			lado_vuelo = "J1"
		if bool(_h13b_proyectil_snapshot(snap, "J2").get("activo", false)):
			lado_vuelo = "J2" if lado_vuelo.is_empty() else lado_vuelo
	if not lado_vuelo.is_empty():
		return {
			"encontrado": true,
			"ventana": ultimos8,
			"clasificacion": "PROYECTIL VUELO",
			"lado": lado_vuelo,
			"defensor": "J2" if lado_vuelo == "J1" else "J1",
			"tick_evento": int(ultimos8[ultimos8.size() - 1].get("tick", -1)),
		}

	# PRIORIDAD 3: startup/spawn pendiente. Es útil si F11 cae justo antes
	# de que aparezca el nodo de proyectil.
	for i in range(historial.size() - 1, -1, -1):
		var snap: Dictionary = historial[i].get("snapshot", {})
		for lado in ["J1", "J2"]:
			var estado := _h13b_fighter_snapshot(snap, lado)
			if bool(estado.get("en_lanzamiento_proyectil", false)) or bool(estado.get("proyectil_disparo_pendiente", false)):
				var ventana := _h13b_ventana_8_alrededor(historial, i)
				if ventana.size() == ROLLBACK_TEST_TICKS:
					return {
						"encontrado": true,
						"ventana": ventana,
						"clasificacion": "PROYECTIL STARTUP",
						"lado": lado,
						"defensor": "J2" if lado == "J1" else "J1",
						"tick_evento": int(historial[i].get("tick", -1)),
					}

	return {}



func _iniciar_prueba_rollback_local() -> void:
	if replay_modo_activo or not versus_local_activo or online_activo:
		print("[91.00.00-H10.88] ROLLBACK TEST no disponible en este modo")
		return
	if rollback_catchup_activo or rollback_comparacion_pendiente:
		print("[91.00.00-H10.88] ROLLBACK TEST ya está en ejecución")
		return
	if rollback_ring == null or rollback_ring.total() < ROLLBACK_TEST_TICKS:
		print("[91.00.00-H10.88] ROLLBACK TEST — historial insuficiente")
		return
	var perfect_auto_evento := _h1072_buscar_ventana_perfect_block()
	if h1072_perfect_auto_armado and not bool(perfect_auto_evento.get("encontrado", false)):
		rollback_test_solicitado = true
		return
	var core3_absolute_match_reset_evento := _h1069_buscar_ventana_core3_absolute_match_reset_entry()
	var core3_absolute_match_reset_pendiente := bool(core3_absolute_match_reset_evento.get("encontrado", false))
	var core3_absolute_victory_hold_evento := _h1067_buscar_ventana_core3_absolute_victory_hold()
	var core3_absolute_victory_hold_pendiente := bool(core3_absolute_victory_hold_evento.get("encontrado", false))
	var core3_absolute_reveal_end_evento := _h1057_buscar_ventana_core3_absolute_finisher_entry()
	var core3_absolute_reveal_end_pendiente := bool(core3_absolute_reveal_end_evento.get("encontrado", false))
	var core3_nineteenth_beat_attack_start_evento := _h1053_buscar_ventana_core3_nineteenth_beat_attack_start()
	var core3_nineteenth_beat_attack_start_pendiente := bool(core3_nineteenth_beat_attack_start_evento.get("encontrado", false))
	var core3_eighteenth_beat_end_evento := _h1051_buscar_ventana_core3_eighteenth_beat_end()
	var core3_eighteenth_beat_end_pendiente := bool(core3_eighteenth_beat_end_evento.get("encontrado", false))
	var core3_eighth_beat_end_evento := _h1028_buscar_ventana_core3_eighth_beat_end()
	var core3_eighth_beat_end_pendiente := bool(core3_eighth_beat_end_evento.get("encontrado", false))
	var core3_seventh_beat_end_evento := _h1027_buscar_ventana_core3_seventh_beat_end()
	var core3_seventh_beat_end_pendiente := bool(core3_seventh_beat_end_evento.get("encontrado", false))
	var core3_sixth_beat_end_evento := _h1025_buscar_ventana_core3_sixth_beat_end()
	var core3_sixth_beat_end_pendiente := bool(core3_sixth_beat_end_evento.get("encontrado", false))
	var core3_fifth_beat_end_evento := _h1023_buscar_ventana_core3_fifth_beat_end()
	var core3_fifth_beat_end_pendiente := bool(core3_fifth_beat_end_evento.get("encontrado", false))
	var core3_fourth_beat_end_evento := _h1021_buscar_ventana_core3_fourth_beat_end()
	var core3_fourth_beat_end_pendiente := bool(core3_fourth_beat_end_evento.get("encontrado", false))
	var core3_third_beat_end_evento := _h1019_buscar_ventana_core3_third_beat_end()
	var core3_third_beat_end_pendiente := bool(core3_third_beat_end_evento.get("encontrado", false))
	var core3_second_beat_end_evento := _h1016_buscar_ventana_core3_second_beat_end()
	var core3_second_beat_end_pendiente := bool(core3_second_beat_end_evento.get("encontrado", false))
	var core3_first_beat_end_evento := _h1014_buscar_ventana_core3_first_beat_end()
	var core3_first_beat_end_pendiente := bool(core3_first_beat_end_evento.get("encontrado", false))
	var core3_approach_end_evento := _h1012_buscar_ventana_core3_approach_end()
	var core3_approach_end_pendiente := bool(core3_approach_end_evento.get("encontrado", false))
	var core3_recarga_end_evento := _h109_buscar_ventana_core3_recarga_end()
	var core3_recarga_end_pendiente := bool(core3_recarga_end_evento.get("encontrado", false))
	var core3_entry_evento := _h10_buscar_ventana_core3_entry()
	var core3_entry_pendiente := bool(core3_entry_evento.get("encontrado", false))
	var core2_sequence_end_evento := _h911_buscar_ventana_core2_sequence_end()
	var core2_sequence_end_pendiente := bool(core2_sequence_end_evento.get("encontrado", false))
	var core2_rematador_poster_end_evento := _h99_buscar_ventana_core2_rematador_poster_end()
	var core2_rematador_poster_end_pendiente := bool(core2_rematador_poster_end_evento.get("encontrado", false))
	var core2_rematador_entry_evento := _h98_buscar_ventana_core2_rematador_entry()
	var core2_rematador_entry_pendiente := bool(core2_rematador_entry_evento.get("encontrado", false))
	var core2_first_beat_end_evento := _h96_buscar_ventana_core2_first_beat_end()
	var core2_first_beat_end_pendiente := bool(core2_first_beat_end_evento.get("encontrado", false))
	var core2_combo_entry_evento := _h94_buscar_ventana_core2_combo_entry()
	var core2_combo_entry_pendiente := bool(core2_combo_entry_evento.get("encontrado", false))
	var core2_recarga_end_evento := _h91_buscar_ventana_core2_recarga_end()
	var core2_recarga_end_pendiente := bool(core2_recarga_end_evento.get("encontrado", false))

	if h1069_match_reset_auto_test_armado and rollback_test_solicitado and not core3_absolute_match_reset_pendiente:
		h1069_match_reset_localizacion_espera_ticks += 1
		if h1069_match_reset_localizacion_espera_ticks <= H1069_LOCALIZACION_MAX_TICKS:
			rollback_test_solicitado = true
			return
		print("[91.00.00-H10.88] CORE III ABSOLUTE MATCH RESET ENTRY AUTO CANCELADO — transición no localizable tras %d ticks" % H1069_LOCALIZACION_MAX_TICKS)
		h1069_match_reset_auto_test_armado = false
		h1069_match_reset_lado = ""
		h1069_match_reset_post_snapshots = 0
		h1069_match_reset_localizacion_espera_ticks = 0
		return

	if h1067_victory_hold_auto_test_armado and not core3_absolute_victory_hold_pendiente:
		h1067_victory_hold_localizacion_espera_ticks += 1
		if h1067_victory_hold_localizacion_espera_ticks <= H1067_LOCALIZACION_MAX_TICKS:
			rollback_test_solicitado = true
			return
		print("[91.00.00-H10.88] CORE III ABSOLUTE VICTORY HOLD AUTO CANCELADO — ventana estable no localizable tras %d ticks" % H1067_LOCALIZACION_MAX_TICKS)
		h1067_victory_hold_auto_test_armado = false
		h1067_victory_hold_lado = ""
		h1067_victory_hold_snapshots_estables = 0
		h1067_victory_hold_localizacion_espera_ticks = 0
		return

	if h1057_auto_test_armado and not core3_absolute_reveal_end_pendiente:
		h1057_localizacion_espera_ticks += 1
		if h1057_localizacion_espera_ticks <= H1057_LOCALIZACION_MAX_TICKS:
			rollback_test_solicitado = true
			return
		print("[91.00.00-H10.88] CORE III ABSOLUTE VICTORY ENTRY AUTO CANCELADO — evento no localizable tras %d ticks" % H1057_LOCALIZACION_MAX_TICKS)
		h1057_auto_test_armado = false
		h1057_event_tick_hint = -1
		h1057_event_lado = ""
		h1057_localizacion_espera_ticks = 0
		return

	if h1053_auto_test_armado and not core3_nineteenth_beat_attack_start_pendiente:
		h1053_localizacion_espera_ticks += 1
		if h1053_localizacion_espera_ticks <= H1053_LOCALIZACION_MAX_TICKS:
			rollback_test_solicitado = true
			return
		print("[91.00.00-H10.88] CORE III NINETEENTH BEAT ATTACK START AUTO CANCELADO — evento no localizable tras %d ticks; gameplay continúa intacto" % H1053_LOCALIZACION_MAX_TICKS)
		h1053_auto_test_armado = false
		h1053_auto_test_tick_evento = -1
		h1053_auto_test_lado = ""
		h1053_localizacion_espera_ticks = 0
		return

	if h1051_auto_test_armado and not core3_eighteenth_beat_end_pendiente:
		h1051_localizacion_espera_ticks += 1
		if h1051_localizacion_espera_ticks <= H1051_LOCALIZACION_MAX_TICKS:
			rollback_test_solicitado = true
			return
		print("[91.00.00-H10.88] CORE III EIGHTEENTH BEAT END AUTO CANCELADO — evento no localizable tras %d ticks; gameplay continúa intacto" % H1051_LOCALIZACION_MAX_TICKS)
		h1051_auto_test_armado = false
		h1051_auto_test_tick_evento = -1
		h1051_auto_test_lado = ""
		h1051_localizacion_espera_ticks = 0
		return

	if h1028_auto_test_armado and not core3_eighth_beat_end_pendiente:
		h1029_localizacion_espera_ticks += 1
		if h1029_localizacion_espera_ticks <= H1029_LOCALIZACION_MAX_TICKS:
			# Silencioso: no imprimir por physics tick. El snapshot post-transición puede
			# necesitar un frame para entrar al ring, pero nunca debe degradar gameplay.
			rollback_test_solicitado = true
			return
		print("[91.00.00-H10.88] CORE III EIGHTH BEAT END AUTO CANCELADO — evento no localizable tras %d ticks; gameplay continúa intacto" % H1029_LOCALIZACION_MAX_TICKS)
		h1028_auto_test_armado = false
		h1028_auto_test_tick_evento = -1
		h1028_auto_test_lado = ""
		h1029_localizacion_espera_ticks = 0
		return

	if h1027_auto_test_armado and not core3_seventh_beat_end_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE III SEVENTH BEAT END AUTO — transición marcada pero aún no localizable; esperando 1 physics tick")
		return

	if h1025_auto_test_armado and not core3_sixth_beat_end_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE III SIXTH BEAT END AUTO — transición marcada pero aún no localizable; esperando 1 physics tick")
		return

	if h1023_auto_test_armado and not core3_fifth_beat_end_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE III FIFTH BEAT END AUTO — transición marcada pero aún no localizable; esperando 1 physics tick")
		return

	if h1021_auto_test_armado and not core3_fourth_beat_end_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE III FOURTH BEAT END AUTO — transición marcada pero aún no localizable; esperando 1 physics tick")
		return

	if h1019_auto_test_armado and not core3_third_beat_end_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE III THIRD BEAT END AUTO — transición marcada pero aún no localizable; esperando 1 physics tick")
		return

	if h1016_auto_test_armado and not core3_second_beat_end_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE III SECOND BEAT END AUTO — transición marcada pero aún no localizable; esperando 1 physics tick")
		return

	if h1014_auto_test_armado and not core3_first_beat_end_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE III FIRST BEAT END AUTO — transición marcada pero aún no localizable; esperando 1 physics tick")
		return

	if h1012_auto_test_armado and not core3_approach_end_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE III APPROACH END AUTO — transición marcada pero aún no localizable; esperando 1 physics tick")
		return

	if h109_auto_test_armado and not core3_recarga_end_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE III RECARGA END AUTO — transición marcada pero aún no localizable; esperando 1 physics tick")
		return

	if h10_core3_auto_armado and not core3_entry_pendiente:
		var post_core3 := _h101_core3_post_ticks_disponibles()
		if post_core3 < H101_CORE3_POST_TICKS_REQUERIDOS:
			rollback_test_solicitado = true
			print("[91.00.00-H10.88] CORE III EXACT ENTRY AUTO — historial post-evento %d/%d ticks" % [
				maxi(post_core3, 0),
				H101_CORE3_POST_TICKS_REQUERIDOS
			])
			return

	if h911_auto_test_armado and not core2_sequence_end_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE II SEQUENCE END AUTO — marcado pero aún no localizable; esperando 1 physics tick")
		return

	if h99_auto_test_armado and not core2_rematador_poster_end_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE II REMATADOR POSTER END AUTO — marcado pero aún no localizable; esperando 1 physics tick")
		return

	if h98_auto_test_armado and not core2_rematador_entry_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE II REMATADOR ENTRY AUTO — marcado pero aún no localizable; esperando 1 physics tick")
		return

	if h96_auto_test_armado and not core2_first_beat_end_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE II FIRST BEAT END AUTO — marcado pero aún no localizable; esperando 1 physics tick")
		return

	if h94_auto_test_armado and not core2_combo_entry_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE II COMBO ENTRY AUTO — marcado pero aún no localizable; esperando 1 physics tick")
		return

	if h92_auto_test_armado and not core2_recarga_end_pendiente:
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] CORE II RECARGA END AUTO — transición marcada pero aún no localizable; esperando 1 physics tick")
		return
	var core3_pendiente := rollback_core3_event_serial > rollback_core3_event_serial_ya_probado
	var core2_pendiente := rollback_core2_event_serial > rollback_core2_event_serial_ya_probado

	# H10.68 — VICTORY HOLD es deliberadamente un estado post-KO/no-ronda.
	# El gate genérico debe seguir rechazando KO/cinemáticas, salvo cuando el
	# localizador TARGET-ONLY ya encontró esta ventana histórica específica.
	if not _snapshot_estado_rollback_h_seguro() 	and not core3_absolute_match_reset_pendiente 	and not core3_absolute_victory_hold_pendiente 	and not core3_pendiente 	and not core2_pendiente 	and not core2_recarga_end_pendiente 	and not core2_combo_entry_pendiente 	and not core2_first_beat_end_pendiente 	and not core2_rematador_entry_pendiente 	and not core2_rematador_poster_end_pendiente 	and not core2_sequence_end_pendiente 	and not core3_absolute_reveal_end_pendiente 	and not core3_nineteenth_beat_attack_start_pendiente 	and not core3_eighteenth_beat_end_pendiente 	and not core3_eighth_beat_end_pendiente 	and not core3_seventh_beat_end_pendiente 	and not core3_sixth_beat_end_pendiente 	and not core3_fifth_beat_end_pendiente 	and not core3_fourth_beat_end_pendiente 	and not core3_third_beat_end_pendiente 	and not core3_second_beat_end_pendiente 	and not core3_first_beat_end_pendiente 	and not core3_approach_end_pendiente 	and not core3_entry_pendiente 	and not core3_recarga_end_pendiente:
		# Si visualmente acaba de terminar la recarga pero el snapshot de Main
		# todavía no capturó la transición, rearmar F11 un physics tick.
		if _h91_core2_recarga_termino_live():
			rollback_test_solicitado = true
			print("[91.00.00-H10.88] CORE II RECARGA END LIVE — esperando 1 physics tick de captura")
			return
		print("[91.00.00-H10.88] TACTICAL TEST CANCELADO — no usar CORE/derribo/KO/cinemáticas")
		return

	# H10 — fase_activada CORE III también ocurre después del snapshot de Main.
	if core3_pendiente:
		var post_core3_pending := _h101_core3_post_ticks_disponibles()
		if post_core3_pending < H101_CORE3_POST_TICKS_REQUERIDOS:
			rollback_test_solicitado = true
			print("[91.00.00-H10.88] CORE III EXACT ENTRY — acumulando post-evento %d/%d ticks" % [
				maxi(post_core3_pending, 0),
				H101_CORE3_POST_TICKS_REQUERIDOS
			])
			return

	# H9 — CORE II puede estar en recarga/cinemática, que el gate genérico
	# rechaza correctamente. Sólo permitimos continuar si existe un evento
	# CORE II Main-only pendiente y localizable.
	if core2_pendiente:
		var core2_ultimo_tick := _h81_core1_ultimo_tick_ring()
		if core2_ultimo_tick <= rollback_core2_event_tick_hint:
			rollback_test_solicitado = true
			print("[91.00.00-H10.88] CORE II RECIÉN MARCADO — esperando 1 physics tick de captura")
			return

	# H8.1 — fase_activada ocurre después del snapshot de inicio de Main.
	# Si F11 llega antes de que el ring haya capturado el tick_hint, esperar
	# exactamente un physics tick. No altera gameplay.
	if rollback_core1_event_serial > rollback_core1_event_serial_ya_probado:
		var core_ultimo_tick := _h81_core1_ultimo_tick_ring()
		if core_ultimo_tick <= rollback_core1_event_tick_hint:
			rollback_test_solicitado = true
			print("[91.00.00-H10.88] CORE I RECIÉN MARCADO — esperando 1 physics tick de captura")
			return

	# H6 — Launcher/Air Hit pueden ocurrir después del snapshot más reciente de Main.
	# Si el sello LIVE todavía no está dentro del ring, esperar exactamente un physics tick.
	var air_live := _h6_airhit_serial_live()
	var air_ring := _h6_airhit_serial_ultimo_ring()
	if air_live > air_ring:
		rollback_airhit_serial_defer = air_live
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] AIR HIT RECIÉN MARCADO — serial=%d fuera del ring; capturando 1 physics tick" % air_live)
		return
	rollback_airhit_serial_defer = -1

	var launcher_live := _h6_launcher_serial_live()
	var launcher_ring := _h6_launcher_serial_ultimo_ring()
	if launcher_live > launcher_ring:
		rollback_launcher_serial_defer = launcher_live
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] LAUNCHER RECIÉN MARCADO — serial=%d fuera del ring; capturando 1 physics tick" % launcher_live)
		return
	rollback_launcher_serial_defer = -1

	# 91.00.00-H10.13 — frontera Main/PerfectBlock para BACK DASH.
	# Igual que Counter, el sello puede ocurrir después del último snapshot de Main.
	var bd_live := _h5_backdash_serial_live()
	var bd_ring := _h5_backdash_serial_ultimo_ring()
	if bd_live > bd_ring and bd_live > rollback_backdash_serial_ya_probado:
		rollback_backdash_serial_defer = bd_live
		rollback_test_solicitado = true
		print("[91.00.00-H10.88] BACKDASH RECIÉN MARCADO — serial=%d todavía fuera del ring; capturando 1 physics tick" % bd_live)
		return
	rollback_backdash_serial_defer = -1

	# 91.00.00-H10.13 — frontera Main/PerfectBlock:
	# el Counter puede haber ocurrido DESPUÉS del snapshot más reciente del ring.
	# En ese caso rearmamos F11 una sola vez y dejamos que este physics tick
	# registre el sello. En el tick siguiente ya existe la transición histórica.
	var serial_live := _h33_counter_serial_live()
	var serial_ring := _h33_counter_serial_ultimo_ring()
	if serial_live > serial_ring and serial_live > rollback_counter_serial_ya_probado:
		if not rollback_counter_defer_activo or rollback_counter_serial_defer != serial_live:
			rollback_counter_defer_activo = true
			rollback_counter_serial_defer = serial_live
			rollback_test_solicitado = true
			print("[91.00.00-H10.88] COUNTER RECIÉN MARCADO — serial=%d todavía fuera del ring; capturando 1 physics tick" % serial_live)
			return

	rollback_counter_defer_activo = false
	rollback_counter_serial_defer = -1

	# H6: Air Hit y Launcher tienen prioridad. Back Dash/Counter quedan como regresión.
	var core2_entry_evento := _h9_buscar_ventana_core2_entry()
	var core1_poster_end_evento := _h86_buscar_ventana_core1_poster_end()
	var core1_target_end_evento := _h84_buscar_ventana_core1_target_end()
	var core1_evento := _h81_buscar_ventana_core1()
	var air_evento := _h6_buscar_airhit()
	var launcher_evento := _h6_buscar_launcher()
	var backdash_evento := _h5_buscar_ventana_backdash()
	var forward_dash_evento := _h1078_buscar_ventana_forward_dash()
	var normal_kick_impact_evento := _h1080_buscar_ventana_kick_impact()
	var normal_punch_block_evento := _h1081_buscar_ventana_punch_block()
	var normal_block_recovery_evento := _h1084_buscar_ventana_block_recovery()
	var normal_attack_recovery_evento := _h1086_buscar_ventana_attack_recovery()
	var perfect_evento := _h1072_buscar_ventana_perfect_block()
	var counter_evento := _h32_buscar_ventana_counter_marcado()
	# 91.02.59 — F11 ya puede seleccionar una ventana de proyectil sin
	# depender del analizador histórico de ataques normales.
	var proyectil_evento := _h13b_buscar_ventana_proyectil()

	var ventana: Array[Dictionary] = []
	var analisis: Dictionary = {}

	if bool(core3_absolute_match_reset_evento.get("encontrado", false)):
		ventana = core3_absolute_match_reset_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III ABSOLUTE MATCH RESET ENTRY",
			"atacante": "%s CORE III ABSOLUTE MATCH RESET ENTRY" % str(core3_absolute_match_reset_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III ABSOLUTE MATCH RESET ENTRY LOCALIZADO — SceneTreeTimer 9.20 s / victoria->partida nueva — tick %d -> %d %s" % [
			int(core3_absolute_match_reset_evento.get("tick_inicio", -1)),
			int(core3_absolute_match_reset_evento.get("tick_final", -1)),
			str(core3_absolute_match_reset_evento.get("lado", "?"))
		])
		rollback_core3_absolute_match_reset_tick_ya_probado = int(core3_absolute_match_reset_evento.get("tick_evento", rollback_core3_absolute_match_reset_tick_ya_probado))
		h1069_match_reset_auto_test_armado = false
		h1069_match_reset_lado = ""
		h1069_match_reset_post_snapshots = 0
		h1069_match_reset_localizacion_espera_ticks = 0
	elif bool(core3_absolute_victory_hold_evento.get("encontrado", false)):
		ventana = core3_absolute_victory_hold_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III ABSOLUTE VICTORY HOLD",
			"atacante": "%s CORE III ABSOLUTE VICTORY HOLD" % str(core3_absolute_victory_hold_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III ABSOLUTE VICTORY HOLD LOCALIZADO — 8 ticks estables; tick %d -> %d %s" % [
			int(core3_absolute_victory_hold_evento.get("tick_inicio", -1)),
			int(core3_absolute_victory_hold_evento.get("tick_final", -1)),
			str(core3_absolute_victory_hold_evento.get("lado", "?"))
		])
		rollback_core3_absolute_victory_hold_tick_ya_probado = int(core3_absolute_victory_hold_evento.get("tick_final", rollback_core3_absolute_victory_hold_tick_ya_probado))
		h1067_victory_hold_auto_test_armado = false
		h1067_victory_hold_lado = ""
		h1067_victory_hold_snapshots_estables = 0
		h1067_victory_hold_localizacion_espera_ticks = 0
	elif bool(core3_absolute_reveal_end_evento.get("encontrado", false)):
		ventana = core3_absolute_reveal_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III ABSOLUTE VICTORY ENTRY",
			"atacante": "%s CORE III ABSOLUTE VICTORY ENTRY" % str(core3_absolute_reveal_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III ABSOLUTE VICTORY ENTRY LOCALIZADO — ronda=false / time_scale 0.42->1.0 / ganador pose_victoria false->true — tick=%d %s" % [
			int(core3_absolute_reveal_end_evento.get("tick_evento", -1)),
			str(core3_absolute_reveal_end_evento.get("lado", "?"))
		])
		rollback_core3_absolute_victory_entry_tick_ya_probado = int(core3_absolute_reveal_end_evento.get(
			"tick_evento", rollback_core3_absolute_victory_entry_tick_ya_probado
		))
		h1057_auto_test_armado = false
		h1057_localizacion_espera_ticks = 0
	elif bool(core3_nineteenth_beat_attack_start_evento.get("encontrado", false)):
		ventana = core3_nineteenth_beat_attack_start_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III NINETEENTH BEAT ATTACK START",
			"atacante": "%s CORE III NINETEENTH BEAT ATTACK START" % str(core3_nineteenth_beat_attack_start_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III NINETEENTH BEAT ATTACK START LOCALIZADO — stage 21 / entrada-activa o fase 0->ataque — tick=%d %s" % [
			int(core3_nineteenth_beat_attack_start_evento.get("tick_evento", -1)),
			str(core3_nineteenth_beat_attack_start_evento.get("lado", "?"))
		])
		rollback_core3_nineteenth_beat_attack_start_tick_ya_probado = int(core3_nineteenth_beat_attack_start_evento.get(
			"tick_evento", rollback_core3_nineteenth_beat_attack_start_tick_ya_probado
		))
		h1053_auto_test_armado = false
		h1053_localizacion_espera_ticks = 0
	elif bool(core3_eighteenth_beat_end_evento.get("encontrado", false)):
		ventana = core3_eighteenth_beat_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III EIGHTEENTH BEAT END",
			"atacante": "%s CORE III EIGHTEENTH BEAT END" % str(core3_eighteenth_beat_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III EIGHTEENTH BEAT END LOCALIZADO — stage 20->21 — tick=%d %s" % [
			int(core3_eighteenth_beat_end_evento.get("tick_evento", -1)),
			str(core3_eighteenth_beat_end_evento.get("lado", "?"))
		])
		rollback_core3_eighteenth_beat_end_tick_ya_probado = int(core3_eighteenth_beat_end_evento.get(
			"tick_evento", rollback_core3_eighteenth_beat_end_tick_ya_probado
		))
		h1051_auto_test_armado = false
		h1051_localizacion_espera_ticks = 0
	elif bool(core3_eighth_beat_end_evento.get("encontrado", false)):
		ventana = core3_eighth_beat_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III EIGHTH BEAT END",
			"atacante": "%s CORE III EIGHTH BEAT END" % str(core3_eighth_beat_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III EIGHTH BEAT END LOCALIZADO — stage 10->11 — tick=%d %s" % [
			int(core3_eighth_beat_end_evento.get("tick_evento", -1)),
			str(core3_eighth_beat_end_evento.get("lado", "?"))
		])
		rollback_core3_eighth_beat_end_tick_ya_probado = int(core3_eighth_beat_end_evento.get(
			"tick_evento", rollback_core3_eighth_beat_end_tick_ya_probado
		))
		h1028_auto_test_armado = false
		h1029_localizacion_espera_ticks = 0
	elif bool(core3_seventh_beat_end_evento.get("encontrado", false)):
		ventana = core3_seventh_beat_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III SEVENTH BEAT END",
			"atacante": "%s CORE III SEVENTH BEAT END" % str(core3_seventh_beat_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III SEVENTH BEAT END LOCALIZADO — stage 9->10 — tick=%d %s" % [
			int(core3_seventh_beat_end_evento.get("tick_evento", -1)),
			str(core3_seventh_beat_end_evento.get("lado", "?"))
		])
		rollback_core3_seventh_beat_end_tick_ya_probado = int(core3_seventh_beat_end_evento.get(
			"tick_evento", rollback_core3_seventh_beat_end_tick_ya_probado
		))
		h1027_auto_test_armado = false
	elif bool(core3_sixth_beat_end_evento.get("encontrado", false)):
		ventana = core3_sixth_beat_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III SIXTH BEAT END",
			"atacante": "%s CORE III SIXTH BEAT END" % str(core3_sixth_beat_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III SIXTH BEAT END LOCALIZADO — stage 8->9 — tick=%d %s" % [
			int(core3_sixth_beat_end_evento.get("tick_evento", -1)),
			str(core3_sixth_beat_end_evento.get("lado", "?"))
		])
		rollback_core3_sixth_beat_end_tick_ya_probado = int(core3_sixth_beat_end_evento.get(
			"tick_evento", rollback_core3_sixth_beat_end_tick_ya_probado
		))
		h1025_auto_test_armado = false
	elif bool(core3_fifth_beat_end_evento.get("encontrado", false)):
		ventana = core3_fifth_beat_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III FIFTH BEAT END",
			"atacante": "%s CORE III FIFTH BEAT END" % str(core3_fifth_beat_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III FIFTH BEAT END LOCALIZADO — stage 7->8 — tick=%d %s" % [
			int(core3_fifth_beat_end_evento.get("tick_evento", -1)),
			str(core3_fifth_beat_end_evento.get("lado", "?"))
		])
		rollback_core3_fifth_beat_end_tick_ya_probado = int(core3_fifth_beat_end_evento.get(
			"tick_evento", rollback_core3_fifth_beat_end_tick_ya_probado
		))
		h1023_auto_test_armado = false
	elif bool(core3_fourth_beat_end_evento.get("encontrado", false)):
		ventana = core3_fourth_beat_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III FOURTH BEAT END",
			"atacante": "%s CORE III FOURTH BEAT END" % str(core3_fourth_beat_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III FOURTH BEAT END LOCALIZADO — stage 6->7 — tick=%d %s" % [
			int(core3_fourth_beat_end_evento.get("tick_evento", -1)),
			str(core3_fourth_beat_end_evento.get("lado", "?"))
		])
		rollback_core3_fourth_beat_end_tick_ya_probado = int(core3_fourth_beat_end_evento.get(
			"tick_evento", rollback_core3_fourth_beat_end_tick_ya_probado
		))
		h1021_auto_test_armado = false
	elif bool(core3_third_beat_end_evento.get("encontrado", false)):
		ventana = core3_third_beat_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III THIRD BEAT END",
			"atacante": "%s CORE III THIRD BEAT END" % str(core3_third_beat_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III THIRD BEAT END LOCALIZADO — stage 5->6 — tick=%d %s" % [
			int(core3_third_beat_end_evento.get("tick_evento", -1)),
			str(core3_third_beat_end_evento.get("lado", "?"))
		])
		rollback_core3_third_beat_end_tick_ya_probado = int(core3_third_beat_end_evento.get(
			"tick_evento", rollback_core3_third_beat_end_tick_ya_probado
		))
		h1019_auto_test_armado = false
	elif bool(core3_second_beat_end_evento.get("encontrado", false)):
		ventana = core3_second_beat_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III SECOND BEAT END",
			"atacante": "%s CORE III SECOND BEAT END" % str(core3_second_beat_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III SECOND BEAT END LOCALIZADO — stage 4->5 — tick=%d %s" % [
			int(core3_second_beat_end_evento.get("tick_evento", -1)),
			str(core3_second_beat_end_evento.get("lado", "?"))
		])
		rollback_core3_second_beat_end_tick_ya_probado = int(core3_second_beat_end_evento.get(
			"tick_evento", rollback_core3_second_beat_end_tick_ya_probado
		))
		h1016_auto_test_armado = false
	elif bool(core3_first_beat_end_evento.get("encontrado", false)):
		ventana = core3_first_beat_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III FIRST BEAT END",
			"atacante": "%s CORE III FIRST BEAT END" % str(core3_first_beat_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III FIRST BEAT END LOCALIZADO — stage 3->4 — tick=%d %s" % [
			int(core3_first_beat_end_evento.get("tick_evento", -1)),
			str(core3_first_beat_end_evento.get("lado", "?"))
		])
		rollback_core3_first_beat_end_tick_ya_probado = int(core3_first_beat_end_evento.get(
			"tick_evento", rollback_core3_first_beat_end_tick_ya_probado
		))
		h1014_auto_test_armado = false
	elif bool(core3_approach_end_evento.get("encontrado", false)):
		ventana = core3_approach_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III APPROACH END",
			"atacante": "%s CORE III APPROACH END" % str(core3_approach_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III APPROACH END LOCALIZADO — stage 2->3 — tick=%d %s" % [
			int(core3_approach_end_evento.get("tick_evento", -1)),
			str(core3_approach_end_evento.get("lado", "?"))
		])
		rollback_core3_approach_end_tick_ya_probado = int(core3_approach_end_evento.get(
			"tick_evento", rollback_core3_approach_end_tick_ya_probado
		))
		h1012_auto_test_armado = false
	elif bool(core3_recarga_end_evento.get("encontrado", false)):
		ventana = core3_recarga_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III RECARGA END",
			"atacante": "%s CORE III RECARGA END" % str(core3_recarga_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III RECARGA END LOCALIZADO — ventana=[evento-7..evento] — tick=%d %s" % [
			int(core3_recarga_end_evento.get("tick_evento", -1)),
			str(core3_recarga_end_evento.get("lado", "?"))
		])
		rollback_core3_recarga_end_tick_ya_probado = int(core3_recarga_end_evento.get(
			"tick_evento", rollback_core3_recarga_end_tick_ya_probado
		))
		h109_auto_test_armado = false
	elif bool(core3_entry_evento.get("encontrado", false)):
		ventana = core3_entry_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE III ENTRY",
			"atacante": "%s CORE III ENTRY" % str(core3_entry_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE III EXACT ENTRY LOCALIZADO — ventana=[evento-1..evento+6] — serial=%d tick=%d %s" % [
			int(core3_entry_evento.get("serial", -1)),
			int(core3_entry_evento.get("tick_evento", -1)),
			str(core3_entry_evento.get("lado", "?"))
		])
		rollback_core3_event_serial_ya_probado = int(core3_entry_evento.get(
			"serial", rollback_core3_event_serial_ya_probado
		))
		h10_core3_auto_armado = false
	elif bool(core2_sequence_end_evento.get("encontrado", false)):
		ventana = core2_sequence_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE II SEQUENCE END",
			"atacante": "%s CORE II SEQUENCE END" % str(core2_sequence_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE II SEQUENCE END LOCALIZADO — tick=%d %s" % [
			int(core2_sequence_end_evento.get("tick_evento", -1)),
			str(core2_sequence_end_evento.get("lado", "?"))
		])
		rollback_core2_sequence_end_tick_ya_probado = int(core2_sequence_end_evento.get(
			"tick_evento", rollback_core2_sequence_end_tick_ya_probado
		))
		h911_auto_test_armado = false
	elif bool(core2_rematador_poster_end_evento.get("encontrado", false)):
		ventana = core2_rematador_poster_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE II REMATADOR POSTER END",
			"atacante": "%s CORE II REMATADOR POSTER END" % str(core2_rematador_poster_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE II REMATADOR POSTER END LOCALIZADO — serial=%d tick=%d %s" % [
			int(core2_rematador_poster_end_evento.get("serial", -1)),
			int(core2_rematador_poster_end_evento.get("tick_evento", -1)),
			str(core2_rematador_poster_end_evento.get("lado", "?"))
		])
		rollback_core2_rematador_poster_serial_ya_probado = int(
			core2_rematador_poster_end_evento.get(
				"serial", rollback_core2_rematador_poster_serial_ya_probado
			)
		)
		h99_auto_test_armado = false
	elif bool(core2_rematador_entry_evento.get("encontrado", false)):
		ventana = core2_rematador_entry_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE II REMATADOR ENTRY",
			"atacante": "%s CORE II REMATADOR ENTRY" % str(core2_rematador_entry_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE II REMATADOR ENTRY LOCALIZADO — tick=%d %s" % [
			int(core2_rematador_entry_evento.get("tick_evento", -1)),
			str(core2_rematador_entry_evento.get("lado", "?"))
		])
		rollback_core2_rematador_entry_tick_ya_probado = int(core2_rematador_entry_evento.get(
			"tick_evento", rollback_core2_rematador_entry_tick_ya_probado
		))
		h98_auto_test_armado = false
	elif bool(core2_first_beat_end_evento.get("encontrado", false)):
		ventana = core2_first_beat_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE II FIRST BEAT END",
			"atacante": "%s CORE II FIRST BEAT END" % str(core2_first_beat_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE II FIRST BEAT END LOCALIZADO — tick=%d %s" % [
			int(core2_first_beat_end_evento.get("tick_evento", -1)),
			str(core2_first_beat_end_evento.get("lado", "?"))
		])
		rollback_core2_first_beat_end_tick_ya_probado = int(core2_first_beat_end_evento.get(
			"tick_evento", rollback_core2_first_beat_end_tick_ya_probado
		))
		h96_auto_test_armado = false
	elif bool(core2_combo_entry_evento.get("encontrado", false)):
		ventana = core2_combo_entry_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE II COMBO ENTRY",
			"atacante": "%s CORE II COMBO ENTRY" % str(core2_combo_entry_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE II COMBO ENTRY LOCALIZADO — tick=%d %s" % [
			int(core2_combo_entry_evento.get("tick_evento", -1)),
			str(core2_combo_entry_evento.get("lado", "?"))
		])
		rollback_core2_combo_entry_tick_ya_probado = int(core2_combo_entry_evento.get(
			"tick_evento", rollback_core2_combo_entry_tick_ya_probado
		))
		h94_auto_test_armado = false
	elif bool(core2_recarga_end_evento.get("encontrado", false)):
		ventana = core2_recarga_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE II RECARGA END",
			"atacante": "%s CORE II RECARGA END" % str(core2_recarga_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE II RECARGA END LOCALIZADO — tick=%d %s" % [
			int(core2_recarga_end_evento.get("tick_evento", -1)),
			str(core2_recarga_end_evento.get("lado", "?"))
		])
		rollback_core2_recarga_end_tick_ya_probado = int(core2_recarga_end_evento.get(
			"tick_evento", rollback_core2_recarga_end_tick_ya_probado
		))
		h92_auto_test_armado = false
	elif bool(core2_entry_evento.get("encontrado", false)):
		ventana = core2_entry_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE II ENTRY",
			"atacante": "%s CORE II ENTRY" % str(core2_entry_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE II EVENT LOCALIZADO — serial=%d tick=%d %s" % [
			int(core2_entry_evento.get("serial", -1)),
			int(core2_entry_evento.get("tick_evento", -1)),
			str(core2_entry_evento.get("lado", "?"))
		])
		rollback_core2_event_serial_ya_probado = int(core2_entry_evento.get(
			"serial", rollback_core2_event_serial_ya_probado
		))
	elif bool(core1_poster_end_evento.get("encontrado", false)):
		ventana = core1_poster_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE I POSTER END",
			"atacante": "%s CORE I POSTER END" % str(core1_poster_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE I POSTER END LOCALIZADO — tick=%d %s" % [
			int(core1_poster_end_evento.get("tick_evento", -1)),
			str(core1_poster_end_evento.get("lado", "?"))
		])
		rollback_core1_poster_end_tick_ya_probado = int(core1_poster_end_evento.get(
			"tick_evento", rollback_core1_poster_end_tick_ya_probado
		))
	elif bool(core1_target_end_evento.get("encontrado", false)):
		ventana = core1_target_end_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE I TARGET END",
			"atacante": "%s CORE I TARGET END" % str(core1_target_end_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE I TARGET END LOCALIZADO — serial=%d tick=%d %s" % [
			int(core1_target_end_evento.get("serial", -1)),
			int(core1_target_end_evento.get("tick_evento", -1)),
			str(core1_target_end_evento.get("lado", "?"))
		])
		rollback_core1_target_end_serial_ya_probado = int(core1_target_end_evento.get(
			"serial", rollback_core1_target_end_serial_ya_probado
		))
	elif bool(core1_evento.get("encontrado", false)):
		ventana = core1_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "CORE I ENTRY",
			"atacante": "%s CORE I" % str(core1_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] CORE I EVENT LOCALIZADO — serial=%d tick=%d %s" % [
			int(core1_evento.get("serial", -1)),
			int(core1_evento.get("tick_evento", -1)),
			str(core1_evento.get("lado", "?"))
		])
		rollback_core1_event_serial_ya_probado = int(core1_evento.get(
			"serial", rollback_core1_event_serial_ya_probado
		))
	elif h1086_attack_recovery_auto_armado and bool(normal_attack_recovery_evento.get("encontrado", false)):
		ventana = normal_attack_recovery_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "NORMAL ATTACK RECOVERY",
			"atacante": "%s PATADA LIMPIA / recuperación ofensiva" % str(normal_attack_recovery_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] NORMAL ATTACK RECOVERY EVENT LOCALIZADO — tick=%d atacante=%s" % [
			int(normal_attack_recovery_evento.get("tick_evento", -1)), str(normal_attack_recovery_evento.get("lado", "?"))
		])
		rollback_attack_recovery_tick_ya_probado = int(normal_attack_recovery_evento.get("tick_evento", rollback_attack_recovery_tick_ya_probado))
		h1086_attack_watch_activo = false
		h1086_attack_lado = ""
		h1086_attack_tick_impacto = -1
		h1086_attack_recovery_auto_armado = false
		h1086_attack_recovery_tick_evento = -1
	elif h1084_block_recovery_auto_armado and bool(normal_block_recovery_evento.get("encontrado", false)):
		ventana = normal_block_recovery_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "NORMAL BLOCK RECOVERY",
			"atacante": "%s PATADA BLOQUEADA / recuperación defensor %s" % [str(normal_block_recovery_evento.get("atacante", "?")), str(normal_block_recovery_evento.get("defensor", "?"))],
		}
		print("[91.00.00-H10.88] NORMAL BLOCK RECOVERY EVENT LOCALIZADO — tick=%d atacante=%s defensor=%s" % [
			int(normal_block_recovery_evento.get("tick_evento", -1)), str(normal_block_recovery_evento.get("atacante", "?")), str(normal_block_recovery_evento.get("defensor", "?"))
		])
		rollback_block_recovery_tick_ya_probado = int(normal_block_recovery_evento.get("tick_evento", rollback_block_recovery_tick_ya_probado))
		h1084_block_watch_activo = false
		h1084_block_atacante = ""
		h1084_block_defensor = ""
		h1084_block_tick_impacto = -1
		h1084_block_recovery_auto_armado = false
		h1084_block_recovery_tick_evento = -1
	elif h1081_punch_block_auto_armado and bool(normal_punch_block_evento.get("encontrado", false)):
		ventana = normal_punch_block_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "NORMAL BLOCK",
			"atacante": "%s PATADA BLOQUEADA / defensor %s" % [str(normal_punch_block_evento.get("atacante", "?")), str(normal_punch_block_evento.get("defensor", "?"))],
		}
		print("[91.00.00-H10.88] NORMAL KICK BLOCK EVENT LOCALIZADO — tick=%d atacante=%s defensor=%s" % [
			int(normal_punch_block_evento.get("tick_evento", -1)), str(normal_punch_block_evento.get("atacante", "?")), str(normal_punch_block_evento.get("defensor", "?"))
		])
		rollback_punch_block_tick_ya_probado = int(normal_punch_block_evento.get("tick_evento", rollback_punch_block_tick_ya_probado))
		h1081_punch_block_auto_armado = false
		h1081_punch_block_tick_evento = -1
		h1081_punch_block_atacante = ""
		h1081_punch_block_defensor = ""
	elif h1080_kick_impact_auto_armado and bool(normal_kick_impact_evento.get("encontrado", false)):
		ventana = normal_kick_impact_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "NORMAL IMPACT",
			"atacante": "%s PATADA LIMPIA" % str(normal_kick_impact_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] NORMAL KICK IMPACT EVENT LOCALIZADO — tick=%d %s" % [
			int(normal_kick_impact_evento.get("tick_evento", -1)), str(normal_kick_impact_evento.get("lado", "?"))
		])
		rollback_kick_impact_tick_ya_probado = int(normal_kick_impact_evento.get("tick_evento", rollback_kick_impact_tick_ya_probado))
		h1080_kick_impact_auto_armado = false
		h1080_kick_impact_tick_evento = -1
		h1080_kick_impact_lado = ""
	elif h1078_forward_dash_auto_armado and bool(forward_dash_evento.get("encontrado", false)):
		ventana = forward_dash_evento.get("ventana", [])
		var fd_dir := float(forward_dash_evento.get("direccion", 0.0))
		var fd_dir_txt := "IZQUIERDA" if fd_dir < 0.0 else "DERECHA"
		analisis = {
			"valida": true,
			"clasificacion": "FORWARD DASH",
			"atacante": "%s FORWARD DASH %s" % [str(forward_dash_evento.get("lado", "?")), fd_dir_txt],
		}
		print("[91.00.00-H10.88] FORWARD DASH EVENT LOCALIZADO — tick=%d %s dir=%s" % [
			int(forward_dash_evento.get("tick_evento", -1)), str(forward_dash_evento.get("lado", "?")), fd_dir_txt
		])
		rollback_forward_dash_tick_ya_probado = int(forward_dash_evento.get("tick_evento", rollback_forward_dash_tick_ya_probado))
		h1078_forward_dash_auto_armado = false
		h1078_forward_dash_tick_evento = -1
		h1078_forward_dash_lado = ""
		h1078_forward_dash_direccion = 0.0
	elif h1077_backdash_auto_armado and bool(backdash_evento.get("encontrado", false)):
		# H10.78 target-only: el sello exacto que armó la autocaptura tiene
		# prioridad sobre localizadores históricos de AIR/Launcher.
		var bd_serial := int(backdash_evento.get("serial", -1))
		if bd_serial != h1077_backdash_serial_evento:
			rollback_test_solicitado = false
			return
		ventana = backdash_evento.get("ventana", [])
		var bd_dir_target := float(backdash_evento.get("direccion", 0.0))
		var bd_dir_txt_target := "IZQUIERDA" if bd_dir_target < 0.0 else "DERECHA"
		analisis = {
			"valida": true,
			"clasificacion": "BACK DASH",
			"atacante": "%s BACK DASH %s" % [str(backdash_evento.get("lado", "?")), bd_dir_txt_target],
		}
		print("[91.00.00-H10.88] BACKDASH EVENT LOCALIZADO — serial=%d tick=%d %s dir=%s" % [
			bd_serial, int(backdash_evento.get("tick_evento", -1)), str(backdash_evento.get("lado", "?")), bd_dir_txt_target
		])
		rollback_backdash_serial_ya_probado = bd_serial
		h1077_backdash_auto_armado = false
		h1077_backdash_tick_evento = -1
		h1077_backdash_lado = ""
		h1077_backdash_serial_evento = -1
		h1077_backdash_direccion = 0.0
	elif bool(air_evento.get("encontrado", false)):
		var air_x_localizado := int(air_evento.get("air_x", 0))
		# H10.76 target-only: si el arnés automático está armado, sólo puede
		# consumir el AIR x3 exacto que lo armó.
		if h1076_airx3_auto_armado and air_x_localizado != 3:
			rollback_test_solicitado = false
			return
		ventana = air_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "AIR HIT",
			"atacante": "%s AIR x%d" % [str(air_evento.get("lado", "?")), air_x_localizado],
		}
		print("[91.00.00-H10.88] AIR HIT EVENT LOCALIZADO — serial=%d tick=%d %s AIR x%d" % [
			int(air_evento.get("serial", -1)), int(air_evento.get("tick_evento", -1)),
			str(air_evento.get("lado", "?")), air_x_localizado
		])
		rollback_airhit_serial_ya_probado = int(air_evento.get("serial", rollback_airhit_serial_ya_probado))
		rollback_airhit_tick_ya_probado = int(air_evento.get("tick_evento", rollback_airhit_tick_ya_probado))
		if h1076_airx3_auto_armado:
			h1076_airx3_auto_armado = false
			h1076_airx3_tick_evento = -1
			h1076_airx3_lado = ""
	elif bool(launcher_evento.get("encontrado", false)):
		ventana = launcher_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "LAUNCHER",
			"atacante": "%s LAUNCHER" % str(launcher_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] LAUNCHER EVENT LOCALIZADO — serial=%d tick=%d %s" % [
			int(launcher_evento.get("serial", -1)), int(launcher_evento.get("tick_evento", -1)), str(launcher_evento.get("lado", "?"))
		])
		rollback_launcher_serial_ya_probado = int(launcher_evento.get("serial", rollback_launcher_serial_ya_probado))
		rollback_launcher_tick_ya_probado = int(launcher_evento.get("tick_evento", rollback_launcher_tick_ya_probado))
		if h1073_launcher_auto_armado:
			h1073_launcher_auto_armado = false
			h1073_launcher_tick_evento = -1
			h1073_launcher_lado = ""
	elif bool(backdash_evento.get("encontrado", false)):
		ventana = backdash_evento.get("ventana", [])
		var dir := float(backdash_evento.get("direccion", 0.0))
		var dir_txt := "IZQUIERDA" if dir < 0.0 else "DERECHA"
		analisis = {
			"valida": true,
			"clasificacion": "BACK DASH",
			"atacante": "%s BACK DASH %s" % [str(backdash_evento.get("lado", "?")), dir_txt],
		}
		print("[91.00.00-H10.88] BACKDASH EVENT LOCALIZADO — serial=%d tick=%d %s dir=%s" % [
			int(backdash_evento.get("serial", -1)), int(backdash_evento.get("tick_evento", -1)), str(backdash_evento.get("lado", "?")), dir_txt
		])
		rollback_backdash_serial_ya_probado = int(backdash_evento.get("serial", rollback_backdash_serial_ya_probado))
	elif bool(perfect_evento.get("encontrado", false)):
		ventana = perfect_evento.get("ventana", [])
		analisis = {
			"valida": true,
			"clasificacion": "PERFECT BLOCK",
			"atacante": "%s PERFECT BLOCK" % str(perfect_evento.get("lado", "?")),
		}
		print("[91.00.00-H10.88] PERFECT BLOCK EVENT LOCALIZADO — tick=%d %s; 8 ticks" % [
			int(perfect_evento.get("tick_evento", -1)), str(perfect_evento.get("lado", "?"))
		])
		rollback_perfect_tick_ya_probado = int(perfect_evento.get("tick_evento", rollback_perfect_tick_ya_probado))
		h1072_perfect_auto_armado = false
		h1072_perfect_tick_evento = -1
		h1072_perfect_lado = ""
	elif bool(counter_evento.get("encontrado", false)):
		ventana = counter_evento.get("ventana", [])
		var tipo_legible := "PUÑO" if str(counter_evento.get("tipo", "")) == "punetazo" else "PATADA"
		analisis = {
			"valida": true,
			"clasificacion": "COUNTER",
			"atacante": "%s COUNTER %s" % [str(counter_evento.get("atacante", "?")), tipo_legible],
		}
		print("[91.00.00-H10.88] COUNTER EVENT LOCALIZADO — serial=%d tick=%d %s %s" % [
			int(counter_evento.get("serial", -1)), int(counter_evento.get("tick_counter", -1)), str(counter_evento.get("atacante", "?")), tipo_legible
		])
		rollback_counter_serial_ya_probado = int(counter_evento.get("serial", rollback_counter_serial_ya_probado))
	elif bool(proyectil_evento.get("encontrado", false)):
		ventana = proyectil_evento.get("ventana", [])
		var clase_proy := str(proyectil_evento.get("clasificacion", "PROYECTIL"))
		var lado_proy := str(proyectil_evento.get("lado", "?"))
		analisis = {
			"valida": true,
			"clasificacion": clase_proy,
			"atacante": "%s %s" % [lado_proy, clase_proy],
		}
		print("[91.02.59-P13B] %s LOCALIZADO — tick=%d atacante=%s defensor=%s CORE %.3f -> %.3f" % [
			clase_proy,
			int(proyectil_evento.get("tick_evento", -1)),
			lado_proy,
			str(proyectil_evento.get("defensor", "?")),
			float(proyectil_evento.get("poder_antes", 0.0)),
			float(proyectil_evento.get("poder_despues", 0.0))
		])
	else:
		ventana = rollback_ring.ventana_desde_el_final(ROLLBACK_TEST_TICKS)
		analisis = _analizar_ventana_ataque_normal_h(ventana)

	if not bool(analisis.get("valida", false)):
		print("[91.00.00-H10.88] TACTICAL TEST — %s" % str(analisis.get(
			"motivo",
			"hacé PERFECT!, soltá bloqueo, X/C, verificá COUNTER! y después F11"
		)))
		return

	if str(analisis.get("clasificacion", "")) not in ["PERFECT BLOCK", "CORE I ENTRY", "CORE I TARGET END", "CORE I POSTER END", "CORE II ENTRY", "CORE II RECARGA END", "CORE II COMBO ENTRY", "CORE II FIRST BEAT END", "CORE II REMATADOR ENTRY", "CORE II REMATADOR POSTER END", "CORE II SEQUENCE END", "CORE III ENTRY", "CORE III RECARGA END", "CORE III APPROACH END", "CORE III FIRST BEAT END", "CORE III SECOND BEAT END", "CORE III THIRD BEAT END", "CORE III FOURTH BEAT END", "CORE III FIFTH BEAT END", "CORE III SIXTH BEAT END", "CORE III SEVENTH BEAT END", "CORE III EIGHTH BEAT END", "CORE III EIGHTEENTH BEAT END", "CORE III NINETEENTH BEAT ATTACK START", "CORE III ABSOLUTE FINISHER ENTRY", "CORE III ABSOLUTE REVEAL END", "CORE III ABSOLUTE KO ENTRY", "CORE III ABSOLUTE VICTORY ENTRY", "CORE III ABSOLUTE VICTORY HOLD", "CORE III ABSOLUTE MATCH RESET ENTRY"] and not rollback_ring.ventana_es_segura(ventana):
		print("[91.00.00-H10.88] TACTICAL TEST — la ventana localizada contiene un estado fuera del alcance H3.2")
		return

	rollback_h_clasificacion = str(analisis.get("clasificacion", "TACTICAL"))
	rollback_h_atacante = str(analisis.get("atacante", "?"))

	if rollback_h_clasificacion in ["PERFECT BLOCK", "COUNTER", "BACK DASH", "NORMAL IMPACT", "NORMAL BLOCK", "NORMAL BLOCK RECOVERY", "NORMAL ATTACK RECOVERY", "FORWARD DASH", "LAUNCHER", "AIR HIT", "PROYECTIL STARTUP", "PROYECTIL VUELO", "PROYECTIL IMPACTO CORE", "PROYECTIL BLOQUEO", "CORE I ENTRY", "CORE I TARGET END", "CORE I POSTER END", "CORE II ENTRY", "CORE II RECARGA END", "CORE III ENTRY", "CORE III RECARGA END", "CORE III APPROACH END", "CORE III FIRST BEAT END", "CORE III SECOND BEAT END", "CORE III THIRD BEAT END", "CORE III FOURTH BEAT END", "CORE III FIFTH BEAT END", "CORE III SIXTH BEAT END", "CORE III SEVENTH BEAT END", "CORE III EIGHTH BEAT END", "CORE III EIGHTEENTH BEAT END", "CORE III NINETEENTH BEAT ATTACK START", "CORE III ABSOLUTE FINISHER ENTRY", "CORE III ABSOLUTE REVEAL END", "CORE III ABSOLUTE KO ENTRY", "CORE III ABSOLUTE VICTORY ENTRY", "CORE III ABSOLUTE VICTORY HOLD", "CORE III ABSOLUTE MATCH RESET ENTRY"]:
		rollback_estado_presente_esperado = _h32_presente_historico_despues_de_ventana(ventana)
	else:
		rollback_estado_presente_esperado = RollbackSnapshotScript.capturar_partida(self, kai, rival)

	if rollback_estado_presente_esperado.is_empty():
		print("[91.00.00-H10.88] TACTICAL TEST — no pude resolver el snapshot final histórico")
		return

	rollback_catchup_ventana = ventana
	rollback_catchup_indice = 0
	rollback_tick_origen = int(ventana[0].get("tick", -1))
	rollback_subtrace_primer_error = -1
	rollback_subtrace_diferencias.clear()

	if rollback_motion_guard != null:
		if rollback_h_clasificacion in ["BACK DASH", "NORMAL IMPACT", "NORMAL BLOCK", "NORMAL BLOCK RECOVERY", "NORMAL ATTACK RECOVERY", "FORWARD DASH", "LAUNCHER", "AIR HIT", "CORE I ENTRY", "CORE I TARGET END", "CORE I POSTER END", "CORE II ENTRY", "CORE II RECARGA END", "CORE III ENTRY", "CORE III RECARGA END", "CORE III APPROACH END", "CORE III FIRST BEAT END", "CORE III SECOND BEAT END", "CORE III THIRD BEAT END", "CORE III FOURTH BEAT END", "CORE III FIFTH BEAT END", "CORE III SIXTH BEAT END", "CORE III SEVENTH BEAT END", "CORE III EIGHTH BEAT END", "CORE III EIGHTEENTH BEAT END", "CORE III NINETEENTH BEAT ATTACK START", "CORE III ABSOLUTE FINISHER ENTRY", "CORE III ABSOLUTE REVEAL END", "CORE III ABSOLUTE KO ENTRY", "CORE III ABSOLUTE VICTORY ENTRY", "CORE III ABSOLUTE VICTORY HOLD", "CORE III ABSOLUTE MATCH RESET ENTRY"]:
			# H6: estas mecánicas cambian posición/velocidad de forma causal.
			# No permitimos que Historical-X Guard esconda una divergencia aérea.
			rollback_motion_guard.cancelar()
		else:
			rollback_motion_guard.preparar_rollback(ventana, rollback_estado_presente_esperado)

	var inicio: Dictionary = ventana[0].get("snapshot", {})

	# H8.5 — durante re-simulación CORE I se reconstruye lógica, no se duplican
	# pósters/Tweens/VFX de presentación.
	if is_instance_valid(kai):
		kai.set("rollback_suprimir_presentacion_core1", true)
		kai.set("rollback_suprimir_presentacion_core2", true)
	if is_instance_valid(rival):
		rival.set("rollback_suprimir_presentacion_core1", true)
		rival.set("rollback_suprimir_presentacion_core2", true)
		rival.set("rollback_reloj_seguridad_delta_override", -1.0)

	RollbackSnapshotScript.restaurar_partida(self, kai, rival, inicio)

	if rollback_h_clasificacion in ["CORE III ENTRY", "CORE III RECARGA END", "CORE III APPROACH END", "CORE III FIRST BEAT END", "CORE III SECOND BEAT END", "CORE III THIRD BEAT END", "CORE III FOURTH BEAT END", "CORE III FIFTH BEAT END", "CORE III SIXTH BEAT END", "CORE III SEVENTH BEAT END", "CORE III EIGHTH BEAT END", "CORE III EIGHTEENTH BEAT END", "CORE III NINETEENTH BEAT ATTACK START", "CORE III ABSOLUTE FINISHER ENTRY", "CORE III ABSOLUTE REVEAL END", "CORE III ABSOLUTE KO ENTRY", "CORE III ABSOLUTE VICTORY ENTRY", "CORE III ABSOLUTE VICTORY HOLD", "CORE III ABSOLUTE MATCH RESET ENTRY"]:
		# H10.17 — no pausamos/reagendamos nodos. Las fronteras CORE III hasta SECOND BEAT END usan
		# delta histórico explícito desde el primer subtick.
		# puede entregar deltas distintos al reactivar callbacks dentro de una
		# transición de time_scale. En su lugar, cada subtick recibe explícitamente
		# el delta histórico que usó LIVE.
		rollback_catchup_inicio_timescale = {}
		rollback_catchup_preparando_timescale = false
		rollback_catchup_reactivar_tactico_next_tick = false
		rollback_catchup_reactivacion_deferred_pendiente = false
		rollback_catchup_barrier_frames_restantes = 0
		rollback_catchup_commit_restore_pendiente = false
		rollback_catchup_activo = true
		if is_instance_valid(kai):
			kai.set_physics_process(true)
		if is_instance_valid(rival):
			rival.set_physics_process(true)
		if is_instance_valid(PerfectBlock90_1):
			PerfectBlock90_1.set_physics_process(true)
		print("[91.00.00-H10.88] CORE III HISTORICAL DELTA ARMADO — restore exacto; catch-up inicia sin barreras de scheduler")
	else:
		rollback_catchup_activo = true

	print("[91.00.00-H10.88] TACTICAL ROLLBACK — %s — %s — tick %d -> histórico; %d ticks" % [
		rollback_h_clasificacion,
		rollback_h_atacante,
		rollback_tick_origen,
		rollback_catchup_ventana.size()
	])


func _finalizar_prueba_rollback_local() -> void:
	rollback_comparacion_pendiente = false
	if rollback_estado_presente_esperado.is_empty():
		return

	var actual: Dictionary = RollbackSnapshotScript.capturar_partida(self, kai, rival)
	var diferencias: Array[String] = RollbackSnapshotScript.comparar_snapshots(
		rollback_estado_presente_esperado, actual
	)

	if diferencias.is_empty() and rollback_subtrace_primer_error < 0:
		print("[91.00.00-H10.88] TACTICAL ROLLBACK OK — %s — %d ticks; estado presente idéntico" % [
			rollback_h_clasificacion, ROLLBACK_TEST_TICKS
		])
	elif diferencias.is_empty() and rollback_subtrace_primer_error >= 0:
		print("[91.00.00-H10.88] TACTICAL TEMPORAL DESYNC — %s — subtick %d aunque el presente volvió a coincidir" % [
			rollback_h_clasificacion, rollback_subtrace_primer_error
		])
	else:
		print("[91.00.00-H10.88] TACTICAL ROLLBACK DESYNC — %s — %d diferencia(s) tras %d ticks" % [
			rollback_h_clasificacion, diferencias.size(), ROLLBACK_TEST_TICKS
		])
		for i in range(mini(diferencias.size(), 20)):
			print("  • " + diferencias[i])

	var h1087_ok := diferencias.is_empty() and rollback_subtrace_primer_error < 0
	_h1087_integral_resultado(h1087_ok, rollback_h_clasificacion)

	rollback_estado_presente_esperado = {}
	rollback_catchup_ventana.clear()
	rollback_catchup_indice = 0
	rollback_catchup_preparando_timescale = false
	rollback_catchup_inicio_timescale = {}
	rollback_catchup_reactivar_tactico_next_tick = false
	rollback_catchup_reactivacion_deferred_pendiente = false
	rollback_catchup_barrier_frames_restantes = 0
	rollback_catchup_commit_restore_pendiente = false
	rollback_tick_origen = -1

	if is_instance_valid(kai):
		kai.set_physics_process(true)
		kai.set("rollback_delta_override", -1.0)
	if is_instance_valid(rival):
		rival.set_physics_process(true)
		rival.set("rollback_delta_override", -1.0)
		rival.set("rollback_reloj_seguridad_delta_override", -1.0)
	if is_instance_valid(PerfectBlock90_1):
		PerfectBlock90_1.set_physics_process(true)
		PerfectBlock90_1.set("rollback_delta_override", -1.0)
	rollback_subtrace_primer_error = -1
	rollback_subtrace_diferencias.clear()
	rollback_h_clasificacion = ""
	rollback_h_atacante = ""

	# Volver a habilitar presentación sólo después de comparar el catch-up.
	if is_instance_valid(kai):
		kai.set("rollback_suprimir_presentacion_core1", false)
		kai.set("rollback_suprimir_presentacion_core2", false)
	if is_instance_valid(rival):
		rival.set("rollback_suprimir_presentacion_core1", false)
		rival.set("rollback_suprimir_presentacion_core2", false)

	if rollback_motion_guard != null:
		rollback_motion_guard.cancelar()


func _snapshot_estado_rollback_h_seguro() -> bool:
	# 91.00.00-H10.13 — alcance táctico controlado.
	# Permitimos:
	# - ataque normal
	# - bloqueo normal
	# - Perfect Block
	# - Counter posterior a Perfect
	# - Launcher + persecución aérea + Air Combo
	# - hitstop / hitstun / empuje / contacto post-golpe
	#
	# Todavía NO permitimos CORE, combos automáticos, derribos, KO ni cinemáticas.
	if not versus_local_activo or replay_modo_activo:
		return false
	if not ronda_activa or congelando_ko or absf(Engine.time_scale - 1.0) > 0.001:
		return false
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return false

	for personaje in [kai, rival]:
		if personaje.esta_derrotado or personaje.en_pose_victoria:
			return false
		if personaje.en_secuencia_especial or personaje.bloqueo_cinematico:
			return false
		if personaje.congelado_por_rival or personaje.en_combo_auto_visual:
			return false
		if personaje.en_fase_absoluta or personaje.en_pose_recarga:
			return false
		if personaje.derribo_especial_activo:
			return false
	return true

func _analizar_ventana_ataque_normal_h(ventana: Array[Dictionary]) -> Dictionary:
	var j1_ataco := false
	var j2_ataco := false
	var j1_bloqueo := false
	var j2_bloqueo := false
	var hubo_impacto := false
	var hubo_counter_j1 := false
	var hubo_counter_j2 := false
	var tipo_j1 := ""
	var tipo_j2 := ""

	var id_j1: int = kai.get_instance_id() if is_instance_valid(kai) else -1
	var id_j2: int = rival.get_instance_id() if is_instance_valid(rival) else -1

	for entrada in ventana:
		var in1: Dictionary = entrada.get("j1", {})
		var in2: Dictionary = entrada.get("j2", {})

		# H3 sigue excluyendo CORE/especial.
		if bool(in1.get("especial", false)) or bool(in2.get("especial", false)):
			return {
				"valida": false,
				"motivo": "CORE/especial detectado; H3 prueba solamente contacto táctico normal"
			}

		j1_bloqueo = j1_bloqueo or bool(in1.get("bloqueo", false))
		j2_bloqueo = j2_bloqueo or bool(in2.get("bloqueo", false))

		if bool(in1.get("puno", false)):
			j1_ataco = true
			tipo_j1 = "PUÑO"
		if bool(in1.get("patada", false)):
			j1_ataco = true
			tipo_j1 = "PATADA"
		if bool(in2.get("puno", false)):
			j2_ataco = true
			tipo_j2 = "PUÑO"
		if bool(in2.get("patada", false)):
			j2_ataco = true
			tipo_j2 = "PATADA"

		var snap: Dictionary = entrada.get("snapshot", {})
		var s1: Dictionary = snap.get("j1", {})
		var s2: Dictionary = snap.get("j2", {})
		var tactico: Dictionary = snap.get("tactico", {})

		# Estado de ataque también identifica un botón que comenzó justo antes
		# del borde de los últimos 8 ticks.
		var atk1: String = str(s1.get("_atk_tipo", ""))
		var atk2: String = str(s2.get("_atk_tipo", ""))
		if int(s1.get("fase_ataque", 0)) != 0 and atk1 in ["punetazo", "patada"]:
			j1_ataco = true
			if tipo_j1.is_empty():
				tipo_j1 = "PUÑO" if atk1 == "punetazo" else "PATADA"
		if int(s2.get("fase_ataque", 0)) != 0 and atk2 in ["punetazo", "patada"]:
			j2_ataco = true
			if tipo_j2.is_empty():
				tipo_j2 = "PUÑO" if atk2 == "punetazo" else "PATADA"

		# Un Perfect Block confirmado abre _counter_disponible para el defensor.
		var counter_disp: Dictionary = tactico.get("_counter_disponible", {})
		if bool(counter_disp.get(id_j1, false)):
			hubo_counter_j1 = true
		if bool(counter_disp.get(id_j2, false)):
			hubo_counter_j2 = true

		# Señales de contacto real.
		if bool(s1.get("_atk_ya_conecto", false)) or bool(s2.get("_atk_ya_conecto", false)):
			hubo_impacto = true
		if float(s1.get("hitstun_timer", 0.0)) > 0.0 or float(s2.get("hitstun_timer", 0.0)) > 0.0:
			hubo_impacto = true
		if float(s1.get("hitstop_timer", 0.0)) > 0.0 or float(s2.get("hitstop_timer", 0.0)) > 0.0:
			hubo_impacto = true
		if float(s1.get("contacto_post_golpe_timer", 0.0)) > 0.0 or float(s2.get("contacto_post_golpe_timer", 0.0)) > 0.0:
			hubo_impacto = true

	# COUNTER: ambos llegaron a atacar dentro de la ventana y uno de ellos tuvo
	# la oportunidad de Counter abierta por Perfect Block.
	if j1_ataco and j2_ataco:
		if hubo_counter_j1:
			return {
				"valida": true,
				"atacante": "J1 COUNTER %s" % (tipo_j1 if not tipo_j1.is_empty() else "ATAQUE"),
				"clasificacion": "COUNTER"
			}
		if hubo_counter_j2:
			return {
				"valida": true,
				"atacante": "J2 COUNTER %s" % (tipo_j2 if not tipo_j2.is_empty() else "ATAQUE"),
				"clasificacion": "COUNTER"
			}
		return {
			"valida": false,
			"motivo": "ataque simultáneo sin ventana Counter; H3 necesita una secuencia Perfect→Counter"
		}

	if not j1_ataco and not j2_ataco:
		return {
			"valida": false,
			"motivo": "no hay ataque normal dentro de los últimos 8 ticks"
		}

	var atacante := "J1 %s" % tipo_j1 if j1_ataco else "J2 %s" % tipo_j2

	# Perfect Block confirmado: la oportunidad Counter del defensor se abrió.
	if (j1_ataco and hubo_counter_j2) or (j2_ataco and hubo_counter_j1):
		return {
			"valida": true,
			"atacante": atacante,
			"clasificacion": "PERFECT BLOCK"
		}

	# Bloqueo normal sin ventana Perfect.
	if (j1_ataco and j2_bloqueo) or (j2_ataco and j1_bloqueo):
		return {
			"valida": true,
			"atacante": atacante,
			"clasificacion": "BLOQUEO"
		}

	return {
		"valida": true,
		"atacante": atacante,
		"clasificacion": "IMPACTO" if hubo_impacto else "WHIFF/FASE"
	}


func _snapshot_estado_seguro() -> bool:
	if not versus_local_activo or replay_modo_activo:
		return false
	if not ronda_activa or congelando_ko or absf(Engine.time_scale - 1.0) > 0.001:
		return false
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return false
	for personaje in [kai, rival]:
		if personaje.en_secuencia_especial or personaje.bloqueo_cinematico:
			return false
		if personaje.fase_ataque != Fighter.FaseAtaque.NINGUNA:
			return false
		if personaje.hitstun_timer > 0.0 or personaje.hitstop_timer > 0.0:
			return false
		if personaje.derribo_especial_activo or personaje.en_pose_victoria:
			return false
	return true

func _guardar_snapshot_manual() -> void:
	if not _snapshot_estado_seguro():
		print("[91.00.00-H10.88] SNAPSHOT NO GUARDADO — esperá un instante neutral de la ronda")
		return
	rollback_snapshot_manual = RollbackSnapshotScript.capturar_partida(self, kai, rival)
	rollback_snapshot_disponible = not rollback_snapshot_manual.is_empty()
	if not rollback_snapshot_disponible:
		print("[91.00.00-H10.88] SNAPSHOT ERROR — no se pudo capturar estado")
		return
	var bytes_aprox := var_to_bytes(rollback_snapshot_manual).size()
	print("[91.00.00-H10.88] SNAPSHOT GUARDADO — J1=(%.2f, %.2f) J2=(%.2f, %.2f) — %d bytes" % [
		kai.position.x, kai.position.y, rival.position.x, rival.position.y, bytes_aprox
	])

func _restaurar_snapshot_manual() -> void:
	if not rollback_snapshot_disponible or rollback_snapshot_manual.is_empty():
		print("[91.00.00-H10.88] RESTORE CANCELADO — primero presioná F9")
		return
	if not _snapshot_estado_seguro():
		print("[91.00.00-H10.88] RESTORE EN ESPERA — soltá controles y esperá un estado neutral")
		return
	RollbackSnapshotScript.restaurar_partida(self, kai, rival, rollback_snapshot_manual)
	var recapturado: Dictionary = RollbackSnapshotScript.capturar_partida(self, kai, rival)
	var diferencias: Array[String] = RollbackSnapshotScript.comparar_snapshots(rollback_snapshot_manual, recapturado)
	if diferencias.is_empty():
		print("[91.00.00-H10.88] SNAPSHOT RESTORE OK — estado lógico restaurado exactamente")
	else:
		print("[91.00.00-H10.88] SNAPSHOT RESTORE DESYNC — %d diferencia(s)" % diferencias.size())
		for i in range(mini(diferencias.size(), 12)):
			print("  • " + diferencias[i])

func _unhandled_input(event: InputEvent) -> void:
	# 91.00.00-H: F9/F10 son diagnóstico de snapshot incluso cuando el combate
	# fue abierto desde el flujo normal de menú.
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_F9:
			_guardar_snapshot_manual()
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_F10:
			_restaurar_snapshot_manual()
			get_viewport().set_input_as_handled()
			return
		if event.physical_keycode == KEY_F11:
			if not rollback_test_solicitado and not rollback_catchup_activo and not rollback_comparacion_pendiente:
				rollback_test_solicitado = true
				print("[91.00.00-H10.88] ROLLBACK SOLICITADO — próximo physics tick")
			get_viewport().set_input_as_handled()
			return

	# 90.10.78: fuera del diagnóstico se conserva exactamente el manejo previo.
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
			KEY_9:
				_cambiar_rival(Xenoid.new())
			KEY_0:
				_cambiar_rival(Dax.new())
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
			KEY_O:
				_cambiar_jugador(_crear_luchador("Xenoid"))
			KEY_P:
				_cambiar_jugador(_crear_luchador("Dax"))

# FASE 90.10.22 — DYNAMIC FIGHT CAMERA CLOSE COMBAT FINAL.
# Conserva EXACTAMENTE la apertura a distancia de 90.10.21 y añade sólo un
# toque extra de acercamiento cuando los luchadores ya están cuerpo a cuerpo.
# La distancia media y lejana no cambian.
func _zoom_camara_por_separacion(separacion: float) -> float:
	if separacion <= 160.0:
		return CAM_ZOOM_CERCA
	if separacion <= 300.0:
		return lerpf(CAM_ZOOM_CERCA, 1.075, (separacion - 160.0) / 140.0)
	if separacion <= 500.0:
		return lerpf(1.075, CAM_ZOOM_NORMAL, (separacion - 300.0) / 200.0)
	if separacion <= 760.0:
		return lerpf(CAM_ZOOM_NORMAL, CAM_ZOOM_LEJOS, (separacion - 500.0) / 260.0)
	return CAM_ZOOM_LEJOS

# Calcula un encuadre seguro para la pelea normal. Importante: el centro se
# obtiene a partir de los DOS luchadores, no del jugador, y los límites X se
# adaptan al zoom para aprovechar el overscan del fondo sin enseñar bordes.
func _objetivo_camara_combate(separacion_filtrada: float = -1.0) -> Dictionary:
	if not is_instance_valid(kai) or not is_instance_valid(rival):
		return {"centro": Vector2(ANCHO_ARENA * 0.5, 360.0), "zoom": 1.0}

	var medio: Vector2 = (kai.global_position + rival.global_position) * 0.5
	var separacion_real: float = absf(kai.global_position.x - rival.global_position.x)
	var separacion: float = separacion_real if separacion_filtrada < 0.0 else separacion_filtrada
	var zoom_objetivo: float = _zoom_camara_por_separacion(separacion)

	# Cuando empiezan a repartir golpes hacemos un punch-in moderado sobre el
	# zoom de distancia. Se nota más que en 90.10.19, pero sigue siendo cámara
	# de combate y no una mini-cinemática por cada puño.
	var ataques_activos := 0
	var foco_ataque_x := 0.0
	for luchador in [kai, rival]:
		if is_instance_valid(luchador) and luchador.fase_ataque != Fighter.FaseAtaque.NINGUNA:
			ataques_activos += 1
			foco_ataque_x += float(luchador.mirando) * 26.0
	if ataques_activos > 0:
		zoom_objetivo += 0.015
	if ataques_activos > 1:
		zoom_objetivo += 0.006

	if pulso_cam_combate > 0.0:
		zoom_objetivo += 0.010 + pulso_cam_combate * 0.018

	# En dash/carrera abrimos apenas para que el movimiento rápido tenga aire
	# por delante y no se sienta como si chocara contra el borde del encuadre.
	if absf(kai.velocity.x) > 280.0 or absf(rival.velocity.x) > 280.0:
		zoom_objetivo -= 0.018
	zoom_objetivo = clampf(zoom_objetivo, CAM_ZOOM_LEJOS, 1.205)

	# Arrastre conjunto: si ambos se desplazan hacia el mismo lado, el centro
	# de cámara anticipa unos píxeles la dirección general de la acción.
	var velocidad_conjunta: float = (kai.velocity.x + rival.velocity.x) * 0.5
	# Arrastre conjunto: la cámara anticipa levemente la dirección general
	# de la acción, también en Versus Local.
	var arrastre_x: float = clampf(velocidad_conjunta * 0.045, -30.0, 30.0)
	var objetivo_x: float = medio.x + foco_ataque_x * 0.38 + arrastre_x

	if foco_impacto_timer > 0.0:
		objetivo_x = lerpf(objetivo_x, foco_impacto_camara_x, 0.30)

	# Calculamos cuánto puede desplazarse la cámara sin mostrar vacío lateral.
	# Los fondos normales usan 1.18x; TRONO DEL NÚCLEO usa 1.08x, por lo que
	# necesita límites de cámara basados en su overscan real y no en el global.
	var mitad_vista_x: float = 640.0 / maxf(zoom_objetivo, 0.01)
	var overscan_x_actual: float = CAM_FONDO_OVERSCAN_X
	if _escenario_redisenado(escenario_nombre_actual):
		overscan_x_actual = ANCHO_ARENA * 0.04 # (1.08 - 1.0) / 2
	var limite_x_min: float = -overscan_x_actual + mitad_vista_x + 8.0
	var limite_x_max: float = ANCHO_ARENA + overscan_x_actual - mitad_vista_x - 8.0
	if limite_x_min <= limite_x_max:
		objetivo_x = clampf(objetivo_x, limite_x_min, limite_x_max)
	else:
		objetivo_x = ANCHO_ARENA * 0.5

	# Seguimiento vertical deliberadamente más sutil que el horizontal. Si uno
	# o ambos saltan, la cámara acompaña un poco hacia arriba pero mantiene el
	# suelo como referencia para evitar mareo.
	var altura_accion: float = clampf(SUELO_Y - medio.y, 0.0, 220.0)
	var objetivo_y: float = 360.0 - altura_accion * 0.15
	objetivo_y = clampf(objetivo_y, 332.0, 372.0)

	return {"centro": Vector2(objetivo_x, objetivo_y), "zoom": zoom_objetivo}

func _process(delta: float) -> void:
	escenario_tiempo += delta
	_perf1_log_fps(delta)
	if not modo_bajo_visual:
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
		# Filtramos la distancia antes de transformarla en zoom. Esto evita el
		# efecto acordeón cuando un knockback separa a los luchadores de golpe.
		var separacion_real: float = absf(kai.global_position.x - rival.global_position.x)
		var alpha_separacion: float = 1.0 - exp(-4.2 * delta)
		camara_separacion_suave = lerpf(camara_separacion_suave, separacion_real, alpha_separacion)
		var datos_camara := _objetivo_camara_combate(camara_separacion_suave)
		var centro_objetivo: Vector2 = datos_camara.get("centro", Vector2(ANCHO_ARENA * 0.5, 360.0))
		var zoom_objetivo: float = float(datos_camara.get("zoom", 1.0))
		# El paneo responde un poco más rápido que el zoom: la cámara sigue la
		# acción sin retraso, pero el acercamiento/alejamiento se siente pesado y
		# cinematográfico en vez de nervioso.
		# CORE III puede recorrer gran parte de la arena en unas décimas. Durante
		# esa secuencia el paneo debe acompañar al luchador, no perseguirlo tarde.
		# CORE I/II y la cámara normal conservan exactamente su respuesta previa.
		var core3_en_secuencia: bool = \
			(kai.en_secuencia_especial and kai.veces_fase_absoluta >= 3) or \
			(rival.en_secuencia_especial and rival.veces_fase_absoluta >= 3)
		var velocidad_paneo: float = 15.0 if core3_en_secuencia else 6.2
		var alpha_camara: float = 1.0 - exp(-velocidad_paneo * delta)
		camara.position = camara.position.lerp(centro_objetivo, alpha_camara)
		# 90.10.21: se conserva la respuesta asimétrica de V2; sólo ajustamos amplitud.
		# Así el cuerpo a cuerpo gana presencia, mientras que al separarse la
		# cámara recupera aire con suavidad y sin efecto acordeón.
		var zoom_actual: float = camara.zoom.x
		var velocidad_zoom: float = 5.2 if zoom_objetivo > zoom_actual else 3.0
		var alpha_zoom: float = 1.0 - exp(-velocidad_zoom * delta)
		camara.zoom = camara.zoom.lerp(Vector2.ONE * zoom_objetivo, alpha_zoom)

	if foco_impacto_timer > 0.0:
		foco_impacto_timer = maxf(0.0, foco_impacto_timer - delta)
	pulso_cam_combate = move_toward(pulso_cam_combate, 0.0, 7.5 * delta)

	var ajustes_shake := get_node_or_null("/root/SettingsManager")
	var shake_habilitado: bool = ajustes_shake == null or bool(ajustes_shake.get("shake_camara"))
	if not shake_habilitado:
		shake_tiempo = 0.0
		shake_fuerza = 0.0
		camara.offset = Vector2.ZERO
	elif shake_tiempo > 0.0:
		shake_tiempo -= delta
		shake_reloj -= delta
		if shake_reloj <= 0.0:
			shake_reloj = shake_intervalo
			camara.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * shake_fuerza
		if shake_tiempo <= 0.0:
			camara.offset = Vector2.ZERO

	_h910205_actualizar_dash_visual_presentacion()


# 91.02.05/91.02.06/91.02.07 — GUARD VISUAL DE DASH / BACK DASH.
# Presentación aislada de la simulación: NO escribe texture/scale/position en el
# Sprite2D real de Fighter porque ese nodo participa indirectamente en cálculos
# de volumen visual del pushbox. En su lugar usa un Sprite2D gemelo sólo para
# render y oculta temporalmente el sprite base. Así no altera Fighter, snapshots,
# timers, pose_timer, colisión, movimiento ni la frontera rollback certificada.
const H910205_DASH_OVERLAY_NAME := "DashVisualOverlay_910205"
const H910205_OFFSET_LINEA_COMBATE_Y := 28.0 # espejo del valor congelado de Fighter
const H910205_CORE_ETAPA_ACERCAMIENTO := 2

func _h910205_obtener_overlay_dash(f: Fighter) -> Sprite2D:
	if not is_instance_valid(f) or not is_instance_valid(f.sprite):
		return null
	var existente := f.get_node_or_null(H910205_DASH_OVERLAY_NAME) as Sprite2D
	if existente:
		return existente
	var overlay := Sprite2D.new()
	overlay.name = H910205_DASH_OVERLAY_NAME
	overlay.centered = true
	overlay.visible = false
	# Es hermano del sprite real dentro del Fighter; se crea después y queda por
	# encima cuando ambos comparten z. El sprite real se oculta durante el guard.
	f.add_child(overlay)
	return overlay

func _h910205_textura_dash_adelante(f: Fighter) -> Texture2D:
	if not is_instance_valid(f):
		return null
	# CORE II/III siempre avanzan hacia el rival. No usamos _tex_carrera() aquí
	# porque carrera_direccion puede contener un valor histórico de back dash.
	if f.en_fase_absoluta and f.textura_furia_carrera:
		return f.textura_furia_carrera
	if f.textura_carrera:
		return f.textura_carrera

	# 91.02.07 — algunos luchadores históricos (Fang es el caso confirmado)
	# poseen el PNG de aceleración en assets pero su script nunca lo asignó a
	# textura_carrera. En vez de tocar Fighter o la física certificada, el guard
	# visual recupera de forma pasiva un asset de dash existente. Esta ruta sólo
	# decide qué Texture2D renderizar durante el impulso.
	if f.textura_parado:
		var base_assets: String = f.textura_parado.resource_path.get_base_dir()
		var candidatos: Array[String]
		if f.en_fase_absoluta:
			candidatos = [
				"aceleracion_furia.png", "aceleración_furia.png",
				"furia_carrera.png", "furia_dash.png", "dash_furia.png"
			]
		else:
			candidatos = [
				"aceleracion_normal.png", "aceleración_normal.png",
				"aceleracion.png", "aceleración.png",
				"carrera.png", "dash.png", "dash_adelante.png", "avance.png"
			]
		for nombre_asset in candidatos:
			var ruta: String = base_assets + "/" + nombre_asset
			if ResourceLoader.exists(ruta):
				var tex: Texture2D = load(ruta)
				if tex:
					return tex
	return null

func _h910205_es_acercamiento_core23(f: Fighter) -> bool:
	if not is_instance_valid(f) or not f.en_secuencia_especial:
		return false
	return (
		f.core2_secuencia_etapa == H910205_CORE_ETAPA_ACERCAMIENTO
		or f.core3_secuencia_etapa == H910205_CORE_ETAPA_ACERCAMIENTO
	)

# 91.02.06 — el Back Dash táctico de suelo NO usa carrera_activa.
# PerfectBlock90_1 cancela la carrera normal al aceptar el doble toque hacia
# atrás y gobierna el desplazamiento con su propio _backdash_timer. Por eso
# 91.02.05 nunca entraba al guard visual en suelo aunque el movimiento sí se
# ejecutara. Leemos ese timer sólo para presentación; no escribimos gameplay.
func _h910206_backdash_tactico_suelo_activo(f: Fighter) -> bool:
	if not is_instance_valid(f) or not f.is_on_floor():
		return false
	if f.en_secuencia_especial or f.esta_derrotado or f.derribo_especial_activo:
		return false
	if f.hitstun_timer > 0.0 or f.bloqueando:
		return false
	if f.fase_ataque != Fighter.FaseAtaque.NINGUNA:
		return false
	var tactico := get_node_or_null("/root/PerfectBlock90_1")
	if tactico == null:
		return false
	var timers: Dictionary = tactico.get("_backdash_timer")
	return float(timers.get(f.get_instance_id(), 0.0)) > 0.0

func _h910205_dash_normal_debe_mostrarse(f: Fighter) -> bool:
	if not is_instance_valid(f) or not f.carrera_activa:
		return false
	if f.en_secuencia_especial or f.esta_derrotado or f.derribo_especial_activo:
		return false
	if f.hitstun_timer > 0.0 or f.bloqueando or not f.is_on_floor():
		return false
	# Un golpe iniciado durante la carrera tiene prioridad visual sobre el dash.
	return f.fase_ataque == Fighter.FaseAtaque.NINGUNA

func _h910205_apagar_overlay_dash(f: Fighter) -> void:
	if not is_instance_valid(f):
		return
	var overlay := f.get_node_or_null(H910205_DASH_OVERLAY_NAME) as Sprite2D
	if overlay:
		overlay.visible = false
	if is_instance_valid(f.sprite):
		f.sprite.visible = true

func _h910205_mostrar_overlay_dash(f: Fighter, tex: Texture2D) -> void:
	if not is_instance_valid(f) or not is_instance_valid(f.sprite) or not tex:
		_h910205_apagar_overlay_dash(f)
		return
	var overlay := _h910205_obtener_overlay_dash(f)
	if not overlay:
		return

	# Normalización idéntica a la visual de Fighter, pero aplicada sólo al gemelo.
	# Llamar estos helpers sólo lee configuración; el único side effect posible es
	# poblar el cache de rects alfa, que no forma parte del estado de gameplay.
	var rect: Rect2 = f._obtener_rect_visual(tex)
	var escala: float = f._escala_normalizada_por_pose(tex, rect)
	var bottom_visible: float = rect.position.y + rect.size.y
	var half_h: float = float(tex.get_height()) * 0.5

	overlay.texture = tex
	overlay.scale = Vector2(escala, escala)
	overlay.position = Vector2(f._sprite_ancla_x(), H910205_OFFSET_LINEA_COMBATE_Y + (half_h - bottom_visible) * escala)
	overlay.rotation = f.sprite.rotation
	overlay.flip_h = f.sprite.flip_h
	overlay.flip_v = f.sprite.flip_v
	overlay.modulate = f.sprite.modulate
	overlay.self_modulate = f.sprite.self_modulate
	overlay.texture_filter = f.sprite.texture_filter
	overlay.z_index = f.sprite.z_index
	overlay.z_as_relative = f.sprite.z_as_relative
	overlay.visible = true
	f.sprite.visible = false

func _h910205_actualizar_dash_visual_fighter(f: Fighter) -> void:
	if not is_instance_valid(f) or not is_instance_valid(f.sprite):
		return
	# 91.02.06 — prioridad explícita al Back Dash táctico de SUELO.
	# Fighter.texture_evasion ya fue cargada desde el PNG oficial del personaje.
	# Si un roster viejo no posee evasión dedicada, usamos carrera sólo como
	# fallback visual sin alterar el movimiento ni el timer táctico.
	if _h910206_backdash_tactico_suelo_activo(f):
		var tex_evasion: Texture2D = f._tex_evasion()
		_h910205_mostrar_overlay_dash(f, tex_evasion if tex_evasion else f.textura_carrera)
		return
	if _h910205_es_acercamiento_core23(f):
		_h910205_mostrar_overlay_dash(f, _h910205_textura_dash_adelante(f))
		return
	if _h910205_dash_normal_debe_mostrarse(f):
		# _tex_carrera() selecciona EVASIÓN cuando el impulso se aleja del rival
		# y CARRERA cuando entra hacia él. 91.02.07 agrega un fallback visual para
		# rosters históricos que sí tienen aceleración.png pero no textura_carrera.
		var tex_dash: Texture2D = f._tex_carrera()
		if tex_dash == null and not f._es_backdash_activo():
			tex_dash = _h910205_textura_dash_adelante(f)
		_h910205_mostrar_overlay_dash(f, tex_dash)
		return
	_h910205_apagar_overlay_dash(f)

func _h910205_actualizar_dash_visual_presentacion() -> void:
	# El guard corre en _process después de la simulación física de ambos Fighter.
	# No se ejecuta durante catch-up de rollback: la re-simulación no necesita
	# presentación y evitamos cualquier ruido visual durante el diagnóstico.
	if (
		rollback_catchup_activo
		or rollback_catchup_preparando_timescale
		or rollback_catchup_barrier_frames_restantes > 0
		or rollback_catchup_commit_restore_pendiente
	):
		_h910205_apagar_overlay_dash(kai)
		_h910205_apagar_overlay_dash(rival)
		return
	_h910205_actualizar_dash_visual_fighter(kai)
	_h910205_actualizar_dash_visual_fighter(rival)


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
	if modo_bajo_visual:
		return
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
