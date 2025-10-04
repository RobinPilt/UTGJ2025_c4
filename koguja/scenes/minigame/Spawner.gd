# res://scripts/minigame/Spawner.gd
extends Node2D

signal spawned_heart(heart: Node2D)
signal spawned_obstacle(obstacle: Node2D)

@export var heart_scene: PackedScene
@export var obstacle_scene: PackedScene

@export var heart_interval: float = 0.8
@export var spawn_margin: float = 24.0

@export var autostart: bool = false
@export var difficulty: String = "easy"   # "easy" | "normal" | "hard"

# --- New: playfield binding ---
@export var playfield_control: NodePath     # Assign this to your PlayfieldOverlay (Control)
var _playfield: Control = null
var playfield_rect: Rect2 = Rect2()         # Global-space rect of the bullet area

var viewport_size: Vector2 = Vector2.ZERO
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _running: bool = false

@onready var heart_timer: Timer = $HeartTimer

func _ready() -> void:
    _rng.randomize()

    # Keep viewport_size up to date
    _on_viewport_resized()
    var vp: Viewport = get_viewport()
    if vp:
        vp.size_changed.connect(_on_viewport_resized)

    # Bind to the playfield control if provided
    if playfield_control != NodePath():
        _playfield = get_node_or_null(playfield_control) as Control
        if _playfield:
            # Control emits 'resized' in Godot 4.x
            _playfield.resized.connect(_update_playfield_rect)

    _update_playfield_rect()

    # Hearts use a simple timer
    heart_timer.wait_time = heart_interval
    heart_timer.timeout.connect(_spawn_heart)

    if autostart:
        start(difficulty)

func _on_viewport_resized() -> void:
    viewport_size = get_viewport_rect().size
    _update_playfield_rect()

func _update_playfield_rect() -> void:
    #if _playfield:
        # Compute the global rect from the Control
        # var p: Vector2 = _playfield.global_position
        # var s: Vector2 = _playfield.size
        # playfield_rect = Rect2(p, s)
    #else:
        # Fallback: center 60% width, full height
    var width_ratio: float = 0.5
    var w: float = viewport_size.x * width_ratio
    var x: float = (viewport_size.x - w) * 0.5
    playfield_rect = Rect2(Vector2(x, 0.0), Vector2(w, viewport_size.y))

func start(diff: String = "easy") -> void:
    if _running:
        return
    difficulty = diff
    _running = true
    heart_timer.start()
    call_deferred("_run_timeline")

func stop() -> void:
    _running = false
    if heart_timer:
        heart_timer.stop()
    # Optional cleanup:
    # for c in get_children():
    #     if c is Area2D:
    #         c.queue_free()

func set_difficulty(diff: String) -> void:
    difficulty = diff

# --------------------------
# HEARTS
# --------------------------
func _spawn_heart() -> void:
    if heart_scene == null:
        return
    var h: Node2D = heart_scene.instantiate() as Node2D
    var x_min: float = playfield_rect.position.x + spawn_margin
    var x_max: float = playfield_rect.position.x + playfield_rect.size.x - spawn_margin
    var x: float = _rng.randf_range(x_min, x_max)
    # Spawn just above the playfield top so they fall in
    var y: float = playfield_rect.position.y - 16.0
    h.position = Vector2(x, y)
    add_child(h)
    spawned_heart.emit(h)

