extends Node

# CORE AWAKENED 90.10.33 — GAMEPAD UI + CINEMÁTICAS
# Mantiene A/Cross como aceptar y B/Circle como volver en toda la UI.
# Además traduce A a Enter sólo dentro de las dos secuencias narrativas,
# porque esos scripts antiguos aceptan teclado/click/toque pero no joypad.

const INTROS_SALTAR := [
	"res://scenes/IntroHistoria.tscn",
	"res://scenes/IntroBatalla.tscn",
]

func _ready() -> void:
	_agregar_boton_si_falta("ui_accept", JOY_BUTTON_A)
	_agregar_boton_si_falta("ui_cancel", JOY_BUTTON_B)

func _input(event: InputEvent) -> void:
	if not (event is InputEventJoypadButton):
		return
	var boton := event as InputEventJoypadButton
	if not boton.pressed or boton.button_index != JOY_BUTTON_A:
		return
	var escena := get_tree().current_scene
	if escena == null or not (escena.scene_file_path in INTROS_SALTAR):
		return
	# La intro ya sabe saltar con cualquier InputEventKey. Inyectar Enter evita
	# duplicar/transcribir su lógica y mantiene exactamente el mismo fade de salida.
	var enter := InputEventKey.new()
	enter.keycode = KEY_ENTER
	enter.physical_keycode = KEY_ENTER
	enter.pressed = true
	Input.parse_input_event(enter)

func _agregar_boton_si_falta(accion: StringName, boton: JoyButton) -> void:
	if not InputMap.has_action(accion):
		InputMap.add_action(accion)

	var evento := InputEventJoypadButton.new()
	evento.device = -1
	evento.button_index = boton
	evento.pressed = true

	if not InputMap.action_has_event(accion, evento):
		InputMap.action_add_event(accion, evento)
