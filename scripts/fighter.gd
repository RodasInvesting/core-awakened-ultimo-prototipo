class_name Fighter
# CORE AWAKENED 91.02.37 — PASS 9.4H RETROCESO GLOBAL CORE I EXCLUSIVAS.
# Ajuste fino visual general: TODAS las gigantografias exclusivas de CORE I
# se desplazan un poco mas hacia atras para despegarse mejor del cuerpo real.
# Se mantiene la calibracion extra de Cibor-X y Magnus incorporada en 91.02.36.
# CORE AWAKENED 91.02.36 — PASS 9.4G CALIBRACION CORE I CIBOR/MAGNUS.
# Ajuste fino visual: las gigantografias exclusivas de Cibor-X y Magnus
# en CORE I se hacen un poco mas grandes y se desplazan mas hacia atras
# para que se lean mejor sin tapar el cuerpo real del luchador.
# CORE AWAKENED 91.02.35 — PASS 9.4F CORE I GIGANTOGRAFIAS EXCLUSIVAS.
# Los PNG exclusivos enviados por el usuario pasan a mostrarse en el
# golpe/poster de CORE I. CORE II vuelve a quedar limpio en la recarga
# y conserva su flujo historico: recarga -> combo -> gigantografia final.
# CORE AWAKENED 91.02.34 — PASS 9.4E CORE II SCREEN-SAFE DETRAS DEL LUCHADOR.
# Conserva el calculo screen-safe de 91.02.33, pero la gigantografia ya
# no vive en CanvasLayer frontal: vuelve al mundo 2D, en coordenadas
# derivadas de la camara y con z_index detras de los luchadores.
# Asi deja de tapar al personaje en doble salto y deja de verse adelante
# en esquina, sin perder composicion segura ni tocar combate/rollback.
# CORE AWAKENED 91.02.33 — PASS 9.4D GIGANTOGRAFIA CORE II SCREEN-SAFE.
# La gigantografia exclusiva deja de depender de global_position del Fighter:
# se presenta en coordenadas de pantalla, con margenes seguros y escala fit.
# Doble salto, apice y esquinas ya no pueden expulsar el PNG del viewport.
# Camara 9.4C, combate, CORE III y rollback quedan intactos.
# CORE AWAKENED 91.02.32 — PASS 9.4C ENCUADRE ABIERTO CORE II.
# CORE II deja de aceptar el punch-in 1.18 de la recarga: durante sus 1.05 s
# usa un encuadre abierto/adaptativo que prioriza la gigantografia completa,
# incluso si se activa desde el aire. Al terminar, devuelve la camara al sistema
# dinamico normal. CORE III conserva intacto su zoom epico/camara lenta.
# CORE AWAKENED 91.02.31 — PASS 9.4B CORE II / GIGANTOGRAFIA EXCLUSIVA DE ENTRADA.
# Usa PNG dedicados por personaje para la presentacion previa al combo de CORE II.
# La aparicion ocurre DENTRO de la recarga existente: no agrega tiempo nuevo,
# no cambia la rafaga y no toca rollback/snapshots.
# CORE AWAKENED 91.02.30 — PASS 9.4A CORE II / GIGANTOGRAFIA FLASH.
# Presentacion PURAMENTE VISUAL: durante los ultimos ~0.42 s de la recarga
# existente aparece un flash breve de la gigantografia CORE II detras del cuerpo.
# No agrega tiempo a la secuencia, no retrasa la rafaga y no modifica snapshots.
# El poster final/rematador conserva su presentacion grande original.
# CORE AWAKENED 91.02.29 — PASS 9.3E MOVILIDAD AEREA / ATERRIZAJE.
# El salto, doble salto, gravedad, altura y air dash conservan sus valores.
# Al tocar suelo, un ataque normal que YA está en RECOVERY queda limitado a
# una salida corta (~2 frames a 60 Hz), y una pose de movilidad aérea residual
# se libera en el mismo aterrizaje para pasar directo a caminar/parado.
# Nunca cancela STARTUP/ACTIVO, hitstun, derribo, CORE ni cinematica.
# CORE AWAKENED 91.02.28 — PASS 9.3D HIT-STOP / IMPACTO NORMAL.
# Recalibra el micro-hitstop LOCAL ya existente: ~2 frames de lectura en puño
# y ~2-3 frames en patada a 60 Hz, sincronizando mejor atacante/receptor.
# Solo aplica a impactos normales LIMPIOS fuera de CORE/Furia/cinematica.
# Bloqueo, CORE, hitstun, daño, knockback, recovery y rollback quedan intactos.
# CORE AWAKENED 91.02.27 — PASS 9.3C CONTINUIDAD VISUAL CORE.
# Auditoria Dax/roster: los timings CORE II/III quedan EXACTAMENTE iguales.
# Durante la rafaga, un sprite ofensivo ya mostrado no puede ser reemplazado
# por reposo/caminata/aceleracion durante RECOVERY o microacercamientos.
# El siguiente golpe sustituye directamente al anterior. Esto cubre tambien
# Aethel y Varkhos sin tocar sus scripts ni sus poses iniciales de aceleracion.
# CORE AWAKENED 91.02.26 — PASS 9.3B ACELERACION / FRENO TERRESTRE.
# Segundo paso de dinamica contra referencias: la velocidad maxima NO cambia.
# Solo el movimiento terrestre normal alcanza antes su velocidad objetivo y
# frena antes al soltar direccion. Aire, dash, footwork de ataque, CORE,
# pushbox, recovery 9.3A y rollback quedan intactos.
# CORE AWAKENED 91.02.25 — PASS 9.3A RECOVERY / TRANSICIONES NORMALES.
# Primer paso de dinamica contra referencias: se acorta SOLO el recovery logico
# de puños/patadas normales. Pose visible, startup, activo, rango, hitbox, hitstun,
# hitstop, daño, knockback, movimiento, pushbox, CORE y rollback quedan intactos.
# El buffer humano existente consume el siguiente golpe en el primer frame legal.
# CORE AWAKENED 91.02.24 — PASS 9.2C CALIBRACION ROCE CORPORAL.
# Punto medio entre 91.02.22 (demasiada penetracion) y 91.02.23
# (separacion perceptible): neutral 78 px, precontacto 80 px y torso 84 px.
# Conserva rescate residual, prioridad del hitbox y exclusion total de CORE.
# CORE AWAKENED 91.02.23 — PASS 9.2B CONTACTO CORPORAL EN COMBATE.
# Conserva el roce neutral de 91.02.22 y extiende la protección de torso a
# ataques normales, trades, hitstun y bloqueo SIN tocar CORE ni el hitbox real.
# Precontacto compacto 80 px; tras contacto confirmado el torso exige 84 px.
# Si un borde impide mover al defensor, el residuo lo absorbe el otro luchador.
# CORE AWAKENED 91.02.22 — PASS 9.2 ROCE CORPORAL NEUTRAL.
# Mantiene un contacto cercano tipo arcade sin permitir fusión de torsos:
# neutral se detiene a 78 px y cualquier penetración residual se resuelve
# aunque ambos luchadores ya estén quietos. No toca golpes, CORE, KO ni rollback.
# CORE AWAKENED 91.02.21 — PASS 9.1 CORE RECEIVER LOCK / VS LOCAL.
# Corrige exclusivamente la captura del receptor durante CORE I/II/III:
# no acepta acciones durante la secuencia, no conserva ataques/buffers previos,
# CORE I mantiene la reacción visual hasta el cierre y CORE II/III no liberan
# al receptor antes del derribo/KO. Rollback, física global y timings quedan intactos.
# CORE AWAKENED 91.02.20 — PASS 8 CONTINUIDAD REMATE CORE II + APOYO DERRIBO.
# Mantiene íntegros PASS 1–6. Reduce de forma muy corta el hitstun únicamente
# en el PRIMER impacto normal limpio, con ambos luchadores en suelo. La cadena
# ya confirmada conserva el stun anterior para no romper COMBO x2/x3. Bloqueo,
# AIR HIT, launcher, CORE, IA defensiva y rollback quedan fuera de este ajuste.
# CORE AWAKENED 91.02.18 — PASS 6 IMPACTO LOCAL / HITSTOP.
# Mantiene íntegros PASS 1–5. Ajusta únicamente el micro-hitstop LOCAL de golpes
# NORMALES limpios para que el contacto se lea más sólido sin volver lenta la pelea.
# No toca hitstun, daño, knockback, rangos, lunge, IA, Combo Cancel, CORE ni rollback.
# El bloqueo conserva exactamente sus tiempos anteriores para no hacer la defensa pegajosa.
# CORE AWAKENED 91.02.17 — PASS 5 CADENCIA DE COMBATE NORMAL.
# Mantiene íntegros PASS 1–4 y acelera de forma quirúrgica sólo la respuesta de
# golpes NORMALES: startup -10 % y recovery reducido, sin tocar daño, hitstun,
# hitstop, knockback, rango, lunge, dash/backdash, launcher, CORE I/II/III ni rollback.
# La patada conserva más peso que el puño; no se acorta su ventana ACTIVA.
# CORE AWAKENED 91.00.00-H10.2 — CORE I SECUENCIA EXPLÍCITA POR PHYSICS TICKS.
# Reemplaza exclusivamente el Tween de acercamiento de CORE I por el mismo
# QUAD EASE OUT evaluado en _physics_process(), para que su progreso sea
# snapshotable/re-simulable. No cambia destino, duración, daño ni CORE II/III.
# CORE AWAKENED 90.11.09 — AIR DASH AISLADO SOBRE 90.11.08.
# Mantiene intacta la coreografía trifásica CORE II/III aprobada y suma un único
# dash horizontal por permanencia en el aire mediante el mismo doble toque.
# No altera Versus Local en suelo, Combo Cancel, IA, gravedad ni doble salto.
# CORE AWAKENED 90.11.08 — CORE II/III TRIFÁSICO: PUÑOS → PATADAS → MIXTA → REMATE.
# Cambia únicamente la coreografía automática de CORE II y CORE III.
# Versus Local y Combo Cancel manual permanecen intactos.
# CORE AWAKENED 90.11.06 — LOCK DE RECEPCIÓN COMBO CANCEL EXCLUSIVO CPU.
# Versus Local queda intacto. Cuando un x2/x3 ya fue confirmado contra IA,
# la CPU no puede insertar una nueva decisión de IA antes del siguiente impacto.
# No acelera ataques, no aumenta hitstun y no cambia física global.
# CORE AWAKENED 90.11.02 — CURVA DE CARGA CORE + REMIX DE PERSONAJE.
# Conserva intacto el combate 90.10.76 y convierte la capa de control en un sistema
# realmente reutilizable por J1, J2 local y futuro input externo/online. J2 puede usar
# teclado independiente o mando asignado sin duplicar ninguna mecánica del Fighter.
extends CharacterBody2D

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
# 91.02.56 — presentación pura: Main usa esta señal para un grito breve
# exactamente al nacer el proyectil. No transporta estado de simulación.
signal proyectil_disparado
signal derrotado
signal salto_hecho
# H8.3 — continuación local de la secuencia CORE I cuando termina su Target Lock.
signal core1_target_lock_finalizado
# H9.9 — borde exacto del await del póster de rematador CORE II.
signal core2_rematador_poster_finalizado

# --- Estos valores los pisa cada personaje en su _init() ---
var nombre_luchador := "Luchador"
var velocidad := 260.0
var fuerza_salto := -420.0
var gravedad := 1200.0

# 91.02.44 — PASS 12A / PROYECTIL ESPECIAL PROTOTIPO.
# Deshabilitado por defecto: sólo el personaje que lo configure participa.
var proyectil_especial_habilitado := false
var textura_proyectil_pose: Texture2D
var proyectil_pose_escala_mult := 1.0
var color_proyectil_primario := Color(1.0, 0.22, 0.72, 1.0)
var color_proyectil_secundario := Color(1.0, 0.78, 0.95, 1.0)
var textura_proyectil_nucleo: Texture2D
var sonido_proyectil_impacto: AudioStream
# 91.02.52 — altura de nacimiento configurable por personaje.
# Default 0.54 conserva EXACTAMENTE Helena + Tanda 1 + Aethel/Kali.
var proyectil_spawn_altura_mult := 0.54
var proyectil_velocidad := 720.0
var proyectil_dano_mult := 0.86
var proyectil_empuje := 148.0
var proyectil_hitstun := 0.22
var proyectil_startup := 0.16
var proyectil_recovery := 0.30
var proyectil_cooldown := 0.62

# 91.02.13 — PASS 1: caída con más peso sin tocar el despegue ni la altura.
# 1.35 hace que, una vez iniciado el descenso normal, el personaje recupere el
# suelo aproximadamente un 14 % antes que con una parábola simétrica. Se excluyen
# derribos especiales/hitstun para no mezclar este test con física de impactos.
const MULT_GRAVEDAD_CAIDA_LIBRE := 1.35

# 91.02.15 — PASS 3: compresión quirúrgica del vértice.
# Sólo se aplica a un salto real iniciado por Fighter (saltos_usados > 0),
# dentro de una banda pequeña alrededor de velocidad Y=0. No toca launcher,
# knockback, derribos especiales ni hitstun. La altura cambia sólo unos píxeles,
# pero la transición subida→caída pierde varios frames de suspensión visual.
const UMBRAL_VELOCIDAD_VERTICE := 120.0
const MULT_GRAVEDAD_VERTICE := 1.50

# 91.02.16 — PASS 4: peso extra únicamente en el último tramo del descenso.
# Se activa cuando un salto real ya cae con velocidad suficiente. El refuerzo
# es pequeño (x1.12 sobre la caída PASS 1), para que el contacto con el suelo
# llegue antes y con más decisión sin convertir el salto en una caída brusca.
const UMBRAL_CAIDA_FINAL := 360.0
const MULT_GRAVEDAD_CAIDA_FINAL := 1.12

# Multiplicador global de daño: bajalo para peleas más largas (la vida
# tarda más en bajar), subilo para peleas más rápidas. Se aplica sobre
# TODO el daño (golpes normales y especiales) de todos los personajes.
const MULT_DANO_GLOBAL := 0.32

# PASS 12A — comando ↓ → + PUÑO.
const VENTANA_COMANDO_PROYECTIL := 0.48
const SCRIPT_PROYECTIL_ENERGIA = preload("res://scripts/proyectil_energia.gd")

# Multiplicador global de la barra de poder: bajalo para que tarde más en
# llenarse (peleas más largas hasta ver la Fase Absoluta).
const MULT_PODER_GLOBAL := 0.55

# Empuje físico global. En 90.10.97 los golpes INTERMEDIOS de CORE II/III
# conservan esta fuerza para reacción visual/sonora, pero el receptor no la
# convierte en desplazamiento hasta el remate final.
const MULT_EMPUJE_GLOBAL := 1.35

# FASE 85 — CORE competitivo: todos los luchadores cargan a un ritmo más
# parejo por impacto limpio. Las diferencias de personalidad siguen viniendo
# de su velocidad/timing, pero nadie obtiene casi el doble de CORE por golpe.
const CORE_GANANCIA_MIN := 5.8
const CORE_GANANCIA_MAX := 7.2
const CORE_BLOQUEO_MULT := 0.18
# 90.11.01 — Rendimientos decrecientes de CORE dentro de una cadena normal.
# El COMBO x2/x3 conserva daño y velocidad, pero no multiplica casi linealmente
# la recarga. El primer impacto carga normal; los siguientes cargan menos.
const CORE_COMBO_SEGUNDO_GOLPE_MULT := 0.45
const CORE_COMBO_TERCER_MAS_MULT := 0.30
# 90.11.02 — CURVA DE PROGRESIÓN CORE. La primera carga aparece pronto para
# presentar la mecánica; la segunda exige más presión y la tercera debe sentirse
# como un recurso final realmente conquistado. Se aplica a la ganancia por impacto
# y convive con los rendimientos decrecientes de COMBO x2/x3.
# 90.11.03 — misma progresión por niveles, pero un poco más accesible en pelea real contra IA.
# CORE I sigue siendo el más frecuente; CORE III continúa siendo claramente el más costoso.
const CORE_CARGA_NIVEL_1_MULT := 1.22
const CORE_CARGA_NIVEL_2_MULT := 0.90
const CORE_CARGA_NIVEL_3_MULT := 0.90

# FASE 85 — cajas de contacto más cercanas al cuerpo que realmente se ve.
# La colisión física sigue compacta para que los personajes no se empujen
# desde demasiado lejos, mientras la hurtbox de golpes cubre torso/cabeza.
const HURTBOX_ALTURA_VISIBLE_MULT := 0.60
const HURTBOX_ANCHO_CUERPO_MULT := 1.18
const COLISION_ALTURA_VISIBLE_MULT := 0.36

# CORE HIERARCHY: los combos automáticos recorren el repertorio disponible
# del modo correspondiente. Desde 90.10.96 ese repertorio se ejecuta en DOS
# pasadas continuas para CORE II y CORE III. El sistema sigue aceptando más
# sprites sin reescribir la arquitectura.
# 90.10.96 — CORE II/III toman como referencia la cadencia del COMBO CANCEL
# manual (COMBO x2): golpes muy seguidos, pero todavía legibles. El multiplicador
# actúa sobre startup+activo; el recovery queda reducido a una transición mínima.
# 90.10.98 — CORE II/III ya NO heredan la duración/cooldown propio de cada
# puño o patada. Ese esquema hacía que una patada larga insertara una pausa
# perceptible dentro de la secuencia (rápido-rápido-pausa). La ráfaga usa un
# beat uniforme, inspirado en el COMBO x2 manual contra pared: cada sprite
# conserva un contacto visible corto, pero todos entran con la misma cadencia.
const MULT_VELOCIDAD_COMBO_CORE := 0.58 # compatibilidad fuera del timing fijo
const STARTUP_COMBO_CORE_UNIFORME := 0.012
const ACTIVO_COMBO_CORE_UNIFORME := 0.065
const RECOVERY_COMBO_CORE_CONTINUO := 0.010
const POLL_COMBO_CORE_CONTINUO := 0.004
# 90.11.08 — la ejecución activa ya no usa el remix reducido de 90.10.99:
# ahora CORE II/III hacen tres actos completos (puños, patadas, mezcla).
# Conservamos estas constantes y el constructor anterior por compatibilidad
# con scripts/personajes viejos; no gobiernan la racha trifásica actual.
const FRACCION_REMIX_COMBO_CORE := 0.50
const FRACCION_REMIX_COMBO_CORE_REPERTORIO_GRANDE := 0.30
const UMBRAL_REPERTORIO_GRANDE_COMBO_CORE := 15
# Distancia base para los combos automáticos. Desde 90.10.71 ya no es una
# cifra rígida: el pushbox calcula una distancia corporal adaptativa por pareja
# y usa esta base como piso. Así Aethel/Kali/Magnus no funden los torsos sin
# convertir alas, pelo, colas o auras en una pared física.
const DISTANCIA_COMBO_AUTO_OBJETIVO := 82.0
const DISTANCIA_COMBO_AUTO_PUSH_MIN := 88.0
const DISTANCIA_COMBO_AUTO_PUSH_MAX := 100.0
# 90.10.46 — el combo CORE también debe alinearse verticalmente. Antes el
# acercamiento sólo corregía X: si se activaba CORE II/III desde salto o
# doble salto, el atacante quedaba arriba del rival y golpeaba al vacío.
const DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO := 18.0
const DISTANCIA_COMBO_AUTO_MAX := 250.0
# Compatibilidad con los personajes actuales:
# algunos (Magnus) pueden desactivar las patadas del combo automático.
var combo_auto_incluye_patada := true
# Compatibilidad heredada del remix 90.11.02. En 90.11.08 la segunda pasada ya
# exhibe todas las patadas, por lo que estas preferencias quedan conservadas
# para no romper scripts de personaje aunque la racha trifásica no las necesite.
var combo_core_remix_prioriza_patadas := false
var combo_core_remix_patadas_objetivo := 0
# FASE 60 — asistencia de avance durante ataques normales. Da una pequeña
# transferencia de peso automática hacia el rival para que los golpes no
# parezcan "anclados" al piso cuando el jugador pulsa X/C cerca del objetivo.
const DISTANCIA_LUNGE_ATAQUE := 240.0
const DISTANCIA_LUNGE_MINIMA := 74.0
const VELOCIDAD_LUNGE_PUNETAZO := 118.0
const VELOCIDAD_LUNGE_PATADA := 104.0

var rango_punetazo := 90.0
var dano_punetazo := 8.0
var cooldown_punetazo := 0.30

var rango_patada := 100.0
var dano_patada := 13.0
var cooldown_patada := 0.55

# 91.02.17 — PASS 5: CADENCIA NORMAL MÁS REACTIVA.
# El objetivo es quitar sensación de "espera" entre intención, contacto y regreso
# a neutral sin convertir CORE ni los combos automáticos en una ametralladora.
# Se conserva íntegra la ventana ACTIVA para no reducir alcance/fiabilidad de hit.
const MULT_STARTUP_ATAQUE_NORMAL := 0.90
# 91.02.25 — PASS 9.3A. No se acelera la animación ni la ventana de impacto:
# únicamente el tiempo lógico DESPUÉS de que desaparece la pose de ataque.
# Reducción moderada para quitar ~1 frame perceptible de espera sin borrar peso.
const MULT_RECOVERY_PUNETAZO_NORMAL := 0.64
const MULT_RECOVERY_PATADA_NORMAL := 0.60

# 91.02.19 — PASS 7: recuperación del RECEPTOR en intercambio neutral.
# Sólo acorta el primer impacto limpio de una cadena y sólo con ambos Fighters
# en suelo. De este modo un golpe aislado vuelve antes a neutral, pero una cadena
# ya confirmada conserva exactamente el hitstun de PASS 6. La patada mantiene
# más peso que el puño.
const MULT_HITSTUN_PUNETAZO_NEUTRAL := 0.92
const MULT_HITSTUN_PATADA_NEUTRAL := 0.96

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
# 91.02.31 / 91.02.35 — PNG exclusivos enviados por el usuario.
# Ahora se reutilizan como gigantografia cinematica de CORE I. Si algun
# personaje no tiene PNG dedicado, el sistema mantiene sus posters normales.
var textura_core2_entrada: Texture2D = null
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
# Compatibilidad con Xenoid V3: conserva su asset de carrera sin activar
# ninguna lógica nueva de escalado o Combat Feel.
var textura_carrera: Texture2D = null
# 90.10.41 — Backdash visual independiente. El dash hacia adelante usa
# textura_carrera; la evasión hacia atrás puede usar su PNG propio sin
# cambiar velocidad, distancia, hitboxes ni lógica física del dash.
var textura_evasion: Texture2D = null
var textura_furia_evasion: Texture2D = null
# Si un personaje todavía no tiene PNG dedicado de dash, puede pedir una
# inclinación procedural más marcada sobre su pose de fallback.
var dash_visual_fallback_reforzado: bool = false
var textura_salto: Texture2D = null
var textura_doble_salto: Texture2D = null
var textura_descenso: Texture2D = null
var textura_bloqueo: Texture2D = null

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
# Compatibilidad con Xenoid V3.
var textura_furia_carrera: Texture2D = null
var textura_furia_salto: Texture2D = null
var textura_furia_doble_salto: Texture2D = null
var textura_furia_descenso: Texture2D = null
var textura_furia_bloqueo: Texture2D = null

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
# 90.10.26 — ajustes cinematográficos por personaje. Solo afectan el arte
# grande de Especial/Remate/Absoluto; NO cambian hitboxes, daño ni cuerpo.
# Jester y Kali tienen ilustraciones/VFX más expansivos, por eso se les da
# un encuadre ligeramente más contenido para que el rival siga leyéndose.
const PODER_CINEMA_ALTURA_MULT := {
	"Jester": 0.90,
	"Kali": 0.92,
}
const PODER_CINEMA_ALPHA_MULT := {
	"Jester": 0.88,
	"Kali": 0.90,
}
const PODER_CINEMA_VFX_MULT := {
	"Jester": 0.72,
	"Kali": 0.76,
}

# 91.02.36 / 91.02.37 — ajuste fino SOLO para CORE I usando los PNG
# exclusivos del usuario. Todas las gigantografias exclusivas retroceden
# un poco mas; Cibor-X y Magnus además conservan su calibracion extra.
const CORE1_POSTER_EXCLUSIVO_SEPARACION_GLOBAL := 18.0

const CORE1_POSTER_EXCLUSIVO_ALTURA_MULT := {
	"Cibor-X": 1.12,
	"CiborX": 1.12,
	"Cibor X": 1.12,
	"Magnus": 1.10,
}

const CORE1_POSTER_EXCLUSIVO_SEPARACION_EXTRA := {
	"Cibor-X": 34.0,
	"CiborX": 34.0,
	"Cibor X": 34.0,
	"Magnus": 28.0,
}

const CORE1_POSTER_EXCLUSIVO_FRACCION_ANCHO_EXTRA := {
	"Cibor-X": 0.05,
	"CiborX": 0.05,
	"Cibor X": 0.05,
	"Magnus": 0.04,
}

const ALTURA_AJUSTES_VISUALES := {
	"Kai": 1.00,
	"Cibor-X": 1.00,
	"Fang": 1.00,
	"Kali": 1.00,
	"Aethel": 1.00,
	# Magnus debe verse un poco más grande.
	"Magnus": 1.15,
	"Helena": 1.00,
	"Jester": 1.00,
	# Varkhos, jefe final: más grande que el roster normal.
	"Varkhos": 1.35,
}

# FASE 83: escala visual precalculada por PNG. Se calcula por masa alfa del
# arte respecto al parado del personaje, para que un frame horizontal, uno
# vertical o uno generado a mayor resolución NO cambie el tamaño corporal.
# 91.02.08 — rediseños de recarga entregados por el usuario.
# Estas ilustraciones incluyen aura alrededor del cuerpo; se deja que la
# normalización geométrica use el parado REAL del personaje y se compensa
# solamente el encuadre para que el fighter no quede visualmente al fondo.
# No altera colisión, daño, velocidad, timers ni lógica de CORE.
const RECARGA_REDRAW_MULT := {
	"Aethel": 1.12,
	"Cibor-X": 1.12,
	"Fang": 1.12,
	"Helena": 1.12,
	"Jester": 1.12,
	"Kai": 1.12,
	"Kali": 1.12,
	"Magnus": 1.12,
	"Dax": 1.12,
	# 91.02.10 — Xenoid usa la misma compensación del rediseño de recarga.
	# En 91.02.09 la ruta era correcta, pero faltaba esta clave y por eso
	# la normalización geométrica lo mostraba más chico que su parado.
	"Xenoid": 1.12,
}