# --------------------------
# BULLET HELPERS
# --------------------------
func _spawn_bullet(pos: Vector2, dir: Vector2, speed: float, params: Dictionary = {}) -> Node2D:
    if obstacle_scene == null:
        return null
    var b: Area2D = obstacle_scene.instantiate() as Area2D

    # Required props (defined in obstacle.gd)
    b.position = pos
    b.direction = dir.normalized()
    b.speed = speed

    # Optional
    if params.has("acceleration"):     b.acceleration = params["acceleration"]
    if params.has("angular_speed"):    b.angular_speed = params["angular_speed"]
    if params.has("life_time"):        b.life_time = params["life_time"]
    if params.has("start_delay"):      b.start_delay = params["start_delay"]
    if params.has("homing"):           b.homing = params["homing"]
    if params.has("homing_turn_rate"): b.homing_turn_rate = params["homing_turn_rate"]
    if params.has("damage"):           b.damage = params["damage"]

    # --- New: give bullets custom despawn bounds matching the playfield ---
    if "use_custom_bounds" in b:
        b.use_custom_bounds = true
    if "bounds_min" in b and "bounds_max" in b:
        b.bounds_min = playfield_rect.position
        b.bounds_max = playfield_rect.position + playfield_rect.size

    add_child(b)
    spawned_obstacle.emit(b)
    return b

func _player_or_center(center_fallback: Vector2) -> Vector2:
    var arr: Array = get_tree().get_nodes_in_group("player")
    if arr.size() > 0 and arr[0] is Node2D:
        return (arr[0] as Node2D).global_position
    return center_fallback

func _aim_angle(from_pos: Vector2) -> float:
    var target: Vector2 = _player_or_center(playfield_rect.position + playfield_rect.size * 0.5)
    return (target - from_pos).angle()

func _timer(wait: float) -> Signal:
    var wait_time: float = wait if wait > 0.0 else 0.0
    return get_tree().create_timer(wait_time).timeout

# --------------------------
# DIFFICULTY CURVES (unchanged)
# --------------------------
func _cfg() -> Dictionary:
    if difficulty == "easy":
        return {
            "speed": 160.0, "ring_count": 16, "spiral_rate": 8.0, "spiral_step_deg": 12.0,
            "spread_ways": 3, "spread_angle_deg": 36.0, "homing_turn": 0.0
        }
    elif difficulty == "normal":
        return {
            "speed": 200.0, "ring_count": 24, "spiral_rate": 12.0, "spiral_step_deg": 10.0,
            "spread_ways": 5, "spread_angle_deg": 50.0, "homing_turn": 0.8
        }
    elif difficulty == "hard":
        return {
            "speed": 240.0, "ring_count": 32, "spiral_rate": 16.0, "spiral_step_deg": 8.0,
            "spread_ways": 7, "spread_angle_deg": 70.0, "homing_turn": 1.4
        }
    return {
        "speed": 160.0, "ring_count": 16, "spiral_rate": 8.0, "spiral_step_deg": 12.0,
        "spread_ways": 3, "spread_angle_deg": 36.0, "homing_turn": 0.0
    }

# --------------------------
# PATTERN PRIMITIVES (now use playfield_rect)
# --------------------------
func _pattern_ring(center: Vector2, count: int, speed: float, start_angle: float = 0.0, spread: float = TAU, params: Dictionary = {}) -> void:
    var denom: int = count if count > 1 else 1
    for i in range(count):
        var t: float = (spread * float(i) / float(denom)) + start_angle
        var dir: Vector2 = Vector2.RIGHT.rotated(t)
        _spawn_bullet(center, dir, speed, params)

func _pattern_aimed_spread(origin: Vector2, ways: int, angle_deg: float, speed: float, params: Dictionary = {}) -> void:
    var base_angle: float = _aim_angle(origin)
    var spread_rad: float = deg_to_rad(angle_deg)
    if ways <= 1:
        _spawn_bullet(origin, Vector2.RIGHT.rotated(base_angle), speed, params)
        return
    var start: float = base_angle - spread_rad * 0.5
    for i in range(ways):
        var t: float = float(i) / float(ways - 1)
        var ang: float = start + t * spread_rad
        _spawn_bullet(origin, Vector2.RIGHT.rotated(ang), speed, params)

