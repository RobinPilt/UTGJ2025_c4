extends CharacterBody2D

@export var base_speed: float = 260.0
@export var acceleration: float = 2000.0
@export var friction: float = 600.0

var current_velocity: Vector2 = Vector2.ZERO
var viewport_size: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	viewport_size = get_viewport_rect().size

func _physics_process(delta: float) -> void:
	var input_vec: Vector2 = Vector2.ZERO
	input_vec.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vec.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vec = input_vec.normalized()

	# Apply acceleration toward input direction
	if input_vec != Vector2.ZERO:
		current_velocity = current_velocity.move_toward(input_vec * base_speed, acceleration * delta)
	else:
		# Apply friction when no input
		current_velocity = current_velocity.move_toward(Vector2.ZERO, friction * delta)

	velocity = current_velocity
	move_and_slide()

	# Clamp inside window (simple, no camera yet)
	position.x = clamp(position.x, 0.0, viewport_size.x)
	position.y = clamp(position.y, 0.0, viewport_size.y)