const ESCALAS_POSE_PRECALCULADAS := {

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
	"res://assets/helena/salto.png": 0.203403,
	"res://assets/helena/victoria.png": 0.205342,

	"res://assets/jester/absoluto.png": 0.236541,
	"res://assets/jester/especial.png": 0.238838,
	"res://assets/jester/furia_parado.png": 0.237490,
	"res://assets/jester/furia_patada_1.png": 0.239130,
	"res://assets/jester/furia_punetazo_1.png": 0.236541,
	"res://assets/jester/furia_punetazo_2.png": 0.243376,
	"res://assets/jester/furia_punetazo_3.png": 0.238065,
	"res://assets/jester/furia_punetazo_4.png": 0.238065,
	"res://assets/jester/furia_punetazo_5.png": 0.239130,
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
	"res://assets/kai/salto.png": 0.463023,
	"res://assets/kai/doble_salto.png": 0.434927,
	"res://assets/kai/victoria.png": 0.306652,

	# Kali: las poses normales actuales se normalizan dinámicamente.
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
# 90.10.82 — PUSHBOX ÚNICO. Entre Fighter y Fighter ya no usamos la
# respuesta física automática de CharacterBody2D; suelo/paredes siguen
# colisionando normalmente. El contacto horizontal entre luchadores lo
# resuelve exclusivamente _aplicar_separacion_fisica(), evitando que el
# orden J1->J2 de move_and_slide produzca desplazamientos asimétricos.
var _objetivo_pushbox_manual_id: int = 0
# 90.10.84 — cada pareja Fighter se resuelve una sola vez por frame físico.
# Main asigna 0 a J1/lado izquierdo y 1 a J2/rival. Esto evita depender del
# orden interno de _physics_process y deja una autoridad estable para rollback.
var indice_lado_combate: int = -1
# 90.10.76 — fuente de control. `controlado_por_jugador` se conserva por
# compatibilidad con escenas/scripts existentes, pero el Fighter ya puede recibir
# input local o un frame externo (futuro J2 / rollback / red) sin leer Input ahí.
enum FuenteControl { IA, LOCAL, EXTERNA }
var fuente_control: int = FuenteControl.IA
var controlado_por_jugador := false
var jugador_local_indice := 0
var gamepad_asignado_id := -1
# 90.10.79 — aislamiento real de dispositivos. Un Fighter con mando asignado
# puede dejar de escuchar teclado; esto evita que J1/J2 compartan una segunda
# fuente de input en Versus Local. Fuera de Versus se conserva compatibilidad.
var teclado_local_habilitado := true
var input_frame_externo: Dictionary = {}
var input_externo_disponible := false
# 90.10.93 — último frame ya enrutado por Main. En Versus Local el Fighter
# jamás consulta Input directamente; este cache también alimenta el footwork
# durante ataques para que no exista una segunda ruta de teclado/mando.
var input_frame_enrutado_actual: Dictionary = {
	"izquierda": false,
	"derecha": false,
	"salto": false,
	"bloqueo": false,
	"puno": false,
	"patada": false,
	"especial": false,
}
# 90.10.85 — DIAGNÓSTICO J2. No modifica gameplay: expone el input crudo y
# el desplazamiento real para distinguir mando/Steam Input de cualquier movimiento físico.
var debug_input_izquierda: bool = false
var debug_input_derecha: bool = false
var debug_gamepad_axis_x: float = 0.0
var debug_gamepad_dpad_izq: bool = false
var debug_gamepad_dpad_der: bool = false
var debug_delta_x_frame: float = 0.0
var debug_x_inicio_frame: float = 0.0
# 90.10.88 — anclaje neutral durante DASH en Versus Local.
# Protege al defensor en el mismo frame donde nace el segundo toque.
var dash_iniciado_este_frame: bool = false
var ultima_intencion_horizontal: float = 0.0
var z_estaba_presionado: bool = false
var salto_estaba_presionado: bool = false
# 90.10.94 — BUFFER DE ATAQUE HUMANO.
# Un tap breve del mando durante RECOVERY no puede desaparecer antes de que el
# Fighter vuelva a FaseAtaque.NINGUNA. Conservamos la última pulsación de
# puño/patada durante una ventana corta; teclado y mando quedan equivalentes.
const ATAQUE_BUFFER_DURACION := 0.24
var puno_estaba_presionado: bool = false
var patada_estaba_presionada: bool = false
var ataque_buffer_tipo: String = ""
var ataque_buffer_timer: float = 0.0

# PASS 12A — estado del comando/lanzamiento.
var comando_proyectil_etapa := 0
var comando_proyectil_timer := 0.0
var en_lanzamiento_proyectil := false
var proyectil_lanzamiento_timer := 0.0
var proyectil_spawn_timer := 0.0
var proyectil_disparo_pendiente := false
var proyectil_cooldown_timer := 0.0
var proyectil_activo: Node = null
# 90.10.30 — GAMEPAD FOUNDATION. El jugador sigue pudiendo usar teclado,
# pero ahora el primer mando conectado se suma en paralelo. Se usan índices
# estándar SDL/Godot: A=0, B=1, X=2, Y=3, RB=10, D-Pad 11..14.
const PAD_A := 0
const PAD_B := 1
const PAD_X := 2
const PAD_Y := 3
const PAD_RB := 10
const PAD_DPAD_UP := 11
const PAD_DPAD_DOWN := 12
const PAD_DPAD_LEFT := 13
const PAD_DPAD_RIGHT := 14
const PAD_AXIS_LEFT_X := 0
const PAD_AXIS_LEFT_Y := 1
const PAD_AXIS_LT := 4
const PAD_AXIS_RT := 5
const PAD_DEADZONE_MOV := 0.45
const PAD_DEADZONE_VERTICAL := 0.64
var gamepad_salto_previo: bool = false
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
# Cooldown independiente de la guardia normal. Sólo se usa para reingresar en
# bloqueo desde hitstun cuando el jugador está atrapado contra una pared.
var guardia_escape_esquina_cooldown: float = 0.0
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
# 91.02.26 — PASS 9.3B. Multiplicadores aislados del movimiento NORMAL en suelo.
# No cambian velocidad maxima ni se aplican a aire, dash o footwork de ataque.
const MULT_ACELERACION_SUELO_DINAMICA := 1.15
const MULT_FRENO_SUELO_DINAMICA := 1.18
var _delta_actual := 0.0166
# H10.7 — override efímero usado sólo por la resimulación local CORE III.
# Valor < 0 = gameplay normal, sin ninguna alteración. Main lo arma antes de
# cada callback histórico y se consume una sola vez.
var rollback_delta_override: float = -1.0
# H10.8 — override one-shot exclusivo del reloj de seguridad de secuencia.
# Se usa sólo en la transición CORE III donde el rival congelado conserva el
# delta LIVE del frame causal aunque el resto de su callback use la escala post.
var rollback_reloj_seguridad_delta_override: float = -1.0
var _rect_visual_cache: Dictionary = {}
# FASE 90.10 — separación física más legible.
# Los cuerpos nunca deben fundirse visualmente cuando están cuerpo a cuerpo.
const DISTANCIA_MINIMA_LUCHADORES := 62.0
# 91.02.22 — PASS 9.2: contacto neutral compacto.
# 62 px permitía que dos torsos quedaran demasiado penetrados visualmente.
# 78 px coincide con el colchón mínimo de precontacto ya certificado para golpes,
# pero sigue siendo suficientemente cercano para conservar roce visual natural.
const PUSHBOX_NEUTRAL_DISTANCIA_MIN := 78.0
# 91.02.23 — PASS 9.2B. En combate normal permitimos que manos, pies, ropa y
# efectos invadan visualmente, pero no que el torso principal desaparezca.
# 80 px se usa ANTES del impacto y 84 px sólo cuando el contacto/hitstun/bloqueo
# ya confirmó que ambos luchadores están realmente cuerpo a cuerpo.
const PUSHBOX_COMBATE_PRECONTACTO_MIN := 80.0
const PUSHBOX_COMBATE_TORSO_MIN := 84.0
# 90.10.80 — PUSHBOX NEUTRAL ANCLADO. Si un solo luchador camina contra
# un rival quieto, el que avanza absorbe la corrección y se frena en el borde
# corporal. El rival quieto ya no es arrastrado hacia atrás frame a frame.
const VELOCIDAD_NEUTRAL_EMPUJE_UMBRAL := 18.0
# 90.10.86 — TOPE DURO DEL PUSHBOX NEUTRAL. El volumen visual de una pose
# horizontal (dash, alas, pelo largo) puede ser enorme, pero NO representa el
# torso físico. En neutral ningún PNG puede declarar contacto corporal a más
# distancia que esta cifra. Golpes/CORE conservan sus reglas específicas.
const PUSHBOX_NEUTRAL_DISTANCIA_MAX := 118.0
# 90.10.14 — zona de combate segura. Los límites anteriores (58..1222)
# permitían que el origen físico siguiera dentro aunque media silueta ya estuviera
# fuera de la plataforma visible. Dejamos un margen real a ambos lados.
const ARENA_LIMITE_IZQUIERDO := 110.0
const ARENA_LIMITE_DERECHO := 1170.0

# 90.11.27 — GUARDIA DE ESCAPE EN ESQUINA (Versus Local).
# Evita el corner-lock infinito sin regalar un ataque durante hitstun. Si un
# jugador está realmente acorralado y mantiene BLOQUEO tras recibir un golpe,
# el siguiente golpe normal puede entrar como bloqueo y cortar el Combo Cancel.
const GUARDIA_ESCAPE_ESQUINA_MARGEN := 72.0
const GUARDIA_ESCAPE_ESQUINA_COOLDOWN := 0.85
const GUARDIA_ESCAPE_ESQUINA_DURACION := 0.24
const FUERZA_REBOTE_MURO_ESPECIAL := 0.42
const DISTANCIA_MINIMA_CONTACTO := 82.0
const DISTANCIA_MINIMA_CONTACTO_BLOQUEO := 88.0
const DISTANCIA_MINIMA_CONTACTO_PESADO := 96.0
# 90.10.7: además de la colisión física compacta, usamos el ancho REAL visible
# del PNG para impedir que dos siluetas se metan una dentro de la otra.
const MARGEN_SEPARACION_VISUAL := 14.0
# 90.10.16 — después de un impacto real mantenemos durante unas centésimas
# una distancia corporal limpia. No afecta el acercamiento ANTES del golpe,
# por lo que conserva el arreglo de patadas de 90.10.12.
const CONTACTO_POST_GOLPE_MIN := 92.0
const CONTACTO_POST_GOLPE_MAX := 118.0
const CONTACTO_POST_GOLPE_DUR_PUNO := 0.095
const CONTACTO_POST_GOLPE_DUR_PATADA := 0.125
# 90.10.74 — MICROESPACIOS DE COMBATE. No bajan la velocidad ni cambian el
# alcance: actúan únicamente DESPUÉS de un impacto limpio y suficientemente
# fuerte. La patada abre más neutral que el puño; CORE automático y bloqueos
# quedan excluidos para no romper combos ni el rebote defensivo ya validado.
const MICROESPACIO_UMBRAL_FUERZA := 185.0
const MICROESPACIO_PUNO_EXTRA_MIN := 2.0
const MICROESPACIO_PUNO_EXTRA_MAX := 5.0
const MICROESPACIO_PATADA_EXTRA_MIN := 5.0
const MICROESPACIO_PATADA_EXTRA_MAX := 11.0
const MICROESPACIO_DISTANCIA_MAX := 130.0
const MICROESPACIO_DUR_PUNO_MAX := 0.040
const MICROESPACIO_DUR_PATADA_MAX := 0.065
# 90.10.72 — PUSHBOX 2.1: la pose de ataque puede proyectar el torso varios
# píxeles por delante del origen físico. Este margen se suma SOLO después de
# que el golpe ya conectó; nunca actúa antes del hitbox y por eso no acorta
# ni rompe el alcance real del puño/patada.
const PUSH_POSE_CONTACTO_PUNO := 4.0
const PUSH_POSE_CONTACTO_PATADA := 6.0
const PUSH_POSE_CONTACTO_TRADE := 2.0
const PUSH_POSE_CONTACTO_MAX := 8.0
# 90.10.17 — colchón corporal ANTES del impacto. La vieja cifra fija de 72 px
# servía para no romper las patadas, pero era demasiado compacta para Magnus,
# Jester y combinaciones con torsos anchos. Ahora el mínimo se adapta al torso
# lógico/masa, ignorando el ancho completo de alas, pelo, colas y auras.
const PRECONTACTO_MIN := 78.0
const PRECONTACTO_MAX := 94.0
const PRECONTACTO_DOBLE_ATAQUE_MAX := 88.0
const MARGEN_KO_VISUAL := 24.0
const REBOTE_KO_EXTRA := 18.0
const Z_BASE_Y_DIVISOR := 12.0
var contacto_post_golpe_timer: float = 0.0
var contacto_post_golpe_distancia: float = 0.0
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
const DATOS_CARA := {
	# y/x = posición local aproximada de los ojos respecto del centro
	# del PNG. Calibración directa sobre los parado.png actuales.
	"Kai": Vector4(-4.5, -56.0, 14.0, 9.0),
	"Cibor-X": Vector4(30.0, -53.0, 30.0, 10.0),
	"Fang": Vector4(35.0, -72.0, 20.0, 9.5),
	"Kali": Vector4(5.0, -79.0, 17.0, 9.0),
	"Aethel": Vector4(32.0, -62.0, 14.0, 9.5),
	"Magnus": Vector4(12.0, -54.0, 19.0, 9.5),
	"Helena": Vector4(16.0, -74.0, 12.0, 9.0),
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
# Red de seguridad: por si alguna secuencia queda trabada por algún motivo.
# Desde 90.10.39 los combos recorren todas las variantes disponibles; damos
# margen suficiente para futuros combos Furia de 10 golpes sin que el reloj
# de seguridad corte una secuencia legítima.
var reloj_seguridad_secuencia := 0.0
const TIEMPO_MAXIMO_SECUENCIA := 18.0

# 91.00.00-H10.2 — estado lógico del acercamiento de CORE I.
# El Tween anterior guardaba su progreso dentro del motor y no podía ser
# restaurado por rollback. Estos cinco valores son la misma trayectoria, pero
# explícita y por physics ticks.
var core1_target_lock_activo: bool = false
var core1_target_lock_origen: Vector2 = Vector2.ZERO
var core1_target_lock_destino: Vector2 = Vector2.ZERO
var core1_target_lock_duracion: float = 0.0
var core1_target_lock_tiempo: float = 0.0

# H8.5 — CORE I deja de depender de una coroutine suspendida para continuar.
# Etapas lógicas snapshotables:
#   0 = inactivo
#   1 = Target Lock
#   2 = impacto + poster en curso
const CORE1_ETAPA_INACTIVO := 0
const CORE1_ETAPA_TARGET_LOCK := 1
const CORE1_ETAPA_POSTER := 2
const CORE1_POSTER_TIEMPO_VISIBLE := 1.05
# _mostrar_poder_reemplazando:
# 0.12 fade-in + 1.05 visible + 0.30 fade-out + 0.18 halo + 0.16 aura.
const CORE1_POSTER_DURACION_LOGICA := 1.81

var core1_secuencia_etapa: int = CORE1_ETAPA_INACTIVO
var core1_poster_timer: float = 0.0
var core1_poster_duracion: float = 0.0

# Flag TRANSITORIO, deliberadamente fuera del snapshot. Main lo activa sólo
# durante catch-up para no duplicar pósters/VFX al re-simular historia.
var rollback_suprimir_presentacion_core1: bool = false

# H9.3 — CORE II: recarga + primer acercamiento dejan de depender de
# SceneTreeTimer/await y Tween internos del motor.
const CORE2_ETAPA_INACTIVO := 0
const CORE2_ETAPA_RECARGA := 1
const CORE2_ETAPA_ACERCAMIENTO := 2
const CORE2_ETAPA_COMBO_FSM := 3
const CORE2_ETAPA_REMATADOR_FSM := 4
const CORE2_RECARGA_DURACION := 1.05

# 91.02.30 — PASS 9.4A. Flash visual dentro del tiempo YA existente de recarga.
# 0.42 s antes del final se dispara una presencia de ~0.38 s, dejando un pequeño
# margen antes del primer golpe. Estas constantes NO gobiernan lógica de combate.
const CORE2_FLASH_ENTRADA_UMBRAL := 0.50
const CORE2_FLASH_FADE_IN := 0.08
const CORE2_FLASH_HOLD := 0.24
const CORE2_FLASH_FADE_OUT := 0.10
const CORE2_FLASH_ALTO := 430.0

# 91.02.32 — PASS 9.4C / CAMARA DE RECARGA CORE II.
# Zoom <= 1 abre la Camera2D. El valor final se calcula por contenido vertical:
# en suelo normalmente queda cerca de 0.96-1.00; desde aire puede abrir hasta 0.88.
const CORE2_CAM_ZOOM_MAX := 1.00
const CORE2_CAM_ZOOM_MIN := 0.88
const CORE2_CAM_MARGEN_VERTICAL := 34.0
const CORE2_CAM_MARGEN_CUERPO_INFERIOR := 82.0
const CORE2_CAM_SEPARACION_POSTER_X := 76.0
const CORE2_CAM_ELEVACION_POSTER := 84.0

# 91.02.33 — PASS 9.4D / ZONA SEGURA DE GIGANTOGRAFIA EN PANTALLA.
# No depende de la posicion fisica ni de la altura del luchador.
const CORE2_FLASH_SAFE_MARGEN_X_FRAC := 0.045
const CORE2_FLASH_SAFE_TOP_FRAC := 0.035
const CORE2_FLASH_SAFE_BOTTOM_FRAC := 0.245
const CORE2_FLASH_SAFE_ANCHO_MAX_FRAC := 0.47
const CORE2_FLASH_SAFE_ALTO_MAX_FRAC := 0.66
const CORE2_FLASH_CENTRO_LADO_IZQ_FRAC := 0.30
const CORE2_FLASH_CENTRO_LADO_DER_FRAC := 0.70
const CORE2_FLASH_CENTRO_Y_FRAC := 0.355
const CORE2_FLASH_CANVAS_LAYER := 2
# 91.02.34 — render en mundo, detrás de los luchadores.
const CORE2_FLASH_WORLD_Z := -1
# 91.02.35 — la recarga de CORE II vuelve limpia.
# Los PNG exclusivos se reutilizan en CORE I y no aparecen mas
# durante la recarga/entrada del CORE II.
const CORE2_FLASH_ENTRADA_ACTIVA := false

# PNG exclusivos de entrada CORE II enviados por el usuario.
const CORE2_ENTRADA_DIR := "res://assets/core2_entrada_flash/"
const CORE2_ENTRADA_POR_LUCHADOR := {
	"Aethel": "aethel.png",
	"Cibor-X": "cibor_x.png",
	"CiborX": "cibor_x.png",
	"Cibor X": "cibor_x.png",
	"Dax": "dax.png",
	"Fang": "fang.png",
	"Helena": "helena.png",
	"Jester": "jester.png",
	"Kai": "kai.png",
	"Kali": "kali.png",
	"Krovan": "krovan.png",
	"Magnus": "magnus.png",
	"Nekhar": "nekhar.png",
	"Momia": "nekhar.png",
	"Momia Gris": "nekhar.png",
	"Varkhos": "varkhos.png",
	"Xenoid": "xenoid.png",
}

# H9.10 — subfases lógicas del rematador CORE II.
const CORE2_REM_SUB_POSTER := 0
const CORE2_REM_SUB_ESPERA_FINAL := 1
const CORE2_REM_POSTER_VISIBLE := 1.30
# _mostrar_poder_reemplazando:
# 0.12 fade-in + 1.30 visible + 0.30 fade-out + 0.18 halo + 0.16 aura = 2.06
const CORE2_REM_POSTER_DURACION_LOGICA := 2.06
const CORE2_REM_ESPERA_FINAL := 0.10

# Subfases internas de la ráfaga CORE II.
const CORE2_COMBO_SUB_PREPARAR := 0
const CORE2_COMBO_SUB_ACERCAR := 1
const CORE2_COMBO_SUB_ESPERAR_ATAQUE := 2

var core2_secuencia_etapa: int = CORE2_ETAPA_INACTIVO
var core2_recarga_timer: float = 0.0
var core2_recarga_duracion: float = 0.0
var core2_acercamiento_origen: Vector2 = Vector2.ZERO
var core2_acercamiento_destino: Vector2 = Vector2.ZERO
var core2_acercamiento_duracion: float = 0.0
var core2_acercamiento_tiempo: float = 0.0

# H9.7 — estado completo y snapshotable de la ráfaga CORE II.
var core2_combo_paso_idx: int = 0
var core2_combo_total_pasos: int = 0
var core2_combo_subfase: int = CORE2_COMBO_SUB_PREPARAR
var core2_combo_acercamiento_origen: Vector2 = Vector2.ZERO
var core2_combo_acercamiento_destino: Vector2 = Vector2.ZERO
var core2_combo_acercamiento_duracion: float = 0.0
var core2_combo_acercamiento_tiempo: float = 0.0

# H9.10 — estado snapshotable del rematador CORE II.
var core2_rematador_subfase: int = CORE2_REM_SUB_POSTER
var core2_rematador_timer: float = 0.0
var core2_rematador_duracion: float = 0.0
var core2_rematador_puede_conectar: bool = false
var core2_rematador_bloqueado: bool = false
var core2_rematador_direccion: float = 1.0

# Presentación transitoria; deliberadamente fuera del snapshot.
var core2_recarga_brillo: Tween
# 91.02.30 — igualmente transitorio/presentación pura. Nunca gobierna daño,
# posición, timers de secuencia, inputs ni ninguna frontera rollback.
var core2_flash_entrada_mostrado: bool = false
var core2_flash_entrada_sprite: Sprite2D = null
var core2_flash_entrada_layer: CanvasLayer = null
var core2_flash_entrada_tween: Tween = null
# 91.02.32 — estado PURAMENTE VISUAL de cámara. Deliberadamente fuera de
# snapshots/rollback: no gobierna posición, daño, timers ni inputs del Fighter.
var core2_encuadre_abierto_activo: bool = false
var rollback_suprimir_presentacion_core2: bool = false

# H10.10 — CORE III: recarga lenta + primer acercamiento pasan a FSM física.
# El timer de recarga avanza en tiempo NO escalado para conservar los 1.55 s
# reales históricos aunque Engine.time_scale sea 0.32.
const CORE3_ETAPA_INACTIVO := 0
const CORE3_ETAPA_RECARGA := 1
const CORE3_ETAPA_ACERCAMIENTO := 2
const CORE3_ETAPA_PRIMER_BEAT_FSM := 3
const CORE3_ETAPA_SEGUNDO_BEAT_FSM := 4
const CORE3_ETAPA_TERCER_BEAT_FSM := 5
const CORE3_ETAPA_CUARTO_BEAT_FSM := 6
const CORE3_ETAPA_QUINTO_BEAT_FSM := 7
const CORE3_ETAPA_SEXTO_BEAT_FSM := 8
const CORE3_ETAPA_SEPTIMO_BEAT_FSM := 9
const CORE3_ETAPA_OCTAVO_BEAT_FSM := 10
const CORE3_ETAPA_NOVENO_BEAT_FSM := 11
const CORE3_ETAPA_DECIMO_BEAT_FSM := 12
const CORE3_ETAPA_UNDECIMO_BEAT_FSM := 13
const CORE3_ETAPA_DUODECIMO_BEAT_FSM := 14
const CORE3_ETAPA_DECIMOTERCER_BEAT_FSM := 15
const CORE3_ETAPA_DECIMOCUARTO_BEAT_FSM := 16
const CORE3_ETAPA_DECIMOQUINTO_BEAT_FSM := 17
const CORE3_ETAPA_DECIMOSEXTO_BEAT_FSM := 18
const CORE3_ETAPA_DECIMOSEPTIMO_BEAT_FSM := 19
const CORE3_ETAPA_DECIMOCTAVO_BEAT_FSM := 20
const CORE3_ETAPA_CONTINUACION_ASYNC := 21
const CORE3_RECARGA_DURACION := 1.55

# H10.50 — los primeros dieciocho beats de la ráfaga CORE III ya no dependen de
# Tween/coroutine histórico. Reutilizan el mismo estado snapshotable de beat;
# el resto continúa por la ruta histórica desde el decimonoveno paso.
const CORE3_BEAT_SUB_PREPARAR := 0
const CORE3_BEAT_SUB_ACERCAR := 1
const CORE3_BEAT_SUB_ESPERAR_ATAQUE := 2

var core3_secuencia_etapa: int = CORE3_ETAPA_INACTIVO
var core3_recarga_timer: float = 0.0
var core3_recarga_duracion: float = 0.0
var core3_recarga_primer_tick: bool = false
var core3_acercamiento_origen: Vector2 = Vector2.ZERO
var core3_acercamiento_destino: Vector2 = Vector2.ZERO
var core3_acercamiento_duracion: float = 0.0
var core3_acercamiento_tiempo: float = 0.0

var core3_primer_beat_subfase: int = CORE3_BEAT_SUB_PREPARAR
var core3_primer_beat_acercamiento_origen: Vector2 = Vector2.ZERO
var core3_primer_beat_acercamiento_destino: Vector2 = Vector2.ZERO
var core3_primer_beat_acercamiento_duracion: float = 0.0
var core3_primer_beat_acercamiento_tiempo: float = 0.0

# Sólo presentación; nunca gobierna estado lógico ni forma parte del snapshot.
var core3_recarga_brillo: Tween

# Cuenta cuántas veces este personaje llenó la barra en TODA la pelea.
# CORE I: especial + gigantografía normal.
# CORE II: combo completo en modo normal, sin Furia ni gigantografía.
# CORE III: Furia + combo completo Furia + Absoluto/gigantografía final.
var veces_fase_absoluta := 0
var bloqueando := false
var bloqueo_timer := 0.0

# --- Personalidad de IA (cada personaje puede pisar estos valores) ---
# 90.10.76 — la IA aprobada en 90.10.75 pasa a ser el perfil FÁCIL. Medio y
# Difícil mejoran tiempo de decisión/defensa/entrada, pero nunca reciben daño,
# velocidad, alcance ni lectura de inputs privilegiados.
enum DificultadIA { FACIL, MEDIA, DIFICIL }
var dificultad_ia: int = DificultadIA.FACIL
var ia_prob_patada := 0.35
var ia_prob_bloqueo := 0.20
var ia_prob_retroceso := 0.15
# 90.10.25 — IA DE COMBATE DINÁMICA.
# La IA comparte ahora el lenguaje de movilidad del jugador: puede entrar con
# dash, retroceder, saltar, usar doble salto/cruce y atacar desde el aire.
# Estas probabilidades son deliberadamente moderadas: buscamos actividad y
# variedad, no lectura perfecta de inputs ni una CPU injusta.
var ia_prob_salto := 0.18
var ia_prob_doble_salto := 0.58
var ia_prob_dash_adelante := 0.34
var ia_prob_dash_atras := 0.10
var ia_prob_ataque_aereo := 0.58
var ia_cooldown_decision := 0.0
var ia_retrocediendo := false
# 90.10.75 — cuando es true la CPU sostiene brevemente una distancia de lectura
# en vez de perseguir al rival frame a frame. Se decide de nuevo al vencer el
# cooldown; no es una pausa fija ni modifica la velocidad del personaje.
var ia_mantener_distancia := false
# 90.11.06 — lock EXCLUSIVO de CPU durante un Combo Cancel ya confirmado.
# Nunca se activa para J1/J2 local. No es hitstun: solamente impide que la
# rutina de IA inserte guardia, retroceso, dash o una nueva decisión antes
# del siguiente impacto que el jugador ya ganó con su input.
var ia_combo_cancel_lock_timer: float = 0.0
var ia_dash_cooldown := 0.0
var ia_doble_salto_pendiente := false
var ia_doble_salto_timer := 0.0
var ia_ataque_aereo_pendiente := false
var ia_ataque_aereo_timer := 0.0

# 91.02.43 — PASS 11E / ráfagas exclusivas de IA DIFÍCIL.
# No cancela recovery ni altera timings de golpes: sólo encadena la próxima
# decisión ofensiva en el primer frame legal, agrupando ataques en tandas.
var ia_rafaga_dificil_restante: int = 0
var ia_rafaga_dificil_ultimo_tipo: String = ""

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
# 90.10.23 — DASH DE COMBATE por doble pulsación. La segunda pulsación ya
# no activa una carrera sostenida/derrape: dispara un impulso corto y limpio
# en la dirección pulsada. El luchador SIEMPRE conserva la mirada hacia el
# rival, así el mismo sistema sirve como dash ofensivo (hacia delante) y
# evasión rápida (hacia atrás).
const VENTANA_DOBLE_PULSO_CARRERA := 0.28
const MULT_CARRERA := 2.05
const DASH_DURACION := 0.17
const DASH_FRENO := 0.10
# 90.11.09 — AIR DASH. Reutiliza exactamente la velocidad y duración del dash
# terrestre, pero sólo aplica el impulso X: la velocidad Y/gravedad siguen su
# curso normal. Se permite UNA vez por permanencia en el aire y se recarga al
# aterrizar. El doble salto no se consume ni se reinicia por usarlo.
const MULT_DASH_AEREO := MULT_CARRERA
const DASH_AEREO_DURACION := DASH_DURACION
var dash_aereo_activo: bool = false
var dash_aereo_direccion: float = 0.0
var dash_aereo_timer: float = 0.0
var dash_aereo_usado: bool = false
# 91.02.14 — PASS 2 dinámica aérea. El segundo salto conserva ventaja real
# para cruce aéreo, pero baja de x1.40 a x1.25 para reducir tiempo suspendido
# y acercar el ritmo a la referencia de juegos de pelea sin tocar el primer salto.
const MULT_DOBLE_SALTO_ALTURA := 1.25
# 91.02.29 — PASS 9.3E. Sólo al ATERRIZAR y sólo si un ataque normal ya terminó
# STARTUP+ACTIVO. Conserva una micro-recuperación legible sin dejar al luchador
# clavado en suelo después de un ataque aéreo.
const RECOVERY_ATERRIZAJE_NORMAL_MAX := 0.033
var doble_pulso_izq_timer: float = 0.0
var doble_pulso_der_timer: float = 0.0
var tecla_izq_previa: bool = false
var tecla_der_previa: bool = false
var carrera_activa: bool = false
var carrera_direccion: float = 0.0
var carrera_inicio_timer: float = 0.0
var carrera_frenado_timer: float = 0.0
var carrera_humo_timer: float = 0.0
const CARRERA_IMPULSO_INICIAL := 220.0
const CARRERA_POLVO_INTERVALO := 0.08

# 90.10.23 — cruce aéreo. El SEGUNDO salto puede pasar por encima del rival;
# mientras dura el cruce se ignora únicamente la colisión Fighter↔Fighter.
# El suelo y los límites de arena siguen funcionando normalmente.
var cruce_aereo_activo: bool = false
var asentamiento_aterrizaje: float = 0.0
const SUELO_REFERENCIA_Y := 560.0
# Ajuste visual global de la línea de combate. La física del escenario sigue
# en Y=560, pero sprites, sombras y cajas de golpe se presentan más abajo.
const OFFSET_VISUAL_LINEA_COMBATE_Y := 28.0
# Ajuste adicional exclusivo de la pose horizontal de K.O.
const OFFSET_DERRIBADO_FINAL_Y := 22.0
# 91.02.20 — PASS 8: apoyo VISUAL del derribo temporal de CORE I/II.
# No mueve el CharacterBody ni cambia gravedad, velocidad o timers: solamente
# baja la textura horizontal unos píxeles para que el torso apoye en el piso.
const OFFSET_DERRIBADO_ESPECIAL_Y := 18.0
const OFFSET_DERRIBADO_ESPECIAL_DINAMICO_MAX := 12.0
# 90.10.70 — apoyo visual dinámico del K.O. horizontal. Algunos PNG de
# derribado (pelo, alas, aura, extremidades) tienen alfa por debajo del torso
# y el used_rect deja al cuerpo principal visualmente suspendido aunque el
# CharacterBody ya esté exactamente en Y=560. Este extra pequeño se calcula
# por el alto visible de la pose y sólo se aplica al K.O. definitivo.
const OFFSET_DERRIBADO_DINAMICO_MAX := 18.0
const DISTANCIA_FINAL_GANADOR_DERRIBADO := 190.0
# 90.10.72 — presentación final: una vez cargada la pose de victoria, el
# ganador mantiene aire suficiente respecto al cuerpo horizontal del perdedor.
# Se calcula además con los radios visuales reales, así no depende de un PNG.
const DISTANCIA_VICTORIA_GANADOR_DERRIBADO := 220.0
const MARGEN_VICTORIA_KO_VISUAL := 34.0

func _aplicar_redisenos_visuales_91_02_09() -> void:
	# 91.02.09 — override VISUAL únicamente. No modifica física, daño, hitboxes ni timings.
	# Aethel: su rediseño final vive en una ruta dedicada para no reutilizar
	# escalas/rutas históricas del arte anterior. Se fuerza aquí para que funcione
	# incluso si el script de personaje del proyecto todavía conserva referencias viejas.
	if nombre_luchador == "Aethel":
		const BASE := "res://assets/aethel_redesign_final/"
		if ResourceLoader.exists(BASE + "parado.png"):
			textura_parado = load(BASE + "parado.png")
			textura_punetazo = load(BASE + "punetazo_1.png")
			texturas_punetazo_extra = [
				load(BASE + "punetazo_2.png"),
				load(BASE + "punetazo_5_90_10_66.png"),
				load(BASE + "punetazo_3.png"),
				load(BASE + "punetazo_4.png"),
			]
			textura_patada = load(BASE + "patada_1.png")
			texturas_patada_extra = [
				load(BASE + "patada_2.png"),
				load(BASE + "patada_5_rodillazo_90_10_66.png"),
				load(BASE + "patada_3.png"),
				load(BASE + "patada_6_90_10_66.png"),
				load(BASE + "patada_4.png"),
			]
			textura_golpe_recibido = load(BASE + "golpe_recibido_1.png")
			texturas_golpe_recibido_extra = [load(BASE + "golpe_recibido_2.png"), load(BASE + "golpe_recibido_3.png")]
			textura_derribado = load(BASE + "derribado.png")
			var levitacion: Texture2D = load(BASE + "levitacion.png")
			texturas_caminata = [levitacion, levitacion]
			textura_caminata_der = levitacion
			textura_caminata_izq = levitacion
			textura_carrera = load(BASE + "carrera.png")
			textura_evasion = load(BASE + "evasion.png")
			textura_furia_evasion = textura_evasion
			textura_salto = load(BASE + "salto.png")
			textura_doble_salto = load(BASE + "doble_salto.png")
			textura_descenso = load(BASE + "descenso.png")
			textura_bloqueo = load(BASE + "bloqueo.png")
			textura_recarga = load(BASE + "recarga.png")
			textura_victoria = load(BASE + "victoria.png")
			textura_rematador = load(BASE + "rematador.png")
			textura_furia_parado = textura_parado
			textura_furia_punetazo = load(BASE + "combo_1.png")
			texturas_furia_punetazo_extra = [load(BASE + "combo_3.png"), load(BASE + "combo_5.png")]
			textura_furia_patada = load(BASE + "combo_2.png")
			texturas_furia_patada_extra = [load(BASE + "combo_4.png"), load(BASE + "combo_6.png")]
			textura_furia_golpe_recibido = textura_golpe_recibido
			textura_furia_derribado = textura_derribado
			texturas_furia_caminata = [levitacion, levitacion]
			textura_furia_carrera = load(BASE + "aceleracion_combo.png")
			textura_furia_salto = textura_salto
			textura_furia_doble_salto = textura_doble_salto
			textura_furia_descenso = textura_descenso
			textura_furia_bloqueo = textura_bloqueo

	# Kai y Xenoid: ruta nueva dedicada. Esto evita que el motor continúe usando
	# una referencia/importación anterior de assets/<personaje>/recarga.png.
	var recarga_override := {
		"Kai": "res://assets/recharge_redesign_final/kai.png",
		"Xenoid": "res://assets/recharge_redesign_final/xenoid.png",
	}
	if recarga_override.has(nombre_luchador):
		var ruta_recarga: String = recarga_override[nombre_luchador]
		if ResourceLoader.exists(ruta_recarga):
			textura_recarga = load(ruta_recarga)

func _cargar_textura_core2_entrada() -> void:
	textura_core2_entrada = null

	if CORE2_ENTRADA_POR_LUCHADOR.has(nombre_luchador):
		var ruta_dedicada: String = CORE2_ENTRADA_DIR + String(CORE2_ENTRADA_POR_LUCHADOR[nombre_luchador])
		if ResourceLoader.exists(ruta_dedicada):
			textura_core2_entrada = load(ruta_dedicada)
			return

	# Fallback futuro: también acepta un PNG dedicado dentro de la carpeta
	# propia del luchador, sin volver a tocar Fighter.
	if textura_parado:
		var base_assets: String = textura_parado.resource_path.get_base_dir()
		var candidatos: Array[String] = [
			"core2_entrada.png", "core2-entry.png", "entrada_core2.png",
			"gigantografia_entrada.png", "poster_entrada.png", "entrada.png"
		]
		for nombre_asset in candidatos:
			var ruta_local: String = base_assets + "/" + nombre_asset
			if ResourceLoader.exists(ruta_local):
				textura_core2_entrada = load(ruta_local)
				return


func _ready() -> void:
	_aplicar_redisenos_visuales_91_02_09()
	_cargar_textura_core2_entrada()
	# FASE 85: si más adelante se agrega assets/<personaje>/victoria.png, se
	# detecta solo. Así podemos incorporar las poses de victoria sin volver a
	# tocar cada script individual.
	if not textura_victoria and textura_parado:
		var ruta_victoria: String = textura_parado.resource_path.get_base_dir() + "/victoria.png"
		if ResourceLoader.exists(ruta_victoria):
			textura_victoria = load(ruta_victoria)

	# 90.10.41 — recuperar automáticamente el sprite dedicado de EVASIÓN /
	# backdash que ya exista en la carpeta de cada peleador. Se aceptan varios
	# nombres habituales para no obligar a renombrar assets anteriores.
	if textura_parado:
		var base_assets: String = textura_parado.resource_path.get_base_dir()
		if not textura_evasion:
			var candidatos_evasion: Array[String] = [
				"evasion.png", "evasión.png", "backdash.png", "dash_atras.png",
				"dash_atrás.png", "retroceso.png", "aceleracion_atras.png",
				"aceleracion_atrás.png", "evasiva.png", "esquiva.png"
			]
			for nombre_asset in candidatos_evasion:
				var ruta_evasion: String = base_assets + "/" + nombre_asset
				if ResourceLoader.exists(ruta_evasion):
					textura_evasion = load(ruta_evasion)
					break
		if not textura_furia_evasion:
			var candidatos_furia_evasion: Array[String] = [
				"furia_evasion.png", "furia_evasión.png", "evasion_furia.png",
				"furia_backdash.png", "furia_dash_atras.png", "furia_dash_atrás.png"
			]
			for nombre_asset_furia in candidatos_furia_evasion:
				var ruta_furia_evasion: String = base_assets + "/" + nombre_asset_furia
				if ResourceLoader.exists(ruta_furia_evasion):
					textura_furia_evasion = load(ruta_furia_evasion)
					break

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

func _actualizar_orientacion_hacia_rival() -> void:
	# Al comenzar una pelea ambos scripts arrancan con mirando=1.0. Una vez que
	# main asigna `objetivo`, corregimos automáticamente la orientación.
	# También mantiene la regla de juego: aun retrocediendo/evasionando, el
	# luchador sigue mirando al contrincante.
	if not objetivo or not is_instance_valid(objetivo):
		return
	if esta_derrotado or bloqueo_cinematico or en_secuencia_especial:
		return
	if fase_ataque != FaseAtaque.NINGUNA:
		return

	var dx: float = objetivo.global_position.x - global_position.x
	if absf(dx) > 1.0:
		mirando = signf(dx)


func _orientar_hacia_rival_inmediato() -> void:
	# Se usa justo antes de lanzar un golpe. En el aire el input horizontal
	# puede ocurrir en el mismo frame que X/C; esta corrección evita que ese
	# input haga salir un puño/patada hacia el lado contrario al oponente.
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return
	var dx: float = objetivo.global_position.x - global_position.x
	if absf(dx) > 1.0:
		mirando = signf(dx)


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
	capa_facial = Node2D.new()
	capa_facial.name = "ExpresionFacial"
	capa_facial.z_index = 8
	add_child(capa_facial)
	var datos: Vector4 = DATOS_CARA.get(nombre_luchador, Vector4(0.0, -195.0, 5.0, 9.0))
	var centro_y: float = datos.y
	var separacion: float = datos.z
	var ancho_ojo: float = datos.w
	parpado_izq = _crear_parpado()
	parpado_der = _crear_parpado()
	parpado_izq.position = Vector2(-separacion, centro_y)
	parpado_der.position = Vector2(separacion, centro_y)
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
	if rollback_delta_override >= 0.0:
		delta = rollback_delta_override
		rollback_delta_override = -1.0
	_delta_actual = delta
	debug_x_inicio_frame = global_position.x
	debug_delta_x_frame = 0.0
	# 90.10.89 — latch del DASH. La 90.10.88 comprobaba carrera_activa sólo al
	# final del frame. Si el pushbox frenaba la carrera antes de llegar al guard,
	# el frame dejaba de parecer un frame de dash y J2 podía quedar desplazado.
	# Guardamos si YA veníamos en dash y luego sumamos cualquier dash iniciado
	# durante este mismo frame. Así el estado no se pierde aunque se frene.
	var dash_activo_al_inicio_frame: bool = carrera_activa
	dash_iniciado_este_frame = false

	# 90.11.06 — este reloj corre incluso durante hit-stop para que el lock de
	# recepción no dure artificialmente más que la ráfaga que protege.
	if ia_combo_cancel_lock_timer > 0.0:
		ia_combo_cancel_lock_timer = maxf(0.0, ia_combo_cancel_lock_timer - delta)

	# PASS 12A — reloj propio del nuevo movimiento.
	_actualizar_lanzamiento_proyectil(delta)

	# Snapshot del rival antes de cualquier mutación hecha por este Fighter.
	var rival_x_antes_del_frame: float = objetivo.global_position.x if objetivo and is_instance_valid(objetivo) else 0.0

	# 90.10.82 — un solo sistema de contacto entre luchadores. La excepción
	# se instala apenas ambos Fighter ya se conocen como objetivo. No afecta
	# suelo, límites ni otros cuerpos: sólo evita que move_and_slide() resuelva
	# también el choque Fighter-vs-Fighter antes/después de nuestro pushbox.
	_asegurar_pushbox_manual_con_rival()

	# 90.10.15 — ESTADO FINAL DE VICTORIA.
	# Una vez declarada la victoria, este Fighter queda completamente fuera de
	# la simulación de combate hasta el cambio de escena. No acepta input,
	# footwork, empujes residuales ni separación corporal. El Tween visual de
	# la pose sigue funcionando porque corre fuera de _physics_process().
	if en_pose_victoria:
		velocity = Vector2.ZERO
		empuje_timer = 0.0
		empuje_x = 0.0
		empuje_pendiente_timer = 0.0
		empuje_pendiente_fuerza = 0.0
		contacto_post_golpe_timer = 0.0
		contacto_post_golpe_distancia = 0.0
		_aplicar_limites_arena()
		return

	# 90.10.16 — el contacto ya confirmado tiene prioridad incluso durante
	# hit-stop. Evita que el follow-through, footwork o el orden de físicas
	# vuelvan a meter los torsos uno dentro del otro justo después del impacto.
	_mantener_separacion_post_golpe(delta)

	if hitstop_timer > 0.0:
		hitstop_timer -= delta
		# 90.10.14 — el hit-stop congela animación/inputs, NO los límites del mundo.
		# Un rival podía ser empujado fuera por el proceso del otro luchador y, si
		# estaba en hit-stop, saltarse varios frames de clamp quedando fuera de escena.
		_aplicar_limites_arena()
		if objetivo and is_instance_valid(objetivo):
			objetivo._aplicar_limites_arena()
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
			var gravedad_frame: float = gravedad
			var vuelo_salto_normal: bool = saltos_usados > 0 and hitstun_timer <= 0.0 and not derribo_especial_activo
			# 91.02.15 — PASS 3. Al entrar en la banda del vértice, un salto real
			# atraviesa Y≈0 un poco más rápido. Es una rama mutuamente exclusiva
			# con la caída x1.35 para no acumular multiplicadores.
			if vuelo_salto_normal and absf(velocity.y) <= UMBRAL_VELOCIDAD_VERTICE:
				gravedad_frame *= MULT_GRAVEDAD_VERTICE
			# 91.02.13 — PASS 1: sólo el descenso libre normal gana peso.
			elif velocity.y > 0.0 and hitstun_timer <= 0.0 and not derribo_especial_activo:
				gravedad_frame *= MULT_GRAVEDAD_CAIDA_LIBRE
				# 91.02.16 — PASS 4. Sólo un salto real en caída franca recibe
				# este último empujón de gravedad. Launcher/impactos/derribos quedan fuera.
				if vuelo_salto_normal and velocity.y >= UMBRAL_CAIDA_FINAL:
					gravedad_frame *= MULT_GRAVEDAD_CAIDA_FINAL
			velocity.y += gravedad_frame * delta
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
			var puede_actuar: bool = not esta_derrotado and not congelado_por_rival \
				and not en_lanzamiento_proyectil \
				and fase_ataque == FaseAtaque.NINGUNA and hitstun_timer <= 0.0 \
				and recuperacion_post_levantada_timer <= 0.0
			if en_lanzamiento_proyectil:
				velocity.x = move_toward(velocity.x, 0.0, friccion_suelo * 2.0 * delta)
			elif puede_actuar:
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
	if guardia_escape_esquina_cooldown > 0.0:
		guardia_escape_esquina_cooldown = maxf(0.0, guardia_escape_esquina_cooldown - delta)

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
	_actualizar_dash_aereo(delta)
	_actualizar_fase_ataque(delta)
	# 90.10.94 — si un botón se pulsó durante recovery, puede dispararse en el
	# primer frame legal inmediatamente después de terminar la animación.
	_actualizar_buffer_ataque(delta)
	_actualizar_orientacion_hacia_rival()

	# H8.3 — el Target Lock CORE I avanza una sola vez por physics tick.
	# Si Especial se activó en este mismo tick, éste es también su primer paso,
	# igualando el primer avance que antes hacía Tween al final del frame.
	_actualizar_core1_target_lock(delta)
	_actualizar_core1_poster_logico(delta)
	_actualizar_core2_fsm(delta)
	_actualizar_core3_fsm(delta)

	# Profundidad dinámica: un luchador más bajo en pantalla queda delante
	# de uno que está saltando. Durante un impacto, el que recibe queda un
	# poco por delante para que el golpe se lea como contacto físico y no
	# como dos papeles atravesándose.
	_actualizar_profundidad_visual()

	var delta_reloj_seguridad := delta
	if rollback_reloj_seguridad_delta_override >= 0.0:
		delta_reloj_seguridad = rollback_reloj_seguridad_delta_override
		rollback_reloj_seguridad_delta_override = -1.0

	if en_secuencia_especial or congelado_por_rival:
		reloj_seguridad_secuencia += delta_reloj_seguridad
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

	# 90.10.11 — SEGUNDO CHEQUEO DE CONTACTO DESPUÉS DEL MOVIMIENTO.
	# El chequeo normal de la fase de ataque ocurre antes de move_and_slide().
	# Si el rival entra caminando en la patada durante ESTE MISMO cuadro, antes
	# podía atravesar visualmente la pierna y recién se comprobaba al cuadro
	# siguiente (cuando la ventana activa ya podía haber terminado). Repetimos
	# el chequeo post-movimiento para ambos luchadores; _atk_ya_conecto evita
	# cualquier daño duplicado.
	if fase_ataque == FaseAtaque.ACTIVO and not _atk_ya_conecto:
		_chequear_impacto_ataque()
	if objetivo and is_instance_valid(objetivo):
		if objetivo.fase_ataque == FaseAtaque.ACTIVO and not objetivo._atk_ya_conecto:
			objetivo._chequear_impacto_ataque()

	_aplicar_separacion_fisica()
	# 90.10.14 — la separación puede mover a LOS DOS cuerpos. Por eso no basta
	# con limitar solamente a quien está ejecutando este _physics_process.
	_aplicar_limites_arena()
	if objetivo and is_instance_valid(objetivo):
		objetivo._aplicar_limites_arena()

	# 90.10.89 — último guard del frame del atacante con DASH LATCHED.
	# Aunque _aplicar_separacion_fisica() haya detenido carrera_activa al llegar
	# al cuerpo, este booleano recuerda que el frame nació/continuó como dash.
	var hubo_dash_en_este_frame: bool = dash_activo_al_inicio_frame or carrera_activa or dash_iniciado_este_frame
	_anclar_rival_neutral_durante_dash(rival_x_antes_del_frame, hubo_dash_en_este_frame)
	debug_delta_x_frame = global_position.x - debug_x_inicio_frame

	var aterrizo_ahora := _estaba_en_aire and is_on_floor()
	en_el_aire = not is_on_floor()
	if aterrizo_ahora and cruce_aereo_activo:
		_terminar_cruce_aereo()
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
		_resolver_transicion_aterrizaje_dinamica()
	_estaba_en_aire = en_el_aire

	if derribo_especial_activo and not derribo_especial_esperando_aterrizar and derribo_especial_se_levanta and not esta_derrotado:
		derribo_especial_timer = maxf(0.0, derribo_especial_timer - delta)
		if derribo_especial_timer <= 0.0:
			_terminar_derribo_especial()

	if is_on_floor():
		saltos_usados = 0
		# AIR DASH se recarga únicamente al tocar suelo.
		dash_aereo_usado = false
		if dash_aereo_activo:
			_detener_dash_aereo()

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
			# 91.02.20 — PASS 8. Durante el póster/remate de CORE II el rival
			# permanece congelado en su última pose de impacto hasta el instante
			# exacto del derribo. Es presentación pura: no prolonga hitstun ni
			# altera el tick lógico del rematador.
			var mantener_reaccion_combo: bool = _mantener_reaccion_visual_congelada()
			if not mantener_reaccion_combo:
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
		var quieto: bool = is_on_floor() and not moviendose and not en_el_aire \
			and not bloqueando and pose_timer <= 0.0 and not esta_derrotado \
			and not en_secuencia_especial and not congelado_por_rival and not derribo_especial_activo
		if quieto:
			# La respiración aumenta ligeramente cuando el CORE está cerca
			# de llenarse: el luchador transmite concentración/esfuerzo sin
			# cambiar su tamaño normal.
			var carga_core: float = clampf(poder / maxf(poder_maximo, 1.0), 0.0, 1.0)
			var ritmo_respiracion: float = lerpf(1.6, 2.15, carga_core * carga_core)
			ciclo_reposo += delta * ritmo_respiracion
			var amplitud_respiracion: float = lerpf(2.5, 4.0, carga_core) * escala_actual
			var respiracion: float = sin(ciclo_reposo) * amplitud_respiracion
			var transferencia_peso: float = sin(ciclo_reposo * 0.5 + 0.8) * (0.65 + carga_core * 0.35) * escala_actual
			sprite.position.y = sprite_base_y + rebote + respiracion
			sprite.position.x = _sprite_ancla_x() + transferencia_peso
			sprite.rotation = sin(ciclo_reposo * 0.5) * lerpf(0.010, 0.015, carga_core)
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
			var mantener_reaccion_combo_timer: bool = _mantener_reaccion_visual_congelada()
			if not mantener_reaccion_combo_timer:
				_actualizar_textura(_tex_reposo())

	# Se ejecuta al final para que squash/impacto no sea pisado por la
	# actualización normal de textura/respiración del cuadro.
	_actualizar_sensacion_fisica(delta)
	_actualizar_expresion_facial(delta)
	_actualizar_aura_core(delta)

	# 90.10.91 — ÚLTIMA AUTORIDAD VISUAL DEL FRAME.
	# El diagnóstico 90.10.90 demostró que J2 podía estar lógicamente quieto
	# (input=0, carrera_activa=false, velocity.x=0 y X mundial sin cambios) y,
	# aun así, renderizar durante unos cuadros la textura de evasión/backdash.
	# La presentación debe derivar del estado lógico, nunca al revés.
	_corregir_visual_dash_fantasma_local()

# Cada personaje decide cómo se mueve: IA, input local o un Input Frame externo.
func _procesar_entrada(_delta: float, _vel_actual: float) -> void:
	if fuente_control == FuenteControl.EXTERNA:
		var frame: Dictionary = input_frame_externo if input_externo_disponible else _input_frame_neutro()
		_aplicar_input_frame(frame, _vel_actual)
		input_externo_disponible = false
		return

	# Compatibilidad: si una escena vieja sólo puso el booleano en true, sigue
	# entrando exactamente por el camino humano local.
	if controlado_por_jugador or fuente_control == FuenteControl.LOCAL:
		_entrada_jugador(_vel_actual)

# API de control preparada para Versus local y futuro online.
func configurar_lado_combate(indice_lado: int) -> void:
	indice_lado_combate = clampi(indice_lado, 0, 1)

func configurar_control_local(indice_jugador: int = 0, gamepad_id: int = -1, teclado_habilitado: bool = true) -> void:
	# indice 0 = J1; indice 1 = J2. gamepad_id -2 fuerza teclado solamente.
	# `teclado_habilitado` permite aislamiento estricto por dispositivo en Versus.
	jugador_local_indice = clampi(indice_jugador, 0, 1)
	gamepad_asignado_id = gamepad_id
	teclado_local_habilitado = teclado_habilitado
	fuente_control = FuenteControl.LOCAL
	controlado_por_jugador = true
	input_externo_disponible = false

func configurar_control_ia(dificultad: int = DificultadIA.FACIL) -> void:
	dificultad_ia = clampi(dificultad, DificultadIA.FACIL, DificultadIA.DIFICIL)
	fuente_control = FuenteControl.IA
	controlado_por_jugador = false
	input_externo_disponible = false

func configurar_dificultad_ia(dificultad: int) -> void:
	dificultad_ia = clampi(dificultad, DificultadIA.FACIL, DificultadIA.DIFICIL)

func configurar_control_externo() -> void:
	fuente_control = FuenteControl.EXTERNA
	controlado_por_jugador = true
	input_externo_disponible = false

# Un frame contiene sólo intención de botones/direcciones. No contiene posición,
# daño ni estados del Fighter: por eso puede viajar por red y re-simularse luego.
func inyectar_input_frame(frame: Dictionary) -> void:
	input_frame_externo = frame.duplicate(true)
	input_frame_enrutado_actual = frame.duplicate(true)
	input_externo_disponible = true

# 90.10.93 — Versus Local usa esta fuente. El Fighter recibe intención ya
# separada por dispositivo desde Main y se le apagan explícitamente todas las
# rutas locales de teclado/gamepad para que no pueda existir input espejo.
func configurar_control_enrutado(indice_jugador: int) -> void:
	jugador_local_indice = clampi(indice_jugador, 0, 1)
	gamepad_asignado_id = -2
	teclado_local_habilitado = false
	fuente_control = FuenteControl.EXTERNA
	controlado_por_jugador = true
	input_frame_externo = _input_frame_neutro()
	input_frame_enrutado_actual = _input_frame_neutro()
	input_externo_disponible = true
	tecla_izq_previa = false
	tecla_der_previa = false
	doble_pulso_izq_timer = 0.0
	doble_pulso_der_timer = 0.0
	carrera_activa = false
	carrera_direccion = 0.0
	puno_estaba_presionado = false
	patada_estaba_presionada = false
	ataque_buffer_tipo = ""
	ataque_buffer_timer = 0.0

func _input_frame_neutro() -> Dictionary:
	return {
		"izquierda": false,
		"derecha": false,
		"salto": false,
		"bloqueo": false,
		"puno": false,
		"patada": false,
		"especial": false,
	}

func _capturar_input_local() -> Dictionary:
	# 90.10.85: misma lectura que 90.10.84, pero guardando los valores CRUDOS
	# para mostrarlos en pantalla. No altera deadzones ni botones.
	var es_j2: bool = jugador_local_indice == 1
	var teclado_izq: bool = teclado_local_habilitado and (Input.is_physical_key_pressed(KEY_A) if es_j2 else Input.is_physical_key_pressed(KEY_LEFT))
	var teclado_der: bool = teclado_local_habilitado and (Input.is_physical_key_pressed(KEY_D) if es_j2 else Input.is_physical_key_pressed(KEY_RIGHT))
	var salto_teclado: bool = teclado_local_habilitado and (Input.is_physical_key_pressed(KEY_W) if es_j2 else Input.is_physical_key_pressed(KEY_UP))
	var bloqueo_teclado: bool = teclado_local_habilitado and (Input.is_physical_key_pressed(KEY_S) if es_j2 else Input.is_physical_key_pressed(KEY_DOWN))
	var puno_teclado: bool = teclado_local_habilitado and (Input.is_physical_key_pressed(KEY_F) if es_j2 else Input.is_physical_key_pressed(KEY_X))
	var patada_teclado: bool = teclado_local_habilitado and (Input.is_physical_key_pressed(KEY_G) if es_j2 else Input.is_physical_key_pressed(KEY_C))
	var especial_teclado: bool = teclado_local_habilitado and (Input.is_physical_key_pressed(KEY_H) if es_j2 else Input.is_physical_key_pressed(KEY_Z))

	debug_gamepad_axis_x = _gamepad_eje(PAD_AXIS_LEFT_X)
	debug_gamepad_dpad_izq = _gamepad_boton_activo(PAD_DPAD_LEFT)
	debug_gamepad_dpad_der = _gamepad_boton_activo(PAD_DPAD_RIGHT)
	debug_input_izquierda = teclado_izq or debug_gamepad_dpad_izq or debug_gamepad_axis_x < -PAD_DEADZONE_MOV
	debug_input_derecha = teclado_der or debug_gamepad_dpad_der or debug_gamepad_axis_x > PAD_DEADZONE_MOV

	return {
		"izquierda": debug_input_izquierda,
		"derecha": debug_input_derecha,
		"salto": salto_teclado or _gamepad_salto_activo(),
		"bloqueo": bloqueo_teclado or _gamepad_bloqueo_activo(),
		"puno": puno_teclado or _gamepad_boton_activo(PAD_X),
		"patada": patada_teclado or _gamepad_boton_activo(PAD_Y),
		"especial": especial_teclado or _gamepad_especial_activo(),
	}

func obtener_debug_control() -> Dictionary:
	return {
		"jugador": jugador_local_indice + 1,
		"fuente": fuente_control,
		"pad": gamepad_asignado_id,
		"teclado": teclado_local_habilitado,
		"axis_x": debug_gamepad_axis_x,
		"dpad_l": debug_gamepad_dpad_izq,
		"dpad_r": debug_gamepad_dpad_der,
		"izq": debug_input_izquierda,
		"der": debug_input_derecha,
		"dash": carrera_activa,
		"dash_dir": carrera_direccion,
		"vx": velocity.x,
		"x": global_position.x,
		"dx_frame": debug_delta_x_frame,
	}

func _entrada_jugador(vel_actual: float) -> void:
	# Los scripts de cada personaje ya llaman a esta función cuando
	# `controlado_por_jugador` es true. Resolver EXTERNA acá garantiza que TODOS
	# los luchadores puedan usar luego exactamente el mismo camino para rollback/red,
	# aunque tengan su propio override de _procesar_entrada().
	if fuente_control == FuenteControl.EXTERNA:
		var frame: Dictionary = input_frame_externo if input_externo_disponible else _input_frame_neutro()
		_aplicar_input_frame(frame, vel_actual)
		input_externo_disponible = false
		return
	_aplicar_input_frame(_capturar_input_local(), vel_actual)

func _aplicar_input_frame(frame: Dictionary, vel_actual: float) -> void:
	# 90.10.94 — una única verdad de input por Fighter/frame.
	input_frame_enrutado_actual = frame.duplicate(false)
	var izquierda: bool = bool(frame.get("izquierda", false))
	var derecha: bool = bool(frame.get("derecha", false))
	var salto_presionado: bool = bool(frame.get("salto", false))
	var bloqueo_presionado: bool = bool(frame.get("bloqueo", false))
	var puno_presionado: bool = bool(frame.get("puno", false))
	var patada_presionada: bool = bool(frame.get("patada", false))
	var especial_presionado: bool = bool(frame.get("especial", false))
	var puno_presionado_crudo: bool = puno_presionado
	var puno_justo: bool = puno_presionado and not puno_estaba_presionado
	var patada_justa: bool = patada_presionada and not patada_estaba_presionada

	# PASS 12A — ↓ → + PUÑO. Si completa el comando, ese PUÑO/BLOQUEO
	# se consume sólo en este frame para no disparar también otra mecánica.
	var comando_proyectil_consumido: bool = _procesar_comando_proyectil(
		bloqueo_presionado,
		izquierda,
		derecha,
		puno_justo
	)
	if comando_proyectil_consumido:
		bloqueo_presionado = false
		puno_presionado = false
		puno_justo = false
		input_frame_enrutado_actual["bloqueo"] = false
		input_frame_enrutado_actual["puno"] = false

	ultima_intencion_horizontal = (-1.0 if izquierda else 0.0) + (1.0 if derecha else 0.0)

	var izquierda_justa: bool = izquierda and not tecla_izq_previa
	var derecha_justa: bool = derecha and not tecla_der_previa

	# Doble toque determinista a partir del mismo frame de intención.
	doble_pulso_izq_timer = maxf(0.0, doble_pulso_izq_timer - _delta_actual)
	doble_pulso_der_timer = maxf(0.0, doble_pulso_der_timer - _delta_actual)

	if izquierda_justa:
		if doble_pulso_izq_timer > 0.0:
			_iniciar_dash_por_doble_toque(-1.0)
			doble_pulso_izq_timer = 0.0
		else:
			doble_pulso_izq_timer = VENTANA_DOBLE_PULSO_CARRERA
		if carrera_activa and carrera_direccion > 0.0:
			_detener_carrera()

	if derecha_justa:
		if doble_pulso_der_timer > 0.0:
			_iniciar_dash_por_doble_toque(1.0)
			doble_pulso_der_timer = 0.0
		else:
			doble_pulso_der_timer = VENTANA_DOBLE_PULSO_CARRERA
		if carrera_activa and carrera_direccion < 0.0:
			_detener_carrera()

	tecla_izq_previa = izquierda
	tecla_der_previa = derecha

	var direccion: float = 0.0
	if izquierda:
		direccion -= 1.0
	if derecha:
		direccion += 1.0
	if dash_aereo_activo:
		# Durante el burst aéreo el input no degrada la velocidad horizontal.
		# La componente Y queda intacta para conservar exactamente el arco del salto.
		_orientar_hacia_rival_inmediato()
		velocity.x = dash_aereo_direccion * vel_actual * MULT_DASH_AEREO
	elif carrera_activa:
		_orientar_hacia_rival_inmediato()
		velocity.x = carrera_direccion * vel_actual * MULT_CARRERA
	else:
		mover(direccion, vel_actual)

	# Salto y CORE derivan sus flancos desde el frame actual/anterior. Este mismo
	# mecanismo funcionará para un frame recibido por red.
	var salto_justo: bool = salto_presionado and not salto_estaba_presionado
	if salto_justo:
		saltar()
	salto_estaba_presionado = salto_presionado
	gamepad_salto_previo = salto_presionado

	if bloqueo_presionado:
		if not bloqueando:
			_iniciar_bloqueo(999.0)
	elif bloqueando:
		_detener_bloqueo()

	# 90.10.94 — el flanco se guarda si llegó durante startup/activo/recovery.
	# Después mantenemos el comportamiento histórico de botón sostenido para no
	# cambiar el feel del teclado: intentar_* simplemente retorna si aún no es legal.
	if puno_justo and fase_ataque != FaseAtaque.NINGUNA:
		_guardar_buffer_ataque("punetazo")
	if patada_justa and fase_ataque != FaseAtaque.NINGUNA:
		_guardar_buffer_ataque("patada")

	if puno_presionado:
		intentar_punetazo()

	if patada_presionada:
		intentar_patada()

	puno_estaba_presionado = puno_presionado_crudo
	patada_estaba_presionada = patada_presionada

	if especial_presionado and not z_estaba_presionado:
		intentar_poder_especial()
	z_estaba_presionado = especial_presionado

# PASS 12A — parser del comando ↓ → + PUÑO.
func _procesar_comando_proyectil(
	abajo: bool,
	izquierda: bool,
	derecha: bool,
	puno_justo: bool
) -> bool:
	if not proyectil_especial_habilitado:
		return false

	if comando_proyectil_timer > 0.0:
		comando_proyectil_timer = maxf(0.0, comando_proyectil_timer - _delta_actual)
		if comando_proyectil_timer <= 0.0:
			comando_proyectil_etapa = 0

	var adelante: bool = derecha if mirando >= 0.0 else izquierda

	if comando_proyectil_etapa == 0 and abajo:
		comando_proyectil_etapa = 1
		comando_proyectil_timer = VENTANA_COMANDO_PROYECTIL

	if comando_proyectil_etapa == 1 and adelante:
		comando_proyectil_etapa = 2
		comando_proyectil_timer = VENTANA_COMANDO_PROYECTIL

	if comando_proyectil_etapa == 2 and puno_justo:
		var salio: bool = intentar_proyectil_especial()
		comando_proyectil_etapa = 0
		comando_proyectil_timer = 0.0
		return salio

	return false


func intentar_proyectil_especial() -> bool:
	if not proyectil_especial_habilitado:
		return false
	if esta_derrotado or congelado_por_rival or hitstun_timer > 0.0:
		return false
	if en_secuencia_especial or bloqueo_cinematico or en_fase_absoluta:
		return false
	if fase_ataque != FaseAtaque.NINGUNA or not is_on_floor():
		return false
	if en_lanzamiento_proyectil or proyectil_cooldown_timer > 0.0:
		return false
	if proyectil_activo and is_instance_valid(proyectil_activo):
		return false
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return false

	_detener_carrera()
	_detener_dash_aereo()
	if bloqueando:
		_detener_bloqueo()
	_orientar_hacia_rival_inmediato()
	velocity.x = 0.0

	en_lanzamiento_proyectil = true
	proyectil_lanzamiento_timer = proyectil_startup + proyectil_recovery
	proyectil_spawn_timer = proyectil_startup
	proyectil_disparo_pendiente = true
	proyectil_cooldown_timer = proyectil_cooldown

	if textura_proyectil_pose and sprite:
		_actualizar_textura(textura_proyectil_pose)
		pose_timer = proyectil_lanzamiento_timer

	return true


func _actualizar_lanzamiento_proyectil(delta: float) -> void:
	if proyectil_cooldown_timer > 0.0:
		proyectil_cooldown_timer = maxf(0.0, proyectil_cooldown_timer - delta)

	if not en_lanzamiento_proyectil:
		return

	# Startup castigable.
	if esta_derrotado or congelado_por_rival or hitstun_timer > 0.0:
		en_lanzamiento_proyectil = false
		proyectil_disparo_pendiente = false
		proyectil_lanzamiento_timer = 0.0
		proyectil_spawn_timer = 0.0
		return

	proyectil_lanzamiento_timer = maxf(0.0, proyectil_lanzamiento_timer - delta)
	if proyectil_disparo_pendiente:
		proyectil_spawn_timer -= delta
		if proyectil_spawn_timer <= 0.0:
			proyectil_disparo_pendiente = false
			_disparar_proyectil_energia()

	if proyectil_lanzamiento_timer <= 0.0:
		en_lanzamiento_proyectil = false


func _disparar_proyectil_energia() -> void:
	if proyectil_activo and is_instance_valid(proyectil_activo):
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return

	var nodo = SCRIPT_PROYECTIL_ENERGIA.new()
	var dano_real: float = dano_punetazo * MULT_DANO_GLOBAL * proyectil_dano_mult
	nodo.configurar(
		self,
		objetivo,
		mirando,
		proyectil_velocidad,
		dano_real,
		proyectil_empuje * peso_golpe,
		proyectil_hitstun,
		color_proyectil_primario,
		color_proyectil_secundario,
		textura_proyectil_nucleo,
		sonido_proyectil_impacto
	)

	var escena = get_tree().current_scene
	if not escena:
		return
	escena.add_child(nodo)

	var alto_visible: float = _altura_visible_objetivo()
	var salida_x: float = maxf(76.0, ancho_cuerpo * 0.72)
	nodo.global_position = global_position + Vector2(
		mirando * salida_x,
		-alto_visible * proyectil_spawn_altura_mult
	)
	proyectil_activo = nodo
	# Audio/voz se resuelve en Main para no mezclar presentación con colisión.
	proyectil_disparado.emit()


func _notificar_proyectil_terminado(nodo: Node) -> void:
	if proyectil_activo == nodo:
		proyectil_activo = null


# Resuelve el mando asignado a ESTE Fighter.
# -2 = teclado solamente (sin fallback a un gamepad compartido).
# -1 = compatibilidad histórica: usar el primer mando conectado.
# >=0 = device id explícito, usado por Versus local.
func _gamepad_principal_id() -> int:
	if gamepad_asignado_id == -2:
		return -1
	var pads := Input.get_connected_joypads()
	if pads.is_empty():
		return -1
	if gamepad_asignado_id >= 0:
		return gamepad_asignado_id if gamepad_asignado_id in pads else -1
	return int(pads[0])

func _gamepad_boton_activo(boton: int) -> bool:
	var id := _gamepad_principal_id()
	return id >= 0 and Input.is_joy_button_pressed(id, boton)

func _gamepad_eje(eje: int) -> float:
	var id := _gamepad_principal_id()
	if id < 0:
		return 0.0
	return Input.get_joy_axis(id, eje)

func _control_izquierda_activo() -> bool:
	if fuente_control == FuenteControl.EXTERNA:
		return bool(input_frame_enrutado_actual.get("izquierda", false))
	var teclado: bool = teclado_local_habilitado and (Input.is_physical_key_pressed(KEY_A) if jugador_local_indice == 1 else Input.is_physical_key_pressed(KEY_LEFT))
	return teclado \
		or _gamepad_boton_activo(PAD_DPAD_LEFT) \
		or _gamepad_eje(PAD_AXIS_LEFT_X) < -PAD_DEADZONE_MOV

func _control_derecha_activo() -> bool:
	if fuente_control == FuenteControl.EXTERNA:
		return bool(input_frame_enrutado_actual.get("derecha", false))
	var teclado: bool = teclado_local_habilitado and (Input.is_physical_key_pressed(KEY_D) if jugador_local_indice == 1 else Input.is_physical_key_pressed(KEY_RIGHT))
	return teclado \
		or _gamepad_boton_activo(PAD_DPAD_RIGHT) \
		or _gamepad_eje(PAD_AXIS_LEFT_X) > PAD_DEADZONE_MOV

func _gamepad_salto_activo() -> bool:
	return _gamepad_boton_activo(PAD_A) 		or _gamepad_boton_activo(PAD_DPAD_UP) 		or _gamepad_eje(PAD_AXIS_LEFT_Y) < -PAD_DEADZONE_VERTICAL

func _gamepad_bloqueo_activo() -> bool:
	return _gamepad_boton_activo(PAD_B) 		or _gamepad_boton_activo(PAD_DPAD_DOWN) 		or _gamepad_eje(PAD_AXIS_LEFT_Y) > PAD_DEADZONE_VERTICAL 		or _gamepad_eje(PAD_AXIS_LT) > 0.55

func _gamepad_especial_activo() -> bool:
	return _gamepad_boton_activo(PAD_RB) or _gamepad_eje(PAD_AXIS_RT) > 0.55

func _procesar_footwork_durante_ataque(vel_actual: float) -> void:
	var direccion_input: float = 0.0
	if controlado_por_jugador:
		if _control_izquierda_activo():
			direccion_input -= 1.0
		if _control_derecha_activo():
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
		# Durante un ataque NO usamos el radio visual adaptativo para frenar,
		# porque cabello/alas/poses anchas pueden detener al atacante antes de
		# que el pie o puño entre en la hurtbox real.
		var distancia_objetivo: float = 68.0 if _atk_tipo == "punetazo" else 74.0
		if separacion <= distancia_objetivo and hacia_rival:
			velocity.x = 0.0

# 90.11.09 — el MISMO doble toque decide el dash según el estado físico.
# En suelo conserva literalmente _iniciar_carrera(); en aire entra por un estado
# nuevo y aislado para no tocar el dash terrestre ya aprobado.
func _iniciar_dash_por_doble_toque(direccion: float) -> void:
	if is_on_floor():
		_iniciar_carrera(direccion)
	else:
		_iniciar_dash_aereo(direccion)

func _iniciar_dash_aereo(direccion: float) -> void:
	if is_on_floor() or saltos_usados <= 0 or dash_aereo_usado or dash_aereo_activo:
		return
	if esta_derrotado or en_secuencia_especial or bloqueo_cinematico \
		or congelado_por_rival or hitstun_timer > 0.0 or fase_ataque != FaseAtaque.NINGUNA:
		return
	var dir: float = signf(direccion)
	if dir == 0.0:
		return
	_detener_carrera()
	_orientar_hacia_rival_inmediato()
	dash_aereo_activo = true
	dash_aereo_usado = true
	dash_aereo_direccion = dir
	dash_aereo_timer = DASH_AEREO_DURACION
	velocity.x = dash_aereo_direccion * velocidad * (mult_velocidad_fase if en_fase_absoluta else 1.0) * MULT_DASH_AEREO

	# Visual: hacia atrás usa la evasión existente; hacia delante usa carrera.
	# Si un personaje carece de ese PNG, conserva su salto/doble salto/descenso.
	var tex_dash: Texture2D = _tex_carrera()
	if not tex_dash:
		tex_dash = _tex_doble_salto() if velocity.y < 0.0 else _tex_descenso()
	if tex_dash and sprite:
		_actualizar_textura(tex_dash)
		pose_timer = maxf(pose_timer, DASH_AEREO_DURACION)

func _detener_dash_aereo() -> void:
	if not dash_aereo_activo:
		return
	dash_aereo_activo = false
	dash_aereo_timer = 0.0
	dash_aereo_direccion = 0.0

func _actualizar_dash_aereo(delta: float) -> void:
	if not dash_aereo_activo:
		return
	if is_on_floor() or esta_derrotado or en_secuencia_especial or bloqueo_cinematico \
		or congelado_por_rival or hitstun_timer > 0.0 or fase_ataque != FaseAtaque.NINGUNA:
		_detener_dash_aereo()
		return
	dash_aereo_timer = maxf(0.0, dash_aereo_timer - delta)
	if dash_aereo_timer <= 0.0:
		_detener_dash_aereo()

func _iniciar_carrera(direccion: float) -> void:
	# Dash solamente desde suelo. En el aire las flechas quedan reservadas al
	# control horizontal y al cruce del doble salto.
	if not is_on_floor() or esta_derrotado or en_secuencia_especial or bloqueo_cinematico or congelado_por_rival:
		return
	carrera_activa = true
	dash_iniciado_este_frame = true
	carrera_direccion = signf(direccion)
	carrera_inicio_timer = DASH_DURACION
	carrera_frenado_timer = 0.0
	carrera_humo_timer = 0.0
	_orientar_hacia_rival_inmediato()
	velocity.x = carrera_direccion * velocidad * MULT_CARRERA
	_efecto_inicio_carrera()

func _detener_carrera() -> void:
	if not carrera_activa:
		return
	carrera_activa = false
	carrera_frenado_timer = DASH_FRENO
	carrera_inicio_timer = 0.0
	carrera_direccion = 0.0

func _actualizar_carrera_visual(delta: float) -> void:
	if carrera_activa:
		carrera_inicio_timer = maxf(0.0, carrera_inicio_timer - delta)
		if carrera_inicio_timer <= 0.0:
			_detener_carrera()
	carrera_frenado_timer = maxf(0.0, carrera_frenado_timer - delta)
	if not carrera_activa or esta_derrotado or not is_on_floor() or en_secuencia_especial:
		return
	carrera_humo_timer -= delta
	if carrera_humo_timer <= 0.0:
		carrera_humo_timer = CARRERA_POLVO_INTERVALO
		_efecto_paso(1 if carrera_direccion < 0.0 else -1)
	if sprite and fase_ataque == FaseAtaque.NINGUNA and pose_timer <= 0.0:
		var tiene_pose_dash: bool = _tex_carrera() != null
		var inclinacion_dash: float = 0.060 if (dash_visual_fallback_reforzado or not tiene_pose_dash) else 0.025
		var objetivo_rot: float = -inclinacion_dash * carrera_direccion
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

# 90.10.88 — lectura del dispositivo asignado a ESTE Fighter. Respeta el
# aislamiento J1/J2 y se usa sólo para decidir si el defensor está neutral.
func _hay_input_horizontal_local_actual() -> bool:
	if fuente_control == FuenteControl.EXTERNA:
		return bool(input_frame_enrutado_actual.get("izquierda", false)) \
			or bool(input_frame_enrutado_actual.get("derecha", false))
	if fuente_control != FuenteControl.LOCAL:
		return false
	return _control_izquierda_activo() or _control_derecha_activo()

func _puede_quedar_anclado_ante_dash() -> bool:
	if fuente_control not in [FuenteControl.LOCAL, FuenteControl.EXTERNA]:
		return false
	if esta_derrotado or derribo_especial_activo or en_secuencia_especial or bloqueo_cinematico:
		return false
	if fase_ataque != FaseAtaque.NINGUNA or hitstun_timer > 0.0:
		return false
	if empuje_timer > 0.0 or empuje_pendiente_timer > 0.0 or empuje_pendiente_fuerza > 0.0:
		return false
	return not _hay_input_horizontal_local_actual()

# Regla competitiva dura: un dash de movimiento no puede arrastrar ni activar
# movimiento del rival local si ese rival no está dando input horizontal ni
# recibiendo un golpe. Se ejecuta al final del frame del atacante y por eso
# neutraliza cualquier escritura indirecta sobre `objetivo` antes de que J2
# procese su propio frame.
func _anclar_rival_neutral_durante_dash(rival_x_antes: float, hubo_dash_en_frame: bool = false) -> void:
	if not objetivo or not is_instance_valid(objetivo):
		return
	if fuente_control not in [FuenteControl.LOCAL, FuenteControl.EXTERNA] \
		or objetivo.fuente_control not in [FuenteControl.LOCAL, FuenteControl.EXTERNA]:
		return
	# 90.10.89 — NO depender del valor final de carrera_activa. El dash puede
	# haber sido detenido por contacto unos renglones antes y aun así este frame
	# debe proteger al defensor neutral de cualquier desplazamiento espejo.
	if not hubo_dash_en_frame:
		return
	if fase_ataque != FaseAtaque.NINGUNA or en_secuencia_especial or hitstun_timer > 0.0:
		return
	if not objetivo._puede_quedar_anclado_ante_dash():
		return

	var dir_rival: float = signf(objetivo.global_position.x - global_position.x)
	if dir_rival == 0.0:
		dir_rival = mirando if mirando != 0.0 else 1.0
	var dir_dash: float = carrera_direccion
	if dir_dash == 0.0:
		# Si el contacto ya llamó _detener_carrera(), carrera_direccion también
		# quedó en 0. El latch nos confirma que fue un frame de dash; usamos la
		# dirección del rival para tratarlo como dash de entrada únicamente si el
		# atacante terminó en contacto/cercanía. Un backdash que se aleja no mueve
		# al rival y no necesita restauración porque no puede producir penetración.
		dir_dash = dir_rival
	# Backdash propio: no hay motivo para tocar al rival.
	if dir_dash * dir_rival <= 0.0:
		return

	objetivo.global_position.x = rival_x_antes
	objetivo.velocity.x = 0.0
	if objetivo.carrera_activa and not objetivo._hay_input_horizontal_local_actual():
		objetivo._detener_carrera()
	objetivo._aplicar_limites_arena()

# 90.10.91 — guard visual puro para Versus Local.
# No mueve el cuerpo, no altera inputs y no toca golpes. Sólo impide que una
# textura de carrera/evasión quede visible cuando el Fighter está lógicamente
# neutral. Esta regla ataca exactamente el caso capturado en 90.10.90:
# J2 DASH=0 / VX=0 / X estable, pero PNG de backdash en pantalla.
func _corregir_visual_dash_fantasma_local() -> void:
	if fuente_control not in [FuenteControl.LOCAL, FuenteControl.EXTERNA] or not controlado_por_jugador:
		return
	if not sprite or carrera_activa:
		return
	if _hay_input_horizontal_local_actual():
		return
	if absf(velocity.x) > 10.0:
		return
	if esta_derrotado or derribo_especial_activo or en_secuencia_especial \
		or bloqueo_cinematico or congelado_por_rival or en_pose_recarga:
		return
	if not is_on_floor() or en_el_aire or bloqueando:
		return
	if fase_ataque != FaseAtaque.NINGUNA or hitstun_timer > 0.0:
		return

	var tex_actual: Texture2D = sprite.texture
	var es_textura_dash: bool = \
		(tex_actual != null and textura_carrera != null and tex_actual == textura_carrera) \
		or (tex_actual != null and textura_furia_carrera != null and tex_actual == textura_furia_carrera) \
		or (tex_actual != null and textura_evasion != null and tex_actual == textura_evasion) \
		or (tex_actual != null and textura_furia_evasion != null and tex_actual == textura_furia_evasion)
	if not es_textura_dash:
		return

	# Estado lógico neutral => visual neutral. No tocamos pose_timer porque puede
	# pertenecer a otro subsistema; sólo sustituimos una textura imposible para
	# el estado actual y limpiamos la inclinación residual de carrera.
	var tex_neutra: Texture2D = _tex_parado()
	if tex_neutra:
		_actualizar_textura(tex_neutra)
		sprite.rotation = 0.0

func mover(direccion: float, vel_actual: float) -> void:
	if direccion != 0.0:
		# Fuera de un ataque el input puede orientar; durante STARTUP/ACTIVO
		# la orientación queda fijada hacia el golpe/rival.
		if fase_ataque == FaseAtaque.NINGUNA or fase_ataque == FaseAtaque.RECOVERY:
			mirando = sign(direccion)
		# 91.02.26 — respuesta terrestre mas inmediata sin elevar vel_actual.
		# En aire conservamos exactamente la aceleracion anterior.
		var aceleracion_aplicada: float = aceleracion
		if is_on_floor():
			aceleracion_aplicada *= MULT_ACELERACION_SUELO_DINAMICA
		velocity.x = move_toward(velocity.x, direccion * vel_actual, aceleracion_aplicada * _delta_actual)
	else:
		var friccion: float = friccion_suelo if is_on_floor() else friccion_aire
		# El freno extra existe solo en suelo. Friccion de aire queda congelada.
		if is_on_floor():
			friccion *= MULT_FRENO_SUELO_DINAMICA
		velocity.x = move_toward(velocity.x, 0.0, friccion * _delta_actual)

func saltar() -> void:
	if congelado_por_rival:
		return
	if is_on_floor():
		velocity.y = fuerza_salto
		saltos_usados = 1
		salto_hecho.emit()
	elif saltos_usados < saltos_maximos:
		velocity.y = fuerza_salto * MULT_DOBLE_SALTO_ALTURA
		saltos_usados += 1
		# El segundo salto abre una ventana real de cruce por encima del rival.
		if saltos_usados >= 2:
			_activar_cruce_aereo()
		salto_hecho.emit()

# 90.10.94 — buffer corto de ataque para taps de mando/teclado.
func _guardar_buffer_ataque(tipo: String) -> void:
	if tipo != "punetazo" and tipo != "patada":
		return
	ataque_buffer_tipo = tipo
	ataque_buffer_timer = ATAQUE_BUFFER_DURACION

func _actualizar_buffer_ataque(delta: float) -> void:
	if ataque_buffer_timer <= 0.0 or ataque_buffer_tipo.is_empty():
		ataque_buffer_timer = 0.0
		ataque_buffer_tipo = ""
		return

	ataque_buffer_timer = maxf(0.0, ataque_buffer_timer - delta)
	if ataque_buffer_timer <= 0.0:
		ataque_buffer_tipo = ""
		return

	# Sólo se consume cuando el Fighter realmente puede comenzar un golpe normal.
	if (
		fase_ataque != FaseAtaque.NINGUNA
		or bloqueando
		or esta_derrotado
		or hitstun_timer > 0.0
		or en_secuencia_especial
		or bloqueo_cinematico
		or congelado_por_rival
		or recuperacion_post_levantada_timer > 0.0
	):
		return


	var tipo: String = ataque_buffer_tipo
	ataque_buffer_tipo = ""
	ataque_buffer_timer = 0.0
	if tipo == "punetazo":
		intentar_punetazo()
	elif tipo == "patada":
		intentar_patada()

func intentar_punetazo() -> void:
	if congelado_por_rival or fase_ataque != FaseAtaque.NINGUNA or bloqueando:
		return
	var lista := _lista_punetazo()
	if lista.is_empty():
		return
	# El primer X usa el golpe 1; cada X siguiente avanza al siguiente frame.
	indice_punetazo = indice_punetazo % lista.size()
	_iniciar_ataque("punetazo", rango_punetazo, dano_punetazo, 120.0, 0.22, cooldown_punetazo)
	indice_punetazo = (indice_punetazo + 1) % lista.size()

func intentar_patada() -> void:
	if congelado_por_rival or fase_ataque != FaseAtaque.NINGUNA or bloqueando:
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
	if poder < poder_maximo or en_fase_absoluta or en_secuencia_especial or congelado_por_rival:
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
	_detener_dash_aereo()
	# 90.10.23 — también en salto/doble salto el ataque nace orientado hacia
	# el rival. El jugador puede moverse hacia atrás en el aire sin lanzar el
	# puño o la patada fuera de la pelea.
	_orientar_hacia_rival_inmediato()
	_atk_tipo = tipo
	ataque_lanzado.emit(tipo, en_fase_absoluta)
	_atk_rango = rango
	_atk_dano = dano_base
	_atk_empuje_base = empuje_base
	_atk_hitstun = hitstun_base
	_atk_ya_conecto = false

	# 90.10.12 — LA POSE VISIBLE Y LA HITBOX TIENEN EL MISMO TIEMPO.
	# El video de prueba mostró que el rival todavía podía entrar caminando en
	# una pierna VISUALMENTE extendida durante RECOVERY. Como cada golpe usa un
	# único sprite estático (no tenemos todavía cuadros de retracción), la regla
	# correcta es: mientras la pose de impacto está visible, el golpe está ACTIVO.
	# Después vuelve al reposo y recién ahí queda la recuperación lógica.
	var frac_startup: float = 0.16 if tipo == "punetazo" else 0.12
	var frac_activo: float = 0.50 if tipo == "punetazo" else 0.62
	var frac_recovery: float = maxf(0.18, 1.0 - frac_startup - frac_activo)
	# CORE II/III siguen acelerando startup + activo con el multiplicador ya
	# validado. 90.10.69 cambia únicamente el recovery de la ráfaga automática:
	# pasa a una transición mínima y constante para que todos los golpes salgan
	# corridos, sin la pausa visual de cada recuperación completa.
	var ciclo_efectivo: float = ciclo_total * (MULT_VELOCIDAD_COMBO_CORE if en_combo_auto_visual else 1.0)
	var startup: float
	if en_combo_auto_visual:
		# 90.10.98 — RÁFAGA CONTINUA. En CORE II/III el ritmo no depende del
		# cooldown individual del personaje ni del tipo de golpe. Puño y patada
		# comparten exactamente el mismo beat para evitar la micro-pausa que se
		# percibía cada vez que entraba una patada de ciclo largo.
		startup = STARTUP_COMBO_CORE_UNIFORME
		_atk_dur_activo = ACTIVO_COMBO_CORE_UNIFORME
		_atk_dur_recovery = RECOVERY_COMBO_CORE_CONTINUO
	else:
		# PASS 5: los ataques normales responden antes y vuelven antes a neutral.
		# El tiempo ACTIVO no se toca: seguimos respetando exactamente la ventana
		# visual/de contacto ya aprobada. Sólo quitamos latencia de startup/recovery.
		startup = ciclo_efectivo * frac_startup * _mult_startup_personalidad() * MULT_STARTUP_ATAQUE_NORMAL
		_atk_dur_activo = ciclo_efectivo * frac_activo
		var mult_recovery_pass5: float = MULT_RECOVERY_PUNETAZO_NORMAL if tipo == "punetazo" else MULT_RECOVERY_PATADA_NORMAL
		_atk_dur_recovery = ciclo_efectivo * frac_recovery * _mult_recovery_personalidad() * mult_recovery_pass5

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
	# La extremidad deja de verse exactamente cuando deja de poder pegar.
	# Así nunca existe el caso visual de "pie dentro del rival pero sin hit".
	_mostrar_pose(tipo, startup + _atk_dur_activo)

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
				# 90.10.9: resolver el contacto EN EL MISMO FRAME en que el golpe
				# entra a ACTIVO. Antes se esperaba un frame más; la separación/marcha
				# del rival podía sacar los cuerpos del rango antes del chequeo.
				if not _atk_ya_conecto:
					_chequear_impacto_ataque()
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
	# 90.11.27 — si el defensor humano está atrapado en una esquina y mantiene
	# BLOQUEO durante el hitstun del golpe anterior, permitimos que este follow-up
	# normal entre como guardia. Como `bloqueado` se calcula DESPUÉS, todo el
	# pipeline existente (daño reducido, stun reducido, recoil y corte de Combo
	# Cancel) funciona sin crear una excepción paralela.
	if objetivo.hitstun_timer > 0.0:
		objetivo.intentar_guardia_escape_esquina_preimpacto()
	var bloqueado := objetivo.bloqueando
	var empuje_final: float = (_atk_empuje_base * peso_golpe + dano * 4.0) * MULT_EMPUJE_GLOBAL
	# Transferencia de masa: un cuerpo pesado pega con más presencia y un
	# cuerpo pesado también absorbe mejor. El rango es deliberadamente corto
	# para conservar el balance que ya funciona.
	var transferencia_masa: float = clampf((_masa_corporal() * peso_golpe) / maxf(objetivo._masa_corporal(), 0.55), 0.72, 1.32)
	empuje_final *= transferencia_masa
	# El combo CORE conserva el empuje real; no lo reducimos artificialmente.
	var hitstun_final: float = _atk_hitstun * peso_golpe * lerpf(0.90, 1.08, clampf((transferencia_masa - 0.72) / 0.60, 0.0, 1.0))
	if objetivo.global_position.y < global_position.y - 25.0:
		hitstun_final *= 0.85

	# 91.02.19 — PASS 7. En un intercambio NEUTRAL de suelo el receptor vuelve
	# un poco antes a control/neutral. No se aplica a bloqueo, AIR HIT, launcher,
	# CORE ni a un segundo/tercer golpe ya encadenado: esos caminos conservan
	# exactamente el hitstun de PASS 6 para no romper secuencias aprobadas.
	var primer_impacto_normal_limpio_suelo: bool = not bloqueado \
		and not en_combo_auto_visual \
		and not en_secuencia_especial \
		and not en_fase_absoluta \
		and combo_count == 0 \
		and is_on_floor() \
		and objetivo.is_on_floor()
	if primer_impacto_normal_limpio_suelo:
		hitstun_final *= MULT_HITSTUN_PUNETAZO_NEUTRAL if _atk_tipo == "punetazo" else MULT_HITSTUN_PATADA_NEUTRAL

	# Transferencia de peso en el contacto. No escalamos el sprite: el golpe
	# se vende con avance, follow-through, hit-stop y la reacción del rival.
	var avance_contacto: float = (19.0 if _atk_tipo == "punetazo" else 28.0) * _mult_followthrough_personalidad()
	velocity.x = mirando * avance_contacto
	seguimiento_ataque_x = mirando * (3.0 if _atk_tipo == "punetazo" else 5.0) * _mult_followthrough_personalidad()
	var intensidad_contacto: float = clampf(empuje_final / 280.0, 0.65, 1.45)
	# 91.05.13 PASS 2M — durante la ráfaga automática de CORE II/III, la
	# CADENCIA usa una masa virtual de receptor igual a Magnus (1.60). Esto
	# modifica únicamente el hit-stop local del atacante: no toca la masa real,
	# el empuje, el hitstun, el daño ni la física del receptor.
	if en_combo_auto_visual:
		var empuje_base_cadencia_core: float = (_atk_empuje_base * peso_golpe + dano * 4.0) * MULT_EMPUJE_GLOBAL
		var transferencia_masa_cadencia_core: float = clampf((_masa_corporal() * peso_golpe) / 1.60, 0.72, 1.32)
		intensidad_contacto = clampf((empuje_base_cadencia_core * transferencia_masa_cadencia_core) / 280.0, 0.65, 1.45)
	# 90.10.73 — HIT FEEDBACK competitivo. Los golpes normales ya no necesitan
	# congelar el Engine completo para sentirse sólidos: el contacto se resuelve
	# con hit-stop LOCAL del Fighter. Puño = seco/rápido; patada = un poco más
	# pesada. Esto mantiene la velocidad del juego y prepara mejor el combate para
	# una futura simulación online/rollback.
	#
	# 91.02.28 — PASS 9.3D. El sistema YA existía; no se apila otro hit-stop.
	# Recalibramos únicamente el contacto limpio normal fuera de CORE/Furia:
	#   puño  ≈ 0.033–0.041 s  (~2 frames a 60 Hz)
	#   patada≈ 0.038–0.051 s  (~2–3 frames a 60 Hz)
	# Bloqueo y cualquier ruta CORE conservan literalmente la fórmula anterior.
	var impacto_normal_limpio_fuera_core: bool = not bloqueado \
		and not en_combo_auto_visual \
		and not en_secuencia_especial \
		and not en_fase_absoluta
	var pausa_contacto_base: float = 0.022 + intensidad_contacto * (0.009 if _atk_tipo == "punetazo" else 0.015)
	var pausa_contacto: float = pausa_contacto_base
	if impacto_normal_limpio_fuera_core:
		pausa_contacto = (0.026 + intensidad_contacto * 0.010) if _atk_tipo == "punetazo" \
			else (0.028 + intensidad_contacto * 0.016)
	hitstop_timer = pausa_contacto if not bloqueado else 0.014 + intensidad_contacto * 0.003
	objetivo.recibir_dano(dano, empuje_final, hitstun_final, mirando, _atk_tipo)
	# Sincronización visual del contacto NORMAL: el receptor conserva su lógica
	# propia, pero nunca sale del freeze mucho antes que el atacante. No modifica
	# hitstun ni estados de control y queda totalmente fuera de CORE.
	if impacto_normal_limpio_fuera_core:
		objetivo.hitstop_timer = maxf(objetivo.hitstop_timer, pausa_contacto * 0.92)
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
		personaje.global_position + Vector2(
			-size.x * 0.5,
			-size.y + personaje.OFFSET_VISUAL_LINEA_COMBATE_Y
		),
		size
	)

func _obtener_hitbox_ataque() -> Rect2:
	var mult_cuerpo := _mult_cuerpo_actual()
	var cuerpo_ancho := ancho_cuerpo * mult_cuerpo
	var cuerpo_alto := alto_cuerpo * mult_cuerpo
	# 90.10.12 — alcance alineado con los sprites reales. El video Fang/Kai
	# confirmó que algunas patadas largas llegan bastante más allá del cuerpo
	# físico que la caja anterior. Ampliamos sólo el frente del ataque (no la
	# hurtbox del rival) y con un margen moderado para no crear golpes fantasma.
	var alcance: float = _atk_rango + (44.0 if _atk_tipo == "patada" else 18.0)
	# Puño: torso/cabeza. Patada: cubre desde pierna baja hasta torso medio;
	# esto contempla patadas rectas, altas y descendentes de todo el roster.
	var alto_hit: float = 52.0 if _atk_tipo == "punetazo" else 76.0
	var centro_y: float = -cuerpo_alto * (0.50 if _atk_tipo == "punetazo" else 0.36)
	var ancho_hit: float = maxf(alcance - cuerpo_ancho * (0.06 if _atk_tipo == "punetazo" else 0.03), 64.0)
	# La caja nace casi desde el borde frontal del torso. En patadas largas no
	# dejamos un hueco muerto entre el cuerpo físico y la pierna dibujada.
	var avance_inicial: float = cuerpo_ancho * (0.08 if _atk_tipo == "punetazo" else 0.04)
	var izquierda: float = avance_inicial if mirando > 0.0 else -avance_inicial - ancho_hit
	return Rect2(
		global_position + Vector2(
			izquierda,
			centro_y - alto_hit * 0.5 + OFFSET_VISUAL_LINEA_COMBATE_Y
		),
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
	# 90.11.05 — dos velocidades de carga. CORE I conserva exactamente la velocidad
	# aprobada de 90.11.04. CORE II y CORE III comparten el mismo ritmo. La velocidad
	# depende del SIGUIENTE CORE que estamos construyendo.
	if veces_fase_absoluta <= 0:
		ganancia *= CORE_CARGA_NIVEL_1_MULT
	elif veces_fase_absoluta == 1:
		ganancia *= CORE_CARGA_NIVEL_2_MULT
	else:
		ganancia *= CORE_CARGA_NIVEL_3_MULT
	# 90.11.01 — COMBO x2/x3: la cadena sigue premiando presión y ejecución,
	# pero con rendimiento decreciente de CORE. Esto alarga la pelea sin tocar
	# daño, hit-stop, velocidad ni la ventana de Combo Cancel.
	if combo_count == 2:
		ganancia *= CORE_COMBO_SEGUNDO_GOLPE_MULT
	elif combo_count >= 3:
		ganancia *= CORE_COMBO_TERCER_MAS_MULT
	# Bloquear ahora sí protege también la carrera de CORE: el atacante recibe
	# solo una fracción pequeña por mantener presión, no la carga completa.
	if bloqueado:
		ganancia *= CORE_BLOQUEO_MULT
	var poder_anterior: float = poder
	poder = min(poder_maximo, poder + ganancia)
	if poder_anterior < poder_maximo and poder >= poder_maximo:
		core_listo.emit()

# 91.02.57 — PASS 12N / CORE POR PROYECTIL.
# Un proyectil que conecta LIMPIO suma la misma carga base que un puño normal.
# Bloqueado no suma nada. No depende de _atk_tipo para evitar heredar una patada
# previa y aplicar por error el +8 % de las patadas.
func _registrar_proyectil_conectado() -> void:
	combo_count += 1
	combo_timer = ventana_combo

	# Igual que los golpes normales: no recargar el siguiente CORE dentro de
	# una secuencia/cinemática CORE ya activa.
	if en_fase_absoluta or en_secuencia_especial:
		return

	var ganancia: float = clampf(
		poder_por_golpe * MULT_PODER_GLOBAL,
		CORE_GANANCIA_MIN,
		CORE_GANANCIA_MAX
	)

	if veces_fase_absoluta <= 0:
		ganancia *= CORE_CARGA_NIVEL_1_MULT
	elif veces_fase_absoluta == 1:
		ganancia *= CORE_CARGA_NIVEL_2_MULT
	else:
		ganancia *= CORE_CARGA_NIVEL_3_MULT

	# Conserva la misma curva decreciente de combo ya certificada.
	if combo_count == 2:
		ganancia *= CORE_COMBO_SEGUNDO_GOLPE_MULT
	elif combo_count >= 3:
		ganancia *= CORE_COMBO_TERCER_MAS_MULT

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
		# CORE I — PODER: mantiene su golpe/logica actual, pero ahora muestra
		# la gigantografia exclusiva del usuario cuando exista. Todo ocurre en
		# modo normal.
		_secuencia_poder_simple()
	elif veces_fase_absoluta == 2:
		# CORE II — COMBO NORMAL + REMATE: la recarga vuelve limpia. La cadena
		# usa sólo golpes normales y conserva su gigantografia final propia.
		_secuencia_combo_normal()
	else:
		# CORE III — FURIA FINAL: transformación exclusiva, combo con todo el
		# repertorio Furia disponible y gigantografía absoluta para cerrar.
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
	# 90.10.15: la coroutine del Absoluto puede terminar DESPUÉS de que Main
	# ya haya llamado mostrar_pose_victoria(). En ese caso no debe pisar
	# victoria.png con la pose normal.
	if en_pose_victoria:
		velocity = Vector2.ZERO
		return
	_actualizar_textura(_tex_parado())

# Compatibilidad: algunos lugares viejos podían llamar a esto por nombre.
func _terminar_fase_absoluta() -> void:
	_salir_furia()

# Cada personaje define su propio golpe definitivo
func _ejecutar_especial() -> void:
	pass

func _core2_construir_coreografia_actual() -> Array[Dictionary]:
	var total_punos: int = _lista_punetazo().size()
	var total_patadas: int = _lista_patada().size() if combo_auto_incluye_patada else 0

	var pasada_punos: Array[Dictionary] = []
	for i in range(total_punos):
		pasada_punos.append({"tipo": "punetazo", "indice": i})

	var pasada_patadas: Array[Dictionary] = []
	for i in range(total_patadas):
		pasada_patadas.append({"tipo": "patada", "indice": i})

	var pasada_mixta: Array[Dictionary] = _construir_pasada_completa_combo_core(
		total_punos,
		total_patadas
	)

	var coreografia: Array[Dictionary] = []
	coreografia.append_array(pasada_punos)
	coreografia.append_array(pasada_patadas)
	coreografia.append_array(pasada_mixta)
	return coreografia


func _core2_iniciar_combo_fsm() -> void:
	if veces_fase_absoluta != 2 or not en_secuencia_especial or esta_derrotado:
		return

	core2_secuencia_etapa = CORE2_ETAPA_COMBO_FSM
	core2_combo_paso_idx = 0
	core2_combo_subfase = CORE2_COMBO_SUB_PREPARAR
	core2_combo_acercamiento_origen = global_position
	core2_combo_acercamiento_destino = global_position
	core2_combo_acercamiento_duracion = 0.0
	core2_combo_acercamiento_tiempo = 0.0

	var coreografia := _core2_construir_coreografia_actual()
	core2_combo_total_pasos = coreografia.size()

	en_combo_auto_visual = true

	# Mismo inicio histórico de _racha_combo_auto().
	if objetivo and is_instance_valid(objetivo):
		objetivo.empuje_timer = 0.0
		objetivo.empuje_x = 0.0
		objetivo.empuje_pendiente_timer = 0.0
		objetivo.empuje_pendiente_fuerza = 0.0
		objetivo.velocity.x = 0.0

	indice_punetazo = 0
	indice_patada = 0

	# La coroutine histórica comenzaba el primer paso inmediatamente después
	# del fin del acercamiento inicial. Hacemos lo mismo en este physics tick.
	_core2_combo_preparar_paso_actual()


func _core2_combo_preparar_paso_actual() -> void:
	if core2_secuencia_etapa != CORE2_ETAPA_COMBO_FSM:
		return
	if veces_fase_absoluta != 2 or not en_secuencia_especial or esta_derrotado:
		_core2_combo_terminar_rafaga()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core2_combo_terminar_rafaga()
		return

	var coreografia := _core2_construir_coreografia_actual()
	core2_combo_total_pasos = coreografia.size()

	if core2_combo_paso_idx >= core2_combo_total_pasos:
		_core2_combo_terminar_rafaga()
		return

	# Si el ataque anterior aún sigue activo, esperar a su fin lógico.
	if fase_ataque != FaseAtaque.NINGUNA:
		core2_combo_subfase = CORE2_COMBO_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core2_combo_ejecutar_paso_actual(coreografia)
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core2_combo_acercamiento_origen = global_position
	core2_combo_acercamiento_destino = destino
	core2_combo_acercamiento_duracion = duracion
	core2_combo_acercamiento_tiempo = 0.0
	core2_combo_subfase = CORE2_COMBO_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core2_combo_ejecutar_paso_actual(coreografia: Array[Dictionary]) -> void:
	if core2_combo_paso_idx < 0 or core2_combo_paso_idx >= coreografia.size():
		_core2_combo_terminar_rafaga()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core2_combo_terminar_rafaga()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	var paso: Dictionary = coreografia[core2_combo_paso_idx]
	_ejecutar_paso_coreografia_combo_core(paso)

	# El viejo bucle siempre hacía un await/poll inmediatamente después de
	# lanzar el golpe y luego esperaba fase_ataque==NINGUNA. Esta subfase
	# representa exactamente esa espera, pero sin coroutine.
	core2_combo_subfase = CORE2_COMBO_SUB_ESPERAR_ATAQUE


func _actualizar_core2_combo_fsm(delta: float) -> void:
	if core2_secuencia_etapa != CORE2_ETAPA_COMBO_FSM:
		return

	if veces_fase_absoluta != 2 or not en_secuencia_especial or esta_derrotado:
		_core2_combo_terminar_rafaga()
		return

	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core2_combo_terminar_rafaga()
		return

	match core2_combo_subfase:
		CORE2_COMBO_SUB_PREPARAR:
			_core2_combo_preparar_paso_actual()

		CORE2_COMBO_SUB_ACERCAR:
			var duracion := maxf(core2_combo_acercamiento_duracion, 0.000001)
			core2_combo_acercamiento_tiempo = minf(
				core2_combo_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core2_combo_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core2_combo_acercamiento_origen.lerp(
				core2_combo_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core2_combo_acercamiento_destino
				core2_combo_acercamiento_tiempo = core2_combo_acercamiento_duracion
				var coreografia := _core2_construir_coreografia_actual()
				_core2_combo_ejecutar_paso_actual(coreografia)

		CORE2_COMBO_SUB_ESPERAR_ATAQUE:
			# _actualizar_fase_ataque(delta) corre antes que esta FSM. Cuando el
			# golpe termina, avanzamos al siguiente paso EN ESTE MISMO physics
			# tick, igual que el poll de 0.004 s del código histórico.
			if fase_ataque == FaseAtaque.NINGUNA:
				core2_combo_paso_idx += 1
				core2_combo_subfase = CORE2_COMBO_SUB_PREPARAR
				_core2_combo_preparar_paso_actual()


func _core2_combo_terminar_rafaga() -> void:
	if core2_secuencia_etapa != CORE2_ETAPA_COMBO_FSM:
		return

	indice_punetazo = 0
	indice_patada = 0
	velocity.x = 0.0
	en_combo_auto_visual = false

	core2_combo_subfase = CORE2_COMBO_SUB_PREPARAR
	core2_combo_acercamiento_duracion = 0.0
	core2_combo_acercamiento_tiempo = 0.0

	_core2_iniciar_rematador_fsm()


func _core2_iniciar_rematador_fsm() -> void:
	if veces_fase_absoluta != 2 or not en_secuencia_especial:
		return

	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core2_finalizar_secuencia()
		return

	core2_secuencia_etapa = CORE2_ETAPA_REMATADOR_FSM
	core2_rematador_subfase = CORE2_REM_SUB_POSTER
	core2_rematador_duracion = CORE2_REM_POSTER_DURACION_LOGICA
	core2_rematador_timer = core2_rematador_duracion

	var distancia: float = absf(objetivo.global_position.x - global_position.x)
	core2_rematador_puede_conectar = distancia <= maxf(rango_patada * 2.8, 360.0)
	core2_rematador_bloqueado = objetivo.bloqueando
	core2_rematador_direccion = signf(objetivo.global_position.x - global_position.x)
	if core2_rematador_direccion == 0.0:
		core2_rematador_direccion = mirando

	# Mismo comienzo lógico del rematador histórico.
	rematador_iniciado.emit()
	_congelar_rival(true)
	bloqueo_cinematico = true
	velocity = Vector2.ZERO
	_pose_final_especial(CORE2_REM_POSTER_VISIBLE + 0.25)

	if core2_rematador_puede_conectar 	and objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		objetivo.preparar_impacto_cinematico(
			1.35,
			core2_rematador_direccion,
			"rematador"
		)

	# El póster real queda como presentación pura: jamás gobierna daño/timers.
	if not rollback_suprimir_presentacion_core2:
		_mostrar_poder_reemplazando(
			textura_rematador,
			CORE2_REM_POSTER_VISIBLE,
			390.0,
			false,
			2.4,
			true
		)


func _actualizar_core2_rematador_fsm(delta: float) -> void:
	if core2_secuencia_etapa != CORE2_ETAPA_REMATADOR_FSM:
		return
	if veces_fase_absoluta != 2 or not en_secuencia_especial:
		return

	match core2_rematador_subfase:
		CORE2_REM_SUB_POSTER:
			core2_rematador_timer = maxf(0.0, core2_rematador_timer - delta)
			if core2_rematador_timer <= 0.0:
				_core2_rematador_aplicar_impacto()

		CORE2_REM_SUB_ESPERA_FINAL:
			core2_rematador_timer = maxf(0.0, core2_rematador_timer - delta)
			if core2_rematador_timer <= 0.0:
				rematador_conectado.emit()
				_core2_finalizar_secuencia()


func _core2_rematador_aplicar_impacto() -> void:
	if core2_secuencia_etapa != CORE2_ETAPA_REMATADOR_FSM:
		return
	if core2_rematador_subfase != CORE2_REM_SUB_POSTER:
		return

	core2_rematador_timer = 0.0

	# Mismo borde que H9.9 diagnosticaba, pero ahora lo produce la FSM.
	core2_rematador_poster_finalizado.emit()

	# 91.02.21 — PASS 9.1. El receptor sigue capturado en este borde.
	# El impacto/derribo entra primero y _core2_finalizar_secuencia() libera después.
	var conecta := core2_rematador_puede_conectar 		and objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado

	if conecta:
		var dano: float = dano_patada * MULT_DANO_GLOBAL * mult_dano_fase * 2.4
		objetivo.recibir_dano(
			dano,
			520.0,
			0.75,
			core2_rematador_direccion,
			"rematador"
		)
		objetivo.recibir_derribo_especial(
			core2_rematador_direccion,
			570.0 if core2_rematador_bloqueado else 1045.0,
			310.0 if core2_rematador_bloqueado else 505.0,
			0.45 if core2_rematador_bloqueado else 0.95,
			true
		)
		_efecto_chispas(core2_rematador_bloqueado, objetivo.global_position)

		core2_rematador_subfase = CORE2_REM_SUB_ESPERA_FINAL
		core2_rematador_duracion = CORE2_REM_ESPERA_FINAL
		core2_rematador_timer = CORE2_REM_ESPERA_FINAL
		return

	# Históricamente, si no conectaba no existía await 0.10.
	rematador_conectado.emit()
	_core2_finalizar_secuencia()


func _core2_finalizar_secuencia() -> void:
	_core2_liberar_encuadre_abierto_recarga()
	_limpiar_core2_flash_entrada()
	core2_flash_entrada_mostrado = false

	_congelar_rival(false)
	_desbloquear_cinematica()
	en_secuencia_especial = false

	core2_secuencia_etapa = CORE2_ETAPA_INACTIVO
	core2_recarga_timer = 0.0
	core2_recarga_duracion = 0.0
	core2_acercamiento_duracion = 0.0
	core2_acercamiento_tiempo = 0.0

	core2_combo_paso_idx = 0
	core2_combo_total_pasos = 0
	core2_combo_subfase = CORE2_COMBO_SUB_PREPARAR
	core2_combo_acercamiento_duracion = 0.0
	core2_combo_acercamiento_tiempo = 0.0

	core2_rematador_subfase = CORE2_REM_SUB_POSTER
	core2_rematador_timer = 0.0
	core2_rematador_duracion = 0.0
	core2_rematador_puede_conectar = false
	core2_rematador_bloqueado = false
	core2_rematador_direccion = 1.0



# El bucle de puños/patadas automáticos en sí (sin el remate al final).
# Lo usan tanto el remate normal como el absoluto. Corre en Fase Absoluta
# (ya la habrá activado quien llama antes de esto). Ahora que cada golpe
# tiene su propio ciclo real (startup/activo/recovery), este bucle espera
# a que el golpe anterior termine su ciclo antes de tirar el siguiente --
# si no, con un intervalo fijo la mitad de los intentos caían a mitad de
# otro golpe y se perdían en silencio.
func _construir_pasada_completa_combo_core(total_punos: int, total_patadas: int) -> Array[Dictionary]:
	var secuencia: Array[Dictionary] = []
	var punos_usados: int = 0
	var patadas_usadas: int = 0

	# Distribución proporcional, no alternancia ciega. Ejemplo Helena 10P/5K:
	# P-P-K / P-P-K / ... Esto mantiene las patadas repartidas a lo largo de
	# TODA la pasada y evita terminar con un bloque de cinco puños parecidos.
	while punos_usados < total_punos or patadas_usadas < total_patadas:
		var usar_patada: bool = false
		if punos_usados >= total_punos:
			usar_patada = true
		elif patadas_usadas >= total_patadas:
			usar_patada = false
		elif total_patadas <= 0:
			usar_patada = false
		elif total_punos <= 0:
			usar_patada = true
		elif punos_usados == 0 and patadas_usadas == 0:
			# Abrimos con puño cuando existe repertorio de puños, como el combo manual.
			usar_patada = false
		else:
			var progreso_puno_siguiente: float = float(punos_usados + 1) / float(total_punos)
			var progreso_patada_siguiente: float = float(patadas_usadas + 1) / float(total_patadas)
			# El tipo que esté más "atrasado" en su repertorio entra primero.
			# En empate privilegiamos puño para evitar K-K innecesario cuando 1:1.
			usar_patada = progreso_patada_siguiente < progreso_puno_siguiente

		if usar_patada:
			secuencia.append({"tipo": "patada", "indice": patadas_usadas})
			patadas_usadas += 1
		else:
			secuencia.append({"tipo": "punetazo", "indice": punos_usados})
			punos_usados += 1

	return secuencia

func _construir_remix_combo_core(completa: Array[Dictionary]) -> Array[Dictionary]:
	var remix: Array[Dictionary] = []
	var total: int = completa.size()
	if total <= 0:
		return remix

	# 90.11.00 — REMIX ADAPTATIVO. Helena (15 ataques normales) y Xenoid
	# (16) ya muestran TODO su repertorio en la pasada completa; repetir luego el 50%
	# hacía que CORE II se alargara más que el resto del roster. Para repertorios
	# grandes el remix baja a 30%, sin quitar ni un solo sprite de la exhibición.
	var fraccion_remix: float = FRACCION_REMIX_COMBO_CORE
	if total >= UMBRAL_REPERTORIO_GRANDE_COMBO_CORE:
		fraccion_remix = FRACCION_REMIX_COMBO_CORE_REPERTORIO_GRANDE
	var objetivo_remix: int = maxi(1, int(ceil(float(total) * fraccion_remix)))
	if total == 1:
		remix.append(completa[0].duplicate())
		return remix

	# 90.11.02 — REMIX CON IDENTIDAD DE PERSONAJE. La pasada completa siempre
	# permanece 100% intacta; sólo el remix de CORE II puede priorizar patadas.
	# CORE III no usa esta preferencia para conservar su coreografía Furia actual.
	if combo_core_remix_prioriza_patadas and not en_fase_absoluta and combo_core_remix_patadas_objetivo > 0:
		var pasos_patada: Array[Dictionary] = []
		var pasos_puno: Array[Dictionary] = []
		for paso in completa:
			if String(paso.get("tipo", "")) == "patada":
				pasos_patada.append(paso)
			else:
				pasos_puno.append(paso)

		var objetivo_patadas: int = mini(combo_core_remix_patadas_objetivo, mini(objetivo_remix, pasos_patada.size()))
		# Si existen puños y el remix tiene más de un beat, conservamos al menos uno
		# para que siga sintiéndose como combinación y no como una ráfaga mono-tipo.
		if not pasos_puno.is_empty() and objetivo_remix > 1:
			objetivo_patadas = mini(objetivo_patadas, objetivo_remix - 1)
		var objetivo_punos: int = mini(objetivo_remix - objetivo_patadas, pasos_puno.size())

		var seleccion_patadas: Array[Dictionary] = []
		if objetivo_patadas > 0:
			for i in range(objetivo_patadas):
				var pos_k: int = int(floor(float(i) * float(pasos_patada.size()) / float(objetivo_patadas)))
				pos_k = clampi(pos_k, 0, pasos_patada.size() - 1)
				seleccion_patadas.append(pasos_patada[pos_k].duplicate())

		var seleccion_punos: Array[Dictionary] = []
		if objetivo_punos > 0:
			for i in range(objetivo_punos):
				# Elegimos desde el centro hacia afuera para no volver siempre a P1/P2.
				var fraccion: float = float(i + 1) / float(objetivo_punos + 1)
				var pos_p: int = clampi(int(round(fraccion * float(pasos_puno.size() - 1))), 0, pasos_puno.size() - 1)
				seleccion_punos.append(pasos_puno[pos_p].duplicate())

		# Patrón K-P-K-K...: abre con pierna para que el cambio de lenguaje corporal
		# sea visible inmediatamente y distribuye los puños disponibles en el remix.
		var ik: int = 0
		var ip: int = 0
		while remix.size() < objetivo_remix and (ik < seleccion_patadas.size() or ip < seleccion_punos.size()):
			if ik < seleccion_patadas.size():
				remix.append(seleccion_patadas[ik])
				ik += 1
			if remix.size() >= objetivo_remix:
				break
			if ip < seleccion_punos.size():
				remix.append(seleccion_punos[ip])
				ip += 1
		# Completar con patadas restantes antes de volver al constructor genérico.
		while remix.size() < objetivo_remix and ik < seleccion_patadas.size():
			remix.append(seleccion_patadas[ik])
			ik += 1
		if remix.size() == objetivo_remix:
			return remix

	# "Zig-zag" entre el comienzo y el final del repertorio. No es volver a
	# ejecutar la primera mitad: toma poses de zonas diferentes y cambia el orden.
	# En una lista P/K alternada esto conserva mezcla; en repertorios 2:1 también
	# evita seleccionar accidentalmente sólo puños.
	var usados: Dictionary = {}
	var izquierda: int = 1 if total > 2 else 0
	var derecha: int = total - 2 if total > 2 else total - 1
	var tomar_izquierda: bool = true
	var intentos: int = 0
	var max_intentos: int = maxi(8, total * 4)

	while remix.size() < objetivo_remix and usados.size() < total and intentos < max_intentos:
		intentos += 1
		var idx: int = izquierda if tomar_izquierda else derecha
		idx = clampi(idx, 0, total - 1)
		if not usados.has(idx):
			remix.append(completa[idx].duplicate())
			usados[idx] = true

		if tomar_izquierda:
			izquierda += 2
			if izquierda >= total:
				izquierda = 0
		else:
			derecha -= 2
			if derecha < 0:
				derecha = total - 1
		tomar_izquierda = not tomar_izquierda

	# Blindaje para tamaños donde los dos cursores pudieran caer repetidamente
	# en posiciones ya usadas. Completa el 50% con huecos aún no seleccionados.
	if remix.size() < objetivo_remix:
		for idx in range(total):
			if remix.size() >= objetivo_remix:
				break
			if not usados.has(idx):
				remix.append(completa[idx].duplicate())
				usados[idx] = true

	return remix

func _ejecutar_paso_coreografia_combo_core(paso: Dictionary) -> void:
	var tipo: String = String(paso.get("tipo", ""))
	var indice: int = int(paso.get("indice", 0))
	if tipo == "patada":
		var lista_patadas: Array[Texture2D] = _lista_patada()
		if lista_patadas.is_empty():
			return
		indice_patada = clampi(indice, 0, lista_patadas.size() - 1)
		intentar_patada()
	else:
		var lista_punos: Array[Texture2D] = _lista_punetazo()
		if lista_punos.is_empty():
			return
		indice_punetazo = clampi(indice, 0, lista_punos.size() - 1)
		intentar_punetazo()

# El bucle de puños/patadas automáticos en sí (sin el remate al final).
# 90.11.08 — COREOGRAFÍA TRIFÁSICA:
#   A) RÁFAGA DE PUÑOS: todos los puños disponibles, en orden;
#   B) RÁFAGA DE PATADAS: todas las patadas disponibles, en orden;
#   C) MIXTA: repertorio completo de puños/patadas intercalado;
#   D) remate/Absoluto único.
# Se aplica únicamente al combo automático de CORE II/III. No altera Versus Local,
# Combo Cancel manual, timings normales, daño, hitstun ni knockback.
# La cadencia uniforme 90.10.98 y el receptor anclado 90.10.97 se conservan.
func _racha_combo_auto() -> void:
	en_combo_auto_visual = true
	# Arrancar la ráfaga sin inercia heredada. Hasta el remate el receptor
	# conserva su posición horizontal entre impactos.
	if objetivo and is_instance_valid(objetivo):
		objetivo.empuje_timer = 0.0
		objetivo.empuje_x = 0.0
		objetivo.empuje_pendiente_timer = 0.0
		objetivo.empuje_pendiente_fuerza = 0.0
		objetivo.velocity.x = 0.0

	indice_punetazo = 0
	indice_patada = 0
	var total_punos: int = _lista_punetazo().size()
	var total_patadas: int = _lista_patada().size() if combo_auto_incluye_patada else 0

	# 90.11.08 — tres actos claramente distintos. La tercera pasada reutiliza el
	# constructor proporcional ya validado para mantener mezclados repertorios 2:1
	# (por ejemplo 10 puños / 5 patadas) sin esconder ningún sprite.
	var pasada_punos: Array[Dictionary] = []
	for i in range(total_punos):
		pasada_punos.append({"tipo": "punetazo", "indice": i})

	var pasada_patadas: Array[Dictionary] = []
	for i in range(total_patadas):
		pasada_patadas.append({"tipo": "patada", "indice": i})

	var pasada_mixta: Array[Dictionary] = _construir_pasada_completa_combo_core(total_punos, total_patadas)
	var coreografia: Array[Dictionary] = []
	coreografia.append_array(pasada_punos)
	coreografia.append_array(pasada_patadas)
	coreografia.append_array(pasada_mixta)

	for paso in coreografia:
		if esta_derrotado:
			break
		if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
			break

		# Cada beat espera únicamente el fin lógico del anterior. Todos los tipos
		# comparten el timing uniforme 90.10.98: no existe pausa por cooldown de patada.
		while fase_ataque != FaseAtaque.NINGUNA and not esta_derrotado:
			await get_tree().create_timer(POLL_COMBO_CORE_CONTINUO, true, false, true).timeout
		if esta_derrotado:
			break

		await _acercar_para_combo_auto()
		if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
			break

		var distancia: float = objetivo.global_position.x - global_position.x
		if absf(distancia) > 1.0:
			mirando = signf(distancia)
		_ejecutar_paso_coreografia_combo_core(paso)
		await get_tree().create_timer(POLL_COMBO_CORE_CONTINUO, true, false, true).timeout

	while fase_ataque != FaseAtaque.NINGUNA and not esta_derrotado:
		await get_tree().create_timer(POLL_COMBO_CORE_CONTINUO, true, false, true).timeout

	# Mantener el estado manual predecible: históricamente las dos vueltas
	# completas devolvían ambos índices a cero por wrap.
	indice_punetazo = 0
	indice_patada = 0
	velocity.x = 0.0
	# Liberar el combo cage ANTES del remate: CORE II/III recupera knockback normal.
	en_combo_auto_visual = false

func _acercar_para_combo_auto() -> void:
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return

	# 90.10.46 — TARGET LOCK 2D. El rival puede estar en el piso mientras el
	# atacante activa CORE desde salto/doble salto (o al revés). Por eso ya no
	# basta con cerrar la distancia horizontal: alineamos también la altura del
	# cuerpo antes de permitir que empiece el siguiente golpe del combo.
	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	# 90.10.71 — el acercamiento usa el mismo target que el pushbox. En 90.10.70
	# el tween siempre intentaba volver a 82 px aunque el cuerpo visual necesitara
	# más espacio, generando la penetración residual que vimos en Kali/Aethel.
	var distancia_combo_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)
	if distancia_x <= distancia_combo_objetivo \
		and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		return

	var lado: float = signf(dx)
	# Si estamos prácticamente encima/debajo del rival, conservar el lado de
	# combate actual evita un giro indeterminado y nos deja a distancia segura.
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_combo_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	# Un trayecto vertical grande (doble salto) necesita unas décimas más que
	# el viejo dash horizontal para verse dirigido, pero sigue siendo muy rápido.
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", destino, duracion)
	await tween.finished
	velocity = Vector2.ZERO

func _congelar_rival(activo: bool) -> void:
	if objetivo and is_instance_valid(objetivo):
		objetivo.congelado_por_rival = activo

		if activo:
			# 91.02.21 — PASS 9.1. Al quedar capturado por un CORE se cancela
			# únicamente una acción manual que ya hubiera arrancado antes del lock.
			# No se toca hitstun, gravedad, knockback, derribo ni estado rollback.
			objetivo._detener_carrera()
			objetivo._detener_dash_aereo()
			objetivo.velocity.x = 0.0
			objetivo.fase_ataque = FaseAtaque.NINGUNA
			objetivo.timer_fase_ataque = 0.0
			objetivo._atk_ya_conecto = false
			objetivo.ataque_buffer_tipo = ""
			objetivo.ataque_buffer_timer = 0.0
			return

		# Al liberar VS Local absorbemos el estado ACTUAL de los botones
		# enrutados. Así una tecla mantenida durante el CORE no nace como
		# "just pressed" en el primer frame libre.
		if objetivo.fuente_control == FuenteControl.EXTERNA:
			var frame_liberacion: Dictionary = objetivo.input_frame_externo \
				if objetivo.input_externo_disponible else objetivo.input_frame_enrutado_actual
			objetivo.puno_estaba_presionado = bool(frame_liberacion.get("puno", false))
			objetivo.patada_estaba_presionada = bool(frame_liberacion.get("patada", false))
			objetivo.salto_estaba_presionado = bool(frame_liberacion.get("salto", false))
			objetivo.gamepad_salto_previo = objetivo.salto_estaba_presionado
			objetivo.z_estaba_presionado = bool(frame_liberacion.get("especial", false))
			objetivo.tecla_izq_previa = bool(frame_liberacion.get("izquierda", false))
			objetivo.tecla_der_previa = bool(frame_liberacion.get("derecha", false))
			objetivo.doble_pulso_izq_timer = 0.0
			objetivo.doble_pulso_der_timer = 0.0
			objetivo.ataque_buffer_tipo = ""
			objetivo.ataque_buffer_timer = 0.0

		if not objetivo.esta_derrotado \
			and not objetivo.derribo_especial_activo and objetivo.pose_timer <= 0.0:
			objetivo._actualizar_textura(objetivo._tex_reposo())

# 91.02.32 — PASS 9.4C / ENCUADRE ABIERTO CORE II.
# Main recibe recarga_iniciada(false) y su presentación histórica intenta un
# punch-in 1.18. Inmediatamente después de emitir la señal, CORE II cancela
# ÚNICAMENTE ese tween visual y sostiene un encuadre abierto durante la recarga.
# No se usa en CORE III.
func _core2_controlador_camara() -> Node:
	var candidato: Node = get_parent()
	if candidato and candidato.has_method("_zoom_dramatico"):
		return candidato
	var escena := get_tree().current_scene
	if escena and escena.has_method("_zoom_dramatico"):
		return escena
	return null


func _core2_cancelar_tween_camara_recarga() -> void:
	var controlador := _core2_controlador_camara()
	if not controlador:
		return
	var tw_variant = controlador.get("tween_camara_cinematica")
	if tw_variant is Tween and is_instance_valid(tw_variant):
		(tw_variant as Tween).kill()
	controlador.set("tween_camara_cinematica", null)


func _core2_calcular_encuadre_abierto() -> Dictionary:
	var cam := get_viewport().get_camera_2d()
	if not cam:
		return {}

	var viewport_size := get_viewport_rect().size
	if viewport_size.y <= 1.0:
		viewport_size = Vector2(1280.0, 720.0)

	# Replicamos la altura visual que usa la gigantografía dedicada.
	var mult_altura: float = float(PODER_CINEMA_ALTURA_MULT.get(nombre_luchador, 1.0))
	var alto_poster: float = CORE2_FLASH_ALTO * mult_altura
	var elevacion: float = CORE2_CAM_ELEVACION_POSTER
	if nombre_luchador == "Jester":
		elevacion += 12.0
	elif nombre_luchador == "Varkhos":
		elevacion += 20.0
	elif nombre_luchador == "Magnus":
		elevacion += 10.0

	# El límite superior representa la cabeza/efecto superior del póster.
	var y_superior: float = global_position.y - elevacion - alto_poster - CORE2_CAM_MARGEN_VERTICAL
	var y_inferior: float = global_position.y + CORE2_CAM_MARGEN_CUERPO_INFERIOR
	if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		y_inferior = maxf(
			y_inferior,
			objetivo.global_position.y + CORE2_CAM_MARGEN_CUERPO_INFERIOR
		)

	var alto_necesario: float = maxf(1.0, y_inferior - y_superior + CORE2_CAM_MARGEN_VERTICAL)
	var zoom_fit: float = viewport_size.y / alto_necesario
	var zoom_objetivo: float = clampf(zoom_fit, CORE2_CAM_ZOOM_MIN, CORE2_CAM_ZOOM_MAX)

	# Horizontalmente priorizamos el par de luchadores y sesgamos muy levemente
	# hacia la espalda del atacante, donde vive la gigantografía de entrada.
	var centro_x: float = global_position.x
	if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		centro_x = (global_position.x + objetivo.global_position.x) * 0.5
	var sesgo_poster_x: float = -mirando * CORE2_CAM_SEPARACION_POSTER_X * 0.32
	centro_x += sesgo_poster_x

	var centro_y: float = (y_superior + y_inferior) * 0.5
	return {
		"camara": cam,
		"centro": Vector2(centro_x, centro_y),
		"zoom": zoom_objetivo,
	}


func _core2_aplicar_encuadre_abierto_recarga() -> void:
	if rollback_suprimir_presentacion_core2:
		return
	var datos := _core2_calcular_encuadre_abierto()
	if datos.is_empty():
		return

	var controlador := _core2_controlador_camara()
	if controlador:
		# Evita que la cámara dinámica o el viejo tween de recarga peleen contra
		# este encuadre durante los 1.05 s. Es una bandera visual de Main.
		controlador.set("camara_cinematica_activa", true)

	var cam: Camera2D = datos.get("camara", null)
	if not cam:
		return
	var centro: Vector2 = datos.get("centro", cam.global_position)
	var zoom_objetivo: float = float(datos.get("zoom", 1.0))

	cam.global_position = centro
	cam.zoom = Vector2(zoom_objetivo, zoom_objetivo)
	core2_encuadre_abierto_activo = true


func _core2_liberar_encuadre_abierto_recarga() -> void:
	if not core2_encuadre_abierto_activo:
		return
	core2_encuadre_abierto_activo = false

	var controlador := _core2_controlador_camara()
	if controlador:
		# La cámara normal recupera el control de forma natural desde el zoom
		# abierto actual; no forzamos ningún salto de zoom al salir.
		controlador.set("camara_cinematica_activa", false)


# 91.02.30 — PASS 9.4A / FLASH DE ENTRADA CORE II.
# Usa la gigantografía del rematador como "presagio" visual: menor escala,
# semitransparente y detrás del luchador. El remate final sigue usando su póster
# grande original. Esta función no contiene await ni modifica ningún estado lógico.
func _limpiar_core2_flash_entrada() -> void:
	if core2_flash_entrada_tween and is_instance_valid(core2_flash_entrada_tween):
		core2_flash_entrada_tween.kill()
	core2_flash_entrada_tween = null

	if core2_flash_entrada_layer and is_instance_valid(core2_flash_entrada_layer):
		core2_flash_entrada_layer.queue_free()
	if core2_flash_entrada_sprite and is_instance_valid(core2_flash_entrada_sprite):
		core2_flash_entrada_sprite.queue_free()

	core2_flash_entrada_sprite = null
	core2_flash_entrada_layer = null


func _actualizar_core2_flash_entrada_worldsafe() -> void:
	if not core2_flash_entrada_sprite or not is_instance_valid(core2_flash_entrada_sprite):
		return

	var tex_flash: Texture2D = core2_flash_entrada_sprite.texture
	if not tex_flash:
		return

	var rect_visible: Rect2 = _obtener_rect_visual(tex_flash)
	if rect_visible.size.x <= 1.0 or rect_visible.size.y <= 1.0:
		rect_visible = Rect2(
			0.0,
			0.0,
			float(tex_flash.get_width()),
			float(tex_flash.get_height())
		)

	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 1.0 or viewport_size.y <= 1.0:
		viewport_size = Vector2(1280.0, 720.0)

	# Conserva la presencia grande de 9.4B/9.4D, pero con FIT real al safe-area.
	var mult_altura: float = float(PODER_CINEMA_ALTURA_MULT.get(nombre_luchador, 1.0))
	var escala_por_altura: float = (CORE2_FLASH_ALTO * mult_altura) / maxf(rect_visible.size.y, 1.0)
	var ancho_maximo: float = viewport_size.x * CORE2_FLASH_SAFE_ANCHO_MAX_FRAC
	var alto_maximo: float = viewport_size.y * CORE2_FLASH_SAFE_ALTO_MAX_FRAC
	var escala_fit_x: float = ancho_maximo / maxf(rect_visible.size.x, 1.0)
	var escala_fit_y: float = alto_maximo / maxf(rect_visible.size.y, 1.0)
	var esc_pantalla: float = minf(escala_por_altura, minf(escala_fit_x, escala_fit_y))

	var centro_visible_tex := Vector2(
		rect_visible.position.x + rect_visible.size.x * 0.5,
		rect_visible.position.y + rect_visible.size.y * 0.5
	)
	var centro_textura := Vector2(
		float(tex_flash.get_width()) * 0.5,
		float(tex_flash.get_height()) * 0.5
	)
	var offset_centro_visible_px: Vector2 = (centro_visible_tex - centro_textura) * esc_pantalla
	if core2_flash_entrada_sprite.flip_h:
		offset_centro_visible_px.x *= -1.0

	var centro_x_deseado: float = viewport_size.x * (
		CORE2_FLASH_CENTRO_LADO_IZQ_FRAC if mirando >= 0.0
		else CORE2_FLASH_CENTRO_LADO_DER_FRAC
	)
	var centro_y_deseado: float = viewport_size.y * CORE2_FLASH_CENTRO_Y_FRAC

	var medio_ancho_visible: float = rect_visible.size.x * esc_pantalla * 0.5
	var medio_alto_visible: float = rect_visible.size.y * esc_pantalla * 0.5
	var margen_x: float = viewport_size.x * CORE2_FLASH_SAFE_MARGEN_X_FRAC
	var safe_top: float = viewport_size.y * CORE2_FLASH_SAFE_TOP_FRAC
	var safe_bottom: float = viewport_size.y * (1.0 - CORE2_FLASH_SAFE_BOTTOM_FRAC)

	var centro_x_seguro: float = clampf(
		centro_x_deseado,
		margen_x + medio_ancho_visible,
		viewport_size.x - margen_x - medio_ancho_visible
	)
	var centro_y_seguro: float = clampf(
		centro_y_deseado,
		safe_top + medio_alto_visible,
		safe_bottom - medio_alto_visible
	)

	var cam := get_viewport().get_camera_2d()
	if not cam:
		# Fallback robusto si la cámara aún no existe.
		core2_flash_entrada_sprite.position = Vector2(centro_x_seguro, centro_y_seguro) - offset_centro_visible_px
		core2_flash_entrada_sprite.scale = Vector2(esc_pantalla, esc_pantalla)
		return

	# 91.02.34 — convertir la composición screen-safe a coordenadas del mundo.
	# Como el sprite vive detrás de los luchadores, el personaje real queda
	# siempre por delante aun en doble salto o esquina.
	var zoom := cam.zoom
	var zoom_x := maxf(zoom.x, 0.0001)
	var zoom_y := maxf(zoom.y, 0.0001)
	var top_left_world := cam.get_screen_center_position() - Vector2(viewport_size.x * 0.5 / zoom_x, viewport_size.y * 0.5 / zoom_y)
	var centro_world := top_left_world + Vector2(centro_x_seguro / zoom_x, centro_y_seguro / zoom_y)
	var offset_world := Vector2(offset_centro_visible_px.x / zoom_x, offset_centro_visible_px.y / zoom_y)
	var esc_world := Vector2(esc_pantalla / zoom_x, esc_pantalla / zoom_y)

	core2_flash_entrada_sprite.position = centro_world - offset_world
	core2_flash_entrada_sprite.scale = esc_world


func _mostrar_core2_flash_entrada() -> void:
	if not CORE2_FLASH_ENTRADA_ACTIVA:
		core2_flash_entrada_mostrado = true
		return
	if core2_flash_entrada_mostrado:
		return

	# Marcamos el beat aunque el catch-up suprima presentación; así jamás se
	# reproduce tarde o duplicado al volver de una re-simulación.
	core2_flash_entrada_mostrado = true
	if rollback_suprimir_presentacion_core2:
		return
	if not sprite:
		return

	var tex_flash: Texture2D = textura_core2_entrada
	if not tex_flash:
		tex_flash = textura_rematador if textura_rematador else textura_especial
	if not tex_flash:
		return

	_limpiar_core2_flash_entrada()

	# 91.02.34 — SCREEN-SAFE + DETRÁS DEL LUCHADOR.
	# El arte vuelve al mundo 2D, pero su composición sigue derivándose de la
	# cámara. Ya no queda por delante del personaje ni tapa la recarga.
	var img := Sprite2D.new()
	img.texture = tex_flash
	img.centered = true
	img.flip_h = mirando < 0.0
	img.top_level = true
	img.z_as_relative = false
	img.z_index = CORE2_FLASH_WORLD_Z
	img.show_behind_parent = false

	var escena_actual := get_tree().current_scene
	if not escena_actual:
		return
	escena_actual.add_child(img)
	core2_flash_entrada_sprite = img
	core2_flash_entrada_layer = null

	_actualizar_core2_flash_entrada_worldsafe()

	var alpha_objetivo: float = minf(
		0.92,
		0.90 * float(PODER_CINEMA_ALPHA_MULT.get(nombre_luchador, 1.0))
	)
	img.modulate = Color(1.0, 1.0, 1.0, 0.0)

	core2_flash_entrada_tween = create_tween()
	core2_flash_entrada_tween.tween_property(
		img,
		"modulate",
		Color(1.0, 1.0, 1.0, alpha_objetivo),
		CORE2_FLASH_FADE_IN
	)
	core2_flash_entrada_tween.tween_interval(CORE2_FLASH_HOLD)
	core2_flash_entrada_tween.tween_property(
		img,
		"modulate",
		Color(1.0, 1.0, 1.0, 0.0),
		CORE2_FLASH_FADE_OUT
	)
	core2_flash_entrada_tween.tween_callback(Callable(img, "queue_free"))

func _core2_iniciar_recarga_logica() -> void:
	_limpiar_core2_flash_entrada()
	core2_flash_entrada_mostrado = false

	core2_secuencia_etapa = CORE2_ETAPA_RECARGA
	core2_recarga_duracion = CORE2_RECARGA_DURACION
	# El updater corre también en el tick de activación; compensamos un delta
	# para que la duración efectiva siga siendo 1.05 s.
	core2_recarga_timer = core2_recarga_duracion + maxf(_delta_actual, 0.0)

	en_pose_recarga = true
	velocity = Vector2.ZERO
	pose_timer = CORE2_RECARGA_DURACION + 0.08

	if textura_recarga and sprite:
		_actualizar_textura(textura_recarga)
		sprite.rotation = 0.0
		sprite.position.x = _sprite_ancla_x()
		recarga_iniciada.emit(false)

		# 91.02.32 — la señal anterior dispara sonido/oscurecimiento histórico
		# en Main y también su antiguo zoom 1.18. Conservamos audio/escenario,
		# cancelamos sólo ese tween de cámara y abrimos el encuadre CORE II.
		_core2_cancelar_tween_camara_recarga()
		_core2_aplicar_encuadre_abierto_recarga()

		# Misma pulsación visual histórica. No gobierna lógica.
		if core2_recarga_brillo and is_instance_valid(core2_recarga_brillo):
			core2_recarga_brillo.kill()
		core2_recarga_brillo = create_tween()
		core2_recarga_brillo.set_loops(4)
		core2_recarga_brillo.tween_property(sprite, "modulate", Color(1.48, 1.48, 1.48, 1.0), 0.14)
		core2_recarga_brillo.tween_property(sprite, "modulate", Color(1.08, 1.08, 1.08, 1.0), 0.14)


func _core2_finalizar_recarga_logica() -> void:
	_core2_liberar_encuadre_abierto_recarga()
	en_pose_recarga = false
	core2_recarga_timer = 0.0

	if core2_recarga_brillo and is_instance_valid(core2_recarga_brillo):
		core2_recarga_brillo.kill()
	core2_recarga_brillo = null
	if sprite:
		sprite.modulate = Color.WHITE

	_core2_iniciar_acercamiento_inicial()


func _core2_iniciar_acercamiento_inicial() -> void:
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core2_iniciar_combo_fsm()
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_combo_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_combo_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		core2_acercamiento_origen = global_position
		core2_acercamiento_destino = global_position
		core2_acercamiento_duracion = 0.0
		core2_acercamiento_tiempo = 0.0
		_core2_iniciar_combo_fsm()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_combo_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core2_secuencia_etapa = CORE2_ETAPA_ACERCAMIENTO
	core2_acercamiento_origen = global_position
	core2_acercamiento_destino = destino
	core2_acercamiento_duracion = duracion
	core2_acercamiento_tiempo = 0.0
	velocity = Vector2.ZERO


func _actualizar_core2_fsm(delta: float) -> void:
	if core2_secuencia_etapa == CORE2_ETAPA_INACTIVO:
		return

	if veces_fase_absoluta != 2 or not en_secuencia_especial:
		_core2_liberar_encuadre_abierto_recarga()
		core2_secuencia_etapa = CORE2_ETAPA_INACTIVO
		core2_recarga_timer = 0.0
		core2_recarga_duracion = 0.0
		core2_acercamiento_duracion = 0.0
		core2_acercamiento_tiempo = 0.0
		core2_combo_paso_idx = 0
		core2_combo_total_pasos = 0
		core2_combo_subfase = CORE2_COMBO_SUB_PREPARAR
		core2_combo_acercamiento_duracion = 0.0
		core2_combo_acercamiento_tiempo = 0.0
		core2_rematador_subfase = CORE2_REM_SUB_POSTER
		core2_rematador_timer = 0.0
		core2_rematador_duracion = 0.0
		core2_rematador_puede_conectar = false
		core2_rematador_bloqueado = false
		core2_rematador_direccion = 1.0
		return

	match core2_secuencia_etapa:
		CORE2_ETAPA_RECARGA:
			core2_recarga_timer = maxf(0.0, core2_recarga_timer - delta)

			# 91.02.32 — mantener el encuadre completo durante toda la recarga,
			# especialmente cuando CORE II nace desde salto/doble salto.
			_core2_aplicar_encuadre_abierto_recarga()
			# 91.02.34 — si la cámara ajusta levemente durante la recarga,
			# recomponemos el arte screen-safe en el mundo detrás del luchador.
			_actualizar_core2_flash_entrada_worldsafe()

			# 91.02.30 / 91.02.35 — la llamada queda neutralizada cuando la entrada
			# exclusiva de CORE II esta desactivada, dejando la recarga limpia.
			# No altera core2_recarga_timer ni el instante de entrada al combo.
			if not core2_flash_entrada_mostrado 			and core2_recarga_timer <= CORE2_FLASH_ENTRADA_UMBRAL 			and core2_recarga_timer > 0.0:
				_mostrar_core2_flash_entrada()

			if core2_recarga_timer <= 0.0:
				_core2_finalizar_recarga_logica()

		CORE2_ETAPA_ACERCAMIENTO:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				velocity = Vector2.ZERO
				_core2_iniciar_combo_fsm()
				return

			var duracion := maxf(core2_acercamiento_duracion, 0.000001)
			core2_acercamiento_tiempo = minf(core2_acercamiento_tiempo + delta, duracion)
			var t := clampf(core2_acercamiento_tiempo / duracion, 0.0, 1.0)

			# Tween.TRANS_QUAD + EASE_OUT.
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core2_acercamiento_origen.lerp(core2_acercamiento_destino, eased)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core2_acercamiento_destino
				velocity = Vector2.ZERO
				_core2_iniciar_combo_fsm()


		CORE2_ETAPA_COMBO_FSM:
			_actualizar_core2_combo_fsm(delta)

		CORE2_ETAPA_REMATADOR_FSM:
			velocity = Vector2.ZERO
			_actualizar_core2_rematador_fsm(delta)



# H10.10 — CORE III determinista: sólo la recarga lenta y el primer Target Lock.
# La ráfaga/finalización posterior sigue siendo la implementación histórica y será
# certificada en fronteras siguientes.
func _core3_iniciar_recarga_logica() -> void:
	core3_secuencia_etapa = CORE3_ETAPA_RECARGA
	core3_recarga_duracion = CORE3_RECARGA_DURACION
	# _actualizar_core3_fsm corre también en el tick de activación. Sumamos ese
	# primer paso para que la duración efectiva siga siendo exactamente 1.55 s.
	core3_recarga_timer = core3_recarga_duracion + maxf(_delta_actual, 0.0)
	core3_recarga_primer_tick = true

	en_pose_recarga = true
	velocity = Vector2.ZERO
	pose_timer = CORE3_RECARGA_DURACION + 0.08

	if textura_recarga and sprite:
		_actualizar_textura(textura_recarga)
		sprite.rotation = 0.0
		sprite.position.x = _sprite_ancla_x()
		recarga_iniciada.emit(true)

		# Pulsación visual histórica. Si un rollback de ENTRY vuelve a pasar por
		# aquí, matar la instancia previa evita Tweens visuales duplicados.
		if core3_recarga_brillo and is_instance_valid(core3_recarga_brillo):
			core3_recarga_brillo.kill()
		core3_recarga_brillo = create_tween()
		core3_recarga_brillo.set_loops(5)
		core3_recarga_brillo.tween_property(sprite, "modulate", Color(1.48, 1.48, 1.48, 1.0), 0.14)
		core3_recarga_brillo.tween_property(sprite, "modulate", Color(1.08, 1.08, 1.08, 1.0), 0.14)


func _core3_finalizar_recarga_logica() -> void:
	core3_recarga_timer = 0.0
	core3_recarga_primer_tick = false
	en_pose_recarga = false

	if core3_recarga_brillo and is_instance_valid(core3_recarga_brillo):
		core3_recarga_brillo.kill()
	core3_recarga_brillo = null
	if sprite:
		sprite.modulate = Color.WHITE

	# H10.10: el fin lógico de CORE III es ahora la única autoridad que devuelve
	# la simulación a velocidad normal. Main conserva sólo presentación/cámara.
	if not get_tree().paused:
		Engine.time_scale = 1.0

	_entrar_furia()
	_core3_iniciar_acercamiento_inicial()


func _core3_iniciar_acercamiento_inicial() -> void:
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_iniciar_primer_beat_fsm()
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_combo_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_combo_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		core3_acercamiento_origen = global_position
		core3_acercamiento_destino = global_position
		core3_acercamiento_duracion = 0.0
		core3_acercamiento_tiempo = 0.0
		_core3_iniciar_primer_beat_fsm()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_combo_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_secuencia_etapa = CORE3_ETAPA_ACERCAMIENTO
	core3_acercamiento_origen = global_position
	core3_acercamiento_destino = destino
	core3_acercamiento_duracion = duracion
	core3_acercamiento_tiempo = 0.0
	velocity = Vector2.ZERO


func _actualizar_core3_fsm(delta: float) -> void:
	if core3_secuencia_etapa == CORE3_ETAPA_INACTIVO:
		return

	if veces_fase_absoluta < 3 or not en_secuencia_especial:
		core3_secuencia_etapa = CORE3_ETAPA_INACTIVO
		core3_recarga_timer = 0.0
		core3_recarga_duracion = 0.0
		core3_recarga_primer_tick = false
		core3_acercamiento_duracion = 0.0
		core3_acercamiento_tiempo = 0.0
		core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
		core3_primer_beat_acercamiento_origen = Vector2.ZERO
		core3_primer_beat_acercamiento_destino = Vector2.ZERO
		core3_primer_beat_acercamiento_duracion = 0.0
		core3_primer_beat_acercamiento_tiempo = 0.0
		return

	match core3_secuencia_etapa:
		CORE3_ETAPA_RECARGA:
			var paso_no_escalado: float
			if core3_recarga_primer_tick:
				# El frame de activación nació a time_scale=1.0 aunque la señal lo
				# cambie a 0.32 dentro del mismo callback. No dividir este delta.
				paso_no_escalado = delta
				core3_recarga_primer_tick = false
			else:
				var escala := maxf(Engine.time_scale, 0.000001)
				paso_no_escalado = delta / escala
			core3_recarga_timer = maxf(0.0, core3_recarga_timer - paso_no_escalado)
			if core3_recarga_timer <= 0.0:
				_core3_finalizar_recarga_logica()

		CORE3_ETAPA_ACERCAMIENTO:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				velocity = Vector2.ZERO
				_core3_iniciar_primer_beat_fsm()
				return

			var duracion := maxf(core3_acercamiento_duracion, 0.000001)
			core3_acercamiento_tiempo = minf(core3_acercamiento_tiempo + delta, duracion)
			var t := clampf(core3_acercamiento_tiempo / duracion, 0.0, 1.0)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_acercamiento_origen.lerp(core3_acercamiento_destino, eased)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_acercamiento_destino
				velocity = Vector2.ZERO
				_core3_iniciar_primer_beat_fsm()

		CORE3_ETAPA_PRIMER_BEAT_FSM:
			_actualizar_core3_primer_beat_fsm(delta)

		CORE3_ETAPA_SEGUNDO_BEAT_FSM:
			_actualizar_core3_segundo_beat_fsm(delta)

		CORE3_ETAPA_TERCER_BEAT_FSM:
			_actualizar_core3_tercer_beat_fsm(delta)

		CORE3_ETAPA_CUARTO_BEAT_FSM:
			_actualizar_core3_cuarto_beat_fsm(delta)

		CORE3_ETAPA_QUINTO_BEAT_FSM:
			_actualizar_core3_quinto_beat_fsm(delta)

		CORE3_ETAPA_SEXTO_BEAT_FSM:
			_actualizar_core3_sexto_beat_fsm(delta)

		CORE3_ETAPA_SEPTIMO_BEAT_FSM:
			_actualizar_core3_septimo_beat_fsm(delta)

		CORE3_ETAPA_OCTAVO_BEAT_FSM:
			_actualizar_core3_octavo_beat_fsm(delta)

		CORE3_ETAPA_NOVENO_BEAT_FSM:
			_actualizar_core3_noveno_beat_fsm(delta)

		CORE3_ETAPA_DECIMO_BEAT_FSM:
			_actualizar_core3_decimo_beat_fsm(delta)

		CORE3_ETAPA_UNDECIMO_BEAT_FSM:
			_actualizar_core3_undecimo_beat_fsm(delta)

		CORE3_ETAPA_DUODECIMO_BEAT_FSM:
			_actualizar_core3_duodecimo_beat_fsm(delta)

		CORE3_ETAPA_DECIMOTERCER_BEAT_FSM:
			_actualizar_core3_decimotercer_beat_fsm(delta)

		CORE3_ETAPA_DECIMOCUARTO_BEAT_FSM:
			_actualizar_core3_decimocuarto_beat_fsm(delta)

		CORE3_ETAPA_DECIMOQUINTO_BEAT_FSM:
			_actualizar_core3_decimoquinto_beat_fsm(delta)

		CORE3_ETAPA_DECIMOSEXTO_BEAT_FSM:
			_actualizar_core3_decimosexto_beat_fsm(delta)

		CORE3_ETAPA_DECIMOSEPTIMO_BEAT_FSM:
			_actualizar_core3_decimoseptimo_beat_fsm(delta)

		CORE3_ETAPA_DECIMOCTAVO_BEAT_FSM:
			_actualizar_core3_decimoctavo_beat_fsm(delta)


func _core3_iniciar_primer_beat_fsm() -> void:
	# H10.13 — la frontera stage 2->3 ya no crea un Tween/coroutine de futuro.
	# Sólo reproducimos el primer beat de la misma coreografía histórica.
	core3_secuencia_etapa = CORE3_ETAPA_PRIMER_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0

	en_combo_auto_visual = true
	if objetivo and is_instance_valid(objetivo):
		objetivo.empuje_timer = 0.0
		objetivo.empuje_x = 0.0
		objetivo.empuje_pendiente_timer = 0.0
		objetivo.empuje_pendiente_fuerza = 0.0
		objetivo.velocity.x = 0.0

	indice_punetazo = 0
	indice_patada = 0
	_core3_primer_beat_preparar()


func _core3_primer_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_PRIMER_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_primer_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_primer_beat_terminar_y_continuar()
		return

	# El primer paso de _racha_combo_auto() siempre es coreografia[0].
	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_primer_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_primer_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.is_empty():
		_core3_primer_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_primer_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[0])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_primer_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_PRIMER_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_primer_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_primer_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_primer_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			# La coroutine histórica no inicia el segundo paso hasta que el primer
			# ataque termina lógicamente. Al llegar aquí entregamos el resto.
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_primer_beat_terminar_y_continuar()


func _core3_primer_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_PRIMER_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_segundo_beat_fsm()


func _core3_iniciar_segundo_beat_fsm() -> void:
	# H10.15 — stage 3->4 ya no entrega a una coroutine. El segundo beat usa
	# exactamente los mismos campos físicos/snapshotables del beat anterior.
	core3_secuencia_etapa = CORE3_ETAPA_SEGUNDO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_segundo_beat_preparar()


func _core3_segundo_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_SEGUNDO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_segundo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_segundo_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 1:
		_core3_segundo_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_segundo_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_segundo_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 1:
		_core3_segundo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_segundo_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[1])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_segundo_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_SEGUNDO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_segundo_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_segundo_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_segundo_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_segundo_beat_terminar_y_continuar()


func _core3_segundo_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_SEGUNDO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_tercer_beat_fsm()


func _core3_iniciar_tercer_beat_fsm() -> void:
	# H10.17 — stage 4->5 tampoco entrega a una coroutine. El tercer beat
	# reutiliza los mismos campos físicos/snapshotables de los beats 1 y 2.
	core3_secuencia_etapa = CORE3_ETAPA_TERCER_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_tercer_beat_preparar()


func _core3_tercer_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_TERCER_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_tercer_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_tercer_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 2:
		_core3_tercer_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_tercer_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_tercer_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 2:
		_core3_tercer_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_tercer_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[2])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_tercer_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_TERCER_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_tercer_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_tercer_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_tercer_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_tercer_beat_terminar_y_continuar()


