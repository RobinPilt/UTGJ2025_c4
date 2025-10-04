# res://scripts/minigame/PlayerShip.gd
extends CharacterBody2D

@export var base_speed: float = 260.0

var viewport_size: Vector2 = Vector2.ZERO

func _ready() -> void:
    add_to_group("player")
    viewport_size = get_viewport_rect().size

func _physics_process(delta: float) -> void:
    var input_vec := Vector2.ZERO
    input_vec.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    input_vec.y = Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
    input_vec = input_vec.normalized()

    velocity = input_vec * base_speed
    move_and_slide()

    # Clamp inside window (simple, no camera yet)
    position.x = clamp(position.x, 0.0, viewport_size.x)
    position.y = clamp(position.y, 0.0, viewport_size.y)