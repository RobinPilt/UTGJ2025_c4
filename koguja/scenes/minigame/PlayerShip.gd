extends CharacterBody2D

@export var base_speed: float = 260.0
@export var acceleration: float = 2000.0
@export var friction: float = 600.0

@export var max_tilt_angle: float = 0.3  # ~17 degrees in radians
@export var tilt_speed: float = 5.0      # How fast the ship tilts

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

    # Tilt the ship based on horizontal input
    var target_tilt = input_vec.x * max_tilt_angle
    rotation = lerp(rotation, target_tilt, tilt_speed * delta)

# Called by Heart when collected
func collect_heart(value: int = 1) -> void:
    if get_parent().has_method("on_heart_collected"):
        get_parent().on_heart_collected(value)