func _core3_tercer_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_TERCER_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_cuarto_beat_fsm()


func _core3_iniciar_cuarto_beat_fsm() -> void:
	# H10.20 — stage 5->6 tampoco entrega a la coroutine histórica. El cuarto
	# beat reutiliza los campos físicos/snapshotables de los beats anteriores.
	core3_secuencia_etapa = CORE3_ETAPA_CUARTO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_cuarto_beat_preparar()


func _core3_cuarto_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_CUARTO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_cuarto_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_cuarto_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 3:
		_core3_cuarto_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_cuarto_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_cuarto_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 3:
		_core3_cuarto_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_cuarto_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[3])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_cuarto_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_CUARTO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_cuarto_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_cuarto_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_cuarto_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_cuarto_beat_terminar_y_continuar()


func _core3_cuarto_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_CUARTO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_quinto_beat_fsm()


func _core3_iniciar_quinto_beat_fsm() -> void:
	# H10.22 — stage 6->7 ya no entrega al quinto beat histórico. El quinto
	# beat reutiliza la misma FSM física/snapshotable de los beats anteriores.
	core3_secuencia_etapa = CORE3_ETAPA_QUINTO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_quinto_beat_preparar()


func _core3_quinto_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_QUINTO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_quinto_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_quinto_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 4:
		_core3_quinto_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_quinto_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_quinto_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 4:
		_core3_quinto_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_quinto_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[4])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_quinto_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_QUINTO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_quinto_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_quinto_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_quinto_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_quinto_beat_terminar_y_continuar()


