# res://scripts/minigame/Obstacle.gd
extends Area2D

signal hit_player

@export var speed: float = 180.0
@export var direction: Vector2 = Vector2.DOWN

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
    position += direction * speed * delta
    var size := get_viewport_rect().size
    if position.y < -32.0 or position.y > size.y + 32.0 or position.x < -32.0 or position.x > size.x + 32.0:
        queue_free()

func _on_body_entered(body: Node) -> void:
    if body.is_in_group("player"):
        emit_signal("hit_player")
        queue_free()