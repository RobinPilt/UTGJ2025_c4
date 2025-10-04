# res://scripts/minigame/Spawner.gd
extends Node2D

signal spawned_heart(heart: Node2D)
signal spawned_obstacle(obstacle: Node2D)

@export var heart_scene: PackedScene
@export var obstacle_scene: PackedScene

@export var heart_interval: float = 0.8
@export var obstacle_interval: float = 1.2
@export var spawn_margin: float = 24.0

var viewport_size: Vector2 = Vector2.ZERO
var _rng := RandomNumberGenerator.new()

@onready var heart_timer: Timer = $HeartTimer
@onready var obstacle_timer: Timer = $ObstacleTimer

func _ready() -> void:
    _rng.randomize()
    viewport_size = get_viewport_rect().size

    heart_timer.wait_time = heart_interval
    obstacle_timer.wait_time = obstacle_interval

    heart_timer.timeout.connect(_spawn_heart)
    obstacle_timer.timeout.connect(_spawn_obstacle)

    heart_timer.start()
    obstacle_timer.start()

func _spawn_heart() -> void:
    if not heart_scene:
        return
    var h := heart_scene.instantiate() as Node2D
    var x := _rng.randf_range(spawn_margin, viewport_size.x - spawn_margin)
    h.position = Vector2(x, -16.0)
    add_child(h)
    spawned_heart.emit(h)

func _spawn_obstacle() -> void:
    if not obstacle_scene:
        return
    var o := obstacle_scene.instantiate() as Node2D
    var x := _rng.randf_range(spawn_margin, viewport_size.x - spawn_margin)
    o.position = Vector2(x, -16.0)
    add_child(o)
    spawned_obstacle.emit(o)