func _core3_quinto_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_QUINTO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_sexto_beat_fsm()


func _core3_iniciar_sexto_beat_fsm() -> void:
	# H10.24 — stage 7->8 ya no entrega al sexto beat histórico. El sexto
	# beat reutiliza la misma FSM física/snapshotable de los beats anteriores.
	core3_secuencia_etapa = CORE3_ETAPA_SEXTO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_sexto_beat_preparar()


func _core3_sexto_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_SEXTO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_sexto_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_sexto_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 5:
		_core3_sexto_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_sexto_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_sexto_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 5:
		_core3_sexto_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_sexto_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[5])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_sexto_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_SEXTO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_sexto_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_sexto_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_sexto_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_sexto_beat_terminar_y_continuar()


func _core3_sexto_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_SEXTO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_septimo_beat_fsm()


func _core3_iniciar_septimo_beat_fsm() -> void:
	# H10.26 — stage 8->9 ya no entrega al séptimo beat histórico. El séptimo
	# beat reutiliza la misma FSM física/snapshotable de los beats anteriores.
	core3_secuencia_etapa = CORE3_ETAPA_SEPTIMO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_septimo_beat_preparar()


func _core3_septimo_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_SEPTIMO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_septimo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_septimo_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 6:
		_core3_septimo_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_septimo_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_septimo_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 6:
		_core3_septimo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_septimo_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[6])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_septimo_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_SEPTIMO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_septimo_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_septimo_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_septimo_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_septimo_beat_terminar_y_continuar()


