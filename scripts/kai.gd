class_name Kai

extends Fighter

func _init() -> void:
    nombre_luchador = "Kai"

    color_base = Color(0.55, 0.25, 0.85)
    color_fase = Color(0.85, 0.45, 1.0)

    velocidad = 336.0
    fuerza_salto = -432.0
    gravedad = 1190.0
    aceleracion = 3245.0
    friccion_suelo = 3402.0
    friccion_aire = 1350.0
    peso_golpe = 1.05
    escala_sprite = 0.6125

    # ============================================================
    # KAI REDISEÑO FINAL — MOVIMIENTOS NUEVOS
    # CORE / ESPECIAL / ABSOLUTO NO SE MODIFICAN.
    # ============================================================
    const KAI_NEW := "res://assets/kai_redesign_final/"

    # Pose normal
    textura_parado = load(KAI_NEW + "parado.png")

    # 90.10.65 — 6 puños normales en total.
    # Se agrega un nuevo puño al repertorio normal y se deja intercalado
    # entre los anteriores para que no caigan poses demasiado parecidas seguidas.
    textura_punetazo = load(KAI_NEW + "punetazo_1.png")
    texturas_punetazo_extra = [
        load(KAI_NEW + "punetazo_2.png"),
        load(KAI_NEW + "punetazo_3.png"),
        load(KAI_NEW + "punetazo_6_90_10_65.png"),
        load(KAI_NEW + "punetazo_4.png"),
        load(KAI_NEW + "punetazo_5.png"),
    ]

    # 90.10.65 — 7 patadas normales en total.
    # Se suman rodillazo y patada alta/lateral y se intercalan para abrir mejor la variedad.
    textura_patada = load(KAI_NEW + "patada_1.png")
    texturas_patada_extra = [
        load(KAI_NEW + "patada_2.png"),
        load(KAI_NEW + "patada_6_rodillazo_90_10_65.png"),
        load(KAI_NEW + "patada_3.png"),
        load(KAI_NEW + "patada_4.png"),
        load(KAI_NEW + "patada_7_90_10_65.png"),
        load(KAI_NEW + "patada_5.png"),
    ]

    # 4 reacciones diferentes
    textura_golpe_recibido = load(KAI_NEW + "golpe_recibido_1.png")
    texturas_golpe_recibido_extra = [
        load(KAI_NEW + "golpe_recibido_2.png"),
        load(KAI_NEW + "golpe_recibido_3.png"),
        load(KAI_NEW + "golpe_recibido_4.png"),
    ]

    textura_derribado = load(KAI_NEW + "derribado.png")

    # Movimiento
    texturas_caminata = [
        load(KAI_NEW + "caminata_1.png"),
        load(KAI_NEW + "caminata_2.png"),
    ]
    textura_salto = load(KAI_NEW + "salto.png")
    textura_doble_salto = load(KAI_NEW + "doble_salto.png")
    textura_descenso = load(KAI_NEW + "descenso.png")
    textura_bloqueo = load(KAI_NEW + "bloqueo.png")
    textura_carrera = load(KAI_NEW + "carrera.png")

    # Recarga y victoria
    textura_recarga = load(KAI_NEW + "recarga.png")
    textura_victoria = load(KAI_NEW + "victoria.png")

    # ============================================================
    # CORE / GIGANTOGRAFÍA: SE CONSERVAN EXACTAMENTE.
    # ============================================================
    textura_especial = load("res://assets/kai/especial.png")
    textura_absoluto = load("res://assets/kai/absoluto.png")

    # El remate corporal SÍ usa el rediseño nuevo.
    textura_rematador = load(KAI_NEW + "rematador.png")

    # ============================================================
    # MODO FURIA — 9 golpes visuales totales
    # Se integran 3 golpes nuevos del combo final (1 puño + 2 patadas)
    # sin tocar los Core ni las gigantografías ya existentes.
    # ============================================================
    textura_furia_parado = load(KAI_NEW + "parado.png")

    textura_furia_punetazo = load(KAI_NEW + "furia_punetazo_1.png")
    texturas_furia_punetazo_extra = [
        load(KAI_NEW + "furia_punetazo_2.png"),
        load(KAI_NEW + "furia_punetazo_3.png"),
        load(KAI_NEW + "furia_punetazo_4_90_10_65.png"),
    ]

    textura_furia_patada = load(KAI_NEW + "furia_patada_1.png")
    texturas_furia_patada_extra = [
        load(KAI_NEW + "furia_patada_2.png"),
        load(KAI_NEW + "furia_patada_4_90_10_65.png"),
        load(KAI_NEW + "furia_patada_3.png"),
        load(KAI_NEW + "furia_patada_5_90_10_65.png"),
    ]

    # Nunca volver al arte viejo mientras está en Furia.
    textura_furia_golpe_recibido = load(KAI_NEW + "golpe_recibido_1.png")
    textura_furia_derribado = load(KAI_NEW + "derribado.png")

    texturas_furia_caminata = [
        load(KAI_NEW + "caminata_1.png"),
        load(KAI_NEW + "caminata_2.png"),
    ]

    textura_furia_salto = load(KAI_NEW + "salto.png")
    textura_furia_doble_salto = load(KAI_NEW + "doble_salto.png")
    textura_furia_descenso = load(KAI_NEW + "descenso.png")
    textura_furia_bloqueo = load(KAI_NEW + "bloqueo.png")
    textura_furia_carrera = load(KAI_NEW + "furia_carrera.png")

    # 91.02.50 — PASS 12G / PROYECTIL TANDA 1 — KAI.
    # Misma arquitectura certificada con Helena: ↓ → + PUÑO.
    proyectil_especial_habilitado = true
    textura_proyectil_pose = load(KAI_NEW + "poder_proyectil.png")
    textura_proyectil_nucleo = load(KAI_NEW + "proyectil_oficial.png")
    proyectil_pose_escala_mult = 1.06
    color_proyectil_primario = Color(0.46, 0.08, 0.92, 1.0)
    color_proyectil_secundario = Color(0.92, 0.74, 1.0, 1.0)
    proyectil_velocidad = 805.0
    proyectil_dano_mult = 0.86
    proyectil_empuje = 148.0
    proyectil_hitstun = 0.22
    proyectil_startup = 0.16
    proyectil_recovery = 0.30
    proyectil_cooldown = 0.62
    # Reutiliza el sonido de salida aprobado con Helena.
    sonido_proyectil_impacto = load("res://assets/helena/proyectil_impacto.wav")


func _procesar_entrada(_delta: float, vel_actual: float) -> void:
    if controlado_por_jugador:
        _entrada_jugador(vel_actual)
        return

    _comportamiento_ia_basico(_delta, vel_actual, 90.0, 300.0)

    if poder >= poder_maximo:
        intentar_poder_especial()


func _ejecutar_especial() -> void:
    _efecto_estallido(Color(0.85, 0.45, 1.0, 0.85), 160.0, 30.0)
