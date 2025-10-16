# res://scripts/minigame/PlayerShip.gd
extends CharacterBody2D

@export var base_speed: float = 260.0
@export var acceleration: float = 2000.0
@export var friction: float = 600.0

@export var max_tilt_angle: float = 0.3  # ~17 degrees in radians
@export var tilt_speed: float = 5.0      # How fast the ship tilts

# Clamp padding inside the playfield so the ship doesn't clip walls
@export var clamp_padding: float = 12.0

# Assign this to your Spawner node in the scene tree (e.g., $Spawner)
@export var spawner_path: NodePath

var current_velocity: Vector2 = Vector2.ZERO
var viewport_size: Vector2 = Vector2.ZERO

# Cached references/state
var _spawner: Node = null
var _fallback_playfield: Rect2 = Rect2()  # Used if spawner is missing

func _ready() -> void:
    add_to_group("player")
    viewport_size = get_viewport_rect().size

    if spawner_path != NodePath():
        _spawner = get_node_or_null(spawner_path)

    var vp: Viewport = get_viewport()
    if vp:
        vp.size_changed.connect(_on_viewport_resized)

    _update_fallback_playfield()

    # Set start position: center bottom of playfield
    var r: Rect2 = _get_playfield_rect()
    global_position = Vector2(
        r.position.x + r.size.x * 0.5,
        r.position.y + r.size.y * 0.85  # 0.85 is near the bottom, adjust as needed
    )

    _clamp_to_playfield()

func _on_viewport_resized() -> void:
    viewport_size = get_viewport_rect().size
    _update_fallback_playfield()

func _physics_process(delta: float) -> void:
    # --- Input ---
    var input_vec: Vector2 = Vector2.ZERO
    var right_strength: float = Input.get_action_strength("move_right")
    var left_strength: float = Input.get_action_strength("move_left")
    var down_strength: float = Input.get_action_strength("move_down")
    var up_strength: float = Input.get_action_strength("move_up")
    input_vec.x = right_strength - left_strength
    input_vec.y = down_strength - up_strength
    input_vec = input_vec.normalized()

    # --- Velocity ---
    if input_vec != Vector2.ZERO:
        current_velocity = current_velocity.move_toward(input_vec * base_speed, acceleration * delta)
    else:
        current_velocity = current_velocity.move_toward(Vector2.ZERO, friction * delta)

    velocity = current_velocity
    move_and_slide()

    # --- Clamp inside the playfield (global space to match playfield_rect) ---
    _clamp_to_playfield()

    # --- Tilt for feedback ---
    var target_tilt: float = input_vec.x * max_tilt_angle
    # Smoothly interpolate current rotation toward the target tilt
    rotation = lerp(rotation, target_tilt, tilt_speed * delta)

# Called by Heart when collected
func collect_heart(value: int = 1) -> void:
    if get_parent().has_method("on_heart_collected"):
        get_parent().on_heart_collected(value)

# --------------------------
# Playfield helpers
# --------------------------
func _get_playfield_rect() -> Rect2:
    # If a spawner is linked and exposes playfield_rect, use that
    if _spawner != null:
        var v: Variant = _spawner.get("playfield_rect")
        if typeof(v) == TYPE_RECT2:
            return v
    # Fallback: center 60% width, full height
    return _fallback_playfield

func _update_fallback_playfield() -> void:
    var width_ratio: float = 0.6
    var w: float = viewport_size.x * width_ratio
    var x: float = (viewport_size.x - w) * 0.5
    _fallback_playfield = Rect2(Vector2(x, 0.0), Vector2(w, viewport_size.y))

func _clamp_to_playfield() -> void:
    var r: Rect2 = _get_playfield_rect()
    var minp: Vector2 = r.position + Vector2(clamp_padding, clamp_padding)
    var maxp: Vector2 = r.position + r.size - Vector2(clamp_padding, clamp_padding)
    # Use global_position so it matches the playfield’s global rect
    global_position = global_position.clamp(minp, maxp)