func _core3_septimo_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_SEPTIMO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_octavo_beat_fsm()


func _core3_iniciar_octavo_beat_fsm() -> void:
	# H10.30 — stage 9->10 ya no entrega al octavo beat histórico. El octavo
	# beat reutiliza la misma FSM física/snapshotable de los beats anteriores.
	core3_secuencia_etapa = CORE3_ETAPA_OCTAVO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_octavo_beat_preparar()


func _core3_octavo_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_OCTAVO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_octavo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_octavo_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 7:
		_core3_octavo_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_octavo_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_octavo_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 7:
		_core3_octavo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_octavo_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[7])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_octavo_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_OCTAVO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_octavo_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_octavo_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_octavo_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_octavo_beat_terminar_y_continuar()


func _core3_octavo_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_OCTAVO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_noveno_beat_fsm()


func _core3_iniciar_noveno_beat_fsm() -> void:
	# H10.32 — stage 10->11 ya no entrega al noveno beat histórico. El noveno
	# beat reutiliza la misma FSM física/snapshotable de los beats anteriores.
	core3_secuencia_etapa = CORE3_ETAPA_NOVENO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_noveno_beat_preparar()


func _core3_noveno_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_NOVENO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_noveno_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_noveno_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 8:
		_core3_noveno_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_noveno_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_noveno_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 8:
		_core3_noveno_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_noveno_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[8])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_noveno_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_NOVENO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_noveno_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_noveno_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_noveno_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_noveno_beat_terminar_y_continuar()


func _core3_noveno_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_NOVENO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_decimo_beat_fsm()


func _core3_iniciar_decimo_beat_fsm() -> void:
	# H10.34 — stage 11->12 ya no entrega al décimo beat histórico. El décimo
	# beat reutiliza la misma FSM física/snapshotable de los beats anteriores.
	core3_secuencia_etapa = CORE3_ETAPA_DECIMO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_decimo_beat_preparar()


func _core3_decimo_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_decimo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimo_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 9:
		_core3_decimo_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_decimo_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_decimo_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 9:
		_core3_decimo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimo_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[9])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_decimo_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_decimo_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_decimo_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_decimo_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_decimo_beat_terminar_y_continuar()


func _core3_decimo_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_undecimo_beat_fsm()


func _core3_iniciar_undecimo_beat_fsm() -> void:
	# H10.36 — stage 12->13 ya no entrega al undécimo beat histórico. El beat 11
	# reutiliza la misma FSM física/snapshotable de los beats anteriores.
	core3_secuencia_etapa = CORE3_ETAPA_UNDECIMO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_undecimo_beat_preparar()


func _core3_undecimo_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_UNDECIMO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_undecimo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_undecimo_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 10:
		_core3_undecimo_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_undecimo_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_undecimo_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 10:
		_core3_undecimo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_undecimo_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[10])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_undecimo_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_UNDECIMO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_undecimo_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_undecimo_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_undecimo_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_undecimo_beat_terminar_y_continuar()


func _core3_undecimo_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_UNDECIMO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_duodecimo_beat_fsm()


func _core3_iniciar_duodecimo_beat_fsm() -> void:
	# H10.38 — stage 13->14 ya no entrega al duodécimo beat histórico. El beat 12
	# reutiliza la misma FSM física/snapshotable de los beats anteriores.
	core3_secuencia_etapa = CORE3_ETAPA_DUODECIMO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_duodecimo_beat_preparar()


func _core3_duodecimo_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DUODECIMO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_duodecimo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_duodecimo_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 11:
		_core3_duodecimo_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_duodecimo_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_duodecimo_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 11:
		_core3_duodecimo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_duodecimo_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[11])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_duodecimo_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DUODECIMO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_duodecimo_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_duodecimo_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_duodecimo_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_duodecimo_beat_terminar_y_continuar()


func _core3_duodecimo_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DUODECIMO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_decimotercer_beat_fsm()


func _core3_iniciar_decimotercer_beat_fsm() -> void:
	# H10.40 — stage 14->15 ya no entrega al decimotercer beat histórico.
	# El beat 13 reutiliza la misma FSM física/snapshotable.
	core3_secuencia_etapa = CORE3_ETAPA_DECIMOTERCER_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_decimotercer_beat_preparar()


func _core3_decimotercer_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOTERCER_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_decimotercer_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimotercer_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 12:
		_core3_decimotercer_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_decimotercer_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_decimotercer_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 12:
		_core3_decimotercer_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimotercer_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[12])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_decimotercer_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOTERCER_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_decimotercer_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_decimotercer_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_decimotercer_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_decimotercer_beat_terminar_y_continuar()


func _core3_decimotercer_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOTERCER_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_decimocuarto_beat_fsm()


func _core3_iniciar_decimocuarto_beat_fsm() -> void:
	# H10.42 — stage 15->16 ya no entrega al decimocuarto beat histórico.
	# El beat 14 reutiliza la misma FSM física/snapshotable.
	core3_secuencia_etapa = CORE3_ETAPA_DECIMOCUARTO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_decimocuarto_beat_preparar()


func _core3_decimocuarto_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOCUARTO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_decimocuarto_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimocuarto_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 13:
		_core3_decimocuarto_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_decimocuarto_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_decimocuarto_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 13:
		_core3_decimocuarto_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimocuarto_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[13])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_decimocuarto_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOCUARTO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_decimocuarto_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_decimocuarto_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_decimocuarto_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_decimocuarto_beat_terminar_y_continuar()


func _core3_decimocuarto_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOCUARTO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_decimoquinto_beat_fsm()


func _core3_iniciar_decimoquinto_beat_fsm() -> void:
	# H10.44 — stage 16->17 ya no entrega al decimoquinto beat histórico.
	# El beat 15 reutiliza la misma FSM física/snapshotable.
	core3_secuencia_etapa = CORE3_ETAPA_DECIMOQUINTO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_decimoquinto_beat_preparar()


func _core3_decimoquinto_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOQUINTO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_decimoquinto_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimoquinto_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 14:
		_core3_decimoquinto_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_decimoquinto_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_decimoquinto_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 14:
		_core3_decimoquinto_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimoquinto_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[14])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_decimoquinto_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOQUINTO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_decimoquinto_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_decimoquinto_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_decimoquinto_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_decimoquinto_beat_terminar_y_continuar()


func _core3_decimoquinto_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOQUINTO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_decimosexto_beat_fsm()


func _core3_iniciar_decimosexto_beat_fsm() -> void:
	# H10.46 — stage 17->18 ya no entrega al decimosexto beat histórico.
	# El beat 16 reutiliza la misma FSM física/snapshotable.
	core3_secuencia_etapa = CORE3_ETAPA_DECIMOSEXTO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_decimosexto_beat_preparar()


func _core3_decimosexto_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOSEXTO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_decimosexto_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimosexto_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 15:
		_core3_decimosexto_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_decimosexto_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_decimosexto_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 15:
		_core3_decimosexto_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimosexto_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[15])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_decimosexto_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOSEXTO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_decimosexto_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_decimosexto_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_decimosexto_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_decimosexto_beat_terminar_y_continuar()


func _core3_decimosexto_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOSEXTO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_decimoseptimo_beat_fsm()


func _core3_iniciar_decimoseptimo_beat_fsm() -> void:
	# H10.48 — stage 18->19 ya no entrega al decimoséptimo beat histórico.
	# El beat 17 reutiliza la misma FSM física/snapshotable.
	core3_secuencia_etapa = CORE3_ETAPA_DECIMOSEPTIMO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_decimoseptimo_beat_preparar()


func _core3_decimoseptimo_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOSEPTIMO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_decimoseptimo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimoseptimo_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 16:
		_core3_decimoseptimo_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_decimoseptimo_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_decimoseptimo_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 16:
		_core3_decimoseptimo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimoseptimo_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[16])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_decimoseptimo_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOSEPTIMO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_decimoseptimo_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_decimoseptimo_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_decimoseptimo_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_decimoseptimo_beat_terminar_y_continuar()


func _core3_decimoseptimo_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOSEPTIMO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_iniciar_decimoctavo_beat_fsm()


func _core3_iniciar_decimoctavo_beat_fsm() -> void:
	# H10.50 — stage 19->20 ya no entrega al decimoctavo beat histórico.
	# El beat 18 reutiliza la misma FSM física/snapshotable.
	core3_secuencia_etapa = CORE3_ETAPA_DECIMOCTAVO_BEAT_FSM
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = global_position
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	_core3_decimoctavo_beat_preparar()


func _core3_decimoctavo_beat_preparar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOCTAVO_BEAT_FSM:
		return
	if veces_fase_absoluta < 3 or not en_secuencia_especial or esta_derrotado:
		_core3_decimoctavo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimoctavo_beat_terminar_y_continuar()
		return

	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 17:
		_core3_decimoctavo_beat_terminar_y_continuar()
		return

	if fase_ataque != FaseAtaque.NINGUNA:
		core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	var distancia_objetivo: float = _distancia_combo_auto_adaptativa(objetivo)

	if distancia_x <= distancia_objetivo \
	and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		_core3_decimoctavo_beat_ejecutar()
		return

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * distancia_objetivo,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 900.0, 0.08, 0.30)

	core3_primer_beat_acercamiento_origen = global_position
	core3_primer_beat_acercamiento_destino = destino
	core3_primer_beat_acercamiento_duracion = duracion
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ACERCAR
	velocity = Vector2.ZERO


func _core3_decimoctavo_beat_ejecutar() -> void:
	var coreografia := _core2_construir_coreografia_actual()
	if coreografia.size() <= 17:
		_core3_decimoctavo_beat_terminar_y_continuar()
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		_core3_decimoctavo_beat_terminar_y_continuar()
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	if absf(distancia) > 1.0:
		mirando = signf(distancia)

	_ejecutar_paso_coreografia_combo_core(coreografia[17])
	core3_primer_beat_subfase = CORE3_BEAT_SUB_ESPERAR_ATAQUE


