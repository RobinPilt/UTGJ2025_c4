# res://scripts/minigame/obstacle.gd
extends Area2D

@export var speed: float = 180.0
@export var acceleration: float = 0.0
@export var direction: Vector2 = Vector2.DOWN
@export var angular_speed: float = 0.0
@export var life_time: float = 10.0
@export var start_delay: float = 0.0
@export var homing: bool = false
@export var homing_turn_rate: float = 0.0
@export var damage: int = 1

# --- New: custom bounds support ---
@export var use_custom_bounds: bool = false
var bounds_min: Vector2 = Vector2.ZERO
var bounds_max: Vector2 = Vector2.ZERO
@export var kill_margin: float = 48.0

var _time_alive: float = 0.0
var _player: Node2D = null
var _viewport_margin: float = 48.0

func _ready() -> void:
	direction = direction.normalized()
	body_entered.connect(_on_body_entered)
	_player = _get_player()

func _physics_process(delta: float) -> void:
	_time_alive += delta
	if _time_alive >= life_time:
		queue_free()
		return

	if start_delay > 0.0:
		start_delay -= delta
		return

	if homing and is_instance_valid(_player):
		var desired_angle := (_player.global_position - global_position).angle()
		var current_angle := direction.angle()
		var angle_diff := wrapf(desired_angle - current_angle, -PI, PI)
		var max_step := homing_turn_rate * delta
		var step = clamp(angle_diff, -max_step, max_step)
		direction = direction.rotated(step).normalized()

	if angular_speed != 0.0:
		direction = direction.rotated(angular_speed * delta).normalized()

	if acceleration != 0.0:
		speed = max(0.0, speed + acceleration * delta)

	position += direction * speed * delta

	# --- Despawn bounds ---
	if use_custom_bounds:
		if position.x < bounds_min.x - kill_margin \
		or position.x > bounds_max.x + kill_margin \
		or position.y < bounds_min.y - kill_margin \
		or position.y > bounds_max.y + kill_margin:
			queue_free()
	else:
		var size := get_viewport_rect().size
		if position.y < -_viewport_margin \
		or position.y > size.y + _viewport_margin \
		or position.x < -_viewport_margin \
		or position.x > size.x + _viewport_margin:
			queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.get_parent().has_method("on_player_hit"):
			body.get_parent().on_player_hit()
		queue_free()

func _get_player() -> Node2D:
	var arr = get_tree().get_nodes_in_group("player")
	if arr.size() > 0:
		return arr[0] as Node2D
	return null