func _pattern_wall_with_gap(y: float, columns: int, gap_width: float, speed: float, dir: Vector2, params: Dictionary = {}) -> void:
    var cols: int = columns if columns > 1 else 1
    var step: float = playfield_rect.size.x / float(cols)
    var gap_center: float = _rng.randf_range(gap_width * 0.5, playfield_rect.size.x - gap_width * 0.5)
    var x: float = playfield_rect.position.x
    var end_x: float = playfield_rect.position.x + playfield_rect.size.x
    while x <= end_x:
        if absf((x - playfield_rect.position.x) - gap_center) > gap_width * 0.5:
            _spawn_bullet(Vector2(x, y), dir, speed, params)
        x += step

func _pattern_spiral_stream(origin: Vector2, duration: float, rate: float, speed: float, step_deg: float, params: Dictionary = {}) -> void:
    var shots: int = int(ceil(duration * rate))
    var wait: float = 1.0 / (rate if rate > 0.0001 else 0.0001)
    var ang: float = 0.0
    for i in range(shots):
        _spawn_bullet(origin, Vector2.RIGHT.rotated(ang), speed, params)
        ang += deg_to_rad(step_deg)
        await _timer(wait)

# --------------------------
# TIMELINE (origins now anchored to playfield)
# --------------------------
func _spawn_top_center() -> Vector2:
    return Vector2(
        playfield_rect.position.x + playfield_rect.size.x * 0.5,
        playfield_rect.position.y + spawn_margin + 8.0
    )

func _spawn_random_top() -> Vector2:
    var x_min: float = playfield_rect.position.x + spawn_margin
    var x_max: float = playfield_rect.position.x + playfield_rect.size.x - spawn_margin
    var x: float = _rng.randf_range(x_min, x_max)
    return Vector2(x, playfield_rect.position.y + spawn_margin + 8.0)

func _run_timeline() -> void:
    await _timer(0.2)
    while _running:
        var cfg: Dictionary = _cfg()
        var base_speed: float = float(cfg["speed"])

        # 1) Opening rings
        for burst in range(3):
            _pattern_ring(
                _spawn_top_center(),
                int(cfg["ring_count"]),
                base_speed,
                0.0,
                TAU,
                {
                    "angular_speed": 0.0 if difficulty == "easy" else (-0.6 if burst % 2 == 0 else 0.6),
                    "life_time": 6.0
                }
            )
            await _timer(0.7 if difficulty == "easy" else 0.55)

        # 2) Aimed spreads
        for salvo in range(5):
            _pattern_aimed_spread(
                _spawn_random_top(),
                int(cfg["spread_ways"]),
                float(cfg["spread_angle_deg"]),
                base_speed * 1.05,
                {"life_time": 6.5}
            )
            await _timer(0.38 if difficulty == "hard" else 0.45)

        # 3) Spiral stream
        await _pattern_spiral_stream(
            _spawn_top_center(),
            1.8 if difficulty == "easy" else (2.4 if difficulty == "normal" else 3.0),
            float(cfg["spiral_rate"]),
            base_speed * (0.9 if difficulty == "easy" else 1.0),
            float(cfg["spiral_step_deg"]),
            {"life_time": 7.0, "angular_speed": 0.0}
        )

        # 4) Sweeping walls with gap
        for sweep in range(3):
            var y: float = lerp(playfield_rect.position.y + 24.0,
                playfield_rect.position.y + playfield_rect.size.y * 0.45,
                float(sweep) / 2.0)
            _pattern_wall_with_gap(
                y,
                22,
                120.0 if difficulty == "easy" else 96.0,
                base_speed * 0.85,
                Vector2.DOWN,
                {"life_time": 5.0}
            )
            await _timer(0.85 if difficulty == "easy" else 0.7)

        # 5) Homing accents
        if difficulty != "easy":
            for i in range(6):
                _spawn_bullet(
                    _spawn_random_top(),
                    Vector2.DOWN,
                    base_speed * 0.8,
                    {
                        "homing": true,
                        "homing_turn_rate": float(cfg["homing_turn"]),
                        "life_time": 5.0
                    }
                )
                await _timer(0.25)

        await _timer(0.6)