func _actualizar_core3_decimoctavo_beat_fsm(delta: float) -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOCTAVO_BEAT_FSM:
		return

	match core3_primer_beat_subfase:
		CORE3_BEAT_SUB_PREPARAR:
			_core3_decimoctavo_beat_preparar()

		CORE3_BEAT_SUB_ACERCAR:
			if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
				_core3_decimoctavo_beat_terminar_y_continuar()
				return
			var duracion := maxf(core3_primer_beat_acercamiento_duracion, 0.000001)
			core3_primer_beat_acercamiento_tiempo = minf(
				core3_primer_beat_acercamiento_tiempo + delta,
				duracion
			)
			var t := clampf(
				core3_primer_beat_acercamiento_tiempo / duracion,
				0.0,
				1.0
			)
			var inv := 1.0 - t
			var eased := 1.0 - inv * inv
			global_position = core3_primer_beat_acercamiento_origen.lerp(
				core3_primer_beat_acercamiento_destino,
				eased
			)
			velocity = Vector2.ZERO

			if t >= 1.0:
				global_position = core3_primer_beat_acercamiento_destino
				core3_primer_beat_acercamiento_tiempo = core3_primer_beat_acercamiento_duracion
				_core3_decimoctavo_beat_ejecutar()

		CORE3_BEAT_SUB_ESPERAR_ATAQUE:
			if fase_ataque == FaseAtaque.NINGUNA:
				_core3_decimoctavo_beat_terminar_y_continuar()


func _core3_decimoctavo_beat_terminar_y_continuar() -> void:
	if core3_secuencia_etapa != CORE3_ETAPA_DECIMOCTAVO_BEAT_FSM:
		return
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	core3_secuencia_etapa = CORE3_ETAPA_CONTINUACION_ASYNC
	_core3_continuar_desde_decimonoveno_beat()


func _core3_racha_restante_desde(indice_inicio: int) -> void:
	var coreografia := _core2_construir_coreografia_actual()
	for i in range(maxi(0, indice_inicio), coreografia.size()):
		if esta_derrotado:
			break
		if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
			break

		while fase_ataque != FaseAtaque.NINGUNA and not esta_derrotado:
			await get_tree().create_timer(POLL_COMBO_CORE_CONTINUO, true, false, true).timeout
		if esta_derrotado:
			break

		await _acercar_para_combo_auto()
		if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
			break

		var distancia: float = objetivo.global_position.x - global_position.x
		if absf(distancia) > 1.0:
			mirando = signf(distancia)
		_ejecutar_paso_coreografia_combo_core(coreografia[i])
		await get_tree().create_timer(POLL_COMBO_CORE_CONTINUO, true, false, true).timeout

	while fase_ataque != FaseAtaque.NINGUNA and not esta_derrotado:
		await get_tree().create_timer(POLL_COMBO_CORE_CONTINUO, true, false, true).timeout

	indice_punetazo = 0
	indice_patada = 0
	velocity.x = 0.0
	en_combo_auto_visual = false


func _core3_continuar_desde_decimonoveno_beat() -> void:
	await _core3_racha_restante_desde(18)
	if not esta_derrotado:
		await _ejecutar_finalizacion_absoluta()
	_salir_furia()
	_congelar_rival(false)
	_desbloquear_cinematica()
	en_secuencia_especial = false
	core3_secuencia_etapa = CORE3_ETAPA_INACTIVO
	core3_recarga_timer = 0.0
	core3_recarga_duracion = 0.0
	core3_recarga_primer_tick = false
	core3_acercamiento_duracion = 0.0
	core3_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = Vector2.ZERO
	core3_primer_beat_acercamiento_destino = Vector2.ZERO
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0


# Beat cinematográfico antes del combo automático (cargas 2 y 3): el
# personaje pasa a su pose de "recarga de energía" propia, brilla, y le
# avisa a main.gd para que oscurezca el escenario y haga zoom -- con
# cámara lenta cuando es la carga 3 (el Absoluto). Recién cuando termina
# este beat arranca _racha_combo_auto().
func _mostrar_recarga_energia(camara_lenta: bool) -> void:
	if not textura_recarga or not sprite:
		return
	var espera: float = 1.55 if camara_lenta else 1.05
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
	# 90.10.15: si ya se declaró la victoria, una secuencia asíncrona vieja
	# (especial/Absoluto) no tiene permiso para reabrir el control del Fighter.
	if en_pose_victoria:
		bloqueo_cinematico = true
		velocity = Vector2.ZERO
		carrera_activa = false
		carrera_direccion = 0.0
		return
	bloqueo_cinematico = false
	velocity = Vector2.ZERO
	carrera_activa = false
	carrera_direccion = 0.0
	dash_aereo_activo = false
	dash_aereo_direccion = 0.0
	dash_aereo_timer = 0.0
	# No recargar dash_aereo_usado acá: sólo aterrizar permite otro air dash.
	doble_pulso_izq_timer = 0.0
	doble_pulso_der_timer = 0.0
	tecla_izq_previa = false
	tecla_der_previa = false
	gamepad_salto_previo = false

func _pose_final_especial(duracion: float) -> void:
	# Usa el último frame de puñetazo como pose de lanzamiento: el cuerpo
	# hace realmente el golpe mientras la ilustración queda detrás.
	var lista: Array[Texture2D] = _lista_punetazo()
	if not lista.is_empty():
		_actualizar_textura(lista[lista.size() - 1])
		pose_timer = duracion

func _acercar_para_especial() -> bool:
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return false

	# 90.10.47 / H8.3-H8.5 — mismo Target Lock 2D, ya sin Tween ni await.
	var dx: float = objetivo.global_position.x - global_position.x
	var dy: float = objetivo.global_position.y - global_position.y
	var distancia_x: float = absf(dx)
	var distancia_y: float = absf(dy)
	if distancia_x <= 210.0 and distancia_y <= DISTANCIA_VERTICAL_COMBO_AUTO_OBJETIVO:
		return false

	var lado: float = signf(dx)
	if lado == 0.0:
		lado = mirando if absf(mirando) > 0.01 else 1.0
	mirando = lado

	var destino := Vector2(
		objetivo.global_position.x - lado * 150.0,
		objetivo.global_position.y
	)
	var distancia_recorrido: float = global_position.distance_to(destino)
	var duracion: float = clampf(distancia_recorrido / 980.0, 0.08, 0.32)

	var tex_aceleracion: Texture2D = _tex_carrera()
	if tex_aceleracion and sprite:
		_actualizar_textura(tex_aceleracion)
		pose_timer = duracion + 0.03

	core1_target_lock_origen = global_position
	core1_target_lock_destino = destino
	core1_target_lock_duracion = duracion
	core1_target_lock_tiempo = 0.0
	core1_target_lock_activo = true
	core1_secuencia_etapa = CORE1_ETAPA_TARGET_LOCK
	return true


func _actualizar_core1_target_lock(delta: float) -> void:
	if not core1_target_lock_activo:
		return

	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		core1_target_lock_activo = false
		core1_target_lock_tiempo = core1_target_lock_duracion
		velocity = Vector2.ZERO
		core1_target_lock_finalizado.emit()
		_core1_continuar_tras_target_lock()
		return

	var duracion := maxf(core1_target_lock_duracion, 0.000001)
	core1_target_lock_tiempo = minf(core1_target_lock_tiempo + delta, duracion)
	var t := clampf(core1_target_lock_tiempo / duracion, 0.0, 1.0)

	# Tween.TRANS_QUAD + EASE_OUT = 1 - (1-t)^2.
	var inverso := 1.0 - t
	var eased := 1.0 - inverso * inverso
	global_position = core1_target_lock_origen.lerp(core1_target_lock_destino, eased)
	velocity = Vector2.ZERO

	if t >= 1.0:
		global_position = core1_target_lock_destino
		core1_target_lock_activo = false

		# Orden histórico preservado:
		# 1) señal de final del lock
		# 2) continuación inmediata del especial EN EL MISMO physics tick.
		core1_target_lock_finalizado.emit()
		_core1_continuar_tras_target_lock()


func _core1_continuar_tras_target_lock() -> void:
	if core1_secuencia_etapa != CORE1_ETAPA_TARGET_LOCK:
		return
	if not en_secuencia_especial or veces_fase_absoluta != 1:
		return

	core1_secuencia_etapa = CORE1_ETAPA_POSTER
	velocity = Vector2.ZERO

	# Mismo bloque que históricamente vivía después de:
	#   await _acercar_para_especial()
	_pose_final_especial(0.95)
	_ejecutar_especial()

	if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		var dir_previa: float = signf(objetivo.global_position.x - global_position.x)
		if dir_previa == 0.0:
			dir_previa = mirando
		objetivo.preparar_impacto_cinematico(1.10, dir_previa, "especial")
		_aplicar_impacto_especial(2.6)

	# La parte LÓGICA de la espera del póster ahora está en physics ticks.
	# Sumamos un delta porque este updater también corre en el tick de transición;
	# así el primer decremento deja exactamente la duración nominal.
	core1_poster_duracion = CORE1_POSTER_DURACION_LOGICA
	core1_poster_timer = core1_poster_duracion + maxf(_delta_actual, 0.0)

	# Replicar de forma explícita las únicas mutaciones lógicas del inicio del
	# póster. Durante rollback catch-up omitimos sólo nodos/Tweens visuales.
	bloqueo_cinematico = true
	velocity = Vector2.ZERO
	_pose_final_especial(CORE1_POSTER_TIEMPO_VISIBLE + 0.25)

	if not rollback_suprimir_presentacion_core1:
		# 91.02.35 / 91.02.36 / 91.02.37 — si existe un PNG exclusivo del
		# usuario, CORE I lo usa aqui como gigantografia cinematica. Todas
		# reciben un retroceso global adicional; Cibor-X y Magnus conservan
		# su calibracion extra de escala/retroceso. Si no existe, cae al
		# poster especial historico sin tocar la logica del golpe.
		var tex_core1_poster: Texture2D = textura_core2_entrada if textura_core2_entrada else textura_especial
		# Presentación asíncrona aislada: en CORE I ya NO gobierna desbloqueo,
		# daño, hitstun ni fin de secuencia.
		_mostrar_poder_reemplazando(
			tex_core1_poster,
			CORE1_POSTER_TIEMPO_VISIBLE,
			320.0,
			false,
			2.6,
			true
		)


func _actualizar_core1_poster_logico(delta: float) -> void:
	if core1_secuencia_etapa != CORE1_ETAPA_POSTER:
		return
	if not en_secuencia_especial or veces_fase_absoluta != 1:
		core1_secuencia_etapa = CORE1_ETAPA_INACTIVO
		core1_poster_timer = 0.0
		core1_poster_duracion = 0.0
		return

	core1_poster_timer = maxf(0.0, core1_poster_timer - delta)
	if core1_poster_timer > 0.0:
		return

	# Equivalente lógico del tramo posterior al viejo:
	#   await _mostrar_poder_reemplazando(...)
	_congelar_rival(false)
	_desbloquear_cinematica()
	en_secuencia_especial = false
	core1_secuencia_etapa = CORE1_ETAPA_INACTIVO
	core1_poster_duracion = 0.0
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
	var empuje: float = 360.0 * peso_golpe
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
	core1_secuencia_etapa = CORE1_ETAPA_TARGET_LOCK
	core1_poster_timer = 0.0
	core1_poster_duracion = 0.0

	# Si hace falta distancia, physics ticks gobernarán la trayectoria y luego
	# llamarán _core1_continuar_tras_target_lock().
	# Si ya estamos cerca, el impacto/poster comienza en este mismo tick.
	var necesita_target_lock := _acercar_para_especial()
	if not necesita_target_lock:
		_core1_continuar_tras_target_lock()


# CORE II: recarga limpia, combo en modo normal y luego su remate/
# gigantografia final. No activa aura/Furia; sólo usa los golpes normales
# y conserva el cierre cinematografico propio del segundo CORE.
func _secuencia_combo_normal() -> void:
	if en_secuencia_especial:
		return
	en_secuencia_especial = true
	_bloquear_cinematica()
	_congelar_rival(true)

	# CORE II permanece en modo normal.
	en_fase_absoluta = false
	indice_punetazo = 0
	indice_patada = 0

	# H9.3 — la recarga y el primer Target Lock ya son estados explícitos
	# gobernados por _physics_process. No existe await/timer/Tween lógico aquí.
	_core2_iniciar_recarga_logica()


# Alias de compatibilidad por si algún script viejo todavía invoca el nombre
# anterior. Desde 90.10.40 CORE II ejecuta combo normal + remate.
func _secuencia_rematador() -> void:
	_secuencia_combo_normal()

func _ejecutar_rematador() -> void:
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return
	var distancia: float = absf(objetivo.global_position.x - global_position.x)
	var puede_conectar: bool = distancia <= maxf(rango_patada * 2.8, 360.0)
	var bloqueado: bool = objetivo.bloqueando
	var direccion: float = signf(objetivo.global_position.x - global_position.x)
	if direccion == 0.0:
		direccion = mirando

	rematador_iniciado.emit()
	_congelar_rival(true)
	if puede_conectar and objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		objetivo.preparar_impacto_cinematico(1.35, direccion, "rematador")
	await _mostrar_poder_reemplazando(textura_rematador, 1.30, 390.0)
	_congelar_rival(false)
	if puede_conectar and objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		var dano: float = dano_patada * MULT_DANO_GLOBAL * mult_dano_fase * 2.4
		objetivo.recibir_dano(dano, 520.0, 0.75, direccion, "rematador")
		objetivo.recibir_derribo_especial(
			direccion,
			1045.0 if not bloqueado else 570.0,
			505.0 if not bloqueado else 310.0,
			0.95 if not bloqueado else 0.45,
			true
		)
		_efecto_chispas(bloqueado, objetivo.global_position)
		await get_tree().create_timer(0.10, true, false, true).timeout
	rematador_conectado.emit()

# CORE III — FURIA FINAL: la transformación ocurre desde el comienzo de la
# secuencia. Se recorre el repertorio Furia en tres actos (puños, patadas y mezcla)
# y recién después llega la gigantografía absoluta. El especial normal de CORE I ya no se
# repite acá, para que cada nivel de CORE tenga una identidad propia.
func _secuencia_absoluta() -> void:
	if en_secuencia_especial:
		return
	en_secuencia_especial = true
	_bloquear_cinematica()
	_congelar_rival(true)

	# H10.10 — CORE III ENTRY permanece idéntico visualmente, pero la recarga
	# 1.55 s y el primer acercamiento ya son estados físicos snapshotables.
	_core3_iniciar_recarga_logica()

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
	# 91.02.21 — PASS 9.1. No abrir control entre póster e impacto/KO.
	# _core3_continuar_desde_decimonoveno_beat() conserva el unlock final existente.
	if objetivo and is_instance_valid(objetivo) and not objetivo.esta_derrotado:
		var direccion: float = signf(objetivo.global_position.x - global_position.x)
		if direccion == 0.0:
			direccion = mirando
		objetivo.recibir_dano(999.0, 980.0, 1.2, direccion, "absoluto")
		# CORE 3: derribo físico estable, sin Tween ni espera artificial.
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
	_aplicar_apoyo_visual_derribo_especial()
	# La textura derribada suele ser mucho más ancha que la pose de pie. Recalcular
	# el límite en el mismo frame evita que desaparezca fuera del borde.
	_aplicar_limites_arena()
	var fuerza_caida: float = 430.0 if derribo_especial_se_levanta else 560.0
	_efecto_golpe_suelo(fuerza_caida)
	aterrizaje_hecho.emit(fuerza_caida, true)

func _aplicar_apoyo_visual_derribo_especial() -> void:
	if not sprite or not sprite.texture:
		return
	# El used_rect de sprites horizontales puede incluir alas, pelo o efectos
	# por debajo del torso. Eso hace parecer que el cuerpo flota aunque la
	# colisión ya esté exactamente en el suelo. Corregimos sólo la presentación.
	var rect_derribo: Rect2 = _obtener_rect_visual(sprite.texture)
	var alto_visible: float = rect_derribo.size.y * absf(sprite.scale.y)
	var apoyo_dinamico: float = clampf(
		alto_visible * 0.055,
		0.0,
		OFFSET_DERRIBADO_ESPECIAL_DINAMICO_MAX
	)
	sprite_base_y += OFFSET_DERRIBADO_ESPECIAL_Y + apoyo_dinamico
	sprite.position.y = sprite_base_y


func recibir_derribo_especial(direccion: float, fuerza_x: float, fuerza_y: float, tiempo_tendido: float, se_levanta: bool) -> void:
	if esta_derrotado:
		return
	if direccion == 0.0:
		direccion = mirando if mirando != 0.0 else 1.0
	derribo_especial_activo = true
	# El cuerpo derribado deja de colisionar físicamente con el rival hasta
	# levantarse. Esto elimina el "personaje invisible que sigue empujando".
	_ignorar_colision_con_rival()
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
	# Tope exclusivo del vuelo de los remates CORE.
	velocity.x = clampf((fuerza_x / maxf(_masa_corporal(), 0.65)) * direccion, -1300.0, 1300.0)
	velocity.y = -fuerza_y
	hitstun_timer = maxf(hitstun_timer, 0.9 if se_levanta else 1.35)
	var t: Texture2D = _tex_golpe_recibido()
	if t:
		_actualizar_textura(t)

func _terminar_derribo_especial() -> void:
	derribo_especial_activo = false
	_restaurar_colision_con_rival()
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

# 91.02.29 — PASS 9.3E / transición suelo inmediata.
# No es un cancel de ataque: STARTUP y ACTIVO jamás se tocan. Únicamente recorta
# el remanente de RECOVERY cuando el golpe aéreo ya terminó visualmente y el
# Fighter acaba de apoyar los pies. También limpia una pose de salto/descenso/
# air-dash que haya quedado retenida por pose_timer.
func _resolver_transicion_aterrizaje_dinamica() -> void:
	if esta_derrotado or derribo_especial_activo or en_secuencia_especial \
		or bloqueo_cinematico or congelado_por_rival or hitstun_timer > 0.0 \
		or en_combo_auto_visual:
		return

	# Si aterrizamos durante la recuperación de un ataque normal, dejamos como
	# máximo ~2 frames a 60 Hz. No se altera daño, hitbox ni ventana ACTIVA.
	if fase_ataque == FaseAtaque.RECOVERY:
		timer_fase_ataque = minf(timer_fase_ataque, RECOVERY_ATERRIZAJE_NORMAL_MAX)
		return

	# STARTUP/ACTIVO conservan su compromiso completo incluso al tocar suelo.
	if fase_ataque != FaseAtaque.NINGUNA or not sprite:
		return

	var tex_actual: Texture2D = sprite.texture
	var es_pose_movilidad_aerea: bool = false
	if tex_actual:
		es_pose_movilidad_aerea = \
			(tex_actual == _tex_salto()) \
			or (tex_actual == _tex_doble_salto()) \
			or (tex_actual == _tex_descenso()) \
			or (tex_actual == _tex_carrera()) \
			or (tex_actual == _tex_evasion())

	if not es_pose_movilidad_aerea:
		return

	# El air dash ya cumplió su función física al tocar suelo. Liberamos además
	# su retención visual para que el mismo frame pueda mostrar caminata/parado.
	if dash_aereo_activo:
		_detener_dash_aereo()
	pose_timer = 0.0
	_actualizar_textura(_tex_reposo())
	sprite.rotation = 0.0

func intentar_guardia_escape_esquina_preimpacto() -> bool:
	# Sólo control humano enrutado: ésta es la ruta exclusiva de Versus Local.
	# No se habilita para IA ni para el control histórico de Arcade.
	if not controlado_por_jugador or fuente_control != FuenteControl.EXTERNA:
		return false
	if esta_derrotado or en_secuencia_especial or bloqueo_cinematico:
		return false
	# Si ya estaba bloqueando antes del impacto, se conserva el bloqueo normal
	# sin tocar su hitstun: esta mecánica sólo sirve para ENTRAR a guardia desde
	# una cadena que de otro modo dejaría al jugador sin respuesta.
	if bloqueando:
		return false
	if congelado_por_rival or derribo_especial_activo:
		# CORE II/III y derribos conservan su coreografía cerrada.
		return false
	if not is_on_floor() or fase_ataque != FaseAtaque.NINGUNA:
		return false
	# Debe existir hitstun previo: el primer golpe limpio nunca se convierte
	# mágicamente en bloqueo. La salida sólo puede aparecer en el follow-up.
	if hitstun_timer <= 0.0 or guardia_escape_esquina_cooldown > 0.0:
		return false
	if not bool(input_frame_enrutado_actual.get("bloqueo", false)):
		return false

	# 90.11.29 — corrección: la Guardia de Esquina debe usar el límite de arena
	# real que ya existe en Fighter. La llamada anterior apuntaba a una función
	# inexistente y provocaba Parse Error en Fighter y todas sus subclases.
	var limites_x: Vector2 = _limites_arena_x_pose_actual()
	var cerca_izquierda: bool = global_position.x <= limites_x.x + GUARDIA_ESCAPE_ESQUINA_MARGEN
	var cerca_derecha: bool = global_position.x >= limites_x.y - GUARDIA_ESCAPE_ESQUINA_MARGEN
	if not cerca_izquierda and not cerca_derecha:
		return false

	# Limpiamos solamente la reacción heredada del impacto anterior para dejar
	# entrar la guardia. El nuevo impacto se procesa inmediatamente después con
	# el daño/stun/knockback normales de BLOQUEO y provoca el recoil del atacante.
	hitstun_timer = 0.0
	_reaccion_impacto_timer = 0.0
	absorcion_impacto_timer = 0.0
	empuje_pendiente_timer = 0.0
	empuje_pendiente_fuerza = 0.0
	empuje_timer = 0.0
	empuje_x = 0.0
	velocity.x = 0.0
	pose_timer = 0.0
	guardia_escape_esquina_cooldown = GUARDIA_ESCAPE_ESQUINA_COOLDOWN
	_iniciar_bloqueo(GUARDIA_ESCAPE_ESQUINA_DURACION)
	return true

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
	if congelado_por_rival:
		return
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
	# 90.10.97 — COMBO CAGE. Si este Fighter está congelado por el rival Y ese
	# rival está ejecutando la ráfaga automática de CORE II/III, el impacto debe
	# sentirse (reacción, hit-stop, partículas, audio) pero NO desplazar el cuerpo.
	# El remate/Absoluto ocurre después de en_combo_auto_visual=false, por lo que
	# conserva intacto su knockback fuerte.
	var recibiendo_racha_core: bool = congelado_por_rival \
		and objetivo and is_instance_valid(objetivo) and objetivo.en_combo_auto_visual

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
	# 90.10.73 — jerarquía de impacto del RECEPTOR. El rival se congela unas
	# centésimas según la categoría real del golpe, nunca por un slow-motion
	# global. Así un puño conserva cadencia, una patada pesa más y CORE/remates
	# tienen una lectura claramente superior sin volver torpes los intercambios.
	var pausa_receptor: float = 0.0
	if en_bloqueo:
		pausa_receptor = 0.014 + float(nivel_impacto_actual) * 0.002
	else:
		match tipo_impacto:
			"punetazo":
				pausa_receptor = 0.012 + float(nivel_impacto_actual) * 0.006
			"patada":
				pausa_receptor = 0.018 + float(nivel_impacto_actual) * 0.007
			"especial":
				pausa_receptor = 0.038
			"rematador":
				pausa_receptor = 0.052
			"absoluto":
				pausa_receptor = 0.070
			_:
				pausa_receptor = 0.012 + float(nivel_impacto_actual) * 0.005
	hitstop_timer = maxf(hitstop_timer, pausa_receptor)

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
	if recibiendo_racha_core:
		# Ningún knockback intermedio: el rival queda como si estuviera contenido
		# por una pared invisible de combo. Limpiamos también cualquier empuje
		# pendiente del impacto anterior para evitar deriva acumulativa.
		empuje_timer = 0.0
		empuje_x = 0.0
		empuje_pendiente_timer = 0.0
		empuje_pendiente_fuerza = 0.0
		empuje_pendiente_direccion = 0.0
		velocity.x = 0.0
	elif direccion_atacante != 0.0:
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
	cruce_aereo_activo = false
	# 90.10.70 — el K.O. manda por encima de cualquier estado cinematográfico
	# anterior. Si el rival venía congelado por CORE/Absoluto, no puede conservar
	# un bloqueo que anule su física o deje una pose suspendida al terminar.
	bloqueo_cinematico = false
	en_secuencia_especial = false
	congelado_por_rival = false
	en_combo_auto_visual = false
	# KO definitivo: el cuerpo puede quedar tendido, pero nunca bloquear ni
	# empujar al ganador con una colisión que ya no corresponde al combate.
	_ignorar_colision_con_rival()
	en_pose_victoria = false
	# K.O. definitivo: fijar el origen sobre la línea física del escenario.
	# La corrección visual del PNG se realiza más abajo, después de cargar
	# exactamente la textura horizontal de derrotado.
	velocity = Vector2.ZERO
	empuje_timer = 0.0
	empuje_x = 0.0
	empuje_pendiente_timer = 0.0
	empuje_pendiente_fuerza = 0.0
	global_position.y = SUELO_REFERENCIA_Y
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

		# 90.10.70 — la pose horizontal suele tener pelo, aura o extremidades que
		# alteran el used_rect. Sumamos un apoyo dinámico pequeño según el alto
		# visible de ESTA pose, para que el torso no parezca flotando por culpa de
		# puntas de pelo/alas que llegan más abajo que el cuerpo real.
		var rect_ko: Rect2 = _obtener_rect_visual(sprite.texture)
		var alto_ko_visible: float = rect_ko.size.y * absf(sprite.scale.y)
		var apoyo_dinamico: float = clampf(alto_ko_visible * 0.075, 0.0, OFFSET_DERRIBADO_DINAMICO_MAX)
		sprite_base_y += OFFSET_DERRIBADO_FINAL_Y + apoyo_dinamico
		sprite.position.y = sprite_base_y

	# Reencuadrar el cuerpo YA con la textura horizontal aplicada y separar el
	# K.O. del ganador. En 90.10.69 la función existía pero nunca se llamaba.
	_aplicar_limites_arena()
	_asegurar_separacion_ko_final()

	# 90.10.18 — K.O. FINAL ESTABLE.
	# Una vez que el derrotado ya cayó y se asentó, NO lo recolocamos con Tween.
	# El rebote lateral del K.O. anterior hacía que el cuerpo pareciera deslizarse
	# solo por el suelo después de terminar la pelea. Velocity ya está en cero,
	# la colisión con el rival está ignorada y los límites de arena ya se aplicaron:
	# por eso la posición final de la caída se conserva exactamente hasta cambiar escena.
	derrotado.emit()

func _asegurar_separacion_ko_final() -> void:
	if not objetivo or not is_instance_valid(objetivo):
		return

	# El centro-a-centro fijo de 190 px no alcanza para sprites acostados.
	# Calculamos cuánto espacio ocupan REALMENTE ambos PNG en este instante.
	var distancia_necesaria: float = maxf(
		DISTANCIA_FINAL_GANADOR_DERRIBADO,
		_distancia_visual_entre_cuerpos(objetivo) + MARGEN_KO_VISUAL
	)
	var distancia_actual: float = absf(global_position.x - objetivo.global_position.x)
	if distancia_actual >= distancia_necesaria:
		return

	var lado_actual: float = signf(global_position.x - objetivo.global_position.x)
	var limites_ko: Vector2 = _limites_arena_x_pose_actual()
	var espacio_izq: float = objetivo.global_position.x - limites_ko.x
	var espacio_der: float = limites_ko.y - objetivo.global_position.x

	var lado: float = lado_actual
	if lado == 0.0:
		lado = -objetivo.mirando if objetivo.mirando != 0.0 else 1.0

	if lado < 0.0 and espacio_izq < distancia_necesaria:
		lado = 1.0
	elif lado > 0.0 and espacio_der < distancia_necesaria:
		lado = -1.0

	var destino_x: float = clampf(
		objetivo.global_position.x + lado * distancia_necesaria,
		limites_ko.x,
		limites_ko.y
	)

	# 90.10.70 — asentamiento inmediato y estable. No usamos Tween: al terminar
	# la pelea la posición del derrotado debe quedar definitiva, sin deslizarse
	# debajo del ganador ni volver a cruzarse por una coroutine tardía.
	global_position.x = destino_x
	velocity.x = 0.0
	_aplicar_limites_arena()


func _separar_ganador_del_ko() -> void:
	if not objetivo or not is_instance_valid(objetivo) or not objetivo.esta_derrotado:
		return

	# El K.O. horizontal puede ser mucho más ancho que un luchador de pie.
	# Usamos ambos radios visuales actuales, pero dejamos un piso de presentación
	# para que la pose de victoria nunca quede parada encima del derrotado.
	var distancia_necesaria: float = maxf(
		DISTANCIA_VICTORIA_GANADOR_DERRIBADO,
		_radio_corporal_visual() + objetivo._radio_corporal_visual() + MARGEN_VICTORIA_KO_VISUAL
	)
	var dx: float = global_position.x - objetivo.global_position.x
	var distancia_actual: float = absf(dx)
	if distancia_actual >= distancia_necesaria:
		return

	var limites: Vector2 = _limites_arena_x_pose_actual()
	var lado_actual: float = signf(dx)
	if lado_actual == 0.0:
		# Mantener al ganador en el lado coherente con su orientación de combate.
		lado_actual = -objetivo.mirando if absf(objetivo.mirando) > 0.01 else 1.0

	var destino_mismo_lado: float = objetivo.global_position.x + lado_actual * distancia_necesaria
	var destino_otro_lado: float = objetivo.global_position.x - lado_actual * distancia_necesaria
	var mismo_lado_valido: bool = destino_mismo_lado >= limites.x and destino_mismo_lado <= limites.y
	var otro_lado_valido: bool = destino_otro_lado >= limites.x and destino_otro_lado <= limites.y

	var destino_x: float
	if mismo_lado_valido:
		destino_x = destino_mismo_lado
	elif otro_lado_valido:
		destino_x = destino_otro_lado
	else:
		# Si ninguna dirección permite la distancia completa por estar contra un
		# borde, elegimos el extremo que más separación real ofrezca.
		var dist_izq: float = absf(limites.x - objetivo.global_position.x)
		var dist_der: float = absf(limites.y - objetivo.global_position.x)
		destino_x = limites.x if dist_izq >= dist_der else limites.y

	global_position.x = clampf(destino_x, limites.x, limites.y)
	velocity = Vector2.ZERO
	_aplicar_limites_arena()

	# La victoria debe seguir mirando hacia el área del combate/perdedor.
	var dir_rival: float = signf(objetivo.global_position.x - global_position.x)
	if dir_rival != 0.0:
		mirando = dir_rival

func reiniciar_para_ronda() -> void:
	vida = vida_maxima
	esta_derrotado = false
	cruce_aereo_activo = false
	# 90.10.82: mantener el contacto Fighter-vs-Fighter exclusivamente por
	# pushbox manual también al comenzar una ronda nueva.
	_restaurar_colision_con_rival()
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
	# H8.3 — ninguna trayectoria CORE I puede sobrevivir al reinicio de ronda.
	core1_target_lock_activo = false
	core1_target_lock_origen = Vector2.ZERO
	core1_target_lock_destino = Vector2.ZERO
	core1_target_lock_duracion = 0.0
	core1_target_lock_tiempo = 0.0
	core1_secuencia_etapa = CORE1_ETAPA_INACTIVO
	core1_poster_timer = 0.0
	core1_poster_duracion = 0.0
	rollback_suprimir_presentacion_core1 = false

	# H9.3 — limpiar completamente CORE II explícito.
	core2_secuencia_etapa = CORE2_ETAPA_INACTIVO
	core2_recarga_timer = 0.0
	core2_recarga_duracion = 0.0
	core2_acercamiento_origen = Vector2.ZERO
	core2_acercamiento_destino = Vector2.ZERO
	core2_acercamiento_duracion = 0.0
	core2_acercamiento_tiempo = 0.0
	core2_combo_paso_idx = 0
	core2_combo_total_pasos = 0
	core2_combo_subfase = CORE2_COMBO_SUB_PREPARAR
	core2_combo_acercamiento_origen = Vector2.ZERO
	core2_combo_acercamiento_destino = Vector2.ZERO
	core2_combo_acercamiento_duracion = 0.0
	core2_combo_acercamiento_tiempo = 0.0
	core2_rematador_subfase = CORE2_REM_SUB_POSTER
	core2_rematador_timer = 0.0
	core2_rematador_duracion = 0.0
	core2_rematador_puede_conectar = false
	core2_rematador_bloqueado = false
	core2_rematador_direccion = 1.0
	rollback_suprimir_presentacion_core2 = false
	core2_flash_entrada_mostrado = false
	_limpiar_core2_flash_entrada()
	if core2_recarga_brillo and is_instance_valid(core2_recarga_brillo):
		core2_recarga_brillo.kill()
	core2_recarga_brillo = null

	# H10.10 — limpiar frontera explícita CORE III.
	core3_secuencia_etapa = CORE3_ETAPA_INACTIVO
	core3_recarga_timer = 0.0
	core3_recarga_duracion = 0.0
	core3_recarga_primer_tick = false
	core3_acercamiento_origen = Vector2.ZERO
	core3_acercamiento_destino = Vector2.ZERO
	core3_acercamiento_duracion = 0.0
	core3_acercamiento_tiempo = 0.0
	core3_primer_beat_subfase = CORE3_BEAT_SUB_PREPARAR
	core3_primer_beat_acercamiento_origen = Vector2.ZERO
	core3_primer_beat_acercamiento_destino = Vector2.ZERO
	core3_primer_beat_acercamiento_duracion = 0.0
	core3_primer_beat_acercamiento_tiempo = 0.0
	if core3_recarga_brillo and is_instance_valid(core3_recarga_brillo):
		core3_recarga_brillo.kill()
	core3_recarga_brillo = null

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
	# PASS 12A — limpiar cualquier comando/tiro de la ronda anterior.
	comando_proyectil_etapa = 0
	comando_proyectil_timer = 0.0
	en_lanzamiento_proyectil = false
	proyectil_lanzamiento_timer = 0.0
	proyectil_spawn_timer = 0.0
	proyectil_disparo_pendiente = false
	proyectil_cooldown_timer = 0.0
	if proyectil_activo and is_instance_valid(proyectil_activo):
		proyectil_activo.queue_free()
	proyectil_activo = null
	# Limpiar flancos del Input Frame al comenzar una ronda nueva.
	z_estaba_presionado = false
	salto_estaba_presionado = false
	tecla_izq_previa = false
	tecla_der_previa = false
	gamepad_salto_previo = false
	input_externo_disponible = false
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
	# 90.10.75 — cada ronda empieza con una decisión limpia de IA.
	ia_cooldown_decision = 0.0
	ia_retrocediendo = false
	ia_mantener_distancia = false
	ia_combo_cancel_lock_timer = 0.0
	ia_dash_cooldown = 0.0
	ia_doble_salto_pendiente = false
	ia_doble_salto_timer = 0.0
	ia_ataque_aereo_pendiente = false
	ia_ataque_aereo_timer = 0.0
	ia_rafaga_dificil_restante = 0
	ia_rafaga_dificil_ultimo_tipo = ""
	dash_aereo_activo = false
	dash_aereo_direccion = 0.0
	dash_aereo_timer = 0.0
	dash_aereo_usado = false
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
	bloqueo_timer = 0.0
	fase_ataque = FaseAtaque.NINGUNA
	timer_fase_ataque = 0.0
	hitstun_timer = 0.0
	hitstop_timer = 0.0
	velocity = Vector2.ZERO
	empuje_timer = 0.0
	empuje_x = 0.0
	empuje_pendiente_timer = 0.0
	empuje_pendiente_fuerza = 0.0
	carrera_activa = false
	carrera_direccion = 0.0
	doble_pulso_izq_timer = 0.0
	doble_pulso_der_timer = 0.0
	tecla_izq_previa = false
	tecla_der_previa = false
	gamepad_salto_previo = false
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

# 90.10.76 — perfiles de dificultad. FÁCIL usa 1.0 en todos los factores y por
# tanto reproduce la IA 90.10.75 aprobada. Los otros perfiles sólo mejoran
# timing y toma de decisiones: jamás tocan daño, velocidad, alcance o CORE.
func _ia_factor_tiempo_decision() -> float:
	match dificultad_ia:
		DificultadIA.MEDIA: return 0.78
		DificultadIA.DIFICIL: return 0.24
		_: return 1.0

func _ia_factor_bloqueo() -> float:
	match dificultad_ia:
		DificultadIA.MEDIA: return 1.16
		# 91.02.42 — Difícil deja de ser "tortuga": menos bloqueo, más ofensiva.
		DificultadIA.DIFICIL: return 0.78
		_: return 1.0

func _ia_factor_ataque() -> float:
	match dificultad_ia:
		DificultadIA.MEDIA: return 1.08
		DificultadIA.DIFICIL: return 1.58
		_: return 1.0

func _ia_factor_movilidad() -> float:
	match dificultad_ia:
		DificultadIA.MEDIA: return 1.14
		DificultadIA.DIFICIL: return 2.05
		_: return 1.0

func _ia_prob_mantener_distancia() -> float:
	match dificultad_ia:
		DificultadIA.MEDIA: return 0.13
		DificultadIA.DIFICIL: return 0.0
		_: return 0.25

func _ia_factor_salto() -> float:
	match dificultad_ia:
		DificultadIA.MEDIA: return 1.16
		# Menos salto que 91.02.41: el jefe difícil debe entrar a pegar, no brincar.
		DificultadIA.DIFICIL: return 0.62
		_: return 1.0

func _ia_factor_backdash() -> float:
	match dificultad_ia:
		DificultadIA.MEDIA: return 1.10
		DificultadIA.DIFICIL: return 0.72
		_: return 1.0

func _ia_factor_doble_salto() -> float:
	return 0.82 if dificultad_ia == DificultadIA.DIFICIL else 1.0

func _ia_factor_ataque_aereo() -> float:
	return 1.05 if dificultad_ia == DificultadIA.DIFICIL else 1.0

func _ia_prob_patada_actual() -> float:
	# Difícil mezcla más puño/patada para que la presión no parezca una sola tecla.
	if dificultad_ia == DificultadIA.DIFICIL:
		return clampf(ia_prob_patada + 0.12, 0.42, 0.58)
	return ia_prob_patada

func _ia_dificil_asegurar_rafaga() -> void:
	if dificultad_ia != DificultadIA.DIFICIL:
		return
	if ia_rafaga_dificil_restante <= 0:
		# Tandas de 3 a 5 ataques normales. Cada ataque mantiene SU recovery legal.
		ia_rafaga_dificil_restante = randi_range(3, 5)

func _ia_dificil_elegir_patada_rafaga() -> bool:
	var prob: float = _ia_prob_patada_actual()
	# Evita series visuales monótonas y favorece puño/patada alternados.
	if ia_rafaga_dificil_ultimo_tipo == "patada":
		prob *= 0.42
	elif ia_rafaga_dificil_ultimo_tipo == "punetazo":
		prob = minf(0.72, prob + 0.20)
	return randf() < prob

func _ia_dificil_registrar_golpe_rafaga(tipo: String) -> void:
	if dificultad_ia != DificultadIA.DIFICIL:
		return
	ia_rafaga_dificil_ultimo_tipo = tipo
	ia_rafaga_dificil_restante = maxi(0, ia_rafaga_dificil_restante - 1)

