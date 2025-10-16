extends Area2D

@export var value: int = 1
@export var speed: float = 120.0
@export var direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	# Auto-delete if off screen with small margin
	var size := get_viewport_rect().size
	if position.y < -32.0 or position.y > size.y + 32.0 or position.x < -32.0 or position.x > size.x + 32.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.collect_heart(value)
		queue_free()
