class_name Dummy
extends CharacterBody2D

const TIEMPO_RESPAWN := 2.0

var vida_maxima := 100.0
var vida := 100.0
var visual: Polygon2D
var flash_timer := 0.0
var tiempo_reaparicion := 0.0

func _ready() -> void:
	var colision := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = Vector2(42, 75)
	colision.shape = forma
	colision.position = Vector2(0, -37.5)
	add_child(colision)

	visual = Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(-21, -75), Vector2(21, -75), Vector2(21, 0), Vector2(-21, 0)
	])
	visual.color = Color(0.5, 0.5, 0.5)
	add_child(visual)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += 1200.0 * delta
	else:
		velocity.y = 0.0
	velocity.x = 0.0
	move_and_slide()

	if flash_timer > 0.0:
		flash_timer -= delta
		if flash_timer <= 0.0 and vida > 0.0:
			visual.color = Color(0.5, 0.5, 0.5)

	if vida <= 0.0:
		tiempo_reaparicion -= delta
		if tiempo_reaparicion <= 0.0:
			_reaparecer()

func recibir_dano(cantidad: float) -> void:
	if vida <= 0.0:
		return
	vida = max(0.0, vida - cantidad)
	visual.color = Color(1.0, 0.2, 0.2)
	flash_timer = 0.12
	if vida <= 0.0:
		_derrotado()

func _derrotado() -> void:
	visual.color = Color(0.25, 0.25, 0.25)
	tiempo_reaparicion = TIEMPO_RESPAWN

func _reaparecer() -> void:
	vida = vida_maxima
	visual.color = Color(0.5, 0.5, 0.5)