# 90.11.06 — API llamada sólo por PerfectBlock después de CONFIRMAR x2/x3.
# Centralizarlo acá garantiza que todos los personajes CPU respeten el mismo lock,
# porque sus scripts terminan usando _comportamiento_ia_basico().
func activar_lock_recepcion_combo_cancel_cpu(duracion: float = 0.26) -> void:
	if controlado_por_jugador or fuente_control != FuenteControl.IA:
		return
	ia_combo_cancel_lock_timer = maxf(ia_combo_cancel_lock_timer, duracion)
	ia_retrocediendo = false
	ia_mantener_distancia = false
	bloqueando = false
	bloqueo_timer = 0.0
	if carrera_activa:
		_detener_carrera()
	velocity.x = 0.0


func _comportamiento_ia_basico(delta: float, vel_actual: float, distancia_ataque: float, distancia_perseguir: float) -> void:
	if esta_derrotado or not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		mover(0.0, vel_actual)
		return

	# 91.02.42 — DIFICIL usa el CORE en cuanto la barra REAL ya está completa.
	# No se regala energía ni se acelera la carga: sólo se evita gastar una
	# decisión ofensiva en otro golpe normal cuando el CORE ya está disponible.
	if dificultad_ia == DificultadIA.DIFICIL 		and poder >= poder_maximo 		and fase_ataque == FaseAtaque.NINGUNA 		and not en_fase_absoluta 		and not en_secuencia_especial 		and not congelado_por_rival:
		intentar_poder_especial()
		if en_secuencia_especial:
			return

	# 90.11.06 — el jugador ya confirmó un Combo Cancel. Durante esta microventana
	# la CPU recibe exactamente como un rival neutral de Versus: no decide nada.
	# No tocamos hitstun, fase_ataque ni los timers del atacante.
	if ia_combo_cancel_lock_timer > 0.0:
		ia_retrocediendo = false
		ia_mantener_distancia = false
		bloqueando = false
		bloqueo_timer = 0.0
		if carrera_activa:
			_detener_carrera()
		mover(0.0, vel_actual)
		return

	var distancia: float = objetivo.global_position.x - global_position.x
	var distancia_abs: float = absf(distancia)
	var direccion_rival: float = signf(distancia) if absf(distancia) > 1.0 else mirando
	mirando = direccion_rival

	# 90.10.75 — IA POR DISTANCIAS.
	# La CPU ya no interpreta toda la pelea como "perseguir hasta tocar". El
	# alcance real de sus golpes define una zona corta; por fuera existe una
	# zona media de lectura/entrada y luego una zona lejana de persecución.
	# Las probabilidades de personalidad de cada luchador siguen intactas.
	var rango_ataque_ia: float = maxf(
		distancia_ataque,
		maxf(rango_punetazo * 1.18, rango_patada * 1.20)
	)
	var zona_corta: float = rango_ataque_ia * 1.03
	var techo_zona_media: float = maxf(205.0, minf(distancia_perseguir, 320.0))
	var zona_media: float = clampf(rango_ataque_ia * 2.15, 205.0, techo_zona_media)
	var rango_presion: float = maxf(zona_corta * 1.38, zona_media * 0.72)
	var rival_atacando: bool = objetivo.fase_ataque == FaseAtaque.STARTUP or objetivo.fase_ataque == FaseAtaque.ACTIVO
	var factor_decision: float = _ia_factor_tiempo_decision()
	var factor_bloqueo: float = _ia_factor_bloqueo()
	var factor_ataque: float = _ia_factor_ataque()
	var factor_movilidad: float = _ia_factor_movilidad()
	var en_zona_corta: bool = distancia_abs <= zona_corta
	var en_zona_media: bool = distancia_abs > zona_corta and distancia_abs <= zona_media
	# Después de un impacto el knockback puede dejar al rival apenas fuera de
	# zona_corta. En DIFÍCIL permitimos que la siguiente decisión de la ráfaga
	# arranque desde esta franja; el lunge/rango real del golpe sigue intacto.
	var zona_rafaga_dificil: float = maxf(zona_corta * 1.28, rango_ataque_ia + 42.0)
	var en_zona_rafaga_dificil: bool = (
		dificultad_ia == DificultadIA.DIFICIL
		and ia_rafaga_dificil_restante > 0
		and distancia_abs <= zona_rafaga_dificil
	)

	ia_dash_cooldown = maxf(0.0, ia_dash_cooldown - delta)
	ia_cooldown_decision -= delta

	# --- Continuación de una acción aérea ya decidida ---
	# La decisión de doble salto/ataque aéreo se toma una vez al despegar para
	# que la CPU no vuelva a sortear una acción diferente en cada frame.
	if not is_on_floor():
		mover(direccion_rival, vel_actual * 0.82)

		if ia_doble_salto_pendiente and saltos_usados == 1:
			ia_doble_salto_timer = maxf(0.0, ia_doble_salto_timer - delta)
			if ia_doble_salto_timer <= 0.0:
				saltar()
				velocity.x = direccion_rival * vel_actual * 0.94
				ia_doble_salto_pendiente = false

		if ia_ataque_aereo_pendiente:
			ia_ataque_aereo_timer = maxf(0.0, ia_ataque_aereo_timer - delta)
			var rango_aereo: float = maxf(rango_ataque_ia * 1.45, 150.0)
			if ia_ataque_aereo_timer <= 0.0 and distancia_abs <= rango_aereo:
				ia_ataque_aereo_pendiente = false
				_orientar_hacia_rival_inmediato()
				if randf() < clampf(_ia_prob_patada_actual() + 0.08, 0.0, 0.68):
					intentar_patada()
				else:
					intentar_punetazo()
		return

	# Al tocar piso se cancelan planes aéreos que hayan quedado sin ejecutar.
	ia_doble_salto_pendiente = false
	ia_ataque_aereo_pendiente = false

	# Un dash ya iniciado conserva el mismo movimiento físico que usa el jugador.
	if carrera_activa:
		_orientar_hacia_rival_inmediato()
		return

	# 90.10.75 — las ofensivas nacen en una ventana de decisión. Antes, una vez
	# dentro de rango, la CPU llamaba intentar_punetazo/patada TODOS los frames;
	# apenas terminaba el recovery volvía a golpear de inmediato. Ahora el breve
	# cooldown genera neutral real sin añadir lentitud al Fighter.
	if ia_cooldown_decision <= 0.0:
		ia_retrocediendo = false
		ia_mantener_distancia = false

		if en_zona_corta or en_zona_rafaga_dificil:
			ia_cooldown_decision = (
				randf_range(0.025, 0.055)
				if dificultad_ia == DificultadIA.DIFICIL
				else randf_range(0.20, 0.39) * factor_decision
			)
		elif en_zona_media:
			ia_cooldown_decision = (
				randf_range(0.045, 0.085)
				if dificultad_ia == DificultadIA.DIFICIL
				else randf_range(0.27, 0.50) * factor_decision
			)
		else:
			ia_cooldown_decision = (
				randf_range(0.055, 0.095)
				if dificultad_ia == DificultadIA.DIFICIL
				else randf_range(0.32, 0.58) * factor_decision
			)

		# Defensa reactiva: en corto importa bastante; en media sólo se anticipa
		# si el rival está atacando. Nunca leemos el input del jugador de forma
		# perfecta, preservando una CPU justa y con personalidad.
		var prob_bloqueo_efectiva: float = clampf(ia_prob_bloqueo * (0.78 if rival_atacando else 0.10) * factor_bloqueo, 0.0, 0.82)
		var rafaga_dificil_activa: bool = (
			dificultad_ia == DificultadIA.DIFICIL
			and ia_rafaga_dificil_restante > 0
		)
		if not rafaga_dificil_activa and distancia_abs <= rango_presion and not bloqueando and randf() < prob_bloqueo_efectiva:
			_iniciar_bloqueo(randf_range(0.20, 0.42))
			return

		# En corto la CPU decide entre intercambio, pequeño retroceso o una pausa
		# mínima de lectura. El ataque ocurre AQUÍ, una vez por decisión, no frame
		# a frame. Esto es el corazón del nuevo ritmo de IA.
		if en_zona_corta or en_zona_rafaga_dificil:
			var prob_retroceso_corto: float = (
				ia_prob_retroceso * 0.34 * (1.0 if rival_atacando else 0.12)
				if dificultad_ia == DificultadIA.DIFICIL
				else ia_prob_retroceso * _ia_factor_backdash() * (1.25 if rival_atacando else 0.62)
			)
			if not rafaga_dificil_activa and randf() < prob_retroceso_corto:
				ia_retrocediendo = true
				if ia_dash_cooldown <= 0.0 and randf() < ia_prob_dash_atras:
					_iniciar_carrera(-direccion_rival)
					ia_dash_cooldown = randf_range(0.62, 1.02)
				return

			# Un porcentaje pequeño de decisiones no ataca: produce amague/neutral
			# sin hacer pasiva a la CPU. Si el rival ya está pegando, se reduce aún
			# más esa pausa para que responda con mayor urgencia.
			var prob_ataque_corto: float = (
				1.0
				if dificultad_ia == DificultadIA.DIFICIL
				else clampf((0.88 if rival_atacando else 0.80) * factor_ataque, 0.0, 0.96)
			)
			if randf() < prob_ataque_corto:
				mover(0.0, vel_actual)
				mirando = direccion_rival
				if dificultad_ia == DificultadIA.DIFICIL:
					_ia_dificil_asegurar_rafaga()
					if _ia_dificil_elegir_patada_rafaga():
						intentar_patada()
						_ia_dificil_registrar_golpe_rafaga("patada")
					else:
						intentar_punetazo()
						_ia_dificil_registrar_golpe_rafaga("punetazo")
					# Mientras queden golpes de la tanda, la siguiente decisión queda
					# lista en 0.0. Fighter igualmente obliga a terminar startup/activo/
					# recovery del ataque vigente antes de aceptar el siguiente.
					if ia_rafaga_dificil_restante > 0:
						ia_cooldown_decision = 0.0
					else:
						# Micro-respiro entre tandas, mucho menor que en MEDIO.
						ia_cooldown_decision = randf_range(0.035, 0.065)
				else:
					if randf() < _ia_prob_patada_actual():
						intentar_patada()
					else:
						intentar_punetazo()
					ia_cooldown_decision = randf_range(0.07, 0.16) * factor_decision
				return
			ia_mantener_distancia = dificultad_ia != DificultadIA.DIFICIL

		# Zona media: es el espacio de intención. Puede saltar, entrar con dash,
		# caminar o sostener brevemente la distancia. Así no todo encuentro termina
		# inmediatamente en dos sprites empujándose en el centro.
		elif en_zona_media:
			var prob_retroceso_media: float = (
				ia_prob_retroceso * 0.22 * (0.8 if rival_atacando else 0.08)
				if dificultad_ia == DificultadIA.DIFICIL
				else ia_prob_retroceso * _ia_factor_backdash() * (0.82 if rival_atacando else 0.28)
			)
			if randf() < prob_retroceso_media:
				ia_retrocediendo = true
				if ia_dash_cooldown <= 0.0 and randf() < ia_prob_dash_atras * 0.82:
					_iniciar_carrera(-direccion_rival)
					ia_dash_cooldown = randf_range(0.70, 1.10)
				return

			var prob_salto_efectiva: float = clampf(
				(ia_prob_salto + (0.06 if not objetivo.is_on_floor() else 0.0)) * _ia_factor_salto(),
				0.0,
				0.16 if dificultad_ia == DificultadIA.DIFICIL else 0.54
			)
			if randf() < prob_salto_efectiva:
				saltar()
				velocity.x = direccion_rival * vel_actual * 0.84
				ia_doble_salto_pendiente = randf() < clampf(
					ia_prob_doble_salto * _ia_factor_doble_salto(), 0.0, 0.90
				)
				ia_doble_salto_timer = (
					randf_range(0.10, 0.20)
					if dificultad_ia == DificultadIA.DIFICIL
					else randf_range(0.15, 0.27)
				)
				ia_ataque_aereo_pendiente = randf() < clampf(
					ia_prob_ataque_aereo * _ia_factor_ataque_aereo(), 0.0, 0.92
				)
				ia_ataque_aereo_timer = (
					randf_range(0.10, 0.22)
					if dificultad_ia == DificultadIA.DIFICIL
					else randf_range(0.18, 0.34)
				)
				return

			# Entrada explosiva desde media distancia, pero no en cada decisión.
			var prob_dash_media: float = clampf(
				ia_prob_dash_adelante * 0.86 * factor_movilidad *
				(1.18 if dificultad_ia == DificultadIA.DIFICIL else 1.0),
				0.0,
				0.96 if dificultad_ia == DificultadIA.DIFICIL else 0.72
			)
			if ia_dash_cooldown <= 0.0 and randf() < prob_dash_media:
				_iniciar_carrera(direccion_rival)
				ia_dash_cooldown = (
					randf_range(0.18, 0.34)
					if dificultad_ia == DificultadIA.DIFICIL
					else randf_range(0.55, 0.92)
				)
				return

			# Aproximadamente una de cada cuatro decisiones de zona media sostiene
			# la distancia; las demás avanzan a velocidad moderada.
			ia_mantener_distancia = randf() < _ia_prob_mantener_distancia()

		# Lejos: perseguir sigue siendo la prioridad. Conservamos el dash para que
		# la pelea no pierda velocidad ni se convierta en dos CPUs esperando.
		else:
			# 91.02.40 — fuera del antiguo radio de persecución la CPU ya no entra
			# en una zona muerta. La prioridad siempre es volver al combate.
			var prob_dash_lejos: float = clampf(
				ia_prob_dash_adelante * factor_movilidad * (1.18 if dificultad_ia == DificultadIA.DIFICIL else 1.0),
				0.0,
				0.94
			)
			if ia_dash_cooldown <= 0.0 and randf() < prob_dash_lejos:
				_iniciar_carrera(direccion_rival)
				ia_dash_cooldown = randf_range(
					0.18 if dificultad_ia == DificultadIA.DIFICIL else 0.52,
					0.36 if dificultad_ia == DificultadIA.DIFICIL else 0.90
				)
				return

	# --- Ejecución continua de la intención elegida ---
	if bloqueando:
		mover(0.0, vel_actual)
		return

	if en_zona_corta:
		if ia_retrocediendo:
			mover(-direccion_rival, vel_actual * 0.78)
		else:
			# En corto no perseguimos ni reintentamos golpes durante cada frame.
			# La siguiente ofensiva llegará en la próxima ventana de decisión.
			mover(0.0, vel_actual)
		return

	if en_zona_media:
		if ia_retrocediendo:
			mover(-direccion_rival, vel_actual * 0.72)
		elif ia_mantener_distancia:
			mover(0.0, vel_actual)
		else:
			mover(direccion_rival, vel_actual * 0.82)
		return

	# 91.02.40 — Zona lejana: persecución SIEMPRE. `distancia_perseguir` deja de
	# ser un muro invisible que apagaba la IA. Difícil usa la misma velocidad
	# legal del Fighter; sólo decide acercarse con mayor constancia.
	mover(direccion_rival, vel_actual)

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
func _mostrar_poder_reemplazando(tex: Texture2D, tiempo_visible: float, alto_deseado: float, aplicar_impacto: bool = false, multiplicador_dano: float = 2.4, solo_presentacion: bool = false) -> void:
	if not tex or not sprite:
		return

	# H8.5: CORE I puede usar esta rutina como PRESENTACIÓN PURA. CORE II/III
	# conservan el comportamiento histórico porque solo_presentacion=false.
	if not solo_presentacion:
		bloqueo_cinematico = true
		velocity = Vector2.ZERO
		_pose_final_especial(tiempo_visible + 0.25)
	var img := Sprite2D.new()
	img.texture = tex
	img.centered = true
	img.z_index = -4

	var es_absoluto: bool = tex == textura_absoluto
	var es_rematador: bool = tex == textura_rematador
	var es_core1_exclusivo: bool = solo_presentacion and tex == textura_core2_entrada
	var mult_altura: float = float(PODER_CINEMA_ALTURA_MULT.get(nombre_luchador, 1.0))
	if es_core1_exclusivo:
		mult_altura *= float(CORE1_POSTER_EXCLUSIVO_ALTURA_MULT.get(nombre_luchador, 1.0))
	var alto_final: float = alto_deseado * mult_altura

	# 90.10.26: escalar por el área VISIBLE del PNG, no por todo el lienzo.
	# Así un archivo con mucho margen transparente no termina ocupando media
	# pantalla ni queda descentrado. También anclamos el contenido visible al piso.
	var rect_visible: Rect2 = _obtener_rect_visual(tex)
	if rect_visible.size.x <= 1.0 or rect_visible.size.y <= 1.0:
		rect_visible = Rect2(0.0, 0.0, float(tex.get_width()), float(tex.get_height()))
	var esc: float = alto_final / maxf(rect_visible.size.y, 1.0)

	# Limitar el ancho cinematográfico según el encuadre REAL de cámara. Esto
	# evita recortes en los extremos y conserva al rival visible.
	var cam: Camera2D = get_viewport().get_camera_2d()
	var ancho_visible_mundo: float = 1280.0
	if cam:
		ancho_visible_mundo = get_viewport_rect().size.x / maxf(cam.zoom.x, 0.01)
	var fraccion_max: float = 0.60 if es_absoluto else (0.56 if es_rematador else 0.52)
	if nombre_luchador in ["Jester", "Kali"]:
		fraccion_max -= 0.035
	if es_core1_exclusivo:
		fraccion_max += float(CORE1_POSTER_EXCLUSIVO_FRACCION_ANCHO_EXTRA.get(nombre_luchador, 0.0))
	var ancho_arte: float = rect_visible.size.x * esc
	var ancho_maximo: float = ancho_visible_mundo * fraccion_max
	if ancho_arte > ancho_maximo and ancho_arte > 1.0:
		esc *= ancho_maximo / ancho_arte
		ancho_arte = rect_visible.size.x * esc

	img.scale = Vector2(esc, esc)
	img.flip_h = mirando < 0.0

	# Compensar el centro real del contenido visible dentro del lienzo PNG.
	var centro_visible_x_tex: float = rect_visible.position.x + rect_visible.size.x * 0.5
	var fondo_visible_y_tex: float = rect_visible.position.y + rect_visible.size.y
	var offset_centro_x: float = (centro_visible_x_tex - float(tex.get_width()) * 0.5) * esc
	var offset_fondo_y: float = (fondo_visible_y_tex - float(tex.get_height()) * 0.5) * esc
	# 90.10.28 — DEPTH PASS V2: la gigantografía retrocede un poco más.
	# El objetivo es dejar todavía más protagonista al cuerpo real del
	# luchador, abrir lectura del rival y mostrar mejor la escenografía del
	# escenario CORE, especialmente en Jester donde el arte ocupa mucho ancho.
	var separacion_poster: float = 118.0 if es_absoluto else (96.0 if es_rematador else 82.0)
	# Jester necesita más aire porque su arte es especialmente ancho/cargado.
	# Kali recibe una corrección menor por sus alas y energía integrada.
	if nombre_luchador == "Jester":
		separacion_poster += 48.0
	elif nombre_luchador == "Kali":
		separacion_poster += 22.0
	if es_core1_exclusivo:
		separacion_poster += CORE1_POSTER_EXCLUSIVO_SEPARACION_GLOBAL
		separacion_poster += float(CORE1_POSTER_EXCLUSIVO_SEPARACION_EXTRA.get(nombre_luchador, 0.0))
	var centro_local_deseado: float = -mirando * separacion_poster
	var pos_base := Vector2(centro_local_deseado - offset_centro_x, -18.0 - offset_fondo_y)

	# Mantener el contenido visible dentro de los bordes actuales de cámara.
	if cam:
		var medio_ancho: float = ancho_visible_mundo * 0.5
		var margen: float = 26.0
		var izquierda: float = cam.global_position.x - medio_ancho + margen
		var derecha: float = cam.global_position.x + medio_ancho - margen
		var centro_global_arte: float = global_position.x + centro_local_deseado
		var medio_arte: float = ancho_arte * 0.5
		var centro_clamp: float = clampf(centro_global_arte, izquierda + medio_arte, derecha - medio_arte)
		centro_local_deseado = centro_clamp - global_position.x
		pos_base.x = centro_local_deseado - offset_centro_x
	img.position = pos_base

	# Presencia cinematográfica sin tapar la lectura del rival. Jester/Kali
	# reciben una transparencia apenas mayor porque su propio arte ya trae
	# mucha energía integrada.
	var alpha_poster: float = 0.90 if es_absoluto else 0.84
	alpha_poster *= float(PODER_CINEMA_ALPHA_MULT.get(nombre_luchador, 1.0))
	var tono_poster: Color = Color(0.66, 0.68, 0.74, 0.0)
	img.modulate = tono_poster
	var escala_inicial: Vector2 = Vector2(esc, esc)
	var escala_final: Vector2 = Vector2(esc, esc)
	img.scale = escala_inicial
	add_child(img)

	# Halo de poder sobre el piso: el golpe especial "enciende" el suelo
	# sin cubrir la pantalla con otra placa. Es muy sutil y queda detrás
	# del luchador/póster.
	var vfx_mult: float = float(PODER_CINEMA_VFX_MULT.get(nombre_luchador, 0.88))
	if es_absoluto:
		vfx_mult = minf(vfx_mult + 0.08, 0.96)

	var halo_piso := Polygon2D.new()
	halo_piso.polygon = _elipse_poder_poligono(74.0 * vfx_mult, 10.0 * vfx_mult)
	halo_piso.color = Color(color_energia_poder().r, color_energia_poder().g, color_energia_poder().b, 0.0)
	halo_piso.position = Vector2(0.0, 3.0)
	halo_piso.z_index = -1
	add_child(halo_piso)

	var tw_halo := create_tween()
	tw_halo.set_ignore_time_scale(true)
	tw_halo.set_parallel(true)
	tw_halo.tween_property(halo_piso, "modulate:a", 0.22, 0.16)
	tw_halo.tween_property(halo_piso, "scale", Vector2(1.18, 1.0), 0.32).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	var tween := create_tween()
	tween.set_ignore_time_scale(true)
	tween.set_parallel(true)
	tween.tween_property(img, "modulate:a", alpha_poster, 0.12)
	tween.tween_property(img, "scale", escala_final, 0.01)
	tween.set_parallel(false)
	tween.tween_interval(tiempo_visible)
	tween.tween_property(img, "modulate:a", 0.0, 0.30)

	# El póster ya no pulsa de tamaño. La energía vive en luz/partículas;
	# la escala permanece clavada para no reintroducir el efecto de "crecer".
	var tween_pulso := create_tween()
	tween_pulso.set_ignore_time_scale(true)
	tween_pulso.set_loops()
	tween_pulso.tween_property(img, "modulate:a", alpha_poster * 0.96, 0.24)
	tween_pulso.tween_property(img, "modulate:a", alpha_poster, 0.24)

	# Capa de aura profunda: muy tenue, detrás del póster, para que el poder
	# parezca emitir energía hacia el escenario en vez de ser una imagen plana.
	var aura_fondo := Polygon2D.new()
	aura_fondo.polygon = _elipse_poder_poligono((145.0 if es_absoluto else 120.0) * vfx_mult, (42.0 if es_absoluto else 34.0) * vfx_mult)
	aura_fondo.position = Vector2(-mirando * 28.0, 4.0)
	aura_fondo.color = Color(color_energia_poder().r, color_energia_poder().g, color_energia_poder().b, 0.0)
	aura_fondo.z_index = -5
	add_child(aura_fondo)
	var tw_aura := create_tween()
	tw_aura.set_ignore_time_scale(true)
	tw_aura.set_parallel(true)
	tw_aura.tween_property(aura_fondo, "modulate:a", 0.12 if not es_absoluto else 0.17, 0.20)
	tw_aura.tween_property(aura_fondo, "scale", Vector2(1.08, 1.0), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	_animar_energia_poder(pos_base, tiempo_visible + 0.5, vfx_mult)

	var impacto_pendiente: bool = aplicar_impacto

	await tween.finished
	tween_pulso.kill()
	if is_instance_valid(halo_piso):
		var tw_halo_out := create_tween()
		tw_halo_out.set_ignore_time_scale(true)
		tw_halo_out.tween_property(halo_piso, "modulate:a", 0.0, 0.18)
		await tw_halo_out.finished
		halo_piso.queue_free()
	if is_instance_valid(aura_fondo):
		var tw_aura_out := create_tween()
		tw_aura_out.set_ignore_time_scale(true)
		tw_aura_out.tween_property(aura_fondo, "modulate:a", 0.0, 0.16)
		await tw_aura_out.finished
		aura_fondo.queue_free()
	img.queue_free()
	if impacto_pendiente:
		_aplicar_impacto_especial(multiplicador_dano)
	if not solo_presentacion:
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
func _animar_energia_poder(centro: Vector2, duracion: float, intensidad: float = 0.88) -> void:
	var color_energia: Color = color_fase if color_fase else Color(1.0, 1.0, 1.0)
	var t := 0.0
	var proximo_anillo := 0.0
	var proximo_rayo := 0.18
	var intervalo_anillo: float = lerpf(0.68, 0.52, intensidad)
	while t < duracion:
		if t >= proximo_anillo:
			_spawn_anillo_energia(centro, color_energia, intensidad)
			proximo_anillo = t + intervalo_anillo
		if t >= proximo_rayo:
			_spawn_rayo_energia(centro, color_energia, intensidad)
			proximo_rayo = t + randf_range(0.42, 0.68)
		await get_tree().create_timer(0.1, true, false, true).timeout
		t += 0.1

func _spawn_anillo_energia(centro: Vector2, color: Color, intensidad: float = 0.88) -> void:
	var anillo := Line2D.new()
	anillo.width = 3.2 * intensidad
	anillo.default_color = Color(color.r, color.g, color.b, 0.56 * intensidad)
	# 90.10.26: energía de presentación DETRÁS de ambos Fighter. El impacto
	# real (chispas/onda) sigue delante cuando conecta.
	anillo.z_index = -2
	var puntos := PackedVector2Array()
	for i in range(33):
		var ang: float = (TAU / 32.0) * i
		puntos.append(Vector2(cos(ang), sin(ang) * 0.55) * 20.0)
	anillo.points = puntos
	anillo.position = centro
	add_child(anillo)

	var radio_final := randf_range(78.0, 126.0) * intensidad
	var tw := create_tween()
	tw.set_ignore_time_scale(true)
	tw.set_parallel(true)
	tw.tween_property(anillo, "scale", Vector2.ONE * (radio_final / 20.0), 0.56).set_trans(Tween.TRANS_SINE)
	tw.tween_property(anillo, "modulate:a", 0.0, 0.56)
	tw.chain().tween_callback(anillo.queue_free)

func _spawn_rayo_energia(centro: Vector2, color: Color, intensidad: float = 0.88) -> void:
	var rayo := Line2D.new()
	rayo.width = 2.4 * intensidad
	rayo.default_color = Color(1.0, 1.0, 1.0, 0.68 * intensidad).lerp(color, 0.3)
	rayo.z_index = -1
	var ang: float = randf_range(0.0, TAU)
	var dist: float = randf_range(48.0, 102.0) * intensidad
	var punta := Vector2(cos(ang), sin(ang) * 0.6) * dist
	var medio := punta * 0.5 + Vector2(randf_range(-14.0, 14.0), randf_range(-14.0, 14.0))
	rayo.points = PackedVector2Array([Vector2.ZERO, medio, punta])
	rayo.position = centro
	add_child(rayo)

	var tw := create_tween()
	tw.set_ignore_time_scale(true)
	tw.tween_property(rayo, "modulate:a", 0.0, 0.16)
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
	sombra.position = Vector2(0, 3 + OFFSET_VISUAL_LINEA_COMBATE_Y)
	sombra.z_index = -5
	add_child(sombra)

func _actualizar_sombra() -> void:
	if not sombra:
		return
	var altura := clampf(SUELO_REFERENCIA_Y - global_position.y, 0.0, 320.0)
	var factor := clampf(1.0 - altura / 260.0, 0.42, 1.0)
	sombra.scale = Vector2(1.0 + (1.0 - factor) * 0.25, factor)
	sombra.modulate.a = 0.34 * factor

func _mantener_reaccion_visual_congelada() -> bool:
	if not congelado_por_rival or not objetivo or not is_instance_valid(objetivo):
		return false

	# 91.02.21 — PASS 9.1. La captura visual pertenece a TODA secuencia CORE,
	# no solamente a la ráfaga CORE II/III. Esto evita que CORE I vuelva a idle
	# mientras el atacante todavía conserva su pose/póster final.
	return objetivo.en_secuencia_especial


func _actualizar_sensacion_fisica(delta: float) -> void:
	if not sprite:
		return

	asentamiento_aterrizaje = move_toward(asentamiento_aterrizaje, 0.0, 7.5 * delta)
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
			parpado_izq.scale.y = 0.25
			parpado_der.scale.y = 0.25
		return

	parpadeo_timer -= delta
	if parpadeo_fase == 0 and parpadeo_timer <= 0.0:
		parpadeo_fase = 1
		parpadeo_progreso = 0.0

	if parpadeo_fase == 1:
		parpadeo_progreso += delta / 0.055
		if parpado_izq:
			# Por ahora la capa no se muestra: los ojos ya están dibujados
			# dentro de cada sprite y un párpado procedural genérico no debe
			# inventar una línea fuera de la cara. Mantenemos el temporizador
			# listo para futuras máscaras faciales por personaje.
			parpado_izq.visible = false
			parpado_der.visible = false
		if parpadeo_progreso >= 1.0:
			parpadeo_fase = 2
			parpadeo_progreso = 0.0
	elif parpadeo_fase == 2:
		parpadeo_progreso += delta / 0.07
		var apertura: float = 1.0 - clampf(parpadeo_progreso, 0.0, 1.0)
		if parpado_izq:
			parpado_izq.visible = false
			parpado_der.visible = false
		if parpadeo_progreso >= 1.0:
			parpadeo_fase = 0
			parpadeo_timer = randf_range(2.0, 4.2)
			if parpado_izq:
				parpado_izq.visible = false
				parpado_der.visible = false
				parpado_izq.scale.y = 0.25
				parpado_der.scale.y = 0.25

func _crear_aura_core() -> void:
	if aura_core or not sprite:
		return
	aura_core = Polygon2D.new()
	aura_core.name = "AuraCore"
	aura_core.polygon = _crear_elipse_local(46.0, 12.0)
	aura_core.position = Vector2(0.0, -2.0 + OFFSET_VISUAL_LINEA_COMBATE_Y)
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
	luz_contacto.position = Vector2(0.0, 1.0 + OFFSET_VISUAL_LINEA_COMBATE_Y)
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
	impulso_visual = 0.76 + peso_aterrizaje * 0.20
	impulso_visual_vel = -1.35 - peso_aterrizaje * 0.60
	# 91.02.16 — PASS 4: contacto más firme pero recuperación visual más corta.
	# La escala sigue bloqueada; sólo reforzamos microcaída/rotación/sombra.
	asentamiento_aterrizaje = 0.84 + peso_aterrizaje * 0.32
	impacto_visual_y = maxf(impacto_visual_y, 1.8 + peso_aterrizaje * 1.0)
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

	# 91.02.27 — PASS 9.3C / CONTINUIDAD VISUAL CORE.
	# La rafaga automatica ya usa una cadencia logica uniforme, pero entre el fin
	# visual de un golpe y el siguiente pueden existir unos milisegundos de
	# RECOVERY/microacercamiento. Antes, en ese hueco, el updater general podia
	# insertar _tex_reposo() y algunos overrides (Aethel/Varkhos) podian insertar
	# aceleracion_combo. Dax se percibia mas limpio porque esa sustitucion era
	# mucho menos visible.
	#
	# Regla nueva: si durante CORE II/III el sprite ACTUAL ya es un golpe del
	# repertorio, RECOVERY/NINGUNA conserva ese golpe hasta que el siguiente
	# ataque entra a STARTUP y lo reemplaza. No cambia pose_timer, hitbox, timing,
	# daño, hitstun, recovery real ni posicion.
	if en_combo_auto_visual 		and (fase_ataque == FaseAtaque.RECOVERY or fase_ataque == FaseAtaque.NINGUNA):
		var textura_actual_combo: Texture2D = sprite.texture
		if _es_textura_ataque_repertorio(textura_actual_combo) 			and not _es_textura_ataque_repertorio(tex):
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
	# La línea visual se baja sin alterar la colisión física del escenario.
	sprite_base_y += OFFSET_VISUAL_LINEA_COMBATE_Y
	sprite.position.y = sprite_base_y
	sprite.position.x = _sprite_ancla_x()

	if forma_colision:
		var mult_cuerpo: float = _mult_cuerpo_actual()
		var ancho_colision: float = ancho_cuerpo * mult_cuerpo
		var alto_colision: float = maxf(alto_cuerpo * mult_cuerpo, _altura_visible_objetivo() * COLISION_ALTURA_VISIBLE_MULT)
		forma_colision.size = Vector2(ancho_colision, alto_colision)
		colision_shape.position.y = -alto_colision / 2.0

	# 90.10.72 — la separación final se hace DESPUÉS de cargar/normalizar la
	# pose de victoria, porque recién aquí conocemos su volumen visual real.
	_separar_ganador_del_ko()

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
	if tex == textura_recarga and RECARGA_REDRAW_MULT.has(nombre_luchador):
		escala_pose *= float(RECARGA_REDRAW_MULT[nombre_luchador])
	if tex == textura_proyectil_pose:
		escala_pose *= proyectil_pose_escala_mult
	return clampf(escala_pose, 0.08, 2.0)

func _textura_en_lista(tex: Texture2D, lista: Array[Texture2D]) -> bool:
	for item in lista:
		if item == tex:
			return true
	return false

# 91.02.27 — reconoce cualquier sprite ofensivo NORMAL o FURIA del roster.
# Se usa únicamente como guardia visual de la rafaga CORE; no participa en
# hitboxes, daño, selección de repertorio ni lógica de combate.
func _es_textura_ataque_repertorio(tex: Texture2D) -> bool:
	if not tex:
		return false
	if tex == textura_punetazo or tex == textura_patada:
		return true
	if tex == textura_furia_punetazo or tex == textura_furia_patada:
		return true
	if _textura_en_lista(tex, texturas_punetazo_extra):
		return true
	if _textura_en_lista(tex, texturas_patada_extra):
		return true
	if _textura_en_lista(tex, texturas_furia_punetazo_extra):
		return true
	if _textura_en_lista(tex, texturas_furia_patada_extra):
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

func _radio_corporal_visual() -> float:
	# No usamos el ancho completo del PNG como cuerpo: pelo, alas y auras
	# pueden sobresalir mucho. Tomamos una fracción del used_rect alfa.
	if not sprite or not sprite.texture:
		return maxf(ancho_cuerpo * _mult_cuerpo_actual() * 0.62, 40.0)

	var rect: Rect2 = _obtener_rect_visual(sprite.texture)
	if rect.size.x <= 1.0 or rect.size.y <= 1.0:
		return maxf(ancho_cuerpo * _mult_cuerpo_actual() * 0.62, 40.0)

	var ancho_visible: float = rect.size.x * absf(sprite.scale.x)
	var alto_visible: float = rect.size.y * absf(sprite.scale.y)
	var horizontal: bool = esta_derrotado or ancho_visible > alto_visible * 1.22

	if horizontal:
		# Un cuerpo tumbado ocupa mucho más espacio lateral.
		return clampf(ancho_visible * 0.47, 96.0, 180.0)

	# De pie protegemos principalmente torso/cadera, no alas/cabello.
	return clampf(ancho_visible * 0.22, 40.0, 62.0)


func _distancia_visual_entre_cuerpos(otro: Fighter) -> float:
	if not otro or not is_instance_valid(otro):
		return DISTANCIA_MINIMA_LUCHADORES
	return _radio_corporal_visual() + otro._radio_corporal_visual() + MARGEN_SEPARACION_VISUAL


func _distancia_combo_auto_adaptativa(otro: Fighter) -> float:
	# 90.10.71 — PUSHBOX 2.0 para CORE II/III. El viejo target fijo de 82 px
	# era suficiente para impedir que los centros se cruzaran, pero no para que
	# dos torsos grandes se leyeran separados. Calculamos una distancia compacta
	# usando sólo el radio corporal recortado (nunca el ancho total del PNG).
	if not otro or not is_instance_valid(otro):
		return DISTANCIA_COMBO_AUTO_PUSH_MIN

	# 91.05.15 PASS 2O — durante la RÁFAGA automática el receptor está anclado,
	# por lo que no necesitamos recalcular la separación con cada nueva pose de
	# golpe recibido. Aethel/Kali/etc. pueden cambiar mucho su radio visual entre
	# sprites y eso disparaba micro-acercamientos de al menos 0.08 s entre beats.
	# Usamos el mismo target compacto máximo que ya admite el CORE (100 px):
	# cadencia constante para todos, sin cambiar masa, hitstun ni física real.
	if en_combo_auto_visual or otro.en_combo_auto_visual:
		return DISTANCIA_COMBO_AUTO_PUSH_MAX

	var radio_suma: float = _radio_corporal_visual() + otro._radio_corporal_visual()
	# El radio de pie está recortado a 40..62 px por luchador. Tomamos sólo una
	# fracción de lo que excede el cuerpo compacto para no alejar los golpes.
	var aporte_visual: float = clampf((radio_suma - 80.0) * 0.30, 0.0, 12.0)
	var masa_mayor: float = maxf(_masa_corporal(), otro._masa_corporal())
	var aporte_masa: float = clampf((masa_mayor - 1.0) * 4.0, 0.0, 3.0)
	var distancia: float = DISTANCIA_COMBO_AUTO_PUSH_MIN + aporte_visual + aporte_masa
	return clampf(distancia, DISTANCIA_COMBO_AUTO_PUSH_MIN, DISTANCIA_COMBO_AUTO_PUSH_MAX)


func _distancia_precontacto_adaptativa(otro: Fighter, atacante: Fighter = null) -> float:
	# Distancia preventiva de torso. Se calcula DESPUÉS de los chequeos de
	# hitbox del frame, así nunca reemplaza al impacto: sólo evita que, si todavía
	# no conectó, los centros corporales terminen prácticamente superpuestos.
	if not otro or not is_instance_valid(otro):
		return PRECONTACTO_MIN

	var radio_suma: float = _radio_corporal_visual() + otro._radio_corporal_visual()
	# La parte visual sólo aporta hasta 9 px. Aunque Kali tenga alas o Helena
	# cabello largo, esos elementos no pueden convertir la silueta completa en
	# una pared física.
	var aporte_visual: float = clampf((radio_suma - 82.0) * 0.22, 0.0, 9.0)
	var masa_mayor: float = maxf(_masa_corporal(), otro._masa_corporal())
	var aporte_masa: float = clampf((masa_mayor - 1.0) * 11.0, 0.0, 7.0)
	var altura_mayor: float = maxf(_altura_visible_objetivo(), otro._altura_visible_objetivo())
	var aporte_altura: float = clampf((altura_mayor / ALTURA_VISIBLE_NORMAL_GLOBAL - 1.0) * 24.0, 0.0, 4.0)

	var distancia: float = PRECONTACTO_MIN + aporte_visual + aporte_masa + aporte_altura
	# La patada tiene una caja frontal holgada desde 90.10.12; puede mantener un
	# poquito más de espacio de cadera sin perder contacto. Para puño no añadimos
	# bonus: preferimos conservar la sensación de corto alcance.
	if atacante and is_instance_valid(atacante) and atacante._atk_tipo == "patada":
		distancia += 1.5
	return clampf(distancia, PRECONTACTO_MIN, PRECONTACTO_MAX)


func _bonus_pushbox_pose_contacto(otro: Fighter) -> float:
	# Sólo corrige la proyección VISUAL después de un impacto confirmado.
	# Antes del contacto retorna 0, manteniendo intactos rango, hitbox y lunge.
	if not otro or not is_instance_valid(otro):
		return 0.0
	if en_combo_auto_visual or otro.en_combo_auto_visual:
		# CORE II/III ya comparte target adaptativo entre tween y pushbox; no
		# introducimos aquí una cifra distinta que haga pelear ambos sistemas.
		return 0.0

	var bonus: float = 0.0
	var yo_contacte: bool = fase_ataque != FaseAtaque.NINGUNA and _atk_ya_conecto
	var otro_contacto: bool = otro.fase_ataque != FaseAtaque.NINGUNA and otro._atk_ya_conecto

	if yo_contacte:
		bonus = maxf(bonus, PUSH_POSE_CONTACTO_PATADA if _atk_tipo == "patada" else PUSH_POSE_CONTACTO_PUNO)
	if otro_contacto:
		bonus = maxf(bonus, PUSH_POSE_CONTACTO_PATADA if otro._atk_tipo == "patada" else PUSH_POSE_CONTACTO_PUNO)
	if yo_contacte and otro_contacto:
		bonus += PUSH_POSE_CONTACTO_TRADE

	return clampf(bonus, 0.0, PUSH_POSE_CONTACTO_MAX)

func _distancia_minima_contextual(otro: Fighter = null) -> float:
	var minimo: float = DISTANCIA_MINIMA_LUCHADORES
	if otro and is_instance_valid(otro):
		var cuerpo_yo: float = ancho_cuerpo * _mult_cuerpo_actual()
		var cuerpo_otro: float = otro.ancho_cuerpo * otro._mult_cuerpo_actual()
		minimo = maxf(minimo, (cuerpo_yo + cuerpo_otro) * 0.54)
		# Esta es la pieza clave: si los PNG son visualmente anchos, la distancia
		# mínima crece lo suficiente para que los torsos no se tapen.
		minimo = maxf(minimo, _distancia_visual_entre_cuerpos(otro))
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
	# Durante el combo automático sí conservamos separación corporal.
	# Solo los posters/cinemáticas puras mantienen los cuerpos completamente fijos.
	if (en_secuencia_especial or otro.en_secuencia_especial) \
		and not (en_combo_auto_visual or otro.en_combo_auto_visual):
		return
	var dir: float = signf(otro.global_position.x - global_position.x)
	if dir == 0.0:
		dir = mirando if mirando != 0.0 else 1.0
	var actual: float = absf(otro.global_position.x - global_position.x)
	var combo_core_activo: bool = en_combo_auto_visual or otro.en_combo_auto_visual

	# 90.10.97 — durante la RÁFAGA CORE el defensor NO cede terreno. Antes esta
	# función agregaba hasta 4 px por impacto al receptor y luego el knockback de
	# recibir_dano() lo alejaba todavía más; el siguiente golpe tenía que perseguirlo.
	# Ahora el defensor conserva su X y sólo recolocamos al atacante a la distancia
	# exacta de combo. Las poses de golpe recibido siguen funcionando normalmente.
	if combo_core_activo:
		var atacante_combo: Fighter = self if en_combo_auto_visual else otro
		var defensor_combo: Fighter = otro if en_combo_auto_visual else self
		if atacante_combo and defensor_combo and is_instance_valid(atacante_combo) and is_instance_valid(defensor_combo):
			defensor_combo.velocity.x = 0.0
			defensor_combo.empuje_timer = 0.0
			defensor_combo.empuje_x = 0.0
			defensor_combo.empuje_pendiente_timer = 0.0
			defensor_combo.empuje_pendiente_fuerza = 0.0
			var dir_combo: float = signf(defensor_combo.global_position.x - atacante_combo.global_position.x)
			if dir_combo == 0.0:
				dir_combo = atacante_combo.mirando if atacante_combo.mirando != 0.0 else 1.0
			var distancia_lock: float = atacante_combo._distancia_combo_auto_adaptativa(defensor_combo)
			atacante_combo.global_position.x = defensor_combo.global_position.x - dir_combo * distancia_lock
			atacante_combo.velocity.x = 0.0
			atacante_combo._aplicar_limites_arena()
			defensor_combo._aplicar_limites_arena()
		return

	var separacion_objetivo: float
	if combo_core_activo:
		# 90.10.71 — usamos exactamente la misma distancia adaptativa que guía el
		# acercamiento del auto-combo. Así el tween y el pushbox dejan de pelearse
		# entre sí y los torsos grandes conservan aire visual entre impactos.
		separacion_objetivo = _distancia_combo_auto_adaptativa(otro)
		if bloqueado:
			separacion_objetivo = minf(separacion_objetivo + 4.0, DISTANCIA_COMBO_AUTO_PUSH_MAX + 4.0)
	else:
		# 90.10.16 — para golpes normales usamos torso lógico, no el ancho total
		# de alas/cabello/cola. El clamp evita tanto la superposición como el efecto
		# de "golpear desde lejos" en personajes visualmente muy anchos.
		separacion_objetivo = clampf(
			_distancia_minima_contextual(otro),
			CONTACTO_POST_GOLPE_MIN,
			CONTACTO_POST_GOLPE_MAX
		)
		# 90.10.72 — margen por pose SOLO post-impacto. Un puño proyecta menos
		# el torso que una patada; un trade puede sumar 2 px extra. Al ocurrir
		# después de _atk_ya_conecto, este margen jamás puede provocar un whiff.
		separacion_objetivo += _bonus_pushbox_pose_contacto(otro)
		if bloqueado:
			separacion_objetivo = maxf(separacion_objetivo, 98.0)
	var energia: float = clampf(fuerza / 320.0, 0.0, 1.0)
	# 90.10.74 — un impacto fuerte crea un microespacio REAL de decisión. Esto
	# ocurre después de confirmar el hit, por lo que jamás acorta el rango ni
	# genera whiffs. No se aplica en bloqueo ni en el auto-combo CORE: ahí ya
	# existen reglas propias de rebote/posición.
	var microespacio_extra: float = 0.0
	var microespacio_duracion: float = 0.0
	if not bloqueado and not combo_core_activo and fuerza >= MICROESPACIO_UMBRAL_FUERZA:
		var peso_micro: float = clampf((fuerza - MICROESPACIO_UMBRAL_FUERZA) / 150.0, 0.0, 1.0)
		if _atk_tipo == "patada":
			microespacio_extra = lerpf(MICROESPACIO_PATADA_EXTRA_MIN, MICROESPACIO_PATADA_EXTRA_MAX, peso_micro)
			microespacio_duracion = lerpf(0.030, MICROESPACIO_DUR_PATADA_MAX, peso_micro)
		else:
			microespacio_extra = lerpf(MICROESPACIO_PUNO_EXTRA_MIN, MICROESPACIO_PUNO_EXTRA_MAX, peso_micro)
			microespacio_duracion = lerpf(0.018, MICROESPACIO_DUR_PUNO_MAX, peso_micro)
		separacion_objetivo = minf(separacion_objetivo + microespacio_extra, MICROESPACIO_DISTANCIA_MAX)

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

		# Micro-rebote de cuerpos: cuando ya se invadieron visualmente, cada uno
		# recibe una pequeña velocidad opuesta. No es knockback de ataque; es
		# solamente la respuesta física de dos cuerpos que no pueden ocupar
		# el mismo lugar.
		var rebote_cuerpo: float = clampf(28.0 + penetracion * 1.10, 28.0, 92.0)
		if not combo_core_activo and not en_secuencia_especial and not otro.en_secuencia_especial:
			velocity.x = -dir * maxf(absf(velocity.x), rebote_cuerpo * 0.35)
			otro.velocity.x = dir * maxf(absf(otro.velocity.x), rebote_cuerpo)
	# Luego suma un microdesplazamiento instantáneo. En auto-combo lo reducimos
	# para que el siguiente ataque no tenga que perseguir un rival que ya se
	# alejó artificialmente antes de aplicar el knockback real.
	if combo_core_activo:
		otro.global_position.x += dir * minf(impulso_defensor, 4.0)
		global_position.x -= dir * minf(impulso_atacante, 1.0)
	else:
		otro.global_position.x += dir * impulso_defensor
		global_position.x -= dir * impulso_atacante

	# 90.10.16 — mantener brevemente esta distancia después del frame inicial.
	# Esto es lo que impide que el atacante vuelva a penetrar el torso durante
	# hit-stop/recovery. En combo CORE se conserva el contacto compacto.
	var dur_contacto: float = 0.045 if combo_core_activo else (CONTACTO_POST_GOLPE_DUR_PATADA if _atk_tipo == "patada" else CONTACTO_POST_GOLPE_DUR_PUNO)
	if not combo_core_activo and _bonus_pushbox_pose_contacto(otro) > 0.0:
		# Unas centésimas extra mantienen la lectura del contacto mientras la pose
		# extendida termina; no es hitstun y no ralentiza el control del jugador.
		dur_contacto += 0.018
	# El microespacio no congela al jugador: solo sostiene durante unas pocas
	# centésimas la abertura creada por el impacto. Al terminar, ambos recuperan
	# inmediatamente el footwork normal y pueden volver a entrar.
	dur_contacto += microespacio_duracion
	_activar_separacion_post_golpe(otro, separacion_objetivo, dur_contacto)

	# 90.10.14 — este método modifica posiciones directamente, por fuera de
	# move_and_slide(). Nunca dejar ese desplazamiento sin revalidar los bordes.
	_aplicar_limites_arena()
	otro._aplicar_limites_arena()

func _activar_separacion_post_golpe(otro: Fighter, distancia: float, duracion: float) -> void:
	if not otro or not is_instance_valid(otro):
		return
	contacto_post_golpe_distancia = maxf(contacto_post_golpe_distancia, distancia)
	contacto_post_golpe_timer = maxf(contacto_post_golpe_timer, duracion)
	otro.contacto_post_golpe_distancia = maxf(otro.contacto_post_golpe_distancia, distancia)
	otro.contacto_post_golpe_timer = maxf(otro.contacto_post_golpe_timer, duracion)

func _mantener_separacion_post_golpe(delta: float) -> void:
	if contacto_post_golpe_timer <= 0.0:
		contacto_post_golpe_distancia = 0.0
		return
	contacto_post_golpe_timer = maxf(0.0, contacto_post_golpe_timer - delta)
	if not objetivo or not is_instance_valid(objetivo):
		return
	if esta_derrotado or objetivo.esta_derrotado or derribo_especial_activo or objetivo.derribo_especial_activo:
		return
	if en_secuencia_especial or objetivo.en_secuencia_especial:
		return

	var dx: float = objetivo.global_position.x - global_position.x
	var dist: float = absf(dx)
	if dist <= 0.01:
		return
	var objetivo_dist: float = contacto_post_golpe_distancia
	if objetivo_dist <= 0.0 or dist >= objetivo_dist:
		return
	var dir: float = signf(dx)
	var penetracion: float = objetivo_dist - dist

	# El receptor del golpe cede más; si ambos están en estado neutro repartimos.
	var factor_yo: float = 0.5
	var factor_otro: float = 0.5
	if hitstun_timer > 0.0 and objetivo.hitstun_timer <= 0.0:
		factor_yo = 0.82
		factor_otro = 0.18
	elif objetivo.hitstun_timer > 0.0 and hitstun_timer <= 0.0:
		factor_yo = 0.18
		factor_otro = 0.82

	global_position.x -= dir * penetracion * factor_yo
	objetivo.global_position.x += dir * penetracion * factor_otro

	# Cortar únicamente velocidad que intenta volver a cerrar el espacio.
	# El knockback que se aleja del contacto permanece intacto.
	if signf(velocity.x) == dir:
		velocity.x = 0.0
	if signf(objetivo.velocity.x) == -dir:
		objetivo.velocity.x = 0.0

	_aplicar_limites_arena()
	objetivo._aplicar_limites_arena()

func _activar_cruce_aereo() -> void:
	if cruce_aereo_activo:
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado:
		return
	cruce_aereo_activo = true
	add_collision_exception_with(objetivo)
	objetivo.add_collision_exception_with(self)

func _terminar_cruce_aereo() -> void:
	if not cruce_aereo_activo:
		return
	cruce_aereo_activo = false
	if not objetivo or not is_instance_valid(objetivo):
		return
	# Si el otro sigue cruzando, o alguno está derribado/KO, la excepción debe
	# permanecer. El estado correspondiente la restaurará cuando sea seguro.
	if objetivo.cruce_aereo_activo or esta_derrotado or objetivo.esta_derrotado \
		or derribo_especial_activo or objetivo.derribo_especial_activo:
		return
	_restaurar_colision_con_rival()

# 90.10.13 — mientras un luchador está derribado/KO no debe quedar una
# colisión fantasma contra el rival. Usamos excepciones entre LOS DOS cuerpos
# (no desactivamos la CollisionShape), así el luchador sigue chocando con el
# suelo y los límites del escenario normalmente.
func _asegurar_pushbox_manual_con_rival() -> void:
	if not objetivo or not is_instance_valid(objetivo):
		_objetivo_pushbox_manual_id = 0
		return
	var oid: int = int(objetivo.get_instance_id())
	if _objetivo_pushbox_manual_id == oid:
		return
	add_collision_exception_with(objetivo)
	objetivo.add_collision_exception_with(self)
	_objetivo_pushbox_manual_id = oid
	objetivo._objetivo_pushbox_manual_id = int(get_instance_id())

func _ignorar_colision_con_rival() -> void:
	# Compatibilidad con derribos/cruce aéreo: desde 90.10.82 esta excepción
	# ya es permanente entre los dos Fighter. Se mantiene esta API porque
	# varias rutas antiguas la llaman, pero todas convergen al mismo estado.
	_asegurar_pushbox_manual_con_rival()


func _restaurar_colision_con_rival() -> void:
	# 90.10.82 — NO reactivar la colisión CharacterBody2D entre luchadores.
	# Reactivarla después de un salto/derribo volvía a mezclar dos resolutores
	# distintos (Godot + pushbox manual), origen del falso backdash asimétrico.
	_asegurar_pushbox_manual_con_rival()


# 90.10.13 — límites visuales para cuerpos derribados.
# El límite histórico protegía solamente el ORIGEN del CharacterBody2D. Una
# pose tumbada muy ancha podía tener el origen dentro de la arena pero todo el
# PNG fuera de pantalla. El cuerpo físico quedaba allí y se sentía como una
# "pared fantasma". Para derribos/KO calculamos también cuánto ocupa el alfa
# real del sprite y mantenemos la silueta visible dentro del escenario.
func _limites_arena_x_pose_actual() -> Vector2:
	var limite_izq: float = ARENA_LIMITE_IZQUIERDO
	var limite_der: float = ARENA_LIMITE_DERECHO
	if not (esta_derrotado or derribo_especial_activo):
		return Vector2(limite_izq, limite_der)
	if not sprite or not sprite.texture:
		return Vector2(limite_izq, limite_der)

	var rect: Rect2 = _obtener_rect_visual(sprite.texture)
	if rect.size.x <= 1.0:
		return Vector2(limite_izq, limite_der)

	var escala_x: float = absf(sprite.scale.x)
	var centro_tex: float = float(sprite.texture.get_width()) * 0.5
	var raw_izq: float = (rect.position.x - centro_tex) * escala_x
	var raw_der: float = (rect.position.x + rect.size.x - centro_tex) * escala_x
	var local_izq: float
	var local_der: float
	if sprite.flip_h:
		local_izq = sprite.position.x - raw_der
		local_der = sprite.position.x - raw_izq
	else:
		local_izq = sprite.position.x + raw_izq
		local_der = sprite.position.x + raw_der

	# Queremos que el alfa visible quede entre los mismos márgenes físicos de
	# la arena segura, no simplemente que el pivote quede allí.
	limite_izq = maxf(limite_izq, ARENA_LIMITE_IZQUIERDO - local_izq)
	limite_der = minf(limite_der, ARENA_LIMITE_DERECHO - local_der)

	# Resguardo para un PNG excepcionalmente ancho: nunca generar un rango
	# invertido. En ese caso lo centramos en el área jugable.
	if limite_izq > limite_der:
		var centro: float = (ARENA_LIMITE_IZQUIERDO + ARENA_LIMITE_DERECHO) * 0.5
		return Vector2(centro, centro)
	return Vector2(limite_izq, limite_der)


func _aplicar_limites_arena() -> void:
	# 90.10.14 — guardia dura del mundo. El CharacterBody2D nunca debe quedar
	# por debajo de la línea física del suelo ni fuera del rango horizontal,
	# incluso si otro luchador lo movió directamente, hubo hit-stop o un derribo.
	var x_anterior: float = global_position.x
	var y_anterior: float = global_position.y
	var limites_x: Vector2 = _limites_arena_x_pose_actual()
	global_position.x = clampf(global_position.x, limites_x.x, limites_x.y)

	# El origen del Fighter está en los pies. El piso físico está en Y=560,
	# así que cualquier valor mayor significa que el cuerpo salió por debajo.
	if global_position.y > SUELO_REFERENCIA_Y:
		global_position.y = SUELO_REFERENCIA_Y
		if velocity.y > 0.0:
			velocity.y = 0.0

	var cambio_x: bool = not is_equal_approx(global_position.x, x_anterior)
	var cambio_y: bool = not is_equal_approx(global_position.y, y_anterior)
	if not cambio_x and not cambio_y:
		return

	# Durante un derribo especial fuerte el cuerpo puede rebotar una vez contra
	# el borde horizontal antes de caer/deslizar. La corrección vertical nunca
	# genera rebote: solo recupera al luchador sobre el suelo válido.
	if cambio_x:
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

	# 91.05.16 — PASS 2P. En contacto NORMAL alternamos la lectura de capas:
	# 1er golpe = receptor delante, 2do = atacante delante, y así sucesivamente.
	# La paridad sale de combo_count, que ya forma parte de la simulación; no
	# agregamos azar ni estado nuevo. CORE II/III queda EXCLUIDO y conserva
	# exactamente su profundidad aprobada en PASS 2O.
	if objetivo and is_instance_valid(objetivo):
		var combo_core_activo: bool = en_combo_auto_visual or objetivo.en_combo_auto_visual
		var secuencia_especial_activa: bool = en_secuencia_especial or objetivo.en_secuencia_especial
		if not combo_core_activo and not secuencia_especial_activa:
			var yo_conecte_normal: bool = fase_ataque != FaseAtaque.NINGUNA \
				and _atk_ya_conecto and objetivo.hitstun_timer > 0.0
			var yo_recibo_normal: bool = hitstun_timer > 0.0 \
				and objetivo.fase_ataque != FaseAtaque.NINGUNA and objetivo._atk_ya_conecto

			# En un trade simultáneo dejamos la regla histórica; la alternancia sólo
			# gobierna un contacto limpio con un atacante y un receptor inequívocos.
			if yo_conecte_normal != yo_recibo_normal:
				var base_pareja: int = maxi(
					int(round(global_position.y / Z_BASE_Y_DIVISOR)),
					int(round(objetivo.global_position.y / Z_BASE_Y_DIVISOR))
				)
				var numero_golpe: int = combo_count if yo_conecte_normal else objetivo.combo_count
				var atacante_delante: bool = numero_golpe > 0 and (numero_golpe % 2 == 0)
				if yo_conecte_normal:
					z_index = base_pareja + (3 if atacante_delante else 1)
				else:
					z_index = base_pareja + (1 if atacante_delante else 3)
				return

	# Regla histórica intacta para aire, CORE, especiales, trades y cualquier
	# situación fuera del contacto normal limpio.
	if fase_ataque == FaseAtaque.ACTIVO:
		base_z += 1
	if hitstun_timer > 0.0:
		base_z += 2
	if en_secuencia_especial:
		base_z += 4
	z_index = base_z

func _aplicar_separacion_fisica() -> void:
	# 90.10.23 — durante el cruce del doble salto permitimos que los cuerpos se
	# atraviesen horizontalmente en el aire. Las hitboxes manuales siguen activas,
	# así todavía se pueden golpear; solo se elimina la pared física entre ambos.
	if cruce_aereo_activo:
		return
	if objetivo and is_instance_valid(objetivo) and objetivo.cruce_aereo_activo:
		return
	# 90.10.13 — un luchador tumbado/KO no participa en la separación corporal
	# preventiva. Si su pose quedó en el borde no puede seguir empujando al rival
	# con un cuerpo invisible. El suelo y los límites de arena siguen funcionando.
	if esta_derrotado or derribo_especial_activo:
		return
	if not objetivo or not is_instance_valid(objetivo) or objetivo.esta_derrotado or objetivo.derribo_especial_activo:
		return

	# 90.10.84 — RESOLUCIÓN ÚNICA POR PAREJA.
	# Antes ambos Fighter ejecutaban esta función. Aunque varios subcasos ya
	# evitaban doble corrección, seguían existiendo ventanas dependientes del
	# orden de proceso. Ahora el lado 0 es la autoridad del par y calcula
	# simétricamente tanto el movimiento de J1 como el de J2.
	if indice_lado_combate >= 0 and objetivo.indice_lado_combate >= 0:
		if indice_lado_combate > objetivo.indice_lado_combate:
			return
	else:
		# Fallback para escenas antiguas que todavía no asignan lado.
		if int(get_instance_id()) > int(objetivo.get_instance_id()):
			return

	# 90.10.70 — durante CORE II/III sí existe un PUSHBOX compacto. En 90.10.69
	# estos dos returns anulaban toda separación justo cuando el tween automático
	# acercaba al atacante, permitiendo que torsos grandes se fundieran. Desde
	# 90.10.71 el objetivo del combo y el pushbox usan la MISMA distancia adaptativa,
	# así no perdemos golpes ni generamos una corrección contradictoria.
	var combo_core_activo: bool = en_combo_auto_visual or objetivo.en_combo_auto_visual

	# Posters/recargas y otras cinemáticas puras siguen inmóviles. La excepción
	# es únicamente la racha automática de golpes, donde necesitamos pushbox.
	if (en_secuencia_especial or objetivo.en_secuencia_especial) and not combo_core_activo:
		return

	# 90.10.97 — PUSHBOX DE RÁFAGA CON DEFENSOR ANCLADO. El receptor del CORE
	# nunca absorbe la penetración: cualquier corrección espacial la hace el
	# atacante. Esto reproduce el ritmo que aparece naturalmente cuando el rival
	# está contra la pared, pero funciona en cualquier punto del escenario.
	if combo_core_activo:
		var atacante_core: Fighter = self if en_combo_auto_visual else objetivo
		var defensor_core: Fighter = objetivo if en_combo_auto_visual else self
		if atacante_core and defensor_core and is_instance_valid(atacante_core) and is_instance_valid(defensor_core):
			defensor_core.velocity.x = 0.0
			defensor_core.empuje_timer = 0.0
			defensor_core.empuje_x = 0.0
			defensor_core.empuje_pendiente_timer = 0.0
			defensor_core.empuje_pendiente_fuerza = 0.0
			var dx_core: float = defensor_core.global_position.x - atacante_core.global_position.x
			var dir_core: float = signf(dx_core)
			if dir_core == 0.0:
				dir_core = atacante_core.mirando if atacante_core.mirando != 0.0 else 1.0
			var distancia_core: float = atacante_core._distancia_combo_auto_adaptativa(defensor_core)
			if absf(dx_core) < distancia_core:
				atacante_core.global_position.x = defensor_core.global_position.x - dir_core * distancia_core
				atacante_core.velocity.x = 0.0
			atacante_core._aplicar_limites_arena()
			defensor_core._aplicar_limites_arena()
		return

	var dx := objetivo.global_position.x - global_position.x
	var dist := absf(dx)
	var yo_atacando: bool = fase_ataque != FaseAtaque.NINGUNA
	var otro_atacando: bool = objetivo.fase_ataque != FaseAtaque.NINGUNA

	# 90.10.87 — PUSHBOX NEUTRAL DURO Y SIMÉTRICO.
	# En neutral NO usamos ningún ancho de PNG, alas, pelo, pose de carrera ni
	# distancia visual contextual. El cuerpo físico base manda. Si sólo uno entra
	# contra el otro, se corrige exclusivamente AL QUE ENTRA; el defensor quieto
	# conserva exactamente su X mundial. Esto elimina de raíz el falso backdash
	# observado con Kali/Helena y Fang/Magnus en Versus Local.
	var neutral_puro: bool = not combo_core_activo \
		and not yo_atacando and not otro_atacando \
		and hitstun_timer <= 0.0 and objetivo.hitstun_timer <= 0.0 \
		and not bloqueando and not objetivo.bloqueando
	if neutral_puro:
		# 91.02.22 — el neutral conserva roce cercano, pero ya no permite que
		# los centros entren hasta 62 px. Usamos el mismo mínimo compacto de
		# precontacto que visualmente ya funciona durante los golpes normales.
		var distancia_neutral: float = maxf(DISTANCIA_MINIMA_LUCHADORES, PUSHBOX_NEUTRAL_DISTANCIA_MIN)
		if dist >= distancia_neutral:
			return
		var dir_neutral: float = signf(dx)
		# Resguardo extremadamente raro: si ambos centros coincidieron exactamente,
		# usamos la orientación para recuperar un lado estable en vez de dejar la
		# superposición congelada para siempre.
		if absf(dir_neutral) < 0.5:
			dir_neutral = mirando if mirando != 0.0 else 1.0
		var penetracion_neutral: float = distancia_neutral - dist
		var yo_hacia_rival_neutral: bool = (carrera_activa and carrera_direccion * dir_neutral > 0.0) \
			or velocity.x * dir_neutral > VELOCIDAD_NEUTRAL_EMPUJE_UMBRAL
		var otro_hacia_rival_neutral: bool = (objetivo.carrera_activa and objetivo.carrera_direccion * dir_neutral < 0.0) \
			or objetivo.velocity.x * dir_neutral < -VELOCIDAD_NEUTRAL_EMPUJE_UMBRAL

		if yo_hacia_rival_neutral and not otro_hacia_rival_neutral:
			# J1/self entra: self absorbe 100% de la corrección.
			global_position.x -= dir_neutral * penetracion_neutral
			velocity.x = 0.0
			if carrera_activa:
				_detener_carrera()
		elif otro_hacia_rival_neutral and not yo_hacia_rival_neutral:
			# J2/objetivo entra: objetivo absorbe 100% de la corrección.
			objetivo.global_position.x += dir_neutral * penetracion_neutral
			objetivo.velocity.x = 0.0
			if objetivo.carrera_activa:
				objetivo._detener_carrera()
		elif yo_hacia_rival_neutral and otro_hacia_rival_neutral:
			# Choque frontal real: reparto simétrico, no depende del orden de proceso.
			global_position.x -= dir_neutral * penetracion_neutral * 0.5
			objetivo.global_position.x += dir_neutral * penetracion_neutral * 0.5
			velocity.x = 0.0
			objetivo.velocity.x = 0.0
			if carrera_activa:
				_detener_carrera()
			if objetivo.carrera_activa:
				objetivo._detener_carrera()
		else:
			# 91.02.22 — RESCATE DE SOLAPAMIENTO RESIDUAL.
			# Antes, si un ataque/dash/cruce dejaba a los dos demasiado juntos y luego
			# ambos quedaban quietos, neutral retornaba sin corregir nada. El personaje
			# de menor z podía permanecer casi oculto detrás del otro indefinidamente.
			# Repartimos SOLO la penetración ilegal según masa; no empuja si ya existe
			# la distancia válida y no introduce una pared visual adicional.
			var masa_yo_neutral: float = maxf(_masa_corporal(), 0.55)
			var masa_otro_neutral: float = maxf(objetivo._masa_corporal(), 0.55)
			var suma_masa_neutral: float = masa_yo_neutral + masa_otro_neutral
			var factor_yo_neutral: float = masa_otro_neutral / suma_masa_neutral
			var factor_otro_neutral: float = masa_yo_neutral / suma_masa_neutral
			global_position.x -= dir_neutral * penetracion_neutral * factor_yo_neutral
			objetivo.global_position.x += dir_neutral * penetracion_neutral * factor_otro_neutral

		_aplicar_limites_arena()
		objetivo._aplicar_limites_arena()
		return

	var distancia_minima: float = _distancia_combo_auto_adaptativa(objetivo) if combo_core_activo else _distancia_minima_contextual(objetivo)

	# 90.10.72 — si ya hubo impacto confirmado, la pose extendida recibe un
	# margen pequeño adicional. Antes del impacto NO se suma: el bloque de
	# precontacto de abajo conserva exactamente la capacidad de entrar en rango.
	if not combo_core_activo:
		var bonus_pose_contacto: float = _bonus_pushbox_pose_contacto(objetivo)
		if bonus_pose_contacto > 0.0:
			distancia_minima += bonus_pose_contacto

	# 90.10.17 — contacto preventivo adaptativo. Conservamos la regla crítica
	# de 90.10.12: la separación NUNCA gana al golpe. Los chequeos de hitbox ya
	# ocurrieron antes de llegar acá; si aún no hubo impacto, evitamos solamente
	# que torso/cadera se fundan mientras el ataque entra en rango.
	if not combo_core_activo:
		if yo_atacando != otro_atacando:
			var atacante: Fighter = self if yo_atacando else objetivo
			if not atacante._atk_ya_conecto:
				# El hitbox de este frame YA tuvo prioridad. Recién después sostenemos
				# un precontacto de 80 px para que el lunge no funda ambos torsos.
				distancia_minima = minf(distancia_minima, _distancia_precontacto_adaptativa(objetivo, atacante))
				distancia_minima = maxf(distancia_minima, PUSHBOX_COMBATE_PRECONTACTO_MIN)
		elif yo_atacando and otro_atacando:
			# Dos ataques simultáneos conservan posibilidad de trade, pero no pueden
			# seguir penetrando por debajo del colchón compacto una vez evaluados sus
			# hitboxes del frame.
			if not _atk_ya_conecto and not objetivo._atk_ya_conecto:
				distancia_minima = minf(
					distancia_minima,
					minf(_distancia_precontacto_adaptativa(objetivo, self), PRECONTACTO_DOBLE_ATAQUE_MAX)
				)
				distancia_minima = maxf(distancia_minima, PUSHBOX_COMBATE_PRECONTACTO_MIN)

		# Después de un contacto real, durante hitstun o bloqueo, el rango ya no
		# necesita ganar al pushbox: aquí manda la legibilidad del torso.
		var contacto_corporal_confirmado: bool = _atk_ya_conecto or objetivo._atk_ya_conecto \
			or hitstun_timer > 0.0 or objetivo.hitstun_timer > 0.0 \
			or bloqueando or objetivo.bloqueando
		if contacto_corporal_confirmado:
			distancia_minima = maxf(distancia_minima, PUSHBOX_COMBATE_TORSO_MIN)

	if dist >= distancia_minima:
		return
	var dir: float = signf(dx)
	# 91.02.23 — si ambos centros llegaron exactamente al mismo X, no dejamos
	# congelada la fusión. Recuperamos un lado estable usando la orientación.
	if absf(dir) < 0.5:
		dir = mirando if mirando != 0.0 else 1.0
	var penetracion := distancia_minima - dist
	# Separación según masa real: el cuerpo liviano cede más y el pesado se
	# planta. Si alguien está aturdido o golpeando, todavía cede una porción adicional.
	var masa_yo: float = maxf(_masa_corporal(), 0.55)
	var masa_otro: float = maxf(objetivo._masa_corporal(), 0.55)
	var suma_masa: float = masa_yo + masa_otro
	var factor_yo: float = masa_otro / suma_masa
	var factor_objetivo: float = masa_yo / suma_masa

	# Prioridad del golpe sobre una caminata durante TODO el ciclo. Otro ATAQUE
	# conserva prioridad propia y puede entrar normalmente.

	if yo_atacando and not otro_atacando:
		factor_yo = 0.0
		factor_objetivo = 1.0
		# Si el rival caminaba hacia el atacante, cortar ese avance.
		if signf(objetivo.velocity.x) == -dir:
			objetivo.velocity.x = 0.0
	elif otro_atacando and not yo_atacando:
		factor_yo = 1.0
		factor_objetivo = 0.0
		if signf(velocity.x) == dir:
			velocity.x = 0.0
	elif yo_atacando and otro_atacando:
		# Trade real: repartimos la corrección por masa en vez de permitir que los
		# dos centros se crucen. No cancelamos velocidades aquí; el impacto/hitstop
		# conserva la prioridad si alguno de los dos conecta.
		pass
	elif hitstun_timer > 0.0:
		factor_yo = minf(0.78, factor_yo + 0.18)
		factor_objetivo = 1.0 - factor_yo
	elif objetivo.hitstun_timer > 0.0:
		factor_objetivo = minf(0.78, factor_objetivo + 0.18)
		factor_yo = 1.0 - factor_objetivo
	else:
		# 90.10.84 — prioridad explícita del DASH sobre cualquier velocidad residual.
		# Si un dash entra contra un rival quieto, SOLO el que hizo dash absorbe
		# la penetración. Además terminamos carrera_activa: antes velocity.x se
		# ponía a cero, pero el siguiente frame la carrera volvía a inyectar velocidad.
		var yo_dash_hacia_rival: bool = carrera_activa and carrera_direccion * dir > 0.0
		var otro_dash_hacia_rival: bool = objetivo.carrera_activa and objetivo.carrera_direccion * dir < 0.0
		if yo_dash_hacia_rival and not otro_dash_hacia_rival:
			factor_yo = 1.0
			factor_objetivo = 0.0
			_detener_carrera()
			velocity.x = 0.0
		elif otro_dash_hacia_rival and not yo_dash_hacia_rival:
			factor_yo = 0.0
			factor_objetivo = 1.0
			objetivo._detener_carrera()
			objetivo.velocity.x = 0.0
		elif yo_dash_hacia_rival and otro_dash_hacia_rival:
			# Dos dashes frontales se encuentran en el borde del pushbox.
			_detener_carrera()
			objetivo._detener_carrera()
			velocity.x = 0.0
			objetivo.velocity.x = 0.0
		else:
			# Caminata/avance normal: el rival quieto queda anclado. Si ambos
			# avanzan uno contra otro se reparte por masa, como antes.
			var yo_hacia_rival: bool = velocity.x * dir > VELOCIDAD_NEUTRAL_EMPUJE_UMBRAL
			var otro_hacia_rival: bool = objetivo.velocity.x * dir < -VELOCIDAD_NEUTRAL_EMPUJE_UMBRAL
			if yo_hacia_rival and not otro_hacia_rival:
				factor_yo = 1.0
				factor_objetivo = 0.0
				velocity.x = 0.0
			elif otro_hacia_rival and not yo_hacia_rival:
				factor_yo = 0.0
				factor_objetivo = 1.0
				objetivo.velocity.x = 0.0
			elif yo_hacia_rival and otro_hacia_rival:
				velocity.x = 0.0
				objetivo.velocity.x = 0.0
			else:
				# No hay presión neutral: no existe nada que resolver.
				return

	global_position.x -= dir * penetracion * factor_yo
	objetivo.global_position.x += dir * penetracion * factor_objetivo

	# 91.02.23 — un defensor contra el borde puede no tener espacio para absorber
	# el 100 % de la separación. Primero respetamos arena y luego trasladamos el
	# residuo al otro cuerpo. Así el atacante tampoco puede enterrarse en el torso
	# de un rival acorralado.
	_aplicar_limites_arena()
	objetivo._aplicar_limites_arena()
	var dx_post: float = objetivo.global_position.x - global_position.x
	var dist_post: float = absf(dx_post)
	if dist_post < distancia_minima - 0.01:
		var dir_post: float = signf(dx_post)
		if absf(dir_post) < 0.5:
			dir_post = dir
		var faltante: float = distancia_minima - dist_post
		var limites_yo_post: Vector2 = _limites_arena_x_pose_actual()
		var limites_otro_post: Vector2 = objetivo._limites_arena_x_pose_actual()
		var capacidad_yo: float
		var capacidad_otro: float
		if dir_post > 0.0:
			capacidad_yo = maxf(0.0, global_position.x - limites_yo_post.x)
			capacidad_otro = maxf(0.0, limites_otro_post.y - objetivo.global_position.x)
		else:
			capacidad_yo = maxf(0.0, limites_yo_post.y - global_position.x)
			capacidad_otro = maxf(0.0, objetivo.global_position.x - limites_otro_post.x)

		var mover_yo: float = minf(faltante * factor_yo, capacidad_yo)
		var mover_otro: float = minf(faltante * factor_objetivo, capacidad_otro)
		var restante: float = maxf(0.0, faltante - mover_yo - mover_otro)

		# Si la prioridad original apuntaba al luchador que ya no tiene espacio,
		# el lado libre absorbe el resto sin alterar knockback ni velocidades.
		if restante > 0.0:
			var extra_otro: float = minf(restante, maxf(0.0, capacidad_otro - mover_otro))
			mover_otro += extra_otro
			restante -= extra_otro
		if restante > 0.0:
			var extra_yo: float = minf(restante, maxf(0.0, capacidad_yo - mover_yo))
			mover_yo += extra_yo

		global_position.x -= dir_post * mover_yo
		objetivo.global_position.x += dir_post * mover_otro
		_aplicar_limites_arena()
		objetivo._aplicar_limites_arena()

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

# True cuando el impulso actual se aleja del rival manteniendo la mirada
# hacia él. Eso distingue visualmente dash de entrada y evasión/backdash.
func _es_backdash_activo() -> bool:
	var dir_dash: float = carrera_direccion if carrera_activa else (dash_aereo_direccion if dash_aereo_activo else 0.0)
	return dir_dash != 0.0 and mirando != 0.0 and dir_dash * mirando < 0.0

func _tex_evasion() -> Texture2D:
	if en_fase_absoluta and textura_furia_evasion:
		return textura_furia_evasion
	return textura_evasion

# Pose dedicada para la aceleración por doble toque. Hacia el rival usa
# carrera/dash; alejándose usa EVASIÓN si existe. Si falta el PNG dedicado,
# conserva el fallback anterior para no romper ningún personaje.
func _tex_carrera() -> Texture2D:
	if _es_backdash_activo():
		var evasion := _tex_evasion()
		if evasion:
			return evasion
	if en_fase_absoluta and textura_furia_carrera:
		return textura_furia_carrera
	return textura_carrera

# Prioridad: bloqueo > aire > aceleración > caminata > parado.
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
